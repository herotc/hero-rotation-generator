# -*- coding: utf-8 -*-
"""
Shaman specific constants and functions.

@author: skasch
"""

from .constants import COMMON

SHAMAN = 'shaman'
ELEMENTAL = 'elemental'
ENHANCEMENT = 'enhancement'

SH_SPECS = {SHAMAN: [ELEMENTAL, ENHANCEMENT]}

SH_POTION = {
    SHAMAN: {
        ELEMENTAL:      'prolonged_power',
        ENHANCEMENT:    'prolonged_power',
    }
}

SH_SPELL_INFO = {
    SHAMAN: {
        COMMON: {
        },
        ELEMENTAL: {
        },
        ENHANCEMENT: {
        },
    },
}

SH_ITEM_INFO = {
}
