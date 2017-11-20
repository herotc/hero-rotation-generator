# -*- coding: utf-8 -*-
"""
Define the objects representing simc executions.

@author: skasch
"""

from .lua import LuaNamed, LuaExpression, Literal, Method
from .modifiers import class_specific_conditions
from .constants import (SPELL, BUFF, DEBUFF,
                        USABLE_SKILLS, INTERRUPT_SKILLS,
                        GCD_AS_OFF_GCD, OFF_GCD_AS_OFF_GCD)


class Castable:
    """
    The class for castable elements: items and spells.
    """

    def condition_method(self):
        """
        Return the method to use in the default condition, which usually tests
        whether the action is doable.
        """
        pass

    def condition_args(self):
        """
        Return the arguments of the default condition, which usually tests
        whether the action is doable.
        """
        return []

    def condition(self):
        """
        Return the LuaExpression of the default condition.
        """
        return LuaExpression(self, self.condition_method(),
                             self.condition_args())

    def additional_conditions(self):
        """
        Additional conditions to test for the specific action; [] by default if
        none.
        """
        return []

    def conditions(self):
        """
        List of conditions to check before executing the action.
        """
        return [self.condition()] + self.additional_conditions()

    def print_conditions(self):
        """
        Print the lua code for the condition of the execution.
        """
        return ' and '.join(condition.print_lua()
                            for condition in self.conditions())

    def cast_method(self):
        """
        The method to call when executing the action.
        """
        return Method('AR.Cast')

    def cast_args(self):
        """
        The arguments of the method used to cast the action.
        """
        return [self]

    def cast(self):
        """
        Return the LuaExpression to cast the action.
        """
        return LuaExpression(None, self.cast_method(), self.cast_args())

    def cast_template(self):
        """
        The template of the code to execute the action; {} will be replaced by
        the result of self.cast().print_lua().
        """
        return 'if {} then return ""; end'

    def print_cast(self):
        """
        Print the lua code of what to do when casting the action.
        """
        return self.cast_template().format(self.cast().print_lua())


class Item(LuaNamed, Castable):
    """
    The Item class, used to represent an item.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action
        self.action.context.add_item(self)

    def condition_method(self):
        return Method('IsReady')

    def cast_method(self):
        return Method('AR.CastSuggested')

    def print_lua(self):
        """
        Print the lua representation of the item.
        """
        return f'I.{self.lua_name()}'


class Potion(Item):
    """
    The Potion class, to handle the specific case of a potion.
    """

    def __init__(self, action):
        super().__init__(action, action.player.potion())

    def additional_conditions(self):
        return [Literal('Settings.Commons.UsePotions')]


class RunActionList(LuaNamed, Castable):
    """
    The class to handle a run_action_string action; calls a function containing
    the code for the speficic ActionList called.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def conditions(self):
        return []

    def cast(self):
        return Literal(self.lua_name() + '()')

    def cast_template(self):
        return 'return {};'


class CallActionList(LuaNamed, Castable):
    """
    The class to handle a call_action_string action; calls a function containing
    the code for the speficic ActionList called.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def conditions(self):
        return []

    def cast(self):
        return Literal(self.lua_name() + '()')

    def cast_template(self):
        return ('local ShouldReturn = {}; '
                'if ShouldReturn then return ShouldReturn; end')


class Variable(LuaNamed):
    """
    The class to handle a variable action; this creates a new variable as a
    local function to compute a value used afterwards.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def print_lua(self):
        """
        Print the lua name of a variable.
        """
        return f'{self.lua_name()}'


class Spell(LuaNamed, Castable):
    """
    Represents a spell; it can be either a spell, a buff or a debuff.
    """

    TYPE_SUFFIX = {
        SPELL: '',
        BUFF: 'Buff',
        DEBUFF: 'Debuff',
    }

    def __init__(self, action, simc, type_=SPELL):
        super().__init__(simc)
        self.action = action
        self.type_ = type_
        self.action.context.add_spell(self)
    
    def lua_name(self):
        return f'{super().lua_name()}{self.TYPE_SUFFIX[self.type_]}'

    def condition_method(self):
        if self.simc in USABLE_SKILLS:
            return Method('IsUsable')
        return Method('IsCastable')

    def condition_args(self):
        return [self]

    @class_specific_conditions
    def additional_conditions(self):
        if self.simc in INTERRUPT_SKILLS:
            return [Literal('Settings.General.InterruptEnabled'),
                    LuaExpression(self.action.target,
                                  Method('IsInterruptible'), [])]
        return []

    def cast_method(self):
        if self.simc in INTERRUPT_SKILLS:
            return Method('AR.CastAnnotated')
        return Method('AR.Cast')

    def cast_args(self):
        args = [self]
        if self.simc in GCD_AS_OFF_GCD:
            args.append(Literal('Settings.'
                                f'{self.action.player.spec.lua_name()}.'
                                'GCDasOffGCD.'
                                f'{self.lua_name()}'))
        if self.simc in OFF_GCD_AS_OFF_GCD:
            args.append(Literal('Settings.'
                                f'{self.action.player.spec.lua_name()}.'
                                'OffGCDasOffGCD.'
                                f'{self.lua_name()}'))
        if self.simc in INTERRUPT_SKILLS:
            args.append(Literal('false'))
            args.append(Literal('"Interrupt"'))
        return args

    def print_lua(self):
        """
        Print the lua expression for the spell.
        """
        return f'S.{self.lua_name()}'
