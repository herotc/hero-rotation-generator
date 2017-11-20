# -*- coding: utf-8 -*-
"""
Define the objects representing simc actions.

@author: skasch
"""

from .lua import LuaNamed
from .helpers import indent
from .conditions import ConditionExpression
from .executions import (Spell, Item, Potion, Variable,
                         RunActionList, CallActionList)
from .constants import (SPELL, ITEM, POTION, VARIABLE,
                        RUN_ACTION_LIST, CALL_ACTION_LIST,
                        ITEM_ACTIONS)


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
        self.name = LuaNamed(name)

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
        function_name = self.name.lua_name()
        return (f'local function {function_name}()\n'
                f'{actions}\n'
                f'end')


class Action:
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
        condition is fulfulled).
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

    def condition_expression(self):
        """
        Return the condition expression of the action (the thing to test
        before doing the execution).
        """
        return self.get_expression('if')

    def value_expression(self):
        """
        Return the value expression of the action (for a variable).
        """
        return self.get_expression('value', null_cond='')

    def condition_tree(self):
        """
        Return the condition tree of the action (the tree form of the conditon
        expression).
        """
        return self.condition_expression().grow()

    def value_tree(self):
        """
        Return the expression tree for the value attribute, in case of a
        variable action.
        """
        return self.value_expression().grow()

    def print_exec(self):
        """
        Print the execution line of the action.
        """
        if 'op' in self.properties():
            operation = self.properties()['op']
        else:
            operation = 'set'
        if operation == 'set':
            exec_cast = self.execution().object_().print_cast()
            exec_value = self.value_tree().print_lua()
            exec_link = ' = ' if exec_value != '' else ''
            return f'{exec_cast}{exec_link}{exec_value}'
        elif operation == 'reset':
            exec_cast = self.execution().object_().print_cast()
            exec_default = self.execution().object_().default
            return f'{exec_cast} = {exec_default}'
        elif operation == 'max':
            exec_cast = self.execution().object_().print_cast()
            exec_value = self.value_tree().print_lua()
            return f'{exec_cast} = math.max({exec_cast}, {exec_value})'
        elif operation == 'min':
            exec_cast = self.execution().object_().print_cast()
            exec_value = self.value_tree().print_lua()
            return f'{exec_cast} = math.min({exec_cast}, {exec_value})'

    def print_lua(self):
        """
        Print the lua expression of the action.
        """
        lua_string = ''
        if self.show_comments:
            lua_string += f'-- {self.simc}\n'
        exec_cond = self.execution().object_().print_conditions()
        cond_link = ' and ' if exec_cond != '' else ''
        if_cond = self.condition_tree().print_lua()
        lua_string += (f'if {exec_cond}{cond_link}({if_cond}) then\n'
                       f'  {self.print_exec()}\n'
                       f'end')
        return lua_string


class Execution:
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
        elif self.execution == VARIABLE:
            variable_name = self.action.properties()['name']
            type_, object_ = VARIABLE, Variable(self.action, variable_name)
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
