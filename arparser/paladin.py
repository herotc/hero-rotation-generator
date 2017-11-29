# -*- coding: utf-8 -*-
"""
Paladin specific constants and functions.

@author: skasch
"""

from .constants import COMMON

PALADIN = 'paladin'
PROTECTION = 'protection'
RETRIBUTION = 'retribution'

PL_SPECS = {PALADIN: [PROTECTION, RETRIBUTION]}

PL_POTION = {
    PALADIN: {
        PROTECTION:     'prolonged_power',
        RETRIBUTION:    'old_war',
    }
}

PL_SPELL_INFO = {
    PALADIN: {
        COMMON: {
        },
        PROTECTION: {
        },
        RETRIBUTION: {
        },
    },
}

PL_ITEM_INFO = {
}
