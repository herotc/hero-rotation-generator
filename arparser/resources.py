# -*- coding: utf-8 -*-
"""
Define the objects representing simc resources expressions.

@author: skasch
"""


from .lua import BuildExpression, Literal, Method
from .druid import balance_astral_power_value
from .warlock import warlock_soul_shard_value


class Resource(BuildExpression):
    """
    Represent the expression for resource (mana, runic_power, etc) condition.
    """

    def __init__(self, condition, simc):
        self.condition = condition
        self.simc = Literal(simc, convert=True)
        if len(condition.condition_list) > 1:
            call = condition.condition_list[1]
        else:
            call = 'value'
        self.object_ = condition.player_unit
        self.method = None
        self.args = []
        super().__init__(call)

    def value(self):
        """
        Return the arguments for the expression {resource}.
        """
        self.method = Method(f'{self.simc.print_lua()}')

    def deficit(self):
        """
        Return the arguments for the expression {resource}.deficit.
        """
        self.method = Method(f'{self.simc.print_lua()}Deficit')

    def pct(self):
        """
        Return the arguments for the expression {resource}.pct.
        """
        self.method = Method(f'{self.simc.print_lua()}Percentage')

    def regen(self):
        """
        Return the arguments for the expression {resource}.regen.
        """
        self.method = Method(f'{self.simc.print_lua()}Regen')

    def max(self):
        """
        Return the arguments for the expression {resource}.max.
        """
        self.method = Method(f'{self.simc.print_lua()}Max')

    def time_to_max(self):
        """
        Return the arguments for the expression {resource}.time_to_max.
        """
        self.method = Method(f'{self.simc.print_lua()}TimeToMaxPredicted')


class Rune(Resource):
    """
    Represent the expression for a rune. condition.
    """

    def __init__(self, condition):
        if (len(condition.condition_list) > 1
                and condition.condition_list[1][:-1] == 'time_to_'):
            condition.condition_list.append(condition.condition_list[1][-1])
            condition.condition_list[1] = 'time_to'
        super().__init__(condition, 'rune')

    def time_to(self):
        """
        Return the arguments for the expression rune.time_to_X.
        """
        self.method = Method('RuneTimeToX')
        self.args = [Literal(self.condition.condition_list[2])]


class AstralPower(Resource):
    """
    Represent the expression for a astral_power. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'astral_power')

    @balance_astral_power_value
    def value(self):
        return super().value()


class HolyPower(Resource):
    """
    Represent the expression for a runic_power. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'holy_power')


class Insanity(Resource):
    """
    Represent the expression for a insanity. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'insanity')


class Pain(Resource):
    """
    Represent the expression for a pain. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'pain')


class Focus(Resource):
    """
    Represent the expression for a focus. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'focus')


class Maelstrom(Resource):
    """
    Represent the expression for a maelstrom. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'maelstrom')


class Energy(Resource):
    """
    Represent the expression for a energy. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'energy')


class ComboPoints(Resource):
    """
    Represent the expression for a combo_points. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'combo_points')


class SoulShard(Resource):
    """
    Represent the expression for a soul_shard. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'soul_shard')

    @warlock_soul_shard_value
    def value(self):
        return super().value()


class ArcaneCharges(Resource):
    """
    Represent the expression for a arcane_charges. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'arcane_charges')


class Chi(Resource):
    """
    Represent the expression for a chi. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'chi')


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


class Rage(Resource):
    """
    Represent the expression for a rage. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'rage')


class Mana(Resource):
    """
    Represent the expression for a mana. condition.
    """

    def __init__(self, condition):
        super().__init__(condition, 'mana')
