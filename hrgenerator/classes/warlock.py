# -*- coding: utf-8 -*-
"""
Warlock specific constants and functions.

@author: skasch
"""

import os

from ..constants import COMMON, SPELL, BUFF, DEBUFF, RANGE

WARLOCK = 'warlock'
AFFLICTION = 'affliction'
DEMONOLOGY = 'demonology'
DESTRUCTION = 'destruction'

CLASS_SPECS = {
    WARLOCK: {
        AFFLICTION:         265,
        DEMONOLOGY:         266,
        DESTRUCTION:        267,
    },
}

DEFAULT_POTION = {
    WARLOCK: {
        AFFLICTION:     'prolonged_power',
        DEMONOLOGY:     'prolonged_power',
        DESTRUCTION:    'prolonged_power',
    }
}

DEFAULT_RANGE = {
    WARLOCK: {
    },
}

SPELL_INFO = {
    WARLOCK: {
        COMMON: {
            # 'summon_doomguard':                 {SPELL:     18540},
            # 'grimoire_of_supremacy':            {SPELL:     152107},
            # 'life_tap':                         {SPELL:     1454},
            # 'empowered_life_tap':               {SPELL:     235157,
            #                                      BUFF:      235156},
            # 'soul_harvest':                     {SPELL:     196098,
            #                                      BUFF:      196098},
            # 'infernal_awakening':               {SPELL:     173491,
            #                                      RANGE:     40},
            # Legendaries
            'lessons_of_spacetime':             {BUFF:      236174},
        },
        AFFLICTION: {
            'haunt':                            {SPELL:     48181,
                                                 DEBUFF:    48181},
            'sow_the_seeds':                    {SPELL:     196226},
            'agony':                            {SPELL:     980,
                                                 DEBUFF:    980},
            'drain_soul':                       {SPELL:     198590,
                                                 DEBUFF:    198590},
            'corruption':                       {SPELL:     172,
                                                 DEBUFF:    172,
                                                 RANGE:     40},
            'unstable_affliction':              {SPELL:     30108,
                                                 DEBUFF:    30108,
                                                 RANGE:     40},
            'siphon_life':                      {SPELL:     63106,
                                                 DEBUFF:    63106},
            'phantom_singularity':              {SPELL:     205179,
                                                 BUFF:      205179},
            'seed_of_corruption':               {SPELL:     27243,
                                                 RANGE:     40},
            'writhe_in_agony':                  {SPELL:     196102},
            'vile_taint':                       {SPELL:     278350,
                                                 DEBUFF:    278350},
            'dark_soul':                        {SPELL:     113860},
            'deathbolt':                        {SPELL:     264106},
            'summon_darkglare':                 {SPELL:     205180},
            'shadow_bolt':                      {SPELL:     232670},
            'grimoire_of_sacrifice':            {SPELL:     108503,
                                                 BUFF:      196099},
            'summon_pet':                       {SPELL:     691},
            'unstable_affliction_1':            {
                                                 DEBUFF:    233490,
                                                 RANGE:     40},
            'unstable_affliction_2':            {
                                                 DEBUFF:    233496,
                                                 RANGE:     40},
            'unstable_affliction_3':            {
                                                 DEBUFF:    233497,
                                                 RANGE:     40},   
            'unstable_affliction_4':            {
                                                 DEBUFF:    233498,
                                                 RANGE:     40},
            'unstable_affliction_5':            {
                                                 DEBUFF:    233499,
                                                 RANGE:     40},                                                                                                                                                
        },
        DEMONOLOGY: {
            'summon_pet':                       {SPELL:     30146},
            'inner_demons':                     {SPELL:     267216},
            'demonbolt':                        {SPELL:     264178},
            'soul_strike':                      {SPELL:     264057},
            'shadow_bolt':                      {SPELL:     686},
            'implosion':                        {SPELL:     196277,
                                                 RANGE:     40},
            #'wild_imps':                        {BUFF:}             ??? buff.wild_imps.stack -> Player:BuffStackP(S.WildImpsBuff)  
            'call_dreadstalkers':               {SPELL:     104316},
            #                                                        ??? buff.dreadstalkers.remains -> Player:BuffRemainsP(S.DreadstalkersBuff)
            'bilescourge_bombers':              {SPELL:     267211},
            'hand_of_guldan':                   {SPELL:     105174},
            'demonic_power':                    {BUFF:      265273},
            'summon_demonic_tyrant':            {SPELL:     265187},
            'grimoire_felguard':                {SPELL:     111898},
            #                                     BUFF:      }       ??? buff.grimoire_felguard.remains -> Player:BuffRemainsP(S.GrimoireFelguardBuff)
            'demonic_calling':                  {SPELL:     205145,
                                                 BUFF:      205146},
            'demonic_core':                     {BUFF:      264173},
            'summon_vilefiend':                 {SPELL:     264119},
            'nether_portal':                    {SPELL:     267217,
                                                 BUFF:      267218},
            'power_siphon':                     {SPELL:     264130},
            'doom':                             {SPELL:     603,
                                                 DEBUFF:    603},    
            'demonic_strength':                 {SPELL:     267171},
        },
        DESTRUCTION: {
            'summon_pet':                       {SPELL:     688},
            'grimoire_of_sacrifice':            {SPELL:     108503},
            'soul_fire':                        {SPELL:     6353},
            'incinerate':                       {SPELL:     29722},
            'rain_of_fire':                     {SPELL:     5740,
                                                 DEBUFF:    5740,
                                                 RANGE:     35},
            'cataclysm':                        {SPELL:     152108,
                                                 RANGE:     40},
            'immolate':                         {SPELL:     348,
                                                 DEBUFF:    157736,
                                                 RANGE:     40},    
            'channel_demonfire':                {SPELL:     196447,
                                                 RANGE:     40},
            'chaos_bolt':                       {SPELL:     116858,
                                                 RANGE:     40},   
            'havoc':                            {SPELL:     80240,
                                                 DEBUFF:    80240,
                                                 RANGE:     40},
                                                                #   ??? buff.active_havoc.remains -> Player:BuffRemainsP(S.ActiveHavocBuff)
            'grimoire_of_supremacy':            {SPELL:     266086,
                                                 BUFF:      266091},
            'conflagrate':                      {SPELL:     17962},
            'shadowburn':                       {SPELL:     17877,
                                                 DEBUFF:    17877},
            'backdraft':                        {SPELL:     196406,
                                                 BUFF:      117828},
            'summon_infernal':                  {SPELL:     1122,
                                                 RANGE:     30},
            'dark_soul_instability':            {SPELL:     113858,
                                                 BUFF:      113858},
            'flashover':                        {SPELL:     267115},
            'roaring_blaze':                    {SPELL:     205184,
                                                 DEBUFF:    265931},
            'internal_combustion':              {SPELL:     266134},
            'eradication':                      {SPELL:     196412,
                                                 DEBUFF:    196414},
            'fire_and_brimstone':               {SPELL:     196408},
            'inferno':                          {SPELL:     270545},
        },
    },
}

