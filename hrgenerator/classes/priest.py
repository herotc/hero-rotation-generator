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
            # Legendaries
            'zeks_exterminatus':                {BUFF:      236546},
            'buff_sephuzs_secret':              {SPELL:     208051},
            'sephuzs_secret':                   {BUFF:      208051},
        },
        SHADOW: {
            'mind_blast':                       {SPELL:     8092,
                                                 RANGE:     40},
            'mind_flay':                        {SPELL:     15407,
                                                 RANGE:     40},
            'mind_sear':                        {SPELL:     48045,
                                                 RANGE:     40},
            'shadowform':                       {SPELL:     232698,
                                                 BUFF:      232698},
            'voidform':                         {SPELL:     194249,
                                                 BUFF:      194249},
            'silence':                          {SPELL:     15487,
                                                 RANGE:     40,
                                                 INTERRUPT: True},
            'vampiric_touch':                   {SPELL:     34914,
                                                 DEBUFF:    34914,
                                                 RANGE:     40},                             
            'void_eruption':                    {SPELL:     228260},
            'void_bolt':                        {SPELL:     205448,
                                                 RANGE:     40},
            'dispersion':                       {SPELL:     47585,
                                                 BUFF:      47585},
            'shadowfiend':                      {SPELL:     34433,
                                                 RANGE:     40},
            
            
            #Talents
            'fortress_of_the_mind':             {SPELL:     193195},     
            'shadowy_insight':                  {SPELL:     162452,
                                                 BUFF:      124430},    
            'shadow_word_void':                 {SPELL:     205351,
                                                 RANGE:     40},

            'body_and_sould':                   {SPELL:     64129},
            'sanlayn':                          {SPELL:     199855},
            'mania':                            {SPELL:     193173},
            
            'twist_of_fate':                    {SPELL:     109142},
            'misery':                           {SPELL:     238558},
            'dark_void':                        {SPELL:     263346,
                                                 RANGE:     40},
            
            'last_word':                        {SPELL:     263716},
            'mind_bomb':                        {SPELL:     205369,
                                                 RANGE:     40},
            'psychic_horror':                   {SPELL:     64044},
            
            'auspicious_spirits':               {SPELL:     155271},
            'shadow_word_death':                {SPELL:     32379,
                                                 RANGE:     40},
            'shadow_crash':                     {SPELL:     205385,
                                                 RANGE:     40},
            
            'lingering_insanity':               {SPELL:     199849},
            'mindbender':                       {SPELL:     200174,
                                                 RANGE:     40},
            'void_torrent':                     {SPELL:     263165,
                                                 RANGE:     40},
                                     
            'legacy_of_the_void':               {SPELL:     193225},
            'dark_ascension':                   {SPELL:     280711,
                                                 RANGE:     40},
            'surrender_to_madness':             {SPELL:     193223,
                                                 BUFF:      193223},
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
