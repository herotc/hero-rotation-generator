# -*- coding: utf-8 -*-
"""
Context of an APL.

@author: skasch
"""

from .database import ITEM_INFO
from .druid import guardian_print_swipe_thrash

class Context:
    """
    Defines the context of an APL, used to print everything outside the Apl
    main function.
    """

    HEADER = (
        '--- ============================ HEADER ============================\n'
        '--- ======= LOCALIZE =======\n'
        '- - Addon\n'
        'local addonName, addonTable=...\n'
        '-- AethysCore\n'
        'local AC =     AethysCore\n'
        'local Cache =  AethysCache\n'
        'local Unit =   AC.Unit\n'
        'local Player = Unit.Player\n'
        'local Target = Unit.Target\n'
        'local Spell =  AC.Spell\n'
        'local Item =   AC.Item\n'
        '-- AethysRotation\n'
        'local AR =     AethysRotation\n')

    CONTENT_HEADER = (
        '--- ============================ CONTENT ===========================\n'
        '--- ======= APL LOCALS =======\n'
        '-- luacheck: max_line_length 9999\n')
    
    NUM_FUNCTION = (
        'local function num(val)\n'
        '  if val then return 1 else return 0 end\n'
        'end\n')
    
    BOOL_FUNCTION = (
        'local function bool(val)\n'
        '  return val ~= 0\n'
        'end\n')

    def __init__(self):
        self.spells = {}
        self.items = {}
        self.variables = {}
        self.custom_code = [self.NUM_FUNCTION, self.BOOL_FUNCTION]
        self.player = None

    @guardian_print_swipe_thrash
    def add_spell(self, spell):
        """
        Add a spell to the context.
        """
        if (spell.simc, spell.type_) not in self.spells:
            self.spells[(spell.simc, spell.type_)] = spell

    def add_item(self, item):
        """
        Add an item to the context.
        """
        if item.simc not in self.items:
            self.items[item.simc] = item

    def add_variable(self, variable):
        """
        Add an variable to the context.
        """
        if variable.simc not in self.variables:
            self.variables[variable.simc] = variable

    def set_player(self, player):
        """
        Set the player for the context.
        """
        self.player = player

    def add_code(self, code):
        """
        Add custom code to the context.
        """
        self.custom_code.append(code)

    def print_spells(self):
        """
        Print the spells object in lua context.
        """
        class_ = self.player.class_.lua_name()
        spec = self.player.spec.lua_name()
        lua_spells = (
            '-- Spells\n'
            f'if not Spell.{class_} then Spell.{class_} = {{}} end\n'
            f'Spell.{class_}.{spec} = {{\n')
        for i, spell in enumerate(self.spells.values()):
            spell_id = str(self.player.spell_property(spell, spell.type_, ''))
            lua_spells += f'  {spell.lua_name():30}= Spell({spell_id})'
            lua_spells += ',\n' if i < len(self.spells)-1 else '\n'
        lua_spells += (
            '};\n'
            f'local S = Spell.{class_}.{spec};\n')
        return lua_spells

    def print_items(self):
        """
        Print the items object in lua context.
        """
        class_ = self.player.class_.lua_name()
        spec = self.player.spec.lua_name()
        lua_items = (
            '-- Items\n'
            f'if not Item.{class_} then Item.{class_} = {{}} end\n'
            f'Item.{class_}.{spec} = {{\n')
        for i, item in enumerate(self.items.values()):
            item_id = str(ITEM_INFO.get(item.simc, ''))
            lua_items += f'  {item.lua_name():30}= Item({item_id})'
            lua_items += ',\n' if i < len(self.items)-1 else '\n'
        lua_items += (
            '};\n'
            f'local I = Item.{class_}.{spec};\n')
        return lua_items

    def print_variables(self):
        """
        Print the variables object in lua context.
        """
        lua_variables = '-- Variables\n'
        for var in self.variables.values():
            lua_variables += f'local {var.lua_name()} = {var.default};\n'
        return lua_variables

    def print_custom_code(self):
        """
        Print the custom code.
        """
        return '\n'.join(self.custom_code)

    def print_settings(self):
        """
        Print additional settings.
        """
        class_ = self.player.class_.lua_name()
        spec = self.player.spec.lua_name()
        return (
            '-- Rotation Var\n'
            'local ShouldReturn; -- Used to get the return string\n'
            '\n'
            '-- GUI Settings\n'
            'local Everyone = AR.Commons.Everyone;\n'
            'local Settings = {\n'
            '  General = AR.GUISettings.General,\n'
            f'  Commons = AR.GUISettings.APL.{class_}.Commons,\n'
            f'  {spec} = AR.GUISettings.APL.{class_}.{spec},\n'
            '};\n')

    def print_lua(self):
        """
        Print the context.
        """
        newline = '\n' if self.custom_code else ''
        return (
            f'{self.HEADER}\n'
            f'{self.CONTENT_HEADER}\n'
            f'{self.print_spells()}\n'
            f'{self.print_items()}\n'
            f'{self.print_settings()}\n'
            f'{self.print_variables()}\n'
            f'{self.print_custom_code()}{newline}')
