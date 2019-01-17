# -*- coding: utf-8 -*-
"""
Hunter specific constants and functions.

@author: skasch
"""

from ..constants import (COMMON, SPELL, BUFF, DEBUFF,
                         PET, INTERRUPT, RANGE, BOOL,
                         GCDAOGCD, OGCDAOGCD, CD, READY, OPENER)

HUNTER = 'hunter'
BEAST_MASTERY = 'beast_mastery'
MARKSMANSHIP = 'marksmanship'
SURVIVAL = 'survival'

CLASS_SPECS = {
    HUNTER: {
        BEAST_MASTERY:      253,
        MARKSMANSHIP:       254,
        SURVIVAL:           255,
    },
}

DEFAULT_POTION = {
    HUNTER: {
        BEAST_MASTERY:  'battle_potion_of_agility',
        MARKSMANSHIP:   'battle_potion_of_agility',
        SURVIVAL:       'battle_potion_of_agility',
    }
}

DEFAULT_RANGE = {
    HUNTER: {
        SURVIVAL: 8,
    },
}

SPELL_INFO = {
    HUNTER: {
        COMMON: {
            'barrage':                      {SPELL:     120360,
                                             RANGE:     40,
                                             READY:     True},
            'binding_shot':                 {SPELL:     109248,
                                             CD:        True},
            'aspect_of_the_turtle':         {SPELL:     186265},
            'exhilaration':                 {SPELL:     109304,
                                             GCDAOGCD:  True},
            'aspect_of_the_cheetah':        {SPELL:     186257,
                                             CD:        True},
            'counter_shot':                 {SPELL:     147362},
            'disengage':                    {SPELL:     781},
            'freezing_trap':                {SPELL:     187650},
            'feign_death':                  {SPELL:     5384},
            'tar_trap':                     {SPELL:     187698},
            'a_murder_of_crows':            {SPELL:     131894,
                                             GCDAOGCD:  True},
            'summon_pet':                   {SPELL:     883,
                                             GCDAOGCD:  True},
        },
        BEAST_MASTERY: {
            'aspect_of_the_wild':           {SPELL:     193530,
                                             BUFF:      193530,
                                             GCDAOGCD:  True},
            'beast_cleave':                 {SPELL:     115939,
                                             BUFF:      118455,
                                             PET:       True},
            'bestial_wrath':                {SPELL:     19574,
                                             BUFF:      19574,
                                             GCDAOGCD:  True},
            'cobra_shot':                   {SPELL:     193455},
            'dire_beast':                   {SPELL:     120679,
                                             RANGE:     40},
            'kill_command':                 {SPELL:     34026},
            'aspect_of_the_beast':          {SPELL:     191384},
            'bestial_ferocity':             {SPELL:     191413},
            'chimaera_shot':                {SPELL:     53209},
            'barbed_shot':                  {SPELL:     217200},
            'scent_of_blood':               {SPELL:     193532},
            'one_with_the_pack':            {SPELL:     199528},
            'stampede':                     {SPELL:     201430,
                                             GCDAOGCD:  True},
            'multishot':                    {SPELL:     2643,
                                             RANGE:     40},
            'killer_instinct':              {SPELL:     273887},
            'frenzy':                       {SPELL:     272790,
                                             BUFF:      272790},
            'spitting_cobra':               {SPELL:     194407,
                                             GCDAOGCD:  True},
            # Azerite Traits
            'primal_instincts':             {SPELL:     279806,
                                             BUFF:      279810}, # CHECK BUFF ID
        },
        MARKSMANSHIP: {
            'aimed_shot':                   {SPELL:     19434,
                                             RANGE:     40,
                                             READY:     True},
            'arcane_shot':                  {SPELL:     185358},
            'bursting_shot':                {SPELL:     186387},
            'hunters_mark':                 {SPELL:     257284,
                                             DEBUFF:    257284},
            'trueshot':                     {SPELL:     288613,
                                             BUFF:      288613,
                                             GCDAOGCD:  True},
            'explosive_shot':               {SPELL:     212431},
            'lock_and_load':                {BUFF:      194594},
            'piercing_shot':                {SPELL:     198670,
                                             RANGE:     40},
            'trick_shot':                   {SPELL:     199522},
            'serpent_sting':                {SPELL:     271788,
                                             DEBUFF:    271788},
            'multishot':                    {SPELL:     257620,
                                             RANGE:     40},
            'double_tap':                   {SPELL:     260402},
            'calling_the_shots':            {SPELL:     260404},
            'streamline':                   {SPELL:     260367},
            'rapid_fire':                   {SPELL:     257044},
            'careful_aim':                  {SPELL:     260228},
            'master_marksman':              {SPELL:     260309,
                                             BUFF:      269576},
            'precise_shots':                {SPELL:     260240,
                                             BUFF:      260242},
            'steady_focus':                 {SPELL:     193533},
            'steady_shot':                  {SPELL:     56641},
            'trick_shots':                  {BUFF:      257622},
            'volley':                       {SPELL:     194386},
            # Azerite Traits
            'unerring_vision':              {SPELL:     274444,
                                             BUFF:      274446},
            'surging_shots':                {SPELL:     287707},
            'focused_fire':                 {SPELL:     278531},
            'in_the_rhythm':                {SPELL:     264198},
        },
        SURVIVAL: {
            'aspect_of_the_eagle':          {SPELL:     186289,
                                             BUFF:      186289,
                                             OGCDAOGCD: True,
                                             CD:        True},
            'carve':                        {SPELL:     187708,
                                             RANGE:     8,
                                             READY:     True},
            'flanking_strike':              {SPELL:     269751},
            'harpoon':                      {SPELL:     190925,
                                             GCDAOGCD:  True,
                                             OPENER:    True},
            'mongoose_bite':                {SPELL:     259387,
                                             READY:     True},
            'mongoose_fury':                {BUFF:      259388},
            'raptor_strike':                {SPELL:     186270,
                                             READY:     True},
            'butchery':                     {SPELL:     212436,
                                             GCDAOGCD:  True},
            'serpent_sting':                {SPELL:     259491,
                                             DEBUFF:    259491,
                                             READY:     True},
            'steel_trap':                   {SPELL:     162488,
                                             DEBUFF:    162487,
                                             OPENER:    True},
            'coordinated_assault':          {SPELL:     266779,
                                             BUFF:      266779,
                                             GCDAOGCD:  True,
                                             CD:        True},
            'shrapnel_bomb':                {DEBUFF:    270339},
            'wildfire_bomb':                {SPELL:     259495,
                                             DEBUFF:    269747},
            'guerrilla_tactics':            {SPELL:     264332},
            'chakrams':                     {SPELL:     259391},
            'kill_command':                 {SPELL:     259489},
            'wildfire_infusion':            {SPELL:     271014},
            'internal_bleeding':            {DEBUFF:    270343},
            'vipers_venom':                 {SPELL:     268501,
                                             BUFF:      268552},
            'terms_of_engagement':          {SPELL:     265895},
            'tip_of_the_spear':             {SPELL:     260285,
                                             BUFF:      260286},
            'birds_of_prey':                {SPELL:     260331},
            'alpha_predator':               {SPELL:     269737}, 
            'bloodseeker':                  {DEBUFF:    259277},
            'muzzle':                       {SPELL:     187707,
                                             INTERRUPT: True},
            # Azerite Traits
            'up_close_and_personal':        {SPELL:     278533},
            'wilderness_survival':          {SPELL:     278532},
            'blur_of_talons':               {SPELL:     277653,
                                             BUFF:      277969}, # CHECK BUFF ID
            'latent_poison':                {SPELL:     273283,
                                             DEBUFF:    273286}, # CHECK DEBUFF ID
            'venomous_fangs':               {SPELL:     274590},
        },
    },
}

