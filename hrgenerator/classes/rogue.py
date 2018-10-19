# -*- coding: utf-8 -*-
"""
Rogue specific constants and functions.

@author: skasch
"""

from ..constants import COMMON, SPELL, BUFF, DEBUFF, RANGE

ROGUE = 'rogue'
ASSASSINATION = 'assassination'
OUTLAW = 'outlaw'
SUBTLETY = 'subtlety'

CLASS_SPECS = {
    ROGUE: {
        ASSASSINATION:      259,
        OUTLAW:             260,
        SUBTLETY:           261,
    },
}

DEFAULT_POTION = {
    ROGUE: {
        ASSASSINATION:  'prolonged_power',
        OUTLAW:         'prolonged_power',
        SUBTLETY:       'prolonged_power',
    }
}

DEFAULT_RANGE = {
    ROGUE: {
    },
}

SPELL_INFO = {
    ROGUE: {
        COMMON: {
            'fan_of_knives':                        {SPELL:     51723,
                                                     RANGE:     10},
            'subterfuge':                           {SPELL:     108208,
                                                     BUFF:      108208},
            'nightstalker':                         {SPELL:     14062},
            'shadow_focus':                         {SPELL:     108209},
            'marked_for_death':                     {SPELL:     137619},
            'death_from_above':                     {SPELL:     152150,
                                                     BUFF:      163786,
                                                     RANGE:     15},
            'deeper_stratagem':                     {SPELL:     193531},
            'anticipation':                         {SPELL:     114015},
            'vanish':                               {SPELL:     1856,
                                                     BUFF:      1856},
            'sprint':                               {SPELL:     2983,
                                                     BUFF:      2983},
            # Legendaries
            'the_dreadlords_deceit':                {BUFF:      208692},
            'the_first_of_the_dead':                {BUFF:      248110},
        },
        ASSASSINATION: {
            'hemorrhage':                           {SPELL:     16511},
            'rupture':                              {SPELL:     1943,
                                                     DEBUFF:    1943,
                                                     RANGE:     5},
            'mutilate':                             {SPELL:     1329},
            'deadly_poison_dot':                    {DEBUFF:    177918},
            'vendetta':                             {SPELL:     79140,
                                                     DEBUFF:    79140},
            'kingsbane':                            {SPELL:     192759,
                                                     DEBUFF:    192759},
            'envenom':                              {SPELL:     32645,
                                                     BUFF:      32645},
            'exsanguinate':                         {SPELL:     200806},
            'garrote':                              {SPELL:     703,
                                                     DEBUFF:    703},
            'toxic_blade':                          {SPELL:     245388,
                                                     DEBUFF:    245389},
            'surge_of_toxins':                      {DEBUFF:    192424},
            'elaborate_planning':                   {SPELL:     193640,
                                                     BUFF:      193641},
            'venom_rush':                           {SPELL:     152152},
            'crimson_tempest':                      {SPELL:     121411,
                                                     BUFF:      121411},
        },
        OUTLAW: {
            'blade_flurry':                         {SPELL:     13877,
                                                     BUFF:      13877,
                                                     RANGE:     8},
            'ghostly_strike':                       {SPELL:     196937,
                                                     DEBUFF:    196937},
            'broadsides':                           {BUFF:      193356},
            'pistol_shot':                          {SPELL:     185763},
            'quick_draw':                           {SPELL:     196938},
            'opportunity':                          {BUFF:      195627},
            'greenskins_waterlogged_wristcuffs':    {BUFF:      209420},
            'blunderbuss':                          {SPELL:     202897,
                                                     BUFF:      202895},
            'saber_slash':                          {SPELL:     193315},
            'adrenaline_rush':                      {SPELL:     13750,
                                                     BUFF:      13750},
            'cannonball_barrage':                   {SPELL:     185767,
                                                     RANGE:     35},
            'true_bearing':                         {BUFF:      193359},
            'curse_of_the_dreadblades':             {SPELL:     202665},
            'between_the_eyes':                     {SPELL:     199804},
            'run_through':                          {SPELL:     2098},
            'jolly_roger':                          {BUFF:      199603},
            'hidden_blade':                         {BUFF:      202753},
            'ambush':                               {SPELL:     8676},
            'slice_and_dice':                       {SPELL:     5171,
                                                     BUFF:      5171},
            'loaded_dice':                          {BUFF:      240837},
            'roll_the_bones':                       {SPELL:     193316},
            'killing_spree':                        {SPELL:     51690},
            'gouge':                                {SPELL:     1776},
            'dirty_tricks':                         {SPELL:     108216},
        },
        SUBTLETY: {
            'shuriken_storm':                       {SPELL:     197835,
                                                     RANGE:     10},
            'gloomblade':                           {SPELL:     200758},
            'backstab':                             {SPELL:     53},
            'shadow_blades':                        {SPELL:     121471,
                                                     BUFF:      121471},
            'symbols_of_death':                     {SPELL:     212283,
                                                     BUFF:      212283},
            'nightblade':                           {SPELL:     195452,
                                                     DEBUFF:    195452},
            'goremaws_bite':                        {SPELL:     209782},
            'shadow_dance':                         {SPELL:     185313,
                                                     BUFF:      185313},
            'vigor':                                {SPELL:     14983},
            'stealth':                              {SPELL:     1784,
                                                     BUFF:      1784},
            'dark_shadow':                          {SPELL:     245687},
            'finality_nightblade':                  {SPELL:     197395,
                                                     BUFF:      197498},
            'finality_eviscerate':                  {SPELL:     197393,
                                                     BUFF:      197496},
            'eviscerate':                           {SPELL:     196819},
            'feeding_frenzy':                       {BUFF:      238140},
            'shadowstrike':                         {SPELL:     185438},
            'enveloping_shadows':                   {SPELL:     238104},
        },
    },
}

