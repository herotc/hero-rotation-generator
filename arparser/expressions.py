# -*- coding: utf-8 -*-
"""
Define the objects representing simc expressions.

@author: skasch
"""

from .lua import LuaNamed, LuaExpression, Method, Literal
from .executions import Spell
from .constants import BUFF, DEBUFF, BOOL


class Expression:
    """
    Represent a singleton condition (i.e. without any operator).
    """

    def __init__(self, condition_expression, simc):
        self.condition_expression = condition_expression
        self.parent_action = condition_expression.action
        self.simc = simc

    def expression(self):
        """
        Return the expression of the condition.
        """
        if (self.condition_list()[0] in self.actions_to_self()
                and len(self.condition_list()) == 1):
            return self.action(to_self=True)
        try:
            return getattr(self, self.condition_list()[0])()
        except AttributeError:
            return Literal(self.simc)

    def actions_to_self(self):
        """
        The list of actions that can be applied to self (i.e. the execution of
        the action) for shortcut.
        """
        return [method for method in dir(ActionExpression)
                if callable(getattr(ActionExpression, method))
                and not method.startswith('__') and not method == 'print_lua']

    def condition_list(self):
        """
        Return the splitted structure of the condition.
        """
        return self.simc.split('.')

    def action(self, to_self=False):
        """
        Return the condition when the prefix is action.
        """
        return ActionExpression(self, to_self)

    def set_bonus(self):
        """
        Return the condition when the prefix is set_bonus.
        """
        return SetBonus(self)

    def cooldown(self):
        """
        Return the condition when the prefix is cooldown.
        """
        return Cooldown(self)

    def buff(self):
        """
        Return the condition when the prefix is buff.
        """
        return Buff(self)

    def debuff(self):
        """
        Return the condition when the prefix is buff.
        """
        return Debuff(self)

    def prev_gcd(self):
        """
        Return the condition when the prefix is prev_gcd.
        """
        return PrevGCD(self)

    def gcd(self):
        """
        Return the condition when the prefix is gcd.
        """
        return GCD(self)

    def time(self):
        """
        Return the condition when the prefix is time.
        """
        return Time(self)

    def runic_power(self):
        """
        Return the condition when the prefix is runic_power.
        """
        return RunicPower(self)

    def fury(self):
        """
        Return the condition when the prefix is fury.
        """
        return Fury(self)

    def mana(self):
        """
        Return the condition when the prefix is mana.
        """
        return Mana(self)

    def talent(self):
        """
        Return the condition when the prefix is talent.
        """
        return Talent(self)

    def charges_fractional(self):
        """
        Return the condition when the prefix is charges_fractional.
        """
        return LuaExpression(Spell(self.parent_action, 'blood_boil'),
                             Method('ChargesFractional'), [])

    def rune(self):
        """
        Return the condition when the prefix is rune.
        """
        return Rune(self)

    def target(self):
        """
        Return the condition when the prefix is target.
        """
        return TargetExpression(self)

    def variable(self):
        """
        Return the condition when the prefix is variable.
        """
        lua_varname = LuaNamed(self.condition_list()[1]).lua_name()
        return Literal(lua_varname)


class ActionExpression(LuaExpression):
    """
    Represent the expression for a action. condition.
    """

    def __init__(self, condition, to_self=False):
        self.condition = condition
        self.to_self = to_self
        if to_self:
            call = condition.condition_list()[0]
        else:
            call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def action_object(self):
        """
        The object of the action, depending on whether the action is applied to
        self (i.e. the execution) or not.
        """
        if self.to_self:
            return self.condition.parent_action.execution().object_()
        else:
            return Spell(self.condition.parent_action,
                         self.condition.condition_list()[1])

    def execute_time(self):
        """
        Return the arguments for the expression action.spell.execute_time.
        """
        object_ = self.action_object()
        method = Method('ExecuteTime')
        args = []
        return object_, method, args

    def recharge_time(self):
        """
        Return the arguments for the expression action.spell.recharge_time.
        """
        object_ = self.action_object()
        method = Method('RechargeP')
        args = []
        return object_, method, args

    def full_recharge_time(self):
        """
        Return the arguments for the expression action.spell.full_recharge_time.
        """
        object_ = self.action_object()
        method = Method('FullRechargeTimeP')
        args = []
        return object_, method, args

    def cast_time(self):
        """
        Return the arguments for the expression action.spell.cast_time.
        """
        object_ = self.action_object()
        method = Method('CastTime')
        args = []
        return object_, method, args

    def charges(self):
        """
        Return the arguments for the expression action.spell.charges.
        """
        object_ = self.action_object()
        method = Method('ChargesP')
        args = []
        return object_, method, args

    def usable_in(self):
        """
        Return the arguments for the expression action.spell.usable_in.
        """
        object_ = self.action_object()
        method = Method('UsableInP')
        args = []
        return object_, method, args


