# -*- coding: utf-8 -*-
"""
Define decorators to redefine some behaviors in specific contexts.

@author: skasch
"""

from .lua import LuaExpression
from .expressions import Method
from .constants import MELEE_SKILLS


def class_specific_conditions(fun):
    """
    Add class specific conditions.
    """

    def additional_conditions(self):
        """
        Additional conditions to test for the specific action; [] by default if
        none.
        """
        conditions = []
        if (self.action.player.spec.simc == 'havoc'
                and self.simc in MELEE_SKILLS):
            conditions.append(LuaExpression(None, Method('IsInMeleeRange'), []))
        return conditions + fun(self)
    return additional_conditions

def class_specific_context(fun):
    """
    Defines class-specific functions in the context.
    """

    def set_spec(self, spec):
        """
        Sets the spec of the player.
        """
        if spec == 'havoc':
            is_in_melee_range = (
                'local function IsInMeleeRange()\n'
                '  if S.Felblade:TimeSinceLastCast() <= Player:GCD() then\n'
                '    return true\n'
                '  elseif S.VengefulRetreat:TimeSinceLastCast() < 1.0 then\n'
                '    return false\n'
                '  end\n'
                '  return Target:IsInRange("Melee")\n'
                'end')
            self.apl.context.add_code(is_in_melee_range)
        fun(self, spec)
    
    return set_spec
