# -*- coding: utf-8 -*-
"""
Define the objects representing lua specific items.

@author: skasch
"""

from inspect import getargspec

from ..abstract.decoratormanager import Decorable
from ..constants import WORD_REPLACEMENTS, TRUE, FALSE, BOOL, NUM


class LuaNamed(Decorable):
    """
    An abstract class for elements whose named in lua can be parsed from its
    name in simc.
    """

    def __init__(self, simc):
        self.simc = simc

    def lua_name(self):
        """
        Return the HeroRotation name of the spell.
        """
        lua_words = [w.title() for w in self.simc.split('_')]
        lua_words = [WORD_REPLACEMENTS.get(w, w) for w in lua_words]
        lua_string = ''.join(lua_words)
        # Recapitalize first letter if lowered
        lua_string = lua_string[0].upper() + lua_string[1:]
        return lua_string


class LuaTyped(Decorable):
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


class LuaCastable(Decorable):
    """
    The class for castable elements: items and spells.
    """

    def __init__(self, cast_method=None, cast_args=None, cast_template=None):
        self.condition_method = None
        self.condition_args = []
        self.additional_conditions = []
        self.cast_method = cast_method or Method('HR.Cast')
        self.cast_args = [self] if cast_args is None else cast_args
        self.cast_template = cast_template or 'if {} then return ""; end'

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


class Method(Decorable):
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


class BuildExpression(Decorable):
    """
    Build an expression from a call.
    """

    def __init__(self, call, model=LuaExpression):
        self.model = model
        self.content = None
        call = 'ready' if call == 'up' else call
        if call:
            getattr(self, call)()
        self.apply_model()

    def apply_model(self):
        """
        Call the right builder depending on the model.
        """
        # getargspec returns the trace of the model. For example, for LuaRange:
        # arg_spec.args = ['self', 'condition', 'range_', 'type_']
        # arg_spec.defaults = (None,)
        # As defaults are for the last args, we know type_=None by default.
        try:
            arg_spec = getargspec(self.model)
            arg_names = arg_spec.args[1:-len(arg_spec.defaults)]
            kwarg_names = arg_spec.args[-len(arg_spec.defaults):]
            self.try_builder(self.model, arg_names, kwarg_names)
        except AttributeError:
            raise AttributeError(f'The model {self.model.__name__} '
                                 'is invalid.')

    def try_builder(self, model, arg_names, kwarg_names):
        """
        Try to build the model.
        """
        try:
            args = [getattr(self, arg_name) for arg_name in arg_names]
            kwargs = {kwarg_name: getattr(self, kwarg_name)
                      for kwarg_name in kwarg_names
                      if hasattr(self, kwarg_name)}
            self.content = model(*args, **kwargs)
        except AttributeError:
            missing_attr = [arg_name for arg_name in arg_names
                            if not hasattr(self, arg_name)]
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