class SetBonus(Literal):
    """
    Represent the expression for a set_bonus. condition.
    """

    def __init__(self, condition):
        lua_tier = f'AC.{self.lua_tier_name(condition)}'
        super().__init__(lua_tier, type_=BOOL)

    def lua_tier_name(self, condition):
        """
        Parse the lua name for the tier variable name holding whether a tier set
        is equipped or not.
        """
        simc = condition.condition_list()[1]
        return '_'.join(word.title() for word in simc.split('_'))


class PrevGCD(LuaExpression):
    """
    Represent the expression for a prev_gcd. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def value(self):
        """
        Return the arguments for the expression prev_gcd.
        """
        object_ = self.condition.parent_action.player
        method = Method('PrevGCD')
        args = [
            Literal(self.condition.condition_list()[1]),
            Spell(self.condition.parent_action,
                  self.condition.condition_list()[2])
        ]
        return object_, method, args


class GCD(LuaExpression):
    """
    Represent the expression for a gcd. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def remains(self):
        """
        Return the arguments for the expression gcd.remains.
        """
        object_ = self.condition.parent_action.player
        method = Method('GCDRemains')
        args = []
        return object_, method, args

    def value(self):
        """
        Return the arguments for the expression gcd.
        """
        object_ = self.condition.parent_action.player
        method = Method('GCD')
        args = []
        return object_, method, args


class Time(LuaExpression):
    """
    Represent the expression for a time. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)
    
    def value(self):
        """
        Return the arguments for the expression time.
        """
        object_ = None
        method = Method('AC.CombatTime')
        args = []
        return object_, method, args


class Rune(LuaExpression):
    """
    Represent the expression for a rune. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def time_to_3(self):
        """
        Return the arguments for the expression rune.time_to_3.
        """
        object_ = self.condition.parent_action.player
        method = Method('RuneTimeToX')
        args = [Literal('3')]
        return object_, method, args


class Talent(LuaExpression):
    """
    Represent the expression for a talent. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def enabled(self):
        """
        Return the arguments for the expression talent.spell.enabled.
        """
        object_ = Spell(self.condition.parent_action,
                        self.condition.condition_list()[1])
        method = Method('IsAvailable', type_=BOOL)
        args = []
        return object_, method, args


class RunicPower(LuaExpression):
    """
    Represent the expression for a runic_power. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def deficit(self):
        """
        Return the arguments for the expression runic_power.deficit.
        """
        object_ = self.condition.parent_action.player
        method = Method('RunicPowerDeficit')
        args = []
        return object_, method, args

    def value(self):
        """
        Return the arguments for the expression runic_power.
        """
        object_ = self.condition.parent_action.player
        method = Method('RunicPower')
        args = []
        return object_, method, args

    def pct(self):
        """
        Return the arguments for the expression runic_power.pct.
        """
        object_ = self.condition.parent_action.player
        method = Method('RunicPowerPercentage')
        args = []
        return object_, method, args


