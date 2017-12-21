# -*- coding: utf-8 -*-
"""
Mage specific constants and functions.

@author: skasch
"""

from .lua import LuaCastable, Method
from .executions import Variable
from .constants import COMMON, SPELL, BUFF, DEBUFF, PET, RANGE

MAGE = 'mage'
ARCANE = 'arcane'
FIRE = 'fire'
FROST = 'frost'

CLASS_SPECS = {
    MAGE: {
        ARCANE:         62,
        FIRE:           63,
        FROST:          64,
    },
}

DEFAULT_POTION = {
    MAGE: {
        ARCANE: 'deadly_grace',
        FIRE:   'prolonged_power',
        FROST:  'prolonged_power',
    }
}

SPELL_INFO = {
    MAGE: {
        COMMON: {
            'time_warp':                    {SPELL:     80353},
            'rune_of_power':                {SPELL:     116011,
                                             BUFF:      116014},
            'incanters_flow':               {BUFF:      1463},
            'ice_barrier':                  {SPELL:     11426},
            'ice_block':                    {SPELL:     45438},
            'invisibility':                 {SPELL:     66},
            'counterspell':                 {SPELL:     2139},
            'blink':                        {SPELL:     1953},
            # Items
            'deadly_grace':                 {BUFF:      188027},
            # Legendaries
            'rhonins_assaulting_armwraps':  {BUFF:      208081},
            'kaelthas_ultimate_ability':    {BUFF:      209455},
            'contained_infernal_core':      {BUFF:      248146},
            'erupting_infernal_core':       {BUFF:      248147},
            'zannesu_journey':              {BUFF:      206397},
        },
        ARCANE: {
            'arcane_charge':                {BUFF:      36032},
            'arcane_blast':                 {SPELL:     30451},
            'arcane_barrage':               {SPELL:     44425,
                                             RANGE:     40},
            'arcane_explosion':             {SPELL:     1449,
                                             RANGE:     10},
            'arcane_missiles':              {SPELL:     5143,
                                             BUFF:      79683,
                                             RANGE:     40},
            'arcane_power':                 {SPELL:     12042,
                                             BUFF:      12042},
            'evocation':                    {SPELL:     12051},
            'presence_of_mind':             {SPELL:     205025,
                                             BUFF:      205025},
            'expanding_mind':               {BUFF:      253262},
            'spell_steal':                  {SPELL:     30449},
            'polymorph':                    {SPELL:     118},
            'arcane_familiar':              {SPELL:     205022},
            'amplification':                {SPELL:     236628},
            'words_of_power':               {SPELL:     205035},
            'mirror_image':                 {SPELL:     55342},
            'incanters_flow':               {SPELL:     1463},
            'supernova':                    {SPELL:     157980},
            'charged_up':                   {SPELL:     205032},
            'resonance':                    {SPELL:     205028},
            'nether_tempest':               {SPELL:     114923},
            'unstable_magic':               {SPELL:     157976},
            'erosion':                      {SPELL:     205039,
                                             DEBUFF:    210134},
            'overpowered':                  {SPELL:     155147},
            'temporal_flux':                {SPELL:     234302},
            'arcane_orb':                   {SPELL:     153626},
            'mark_of_aluneth':              {SPELL:     224968},
            'prismatic_barrier':            {SPELL:     235450},
            'greater_invisibility':         {SPELL:     110959},
        },
        FIRE: {
            'fireball':                     {SPELL:     133},
            'pyroblast':                    {SPELL:     11366},
            'critical_mass':                {SPELL:     117216},
            'fire_blast':                   {SPELL:     108853},
            'hot_streak':                   {BUFF:      48108},
            'heating_up':                   {BUFF:      48107},
            'enhanced_pyrotechnics':        {SPELL:     157642},
            'dragons_breath':               {SPELL:     31661,
                                             RANGE:     12},
            'combustion':                   {SPELL:     190319,
                                             BUFF:      190319},
            'scorch':                       {SPELL:     2948},
            'flamestrike':                  {SPELL:     2120,
                                             RANGE:     40},
            'pyromaniac':                   {SPELL:     205020},
            'conflagration':                {SPELL:     205023},
            'firestarter':                  {SPELL:     205026},
            'blast_wave':                   {SPELL:     157981},
            'mirror_image':                 {SPELL:     55342},
            'alexstraszas_fury':            {SPELL:     235870},
            'flame_on':                     {SPELL:     205029},
            'controlled_burn':              {SPELL:     205033},
            'living_bomb':                  {SPELL:     44457,
                                             RANGE:     40},
            'flame_patch':                  {SPELL:     205037},
            'kindling':                     {SPELL:     155148},
            'cinderstorm':                  {SPELL:     198929},
            'meteor':                       {SPELL:     153561},
            'phoenixs_flames':              {SPELL:     194466,
                                             RANGE:     40},
            'big_mouth':                    {SPELL:     215796},
        },
        FROST: {
            'blizzard':                     {SPELL:     190356,
                                             RANGE:     35},
            'brain_freeze':                 {BUFF:      190446},
            'cone_of_cold':                 {SPELL:     120},
            'fingers_of_frost':             {BUFF:      44544},
            'icicles':                      {BUFF:      205473},
            'flurry':                       {SPELL:     44614},
            'freeze':                       {SPELL:     33395,
                                             PET:       True},
            'frost_nova':                   {SPELL:     122},
            'frostbolt':                    {SPELL:     116},
            'frozen_orb':                   {SPELL:     84714},
            'ice_lance':                    {SPELL:     30455},
            'icy_veins':                    {SPELL:     12472,
                                             BUFF:      12472},
            'summon_water_elemental':       {SPELL:     31687},
            'water_jet':                    {SPELL:     135029,
                                             PET:       True},
            'winters_chill':                {DEBUFF:    228358},
            'freezing_rain':                {SPELL:     240555},
            'ray_of_frost':                 {SPELL:     205021},
            'lonely_winter':                {SPELL:     205024},
            'bone_chilling':                {SPELL:     205027,
                                             BUFF:      205766},
            'shimmer':                      {SPELL:     212653},
            'ice_floes':                    {SPELL:     108839,
                                             BUFF:      108839},
            'glacial_insulation':           {SPELL:     235297},
            'mirror_image':                 {SPELL:     55342},
            'ice_nova':                     {SPELL:     157997},
            'frozen_touch':                 {SPELL:     205030},
            'splitting_ice':                {SPELL:     56377},
            'frost_bomb':                   {SPELL:     112948,
                                             DEBUFF:    112948},
            'unstable_magic':               {SPELL:     157976},
            'arctic_gale':                  {SPELL:     205038},
            'thermal_void':                 {SPELL:     155149},
            'glacial_spike':                {SPELL:     199786,
                                             BUFF:      199844},
            'comet_storm':                  {SPELL:     153595},
            'ebonbolt':                     {SPELL:     214634},
            'icy_hand':                     {SPELL:     220817},
            'cold_snap':                    {SPELL:     235219},
            'spellsteal':                   {SPELL:     30449},
            'frozen_mass':                  {BUFF:      242253},
        },
    },
}

