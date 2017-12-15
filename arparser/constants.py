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

BLOODLUST = 'bloodlust'

BOOL = 'bool'
NUM = 'num'
TRUE = 'true'
FALSE = 'false'

GCDAOGCD = 'GCDasOffGCD'
OGCDAOGCD = 'OffGCDasOffGCD'
USABLE = 'usable'
INTERRUPT = 'interrupt'
MELEE = 'melee'
CD = 'cd'
PET = 'pet'
COMMON = 'common'
RANGE = 'range'

MAX_INT = 10**10

# Miscellaneous
# =============

# Named action lists to ignore in simc
IGNORED_ACTION_LISTS = [
]

# Named executions which should be ignored by ARParser
IGNORED_EXECUTIONS = [
    'auto_attack',
    'auto_shot',
    'food',
    'flask',
    'augmentation',
    'snapshot_stats',
    # Monk Brewmaster
    'greater_gift_of_the_ox',
    'gift_of_the_ox',
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
    'The': 'the',
    'Deathknight': 'DeathKnight',
    'Demonhunter': 'DemonHunter',
    'Apl': 'APL',
}

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
