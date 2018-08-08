# -*- coding: utf-8 -*-
"""
Define the objects representing simc conditions.

@author: skasch
"""

from ..objects.expressions import Expression
from ..abstract.helpers import convert_type
from ..objects.lua import Literal
from ..constants import (BOOL, NUM,
                         BINARY_OPERATORS, UNARY_OPERATORS,
                         LOGIC_OPERATORS, COMPARISON_OPERATORS,
                         ADDITION_OPERATORS, MULTIPLIACTION_OPERATORS,
                         FUNCTION_OPERATORS)


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

    def expected_type(self):
        """
        Return the expected type of both sides of the operator.
        """
        if self.symbol in LOGIC_OPERATORS:
            return BOOL, BOOL
        else:
            return NUM, NUM

    def lua_type(self):
        """
        Return the returned type of the operator.
        """
        if self.symbol in LOGIC_OPERATORS + COMPARISON_OPERATORS:
            return BOOL
        else:
            return NUM


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

    def expected_type(self):
        """
        Return the expected type of both sides of the operator
        """
        if self.symbol in LOGIC_OPERATORS:
            return BOOL
        else:
            return NUM

    def lua_type(self):
        """
        Return the returned type of the operator.
        """
        if self.symbol in LOGIC_OPERATORS + COMPARISON_OPERATORS:
            return BOOL
        else:
            return NUM


class ConditionExpression:
    """
    Represent a condition expression from a string extracted from a simc
    profile.
    """

    def __init__(self, action, simc, exps=None, null_cond='true'):
        expressions = exps.copy() if exps is not None else []
        self.action = action
        self.null_cond = null_cond
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

    def has_symbol_in(self, symbols, unary=False):
        """
        Retun true if any symbol in symbols is in the condition expression.
        """
        if unary:
            return any(self.simc.startswith(symbol) for symbol in symbols)
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
        elif self.has_symbol_in(FUNCTION_OPERATORS, unary=True):
            symbol = self.extract_first_operator(
                FUNCTION_OPERATORS, unary=True)
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
            tree = ConditionLeaf(self, self.null_cond)
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

    def lua_type(self):
        """
        Print the type for the tree representation fo a condition expression.
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
        left_exp = convert_type(self.left_tree,
                                self.operator.expected_type()[0])
        right_exp = convert_type(self.right_tree,
                                 self.operator.expected_type()[1])
        return f'{left_exp} {self.operator.print_lua()} {right_exp}'

    def lua_type(self):
        return self.operator.lua_type()


class ConditionUnaryNode(ConditionNode):
    """
    Node for a unary operator in a tree representing a condition expresion.
    """

    def __init__(self, condition_expression, operator, sub_expression):
        super().__init__(condition_expression)
        self.operator = operator
        self.sub_tree = sub_expression.grow()

    def print_lua(self):
        sub_exp = convert_type(self.sub_tree, self.operator.expected_type())
        return f'{self.operator.print_lua()} {sub_exp}'

    def lua_type(self):
        return self.operator.lua_type()


class ConditionParenthesesNode(ConditionNode):
    """
    Node for parentheses in a tree representing a condition expresion.
    """

    def __init__(self, condition_expression, sub_expression):
        super().__init__(condition_expression)
        self.sub_tree = sub_expression.grow()

    def print_lua(self):
        return f'({self.sub_tree.print_lua()})'

    def lua_type(self):
        return self.sub_tree.lua_type()


class ConditionLeaf(ConditionNode):
    """
    Node for a leaf containing a singleton condition in a tree representing a
    condition expresion.
    """

    def __init__(self, condition_expression, condition):
        super().__init__(condition_expression)
        self.condition = Expression(condition_expression, condition)

    def print_lua(self):
        return f'{self.condition.expression().print_lua()}'

    def lua_type(self):
        return self.condition.expression().lua_type()
