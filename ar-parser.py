# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 12:22:12 2017

@author: rmondoncancel
"""

class Player:
    
    def __init__(self):
        pass
    
    def potion(self):
        pass
    
    
class DeathKnight:
    
    def __init__(self):
        pass
    
    def potion(self):
        return Item("ProlongedPower")

class Item:
    
    def __init__(self, name):
        self.name = name

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

ACTION_SPECIAL_REPLACEMENTS = {
    'And': 'and',
    'Blooddrinker': 'BloodDrinker',
}

class Action:
    
    def __init__(self, simc_string, player):
        self.simc = simc_string
        self.player = player
    
    def ar_name(self):
        ar_name = self.simc.replace('_', ' ').title().replace(' ', '')
        # Lowercases 'and' for correct parsing
        for k, v in ACTION_SPECIAL_REPLACEMENTS.items():
            ar_name.replace(k, v)
        return ar_name
    
    def type_(self):
        if self.simc in ITEM_ACTIONS:
            return ActionType('item')
        else:
            return ActionType('spell')

        
class ActionType:
    
    def __init__(self, type_):
        self.type_ = type_


class Spell:

    def __init__(self):
        pass

class Condition:
    
    def __init__(self, simc_string):
        self.simc = simc_string
    
    def condition_list(self):
        return self.simc.split('.')
    
    def cooldown(self):
        pass
        
    
class Cooldown:
    
    def __init__(self, condition):
        self.condition = condition
    
    def ready(self):
        self.object = Spell()
        self.method = Method('IsReady')

class Method:
    
    def __init__(self, name):
        self.name = name