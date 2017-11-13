# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 12:22:12 2017

@author: rmondoncancel
"""

ITEM_ACTIONS = [
]

GCD_AS_OFF_GCD = [
    'blood_drinker',
]

OFF_GCD_AS_OFF_GCD = [
    'dancing_rune_weapon',
    'arcane_torrent',
]

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
]

CD_SKILLS = [
    'dancing_rune_weapon',
]

SPELL_REPLACEMENTS = {
    'And': 'and',
    'Blooddrinker': 'BloodDrinker',
    'Of': 'of',
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

POTION = 'potion'

RUN_ACTION_LIST = 'run_action_list'


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
        ar_words = [word.title() for word in self.simc.split('_')]
        ar_words = [SPELL_REPLACEMENTS[ar_word]
                    if ar_word in SPELL_REPLACEMENTS else ar_word
                    for ar_word in ar_words]
        return ''.join(ar_words)


class APL:
    """
    The main class representing an Action Priority List (or simc profile),
    extracted from its simc string.
    """

    def __init__(self):
        self.player = None
        self.target = Target()
    
    def set_player(self, simc):
        """
        Set a player as the main actor of the APL.
        """
        self.player = Player(simc)
    
    def set_target(self, simc):
        """
        Set the target of the main actor of the APL.
        """
        self.target = Target(simc)


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


class Target:
    """
    Define a target of the main actor of a simulation.
    """

    def __init__(self, simc=None):
        self.simc = simc if simc is not None else 'patchwerk'

    def print_lua(self):
        """
        Print the lua expression for the target.
        """
        return 'Target'


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

    def __init__(self, apl, simc, name='APL'):
        self.player = apl.player
        self.target = apl.target
        self.simc = simc
        self.name = LuaNamed(name)

    def split_simc(self):
        return self.simc.split('/')

    def actions(self):
        return [Action(self, simc) for simc in self.split_simc()]

    def print_lua(self):
        actions = '\n'.join('  ' + action.print_lua().replace('\n', '\n  ')
                            for action in self.actions())
        function_name = self.name.lua_name()
        return ('local function {}()\n'
                '{}\n'
                'end').format(function_name, actions)


class Action:
    """
    A single action in an action list. A action is of the form:
    \\actions.action_list_name+=/execution,if=condition_expression
    """

    def __init__(self, action_list, simc):
        self.action_list = action_list
        self.player = action_list.player
        self.target = action_list.target
        self.simc = simc

    def split_simc(self):
        return self.simc.split(',')

    def properties(self):
        """
        Split the simc action string in execution, condition_expression.
        """
        props = {}
        for simc_prop in self.split_simc()[1:]:
            equal_index = simc_prop.find('=')
            simc_key = simc_prop[:equal_index]
            simc_val = simc_prop[equal_index+1:]
            props[simc_key] = simc_val
        return props

    def execution(self):
        """
        Return the execution of the action (the thing to execute if the
        condition is fulfulled).
        """
        execution_string = self.split_simc()[0]
        return Execution(self, execution_string)

    def condition_expression(self):
        """
        Return the condition expression of the action (the thing to test
        before doing the execution).
        """
        if 'if' in self.properties():
            condition_expression = self.properties()['if']
        else:
            condition_expression = ''
        return ConditionExpression(self, condition_expression)

    def condition_tree(self):
        """
        Return the condition tree of the action (the tree form of the conditon
        expression).
        """
        return self.condition_expression().grow()

    # Is this useful?
    def type_(self):
        """
        Return the type of the execution.
        """
        if self.execution().execution in ITEM_ACTIONS:
            return ActionType('item')
        else:
            return ActionType('spell')

    def print_lua(self):
        """
        Print the lua code for the action.
        """
        exec_cond = self.execution().print_lua_condition()
        cond_link = ' and ' if exec_cond != '' else ''
        if_cond = self.condition_tree().print_lua()
        exec_cast = self.execution().print_lua_cast()
        return ('if {}{}({}) then\n'
                '  {}\n'
                'end').format(exec_cond, cond_link, if_cond, exec_cast)


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
        if self.execution == POTION:
            return Potion(self.action)
        elif self.execution in ITEM_ACTIONS:
            return Item(self.action, self.execution)
        elif self.execution.startswith(RUN_ACTION_LIST):
            action_list_name = self.action.properties()['name']
            return RunActionList(self.action, action_list_name)
        return Spell(self.action, self.execution)

    def print_lua_condition(self):
        """
        Print the lua code for the condition of the execution.
        """
        conditions = self.object_().conditions()
        return ' and '.join(condition.print_lua() for condition in conditions)

    def print_lua_cast(self):
        """
        Print the representation of the action
        """
        return self.object_().print_cast()


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
        Replace first-level parentheses by {} and saves the content of
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
        right_simc = self.simc[symbol_index + len(symbol):]
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
        elif self.simc == '':
            tree = ConditionLeaf(self, 'true')
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


class LuaCastable:
    """
    The class for castable elements: items and spells.
    """

    def condition_method(self):
        pass
    
    def condition_args(self):
        return []

    def condition(self):
        return LuaExpression(self, self.condition_method(), 
                             self.condition_args())

    def additional_conditions(self):
        return []

    def conditions(self):
        return [self.condition()] + self.additional_conditions()

    def cast_method(self):
        return Method('Cast')

    def cast_args(self):
        return [self]

    def cast(self):
        return LuaExpression(Literal('AR'), 
                             self.cast_method(), self.cast_args())

    def cast_template(self):
        return 'if {} then return ""; end'

    def print_cast(self):
        return self.cast_template().format(self.cast().print_lua())


class Item(LuaNamed, LuaCastable):
    """
    The Item class, used to represent an item.
    """

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def condition_method(self):
        return Method('IsReady')

    def cast_method(self):
        return Method('CastSuggested')

    def print_lua(self):
        """
        Print the lua representation of the item.
        """
        return f'I.{self.lua_name()}'


class Potion(Item):
    """
    The Potion class, to handle the specific case of a potion.
    """

    def __init__(self, action):
        super().__init__(action, action.player.potion())
        self.action = action

    def additional_conditions(self):
        return [Literal('Settings.Commons.UsePotions')]


class RunActionList(LuaNamed, LuaCastable):

    def __init__(self, action, simc):
        super().__init__(simc)
        self.action = action

    def conditions(self):
        return []

    def cast(self):
        return Literal(self.lua_name() + '()')

    def cast_template(self):
        return ('ShouldReturn = {}; '
                'if ShouldReturn then return ShouldReturn; end')


class Spell(LuaNamed, LuaCastable):
    """
    Represents a spell; it can be either a spell, a buff or a debuff.
    """

    def __init__(self, action, simc, type_=SPELL):
        super().__init__(simc)
        self.action = action
        self.type_ = type_
    
    def condition_method(self):
        if self.simc in USABLE_SKILLS:
            return Method('IsUsable')
        return Method('IsCastable')

    def condition_args(self):
        if self.simc in MELEE_SKILLS:
            return [Literal('"melee"')]
        return []

    def additional_conditions(self):
        if self.simc in INTERRUPT_SKILLS:
            return [Literal('Settings.General.InterruptEnabled'),
                    LuaExpression(self.action.target,
                                  Method('IsInterruptible'), [])]
        return []

    def cast_method(self):
        if self.simc in INTERRUPT_SKILLS:
            return Method('CastAnnotated')
        return Method('Cast')

    def cast_args(self):
        args = [self]
        if self.simc in GCD_AS_OFF_GCD:
            args.append(Literal('Settings.'
                                f'{self.action.player.spec.lua_name()}.'
                                'GCDasOffGCD.'
                                f'{self.lua_name()}'))
        if self.simc in OFF_GCD_AS_OFF_GCD:
            args.append(Literal('Settings.'
                                f'{self.action.player.spec.lua_name()}.'
                                'OffGCDasOffGCD.'
                                f'{self.lua_name()}'))
        if self.simc in INTERRUPT_SKILLS:
            args.append(Literal('false'))
            args.append(Literal('"Interrupt"'))
        return args

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
        return LuaExpression(self.action.player, Method('GCD'), [])

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
        return LuaExpression(Spell(self.action, 'blood_boil'),
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

    def __init__(self, object_, method, args):
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
        self.condition = condition
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(object_, method, args)

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
        self.condition = condition
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(object_, method, args)

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
        self.condition = condition
        call = condition.condition_list()[1]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(object_, method, args)

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
        self.condition = condition
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(object_, method, args)

    def up(self, condition):
        """
        Return the arguments for the expression buff.spell.up.
        """
        object_ = condition.action.player
        method = Method('Buff')
        args = [Spell(self.condition.action,
                      condition.condition_list()[1], BUFF)]
        return object_, method, args

    def stack(self, condition):
        """
        Return the arguments for the expression buff.spell.stack.
        """
        object_ = condition.action.player
        method = Method('BuffStack')
        args = [Spell(self.condition.action,
                      condition.condition_list()[1], BUFF)]
        return object_, method, args

    def remains(self, condition):
        """
        Return the arguments for the expression buff.spell.remains.
        """
        object_ = condition.action.player
        method = Method('BuffRemains')
        args = [Spell(self.condition.action, 
                      condition.condition_list()[1], BUFF)]
        return object_, method, args


class Cooldown(LuaExpression):
    """
    Represent the expression for a cooldown. condition.
    """

    def __init__(self, condition):
        self.condition = condition
        call = condition.condition_list()[2]
        object_, method, args = getattr(self, call)(condition)
        super().__init__(object_, method, args)

    def ready(self, condition):
        """
        Return the arguments for the expression cooldown.spell.ready.
        """
        object_ = Spell(self.condition.action, condition.condition_list()[1])
        method = Method('IsReady')
        args = []
        return object_, method, args

    def remains(self, condition):
        """
        Return the arguments for the expression cooldown.spell.remains.
        """
        object_ = Spell(self.condition.action, condition.condition_list()[1])
        method = Method('CooldownRemainsP')
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
