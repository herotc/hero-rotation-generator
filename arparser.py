# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 12:22:12 2017

@author: rmondoncancel
"""

ITEM_ACTIONS = [
    'potion',
]

ADDITIONAL_PARAMETERS = {
    'dancing_rune_weapon': 'Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon',
    'arcane_torrents': 'Settings.Blood.OffGCDasOffGCD.ArcaneTorrent',
    'blood_drinker': 'Settings.Blood.GCDasOffGCD.BloodDrinker',
}

USABLE_SKILLS = [
    'death_strike',
    'death_and_decay',
]

ADDITIONAL_CONDITIONS = {
    'potion': 'Settings.Commons.UsePotions',
}

INTERRUPT_SKILLS = [
    'mind_freeze',
]

CD_SKILLS = [
    'dancing_rune_weapon',
]

SPELL_REPLACEMENTS = {
    'And': 'and',
    'Blooddrinker': 'BloodDrinker',
}

SPELL = 'spell'
BUFF = 'buff'


class Player:

    def __init__(self):
        pass

    def setClass(self, class_):
        self.class_ = class_

    def potion(self):
        return self.class_.potion()

    def parse_lua(self):
        return 'Player'


class DeathKnight:

    def __init__(self):
        pass

    def potion(self):
        return Item("ProlongedPower")


class Item:

    def __init__(self, name):
        self.name = name


class APL:

    def __init__(self, player):
        self.player = player


class ActionList:

    def __init__(self, player):
        self.player = player


class Action:

    def __init__(self, action_list, action):
        self.action_list = action_list
        self.player = action_list.player
        self.action = action

    def execution(self):
        return Execution(self)

    def condition_tree(self):
        return ConditionTree(self)

    def type_(self):
        if self.execution().string() in ITEM_ACTIONS:
            return ActionType('item')
        else:
            return ActionType('spell')


class Execution:

    def __init__(self, action, execution):
        self.action = action
        self.execution = execution

    def string(self):
        return self.execution


class ActionType:

    def __init__(self, type_):
        self.type_ = type_


class Spell:

    def __init__(self, simc, type_=SPELL):
        self.simc = simc
        self.type_ = type_

    def ar(self):
        ar_name = self.simc.replace('_', ' ').title().replace(' ', '')
        for simc_str, ar_str in SPELL_REPLACEMENTS.items():
            ar_name.replace(simc_str, ar_str)
        return ar_name

    def parse_lua(self):
        if self.type_ == SPELL:
            return f'S.{self.ar()}'
        elif self.type_ == BUFF:
            return f'S.{self.ar()}Buff'


class Condition:

    def __init__(self, condition_tree, simc):
        self.condition_tree = condition_tree
        self.action = condition_tree.action
        self.simc = simc

    def expression(self):
        return getattr(self, self.condition_list()[0])()

    def condition_list(self):
        return self.simc.split('.')

    def cooldown(self):
        return Cooldown(self)

    def buff(self):
        return Buff(self)

    def gcd(self):
        return LuaExpression(self, self.action.player, Method('GCD'), [])

    def runic_power(self):
        return RunicPower(self)

    def talent(self):
        return Talent(self)

    def charges_fractional(self):
        return LuaExpression(
            self, Spell('blood_boil'), Method('ChargesFractional'), [])

    def rune(self):
        return Rune(self)


class ConditionTree:

    def __init__(self, action, simc):
        self.action = action
        self.simc = simc


class LuaExpression:

    def __init__(self, condition, object_, method, args):
        self.condition = condition
        self.object_ = object_
        self.method = method
        self.args = args

    def parse_lua(self):
        return (f'{self.object_.parse_lua()}:{self.method.parse_lua()}('
            f'{", ".join(arg.parse_lua() for arg in self.args)})')


class Rune(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        getattr(self, condition.condition_list()[1])()

    def time_to_3(self):
        # rune.time_to_3
        self.method = Method('RuneTimeToX')
        self.args = [Literal('3')]


class Talent(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = Spell(condition.condition_list()[1])
        getattr(self, condition.condition_list()[2])()

    def enabled(self):
        # talent.spell.enabled
        self.method = Method('IsLearned')
        self.args = []


class RunicPower(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        self.args = []
        getattr(self, condition.condition_list()[1])()

    def deficit(self):
        # runic_power.deficit
        self.method = Method('RunicPowerDeficit')


class Buff(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        self.args = [Spell(condition.condition_list()[1], BUFF)]
        getattr(self, condition.condition_list()[2])()

    def up(self):
        # buff.spell.up
        self.method = Method('Buff')

    def stack(self):
        # buff.spell.stack
        self.method = Method('BuffStack')


class Cooldown(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = Spell(condition.condition_list()[1])
        getattr(self, condition.condition_list()[2])()

    def ready(self):
        # cooldown.spell.ready
        self.method = Method('IsReady')
        self.args = []


class Method:

    def __init__(self, name):
        self.name = name

    def parse_lua(self):
        return self.name


class Literal:

    def __init__(self, value):
        self.value = value

    def parse_lua(self):
        return self.value
