# -*- coding: utf-8 -*-
"""
Druid specific constants and functions.

@author: skasch
"""

from ..constants import SPELL, BUFF, DEBUFF, COMMON, RANGE

DRUID = 'druid'
BALANCE = 'balance'
FERAL = 'feral'
GUARDIAN = 'guardian'
RESTORATION = 'restoration'

CLASS_SPECS = {
    DRUID: {
        BALANCE:        102,
        FERAL:          103,
        GUARDIAN:       104,
        RESTORATION:    105,
    },
}

DEFAULT_POTION = {
    DRUID: {
        BALANCE:    'prolonged_power',
        FERAL:      'old_war',
        GUARDIAN:   'prolonged_power',
    }
}

SPELL_INFO = {
    DRUID: {
        COMMON: {
            'bear_form':                        {SPELL:     5487},
            'cat_form':                         {SPELL:     768,
                                                 BUFF:      768},
            'travel_form':                      {SPELL:     783},
            'swipe_bear':                       {SPELL:     213771,
                                                 RANGE:     8},
            'swipe_cat':                        {SPELL:     106785,
                                                 RANGE:     8},
            'thrash_bear':                      {SPELL:     77758,
                                                 DEBUFF:    192090,
                                                 RANGE:     8},
            'thrash_cat':                       {SPELL:     106830,
                                                 DEBUFF:    106830,
                                                 RANGE:     8},
            'moonfire_cat':                     {SPELL:     155625,
                                                 DEBUFF:    155625},
            'ferocious_bite':                   {SPELL:     22568},
            'rake':                             {SPELL:     1822,
                                                 DEBUFF:    155722},
            'rip':                              {SPELL:     1079,
                                                 DEBUFF:    1079},
            'shred':                            {SPELL:     5221},
            'moonfire':                         {SPELL:     8921,
                                                 DEBUFF:    164812,
                                                 RANGE:     40},
            'ironfur':                          {SPELL:     192081,
                                                 BUFF:      192081},
            'regrowth':                         {SPELL:     8936},
            'healing_touch':                    {SPELL:     5185},
            'rejuvenation':                     {SPELL:     774},
            'swiftmend':                        {SPELL:     18562},
            'balance_affinity':                 {SPELL:     197488},
            'restoration_affinity':             {SPELL:     197492},
            'frenzied_regeneration':            {SPELL:     22842},
            'survival_instincts':               {SPELL:     61336},
            'barkskin':                         {SPELL:     22812},
            'skull_bash':                       {SPELL:     106839},
            # Legendaries
            'oneths_intuition':                 {BUFF:      209406},
            'oneths_overconfidence':            {BUFF:      209407},
            'the_emerald_dreamcatcher':         {BUFF:      208190},
            'sephuzs_secret':                   {BUFF:      208052},
            'norgannons_foresight':             {BUFF:      236431},
            'fiery_red_maimers':                {BUFF:      236757},
        },
        BALANCE: {
            'moonkin_form':                     {SPELL:     24858},
            'celestial_alignment':              {SPELL:     194223,
                                                 BUFF:      194223},
            'lunar_strike':                     {SPELL:     194153,
                                                 RANGE:     40},
            'solar_wrath':                      {SPELL:     190984},
            'sunfire':                          {SPELL:     93402,
                                                 DEBUFF:    164815},
            'starsurge':                        {SPELL:     78674},
            'starfall':                         {SPELL:     191034,
                                                 RANGE:     40},
            'force_of_nature':                  {SPELL:     205636},
            'warrior_of_elune':                 {SPELL:     202425,
                                                 BUFF:      202425},
            'starlord':                         {SPELL:     202345},
            'renewal':                          {SPELL:     108235},
            'displacer_beast':                  {SPELL:     102280},
            'wild_charge':                      {SPELL:     102401},
            'feral_affinity':                   {SPELL:     202157},
            'guardian_affinity':                {SPELL:     197491},
            'mighty_bash':                      {SPELL:     5211},
            'mass_entanglement':                {SPELL:     102359},
            'typhoon':                          {SPELL:     132469},
            'soul_of_the_forest':               {SPELL:     114107},
            'incarnation':                      {SPELL:     102560,
                                                 BUFF:      102560},
            'stellar_flare':                    {SPELL:     202347},
            'shooting_stars':                   {SPELL:     202342},
            'astral_communion':                 {SPELL:     202359},
            'blessing_of_the_ancients':         {SPELL:     202360},
            'blessing_of_elune':                {SPELL:     202737,
                                                 BUFF:      202737},
            'blessing_of_anshe':                {BUFF:      202739},
            'fury_of_elune':                    {SPELL:     202770,
                                                 BUFF:      202770},
            'stellar_drift':                    {SPELL:     202354},
            'natures_balance':                  {SPELL:     202430},
            'new_moon':                         {SPELL:     202767},
            'half_moon':                        {SPELL:     202768},
            'full_moon':                        {SPELL:     202771},
            'innervate':                        {SPELL:     29166},
            'solar_beam':                       {SPELL:     78675},
            'entangling_roots':                 {SPELL:     339},
            'solar_empowerment':                {BUFF:      164545},
            'lunar_empowerment':                {BUFF:      164547},
            'stellar_empowerment':              {DEBUFF:    197637},
            'solar_solstice':                   {BUFF:      252767},
            'astral_acceleration':              {BUFF:      242232},
        },
        FERAL: {
            'moonkin_form':                     {SPELL:     197625},
            'berserk':                          {SPELL:     106951,
                                                 BUFF:      106951},
            'maim':                             {SPELL:     22570},
            'predatory_swiftness':              {BUFF:      69369},
            'prowl':                            {SPELL:     5215,
                                                 BUFF:      5215},
            'swipe':                            {SPELL:     106785,
                                                 RANGE:     8},
            'thrash':                           {SPELL:     106830,
                                                 RANGE:     8},
            'tigers_fury':                      {SPELL:     5217,
                                                 BUFF:      5217},
            'dash':                             {SPELL:     1850},
            'wild_charge':                      {SPELL:     49376},
            'bloodtalons':                      {SPELL:     155672,
                                                 BUFF:      145152},
            'brutal_slash':                     {SPELL:     202028,
                                                 RANGE:     8},
            'guardian_affinity':                {SPELL:     217615},
            'incarnation':                      {SPELL:     102543,
                                                 BUFF:      102543},
            'jungle_stalker':                   {BUFF:      252071},
            'jagged_wounds':                    {SPELL:     202032},
            'lunar_inspiration':                {SPELL:     155580},
            'sabertooth':                       {SPELL:     202031},
            'savage_roar':                      {SPELL:     52610,
                                                 BUFF:      52610},
            'renewal':                          {SPELL:     108238},
            'clearcasting':                     {BUFF:      135700},
            'apex_predator':                    {BUFF:      252752},
            'feral_frenzy':                     {SPELL:     274837},
            'moment_of_clarity':                {SPELL:     236068},
        },
        GUARDIAN:   {
            'moonkin_form':                     {SPELL:     197625},
            'gore':                             {BUFF:      93622},
            'gory_fur':                         {BUFF:      201671},
            'mangle':                           {SPELL:     33917},
            'maul':                             {SPELL:     6807},
            'blood_frenzy':                     {SPELL:     203962},
            'brambles':                         {SPELL:     203953},
            'bristling_fur':                    {SPELL:     155835},
            'earthwarden':                      {SPELL:     203974,
                                                 BUFF:      203975},
            'feral_affinity':                   {SPELL:     202155},
            'galactic_guardian':                {SPELL:     203964,
                                                 BUFF:      213708},
            'guardian_of_elune':                {SPELL:     155578,
                                                 BUFF:      213680},
            'incarnation':                      {SPELL:     102558,
                                                 BUFF:      102558},
            'lunar_beam':                       {SPELL:     204066},
            'pulverize':                        {SPELL:     80313,
                                                 BUFF:      158792},
            'soul_of_the_forest':               {SPELL:     158477},
            'rage_of_the_sleeper':              {SPELL:     200851},
            'growl':                            {SPELL:     6795},
            'lunar_strike':                     {SPELL:     197628},
            'solar_wrath':                      {SPELL:     197629},
            'starsurge':                        {SPELL:     197626},
            'sunfire':                          {SPELL:     197630,
                                                 DEBUFF:    164815},
        },
    },
}

