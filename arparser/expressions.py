# -*- coding: utf-8 -*-
"""
Define the objects representing simc expressions.

@author: skasch
"""

from .lua import LuaNamed, LuaExpression, Method, Literal
from .executions import Spell, Item
from .druid import balance_astral_power_value
from .constants import SPELL, BUFF, DEBUFF, BOOL, BLOODLUST


def auto_expression(fun):
    """
    Auto complete an expression builder with object_, method and args properties
    of the object if they are None.
    """

    def express(self):
        """
        Return the object_, method and args to build the LuaExpression.
        """
        object_, method, args = fun(self)
        if object_ is None:
            object_ = self.object_
        if method is None:
            method = self.method
        if args is None:
            args = self.args
        return object_, method, args

    return express


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

    def spell_haste(self):
        """
        Return the condition when the prefix is spell_haste.
        """
        return LuaExpression(self.parent_action.player,
                             Method('SpellHaste'), [])

    def set_bonus(self):
        """
        Return the condition when the prefix is set_bonus.
        """
        return SetBonus(self)

    def equipped(self):
        """
        Return the condition when the prefix is equipped.
        """
        return Equipped(self)

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
        Return the condition when the prefix is debuff.
        """
        return Debuff(self)

    def dot(self):
        """
        Return the condition when the prefix is dot.
        """
        return Dot(self)

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

    def astral_power(self):
        """
        Return the condition when the prefix is astral_power.
        """
        return AstralPower(self)

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


class BuildExpression(LuaExpression):
    """
    Build an expression from a call.
    """

    def __init__(self, call):
        call = 'ready' if call == 'up' else call
        object_, method, args = getattr(self, call)()
        super().__init__(object_, method, args)


class Expires:
    """
    Represent the expression for conditions with expiration times.
    """

    def __init__(self, condition, simc, ready_simc, spell_type=SPELL,
                 spell=None):
        self.condition = condition
        self.simc = LuaNamed(simc)
        self.ready_simc = LuaNamed(ready_simc)
        if not spell:
            spell_simc = condition.condition_list()[1]
            if spell_simc == BLOODLUST:
                self.spell = Literal(BLOODLUST)
            else:
                self.spell = Spell(condition.parent_action, spell_simc,
                                   spell_type)
        else:
            self.spell = spell
        self.object_ = self.spell
        self.args = []

    @auto_expression
    def ready(self):
        """
        Return the arguments for the expression {expires}.spell.up.
        """
        if self.spell.simc == BLOODLUST:
            method = Method('HasHeroism', type_=BOOL)
            args = []
        else:
            method = Method(f'{self.ready_simc.lua_name()}P', type_=BOOL)
            args = self.args
        return None, method, args

    @auto_expression
    def remains(self):
        """
        Return the arguments for the expression {expires}.spell.remains.
        """
        if self.spell.simc == BLOODLUST:
            method = Method('HasHeroism', type_=BOOL)
            args = []
        else:
            method = Method(f'{self.simc.lua_name()}RemainsP')
            args = self.args
        return None, method, args

    @auto_expression
    def duration(self):
        """
        Return the arguments for the expression {aura}.spell.duration.
        """
        method = Method('BaseDuration')
        return None, method, None


class Aura(Expires):
    """
    Represent the expression for auras (buffs and debuffs).
    """

    def __init__(self, condition, simc, object_, spell_type=SPELL, spell=None):
        super().__init__(condition, simc, simc, spell_type=spell_type,
                         spell=spell)
        self.object_ = object_
        self.args = [self.spell]

    @auto_expression
    def down(self):
        """
        Return the arguments for the expression {aura}.spell.down.
        """
        if self.spell.simc == BLOODLUST:
            method = Method('HasNotHeroism', type_=BOOL)
            args = []
        else:
            method = Method(f'{self.simc.lua_name()}DownP', type_=BOOL)
            args = self.args
        return None, method, args

    @auto_expression
    def stack(self):
        """
        Return the arguments for the expression {aura}.spell.stack.
        """
        if self.spell.simc == BLOODLUST:
            method = Method('HasHeroism', type_=BOOL)
            args = []
        else:
            method = Method(f'{self.simc.lua_name()}StackP')
            args = self.args
        return None, method, args

    def react(self):
        """
        Return the arguments for the expression {aura}.spell.stack.
        """
        return self.stack()

    @auto_expression
    def duration(self):
        """
        Return the arguments for the expression {aura}.spell.duration.
        """
        object_ = self.spell
        method = Method('BaseDuration')
        args = []
        return object_, method, args


class ActionExpression(BuildExpression):
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
        self.object_ = self.action_object()
        self.args = []
        super().__init__(call)

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

    def action_aura(self):
        """
        The action aura when referring to the action as a buff or debuff.
        """
        if self.condition.parent_action.player.spell_property(
                self.action_object(), DEBUFF):
            aura_type = DEBUFF
            aura_object = self.condition.parent_action.target
        else:
            aura_type = BUFF
            aura_object = self.condition.parent_action.player
        return Aura(self.condition, aura_type, aura_object,
                    spell=self.action_object())

    @auto_expression
    def execute_time(self):
        """
        Return the arguments for the expression action.spell.execute_time.
        """
        method = Method('ExecuteTime')
        return None, method, None

    @auto_expression
    def recharge_time(self):
        """
        Return the arguments for the expression action.spell.recharge_time.
        """
        method = Method('RechargeP')
        return None, method, None

    @auto_expression
    def full_recharge_time(self):
        """
        Return the arguments for the expression action.spell.full_recharge_time.
        """
        method = Method('FullRechargeTimeP')
        return None, method, None

    @auto_expression
    def cast_time(self):
        """
        Return the arguments for the expression action.spell.cast_time.
        """
        method = Method('CastTime')
        return None, method, None

    @auto_expression
    def charges(self):
        """
        Return the arguments for the expression action.spell.charges.
        """
        method = Method('ChargesP')
        return None, method, None

    @auto_expression
    def cooldown(self):
        """
        Return the arguments for the expression action.spell.charges.
        """
        method = Method('Cooldown')
        return None, method, None

    @auto_expression
    def usable_in(self):
        """
        Return the arguments for the expression action.spell.usable_in.
        """
        method = Method('UsableInP')
        return None, method, None

    def ready(self):
        """
        Return the arguments for the expression action.spell.ready.
        """
        return self.action_aura().ready()

    def remains(self):
        """
        Return the arguments for the expression action.spell.remains.
        """
        return self.action_aura().remains()

    def down(self):
        """
        Return the arguments for the expression action.spell.down.
        """
        return self.action_aura().down()

    def stack(self):
        """
        Return the arguments for the expression action.spell.stack.
        """
        return self.action_aura().stack()

    def react(self):
        """
        Return the arguments for the expression action.spell.react.
        """
        return self.action_aura().react()

    def duration(self):
        """
        Return the arguments for the expression action.spell.duration.
        """
        return self.action_aura().duration()


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


class Equipped(BuildExpression):
    """
    Represent the expression for a equipped. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = 'value'
        self.object_ = Item(self.condition.parent_action,
                            self.condition.condition_list()[1])
        self.args = []
        super().__init__(call)

    @auto_expression
    def  value(self):
        """
        Return the arguments for the expression equipped.
        """
        method = Method('IsEquipped', type_=BOOL)
        return None, method, None


