# -*- coding: utf-8 -*-
"""
Define function helpers for arparser.

@author: skasch
"""


def indent(string, length=2):
    """
    Indent a string by indent_size spaces at the beginning of each new line.
    """
    indent_string = '\n' + ' ' * length
    return ' ' * length + string.replace('\n', indent_string)
