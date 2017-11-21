# -*- coding: utf-8 -*-
"""
Initialize the arparser package.

@author: skasch
"""

# String constants
# ================

SPELL = 'spell'
ITEM = 'item'
BUFF = 'buff'
DEBUFF = 'debuff'
POTION = 'potion'
VARIABLE = 'variable'
CANCEL_BUFF = 'cancel_buff'
RUN_ACTION_LIST = 'run_action_list'
CALL_ACTION_LIST = 'call_action_list'
BOOL = 'bool'
NUM = 'num'
TRUE = 'true'
FALSE = 'false'

# Miscellaneous
# =============

# Named action lists to ignore in simc
IGNORED_ACTION_LISTS = [
    'precombat',
]

# Strings to recognize as items
ITEM_ACTIONS = [
]

# Mostly, words to lowercase when converting to lua names to match
# AethysRotation naming convention
WORD_REPLACEMENTS = {
    'And': 'and',
    'Blooddrinker': 'BloodDrinker',
    'Of': 'of',
    'Deathknight': 'DeathKnight',
    'Demonhunter': 'DemonHunter',
}

# Define specific categories for skills
# =====================================

# GCDs to use as OffGCD according to AethysRotation settings
GCD_AS_OFF_GCD = [
    'blood_drinker',
]

# OffGCDs to use as OffGCD according to AethysRotation settings
OFF_GCD_AS_OFF_GCD = [
    'dancing_rune_weapon',
    'arcane_torrent',
]

# Skills for which to call IsUsable instead of IsCastable
USABLE_SKILLS = [
    'death_strike',
    'death_and_decay',
]

INTERRUPT_SKILLS = [
    'mind_freeze',
]

# Skills for which "melee" must be specified as an argument of IsCastable
MELEE_SKILLS = [
    'mind_freeze',
    'annihilation',
    'chaos_strike',
    'demons_bite',
]

CD_SKILLS = [
    'dancing_rune_weapon',
]

# Expressions operators
# =====================

# simc > lua map for unary operators
UNARY_OPERATORS = {
    '-': '-',
    '!': 'not',
    'abs': 'math.abs',
    'floor': 'math.floor',
    'ceil': 'math.ceil',
}

# simc > lua map for binary operators
BINARY_OPERATORS = {
    '&': 'and',
    '|': 'or',
    '+': '+',
    '-': '-',
    '*': '*',
    '%': '/',
    '=': '==',
    '!=': '~=',
    '<': '<',
    '<=': '<=',
    '>': '>',
    '>=': '>=',
    # TODO Handle the in/not_in cases
}

LOGIC_OPERATORS = ['&', '|', '!']
COMPARISON_OPERATORS = ['!=', '<=', '>=', '=', '<', '>']
ADDITION_OPERATORS = ['+', '-']
MULTIPLIACTION_OPERATORS = ['*', '%']
FUNCTION_OPERATORS = ['abs', 'floor', 'ceil']

TYPE_CONVERSION = {
    NUM: {
        NUM: '{}',
        BOOL: 'bool({})',
    },
    BOOL: {
        NUM: 'num({})',
        BOOL: '{}',
    },
}

# Unit specific constants
# =======================

CLASS_SPECS = {
    'deathknight': ['blood', 'frost', 'unholy'],
    'demonhunter': ['havoc'],
    'mage': ['arcane'],
}

RACES = [
    'blood_elf',
    'draenei',
    'dwarf',
    'gnome',
    'goblin',
    'human',
    'night_elf',
    'orc',
    'pandaren',
    'tauren',
    'troll',
    'undead',
    'worgen',
]
