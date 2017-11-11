# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 12:22:12 2017

@author: rmondoncancel
"""

ITEM_ACTIONS = [
    'potion',
]

GCD_AS_OFF_GCD = [
    'blood_drinker',
]

OFF_GCD_AS_OFF_GCD = [
    'dancing_rune_weapon',
    'arcane_torrents',
]

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
DEBUFF = 'debuff'

UNARY_OPERATORS = {
    '-': '-',
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
    '>=': '>=',
    # TODO Handle the in/not_in cases
}

COMPARISON_OPERATORS = ['!=', '<=', '>=', '=', '<', '>']
ADDITION_OPERATORS = ['+', '-']
MULTIPLIACTION_OPERATORS = ['*', '%']
FUNCTION_OPERATORS = ['abs', 'floor', 'ceil']

CLASS_SPECS = {
    'deathknight': ['blood', 'frost', 'unholy'],
}


class LuaNamed:
    """
    An abstract class for elements whose named in lua can be parsed from its
    name in simc.
    """

    def __init__(self, simc):
        self.simc = simc

    def lua_name(self):
        """
        Returns the AethysRotation name of the spell.
        """
        ar_name = self.simc.replace('_', ' ').title().replace(' ', '')
        for simc_str, ar_str in SPELL_REPLACEMENTS.items():
            ar_name.replace(simc_str, ar_str)
        return ar_name


class APL:
    """
    The main class representing an Action Priority List (or simc profile),
    extracted from its simc string.
    """

    def __init__(self, player):
        self.player = player


class Player:
    """
    Define a player as the main actor of a simulation.
    """

    def __init__(self, simc):
        self.class_ = PlayerClass(simc)
        self.spec = None

    def potion(self):
        """
        Return the item of the potion used by the player.
        """
        return self.spec.potion()

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        self.spec = PlayerSpec(self.class_, spec)

    def print_lua(self):
        """
        Print the lua expression for the player.
        """
        return 'Player'


class PlayerClass:
    """
    The player class.
    """

    def __init__(self, simc):
        try:
            assert simc in CLASS_SPECS.keys()
        except AssertionError:
            ValueError(f'Invalid class {simc}.')
        self.simc = simc


class PlayerSpec(LuaNamed):
    """
    The player spec.
    """

    def __init__(self, class_, simc):
        try:
            assert simc in CLASS_SPECS[class_.simc]
        except AssertionError:
            ValueError(f'Invalid spec {simc} for class {class_.simc}.')
        self.class_ = class_
        super().__init__(simc)

    def potion(self):
        """
        Return the potion used by a Death Knight.
        """
        if self.class_.simc in ['deathknight']:
            potion = 'prolonged_power'
        return potion


class ActionList:
    """
    An action list; useful when the APL defines multiple named action lists to
    handle specific decision branchings.
    """

    def __init__(self, player):
        self.player = player


class Action:
    """
    A single action in an action list. A action is of the form:
    \\actions.action_list_name+=/execution,if=condition_expression
    """

    def __init__(self, action_list, simc):
        self.action_list = action_list
        self.player = action_list.player
        self.simc = simc

    def split_simc(self):
        """
        Splits the simc action string in execution, condition_expression
        """
        if ',if=' in self.simc:
            if_index = self.simc.find(',if=')
            return self.simc[:if_index], self.simc[if_index+4:]
        return self.simc, ''

    def execution(self):
        """
        Return the execution of the action (the thing to execute if the
        condition is fulfulled)
        """
        execution_string, _ = self.split_simc()
        return Execution(self, execution_string)

    def condition_expression(self):
        """
        Return the condition expression of the action (the thing to test
        before doing the execution)
        """
        _, condition_expression = self.split_simc()
        return ConditionExpression(self, condition_expression)

    # Is this useful?
    def type_(self):
        """
        Return the type of the execution.
        """
        if self.execution().execution in ITEM_ACTIONS:
            return ActionType('item')
        else:
            return ActionType('spell')


class Execution:
    """
    Represent an execution, what to do in a specific situation during the
    simulation.
    """

    def __init__(self, action, execution):
        self.action = action
        self.execution = execution

    def object_(self):
        """
        Return the object of the execution
        """
        if self.execution in ITEM_ACTIONS:
            return Item(self.action, self.execution)
        return Spell(self.action, self.execution)

    def lua_cast_args(self):
        """
        Returns the list of arguments for the execution.
        """
        args = [self.object_().print_lua()]
        if self.execution in GCD_AS_OFF_GCD:
            arg = ('Settings.'
                   f'{self.action.player.spec.lua_name()}.'
                   'GCDasOffGCD.'
                   f'{self.object_().lua_name()}')
            args.append(arg)
        if self.execution in OFF_GCD_AS_OFF_GCD:
            arg = ('Settings.'
                   f'{self.action.player.spec.lua_name()}.'
                   'OffGCDasOffGCD.'
                   f'{self.object_().lua_name()}')
            args.append(arg)
        return args

    def print_lua(self):
        """
        Print the representation of the action
        """
        if self.execution in INTERRUPT_SKILLS:
            cast_action = 'CastAnnotated'
        elif type(self.object_()).__name__ == 'Item':
            cast_action = 'CastSuggested'
        else:
            cast_action = 'Cast'
        return f'AR.{cast_action}({", ".join(self.lua_cast_args())})'


class ActionType:
    """
    Represent the type of an action.
    """

    def __init__(self, type_):
        self.type_ = type_


class BinaryOperator:
    """
    Represent a binary operator in a condition expression.
    """

    def __init__(self, symbol):
        self.symbol = symbol

    def print_lua(self):
        """
        Print the lua expression for the binary operator.
        """
        return BINARY_OPERATORS[self.symbol]


class UnaryOperator:
    """
    Represent a unary operator in a condition expression.
    """

    def __init__(self, symbol):
        self.symbol = symbol

    def print_lua(self):
        """
        Print the lua expression for the binary operator.
        """
        return UNARY_OPERATORS[self.symbol]


class ConditionExpression:
    """
    Represent a condition expression from a string extracted from a simc
    profile.
    """

    def __init__(self, action, simc, exps=None):
        expressions = exps.copy() if exps is not None else []
        self.action = action
        self.parse_parentheses(simc, expressions)

    def parse_parentheses(self, simc, expressions):
        """
        Replaces first-level parentheses by {} and saves the content of
        parentheses in a list of strings.
        """
        n_parentheses = 0
        parsed_simc = ''
        for i, char in enumerate(simc):
            if char == '(':
                n_parentheses += 1
                # save index to extract substring for expressions
                if n_parentheses == 1:
                    start_index = i
            elif char == ')':
                n_parentheses -= 1
                if n_parentheses == 0:
                    end_index = i
                    expressions.append(simc[start_index + 1:end_index])
                    parsed_simc += '{}'
                if n_parentheses < 0:
                    raise ValueError('Invalid condition expression')
            elif n_parentheses == 0:
                # Only write in parsed_simc of not in a sub-expression
                parsed_simc += char
        self.simc = parsed_simc
        self.expressions = expressions

    def grow_binary_tree(self, symbol):
        """
        Grow the condition expression into a binary tree for a binary operator.
        """
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
        """
        Grow the condition expression into a unary tree for a unary operator.
        """
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

    def extract_first_operator(self, symbols, unary=False):
        """
        Extract the first operator in the symbols list. If unary, the symbol
        is a unary operator, otherwise it is a binary operator.
        """
        valid_symbols = [symbol for symbol in symbols if symbol in self.simc]
        if unary:
            symbols_indexes = [
                self.simc.find(symbol) for symbol in valid_symbols]
        else:
            # Ignores first character to force discovery of a binary operator
            # (mostly to handle the case of the - as a unary operator)
            symbols_indexes = [
                self.simc[1:].find(symbol) for symbol in valid_symbols]
        first_symbol_index = symbols_indexes.index(min(symbols_indexes))
        return valid_symbols[first_symbol_index]

    def has_symbol_in(self, symbols):
        """
        Retun true if any symbol in symbols is in the condition expression.
        """
        return any(symbol in self.simc for symbol in symbols)

    def grow(self):
        """
        Use simc precedence: https://github.com/simulationcraft/simc/wiki/ActionLists#complete-list-of-operators
        Grow the condition expression into a tree represention its condition.
        """
        if '|' in self.simc:
            tree = self.grow_binary_tree('|')
        elif '&' in self.simc:
            tree = self.grow_binary_tree('&')
        elif self.has_symbol_in(COMPARISON_OPERATORS):
            symbol = self.extract_first_operator(COMPARISON_OPERATORS)
            tree = self.grow_binary_tree(symbol)
        elif self.has_symbol_in(ADDITION_OPERATORS):
            symbol = self.extract_first_operator(ADDITION_OPERATORS)
            tree = self.grow_binary_tree(symbol)
        elif self.has_symbol_in(MULTIPLIACTION_OPERATORS):
            symbol = self.extract_first_operator(MULTIPLIACTION_OPERATORS)
            tree = self.grow_binary_tree(symbol)
        elif '!' in self.simc:
            tree = self.grow_unary_tree('!')
        elif self.has_symbol_in(FUNCTION_OPERATORS):
            symbol = self.extract_first_operator(FUNCTION_OPERATORS, unary=True)
            tree = self.grow_unary_tree(symbol)
        elif self.simc == '{}':
            try:
                assert len(self.expressions) == 1
            except AssertionError:
                raise ValueError((f'Invalid expressions stack: '
                                  f'{str(self.expressions)}'))
            tree = ConditionParenthesesNode(
                self,
                ConditionExpression(
                    self.action, self.expressions[0]))
        else:
            tree = ConditionLeaf(self, self.simc)
        return tree


class ConditionNode:
    """
    Abstract class to represent a condition node in a tree representing a
    condition expression.
    """

    def __init__(self, condition_expression):
        self.action = condition_expression.action
        self.condition_expression = condition_expression

    def print_lua(self):
        """
        Print the lua code for the tree represention a condition expression.
        """
        pass


class ConditionBinaryNode(ConditionNode):
    """
    Node for a binary operator in a tree representing a condition expresion.
    """

    def __init__(self, condition_expression, operator, left_expression,
                 right_expression):
        super().__init__(condition_expression)
        self.operator = operator
        self.left_tree = left_expression.grow()
        self.right_tree = right_expression.grow()

    def print_lua(self):
        return (f'{self.left_tree.print_lua()} {self.operator.print_lua()} '
                f'{self.right_tree.print_lua()}')


class ConditionUnaryNode(ConditionNode):
    """
    Node for a unary operator in a tree representing a condition expresion.
    """

    def __init__(self, condition_expression, operator, sub_expression):
        super().__init__(condition_expression)
        self.operator = operator
        self.sub_tree = sub_expression.grow()

    def print_lua(self):
        return f'{self.operator.print_lua()} {self.sub_tree.print_lua()}'


class ConditionParenthesesNode(ConditionNode):
    """
    Node for parentheses in a tree representing a condition expresion.
    """

    def __init__(self, condition_expression, sub_expression):
        super().__init__(condition_expression)
        self.sub_tree = sub_expression.grow()

    def print_lua(self):
        return f'({self.sub_tree.print_lua()})'


class ConditionLeaf(ConditionNode):
    """
    Node for a leaf containing a singleton condition in a tree representing a
    condition expresion.
    """

    def __init__(self, condition_expression, condition):
        super().__init__(condition_expression)
        self.condition = Condition(condition_expression, condition)

    def print_lua(self):
        return f'{self.condition.expression().print_lua()}'


class Item(LuaNamed):
    """
    The Item class, used to represent an item.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def print_lua(self):
        """
        Print the lua representation of the item.
        """
        return f'I.{self.lua_name()}'


