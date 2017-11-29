# -*- coding: utf-8 -*-
"""
Define the objects representing simc units.

@author: skasch
"""

from .lua import LuaNamed
from .demonhunter import havoc_is_in_melee_range
from .druid import balance_future_astral_power, guardian_swipe_thrash
from .database import (CLASS_SPECS, RACES, SPELL_INFO, COMMON, DEFAULT_POTION)


class Player:
    """
    Define a player as the main actor of a simulation.
    """

    def __init__(self, simc, apl):
        self.class_ = PlayerClass(simc)
        self.spec = None
        self.level = 110
        self.race = None
        self.apl = apl
        self.spells = None

    def potion(self):
        """
        Return the item of the potion used by the player.
        """
        return self.spec.potion()

    @havoc_is_in_melee_range
    @balance_future_astral_power
    @guardian_swipe_thrash
    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        self.spec = PlayerSpec(self, spec)

    def spell_book(self):
        """
        Returns the spell book of the player.
        """
        if not self.spells:
            class_simc = self.class_.simc
            spec_simc = self.spec.simc
            spells = SPELL_INFO.get(COMMON, {}).copy()
            spells.update(SPELL_INFO.get(class_simc, {}).get(COMMON, {}))
            spells.update(SPELL_INFO.get(class_simc, {}).get(spec_simc, {}))
            self.spells = spells
        return self.spells

    def spell_property(self, spell, key, default=False):
        """
        Return the requested spell property from the spell book of the player.
        """
        spell_name = spell.simc if type(spell).__name__ == 'Spell' else spell
        spells = self.spell_book()
        return spells.get(spell_name, {}).get(key, default)

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


class Pet:
    """
    Define a pet of the main actor of a simulation.
    """

    def __init__(self, owner, name='pet'):
        self.owner = owner
        self.name = name

    def print_lua(self):
        """
        Print the lua expression for the pet.
        """
        return 'Pet'


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
        Return the potion used by a the spec.
        """
        return DEFAULT_POTION.get(
                        self.player.class_.simc, {}).get(self.simc, None)
