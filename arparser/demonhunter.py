# -*- coding: utf-8 -*-
"""
Demon Hunter specific constants and functions.

@author: skasch
"""

import os

from .lua import LuaExpression
from .expressions import Method
from .constants import MELEE, SPELL, BUFF, DEBUFF, COMMON, RANGE

DEMONHUNTER = 'demonhunter'
HAVOC = 'havoc'
VENGEANCE = 'vengeance'

DH_SPECS = {DEMONHUNTER: [HAVOC, VENGEANCE]}

DH_POTION = {
    DEMONHUNTER: {
        HAVOC:      'prolonged_power',
        VENGEANCE:  'prolonged_power',
    }
}

DH_SPELL_INFO = {
    DEMONHUNTER: {
        COMMON: {
            'annihilation':         {SPELL:     201427,
                                     MELEE:     True},
            'blade_dance':          {SPELL:     188499,
                                     RANGE:     8},
            'blade_dance1':         {SPELL:     188499,
                                     RANGE:     8},
            'consume_magic':        {SPELL:     183752},
            'chaos_strike':         {SPELL:     162794,
                                     MELEE:     True},
            'chaos_nova':           {SPELL:     179057},
            'death_sweep':          {SPELL:     210152},
            'demons_bite':          {SPELL:     162243,
                                     MELEE:     True},
            'eye_beam':             {SPELL:     198013,
                                     RANGE:     20},
            'eye_beam_tick':        {SPELL:     198013,
                                     RANGE:     20},
            'fel_rush':             {SPELL:     195072},
            'metamorphosis':        {SPELL:     191427,
                                     BUFF:      162264},
            'vengeful_retreat':     {SPELL:     198793},
            'blind_fury':           {SPELL:     203550},
            'bloodlet':             {SPELL:     206473},
            'chaos_blades':         {SPELL:     247938,
                                     BUFF:      247938},
            'chaos_cleave':         {SPELL:     206475},
            'demon_blades':         {SPELL:     203555},
            'demonic':              {SPELL:     213410},
            'demonic_appetite':     {SPELL:     206478},
            'demon_reborn':         {SPELL:     193897},
            'fel_barrage':          {SPELL:     211053,
                                     RANGE:     30},
            'felblade':             {SPELL:     232893},
            'fel_eruption':         {SPELL:     211881},
            'fel_mastery':          {SPELL:     192939},
            'first_blood':          {SPELL:     206416},
            'master_of_the_glaive': {SPELL:     203556},
            'momentum':             {SPELL:     206476,
                                     BUFF:      208628},
            'nemesis':              {SPELL:     206491,
                                     DEBUFF:    206491},
            'prepared':             {SPELL:     203551,
                                     BUFF:      203650},
            'fury_of_the_illidari': {SPELL:     201467,
                                     RANGE:     40},
            'fel_devastation':      {SPELL:     212084},
            'immolation_aura':      {SPELL:     178740},
            'shear':                {SPELL:     203782},
            'sigil_of_flame':       {SPELL:     204596},
            'soul_cleave':          {SPELL:     228477},
            'soul_carver':          {SPELL:     207407},
            'demon_spikes':         {SPELL:     203720,
                                     BUFF:      203819},
            'infernal_strike':      {SPELL:     189110},
        },
        HAVOC: {
            'throw_glaive':         {SPELL:     185123,
                                     RANGE:     30},
        },
        VENGEANCE: {
            'throw_glaive':         {SPELL:     204157},
        },
    },
}

DH_ITEM_INFO = {
}


def havoc_melee_condition(fun):
    """
    Add class specific conditions.
    """

    def additional_conditions(self):
        """
        Additional conditions to test for the specific action; [] by default if
        none.
        """
        conditions = []
        if (self.action.player.spec.simc == HAVOC
                and self.action.player.spell_property(self, MELEE)):
            conditions.append(LuaExpression(
                None, Method('IsInMeleeRange'), []))
        return conditions + fun(self)
    return additional_conditions


def havoc_is_in_melee_range(fun):
    """
    Adds melee range prediction with movement skills for Havoc.
    """

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        if spec == HAVOC:
            is_in_melee_range = ''
            lua_file_path = os.path.join(os.path.dirname(__file__),
                                         'luafunctions', 'IsInMeleeRange.lua')
            with open(lua_file_path) as lua_file:
                is_in_melee_range = ''.join(lua_file.readlines())
            self.apl.context.add_code(is_in_melee_range)
        fun(self, spec)

    return set_spec
