# -*- coding: utf-8 -*-
"""
Hunter specific constants and functions.

@author: skasch
"""

from .constants import COMMON

HUNTER = 'hunter'
BEAST_MASTERY = 'beast_mastery'
MARKSMANSHIP = 'marksmanship'
SURVIVAL = 'survival'

HT_SPECS = {HUNTER: [BEAST_MASTERY, MARKSMANSHIP, SURVIVAL]}

HT_POTION = {
    HUNTER: {
        BEAST_MASTERY:  'prolonged_power',
        MARKSMANSHIP:   'prolonged_power',
        SURVIVAL:       'prolonged_power',
    }
}

HT_SPELL_INFO = {
    HUNTER: {
        COMMON: {
        },
        BEAST_MASTERY: {
        },
        MARKSMANSHIP: {
        },
        SURVIVAL: {
        },
    },
}

HT_ITEM_INFO = {
}