ITEM_INFO = {
    'the_dreadlords_deceit':                137021,
    'insignia_of_ravenholdt':               137049,
    'mantle_of_the_master_assassin':        144236,
    'duskwalkers_footpads':                 137030,
    'greenskins_waterlogged_wristcuffs':    137099,
    'shivarran_symmetry':                   141321,
    'thraxis_tricksy_treads':               137031,
    'the_first_of_the_dead':                151818,
    'shadow_satyrs_walk':                   137032,
    'denial_of_the_halfgiants':             137100,
}

CLASS_FUNCTIONS = {
    ROGUE: {
        COMMON: [
        ],
        ASSASSINATION: [
        ],
        OUTLAW: [
        ],
        SUBTLETY: [
        ],
    },
}

def rogue_stealthed(fun):

    from ..objects.lua import Literal, Method, LuaExpression
    from ..constants import BOOL

    def stealthed(self):
        if (self.condition_list[1] in 'all'):
            self.args = [Literal('true'), Literal('true')]
        elif (self.condition_list[1] in 'rogue'):
            self.args = [Literal('true'), Literal('false')]
        return LuaExpression(self.player_unit, Method('IsStealthedP', type_=BOOL), args=self.args)

    return stealthed

def rogue_cp_max_spend(fun):

    from ..objects.lua import Literal

    def cp_max_spend(self):
        return Literal('Rogue.CPMaxSpend()')

    return cp_max_spend

def rogue_poisoned_bleeds(fun):
    
    from ..objects.lua import Literal

    def poisoned_bleeds(self):
        return Literal('Rogue.PoisonedBleeds()')

    return poisoned_bleeds

def rogue_exsanguinated(fun):

    from ..objects.lua import Literal, Method, LuaExpression
    from ..constants import BOOL

    def exsanguinated(self):
        return LuaExpression(None, Method('HL.Exsanguinated'), args=[self.target_unit, Literal(self.parent_action.execution().execution, convert=True, quoted=True)], type_=BOOL)

    return exsanguinated

DECORATORS = {
    ROGUE: [
        {
            'class_name': 'Expression',
            'method': 'stealthed',
            'decorator': rogue_stealthed,
        },
        {
            'class_name': 'Expression',
            'method': 'cp_max_spend',
            'decorator': rogue_cp_max_spend,
        },     
        {
            'class_name': 'Expression',
            'method': 'poisoned_bleeds',
            'decorator': rogue_poisoned_bleeds,
        },    
        {
            'class_name': 'Expression',
            'method': 'exsanguinated',
            'decorator': rogue_exsanguinated,
        },  
    ]
}