class PrevGCD(BuildExpression):
    """
    Represent the expression for a prev_gcd. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = 'value'
        self.object_ = self.condition.parent_action.player
        self.args = [Literal(self.condition.condition_list()[1]),
                     Spell(self.condition.parent_action,
                           self.condition.condition_list()[2])]
        super().__init__(call)

    @auto_expression
    def value(self):
        """
        Return the arguments for the expression prev_gcd.
        """
        method = Method('PrevGCDP', type_=BOOL)
        return None, method, None


class GCD(BuildExpression):
    """
    Represent the expression for a gcd. condition.
    """
    # TODO update GCD to take into account current execution.

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        self.object_ = self.condition.parent_action.player
        self.args = []
        super().__init__(call)

    @auto_expression
    def remains(self):
        """
        Return the arguments for the expression gcd.remains.
        """
        method = Method('GCDRemains')
        return None, method, None

    def max(self):
        """
        Return the arguments for the expression gcd.max.
        """
        return self.value()

    @auto_expression
    def value(self):
        """
        Return the arguments for the expression gcd.
        """
        method = Method('GCD')
        return None, method, None


class Time(BuildExpression):
    """
    Represent the expression for a time. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        self.object_ = None
        self.args = []
        super().__init__(call)

    @auto_expression
    def value(self):
        """
        Return the arguments for the expression time.
        """
        method = Method('AC.CombatTime')
        return None, method, None


