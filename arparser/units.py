# -*- coding: utf-8 -*-
"""
Define the objects representing simc units.

@author: skasch
"""

from .lua import LuaNamed
from .constants import (CLASS_SPECS, RACES)


class Player:
    """
    Define a player as the main actor of a simulation.
    """

    def __init__(self, simc):
        self.class_ = PlayerClass(simc)
        self.spec = None
        self.level = 110
        self.race = None

    def potion(self):
        """
        Return the item of the potion used by the player.
        """
        return self.spec.potion()

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        self.spec = PlayerSpec(self, spec)

    def set_race(self, race):
        """
        Sets the race of the player.
        """
        self.race = PlayerRace(self, race)

    def set_level(self, level):
        """
        Sets the level of the player.
        """
        self.level = int(level)

    def print_lua(self):
        """
        Print the lua expression for the player.
        """
        return 'Player'


class Target:
    """
    Define a target of the main actor of a simulation.
    """

    def __init__(self, simc=None):
        self.simc = simc if simc is not None else 'patchwerk'

    def print_lua(self):
        """
        Print the lua expression for the target.
        """
        return 'Target'


class PlayerClass(LuaNamed):
    """
    The player class.
    """

    def __init__(self, simc):
        try:
            assert simc in CLASS_SPECS.keys()
        except AssertionError:
            ValueError(f'Invalid class {simc}.')
        super().__init__(simc)


class PlayerRace(LuaNamed):
    """
    The player race.
    """

    def __init__(self, player, simc):
        try:
            assert simc in RACES
        except AssertionError:
            ValueError(f'Invalid race {simc}.')
        self.player = player
        super().__init__(simc)


class PlayerSpec(LuaNamed):
    """
    The player spec.
    """

    def __init__(self, player, simc):
        try:
            assert simc in CLASS_SPECS[player.class_.simc]
        except AssertionError:
            ValueError(f'Invalid spec {simc} for class {player.class_.simc}.')
        self.player = player
        super().__init__(simc)

    def potion(self):
        """
        Return the potion used by a Death Knight.
        """
        if self.player.class_.simc in ['deathknight', 'demonhunter']:
            potion = 'prolonged_power'
        elif self.player.class_.simc in ['mage']:
            potion = 'deadly_grace'
        return potion
