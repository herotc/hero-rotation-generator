--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Paladin then Spell.Paladin = {} end
Spell.Paladin.Retribution = {
  AvengingWrathBuff                     = Spell(31884),
  CrusadeBuff                           = Spell(224668),
  LightsJudgment                        = Spell(255647),
  ShieldofVengeance                     = Spell(184662),
  AvengingWrath                         = Spell(31884),
  InquisitionBuff                       = Spell(),
  Inquisition                           = Spell(),
  Crusade                               = Spell(224668),
  DivineJudgment                        = Spell(),
  DivineRightBuff                       = Spell(),
  ExecutionSentence                     = Spell(213757),
  DivineStorm                           = Spell(53385),
  DivinePurposeBuff                     = Spell(223819),
  TemplarsVerdict                       = Spell(85256),
  HammerofWrath                         = Spell(),
  WakeofAshes                           = Spell(205273),
  BladeofJustice                        = Spell(184575),
  Judgment                              = Spell(20271),
  Consecration                          = Spell(26573),
  CrusaderStrike                        = Spell(35395),
  ArcaneTorrent                         = Spell(50613),
  ExecutionSentenceDebuff               = Spell(213757),
  Sequence                              = Spell(),
  Rebuke                                = Spell(96231)
};
local S = Spell.Paladin.Retribution;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Retribution = {
  OldWar                           = Item(127844)
};
local I = Item.Paladin.Retribution;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Paladin.Commons,
  Retribution = HR.GUISettings.APL.Paladin.Retribution
};

-- Variables
local VarDsCastable = 0;
local VarHow = 0;

