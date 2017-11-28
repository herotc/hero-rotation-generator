# -*- coding: utf-8 -*-
"""
Warrior specific constants and functions.

@author: skasch
"""

from .constants import COMMON

WARRIOR = 'warrior'
ARMS = 'arms'
FURY = 'fury'

WR_SPECS = {WARRIOR: [ARMS, FURY]}

WR_POTION = {
    WARRIOR: {
        ARMS: 'prolonged_power',
        FURY: 'old_war',
    }
}

WR_SPELL_INFO = {
    WARRIOR: {
        COMMON: {}
    }
}

WR_ITEM_INFO = {}
