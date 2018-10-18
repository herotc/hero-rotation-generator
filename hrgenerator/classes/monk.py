# -*- coding: utf-8 -*-
"""
Monk specific constants and functions.

@author: skasch
"""

from ..constants import (SPELL, BUFF, DEBUFF, COMMON,
                         OGCDAOGCD, USABLE, INTERRUPT,
                         CD, RANGE)

MONK = 'monk'
BREWMASTER = 'brewmaster'
WINDWALKER = 'windwalker'
MISTWEAVER = 'mistweaver'

CLASS_SPECS = {
    MONK: {
        BREWMASTER:     268,
        WINDWALKER:     269,
        MISTWEAVER:     270,
    },
}

DEFAULT_POTION = {
    MONK: {
        BREWMASTER: 'prolonged_power',
        WINDWALKER: 'prolonged_power',
    }
}

DEFAULT_RANGE = {
    MONK: {
    },
}

SPELL_INFO = {
    MONK: {
        COMMON: {
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
            # Azerite
            'swift_roundhouse':                 {SPELL:     277669,
                                                 BUFF:      278710},
        },
        BREWMASTER: {
            'black_ox_brew':                    {SPELL:     115399,
                                                 OGCDAOGCD: True},
            'blackout_combo':                   {SPELL:     196736,
                                                 BUFF:      228563},
            'blackout_strike':                  {SPELL:     205523},
            'breath_of_fire':                   {SPELL:     115181,
                                                 RANGE:     8},
            'breath_of_fire_dot':               {DEBUFF:    123725},
            'brews':                            {SPELL:     115308},
            'dampen_harm':                      {SPELL:     122278,
                                                 BUFF:      122278},
            'exploding_keg':                    {SPELL:     214326,
                                                 RANGE:     8},
            'fortifying_brew':                  {SPELL:     115203,
                                                 BUFF:      115203},
            'invoke_niuzao_the_black_ox':       {SPELL:     132578,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'ironskin_brew':                    {SPELL:     115308,
                                                 BUFF:      215479,
                                                 OGCDAOGCD: True},
            'keg_smash':                        {SPELL:     121253,
                                                 RANGE:     8},
            'light_brewing':                    {SPELL:     196721},
            'purifying_brew':                   {SPELL:     119582,
                                                 OGCDAOGCD: True},
        },
        WINDWALKER: {
            'crackling_jade_lightning':         {SPELL:     117952},
            'diffuse_magic':                    {BUFF:      122783},
            'energizing_elixir':                {SPELL:     115288,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'fists_of_fury':                    {SPELL:     113656,
                                                 RANGE:     8},
            'invoke_xuen_the_white_tiger':      {SPELL:     123904,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'pressure_point':                   {BUFF:      247255},
            'rising_sun_kick':                  {SPELL:     107428},
            'serenity':                         {SPELL:     152173,
                                                 BUFF:      152173,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'spinning_crane_kick':              {SPELL:     101546,
                                                 RANGE:     8},
            'storm_earth_and_fire':             {SPELL:     137639,
                                                 BUFF:      137639,
                                                 CD:        True,
                                                 OGCDAOGCD: True},
            'strike_of_the_windlord':           {SPELL:     205320,
                                                 CD:        True},
            'touch_of_death':                   {SPELL:     115080,
                                                 CD:        True},
            'touch_of_karma':                   {SPELL:     122470,
                                                 OGCDAOGCD: True},
            'rushing_jade_wind':                {SPELL:     261715,
                                                 BUFF:      261715,
                                                 RANGE:     8},
            'whirling_dragon_punch':            {SPELL:     152175},
            'fist_of_the_white_tiger':          {SPELL:     261947},
            'mark_of_the_crane':                {DEBUFF:    228287},
            'hit_combo':                        {SPELL:     196741},
            'flying_serpent_kick':              {SPELL:     101545},
            'bok_proc':                         {BUFF:      116768},
            'good_karma':                       {SPELL:     280195},
        },
    },
}

ITEM_INFO = {
    'archimondes_hatred_reborn':        144249,
    'drinking_horn_cover':              137097,
    'hidden_masters_forbidden_touch':   137057,
    'the_emperors_capacitor':           144239,
    'lustrous_golden_plumage':          159617,
}

CLASS_FUNCTIONS = {
    MONK: {
        COMMON: [
        ],
        BREWMASTER: [
        ],
        WINDWALKER: [
        ],
    },
}
