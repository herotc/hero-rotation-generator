# -*- coding: utf-8 -*-
"""
Priest specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, INTERRUPT, RANGE, READY, OPENER

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
        HOLY: 'prolonged_power',
    }
}

DEFAULT_RANGE = {
    PRIEST: {
    },
}

SPELL_INFO = {
    PRIEST: {
        COMMON: {
            'shadow_word_pain':                 {SPELL:     589,
                                                 DEBUFF:    589,
                                                 RANGE:     40},
        },
        SHADOW: {
            'mind_blast':                       {SPELL:     8092,
                                                 READY:     True,
                                                 RANGE:     40,
                                                 OPENER:    True},
            'mind_flay':                        {SPELL:     15407,
                                                 RANGE:     40},
            'mind_sear':                        {SPELL:     48045,
                                                 RANGE:     40},
            'shadowform':                       {SPELL:     232698,
                                                 BUFF:      232698},
            'voidform':                         {SPELL:     194249,
                                                 BUFF:      194249},
            'silence':                          {SPELL:     15487,
                                                 READY:     True,
                                                 RANGE:     40,
                                                 INTERRUPT: True},
            'vampiric_touch':                   {SPELL:     34914,
                                                 DEBUFF:    34914,
                                                 RANGE:     40,
                                                 OPENER:    True},                             
            'void_eruption':                    {SPELL:     228260,
                                                 READY:     True,
                                                 RANGE:     40},
            'void_bolt':                        {SPELL:     205448,
                                                 READY:     True,
                                                 RANGE:     40},
            'dispersion':                       {SPELL:     47585,
                                                 READY:     True,
                                                 BUFF:      47585},
            'shadowfiend':                      {SPELL:     34433,
                                                 READY:     True,
                                                 RANGE:     40},
            
            
            #Talents
            'fortress_of_the_mind':             {SPELL:     193195},     
            'shadowy_insight':                  {SPELL:     162452,
                                                 BUFF:      124430},    
            'shadow_word_void':                 {SPELL:     205351,
                                                 READY:     True,
                                                 RANGE:     40,
                                                 OPENER:    True},

            'body_and_soul':                    {SPELL:     64129},
            'sanlayn':                          {SPELL:     199855},
            'mania':                            {SPELL:     193173},
            
            'twist_of_fate':                    {SPELL:     109142},
            'misery':                           {SPELL:     238558},
            'dark_void':                        {SPELL:     263346,
                                                 READY:     True,
                                                 RANGE:     40},
            
            'last_word':                        {SPELL:     263716},
            'mind_bomb':                        {SPELL:     205369,
                                                 RANGE:     40},
            'psychic_horror':                   {SPELL:     64044},
            
            'auspicious_spirits':               {SPELL:     155271},
            'shadow_word_death':                {SPELL:     32379,
                                                 READY:     True,
                                                 RANGE:     40},
            'shadow_crash':                     {SPELL:     205385,
                                                 READY:     True,
                                                 RANGE:     40},
            
            'lingering_insanity':               {SPELL:     199849},
            'mindbender':                       {SPELL:     200174,
                                                 READY:     True,
                                                 RANGE:     40},
            'void_torrent':                     {SPELL:     263165,
                                                 READY:     True,
                                                 RANGE:     40},
                                     
            'legacy_of_the_void':               {SPELL:     193225},
            'dark_ascension':                   {SPELL:     280711,
                                                 READY:     True,
                                                 RANGE:     40},
            'surrender_to_madness':             {SPELL:     193223,
                                                 READY:     True,
                                                 BUFF:      193223},

            # Azerite
            'thought_harvester':                {SPELL:     273319},
            'harvested_thoughts':               {SPELL:     273320,
                                                 BUFF:      273321},                                     
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
            'InsanityThreshold',
            'ExecuteRange'
        ],
    },
}
