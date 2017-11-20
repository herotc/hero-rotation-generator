# -*- coding: utf-8 -*-
"""
Context of an APL.

@author: skasch
"""

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
        'local AC=AethysCore\n'
        'local Cache=AethysCache\n'
        'local Unit=AC.Unit\n'
        'local Player=Unit.Player\n'
        'local Target=Unit.Target\n'
        'local Spell=AC.Spell\n'
        'local Item=AC.Item\n'
        '-- AethysRotation\n'
        'local AR=AethysRotation\n')

    CONTENT_HEADER = (
        '--- ============================ CONTENT ===========================\n'
        '--- ======= APL LOCALS =======\n'
        '-- luacheck: max_line_length 9999\n')

    def __init__(self):
        self.spells = {}
        self.items = {}
        self.variables = {}
        self.custom_code = []
        self.player = None

    def add_spell(self, spell):
        """
        Add a spell to the context.
        """
        if spell.simc not in self.spells:
            self.spells[spell.simc] = spell

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
            f'if not Spell.{class_} then Spell.{class_}={{}} end\n'
            f'Spell.{class_}.{spec}={{\n')
        for spell in self.spells.values():
            lua_spells += f'  {spell.lua_name():30}= Spell(),\n'
        lua_spells += (
            '  -- Misc\n'
            '  PoolEnergy                    = Spell(9999000010),\n'
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
            f'if not Item.{class_} then Item.{class_}={{}} end\n'
            f'Item.{class_}.{spec}={{\n')
        for item in self.items.values():
            lua_items += f'  {item.lua_name():30}= Item(),\n'
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
        lua_code = ''
        for code in self.custom_code:
            lua_code += f'{code}\n'
        return lua_code

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
