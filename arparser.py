# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 12:22:12 2017

@author: rmondoncancel
"""

ITEM_ACTIONS = [
    'potion',
]

ADDITIONAL_PARAMETERS = {
    'dancing_rune_weapon': 'Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon',
    'arcane_torrents': 'Settings.Blood.OffGCDasOffGCD.ArcaneTorrent',
    'blood_drinker': 'Settings.Blood.GCDasOffGCD.BloodDrinker',
}

USABLE_SKILLS = [
    'death_strike',
    'death_and_decay',
]

ADDITIONAL_CONDITIONS = {
    'potion': 'Settings.Commons.UsePotions',
}

INTERRUPT_SKILLS = [
    'mind_freeze',
]

CD_SKILLS = [
    'dancing_rune_weapon',
]

SPELL_REPLACEMENTS = {
    'And': 'and',
    'Blooddrinker': 'BloodDrinker',
}

SPELL = 'spell'
BUFF = 'buff'

UNARY_OPERATORS = {
    # TODO the - unary case
    '!': 'not',
    'abs': 'math.abs',
    'floor': 'math.floor',
    'ceil': 'math.ceil',
}

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
    '<=': '<=',
    # TODO Handle the in/not_in cases
}

COMPARISON_OPERATORS = ['!=', '<=', '>=', '=', '<', '>']
ADDITION_OPERATORS = ['+', '-']
MULTIPLIACTION_OPERATORS = ['*', '%']
FUNCTION_OPERATORS = ['abs', 'floor', 'ceil']


class Player:

    def __init__(self):
        pass

    def setClass(self, class_):
        self.class_ = class_

    def potion(self):
        return self.class_.potion()

    def parse_lua(self):
        return 'Player'


class DeathKnight:

    def __init__(self):
        pass

    def potion(self):
        return Item("ProlongedPower")


class Item:

    def __init__(self, name):
        self.name = name


class APL:

    def __init__(self, player):
        self.player = player


class ActionList:

    def __init__(self, player):
        self.player = player


class Action:

    def __init__(self, action_list, action):
        self.action_list = action_list
        self.player = action_list.player
        self.action = action

    def execution(self):
        return Execution(self)

    def condition_expression(self):
        return ConditionExpression(self)

    def type_(self):
        if self.execution().string() in ITEM_ACTIONS:
            return ActionType('item')
        else:
            return ActionType('spell')


class Execution:

    def __init__(self, action, execution):
        self.action = action
        self.execution = execution

    def string(self):
        return self.execution


class ActionType:

    def __init__(self, type_):
        self.type_ = type_


class Spell:

    def __init__(self, simc, type_=SPELL):
        self.simc = simc
        self.type_ = type_

    def ar(self):
        ar_name = self.simc.replace('_', ' ').title().replace(' ', '')
        for simc_str, ar_str in SPELL_REPLACEMENTS.items():
            ar_name.replace(simc_str, ar_str)
        return ar_name

    def parse_lua(self):
        if self.type_ == SPELL:
            return f'S.{self.ar()}'
        elif self.type_ == BUFF:
            return f'S.{self.ar()}Buff'


class Condition:

    def __init__(self, condition_expression, simc):
        self.condition_expression = condition_expression
        self.action = condition_expression.action
        self.simc = simc

    def expression(self):
        try:
            return getattr(self, self.condition_list()[0])()
        except:
            return Literal(self.simc)

    def condition_list(self):
        return self.simc.split('.')

    def cooldown(self):
        return Cooldown(self)

    def buff(self):
        return Buff(self)

    def gcd(self):
        return LuaExpression(self, self.action.player, Method('GCD'), [])

    def runic_power(self):
        return RunicPower(self)

    def talent(self):
        return Talent(self)

    def charges_fractional(self):
        return LuaExpression(
            self, Spell('blood_boil'), Method('ChargesFractional'), [])

    def rune(self):
        return Rune(self)


class BinaryOperator:

    def __init__(self, symbol):
        self.symbol = symbol

    def parse_lua(self):
        return BINARY_OPERATORS[self.symbol]


class UnaryOperator:

    def __init__(self, symbol):
        self.symbol = symbol

    def parse_lua(self):
        return UNARY_OPERATORS[self.symbol]


class ConditionExpression:

    def __init__(self, action, simc, exps=None):
        expressions = exps.copy() if exps is not None else []
        self.action = action
        self.parse_parentheses(simc, expressions)

    def parse_parentheses(self, simc, expressions=[]):
        """
        Replaces first-level parentheses by {} and saves the content of
        parentheses in a list of strings.
        """
        n_parentheses = 0
        parsed_simc = ''
        for i, c in enumerate(simc):
            if c == '(':
                n_parentheses += 1
                # save index to extract substring for expressions
                if n_parentheses == 1:
                    start_index = i
            elif c == ')':
                n_parentheses -= 1
                if n_parentheses == 0:
                    end_index = i
                    expressions.append(simc[start_index + 1:end_index])
                    parsed_simc += '{}'
                if n_parentheses < 0:
                    raise ValueError('Invalid condition expression')
            elif n_parentheses == 0:
                # Only write in parsed_simc of not in a sub-expression
                parsed_simc += c
        self.simc = parsed_simc
        self.expressions = expressions

    def grow_binary_tree(self, symbol):
        symbol_index = self.simc.find(symbol)
        left_simc = self.simc[:symbol_index]
        right_simc = self.simc[symbol_index + 1:]
        n_expressions_before = left_simc.count('{}')
        left_exps = self.expressions[:n_expressions_before]
        right_exps = self.expressions[n_expressions_before:]
        return ConditionBinaryNode(
            self,
            BinaryOperator(symbol),
            ConditionExpression(self.action, left_simc, left_exps),
            ConditionExpression(self.action, right_simc, right_exps))

    def grow_unary_tree(self, symbol):
        try:
            assert self.simc.find(symbol) == 0
        except AssertionError:
            raise ValueError((f'Invalid expression, unary operator should be '
                              f'at the beginning: {self.simc}'))
        exp = self.simc[len(symbol):]
        return ConditionUnaryNode(
            self,
            UnaryOperator(symbol),
            ConditionExpression(self.action, exp, self.expressions))

    def extract_first_operator(self, symbols):
        valid_symbols = [symbol for symbol in symbols if symbol in self.simc]
        symbols_indexes = [self.simc.find(symbol) for symbol in valid_symbols]
        first_symbol_index = symbols_indexes.index(min(symbols_indexes))
        return valid_symbols[first_symbol_index]

    def has_symbol_in(self, symbols):
        return any(symbol in self.simc for symbol in symbols)

    def grow(self):
        """
        Use simc precedence: https://github.com/simulationcraft/simc/wiki/ActionLists#complete-list-of-operators
        """
        if '|' in self.simc:
            return self.grow_binary_tree('|')
        if '&' in self.simc:
            return self.grow_binary_tree('&')
        if self.has_symbol_in(COMPARISON_OPERATORS):
            symbol = self.extract_first_operator(COMPARISON_OPERATORS)
            return self.grow_binary_tree(symbol)
        if self.has_symbol_in(ADDITION_OPERATORS):
            symbol = self.extract_first_operator(ADDITION_OPERATORS)
            return self.grow_binary_tree(symbol)
        if self.has_symbol_in(MULTIPLIACTION_OPERATORS):
            symbol = self.extract_first_operator(MULTIPLIACTION_OPERATORS)
            return self.grow_binary_tree(symbol)
        if '!' in self.simc:
            return self.grow_unary_tree('!')
        if self.has_symbol_in(FUNCTION_OPERATORS):
            symbol = self.extract_first_operator(FUNCTION_OPERATORS)
            return self.grow_unary_tree(symbol)
        if self.simc == '{}':
            try:
                assert len(self.expressions) == 1
            except AssertionError:
                raise ValueError((f'Invalid expressions stack: '
                                  f'{str(self.expressions)}'))
            return ConditionParenthesesNode(
                self,
                ConditionExpression(
                    self.action, self.expressions[0]))
        return ConditionLeaf(self, self.simc)


class ConditionNode:

    def __init__(self, condition_expression):
        self.action = condition_expression.action
        self.condition_expression = condition_expression

    def parse_lua(self):
        pass


class ConditionBinaryNode(ConditionNode):

    def __init__(self, condition_expression, operator, left_expression,
                 right_expression):
        self.action = condition_expression.action
        self.condition_expression = condition_expression
        self.operator = operator
        self.left_tree = left_expression.grow()
        self.right_tree = right_expression.grow()

    def parse_lua(self):
        return (f'{self.left_tree.parse_lua()} {self.operator.parse_lua()} '
                f'{self.right_tree.parse_lua()}')


class ConditionUnaryNode(ConditionNode):

    def __init__(self, condition_expression, operator, sub_expression):
        self.action = condition_expression.action
        self.condition_expression = condition_expression
        self.operator = operator
        self.sub_tree = sub_expression.grow()

    def parse_lua(self):
        return f'{self.operator.parse_lua()} {self.sub_tree.parse_lua()}'


class ConditionParenthesesNode(ConditionNode):

    def __init__(self, condition_expression, sub_expression):
        self.action = condition_expression.action
        self.condition_expression = condition_expression
        self.sub_tree = sub_expression.grow()

    def parse_lua(self):
        return f'({self.sub_tree.parse_lua()})'


class ConditionLeaf(ConditionNode):

    def __init__(self, condition_expression, condition):
        self.action = condition_expression.action
        self.condition_expression = condition_expression
        self.condition = Condition(condition_expression, condition)

    def parse_lua(self):
        return f'{self.condition.expression().parse_lua()}'


class LuaExpression:

    def __init__(self, condition, object_, method, args):
        self.condition = condition
        self.object_ = object_
        self.method = method
        self.args = args

    def parse_lua(self):
        return (f'{self.object_.parse_lua()}:{self.method.parse_lua()}('
                f'{", ".join(arg.parse_lua() for arg in self.args)})')


class Rune(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        getattr(self, condition.condition_list()[1])()

    def time_to_3(self):
        # rune.time_to_3
        self.method = Method('RuneTimeToX')
        self.args = [Literal('3')]


class Talent(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = Spell(condition.condition_list()[1])
        getattr(self, condition.condition_list()[2])()

    def enabled(self):
        # talent.spell.enabled
        self.method = Method('IsAvailable')
        self.args = []


class RunicPower(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        self.args = []
        getattr(self, condition.condition_list()[1])()

    def deficit(self):
        # runic_power.deficit
        self.method = Method('RunicPowerDeficit')


class Buff(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = condition.action.player
        self.args = [Spell(condition.condition_list()[1], BUFF)]
        getattr(self, condition.condition_list()[2])()

    def up(self):
        # buff.spell.up
        self.method = Method('Buff')

    def stack(self):
        # buff.spell.stack
        self.method = Method('BuffStack')


class Cooldown(LuaExpression):

    def __init__(self, condition):
        self.condition = condition
        self.object_ = Spell(condition.condition_list()[1])
        getattr(self, condition.condition_list()[2])()

    def ready(self):
        # cooldown.spell.ready
        self.method = Method('IsReady')
        self.args = []


class Method:

    def __init__(self, name):
        self.name = name

    def parse_lua(self):
        return self.name


class Literal:

    def __init__(self, value):
        self.value = value

    def parse_lua(self):
        return self.value