local EnemyRanges = {5, 8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  UpdateRanges()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.OldWar) then return ""; end
    end
  end
  local function Cooldowns()
    -- potion,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25|target.time_to_die<=40)
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and ((Player:HasHeroism() or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffRemainsP(S.CrusadeBuff) < 25 or Target:TimeToDie() <= 40)) then
      if HR.CastSuggested(I.OldWar) then return ""; end
    end
    -- lights_judgment,if=spell_targets.lights_judgment>=2|(!raid_event.adds.exists|raid_event.adds.in>75)
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Cache.EnemiesCount[5] >= 2 or (not false or 10000000000 > 75)) then
      if HR.Cast(S.LightsJudgment) then return ""; end
    end
    -- shield_of_vengeance
    if S.ShieldofVengeance:IsCastableP() and (true) then
      if HR.Cast(S.ShieldofVengeance) then return ""; end
    end
    -- avenging_wrath,if=buff.inquisition.up|!talent.inquisition.enabled
    if S.AvengingWrath:IsCastableP() and (Player:BuffP(S.InquisitionBuff) or not S.Inquisition:IsAvailable()) then
      if HR.Cast(S.AvengingWrath) then return ""; end
    end
    -- crusade,if=holy_power>=4
    if S.Crusade:IsCastableP() and (Player:HolyPower() >= 4) then
      if HR.Cast(S.Crusade) then return ""; end
    end
  end
  local function Finishers()
    -- variable,name=ds_castable,value=spell_targets.divine_storm>=3|talent.divine_judgment.enabled&spell_targets.divine_storm>=2|azerite.divine_right.enabled&target.health.pct<=20&buff.divine_right.down
    if (true) then
      VarDsCastable = num(Cache.EnemiesCount[8] >= 3 or S.DivineJudgment:IsAvailable() and Cache.EnemiesCount[8] >= 2 or bool(azerite.divine_right.enabled) and Target:HealthPercentage() <= 20 and Player:BuffDownP(S.DivineRightBuff))
    end
    -- inquisition,if=buff.inquisition.down|buff.inquisition.remains<5&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3
    if S.Inquisition:IsCastableP() and (Player:BuffDownP(S.InquisitionBuff) or Player:BuffRemainsP(S.InquisitionBuff) < 5 and Player:HolyPower() >= 3 or S.ExecutionSentence:IsAvailable() and S.ExecutionSentence:CooldownRemainsP() < 10 and Player:BuffRemainsP(S.InquisitionBuff) < 15 or S.AvengingWrath:CooldownRemainsP() < 15 and Player:BuffRemainsP(S.InquisitionBuff) < 20 and Player:HolyPower() >= 3) then
      if HR.Cast(S.Inquisition) then return ""; end
    end
    -- execution_sentence,if=spell_targets.divine_storm<=3&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
    if S.ExecutionSentence:IsCastableP() and (Cache.EnemiesCount[8] <= 3 and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2)) then
      if HR.Cast(S.ExecutionSentence) then return ""; end
    end
    -- divine_storm,if=variable.ds_castable&buff.divine_purpose.react
    if S.DivineStorm:IsCastableP() and (bool(VarDsCastable) and bool(Player:BuffStackP(S.DivinePurposeBuff))) then
      if HR.Cast(S.DivineStorm) then return ""; end
    end
    -- divine_storm,if=variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
    if S.DivineStorm:IsCastableP() and (bool(VarDsCastable) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2)) then
      if HR.Cast(S.DivineStorm) then return ""; end
    end
    -- templars_verdict,if=buff.divine_purpose.react&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
    if S.TemplarsVerdict:IsCastableP() and (bool(Player:BuffStackP(S.DivinePurposeBuff)) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemainsP() > Player:GCD())) then
      if HR.Cast(S.TemplarsVerdict) then return ""; end
    end
    -- templars_verdict,if=(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|buff.crusade.up&buff.crusade.stack<10|cooldown.execution_sentence.remains>gcd*2)
    if S.TemplarsVerdict:IsCastableP() and ((not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2) and (not S.ExecutionSentence:IsAvailable() or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) < 10 or S.ExecutionSentence:CooldownRemainsP() > Player:GCD() * 2)) then
      if HR.Cast(S.TemplarsVerdict) then return ""; end
    end
  end
  local function Generators()
    -- variable,name=HoW,value=(!talent.hammer_of_wrath.enabled|target.health.pct>=20&(buff.avenging_wrath.down|buff.crusade.down))
    if (true) then
      VarHow = num((not S.HammerofWrath:IsAvailable() or Target:HealthPercentage() >= 20 and (Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff))))
    end
    -- call_action_list,name=finishers,if=holy_power>=5
    if (Player:HolyPower() >= 5) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- wake_of_ashes,if=(!raid_event.adds.exists|raid_event.adds.in>20)&(holy_power<=0|holy_power=1&cooldown.blade_of_justice.remains>gcd)
    if S.WakeofAshes:IsCastableP() and ((not false or 10000000000 > 20) and (Player:HolyPower() <= 0 or Player:HolyPower() == 1 and S.BladeofJustice:CooldownRemainsP() > Player:GCD())) then
      if HR.Cast(S.WakeofAshes) then return ""; end
    end
    -- blade_of_justice,if=holy_power<=2|(holy_power=3&(cooldown.hammer_of_wrath.remains>gcd*2|variable.HoW))
    if S.BladeofJustice:IsCastableP() and (Player:HolyPower() <= 2 or (Player:HolyPower() == 3 and (S.HammerofWrath:CooldownRemainsP() > Player:GCD() * 2 or bool(VarHow)))) then
      if HR.Cast(S.BladeofJustice) then return ""; end
    end
    -- judgment,if=holy_power<=2|(holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|variable.HoW))
    if S.Judgment:IsCastableP() and (Player:HolyPower() <= 2 or (Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 or bool(VarHow)))) then
      if HR.Cast(S.Judgment) then return ""; end
    end
    -- hammer_of_wrath,if=holy_power<=4
    if S.HammerofWrath:IsCastableP() and (Player:HolyPower() <= 4) then
      if HR.Cast(S.HammerofWrath) then return ""; end
    end
    -- consecration,if=holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2
    if S.Consecration:IsCastableP() and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 and S.Judgment:CooldownRemainsP() > Player:GCD() * 2) then
      if HR.Cast(S.Consecration) then return ""; end
    end
    -- call_action_list,name=finishers,if=talent.hammer_of_wrath.enabled&(target.health.pct<=20|buff.avenging_wrath.up|buff.crusade.up)&(buff.divine_purpose.up|buff.crusade.stack<10)
    if (S.HammerofWrath:IsAvailable() and (Target:HealthPercentage() <= 20 or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff)) and (Player:BuffP(S.DivinePurposeBuff) or Player:BuffStackP(S.CrusadeBuff) < 10)) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.75&(holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2&cooldown.consecration.remains>gcd*2)
    if S.CrusaderStrike:IsCastableP() and (S.CrusaderStrike:ChargesFractional() >= 1.75 and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 and S.Judgment:CooldownRemainsP() > Player:GCD() * 2 and S.Consecration:CooldownRemainsP() > Player:GCD() * 2)) then
      if HR.Cast(S.CrusaderStrike) then return ""; end
    end
    -- call_action_list,name=finishers
    if (true) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- crusader_strike,if=holy_power<=4
    if S.CrusaderStrike:IsCastableP() and (Player:HolyPower() <= 4) then
      if HR.Cast(S.CrusaderStrike) then return ""; end
    end
    -- arcane_torrent,if=(debuff.execution_sentence.up|(talent.hammer_of_wrath.enabled&(target.health.pct>=20|buff.avenging_wrath.down|buff.crusade.down))|!talent.execution_sentence.enabled|!talent.hammer_of_wrath.enabled)&holy_power<=4
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and ((Target:DebuffP(S.ExecutionSentenceDebuff) or (S.HammerofWrath:IsAvailable() and (Target:HealthPercentage() >= 20 or Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff))) or not S.ExecutionSentence:IsAvailable() or not S.HammerofWrath:IsAvailable()) and Player:HolyPower() <= 4) then
      if HR.Cast(S.ArcaneTorrent, Settings.Retribution.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  local function Opener()
    -- sequence,if=talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled,name=wake_opener_ES_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:execution_sentence
    if S.Sequence:IsCastableP() and (S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and S.ExecutionSentence:IsAvailable() and not S.HammerofWrath:IsAvailable()) then
      if HR.Cast(S.Sequence) then return ""; end
    end
    -- sequence,if=talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled,name=wake_opener_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:templars_verdict
    if S.Sequence:IsCastableP() and (S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and not S.ExecutionSentence:IsAvailable() and not S.HammerofWrath:IsAvailable()) then
      if HR.Cast(S.Sequence) then return ""; end
    end
    -- sequence,if=talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled,name=wake_opener_ES_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:execution_sentence
    if S.Sequence:IsCastableP() and (S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and S.ExecutionSentence:IsAvailable() and S.HammerofWrath:IsAvailable()) then
      if HR.Cast(S.Sequence) then return ""; end
    end
    -- sequence,if=talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled,name=wake_opener_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:templars_verdict
    if S.Sequence:IsCastableP() and (S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and not S.ExecutionSentence:IsAvailable() and S.HammerofWrath:IsAvailable()) then
      if HR.Cast(S.Sequence) then return ""; end
    end
    -- sequence,if=talent.wake_of_ashes.enabled&talent.inquisition.enabled,name=wake_opener_Inq:shield_of_vengeance:blade_of_justice:judgment:inquisition:avenging_wrath:wake_of_ashes
    if S.Sequence:IsCastableP() and (S.WakeofAshes:IsAvailable() and S.Inquisition:IsAvailable()) then
      if HR.Cast(S.Sequence) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- rebuke
  if S.Rebuke:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if HR.CastAnnotated(S.Rebuke, false, "Interrupt") then return ""; end
  end
  -- call_action_list,name=opener
  if (true) then
    local ShouldReturn = Opener(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=generators
  if (true) then
    local ShouldReturn = Generators(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(70, APL)
