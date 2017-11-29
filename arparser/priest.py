# -*- coding: utf-8 -*-
"""
Priest specific constants and functions.

@author: skasch
"""

from .constants import COMMON

PRIEST = 'priest'
SHADOW = 'shadow'

PR_SPECS = {PRIEST: [SHADOW]}

PR_POTION = {
    PRIEST: {
        SHADOW: 'prolonged_power',
    }
}

PR_SPELL_INFO = {
    PRIEST: {
        COMMON: {
        },
        SHADOW: {
        },
    },
}

PR_ITEM_INFO = {
}
