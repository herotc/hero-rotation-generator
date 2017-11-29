# -*- coding: utf-8 -*-
"""
Rogue specific constants and functions.

@author: skasch
"""

from .constants import COMMON

ROGUE = 'rogue'
ASSASSINATION = 'assassination'
OUTLAW = 'outlaw'
SUBTLETY = 'subtlety'

RG_SPECS = {ROGUE: [ASSASSINATION, OUTLAW, SUBTLETY]}

RG_POTION = {
    ROGUE: {
        ASSASSINATION:  'prolonged_power',
        OUTLAW:         'prolonged_power',
        SUBTLETY:       'prolonged_power',
    }
}

RG_SPELL_INFO = {
    ROGUE: {
        COMMON: {
        },
        ASSASSINATION: {
        },
        OUTLAW: {
        },
        SUBTLETY: {
        },
    },
}

RG_ITEM_INFO = {
}
