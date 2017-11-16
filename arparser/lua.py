# -*- coding: utf-8 -*-
"""
Define the objects representing lua specific items.

@author: skasch
"""

from .constants import WORD_REPLACEMENTS


class LuaNamed:
    """
    An abstract class for elements whose named in lua can be parsed from its
    name in simc.
    """

    def __init__(self, simc):
        self.simc = simc

    def lua_name(self):
        """
        Return the AethysRotation name of the spell.
        """
        ar_words = [word.title() for word in self.simc.split('_')]
        ar_words = [WORD_REPLACEMENTS[ar_word]
                    if ar_word in WORD_REPLACEMENTS else ar_word
                    for ar_word in ar_words]
        return ''.join(ar_words)


class LuaCastable:
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
        return Method('Cast')

    def cast_args(self):
        """
        The arguments of the method used to cast the action.
        """
        return [self]

    def cast(self):
        """
        Return the LuaExpression to cast the action.
        """
        return LuaExpression(Literal('AR'),
                             self.cast_method(), self.cast_args())

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


class LuaExpression:
    """
    Abstract class representing a generic lua expression in the form:
    object:method(args)
    """

    def __init__(self, object_, method, args):
        self.object_ = object_
        self.method = method
        self.args = args

    def print_lua(self):
        """
        Print the lua code for the expression
        """
        object_caller = f'{self.object_.print_lua()}:' if self.object_ else ''
        return (f'{object_caller}{self.method.print_lua()}('
                f'{", ".join(arg.print_lua() for arg in self.args)})')


class Method:
    """
    Represent a lua method.
    """

    def __init__(self, name):
        self.name = name

    def print_lua(self):
        """
        Print the method.
        """
        return self.name


class Literal:
    """
    Represent a literal expression (a value) as a string.
    """

    def __init__(self, value):
        self.value = value

    def print_lua(self):
        """
        Print the literal value.
        """
        return self.value
