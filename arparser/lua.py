# -*- coding: utf-8 -*-
"""
Define the objects representing lua specific items.

@author: skasch
"""

from .constants import WORD_REPLACEMENTS, TRUE, FALSE, BOOL, NUM


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
        ar_string = ''.join(ar_words)
        # Recapitalize first letter if lowered
        ar_string = ar_string[0].upper() + ar_string[1:]
        return ar_string


class LuaTyped:
    """
    An abstract class for elements who have a lua type.
    """

    def __init__(self, type_=NUM):
        self.type_ = type_

    def lua_type(self):
        """
        Return the lua type of the object.
        """
        return self.type_


class LuaCastable:
    """
    The class for castable elements: items and spells.
    """

    def __init__(self):
        self.condition_method = None
        self.condition_args = []
        self.additional_conditions = []
        self.cast_method = Method('AR.Cast')
        self.cast_args = [self]
        self.cast_template = 'if {} then return ""; end'

    def main_condition(self):
        """
        Return the LuaExpression of the default condition.
        """
        return LuaExpression(self, self.condition_method, self.condition_args)

    def conditions(self):
        """
        List of conditions to check before executing the action.
        """
        return [self.main_condition()] + self.additional_conditions

    def print_conditions(self):
        """
        Print the lua code for the condition of the execution.
        """
        return ' and '.join(condition.print_lua()
                            for condition in self.conditions())

    def cast(self):
        """
        Return the LuaExpression to cast the action.
        """
        return LuaExpression(None, self.cast_method, self.cast_args)

    def print_cast(self):
        """
        Print the lua code of what to do when casting the action.
        """
        return self.cast_template.format(self.cast().print_lua())


class LuaExpression(LuaTyped):
    """
    Abstract class representing a generic lua expression in the form:
    object:method(args)
    """

    def __init__(self, object_, method, args, type_=None, array=False):
        self.array = array
        self.object_ = object_
        self.method = method
        self.args = args
        if type_:
            super().__init__(type_)
        elif method.type_:
            super().__init__(method.type_)
        else:
            super().__init__()

    def template(self):
        """
        The template for the expression, depending on if it's an array or not.
        """
        if self.array:
            return '{}{}[{}]'
        return '{}{}({})'

    def print_lua(self):
        """
        Print the lua code for the expression.
        """
        object_caller = f'{self.object_.print_lua()}:' if self.object_ else ''
        return self.template().format(
            object_caller,
            self.method.print_lua(),
            ', '.join(arg.print_lua() for arg in self.args)
        )


class BuildExpression(LuaExpression):
    """
    Build an expression from a call.
    """

    def __init__(self, call, array=False):
        call = 'ready' if call == 'up' else call
        self.array = array
        if call:
            getattr(self, call)()
        super().__init__(self.object_, self.method, self.args, array=self.array)


class LuaComparison(LuaTyped):
    """"
    Abstract class representing a generic lua comparison of the form:
    exp1 <comp> exp2.
    """

    def __init__(self, exp1, exp2, symbol):
        self.exp1 = exp1
        self.exp2 = exp2
        self.symbol = symbol
        super().__init__(type_=BOOL)

    def print_lua(self):
        """
        Print the lua code for the comparison.
        """
        return (f'({self.exp1.print_lua()} {self.symbol} '
                f'{self.exp2.print_lua()})')


class Method:
    """
    Represent a lua method.
    """

    def __init__(self, name, type_=None):
        self.name = name
        self.type_ = type_

    def print_lua(self):
        """
        Print the method.
        """
        return self.name


class Literal(LuaTyped, LuaNamed):
    """
    Represent a literal expression (a value) as a string.
    """

    def __init__(self, simc=None, type_=None, convert=False, quoted=False):
        if simc is not None:
            self.simc = simc
        self.convert = convert
        self.quoted = quoted
        if not type_:
            type_ = BOOL if self.simc in (TRUE, FALSE) else NUM
        super().__init__(type_)

    def print_lua(self):
        """
        Print the literal value.
        """
        result = ''
        if self.convert:
            result = self.lua_name()
        else:
            result = str(self.simc)
        if self.quoted:
            result = f'"{result}"'
        return result
