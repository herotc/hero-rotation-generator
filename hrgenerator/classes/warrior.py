# -*- coding: utf-8 -*-
"""
Warrior specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, RANGE

WARRIOR = 'warrior'
ARMS = 'arms'
FURY = 'fury'
PROTECTION = 'protection'

CLASS_SPECS = {
    WARRIOR: {
        ARMS:           71,
        FURY:           72,
        PROTECTION:     73,
    },
}

DEFAULT_POTION = {
    WARRIOR: {
        ARMS: 'prolonged_power',
        FURY: 'old_war',
    }
}

DEFAULT_RANGE = {
    WARRIOR: {
    },
}

SPELL_INFO = {
    WARRIOR: {
        COMMON: {
            'battle_cry':                           {SPELL:     1719,
                                                     BUFF:      1719},
            'stone_heart':                          {BUFF:      225947},
            'charge':                               {SPELL:     100},
            'avatar':                               {SPELL:     107574,
                                                     BUFF:      107574},
            # Trinkets
            'umbral_moonglaives':                   {SPELL:     242553},
            # Legendaries
            'fujiedas_fury':                        {BUFF:      207775},
        },
        ARMS: {
            'warbreaker':                           {SPELL:     209577},
            'bladestorm':                           {SPELL:     227847,
                                                     RANGE:     8},
            'ravager':                              {SPELL:     152277,
                                                     BUFF:      152277},
            'colossus_smash':                       {SPELL:     167105,
                                                     DEBUFF:    198804},
            'in_for_the_kill':                      {SPELL:     248621,
                                                     BUFF:      248622},
            'cleave':                               {SPELL:     845,
                                                     BUFF:      231833},
            'whirlwind':                            {SPELL:     1680,
                                                     RANGE:     8},
            'shattered_defenses':                   {BUFF:      248625},
            'execute':                              {SPELL:     163201},
            'mortal_strike':                        {SPELL:     12294},
            'executioners_precision':               {SPELL:     238147,
                                                     BUFF:      242188},
            'rend':                                 {SPELL:     772,
                                                     DEBUFF:    772},
            'focused_rage':                         {SPELL:     207982,
                                                     BUFF:      207982},
            'fervor_of_battle':                     {SPELL:     202316},
            'weighted_blade':                       {BUFF:      253383},
            'overpower':                            {SPELL:     7384},
            'dauntless':                            {SPELL:     202297},
            'deadly_calm':                          {SPELL:     227266},
            'anger_management':                     {SPELL:     152278},
            'slam':                                 {SPELL:     1464},
        },
        FURY: {
            'bloodthirst':                          {SPELL:     23881},
            'enrage':                               {SPELL:     184361,
                                                     BUFF:      184362},
            'bladestorm':                           {SPELL:     46924,
                                                     BUFF:      46924,
                                                     RANGE:     8},
            'bladestorm_mh':                        {RANGE:     8},
            'whirlwind':                            {SPELL:     190411,
                                                     RANGE:     8},
            'meat_cleaver':                         {SPELL:     85739,
                                                     BUFF:      85739},
            'rampage':                              {SPELL:     184367},
            'frothing_berserker':                   {SPELL:     215571},
            'massacre':                             {SPELL:     206315,
                                                     BUFF:      206316},
            'execute':                              {SPELL:     5308},
            'raging_blow':                          {SPELL:     85288},
            'inner_rage':                           {SPELL:     215573},
            'odyns_fury':                           {SPELL:     205545},
            'berserker_rage':                       {SPELL:     18499,
                                                     BUFF:      18499},
            'outburst':                             {SPELL:     206320},
            'wrecking_ball':                        {SPELL:     215569,
                                                     BUFF:      215570},
            'furious_slash':                        {SPELL:     100130},
            'juggernaut':                           {SPELL:     200875,
                                                     BUFF:      201009},
            'frenzy':                               {SPELL:     206313,
                                                     BUFF:      202539},
            'heroic_leap':                          {SPELL:     6544},
            'bloodbath':                            {SPELL:     12292,
                                                     BUFF:      12292},
            'carnage':                              {SPELL:     202922},
            'dragon_roar':                          {SPELL:     118000,
                                                     BUFF:      118000},
            'reckless_abandon':                     {SPELL:     202751},
        },
    },
}

ITEM_INFO = {
    'the_great_storms_eye':             151823,
    'archavons_heavy_hand':             137060,
    'kazzalax_fujiedas_fury':           137053,
    'umbral_moonglaives':               147012,
}

CLASS_FUNCTIONS = {
    WARRIOR: {
        COMMON: [
        ],
        ARMS: [
        ],
        FURY: [
        ],
    },
}
