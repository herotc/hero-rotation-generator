# -*- coding: utf-8 -*-
"""
Demon Hunter specific constants and functions.

@author: skasch
"""

from .constants import MELEE, SPELL, BUFF, DEBUFF, COMMON, RANGE, BOOL

DEMONHUNTER = 'demonhunter'
HAVOC = 'havoc'
VENGEANCE = 'vengeance'

CLASS_SPECS = {
    DEMONHUNTER: {
        HAVOC:          577,
        VENGEANCE:      581,
    },
}

DEFAULT_POTION = {
    DEMONHUNTER: {
        HAVOC:      'prolonged_power',
        VENGEANCE:  'prolonged_power',
    }
}

SPELL_INFO = {
    DEMONHUNTER: {
        COMMON: {
            'annihilation':         {SPELL:     201427,
                                     MELEE:     True},
            'blade_dance':          {SPELL:     188499,
                                     RANGE:     8},
            'blade_dance1':         {SPELL:     188499,
                                     RANGE:     8},
            'consume_magic':        {SPELL:     183752},
            'chaos_strike':         {SPELL:     162794,
                                     MELEE:     True},
            'chaos_nova':           {SPELL:     179057},
            'death_sweep':          {SPELL:     210152},
            'demons_bite':          {SPELL:     162243,
                                     MELEE:     True},
            'eye_beam':             {SPELL:     198013,
                                     RANGE:     20},
            'eye_beam_tick':        {SPELL:     198013,
                                     RANGE:     20},
            'fel_rush':             {SPELL:     195072},
            'metamorphosis':        {SPELL:     191427,
                                     BUFF:      162264},
            'vengeful_retreat':     {SPELL:     198793},
            'blind_fury':           {SPELL:     203550},
            'bloodlet':             {SPELL:     206473},
            'chaos_blades':         {SPELL:     247938,
                                     BUFF:      247938},
            'chaos_cleave':         {SPELL:     206475},
            'demon_blades':         {SPELL:     203555},
            'demonic':              {SPELL:     213410},
            'demonic_appetite':     {SPELL:     206478},
            'demon_reborn':         {SPELL:     193897},
            'fel_barrage':          {SPELL:     211053,
                                     RANGE:     30},
            'felblade':             {SPELL:     232893},
            'fel_eruption':         {SPELL:     211881},
            'fel_mastery':          {SPELL:     192939},
            'first_blood':          {SPELL:     206416},
            'master_of_the_glaive': {SPELL:     203556},
            'momentum':             {SPELL:     206476,
                                     BUFF:      208628},
            'nemesis':              {SPELL:     206491,
                                     DEBUFF:    206491},
            'prepared':             {SPELL:     203551,
                                     BUFF:      203650},
            'fury_of_the_illidari': {SPELL:     201467,
                                     RANGE:     40},
            'fel_devastation':      {SPELL:     212084},
            'immolation_aura':      {SPELL:     178740},
            'shear':                {SPELL:     203782},
            'sigil_of_flame':       {SPELL:     204596},
            'soul_cleave':          {SPELL:     228477},
            'soul_carver':          {SPELL:     207407},
            'demon_spikes':         {SPELL:     203720,
                                     BUFF:      203819},
            'infernal_strike':      {SPELL:     189110},
        },
        HAVOC: {
            'throw_glaive':         {SPELL:     185123,
                                     RANGE:     30},
        },
        VENGEANCE: {
            'throw_glaive':         {SPELL:     204157},
        },
    },
}

ITEM_INFO = {
}

CLASS_FUNCTIONS = {
    DEMONHUNTER: {
        COMMON: [
        ],
        HAVOC: [
            'IsInMeleeRange',
            'IsMetaExtendedByDemonic',
            'MetamorphosisCooldownAdjusted',
        ],
        VENGEANCE: [
        ],
    },
}


def havoc_melee_condition(fun):
    """
    Add class specific conditions.
    """
    from .lua import LuaExpression, Method

    def custom_init(self):
        """
        Init of the Spell class.
        """
        fun(self)
        if (self.action.player.spec.simc == HAVOC
                and self.action.player.spell_property(self, MELEE)):
            self.additional_conditions = (
                [LuaExpression(None, Method('IsInMeleeRange'), [])]
                + self.additional_conditions)
    return custom_init


def havoc_extended_by_demonic_buff(fun):
    """
    Add extended_by_demonic for metamorphosis to buff. expression.
    """
    from .lua import Method

    def extended_by_demonic(self):
        """
        Return the arguments for the expression buff.spell.extended_by_demonic.
        """
        if (self.condition.player_unit.spec.simc == HAVOC
                and self.condition.condition_list[1] == 'metamorphosis'):
            self.object_ = None
            self.method = Method('IsMetaExtendedByDemonic', type_=BOOL)
            self.args = []
        else:
            fun(self)

    return extended_by_demonic


def havoc_metamorphosis_cooldown(fun):
    """
    Add cooldown_adjusted for metamorphosis to cooldown. expression.
    """
    from .lua import Method

    def adjusted_remains(self):
        """
        Return the arguments for the expression cooldown.spell.adjusted_remains.
        """
        if (self.condition.player_unit.spec.simc == HAVOC
                and self.condition.condition_list[1] == 'metamorphosis'):
            self.object_ = None
            self.method = Method('MetamorphosisCooldownAdjusted')
            self.args = []
        else:
            fun(self)

    return adjusted_remains

DECORATORS = {
    DEMONHUNTER: [
        {
            'class_name': 'Spell',
            'method': 'custom_init',
            'decorator': havoc_melee_condition,
        },
        {
            'class_name': 'Buff',
            'method': 'extended_by_demonic',
            'decorator': havoc_extended_by_demonic_buff,
        },
        {
            'class_name': 'Cooldown',
            'method': 'adjusted_remains',
            'decorator': havoc_metamorphosis_cooldown,
        },
    ],
}