ITEM_INFO = {
    'the_emerald_dreamcatcher': 137062,
    'lady_and_the_child':       144295,
    'oneths_intuition':         137092,
    'sephuzs_secret':           132452,
    'radiant_moonlight':        151800,
    'ailuro_pouncers':          137024,
    'luffa_wrappings':          137056,
}

CLASS_FUNCTIONS = {
    DRUID: {
        COMMON: [
        ],
        BALANCE: [
            'FutureAstralPower',
        ],
        FERAL: [
        ],
        GUARDIAN: [
            'Swipe',
            'Thrash',
        ],
    },
}


def balance_astral_power_value(fun):
    """
    Replaces the astral_power expression with a call to FutureAstralPower.
    """
    from ..objects.expressions import Method

    def value(self):
        """
        Return the arguments for the expression astral_power.
        """
        if self.condition.parent_action.player.spec.simc == BALANCE:
            self.object_ = None
            self.method = Method('FutureAstralPower')
        else:
            fun(self)

    return value


def guardian_swipe_thrash_value(fun):
    """
    Replaces the expression of a spell by a call to Swipe/Thrash specific
    functions for form check for guardian.
    """

    def print_lua(self):
        """
        Print the lua expression for the spell.
        """
        if (self.action.player.spec.simc == GUARDIAN
                and self.simc in ['swipe', 'thrash']):
            return f'{self.lua_name()}()'
        return fun(self)

    return print_lua

def guardian_print_swipe_thrash(fun):
    """
    Modify the function to add a spell to take into account the fact that swipe
    and thrash are two different spells for guardian.
    """
    import copy

    def add_spell(self, spell):
        """
        Add a spell to the context.
        """
        if (self.player.spec.simc == GUARDIAN
                and spell.simc in ['swipe', 'thrash']):
            spell_cat = copy.copy(spell)
            spell_cat.simc += '_cat'
            spell_bear = copy.copy(spell)
            spell_bear.simc += '_bear'
            fun(self, spell_cat)
            fun(self, spell_bear)
        else:
            fun(self, spell)

    return add_spell

DECORATORS = {
    DRUID: [
        {
            'class_name': 'AstralPower',
            'method': 'value',
            'decorator': balance_astral_power_value,
        },
        {
            'class_name': 'Spell',
            'method': 'print_lua',
            'decorator': guardian_swipe_thrash_value,
        },
        {
            'class_name': 'Context',
            'method': 'add_spell',
            'decorator': guardian_print_swipe_thrash,
        },
    ],
}
