# -*- coding: utf-8 -*-
"""
Shaman specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE

SHAMAN = 'shaman'
ELEMENTAL = 'elemental'
ENHANCEMENT = 'enhancement'
RESTORATION = 'restoration'

CLASS_SPECS = {
    SHAMAN: {
        ELEMENTAL:          262,
        ENHANCEMENT:        263,
        RESTORATION:        264,
    },
}

DEFAULT_POTION = {
    SHAMAN: {
        ELEMENTAL:      'prolonged_power',
        ENHANCEMENT:    'prolonged_power',
    }
}

DEFAULT_RANGE = {
    SHAMAN: {
    },
}

SPELL_INFO = {
    SHAMAN: {
        COMMON: {
            'bloodlust':                        {SPELL:     2825},
            'wind_shear':                       {SPELL:     57994,
                                                 INTERRUPT: True},
            # Legendaries
            'echoes_of_the_great_sundering':    {BUFF:      208722},
        },
        ELEMENTAL: {
            'stormkeeper':                      {SPELL:     205495,
                                                 BUFF:      205495},
            'ascendance':                       {SPELL:     114050,
                                                 BUFF:      114050},
            'liquid_magma_totem':               {SPELL:     192222},
            'flame_shock':                      {SPELL:     188389,
                                                 DEBUFF:    188389},
            'earthquake':                       {SPELL:     61882},
            'lava_burst':                       {SPELL:     51505},
            'lava_surge':                       {BUFF:      77762},
            'lightning_rod':                    {SPELL:     210689},
            'elemental_blast':                  {SPELL:     117014},
            'lava_beam':                        {SPELL:     114074,
                                                 RANGE:     40},
            'chain_lightning':                  {SPELL:     188443,
                                                 RANGE:     40},
            'earth_shock':                      {SPELL:     8042},
            'swelling_maelstrom':               {SPELL:     238105},
            'lightning_bolt':                   {SPELL:     188196},
            'power_of_the_maelstrom':           {SPELL:     191861,
                                                 BUFF:      191877},
            'elemental_focus':                  {BUFF:      16246},
            'aftershock':                       {SPELL:     210707},
            'totem_mastery':                    {SPELL:     210643},
            'resonance_totem':                  {BUFF:      202192},
            'earthen_strength':                 {BUFF:      252141},
            'frost_shock':                      {SPELL:     196840,
                                                 DEBUFF:    196840},
            'icefury':                          {SPELL:     210714,
                                                 BUFF:      210714},
            'fire_elemental':                   {SPELL:     198067},
            'storm_elemental':                  {SPELL:     192249},
            'elemental_mastery':                {SPELL:     16166,
                                                 BUFF:      16166},
        },
        ENHANCEMENT: {
            'earthen_spike':                    {SPELL:     188089,
                                                 DEBUFF:    188089},
            'doom_winds':                       {SPELL:     204945,
                                                 BUFF:      204945},
            'windstrike':                       {SPELL:     115356},
            'rockbiter':                        {SPELL:     193786},
            'landslide':                        {SPELL:     197992,
                                                 BUFF:      202004},
            'fury_of_air':                      {SPELL:     197211,
                                                 BUFF:      197211},
            'crash_lightning':                  {SPELL:     187874,
                                                 BUFF:      187874,
                                                 RANGE:     8},
            'alpha_wolf':                       {SPELL:     198434,
                                                 BUFF:      198434},
            'feral_spirit':                     {SPELL:     51533},
            'flametongue':                      {SPELL:     193796,
                                                 BUFF:      194084},
            'frostbrand':                       {SPELL:     196834,
                                                 BUFF:      196834},
            'hailstorm':                        {SPELL:     210853},
            'ascendance':                       {SPELL:     114051,
                                                 BUFF:      114051},
            'boulderfist':                      {SPELL:     246035},
            'windsong':                         {SPELL:     201898,
                                                 BUFF:      201898},
            'crashing_storm':                   {SPELL:     192246},
            'stormstrike':                      {SPELL:     17364},
            'stormbringer':                     {BUFF:      201845},
            'lightning_bolt':                   {SPELL:     187837},
            'overcharge':                       {SPELL:     210727},
            'lava_lash':                        {SPELL:     60103},
            'exposed_elements':                 {DEBUFF:    252151},
            'lashing_flames':                   {SPELL:     238142,
                                                 DEBUFF:    240842},
            'hot_hand':                         {SPELL:     201900,
                                                 BUFF:      215785},
            'sundering':                        {SPELL:     197214,
                                                 DEBUFF:    197214,
                                                 RANGE:     8},
            'lightning_crash':                  {BUFF:      242284},
        },
    },
}

ITEM_INFO = {
    'echoes_of_the_great_sundering':        137074,
    'smoldering_heart':                     151819,
    'the_deceivers_blood_pact':             137035,
    'gnawed_thumb_ring':                    134526,
}

CLASS_FUNCTIONS = {
    SHAMAN: {
        COMMON: [
        ],
        ELEMENTAL: [
        ],
        ENHANCEMENT: [
        ],
    },
}
