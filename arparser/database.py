# -*- coding: utf-8 -*-
"""
Initialize the arparser package.

@author: skasch
"""

from .constants import SPELL, OGCDAOGCD
from .deathknight import DK_SPECS, DK_POTION, DK_SPELL_INFO
from .demonhunter import DH_SPECS, DH_POTION, DH_SPELL_INFO
from .druid import DR_SPECS, DR_POTION
from .mage import MG_SPECS, MG_POTION

DEFAULT = 'default'

CLASS_SPECS = {
    'demonhunter': ['havoc'],
    'mage': ['arcane'],
}
CLASS_SPECS.update(DK_SPECS)
CLASS_SPECS.update(DH_SPECS)
CLASS_SPECS.update(DR_SPECS)
CLASS_SPECS.update(MG_SPECS)

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
DEFAULT_POTION.update(DK_POTION)
DEFAULT_POTION.update(DH_POTION)
DEFAULT_POTION.update(DR_POTION)
DEFAULT_POTION.update(MG_POTION)

SPELL_INFO = {
    DEFAULT: {
        'arcane_torrent':       {SPELL:     50613,
                                 OGCDAOGCD: True},
        'berserking':           {SPELL:     26297,
                                 OGCDAOGCD: True},
        'blood_fury':           {SPELL:     20572,
                                 OGCDAOGCD: True},
        'gift_of_the_naaru':    {SPELL:     59547},
        'shadowmeld':           {SPELL:     58984},
        'pool_resource':        {SPELL:     9999000010},
    }
}
SPELL_INFO.update(DK_SPELL_INFO)
SPELL_INFO.update(DH_SPELL_INFO)

ITEM_INFO = {
    'prolonged_power': 142117,
}
