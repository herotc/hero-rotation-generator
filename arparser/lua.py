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

    def __init__(self, type_=None):
        if type_ is None:
            self.type_ = NUM
        else:
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

    def __init__(self, cast_method=None, cast_args=None, cast_template=None):
        self.condition_method = None
        self.condition_args = []
        self.additional_conditions = []
        if cast_method is None:
            self.cast_method = Method('AR.Cast')
        else:
            self.cast_method = cast_method
        if cast_args is None:
            self.cast_args = [self]
        else:
            self.cast_args = cast_args
        if cast_template is None:
            self.cast_template = 'if {} then return ""; end'
        else:
            self.cast_template = cast_template

    def main_condition(self):
        """
        Return the LuaExpression of the default condition.
        """
        if self.condition_method is None:
            return []
        return [LuaExpression(self, self.condition_method, self.condition_args)]

    def conditions(self):
        """
        List of conditions to check before executing the action.
        """
        return self.main_condition() + self.additional_conditions

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


class LuaTemplated(LuaTyped):
    """
    Abstract class representing a generic lua expression in the form:
    object:method(args)
    """

    def __init__(self, **kwargs):
        self.lua_keys = []
        self.template = ''
        self.attributes = kwargs
        try:
            super().__init__(self.type_)
        except AssertionError:
            super().__init__()

    def print_lua(self):
        """
        Print the lua code for the composite object.
        """
        return self.template.format(**self.attributes)


class LuaExpression(LuaTemplated):
    """
    Abstract class representing a generic lua expression in the form:
    object:method(args)
    """

    def __init__(self, object_, method, args, type_=None):
        if type_ is not None:
            self.type_ = type_
        else:
            try:
                self.type_ = method.type_
            except AttributeError:
                self.type_ = None
        lua_object = object_.print_lua() if object_ else ''
        link = ':' if object_ else ''
        lua_args = ', '.join(arg.print_lua() for arg in args)
        LuaTemplated.__init__(self,
                              object_=lua_object,
                              link=link,
                              method=method.print_lua(),
                              args=lua_args)
        self.template = '{object_}{link}{method}({args})'


class LuaArray(LuaTemplated):
    """
    Abstract class representing a lua array call of the form: object:array[idx]
    """

    def __init__(self, object_, method, index, type_=None):
        if type_ is not None:
            self.type_ = type_
        else:
            try:
                self.type_ = method.type_
            except AttributeError:
                self.type_ = None
        lua_object = object_.print_lua() if object_ else ''
        link = ':' if object_ else ''
        LuaTemplated.__init__(self,
                              object_=lua_object,
                              link=link,
                              method=method.print_lua(),
                              index=str(index))
        self.template = '{object_}{link}{method}[{index}]'


class LuaRange(LuaArray):
    """
    Abstract class representing a lua call for a range check:
    Cache.EnemiesCount[idx]
    """

    def __init__(self, condition, range_, type_=None):
        condition.parent_action.context.add_range(range_)
        LuaArray.__init__(self,
                          object_=None,
                          method=Method('Cache.EnemiesCount'),
                          index=range_,
                          type_=type_)


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


class Literal(LuaTemplated, LuaNamed):
    """
    Represent a literal expression (a value) as a string.
    """

    def __init__(self, simc=None, convert=False, quoted=False, type_=None):
        if simc is not None:
            LuaNamed.__init__(self, simc)
        self.convert = convert
        self.quoted = quoted
        if type_ is not None:
            self.type_ = type_
        else:
            self.type_ = BOOL if self.simc in (TRUE, FALSE) else NUM
        LuaTemplated.__init__(self, value=self.get_value())
        if self.quoted:
            self.template = '"{value}"'
        else:
            self.template = '{value}'

    def get_value(self):
        """
        Return the lua value for the literal.
        """
        if self.convert:
            return self.lua_name()
        return str(self.simc)


class BuildExpression:
    """
    Build an expression from a call.
    """

    def __init__(self, call, model='expression'):
        self.model = model
        self.content = None
        call = 'ready' if call == 'up' else call
        if call:
            getattr(self, call)()
        self.switch_model()

    def switch_model(self):
        """
        Call the right builder depending on the model.
        """
        if self.model == 'array':
            type_ = getattr(self, 'type_', None)
            self.try_builder(LuaArray, ['object_', 'method', 'index'],
                             type_=type_)
        elif self.model == 'range':
            type_ = getattr(self, 'type_', None)
            self.try_builder(LuaRange, ['condition', 'range_'], type_=type_)
        elif self.model == 'expression':
            type_ = getattr(self, 'type_', None)
            self.try_builder(LuaExpression, ['object_', 'method', 'args'],
                             type_=type_)
        elif self.model == 'literal':
            convert = getattr(self, 'convert', False)
            quoted = getattr(self, 'quoted', False)
            type_ = getattr(self, 'type_', None)
            self.try_builder(Literal, ['simc'], convert=convert, quoted=quoted,
                             type_=type_)
        else:
            raise AttributeError(f'The model {self.model} is invalid.')

    def try_builder(self, model, attributes, **kwargs):
        """
        Try to build the model.
        """
        try:
            args = [getattr(self, attribute) for attribute in attributes]
            self.content = model(*args, **kwargs)
        except AttributeError:
            missing_attr = [not hasattr(self, attribute)
                            for attribute in attributes]
            error_msg = (f'The {model.__name__} model did not have the '
                         f'following attributes: {", ".join(missing_attr)}')
            raise AttributeError(error_msg)
    
    @classmethod
    def build(cls, *args, **kwargs):
        """
        Build the expression and return its content.
        """
        obj = cls(*args, **kwargs)
        return obj.content
