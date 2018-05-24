# -*- coding: utf-8 -*-
"""
Initialize the arparser package.

@author: skasch
"""

from . import deathknight
from . import demonhunter
from . import druid
from . import hunter
from . import mage
from . import monk
from . import paladin
from . import priest
from . import rogue
from . import shaman
from . import warlock
from . import warrior
from .constants import SPELL, BUFF, OGCDAOGCD, CD, COMMON

CLASSES = [deathknight, demonhunter, druid, hunter, mage, monk, paladin, priest,
           rogue, shaman, warlock, warrior]

CLASS_SPECS = {}
for class_ in CLASSES:
    CLASS_SPECS.update(class_.CLASS_SPECS)

RACES = [
    'blood_elf',
    'draenei',
    'dwarf',
    'gnome',
    'goblin',
    'human',
    'night_elf',
    'orc',
    'pandaren',
    'tauren',
    'troll',
    'undead',
    'worgen',
]

DEFAULT_POTION = {}
for class_ in CLASSES:
    DEFAULT_POTION.update(class_.DEFAULT_POTION)

SPELL_INFO = {
    COMMON: {
        'arcane_torrent':               {SPELL:     50613,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'berserking':                   {SPELL:     26297,
                                         BUFF:      26297,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'blood_fury':                   {SPELL:     20572,
                                         BUFF:      20572,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'gift_of_the_naaru':            {SPELL:     59547},
        'shadowmeld':                   {SPELL:     58984,
                                         BUFF:      58984},
        'darkflight':                   {SPELL:     68992},
        'stoneform':                    {SPELL:     20594},
        'exhaustion':                   {BUFF:      57723},
        # TODO: Fix; hack to make it work from consumable
        'prolonged_power':              {BUFF:      229206},
        'potion_of_prolonged_power':    {BUFF:      229206},
        'potion_of_deadly_grace':       {BUFF:      188027},
        'pool_resource':                {SPELL:     9999000010},
    }
}
for class_ in CLASSES:
    SPELL_INFO.update(class_.SPELL_INFO)

ITEM_INFO = {
    'prolonged_power':          142117,
    'old_war':                  127844,
    'deadly_grace':             127843,
}
for class_ in CLASSES:
    ITEM_INFO.update(class_.ITEM_INFO)

CLASS_FUNCTIONS = {}
for class_ in CLASSES:
    CLASS_FUNCTIONS.update(class_.CLASS_FUNCTIONS)

DECORATORS = {}
for class_ in CLASSES:
    try:
        DECORATORS.update(class_.DECORATORS)
    except AttributeError:
        pass

TEMPLATES = {}
for class_ in CLASSES:
    try:
        TEMPLATES.update(class_.TEMPLATES)
    except AttributeError:
        pass