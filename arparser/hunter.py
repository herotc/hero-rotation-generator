# -*- coding: utf-8 -*-
"""
Hunter specific constants and functions.

@author: skasch
"""

from .constants import COMMON, SPELL, BUFF, DEBUFF, PET

HUNTER = 'hunter'
BEAST_MASTERY = 'beast_mastery'
MARKSMANSHIP = 'marksmanship'
SURVIVAL = 'survival'

HT_SPECS = {HUNTER: [BEAST_MASTERY, MARKSMANSHIP, SURVIVAL]}

HT_POTION = {
    HUNTER: {
        BEAST_MASTERY:  'prolonged_power',
        MARKSMANSHIP:   'prolonged_power',
        SURVIVAL:       'prolonged_power',
    }
}

HT_SPELL_INFO = {
    HUNTER: {
        COMMON: {
            'multishot':                    {SPELL:     2643},
            'barrage':                      {SPELL:     120360},
            'binding_shot':                 {SPELL:     109248},
            'volley':                       {SPELL:     194386},
            'aspect_of_the_turtle':         {SPELL:     186265},
            'exhilaration':                 {SPELL:     109304},
            'aspect_of_the_cheetah':        {SPELL:     186257},
            'counter_shot':                 {SPELL:     147362},
            'disengage':                    {SPELL:     781},
            'freezing_trap':                {SPELL:     187650},
            'feign_death':                  {SPELL:     5384},
            'tar_trap':                     {SPELL:     187698},
            # Legendaries
            'parsels_tongue':               {BUFF:      248084},
            'sephuzs_secret':               {BUFF:      208052},
        },
        BEAST_MASTERY: {
            'aspect_of_the_wild':           {SPELL:     193530},
            'beast_cleave':                 {SPELL:     115939,
                                             BUFF:      118455,
                                             PET:       True},
            'bestial_wrath':                {SPELL:     19574},
            'cobra_shot':                   {SPELL:     193455},
            'dire_beast':                   {SPELL:     120679},
            'kill_command':                 {SPELL:     34026},
            'a_murder_of_crows':            {SPELL:     131894},
            'aspect_of_the_beast':          {SPELL:     191384},
            'bestial_ferocity':             {SPELL:     191413},
            'chimaera_shot':                {SPELL:     53209},
            'dire_frenzy':                  {SPELL:     217200},
            'dire_stable':                  {SPELL:     193532},
            'one_with_the_pack':            {SPELL:     199528},
            'stampede':                     {SPELL:     201430},
            'titans_thunder':               {SPELL:     207068},
        },
        MARKSMANSHIP: {
            'aimed_shot':                   {SPELL:     19434},
            'arcane_shot':                  {SPELL:     185358},
            'bursting_shot':                {SPELL:     186387},
            'hunters_mark':                 {SPELL:     185365},
            'marked_shot':                  {SPELL:     185901},
            'marking_targets':              {SPELL:     223138},
            'true_shot':                    {SPELL:     193526},
            'vulnerability':                {SPELL:     197131},
            'a_murder_of_crows':            {SPELL:     131894},
            'black_arrow':                  {SPELL:     194599},
            'explosive_shot':               {SPELL:     212431},
            'lock_and_load':                {SPELL:     194594},
            'patient_sniper':               {SPELL:     234588},
            'piercing_shot':                {SPELL:     198670},
            'sentinel':                     {SPELL:     206817},
            'sidewinders':                  {SPELL:     214579},
            'trick_shot':                   {SPELL:     199522},
            'windburst':                    {SPELL:     204147},
            'bulls_eye':                    {SPELL:     204090},
            'sentinels_sight':              {SPELL:     208913},
            'critical_aimed':               {BUFF:      242243},
        },
        SURVIVAL: {
            'aspect_of_the_eagle':          {SPELL:     186289},
            'carve':                        {SPELL:     187708},
            'explosive_trap':               {SPELL:     191433,
                                             DEBUFF:    13812},
            'flanking_strike':              {SPELL:     202800},
            'harpoon':                      {SPELL:     190925},
            'lacerate':                     {SPELL:     185855},
            'mongoose_bite':                {SPELL:     190928},
            'mongoose_fury':                {SPELL:     190931},
            'raptor_strike':                {SPELL:     186270},
            'a_murder_of_crows':            {SPELL:     206505},
            'animal_instincts':             {SPELL:     204315},
            'butchery':                     {SPELL:     212436},
            'caltrops':                     {SPELL:     187698,
                                             DEBUFF:    194279},
            'dragonsfire_grenade':          {SPELL:     194855},
            'moknathal_tactics':            {SPELL:     201081},
            'serpent_sting':                {SPELL:     87935,
                                             DEBUFF:    118253},
            'snake_hunter':                 {SPELL:     201078},
            'spitting_cobra':               {SPELL:     194407},
            'steel_trap':                   {SPELL:     162488,
                                             DEBUFF:    162487},
            'throwing_axes':                {SPELL:     200163},
            'way_of_the_moknathal':         {SPELL:     201082},
            'fury_of_the_eagle':            {SPELL:     203415},
            'exposed_flank':                {SPELL:     252094},
        },
    },
}

HT_ITEM_INFO = {
    'call_of_the_wild':         137101,
    'the_mantle_of_command':    144326,
    'parsels_tongue':           151805,
    'qapla_eredun_war_order':   137227,
    'frizzos_finger':           137043,
    'sephuzs_secret':           132452,
    'convergence_of_fates':     140806,
}
