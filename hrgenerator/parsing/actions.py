# -*- coding: utf-8 -*-
"""
Define the objects representing simc actions.

@author: skasch
"""

from ..objects.lua import Literal
from .conditions import ConditionExpression
from ..objects.executions import (Spell, Item, Potion, Variable, CancelBuff,
                                  RunActionList, CallActionList)
from ..abstract.helpers import indent, convert_type
from ..abstract.decoratormanager import Decorable
from ..constants import (SPELL, ITEM, POTION, VARIABLE, CANCEL_BUFF,
                         USE_ITEM, RUN_ACTION_LIST, CALL_ACTION_LIST,
                         ITEM_ACTIONS, BOOL, NUM, RANGE)
from re import search


class ActionList:
    """
    An action list; useful when the APL defines multiple named action lists to
    handle specific decision branchings.
    """

    def __init__(self, apl, simc, name='APL'):
        self.player = apl.player
        self.target = apl.target
        self.context = apl.context
        self.show_comments = apl.show_comments
        self.simc = simc
        self.pool_for_next = 0
        self.pool_extra_amount = 0
        self.name = Literal(name, convert=True)

    def split_simc(self):
        """
        Split the simc string of an action list into unique action simc strings.
        """
        return self.simc.split('/')

    def actions(self):
        """
        Return the list of action as Action instances of the ActionList.
        """
        return [Action(self, simc) for simc in self.split_simc()]

    def print_actions_lua(self):
        """
        Print the lua string for the actions of the list (without the function
        wrapper).
        """
        return '\n'.join(indent(action.print_lua())
                         for action in self.actions())

    def print_lua(self):
        """
        Print the lua string representing the action list.
        """
        actions = self.print_actions_lua()
        function_name = self.name.print_lua()
        return (f'{function_name} = function()\n'
                f'{actions}\n'
                f'end')


