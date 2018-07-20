# -*- coding: utf-8 -*-
"""
Death Knight specific constants and functions.

@author: skasch
"""

from ..constants import (SPELL, BUFF, DEBUFF, COMMON,
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
# TO-DO: Update talents, spellids and buffids for blood
SPELL_INFO = {
    DEATHKNIGHT: {
        COMMON: {
            #Racials
            'arcane_torrent':                   {SPELL:     50613,
                                                 GCDAOGCD:  True},
            'berserking':                       {SPELL:     26297,
                                                 OGCDAOGCD: True},
            'blood_fury':                       {SPELL:     20572,
                                                 OGCDAOGCD: True},
            'mind_freeze':                      {SPELL:     47528,
                                                 INTERRUPT: True,
                                                 MELEE:     True},
            
            'chains_of_ice':                    {SPELL:     45524},
            'unholy_strength':                  {BUFF:      53365},
            'blood_plague':                     {SPELL:     55078},
            'death_strike':                     {SPELL:     49998,
                                                 USABLE:    True},
            'blood_mirror':                     {SPELL:     206977},
            'heart_breaker':                    {SPELL:     221536},
            'deaths_caress':                    {SPELL:     195292},
            'anti_magic_shell':                 {SPELL:     48707},
            'icebound_fortitude':               {SPELL:     48792},
            'control_undead':                   {SPELL:     45524},
            'death_grip':                       {SPELL:     49576},
            'path_of_frost':                    {SPELL:     3714},
            'wraith_walk':                      {SPELL:     212552},
            # Items
            # Ring of collapsing futures
            'temptation':                       {BUFF:      234143},
            # Legendaries
            'haemostasis':                      {BUFF:      235558},
            'cold_heart_item':                  {BUFF:      235599},
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
            #Abilities
            'remorseless_winter':               {SPELL:     196770,
                                                 BUFF:      196770,
                                                 RANGE:     8},
            'howling_blast':                    {SPELL:     49184,
                                                 RANGE:     30},
            'obliterate':                       {SPELL:     49020},
            'frost_strike':                     {SPELL:     49143,
                                                 USABLE:    True},
            'pillar_of_frost':                  {SPELL:     51271,
                                                 GCDAOGCD:  True},
            'empower_rune_weapon':              {SPELL:     47568,
                                                 GCDAOGCD:  True},
            #Talents
            'icy_talons':                       {SPELL:     194878,
                                                 BUFF:      194879},
            'cold_heart_talent':                 {SPELL:     281208,
                                                 BUFF:      281209},
            'runic_attenuation':                {SPELL:     207104},
            'murderous_efficiency':             {SPELL:     207061},
            'horn_of_winter':                   {SPELL:     57330},
            'frozen_pulse':                     {SPELL:     194909},
            'frostscythe':                      {SPELL:     207230,
                                                 RANGE:     8},
            'gathering_storm':                  {SPELL:     194912,
                                                 BUFF:      211805},
            'glacial_advance':                  {SPELL:     194913,
                                                 RANGE:     30},
            'frostwyrms_fury':                  {SPELL:     279302},
            'icecap':                           {SPELL:     207126},
            'obliteration':                     {SPELL:     281238},
            'breath_of_sindragosa':             {SPELL:     152279,
                                                 GCDAOGCD:  True,
                                                 BUFF:      155166},
            #Buffs/Procs
            'rime':                             {SPELL:     59052},                                      
            'razorice':                         {DEBUFF:    51714},
            'killing_machine':                  {BUFF:      51124},
            'frost_fever':                      {SPELL:     55095},
            
        },
        UNHOLY: {
            #Abilities
            'death_and_decay':                  {SPELL:     43265,
                                                 BUFF:      188290,
                                                 RANGE:     30},
            'scourge_strike':                   {SPELL:     55090,
                                                 RANGE:     8},
            'army_of_the_dead':                 {SPELL:     42650,
                                                 GCDAOGCD:  True},
            'apocalypse':                       {SPELL:     275699},
            'dark_transformation':              {SPELL:     63560},
            'death_coil':                       {SPELL:     47541,
                                                 USABLE:    True},
            'festering_strike':                 {SPELL:     85948},
            'outbreak':                         {SPELL:     77575},
            'summon_pet':                       {SPELL:     46584},
            #Talents
            'clawing_shadows':                  {SPELL:     207311,
                                                 RANGE:     30},
            'unholy_blight':                    {SPELL:     115989},
            'soul_reaper':                      {SPELL:     130736},
            'pestilence':                       {SPELL:     277234},
            'defile':                           {SPELL:     152280},  
            'epidemic':                         {SPELL:     207317,
                                                 USABLE:    True,
                                                 RANGE:     10},
            'unholy_frenzy':                    {SPELL:     207289},
            'summon_gargoyle':                  {SPELL:     49206},
            #Buffs/Procs 
            'master_of_ghouls':                 {BUFF:      246995},
            'festering_wound':                  {DEBUFF:    194310},
            'sudden_doom':                      {BUFF:      81340},          
            'virulent_plague':                  {DEBUFF:    191587},
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
