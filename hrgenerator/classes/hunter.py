# -*- coding: utf-8 -*-
"""
Hunter specific constants and functions.

@author: skasch
"""

from ..constants import (COMMON, SPELL, BUFF, DEBUFF,
                         PET, INTERRUPT, RANGE, BOOL)

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
        BEAST_MASTERY:  'prolonged_power',
        MARKSMANSHIP:   'prolonged_power',
        SURVIVAL:       'prolonged_power',
    }
}

DEFAULT_RANGE = {
    HUNTER: {
    },
}

SPELL_INFO = {
    HUNTER: {
        COMMON: {
            'multishot':                    {SPELL:     2643,
                                             RANGE:     40},
            'barrage':                      {SPELL:     120360,
                                             RANGE:     40},
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
            'muzzle':                       {SPELL:     187707,
                                             INTERRUPT: True},
            # Legendaries
            'parsels_tongue':               {BUFF:      248084},
            'sephuzs_secret':               {BUFF:      208052},
            # Azerite
            'up_close_and_personal':        {SPELL:     278533},
            'wilderness_survival':          {SPELL:     278532},
            'blur_of_talons':               {SPELL:     277653,
                                             BUFF:      277969}, # CHECK BUFF ID
            'latent_poison':                {SPELL:     273283,
                                             DEBUFF:    273286}, # CHECK DEBUFF ID
            'venomous_fangs':               {SPELL:     274590},
        },
        BEAST_MASTERY: {
            'aspect_of_the_wild':           {SPELL:     193530,
                                             BUFF:      193530},
            'beast_cleave':                 {SPELL:     115939,
                                             BUFF:      118455,
                                             PET:       True},
            'bestial_wrath':                {SPELL:     19574,
                                             BUFF:      19574},
            'cobra_shot':                   {SPELL:     193455},
            'dire_beast':                   {SPELL:     120679,
                                             RANGE:     40},
            'kill_command':                 {SPELL:     34026},
            'a_murder_of_crows':            {SPELL:     131894},
            'aspect_of_the_beast':          {SPELL:     191384},
            'bestial_ferocity':             {SPELL:     191413},
            'chimaera_shot':                {SPELL:     53209},
            'dire_frenzy':                  {SPELL:     217200,
                                             BUFF:      217200},
            'dire_stable':                  {SPELL:     193532},
            'one_with_the_pack':            {SPELL:     199528},
            'stampede':                     {SPELL:     201430},
            'titans_thunder':               {SPELL:     207068},
        },
        MARKSMANSHIP: {
            'aimed_shot':                   {SPELL:     19434,
                                             RANGE:     40},
            'arcane_shot':                  {SPELL:     185358},
            'bursting_shot':                {SPELL:     186387},
            'hunters_mark':                 {DEBUFF:    185365},
            'marked_shot':                  {SPELL:     185901,
                                             RANGE:     40},
            'marking_targets':              {BUFF:      223138},
            'trueshot':                     {SPELL:     193526,
                                             BUFF:      193526},
            'vulnerability':                {DEBUFF:    187131},
            'a_murder_of_crows':            {SPELL:     131894},
            'black_arrow':                  {SPELL:     194599},
            'explosive_shot':               {SPELL:     212431},
            'lock_and_load':                {BUFF:      194594},
            'patient_sniper':               {SPELL:     234588},
            'piercing_shot':                {SPELL:     198670,
                                             RANGE:     40},
            'sentinel':                     {SPELL:     206817},
            'sidewinders':                  {SPELL:     214579},
            'trick_shot':                   {SPELL:     199522},
            'windburst':                    {SPELL:     204147},
            'bullseye':                     {BUFF:      204090},
            'sentinels_sight':              {BUFF:      208913},
            'critical_aimed':               {BUFF:      242243},
            'serpent_sting':                {SPELL:     271788,
                                             DEBUFF:    271788},
            't20_2p_critical_aimed_damage': {BUFF:      242242},
        },
        SURVIVAL: {
            'aspect_of_the_eagle':          {SPELL:     186289,
                                             BUFF:      186289},
            'carve':                        {SPELL:     187708,
                                             RANGE:     8},
            'flanking_strike':              {SPELL:     269751},
            'harpoon':                      {SPELL:     190925},
            'mongoose_bite':                {SPELL:     259387},
            'mongoose_fury':                {BUFF:      259388},
            'raptor_strike':                {SPELL:     186270},
            'a_murder_of_crows':            {SPELL:     131894},
            'butchery':                     {SPELL:     212436},
            'serpent_sting':                {SPELL:     259491,
                                             DEBUFF:    259491},
            'steel_trap':                   {SPELL:     162488,
                                             DEBUFF:    162487},
            'summon_pet':                   {SPELL:     883},
            'coordinated_assault':          {SPELL:     266779,
                                             BUFF:      266779},
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
            'TargetDebuffRemainsP',
            'TargetDebuffP',
        ],
        SURVIVAL: [
        ],
    },
}


def marksmanship_lowest_vuln_within(fun):
    """
    Call TargetDebuffRemainsP function for lowest_vuln_within.
    """
    from ..objects.executions import Spell
    from ..objects.lua import LuaExpression, Method


    def lowest_vuln_within(self):
        """
        Return the condition when the prefix is lowest_vuln_within.
        """
        if self.player_unit.spec.simc == MARKSMANSHIP:
            object_ = None
            method = Method('TargetDebuffRemainsP')
            args = [Spell(self.parent_action, 'vulnerability', type_=DEBUFF)]
            return LuaExpression(object_, method, args)
        else:
            fun(self)

    return lowest_vuln_within


def marksmanship_debuff_remains(fun):
    """
    Call TargetDebuffRemainsP function for lowest_vuln_within.
    """
    from ..objects.lua import Method

    def remains(self):
        """
        Return the arguments for the expression debuff.spell.remains.
        """
        if self.condition.player_unit.spec.simc == MARKSMANSHIP:
            self.object_ = None
            self.method = Method('TargetDebuffRemainsP')
            self.args = [self.spell]
        else:
            fun(self)

    return remains


def marksmanship_debuff_ready(fun):
    """
    Call TargetDebuffRemainsP function for lowest_vuln_within.
    """
    from ..objects.lua import Method

    def ready(self):
        """
        Return the arguments for the expression debuff.spell.up/ready.
        """
        if self.condition.player_unit.spec.simc == MARKSMANSHIP:
            self.object_ = None
            self.method = Method('TargetDebuffP', type_=BOOL)
            self.args = [self.spell]
        else:
            fun(self)

    return ready

DECORATORS = {
    HUNTER: [
        {
            'class_name': 'Expression',
            'method': 'lowest_vuln_within',
            'decorator': marksmanship_lowest_vuln_within,
        },
        {
            'class_name': 'Debuff',
            'method': 'remains',
            'decorator': marksmanship_debuff_remains,
        },
        {
            'class_name': 'Debuff',
            'method': 'ready',
            'decorator': marksmanship_debuff_ready,
        },
    ],
}