class Action(Decorable):
    """
    A single action in an action list. A action is of the form:
    \\actions.action_list_name+=/execution,if=condition_expression
    """

    def __init__(self, action_list, simc):
        self.action_list = action_list
        self.player = action_list.player
        self.target = action_list.target
        self.context = action_list.context
        self.show_comments = action_list.show_comments
        self.simc = simc
        self.operation_simc = None

    def split_simc(self):
        """
        Split the simc string of an action into its different properties
        strings.
        """
        return self.simc.split(',')

    def properties(self):
        """
        Return the named properties of the action; corresponds ton the elements
        of the form key=expression in a simc string.
        """
        props = {}
        for simc_prop in self.split_simc()[1:]:
            equal_index = simc_prop.find('=')
            simc_key = simc_prop[:equal_index]
            simc_val = simc_prop[equal_index + 1:]
            props[simc_key] = simc_val
        return props

    def execution(self):
        """
        Return the execution of the action (the thing to execute if the
        condition is fulfilled).
        """
        execution_string = self.split_simc()[0]
        return Execution(self, execution_string)

    def get_expression(self, key, **kwargs):
        """
        Return an expression from the name of the key to parse.
        """
        if key in self.properties():
            condition_expression = self.properties()[key]
        else:
            condition_expression = ''
        return ConditionExpression(self, condition_expression, **kwargs)

    def condition_expression(self, ifmode):
        """
        Return the condition expression of the action (the thing to test
        before doing the execution).
        """
        if self.operation() == 'setif':
            return self.get_expression('condition')
        ifexpression = self.get_expression(ifmode)
        return ifexpression

    def value_expression(self):
        """
        Return the value expression of the action (for a variable).
        """
        return self.get_expression('value', null_cond='')

    def condition_tree(self, ifmode):
        """
        Return the condition tree of the action (the tree form of the conditon
        expression).
        """
        return self.condition_expression(ifmode).grow()

    def value_tree(self):
        """
        Return the expression tree for the value attribute, in case of a
        variable action.
        """
        return self.value_expression().grow()

    def operation(self):
        """
        The operation of the action.
        """
        if not self.operation_simc:
            if 'op' in self.properties():
                self.operation_simc = self.properties()['op']
            else:
                self.operation_simc = 'set'
        return self.operation_simc

    def print_exec(self):
        """
        Print the execution line of the action.
        """
        if self.operation() == 'set':
            if self.action_list.pool_for_next > 0:
                extra_amount = str(self.action_list.pool_extra_amount or '')
                self.action_list.pool_for_next -= 1
                if self.action_list.pool_for_next == 0:
                    self.action_list.pool_extra_amount = 0
                exec_name = self.execution().object_().print_lua()
                exec_cast = self.execution().object_().print_cast()
                exec_value = convert_type(self.value_tree(), NUM)
                exec_link = ' = ' if exec_value != '' else ''
                exec_pool = Spell(self, 'pool_resource').print_cast()
                return (
                    f'if {exec_name}:IsUsablePPool({extra_amount}) then\n'
                    f'  {exec_cast}{exec_link}{exec_value}\n'
                    'else\n'
                    f'  {exec_pool}\n'
                    'end'
                )
            else:
                exec_cast = self.execution().object_().print_cast()
                exec_value = convert_type(self.value_tree(), NUM)
                exec_link = ' = ' if exec_value != '' else ''
                return f'{exec_cast}{exec_link}{exec_value}'
        elif self.operation() == 'reset':
            exec_cast = self.execution().object_().print_cast()
            exec_default = self.execution().object_().default
            return f'{exec_cast} = {exec_default}'
        elif self.operation() == 'max':
            exec_cast = self.execution().object_().print_cast()
            exec_value = convert_type(self.value_tree(), NUM)
            return f'{exec_cast} = math.max({exec_cast}, {exec_value})'
        elif self.operation() == 'min':
            exec_cast = self.execution().object_().print_cast()
            exec_value = convert_type(self.value_tree(), NUM)
            return f'{exec_cast} = math.min({exec_cast}, {exec_value})'
        elif self.operation() == 'add':
            exec_cast = self.execution().object_().print_cast()
            exec_value = convert_type(self.value_tree(), NUM)
            return f'{exec_cast} = {exec_cast} + {exec_value}'
        elif self.operation() == 'setif':
            exec_cast = self.execution().object_().print_cast()
            exec_value = convert_type(self.value_tree(), NUM)
            return f'{exec_cast} = {exec_value}'

    def print_exec_else(self):
        """
        Print the execution line of the action for the else case.
        """
        if self.operation() == 'setif':
            exec_cast = self.execution().object_().print_cast()
            exec_value = convert_type(
                self.get_expression('value_else', null_cond='').grow(), NUM)
            return (f'else\n'
                    f'  {exec_cast} = {exec_value}\n')
        return ''

    def print_cycle_targets(self, lua_string, condition, plustargetif=False):
        cycle_cast = ''
        self.target.unit_object = Literal('TargetUnit')
        self.range_ = self.player.spell_property(self.execution().object_(), RANGE, self.player.spec_range())
        if plustargetif:
            if_condition_tree = self.condition_tree('if')
            targetif_condition_tree = self.condition_tree('target_if')
            targetif_condition = convert_type(targetif_condition_tree, BOOL)
            if if_condition_tree.condition_expression.simc != '':
                if_condition = convert_type(if_condition_tree, BOOL)
                cycle_cast = f'if HR.CastCycle({self.execution().object_().print_lua()}, {str(self.range_)}, function(TargetUnit) return ({targetif_condition}) and ({if_condition}) end) then return "{self.execution().object_().return_string()}" end'
            else:
                cycle_cast = f'if HR.CastCycle({self.execution().object_().print_lua()}, {str(self.range_)}, function(TargetUnit) return {targetif_condition} end) then return "{self.execution().object_().return_string()}" end'
        else:
            if_condition_tree = self.condition_tree('if')
            if_condition = convert_type(if_condition_tree, BOOL)
            cycle_cast = f'if HR.CastCycle({self.execution().object_().print_lua()}, {str(self.range_)}, function(TargetUnit) return {if_condition} end) then return "{self.execution().object_().return_string()}" end'
        lua_string += ('\n'
                    f'if {condition.print_lua()} then\n'
                    f'{indent(cycle_cast)}\n'
                    f'end')
        self.target.unit_object = Literal('Target', convert=True)
        return lua_string

    def print_lua(self):
        """
        Print the lua expression of the action.
        """
        lua_string = ''
        if self.show_comments:
            lua_string += f'-- {self.simc}'
        if self.split_simc()[0] == 'pool_resource':
            for_next = int(self.properties().get('for_next', 1))
            extra_amount = int(self.properties().get('extra_amount', 0))
            self.action_list.pool_for_next = for_next
            self.action_list.pool_extra_amount = extra_amount
            return lua_string
        if self.split_simc()[0] == 'use_item' and 'slot' in self.simc:
            return lua_string
        exec_cast = self.print_exec()
        if exec_cast == '':
            return lua_string
        condition = self.execution().object_().conditions()
        if int(self.properties().get('moving', 0)) > 0:
            condition.add_condition(Literal('Player:IsMoving()'))
        
        # TODO: Make CycleTargets execution class
        if self.properties().get('cycle_targets'):
            return self.print_cycle_targets(lua_string, condition)

        if_condition_tree = self.condition_tree('if')
        targetif_condition_tree = self.condition_tree('target_if')
        if targetif_condition_tree.condition_expression.simc != '':
            mmax = search('min|max', targetif_condition_tree.condition_expression.simc)
            if mmax:
                cycle_cast = ''
                for idx, x in enumerate(targetif_condition_tree.condition.condition_list):
                    targetif_condition_tree.condition.condition_list[idx] = x.replace(f'{mmax.group(0)}:','')
                targetif_condition = convert_type(targetif_condition_tree, NUM)
                self.target.unit_object = Literal('TargetUnit')
                targetif_condition = convert_type(targetif_condition_tree, NUM)
                self.range_ = self.player.spell_property(self.execution().object_(), RANGE, self.player.spec_range())
                if if_condition_tree.condition_expression.simc != '':
                    if_condition = convert_type(if_condition_tree, BOOL)
                    cycle_cast = f'if HR.CastTargetIf({self.execution().object_().print_lua()}, {str(self.range_)}, "{mmax.group(0)}", function(TargetUnit) return {targetif_condition} end, function(TargetUnit) return {if_condition} end) then return "{self.execution().object_().return_string()}" end'
                else:
                    cycle_cast = f'if HR.CastTargetIf({self.execution().object_().print_lua()}, {str(self.range_)}, "{mmax.group(0)}", function(TargetUnit) return {targetif_condition} end) then return "{self.execution().object_().return_string()}" end'
                lua_string += ('\n'
                    f'if {condition.print_lua()} then\n'
                    f'{indent(cycle_cast)}\n'
                    f'end')
                self.target.unit_object = Literal('Target', convert=True)
                return lua_string
            else:
                return self.print_cycle_targets(lua_string, condition, plustargetif=True)
        if if_condition_tree.condition_expression.simc != '':
            if_condition = convert_type(if_condition_tree, BOOL)
            condition.add_condition(Literal(f'({if_condition})'))
        exec_else = self.print_exec_else()
        if condition.print_lua() == '':
            lua_string += ('\n'
                        f'if (true) then\n'
                        f'{indent(exec_cast)}\n'
                        f'{exec_else}'
                        f'end')
        else:
            lua_string += ('\n'
                        f'if {condition.print_lua()} then\n'
                        f'{indent(exec_cast)}\n'
                        f'{exec_else}'
                        f'end')
        return lua_string


