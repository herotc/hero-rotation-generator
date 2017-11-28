# -*- coding: utf-8 -*-
"""
Mage specific constants and functions.

@author: skasch
"""

from .constants import COMMON

MAGE = 'mage'
ARCANE = 'arcane'
FIRE = 'fire'
FROST = 'frost'

MG_SPECS = {MAGE: [ARCANE, FIRE, FROST]}

MG_POTION = {
    MAGE: {
        ARCANE: 'deadly_grace',
        FIRE: 'prolonged_power',
        FROST: 'prolonged_power',
    }
}

MG_SPELL_INFO = {
    MAGE: {
        COMMON: {}
    }
}

MG_ITEM_INFO = {}
