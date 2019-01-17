# -*- coding: utf-8 -*-
"""
Paladin specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE, CD, READY, OGCDAOGCD

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

ACTION_LIST_INFO = {
    PALADIN: {
        RETRIBUTION: {
            'cooldowns':             {CD:        True},
        },
    },
}

DEFAULT_POTION = {
    PALADIN: {
        PROTECTION:     'battle_potion_of_stamina',
        RETRIBUTION:    'battle_potion_of_strength',
    }
}

DEFAULT_RANGE = {
    PALADIN: {
    },
}

SPELL_INFO = {
    PALADIN: {
        COMMON: {
            'divine_shield':                    {SPELL:     642,
                                                 BUFF:      642},
            'lay_on_hand':                      {SPELL:     633},
            'avenging_wrath':                   {SPELL:     31884,
                                                 BUFF:      31884,
                                                 OGCDAOGCD: True},
            'consecration':                     {SPELL:     26573}, # Holy/Prot
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
            'consecration':                     {SPELL:     26573,
                                                 BUFF:      188370},
        },
        RETRIBUTION: {
            'crusade':                          {SPELL:     231895,
                                                 BUFF:      231895,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'blade_of_justice':                 {SPELL:     184575},
            'shield_of_vengeance':              {SPELL:     184662},
            'execution_sentence':               {SPELL:     267798,
                                                 DEBUFF:    267799,
                                                 READY:     True},
            'judgment':                         {SPELL:     20271,
                                                 DEBUFF:    197277,
                                                 RANGE:     30},
            'divine_storm':                     {SPELL:     53385,
                                                 RANGE:     8,
                                                 READY:     True},
            'divine_purpose':                   {BUFF:      223817},
            'templars_verdict':                 {SPELL:     85256,
                                                 READY:     True},
            'wake_of_ashes':                    {SPELL:     255937},
            'zeal':                             {SPELL:     269569},
            'crusader_strike':                  {SPELL:     35395},
            'rebuke':                           {SPELL:     96231,
                                                 INTERRUPT: True},
            'inquisition':                      {SPELL:     84963,
                                                 BUFF:      84963,
                                                 READY:     True},
            'divine_judgment':                  {SPELL:     271580},
            'hammer_of_wrath':                  {SPELL:     24275},
            'consecration':                     {SPELL:     205228},
            'righteous_verdict':                {SPELL:     267610},
            'empyrean_power':                   {SPELL:     286390,
                                                 BUFF:      286393}, # CHECK BUFF ID
        },
    },
}

ITEM_INFO = {
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