class Execution(Decorable):
    """
    Represent an execution, what to do in a specific situation during the
    simulation.
    """

    def __init__(self, action, execution):
        self.action = action
        self.execution = execution

    def switch_type(self):
        """
        Return the couple type, object of the execution depending on its value.
        """
        if self.execution == POTION:
            type_, object_ = ITEM, Potion(self.action)
        elif self.execution in ITEM_ACTIONS:
            type_, object_ = ITEM, Item(self.action, self.execution)
        elif self.execution == USE_ITEM:
            item_name = self.action.properties().get('name', '')
            type_, object_ = ITEM, Item(self.action, item_name)
        elif self.execution == VARIABLE:
            variable_name = self.action.properties()['name']
            type_, object_ = VARIABLE, Variable(self.action, variable_name)
        elif self.execution == CANCEL_BUFF:
            buff_name = self.action.properties()['name']
            type_, object_ = CANCEL_BUFF, CancelBuff(self.action, buff_name)
        elif self.execution == RUN_ACTION_LIST:
            action_list_name = self.action.properties()['name']
            type_, object_ = (RUN_ACTION_LIST,
                              RunActionList(self.action, action_list_name))
        elif self.execution == CALL_ACTION_LIST:
            action_list_name = self.action.properties()['name']
            type_, object_ = (CALL_ACTION_LIST,
                              CallActionList(self.action, action_list_name))
        else:
            type_, object_ = SPELL, Spell(self.action, self.execution)
        return type_, object_

    def type_(self):
        """
        Get the type of the execution.
        """
        return self.switch_type()[0]

    def object_(self):
        """
        Get the object of the execution.
        """
        return self.switch_type()[1]


class PrecombatAction(Action):
    """
    Special action for precombat.
    """

    def __init__(self, apl):
        super().__init__(ActionList(apl, '', 'CallPrecombat'),
                         'call_action_list,name=precombat')

    def print_lua(self):
        lua_string = ''
        if self.show_comments:
            lua_string += f'-- call precombat'
        exec_cast = self.execution().object_().print_cast()
        lua_string += (
            '\n'
            f'if not Player:AffectingCombat() then\n'
            f'  {exec_cast}\n'
            f'end')
        return lua_string
