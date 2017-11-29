# -*- coding: utf-8 -*-
"""
Death Knight specific constants and functions.

@author: skasch
"""

from .constants import (SPELL, BUFF, DEBUFF, COMMON,
                        GCDAOGCD, OGCDAOGCD, USABLE, INTERRUPT, MELEE, CD)

DEATHKNIGHT = 'deathknight'
BLOOD = 'blood'
FROST = 'frost'
UNHOLY = 'unholy'

DK_SPECS = {DEATHKNIGHT: [BLOOD, FROST, UNHOLY]}

DK_POTION = {
    DEATHKNIGHT: {
        BLOOD:  'prolonged_power',
        FROST:  'prolonged_power',
        UNHOLY: 'prolonged_power',
    }
}

DK_SPELL_INFO = {
    DEATHKNIGHT: {
        COMMON: {
            'blooddrinker':                     {SPELL:     206931,
                                                 GCDAOGCD:  True},
            'blood_plague':                     {SPELL:     55078},
            'dancing_rune_weapon':              {SPELL:     49028,
                                                 BUFF:      81256,
                                                 OGCDAOGCD: True,
                                                 CD:        True},
            'death_strike':                     {SPELL:     49998,
                                                 USABLE:    True},
            'marrowrend':                       {SPELL:     195182},
            'bone_shield':                      {BUFF:      195181},
            'vampiric_blood':                   {SPELL:     55233},
            'blood_mirror':                     {SPELL:     206977},
            'bonestorm':                        {SPELL:     194844},
            'consumption':                      {SPELL:     205223},
            'death_and_decay':                  {SPELL:     43265,
                                                 BUFF:      188290,
                                                 USABLE:    True},
            'crimson_scourge':                  {BUFF:      81141},
            'rapid_decomposition':              {SPELL:     194662},
            'ossuary':                          {SPELL:     219786},
            'heart_strike':                     {SPELL:     206930},
            'blood_boil':                       {SPELL:     50842},
            'heart_breaker':                    {SPELL:     221536},
            'deaths_caress':                    {SPELL:     195292},
            'mind_freeze':                      {SPELL:     47528,
                                                 INTERRUPT: True,
                                                 MELEE:     True},
            'blood_shield':                     {BUFF:      77535},
            'chains_of_ice':                    {SPELL:     45524},
            'empower_rune_weapon':              {SPELL:     47568},
            'frost_fever':                      {SPELL:     55095},
            'frost_strike':                     {SPELL:     49143},
            'howling_blast':                    {SPELL:     49184},
            'obliterate':                       {SPELL:     49020},
            'pillar_of_frost':                  {SPELL:     51271},
            'razor_ice':                        {SPELL:     51714},
            'remorseless_winter':               {SPELL:     196770},
            'killing_machine':                  {SPELL:     51124},
            'rime':                             {SPELL:     59052},
            'unholy_strength':                  {SPELL:     53365},
            'breath_of_sindragosa':             {SPELL:     152279,
                                                 DEBUFF:    155166},
            'frost_scythe':                     {SPELL:     207230},
            'frozen_pulse':                     {SPELL:     194909},
            'freezing_fog':                     {SPELL:     207060},
            'gathering_storm':                  {SPELL:     194912,
                                                 BUFF:      211805},
            'glacial_advance':                  {SPELL:     194913},
            'horn_of_winter':                   {SPELL:     57330},
            'hungering_rune_weapon':            {SPELL:     207127},
            'icy_talons':                       {SPELL:     194878,
                                                 BUFF:      194879},
            'murderous_efficiency':             {SPELL:     207061},
            'obliteration':                     {SPELL:     207256},
            'runic_attenuation':                {SPELL:     207104},
            'shattering_strikes':               {SPELL:     207057},
            'icecap':                           {SPELL:     207126},
            'singragosas_fury':                 {SPELL:     190778},
            'anti_magic_shell':                 {SPELL:     48707},
            'icebound_fortitude':               {SPELL:     48792},
            'control_undead':                   {SPELL:     45524},
            'death_grip':                       {SPELL:     49576},
            'path_of_frost':                    {SPELL:     3714},
            'wraith_walk':                      {SPELL:     212552},
            'apocalypse':                       {SPELL:     220143},
            'army_of_the_dead':                 {SPELL:     42650},
            'scourge_strike':                   {SPELL:     55090},
            'dark_transformation':              {SPELL:     63560},
            'death_coil':                       {SPELL:     47541},
            'festering_strike':                 {SPELL:     85948},
            'outbreak':                         {SPELL:     77575},
            'summon_gargoyle':                  {SPELL:     49206},
            'summon_pet':                       {SPELL:     46584},
            'blighted_rune_weapon':             {SPELL:     194918},
            'epidemic':                         {SPELL:     207317},
            'castigator':                       {SPELL:     207305},
            'clawing_shadows':                  {SPELL:     207311},
            'necrosis':                         {SPELL:     207346,
                                                 BUFF:      216974},
            'shadow_infusion':                  {SPELL:     198943},
            'dark_arbiter':                     {SPELL:     207349,
                                                 BUFF:      212412},
            'defile':                           {SPELL:     152280},
            'soul_reaper':                      {DEBUFF:    130736},
            'master_of_ghouls':                 {SPELL:     246995},
            'sudden_doom':                      {SPELL:     81340},
            'festering_wounds':                 {SPELL:     194310},
            'virulent_plague':                  {DEBUFF:    191587},
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
        },
        FROST: {
        },
        UNHOLY: {
        },
    },
}

DK_ITEM_INFO = {
}
