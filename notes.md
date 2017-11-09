# Notes for the development of AethysRotation Parser

## Structure

An action is a combination of an execution (the spell, item or such to execute) and a condition.

## List of conditional expressions to parse

* `cooldown.{spell}.ready`: `S.{Spell}:IsReady()`
* `buff.{spell}.up`: `Player:Buff(S.{SpellBuff})`
* `runic_power.deficit`: `Player:RunicPowerDeficit()`
* `talent.{spell}.enabled`: `S.{Spell}:IsAvailable()`
* `gcd`: `Player:GCD()`
* `buff.{spell}.stack`: `Player:BuffStack(S.{SpellBuff})`
* `charges_fractional`: `S.BloodBoil:ChargesFractional()`
* `rune.time_to_3`: `Player:RuneTimeToX(3)`

## Context

* Use a Context class to manage elements outside the APL function, notably the spell/item objects. This will make specific parsing modifiers futile, but will require to retrieve the IDs of spells/items one way or another.
