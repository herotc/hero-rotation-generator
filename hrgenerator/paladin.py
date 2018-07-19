# -*- coding: utf-8 -*-
"""
Paladin specific constants and functions.

@author: skasch
"""

from .constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE

PALADIN = 'paladin'
HOLY = 'holy'
PROTECTION = 'protection'
RETRIBUTION = 'retribution'

CLASS_SPECS = {
    PALADIN: {
        HOLY:           65,
        PROTECTION:     66,
        RETRIBUTION:    70,
    },
}

DEFAULT_POTION = {
    PALADIN: {
        PROTECTION:     'prolonged_power',
        RETRIBUTION:    'old_war',
    }
}

SPELL_INFO = {
    PALADIN: {
        COMMON: {
            'divine_shield':                    {SPELL:     642,
                                                 BUFF:      642},
            'lay_on_hand':                      {SPELL:     633},
            'avenging_wrath':                   {SPELL:     31884,
                                                 BUFF:      31884},
            'consecration':                     {SPELL:     26573},
            # Legendaries
            'scarlet_inquisitors_expurgation':  {BUFF:      248103},
            'liadrins_fury_unleashed':          {BUFF:      208408},
            'whisper_of_the_nathrezim':         {BUFF:      207633},
        },
        PROTECTION: {
            'shield_of_the_righteous':          {SPELL:     53600},
            'seraphim':                         {SPELL:     152262,
                                                 BUFF:      152262},
            'eye_of_tyr':                       {SPELL:     209202,
                                                 DEBUFF:    209202},
            'aegis_of_light':                   {SPELL:     204150,
                                                 BUFF:      204150},
            'ardent_defender':                  {SPELL:     31850,
                                                 BUFF:      31850},
            'guardian_of_ancient_kings':        {SPELL:     86659,
                                                 BUFF:      86659},
            'bastion_of_light':                 {SPELL:     204035},
            'light_of_the_protector':           {SPELL:     184092},
            'hand_of_the_protector':            {SPELL:     213652},
            'righteous_protector':              {SPELL:     204074},
            'divine_steed':                     {SPELL:     190784},
            'knight_templar':                   {SPELL:     204139},
            'final_stand':                      {SPELL:     204077},
            'avengers_shield':                  {SPELL:     31935},
            'crusaders_judgement':              {SPELL:     204023},
            'grand_crusader':                   {BUFF:      85043},
            'blessed_hammer':                   {SPELL:     204019},
            'judgment':                         {SPELL:     20271,
                                                 RANGE:     30},
            'hammer_of_the_righteous':          {SPELL:     53595},
        },
        RETRIBUTION: {
            'crusade':                          {SPELL:     224668,
                                                 BUFF:      224668},
            'blade_of_justice':                 {SPELL:     184575},
            'divine_hammer':                    {SPELL:     198034},
            'holy_wrath':                       {SPELL:     210220},
            'shield_of_vengeance':              {SPELL:     184662},
            'execution_sentence':               {SPELL:     213757,
                                                 DEBUFF:    213757},
            'judgment':                         {SPELL:     20271,
                                                 DEBUFF:    231663,
                                                 RANGE:     30},
            'divine_storm':                     {SPELL:     53385,
                                                 RANGE:     8},
            'divine_purpose':                   {BUFF:      223819},
            'justicars_vengeance':              {SPELL:     215661},
            'templars_verdict':                 {SPELL:     85256},
            'wake_of_ashes':                    {SPELL:     205273,
                                                 DEBUFF:    205273},
            'zeal':                             {SPELL:     217020},
            'crusader_strike':                  {SPELL:     35395},
            'greater_judgment':                 {SPELL:     218178},
            'the_fires_of_justice':             {SPELL:     203316},
            'hammer_of_justice':                {SPELL:     853},
            'rebuke':                           {SPELL:     96231,
                                                 INTERRUPT: True},
        },
    },
}

ITEM_INFO = {
    'scarlet_inquisitors_expurgation':      151813,
    'liadrins_fury_unleashed':              137048,
    'whisper_of_the_nathrezim':             137020,
    'apocalypse_drive':                     151975,
}

CLASS_FUNCTIONS = {
    PALADIN: {
        COMMON: [
        ],
        PROTECTION: [
        ],
        RETRIBUTION: [
        ],
    },
}