class Rune(BuildExpression):
    """
    Represent the expression for a rune. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[1]
        self.object_ = self.condition.parent_action.player
        super().__init__(call)

    @auto_expression
    def time_to_3(self):
        """
        Return the arguments for the expression rune.time_to_3.
        """
        method = Method('RuneTimeToX')
        args = [Literal('3')]
        return None, method, args


class Talent(BuildExpression):
    """
    Represent the expression for a talent. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[2]
        self.object_ = Spell(self.condition.parent_action,
                             self.condition.condition_list()[1])
        self.args = []
        super().__init__(call)

    @auto_expression
    def enabled(self):
        """
        Return the arguments for the expression talent.spell.enabled.
        """
        method = Method('IsAvailable', type_=BOOL)
        return None, method, None


class Resource(BuildExpression):
    """
    Represent the expression for resource (mana, runic_power, etc) condition.
    """

    def __init__(self, condition, simc):
        self.condition = condition
        self.simc = LuaNamed(simc)
        if len(condition.condition_list()) > 1:
            call = condition.condition_list()[1]
        else:
            call = 'value'
        self.object_ = self.condition.parent_action.player
        self.args = []
        super().__init__(call)

    @auto_expression
    def value(self):
        """
        Return the arguments for the expression {resource}.
        """
        method = Method(f'{self.simc.lua_name()}')
        return None, method, None

    @auto_expression
    def deficit(self):
        """
        Return the arguments for the expression {resource}.deficit.
        """
        method = Method(f'{self.simc.lua_name()}Deficit')
        return None, method, None

    @auto_expression
    def pct(self):
        """
        Return the arguments for the expression {resource}.pct.
        """
        method = Method(f'{self.simc.lua_name()}Percentage')
        return None, method, None


class AstralPower(Resource):
    """
    Represent the expression for a astral_power. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'astral_power')

    @balance_astral_power_value
    def value(self):
        return super().value()


class RunicPower(Resource):
    """
    Represent the expression for a runic_power. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'runic_power')


class Fury(Resource):
    """
    Represent the expression for a fury. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'fury')


class Mana(Resource):
    """
    Represent the expression for a mana. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'mana')


class Debuff(BuildExpression, Aura):
    """
    Represent the expression for a debuff. condition.
    """

    def __init__(self, condition):
        object_ = condition.parent_action.target
        Aura.__init__(self, condition, DEBUFF, object_, spell_type=DEBUFF)
        call = condition.condition_list()[2]
        super().__init__(call)


class Dot(Debuff):
    """
    Represent the expression for a dot. condition.
    """


class Buff(BuildExpression, Aura):
    """
    Represent the expression for a buff. condition.
    """

    def __init__(self, condition):
        object_ = condition.parent_action.player
        Aura.__init__(self, condition, BUFF, object_, spell_type=BUFF)
        call = condition.condition_list()[2]
        super().__init__(call)


class Cooldown(BuildExpression, Expires):
    """
    Represent the expression for a cooldown. condition.
    """

    def __init__(self, condition):
        Expires.__init__(self, condition, 'cooldown', 'cooldown_up')
        call = condition.condition_list()[2]
        super().__init__(call)

    @auto_expression
    def charges(self):
        """
        Return the arguments for the expression cooldown.spell.charges.
        """
        method = Method('ChargesP')
        return None, method, None

    @auto_expression
    def recharge_time(self):
        """
        Return the arguments for the expression cooldown.spell.recharge_time.
        """
        method = Method('RechargeP')
        return None, method, None



class TargetExpression(BuildExpression):
    """
    Represent the expression for a target. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[1]
        self.object_ = self.condition.parent_action.target
        self.args = []
        super().__init__(call)

    @auto_expression
    def time_to_die(self):
        """
        Return the arguments for the expression cooldown.spell.ready.
        """
        method = Method('TimeToDie')
        return None, method, None
