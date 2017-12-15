# -*- coding: utf-8 -*-
"""
Monk specific constants and functions.

@author: skasch
"""

from .constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE

MONK = 'monk'
BREWMASTER = 'brewmaster'
WINDWALKER = 'windwalker'

MK_SPECS = {MONK: [BREWMASTER, WINDWALKER]}

MK_POTION = {
    MONK: {
        BREWMASTER: 'prolonged_power',
        WINDWALKER: 'prolonged_power',
    }
}

MK_SPELL_INFO = {
    MONK: {
        COMMON: {
            'blackout_combo':                   {SPELL:     196736,
                                                 BUFF:      228563},
            'blackout_kick':                    {SPELL:     100784},
            'chi_burst':                        {SPELL:     123986},
            'chi_wave':                         {SPELL:     115098},
            'rushing_jade_wind':                {SPELL:     116847,
                                                 BUFF:      116847,
                                                 RANGE:     8},
            'spear_hand_strike':                {SPELL:     116705,
                                                 INTERRUPT: True},
            'tiger_palm':                       {SPELL:     100780},
            # Legendaries
            'the_emperors_capacitor':           {BUFF:      235054},
        },
        BREWMASTER: {
            'exploding_keg':                    {SPELL:     214326},
            'invoke_niuzao_the_black_ox':       {SPELL:     132578},
            'ironskin_brew':                    {SPELL:     115308},
            'black_ox_brew':                    {SPELL:     115399},
            'keg_smash':                        {SPELL:     121253},
            'blackout_strike':                  {SPELL:     205523},
            'breath_of_fire':                   {SPELL:     115181},
            'breath_of_fire_dot':               {DEBUFF:    123725},
            'gift_of_the_ox':                   {SPELL:     124507},
            'dampen_harm':                      {SPELL:     122278,
                                                 BUFF:      122278},
            'fortifying_brew':                  {SPELL:     115203,
                                                 BUFF:      115203},
            'diffuse_magic':                    {BUFF:      122783},
        },
        WINDWALKER: {
            'invoke_xuen_the_white_tiger':      {SPELL:     123904},
            'touch_of_death':                   {SPELL:     115080},
            'serenity':                         {SPELL:     152173,
                                                 BUFF:      152173},
            'strike_of_the_windlord':           {SPELL:     205320},
            'fists_of_fury':                    {SPELL:     113656,
                                                 RANGE:     8},
            'rising_sun_kick':                  {SPELL:     107428},
            'storm_earth_and_fire':             {SPELL:     137639,
                                                 BUFF:      137639},
            'pressure_point':                   {BUFF:      247255},
            'spinning_crane_kick':              {SPELL:     107270,
                                                 RANGE:     8},
            'energizing_elixir':                {SPELL:     115288},
            'whirling_dragon_punch':            {SPELL:     152175},
            'crackling_jade_lightning':         {SPELL:     117952},
            'touch_of_karma':                   {SPELL:     122470},
        },
    },
}

MK_ITEM_INFO = {
    'archimondes_hatred_reborn':        144249,
    'drinking_horn_cover':              137097,
    'hidden_masters_forbidden_touch':   137057,
    'the_emperors_capacitor':           144239,
}