ITEM_INFO = {
    'call_of_the_wild':             137101,
    'the_mantle_of_command':        144326,
    'parsels_tongue':               151805,
    'qapla_eredun_war_order':       137227,
    'frizzos_finger':               137043,
    'sephuzs_secret':               132452,
    'convergence_of_fates':         140806,
    'roar_of_the_seven_lions':      137080,
    'tarnished_sentinel_medallion': 147017,
}

CLASS_FUNCTIONS = {
    HUNTER: {
        COMMON: [
        ],
        BEAST_MASTERY: [
        ],
        MARKSMANSHIP: [
        ],
        SURVIVAL: [
            'SurvivalPreAPLSetup',
        ],
    },
}

def survival_next_wi_bomb(fun):

    from ..objects.lua import Literal

    def next_wi_bomb(self):
        call = self.simc
        if (self.condition_list[1] in 'shrapnel'):
            call = 'S.ShrapnelBomb:IsLearned()'
        elif (self.condition_list[1] in 'pheromone'):
            call = 'S.PheromoneBomb:IsLearned()'
        elif (self.condition_list[1] in 'volatile'):
            call = 'S.VolatileBomb:IsLearned()'
        return Literal(call, type_=BOOL)

    return next_wi_bomb

def survival_bloodseeker(fun):

    from ..objects.executions import Spell
    from ..objects.lua import Literal, Method, LuaExpression

    def bloodseeker(self):
        if (self.condition_list[1] in 'remains'):
            object_ = self.target_unit
            method = Method('DebuffRemainsP')
            args = [Spell(self.parent_action, 'bloodseeker', type_=DEBUFF)]
            return LuaExpression(object_, method, args)
        return Literal(self.simc)

    return bloodseeker

DECORATORS = {
    HUNTER: [
        {
            'class_name': 'Expression',
            'method': 'next_wi_bomb',
            'decorator': survival_next_wi_bomb,
        },
        {
            'class_name': 'Expression',
            'method': 'bloodseeker',
            'decorator': survival_bloodseeker,
        },
    ],
}

TEMPLATES = {
    HUNTER+SURVIVAL:    ('{context}'
                        '--- ======= ACTION LISTS =======\n'
                        'local function {function_name}()\n'
                        '{action_list_names}\n'
                        '  UpdateRanges()\n'
                        '  Everyone.AoEToggleEnemiesUpdate()\n'
                        '  S.WildfireBomb = CurrentWildfireInfusion()\n'
                        '  S.RaptorStrike = CurrentRaptorStrike()\n'
                        '  S.MongooseBite = CurrentMongooseBite()\n'
                        '{action_lists}\n'
                        '  if Everyone.TargetIsValid() then\n'
                        '{precombat_call}\n'
                        '{main_actions}\n'
                        '  end\n'
                        'end\n'
                        '\n{set_apl}')
}