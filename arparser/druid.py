# -*- coding: utf-8 -*-
"""
Druid specific constants and functions.

@author: skasch
"""
import os

from .expressions import Method

DRUID = 'druid'
BALANCE = 'balance'
FERAL = 'feral'
GUARDIAN = 'guardian'

DR_SPECS = {DRUID: [BALANCE, FERAL, GUARDIAN]}

DR_POTION = {
    DRUID: {
        BALANCE: 'prolonged_power',
        FERAL: 'old_war',
        GUARDIAN: 'prolonged_power',
    }
}

DR_SPELL_INFO = {
    DRUID: {}
}

DR_ITEM_INFO = {}


def balance_future_astral_power(fun):
    """
    Adds astral power value prediction for Balance.
    """

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        if spec == BALANCE:
            future_astral_power = ''
            lua_file_path = os.path.join(os.path.dirname(__file__),
                                         'luafunctions',
                                         'FutureAstralPower.lua')
            with open(lua_file_path) as lua_file:
                future_astral_power = ''.join(lua_file.readlines())
            self.apl.context.add_code(future_astral_power)
        fun(self, spec)

    return set_spec

def balance_astral_power_value(fun):
    """
    Replaces the astral_power expression with a call to FutureAstralPower.
    """

    def value(self):
        """
        Return the arguments for the expression astral_power.
        """
        if self.condition.parent_action.player.spec.simc == BALANCE:
            return None, Method('FutureAstralPower'), []
        return fun()

    return value
