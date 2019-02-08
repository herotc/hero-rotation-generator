# -*- coding: utf-8 -*-
"""
Shaman specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE, CD, GCDAOGCD

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
        ELEMENTAL:      'battle_potion_of_intellect',
        ENHANCEMENT:    'battle_potion_of_agility',
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
            'heroism':                          {SPELL:     32182},
            'wind_shear':                       {SPELL:     57994,
                                                 INTERRUPT: True},
            # azerite traits
            'natural_harmony':                  {SPELL:     278697},
            'natural_harmony_nature':           {BUFF:      279033},
            'natural_harmony_frost':            {BUFF:      279029},
            'natural_harmony_fire':             {BUFF:      279028},
        },
        ELEMENTAL: {
            'flame_shock':                      {SPELL:     188389,
                                                 DEBUFF:    188389},
            'earthquake':                       {SPELL:     61882},
            'lava_burst':                       {SPELL:     51505},
            'lava_surge':                       {BUFF:      77762},
            'chain_lightning':                  {SPELL:     188443,
                                                 RANGE:     40},
            'earth_shock':                      {SPELL:     8042},
            'lightning_bolt':                   {SPELL:     188196},
            'frost_shock':                      {SPELL:     196840,
                                                 DEBUFF:    196840},
            'fire_elemental':                   {SPELL:     198067,
                                                 CD:        True,
                                                 GCDAOGCD:  True},
            'wind_gust':                        {BUFF:      263806},
            'lava_beam':                        {SPELL:     114074},
            # talents
            'aftershock':                       {SPELL:     273221},
            'totem_mastery':                    {SPELL:     210643},
            'stormkeeper':                      {SPELL:     191634,
                                                 BUFF:      191634},
            'ascendance':                       {SPELL:     114050,
                                                 BUFF:      114050,
                                                 CD:        True,
                                                 GCDAOGCD:  True},
            'liquid_magma_totem':               {SPELL:     192222},
            'elemental_blast':                  {SPELL:     117014},
            'icefury':                          {SPELL:     210714,
                                                 BUFF:      210714},
            'storm_elemental':                  {SPELL:     192249,
                                                 CD:        True,
                                                 GCDAOGCD:  True},
            'master_of_the_elements':           {SPELL:     16166,
                                                 BUFF:      260734},
            'surge_of_power':                   {SPELL:     262303,
                                                 BUFF:      285514},
            'call_the_thunder':                 {SPELL:     260897},
            'resonance_totem':                  {BUFF:      202192},
            # azerite traits
            'echo_of_the_elementals':           {SPELL:     275381},
        },
        ENHANCEMENT: {
            'windstrike':                       {SPELL:     115356},
            'rockbiter':                        {SPELL:     193786},
            'crash_lightning':                  {SPELL:     187874,
                                                 BUFF:      187874,
                                                 RANGE:     8},
            'gathering_storms':                 {BUFF:      198300},
            'feral_spirit':                     {SPELL:     51533},
            'flametongue':                      {SPELL:     193796,
                                                 BUFF:      194084},
            'frostbrand':                       {SPELL:     196834,
                                                 BUFF:      196834},
            'crashing_storm':                   {SPELL:     192246},
            'stormstrike':                      {SPELL:     17364},
            'stormbringer':                     {BUFF:      201845},
            'lightning_bolt':                   {SPELL:     187837},
            'lava_lash':                        {SPELL:     60103},
            # talents
            'earthen_spike':                    {SPELL:     188089,
                                                 DEBUFF:    188089},
            'hailstorm':                        {SPELL:     210853},
            'landslide':                        {SPELL:     197992,
                                                 BUFF:      202004},
            'fury_of_air':                      {SPELL:     197211,
                                                 BUFF:      197211},
            'ascendance':                       {SPELL:     114051,
                                                 BUFF:      114051},
            'boulderfist':                      {SPELL:     246035},
            'overcharge':                       {SPELL:     210727},
            'hot_hand':                         {SPELL:     201900,
                                                 BUFF:      215785},
            'sundering':                        {SPELL:     197214,
                                                 DEBUFF:    197214,
                                                 RANGE:     8},
            'lightning_shield':                 {SPELL:     192106},
            'searing_assault':                  {SPELL:     192087},
            'totem_mastery':                    {SPELL:     262395},
            'resonance_totem':                  {BUFF:      262419},
            # azerite traits
            'lightning_conduit':                {SPELL:     275388,
                                                 DEBUFF:    275391},
            'forceful_winds':                   {SPELL:     262647},
            'strength_of_earth':                {SPELL:     273461,
                                                 BUFF:      273465},
            'primal_primer':                    {SPELL:     272992,
                                                 DEBUFF:    273006},
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