class Spell(LuaNamed):
    """
    Represents a spell; it can be either a spell, a buff or a debuff.
    """

    def __init__(self, action, simc, type_=SPELL):
        super().__init__(simc)
        self.action = action
        self.type_ = type_

    def print_lua(self):
        """
        Print the lua expression for the spell.
        """
        if self.type_ == SPELL:
            return f'S.{self.lua_name()}'
        elif self.type_ == BUFF:
            return f'S.{self.lua_name()}Buff'


class Condition:
    """
    Represent a singleton condition (i.e. without any operator).
    """

    def __init__(self, condition_expression, simc):
        self.condition_expression = condition_expression
        self.action = condition_expression.action
        self.simc = simc

    def expression(self):
        """
        Return the expression of the condition.
        """
        try:
            return getattr(self, self.condition_list()[0])()
        except AttributeError:
            return Literal(self.simc)

    def condition_list(self):
        """
        Returns the splitted structure of the condition.
        """
        return self.simc.split('.')

    def cooldown(self):
        """
        Returns the condition when the prefix is cooldown.
        """
        return Cooldown(self)

    def buff(self):
        """
        Returns the condition when the prefix is buff.
        """
        return Buff(self)

    def gcd(self):
        """
        Returns the condition when the prefix is gcd.
        """
        return LuaExpression(self, self.action.player, Method('GCD'), [])

    def runic_power(self):
        """
        Returns the condition when the prefix is runic_power.
        """
        return RunicPower(self)

    def talent(self):
        """
        Returns the condition when the prefix is talent.
        """
        return Talent(self)

    def charges_fractional(self):
        """
        Returns the condition when the prefix is charges_fractional.
        """
        return LuaExpression(
            self, Spell(self.action, 'blood_boil'),
            Method('ChargesFractional'), [])

    def rune(self):
        """
        Returns the condition when the prefix is rune.
        """
        return Rune(self)


