# -*- coding: utf-8 -*-
"""
Death Knight specific constants and functions.

@author: skasch
"""

from .constants import (SPELL, BUFF, DEBUFF, COMMON,
                        GCDAOGCD, OGCDAOGCD, USABLE, INTERRUPT,
                        MELEE, CD, RANGE)

DEATHKNIGHT = 'deathknight'
BLOOD = 'blood'
FROST = 'frost'
UNHOLY = 'unholy'

CLASS_SPECS = {
    DEATHKNIGHT: {
        BLOOD:          250,
        FROST:          251,
        UNHOLY:         252,
    },
}

DEFAULT_POTION = {
    DEATHKNIGHT: {
        BLOOD:  'prolonged_power',
        FROST:  'prolonged_power',
        UNHOLY: 'prolonged_power',
    }
}

SPELL_INFO = {
    DEATHKNIGHT: {
        COMMON: {
            'mind_freeze':                      {SPELL:     47528,
                                                 INTERRUPT: True,
                                                 MELEE:     True},
            'death_and_decay':                  {SPELL:     43265,
                                                 BUFF:      188290,
                                                 USABLE:    True,
                                                 RANGE:     30},
            'chains_of_ice':                    {SPELL:     45524},
            'unholy_strength':                  {BUFF:      53365},
            'blood_plague':                     {SPELL:     55078},
            'death_strike':                     {SPELL:     49998,
                                                 USABLE:    True},
            'blood_mirror':                     {SPELL:     206977},
            'heart_breaker':                    {SPELL:     221536},
            'deaths_caress':                    {SPELL:     195292},
            'frost_fever':                      {SPELL:     55095},
            'murderous_efficiency':             {SPELL:     207061},
            'runic_attenuation':                {SPELL:     207104},
            'anti_magic_shell':                 {SPELL:     48707},
            'icebound_fortitude':               {SPELL:     48792},
            'control_undead':                   {SPELL:     45524},
            'death_grip':                       {SPELL:     49576},
            'path_of_frost':                    {SPELL:     3714},
            'wraith_walk':                      {SPELL:     212552},
            'outbreak':                         {SPELL:     77575},
            'summon_pet':                       {SPELL:     46584},
            'virulent_plague':                  {DEBUFF:    191587},
            # Items
            # Ring of collapsing futures
            'temptation':                       {BUFF:      234143},
            # Legendaries
            'haemostasis':                      {BUFF:      235558},
            'cold_heart':                       {BUFF:      235599},
            'consorts_cold_core':               {SPELL:     235605},
            'kiljaedens_burning_wish':          {SPELL:     144259},
            'koltiras_newfound_will':           {SPELL:     208782},
            'perseverance_of_the_ebon_martyre': {SPELL:     216059},
            'seal_of_necrofantasia':            {SPELL:     212216},
            'toravons_whiteout_bindings':       {SPELL:     205628},
            'instructors_fourth_lesson':        {SPELL:     208713},
        },
        BLOOD: {
            'blooddrinker':                     {SPELL:     206931,
                                                 GCDAOGCD:  True},
            'rapid_decomposition':              {SPELL:     194662},
            'dancing_rune_weapon':              {SPELL:     49028,
                                                 BUFF:      81256,
                                                 OGCDAOGCD: True,
                                                 CD:        True},
            'marrowrend':                       {SPELL:     195182},
            'bone_shield':                      {BUFF:      195181},
            'blood_boil':                       {SPELL:     50842},
            'ossuary':                          {SPELL:     219786},
            'bonestorm':                        {SPELL:     194844,
                                                 RANGE:     8},
            'blood_shield':                     {BUFF:      77535},
            'consumption':                      {SPELL:     205223},
            'heart_strike':                     {SPELL:     206930},
            'crimson_scourge':                  {BUFF:      81141},
            'vampiric_blood':                   {SPELL:     55233,
                                                 BUFF:      55233},
        },
        FROST: {
            'remorseless_winter':               {SPELL:     196770,
                                                 BUFF:      196770,
                                                 RANGE:     8},
            'gathering_storm':                  {SPELL:     194912,
                                                 BUFF:      211805},
            'howling_blast':                    {SPELL:     49184,
                                                 RANGE:     30},
            'rime':                             {SPELL:     59052,
                                                 BUFF:      59052},
            'obliterate':                       {SPELL:     49020},
            'breath_of_sindragosa':             {SPELL:     152279,
                                                 DEBUFF:    155166},
            'frost_strike':                     {SPELL:     49143},
            'shattering_strikes':               {SPELL:     207057},
            'razorice':                         {DEBUFF:    51714},
            'sindragosas_fury':                 {SPELL:     190778},
            'pillar_of_frost':                  {SPELL:     51271,
                                                 BUFF:      51271},
            'frostscythe':                      {SPELL:     207230,
                                                 RANGE:     8},
            'killing_machine':                  {BUFF:      51124},
            'glacial_advance':                  {SPELL:     194913,
                                                 RANGE:     30},
            'empower_rune_weapon':              {SPELL:     47568},
            'horn_of_winter':                   {SPELL:     57330},
            'obliteration':                     {SPELL:     207256,
                                                 BUFF:      207256},
            'hungering_rune_weapon':            {SPELL:     207127,
                                                 BUFF:      207127},
            'icecap':                           {SPELL:     207126},
            'frozen_pulse':                     {SPELL:     194909},
            'freezing_fog':                     {SPELL:     207060},
            'icy_talons':                       {SPELL:     194878,
                                                 BUFF:      194879},
        },
        UNHOLY: {
            'epidemic':                         {SPELL:     207317,
                                                 RANGE:     10},
            'scourge_strike':                   {SPELL:     55090,
                                                 RANGE:     8},
            'clawing_shadows':                  {SPELL:     207311,
                                                 RANGE:     8},
            'master_of_ghouls':                 {BUFF:      246995},
            'soul_reaper':                      {SPELL:     130736,
                                                 DEBUFF:    130736},
            'army_of_the_dead':                 {SPELL:     42650},
            'apocalypse':                       {SPELL:     220143},
            'festering_wound':                  {DEBUFF:    194310},
            'dark_arbiter':                     {SPELL:     207349,
                                                 BUFF:      212412},
            'dark_transformation':              {SPELL:     63560},
            'summon_gargoyle':                  {SPELL:     49206},
            'shadow_infusion':                  {SPELL:     198943},
            'death_coil':                       {SPELL:     47541},
            'necrosis':                         {SPELL:     207346,
                                                 BUFF:      216974},
            'sudden_doom':                      {BUFF:      81340},
            'festering_strike':                 {SPELL:     85948},
            'defile':                           {SPELL:     152280},
            'blighted_rune_weapon':             {SPELL:     194918,
                                                 BUFF:      194918},
            'castigator':                       {SPELL:     207305},
        },
    },
}

ITEM_INFO = {
    'archimondes_hatred_reborn':        144249,
    'perseverance_of_the_ebon_martyr':  132459,
    'consorts_cold_core':               144293,
    'koltiras_newfound_will':           132366,
    'cold_heart':                       151796,
    'taktheritrixs_shoulderpads':       137075,
    'convergence_of_fates':             140806,
    'the_instructors_fourth_lesson':    132448,
    'ring_of_collapsing_futures':       142173,
    'horn_of_valor':                    133642,
    'draught_of_souls':                 140808,
    'feloiled_infernal_machine':        144482,
}

CLASS_FUNCTIONS = {
    DEATHKNIGHT: {
        COMMON: [
        ],
        BLOOD: [
        ],
        FROST: [
        ],
        UNHOLY: [
        ],
    },
}