ITEM_INFO = {
    'mystic_kilt_of_the_rune_master':   209280,
    'mantle_of_the_first_kirin_tor':    248098,
    'marquee_bindings_of_the_sun_king': 132406,
    'koralons_burning_touch':           132454,
    'shard_of_exodar':                  132410,
    'contained_infernal_core':          151809,
    'soul_of_the_archmage':             151642,
    'pyrotex_ignition_cloth':           144355,
    'sephuzs_secret':                   132452,
    'kiljaedens_burning_wish':          144259,
    'darcklis_dragonfire_diadem':       132863,
    'norgannons_foresight':             132455,
    'belovirs_final_stand':             133977,
    'prydaz_xavarics_magnum_opus':      132444,
    'shard_of_the_exodar':              132410,
}

CLASS_FUNCTIONS = {
    MAGE: {
        COMMON: [
        ],
        ARCANE: [
            'MaxStack',
            'BurnPhase',
        ],
        FIRE: [
        ],
        FROST: [
        ],
    },
}

def arcane_burn_phase_variables(fun):
    """
    Inject burn phase specific variables in the context.
    """

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        fun(self, spec)
        if self.class_.simc == MAGE and spec == ARCANE:
            self.apl.context.add_variable(Variable(None, 'burn_phase'))
            self.apl.context.add_variable(Variable(None, 'burn_phase_start'))
            self.apl.context.add_variable(Variable(None, 'burn_phase_duration'))

    return set_spec

def arcane_burn_phase(fun):
    """
    Handle start_burn_phase and stop_burn_phase executions.
    """

    def switch_type(self):
        """
        Return the couple type, object of the execution depending on its value.
        """
        if self.execution == 'start_burn_phase':
            type_, object_ = 'start_burn_phase', LuaCastable(
                cast_method=Method('StartBurnPhase'),
                cast_args=[],
                cast_template='{}'
            )
        elif self.execution == 'stop_burn_phase':
            type_, object_ = 'stop_burn_phase', LuaCastable(
                cast_method=Method('StopBurnPhase'),
                cast_args=[],
                cast_template='{}'
            )
        else:
            type_, object_ = fun(self)
        return type_, object_

    return switch_type


def arcane_burn_expressions(fun):
    """
    Handle burn phase specific variables.
    """

    def expression(self):
        """
        Return the expression of the condition.
        """
        if self.condition_list[0] in ['burn_phase', 'burn_phase_start',
                                      'burn_phase_duration']:
            return Variable(self.parent_action, self.condition_list[0])
        return fun(self)

    return expression


def arcane_max_stack(fun):
    """
    Handle max_stack expressions for Arcane.
    """

    def max_stack(self):
        """
        Return the arguments for the expression buff.spell.max_stack.
        """
        if self.condition.condition_list[1] == 'arcane_charge':
            self.object_ = self.condition.player_unit
            self.method = Method('ArcaneChargesMax')
            self.args = []
        elif self.condition.condition_list[1] == 'presence_of_mind':
            self.object_ = None
            self.method = Method('PresenceOfMindMax')
            self.args = []
        elif self.condition.condition_list[1] == 'arcane_missiles':
            self.object_ = None
            self.method = Method('ArcaneMissilesProcMax')
            self.args = []
        else:
            fun(self)

    return max_stack