class LuaExpression:
    """
    Abstract class representing a generic lua expression in the form:
    object:method(args)
    """

    def __init__(self, condition, object_, method, args):
        self.condition = condition
        self.object_ = object_
        self.method = method
        self.args = args

    def print_lua(self):
        """
        Print the lua code for the expression
        """
        return (f'{self.object_.print_lua()}:{self.method.print_lua()}('
                f'{", ".join(arg.print_lua() for arg in self.args)})')


class Rune(LuaExpression):
    """
    Represent the expression for a rune. condition.
    """

    def __init__(self, condition):
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(condition, object_, method, args)

    def time_to_3(self, condition):
        """
        Return the arguments for the expression rune.time_to_3.
        """
        object_ = condition.action.player
        method = Method('RuneTimeToX')
        args = [Literal('3')]
        return object_, method, args


class Talent(LuaExpression):
    """
    Represent the expression for a talent. condition.
    """

    def __init__(self, condition):
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(condition, object_, method, args)

    def enabled(self, condition):
        """
        Return the arguments for the expression talent.spell.enabled.
        """
        object_ = Spell(self.condition.action, condition.condition_list()[1])
        method = Method('IsAvailable')
        args = []
        return object_, method, args


class RunicPower(LuaExpression):
    """
    Represent the expression for a runic_power. condition.
    """

    def __init__(self, condition):
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(condition, object_, method, args)

    def deficit(self, condition):
        """
        Return the arguments for the expression runic_power.deficit.
        """
        object_ = condition.action.player
        method = Method('RunicPowerDeficit')
        args = []
        return object_, method, args


