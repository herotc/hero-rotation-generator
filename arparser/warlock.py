# -*- coding: utf-8 -*-
"""
Warlock specific constants and functions.

@author: skasch
"""

import os

from .lua import Method
from .constants import COMMON, SPELL, BUFF, DEBUFF, RANGE

WARLOCK = 'warlock'
AFFLICTION = 'affliction'
DEMONOLOGY = 'demonology'
DESTRUCTION = 'destruction'

WL_SPECS = {
    WARLOCK: {
        AFFLICTION:         265,
        DEMONOLOGY:         266,
        DESTRUCTION:        267,
    },
}

WL_POTION = {
    WARLOCK: {
        AFFLICTION:     'prolonged_power',
        DEMONOLOGY:     'prolonged_power',
        DESTRUCTION:    'prolonged_power',
    }
}

WL_SPELL_INFO = {
    WARLOCK: {
        COMMON: {
            'summon_infernal':                  {SPELL:     1122,
                                                 RANGE:     30},
            'summon_doomguard':                 {SPELL:     18540},
            'grimoire_of_supremacy':            {SPELL:     152107},
            'life_tap':                         {SPELL:     1454},
            'empowered_life_tap':               {SPELL:     235157,
                                                 BUFF:      235156},
            'soul_harvest':                     {SPELL:     196098,
                                                 BUFF:      196098},
            'infernal_awakening':               {SPELL:     173491,
                                                 RANGE:     40},
            'concordance_of_the_legionfall':    {BUFF:      242586},
            # Legendaries
            'lessons_of_spacetime':             {BUFF:      236174},
        },
        AFFLICTION: {
            'reap_souls':                       {SPELL:     216698},
            'deadwind_harvester':               {BUFF:      216708},
            'tormented_souls':                  {BUFF:      216695},
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
            'malefic_grasp':                    {SPELL:     235155},
            'seed_of_corruption':               {SPELL:     27243,
                                                 RANGE:     40},
            'contagion':                        {SPELL:     196105},
            'deaths_embrace':                   {SPELL:     234876},
            'writhe_in_agony':                  {SPELL:     196102},
        },
        DEMONOLOGY: {
            'implosion':                        {SPELL:     196277,
                                                 RANGE:     40},
            'shadow_bolt':                      {SPELL:     686},
            'demonic_synergy':                  {BUFF:      171982},
            'soul_conduit':                     {SPELL:     215941},
            'hand_of_guldan':                   {SPELL:     105174},
            'shadowflame':                      {SPELL:     205181,
                                                 DEBUFF:    205181},
            'call_dreadstalkers':               {SPELL:     104316},
            'summon_darkglare':                 {SPELL:     205180},
            'power_trip':                       {SPELL:     196605},
            'demonic_calling':                  {SPELL:     205145,
                                                 BUFF:      205146},
            'doom':                             {SPELL:     603,
                                                 DEBUFF:    603},
            'hand_of_doom':                     {SPELL:     196283},
            'shadowy_inspiration':              {SPELL:     196269,
                                                 BUFF:      196606},
            'thalkiels_ascendance':             {SPELL:     238145},
            'demonic_empowerment':              {SPELL:     193396,
                                                 BUFF:      193396},
            'thalkiels_consumption':            {SPELL:     211714},
            'demonwrath':                       {SPELL:     193440,
                                                 RANGE:     40},
            'demonbolt':                        {SPELL:     157695},
        },
        DESTRUCTION: {
            'immolate':                         {SPELL:     348,
                                                 DEBUFF:    157736,
                                                 RANGE:     40},
            'roaring_blaze':                    {SPELL:     205184,
                                                 DEBUFF:    205690},
            'havoc':                            {SPELL:     80240,
                                                 DEBUFF:    80240,
                                                 RANGE:     40},
            'wreak_havoc':                      {SPELL:     196410},
            'dimensional_rift':                 {SPELL:     196586},
            'cataclysm':                        {SPELL:     152108,
                                                 RANGE:     40},
            'fire_and_brimstone':               {SPELL:     196408},
            'conflagrate':                      {SPELL:     17962},
            'shadowburn':                       {SPELL:     17877,
                                                 DEBUFF:    17877},
            'conflagration_of_chaos':           {SPELL:     219195,
                                                 BUFF:      196546},
            'chaos_bolt':                       {SPELL:     116858,
                                                 RANGE:     40},
            'backdraft':                        {SPELL:     196406,
                                                 BUFF:      117828},
            'grimoire_of_service':              {SPELL:     108501},
            'lord_of_flames':                   {SPELL:     224103,
                                                 BUFF:      226802},
            'channel_demonfire':                {SPELL:     196447,
                                                 RANGE:     40},
            'rain_of_fire':                     {SPELL:     5740,
                                                 DEBUFF:    5740,
                                                 RANGE:     35},
            'incinerate':                       {SPELL:     29722},
        },
    },
}

WL_ITEM_INFO = {
    'lessons_of_spacetime':             144369,
}


WL_FUNCTIONS = {
    WARLOCK: {
        COMMON: [
            'FutureShard',
        ],
        AFFLICTION: [
            'UnstableAfflictionDebuffs',
            'ActiveUAs',
        ],
    },
}


def affliction_functions(fun):
    """
    Adds melee range prediction with movement skills for Havoc.
    """

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        if spec == AFFLICTION:
            for affliction_fun in WL_FUNCTIONS[WARLOCK][AFFLICTION]:
                lua_fun = ''
                lua_file_path = os.path.join(
                    os.path.dirname(__file__),
                    'luafunctions',
                    f'{affliction_fun}.lua'
                )
                with open(lua_file_path) as lua_file:
                    lua_fun = lua_file.read()
                self.apl.context.add_code(lua_fun)
        fun(self, spec)

    return set_spec


def warlock_soul_shard_value(fun):
    """
    Replaces the soul_shard expression with a call to FutureShard.
    """

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
