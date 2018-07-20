# -*- coding: utf-8 -*-
"""
Priest specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE

PRIEST = 'priest'
DISCIPLINE = 'discipline'
HOLY = 'holy'
SHADOW = 'shadow'


CLASS_SPECS = {
    PRIEST: {
        DISCIPLINE:     256,
        HOLY:           257,
        SHADOW:         258,
    },
}

DEFAULT_POTION = {
    PRIEST: {
        SHADOW: 'prolonged_power',
    }
}

SPELL_INFO = {
    PRIEST: {
        COMMON: {
            'shadow_word_pain':                 {SPELL:     589,
                                                 DEBUFF:    589,
                                                 RANGE:     40},
            'power_infusion':                   {SPELL:     10060,
                                                 BUFF:      10060},
            # Legendaries
            'zeks_exterminatus':                {BUFF:      236546},
            'buff_sephuzs_secret':              {SPELL:     208051},
            'sephuzs_secret':                   {BUFF:      208051},
        },
        SHADOW: {
            'surrender_to_madness':             {SPELL:     193223,
                                                 BUFF:      193223},
            'shadow_word_death':                {SPELL:     32379,
                                                 RANGE:     40},
            'misery':                           {SPELL:     238558},
            'vampiric_touch':                   {SPELL:     34914,
                                                 DEBUFF:    34914,
                                                 RANGE:     40},
            'void_eruption':                    {SPELL:     228260},
            'mindbender':                       {SPELL:     200174,
                                                 RANGE:     40},
            'shadow_crash':                     {SPELL:     205385},
            'reaper_of_souls':                  {SPELL:     199853},
            'mind_blast':                       {SPELL:     8092,
                                                 RANGE:     40},
            'legacy_of_the_void':               {SPELL:     193225},
            'fortress_of_the_mind':             {SPELL:     193195},
            'auspicious_spirits':               {SPELL:     155271},
            'shadowy_insight':                  {SPELL:     162452,
                                                 BUFF:      124430},
            'shadow_word_void':                 {SPELL:     205351},
            'mind_flay':                        {SPELL:     15407},
            'silence':                          {SPELL:     15487,
                                                 INTERRUPT: True},
            'void_bolt':                        {SPELL:     231688},
            'mind_bomb':                        {SPELL:     205369},
            'voidform':                         {SPELL:     194249,
                                                 BUFF:      194249},
            'void_torrent':                     {SPELL:     205065},
            'dispersion':                       {SPELL:     47585},
            'shadowfiend':                      {SPELL:     34433},
            'sanlayn':                          {SPELL:     199855},
        },
    },
}

# TODO insanity_drain_stacks

ITEM_INFO = {
    'zeks_exterminatus':            144438,
    'mangazas_madness':             132864,
}

CLASS_FUNCTIONS = {
    PRIEST: {
        COMMON: [
        ],
        SHADOW: [
        ],
    },
}
