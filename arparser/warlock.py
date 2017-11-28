# -*- coding: utf-8 -*-
"""
Warlock specific constants and functions.

@author: skasch
"""

from .constants import COMMON

WARLOCK = 'warlock'
AFFLICTION = 'affliction'
DEMONOLOGY = 'demonology'
DESTRUCTION = 'destruction'

WL_SPECS = {WARLOCK: [AFFLICTION, DEMONOLOGY, DESTRUCTION]}

WL_POTION = {
    WARLOCK: {
        AFFLICTION: 'prolonged_power',
        DEMONOLOGY: 'prolonged_power',
        DESTRUCTION: 'prolonged_power',
    }
}

WL_SPELL_INFO = {
    WARLOCK: {
        COMMON: {}
    }
}

WL_ITEM_INFO = {}