class Buff(LuaExpression):
    """
    Represent the expression for a buff. condition.
    """

    def __init__(self, condition):
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(condition, object_, method, args)

    def up(self, condition):
        """
        Return the arguments for the expression buff.spell.up.
        """
        object_ = condition.action.player
        method = Method('Buff')
        args = [Spell(condition.condition_list()[1], BUFF)]
        return object_, method, args

    def stack(self, condition):
        """
        Return the arguments for the expression buff.spell.stack.
        """
        object_ = condition.action.player
        method = Method('BuffStack')
        args = [Spell(condition.condition_list()[1], BUFF)]
        return object_, method, args


class Cooldown(LuaExpression):
    """
    Represent the expression for a cooldown. condition.
    """

    def __init__(self, condition):
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(condition, object_, method, args)

    def ready(self, condition):
        """
        Return the arguments for the expression cooldown.spell.ready.
        """
        object_ = Spell(self.condition.action, condition.condition_list()[1])
        method = Method('IsReady')
        args = []
        return object_, method, args


class Method:
    """
    Represent a lua method.
    """

    def __init__(self, name):
        self.name = name

    def print_lua(self):
        """
        Print the method.
        """
        return self.name


class Literal:
    """
    Represent a literal expression (a value) as a string.
    """

    def __init__(self, value):
        self.value = value

    def print_lua(self):
        """
        Print the literal value.
        """
        return self.value