class Fury(LuaExpression):
    """
    Represent the expression for a fury. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def deficit(self):
        """
        Return the arguments for the expression fury.deficit.
        """
        object_ = self.condition.parent_action.player
        method = Method('FuryDeficit')
        args = []
        return object_, method, args

    def value(self):
        """
        Return the arguments for the expression fury.
        """
        object_ = self.condition.parent_action.player
        method = Method('Fury')
        args = []
        return object_, method, args

    def pct(self):
        """
        Return the arguments for the expression fury.pct.
        """
        object_ = self.condition.parent_action.player
        method = Method('FuryPercentage')
        args = []
        return object_, method, args


class Mana(LuaExpression):
    """
    Represent the expression for a mana. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def deficit(self):
        """
        Return the arguments for the expression mana.deficit.
        """
        object_ = self.condition.parent_action.player
        method = Method('ManaDeficit')
        args = []
        return object_, method, args

    def value(self):
        """
        Return the arguments for the expression mana.
        """
        object_ = self.condition.parent_action.player
        method = Method('Mana')
        args = []
        return object_, method, args

    def pct(self):
        """
        Return the arguments for the expression mana.pct.
        """
        object_ = self.condition.parent_action.player
        method = Method('ManaPercentage')
        args = []
        return object_, method, args


class Debuff(LuaExpression):
    """
    Represent the expression for a debuff. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[2]
        call = 'ready' if call == 'up' else call
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def ready(self):
        """
        Return the arguments for the expression debuff.spell.up.
        """
        object_ = self.condition.parent_action.player
        method = Method('Debuff', type_=BOOL)
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], DEBUFF)]
        return object_, method, args

    def down(self):
        """
        Return the arguments for the expression debuff.spell.down.
        """
        object_ = self.condition.parent_action.player
        method = Method('DebuffDown', type_=BOOL)
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], DEBUFF)]
        return object_, method, args

    def stack(self):
        """
        Return the arguments for the expression debuff.spell.stack.
        """
        object_ = self.condition.parent_action.player
        method = Method('DebuffStack')
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], DEBUFF)]
        return object_, method, args

    def remains(self):
        """
        Return the arguments for the expression debuff.spell.remains.
        """
        object_ = self.condition.parent_action.player
        method = Method('DebuffRemainsP')
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], DEBUFF)]
        return object_, method, args


class Buff(LuaExpression):
    """
    Represent the expression for a buff. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[2]
        call = 'ready' if call == 'up' else call
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def ready(self):
        """
        Return the arguments for the expression buff.spell.up.
        """
        object_ = self.condition.parent_action.player
        method = Method('Buff', type_=BOOL)
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], BUFF)]
        return object_, method, args

    def down(self):
        """
        Return the arguments for the expression buff.spell.down.
        """
        object_ = self.condition.parent_action.player
        method = Method('BuffDown', type_=BOOL)
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], BUFF)]
        return object_, method, args

    def stack(self):
        """
        Return the arguments for the expression buff.spell.stack.
        """
        object_ = self.condition.parent_action.player
        method = Method('BuffStackP')
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], BUFF)]
        return object_, method, args

    def remains(self):
        """
        Return the arguments for the expression buff.spell.remains.
        """
        object_ = self.condition.parent_action.player
        method = Method('BuffRemainsP')
        args = [Spell(self.condition.parent_action,
                      self.condition.condition_list()[1], BUFF)]
        return object_, method, args


class Cooldown(LuaExpression):
    """
    Represent the expression for a cooldown. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 2:
            call = condition.condition_list()[2]
        else:
            call = 'remains'
        call = 'ready' if call == 'up' else call
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def ready(self):
        """
        Return the arguments for the expression cooldown.spell.ready.
        """
        object_ = Spell(self.condition.parent_action,
                        self.condition.condition_list()[1])
        method = Method('IsReady', type_=BOOL)
        args = []
        return object_, method, args

    def remains(self):
        """
        Return the arguments for the expression cooldown.spell.remains.
        """
        if len(self.condition.condition_list()) > 1:
            object_ = Spell(self.condition.parent_action,
                            self.condition.condition_list()[1])
        else:
            object_ = self.condition.parent_action.execution().object_()
        method = Method('CooldownRemainsP')
        args = []
        return object_, method, args


class TargetExpression(LuaExpression):
    """
    Represent the expression for a target. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)

    def time_to_die(self):
        """
        Return the arguments for the expression cooldown.spell.ready.
        """
        object_ = self.condition.parent_action.target
        method = Method('TimeToDie')
        args = []
        return object_, method, args
