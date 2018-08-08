# -*- coding: utf-8 -*-
"""
Define the objects representing simc units.

@author: skasch
"""

import os
from functools import reduce

from .lua import LuaNamed, Literal
from ..abstract.decoratormanager import decorating_manager
from ..constants import RANGE
from ..database import (CLASS_SPECS, RACES, SPELL_INFO, ACTION_LIST_INFO,
                        COMMON, DEFAULT_POTION, DEFAULT_RANGE, CLASS_FUNCTIONS,
                        DECORATORS)


class Unit:
    """
    Define a unit.
    """

    def __init__(self, unit_object):
        self.unit_object = Literal(unit_object, convert=True)

    def print_lua(self):
        """
        Return the representation of the unit.
        """
        return f'{self.unit_object.print_lua()}'


class Player(Unit, LuaNamed):
    """
    Define a player as the main actor of a simulation.
    """

    def __init__(self, simc, apl):
        super().__init__('player')
        self.simc = simc
        self.class_ = PlayerClass(simc)
        self.spec = None
        self.level = 110
        self.race = None
        self.apl = apl
        self.spells = None
        self.al_tags = None
        self.funs = None
        self.range_ = None
        for decorator in DECORATORS.get(simc, []):
            decorating_manager.register(**decorator)

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
        for function_name in self.spec_functions():
            self.add_to_context(function_name)

    def spec_functions(self):
        """
        Return the context functions specific to the player spec.
        """
        if not self.funs:
            class_simc = self.class_.simc
            spec_simc = self.spec.simc
            funs = CLASS_FUNCTIONS.get(COMMON, []).copy()
            funs.extend(CLASS_FUNCTIONS.get(class_simc, {}).get(COMMON, []))
            funs.extend(CLASS_FUNCTIONS.get(class_simc, {}).get(spec_simc, []))
            self.funs = funs
        return self.funs

    def add_to_context(self, function_name):
        """
        Add a function to the context given the function name (must match a file
        in the luafunctions folder).
        """
        lua_fun = ''
        lua_file_path = os.path.join(
            os.path.dirname(__file__),
            '..',
            'luafunctions',
            f'{function_name}.lua'
        )
        with open(lua_file_path) as lua_file:
            lua_fun = lua_file.read()
        self.apl.context.add_code(lua_fun)

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

    def action_list_tags(self):
        """
        Returns the action lists tags for the player.
        """
        if self.al_tags is None:
            class_simc = self.class_.simc
            spec_simc = self.spec.simc
            al_tags = ACTION_LIST_INFO.get(COMMON, {}).copy()
            al_tags.update(
                ACTION_LIST_INFO.get(class_simc, {}).get(COMMON, {})
            )
            al_tags.update(
                ACTION_LIST_INFO.get(class_simc, {}).get(spec_simc, {})
            )
            self.al_tags = al_tags
        return self.al_tags

    def spec_range(self):
        """
        Returns the default range of the spec.
        """
        if not self.range_:
            class_simc = self.class_.simc
            spec_simc = self.spec.simc
            if spec_simc in DEFAULT_RANGE.get(class_simc, {}):
                self.range_ = DEFAULT_RANGE[class_simc][spec_simc]
            else:
                self.range_ = reduce(
                    lambda range_, spell: max(spell[RANGE], range_),
                    filter(lambda spell: RANGE in spell,
                           self.spell_book().values()),
                    5)
        return self.range_

    def spell_property(self, spell, key, default=False):
        """
        Return the requested spell property from the spell book of the player.
        """
        spell_name = spell.simc if type(spell).__name__ == 'Spell' else spell
        spells = self.spell_book()
        return spells.get(spell_name, {}).get(key, default)

    def action_list_property(self, al, key, default=False):
        """
        Return the requested spell property from the spell book of the player.
        """
        al_name = al.simc if hasattr(al, 'simc') else al
        al_tags = self.action_list_tags()
        return al_tags.get(al_name, {}).get(key, default)

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


class Target(Unit, LuaNamed):
    """
    Define a target of the main actor of a simulation.
    """

    def __init__(self, simc=None):
        super().__init__('target')
        self.simc = simc if simc is not None else 'patchwerk'


class Pet(Unit, LuaNamed):
    """
    Define a pet of the main actor of a simulation.
    """

    def __init__(self, owner, name='pet'):
        super().__init__('pet')
        self.owner = owner
        self.name = name


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
