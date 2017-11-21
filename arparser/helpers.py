# -*- coding: utf-8 -*-
"""
Define function helpers for arparser.

@author: skasch
"""

from .constants import TYPE_CONVERSION


def indent(string, length=2):
    """
    Indent a string by indent_size spaces at the beginning of each new line.
    """
    indent_string = '\n' + ' ' * length
    return ' ' * length + string.replace('\n', indent_string)

def convert_type(expr, expected_type):
    """
    Print an expression with type conversion.
    """
    template = TYPE_CONVERSION[expr.lua_type()][expected_type]
    return template.format(expr.print_lua())
