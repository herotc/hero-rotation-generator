# -*- coding: utf-8 -*-
"""
Initialize the arparser package.

@author: skasch
"""

from .constants import SPELL, BUFF, OGCDAOGCD, CD, COMMON
from .deathknight import    DK_SPECS, DK_POTION, DK_SPELL_INFO, DK_ITEM_INFO
from .demonhunter import    DH_SPECS, DH_POTION, DH_SPELL_INFO, DH_ITEM_INFO
from .druid import          DR_SPECS, DR_POTION, DR_SPELL_INFO, DR_ITEM_INFO
from .hunter import         HT_SPECS, HT_POTION, HT_SPELL_INFO, HT_ITEM_INFO
from .mage import           MG_SPECS, MG_POTION, MG_SPELL_INFO, MG_ITEM_INFO
from .monk import           MK_SPECS, MK_POTION, MK_SPELL_INFO, MK_ITEM_INFO
from .paladin import        PL_SPECS, PL_POTION, PL_SPELL_INFO, PL_ITEM_INFO
from .priest import         PR_SPECS, PR_POTION, PR_SPELL_INFO, PR_ITEM_INFO
from .rogue import          RG_SPECS, RG_POTION, RG_SPELL_INFO, RG_ITEM_INFO
from .shaman import         SH_SPECS, SH_POTION, SH_SPELL_INFO, SH_ITEM_INFO
from .warlock import        WL_SPECS, WL_POTION, WL_SPELL_INFO, WL_ITEM_INFO
from .warrior import        WR_SPECS, WR_POTION, WR_SPELL_INFO, WR_ITEM_INFO

CLASS_SPECS = {}
CLASS_SPECS.update(DK_SPECS)
CLASS_SPECS.update(DH_SPECS)
CLASS_SPECS.update(DR_SPECS)
CLASS_SPECS.update(HT_SPECS)
CLASS_SPECS.update(MG_SPECS)
CLASS_SPECS.update(MK_SPECS)
CLASS_SPECS.update(PL_SPECS)
CLASS_SPECS.update(PR_SPECS)
CLASS_SPECS.update(RG_SPECS)
CLASS_SPECS.update(SH_SPECS)
CLASS_SPECS.update(WL_SPECS)
CLASS_SPECS.update(WR_SPECS)

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
DEFAULT_POTION.update(HT_POTION)
DEFAULT_POTION.update(MG_POTION)
DEFAULT_POTION.update(MK_POTION)
DEFAULT_POTION.update(PL_POTION)
DEFAULT_POTION.update(PR_POTION)
DEFAULT_POTION.update(RG_POTION)
DEFAULT_POTION.update(SH_POTION)
DEFAULT_POTION.update(WL_POTION)
DEFAULT_POTION.update(WR_POTION)

SPELL_INFO = {
    COMMON: {
        'arcane_torrent':               {SPELL:     50613,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'berserking':                   {SPELL:     26297,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'blood_fury':                   {SPELL:     20572,
                                         OGCDAOGCD: True,
                                         CD:        True},
        'gift_of_the_naaru':            {SPELL:     59547},
        'shadowmeld':                   {SPELL:     58984},
        'potion_of_prolonged_power':    {BUFF:      229206},
        'potion_of_deadly_grace':       {BUFF:      188027},
        'pool_resource':                {SPELL:     9999000010},
    }
}
SPELL_INFO.update(DK_SPELL_INFO)
SPELL_INFO.update(DH_SPELL_INFO)
SPELL_INFO.update(DR_SPELL_INFO)
SPELL_INFO.update(HT_SPELL_INFO)
SPELL_INFO.update(MG_SPELL_INFO)
SPELL_INFO.update(MK_SPELL_INFO)
SPELL_INFO.update(PL_SPELL_INFO)
SPELL_INFO.update(PR_SPELL_INFO)
SPELL_INFO.update(RG_SPELL_INFO)
SPELL_INFO.update(SH_SPELL_INFO)
SPELL_INFO.update(WL_SPELL_INFO)
SPELL_INFO.update(WR_SPELL_INFO)

ITEM_INFO = {
    'prolonged_power':          142117,
    'old_war':                  127844,
    'deadly_grace':             127843,
}
ITEM_INFO.update(DK_ITEM_INFO)
ITEM_INFO.update(DH_ITEM_INFO)
ITEM_INFO.update(DR_ITEM_INFO)
ITEM_INFO.update(HT_ITEM_INFO)
ITEM_INFO.update(MG_ITEM_INFO)
ITEM_INFO.update(MK_ITEM_INFO)
ITEM_INFO.update(PL_ITEM_INFO)
ITEM_INFO.update(PR_ITEM_INFO)
ITEM_INFO.update(RG_ITEM_INFO)
ITEM_INFO.update(SH_ITEM_INFO)
ITEM_INFO.update(WL_ITEM_INFO)
ITEM_INFO.update(WR_ITEM_INFO)