ITEM_INFO = {
    'lessons_of_spacetime':             144369,
}


CLASS_FUNCTIONS = {
    WARLOCK: {
        COMMON: [
            'FutureShard',
        ],
        AFFLICTION: [
            'UnstableAfflictionDebuffs',
            'ActiveUAs',
        ],
        DEMONOLOGY: [
        ],
        DESTRUCTION: [
        ],
    },
}


def warlock_soul_shard_value(fun):
    """
    Replaces the soul_shard expression with a call to FutureShard.
    """
    from ..objects.lua import Method

    def value(self):
        """
        Return the arguments for the expression soul_shard.
        """
        if self.condition.parent_action.player.class_.simc == WARLOCK:
            self.object_ = None
            self.method = Method('FutureShard')
        else:
            fun(self)

    return value


def affliction_active_uas_stack(fun):
    """
    Replaces the buff.active_uas.stack expression with a call to ActiveUAs.
    """
    from ..objects.lua import Method

    def stack(self):
        """
        Return the arguments for the expression buff.active_uas.stack.
        """
        if (self.condition.parent_action.player.spec.simc == AFFLICTION
                and self.condition.condition_list[1] == 'active_uas'):
            self.object_ = None
            self.method = Method('ActiveUAs')
            self.args = []
        else:
            fun(self)

    return stack

DECORATORS = {
    WARLOCK: [
        {
            'class_name': 'SoulShard',
            'method': 'value',
            'decorator': warlock_soul_shard_value,
        },
        {
            'class_name': 'Buff',
            'method': 'stack',
            'decorator': affliction_active_uas_stack,
        },
    ],
}
