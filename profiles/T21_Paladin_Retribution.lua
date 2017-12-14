--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- AethysCore
local AC     = AethysCore
local Cache  = AethysCache
local Unit   = AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = AC.Spell
local Item   = AC.Item
-- AethysRotation
local AR     = AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Paladin then Spell.Paladin = {} end
Spell.Paladin.Retribution = {
  AvengingWrathBuff                     = Spell(31884),
  CrusadeBuff                           = Spell(224668),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  BladeofJustice                        = Spell(184575),
  DivineHammer                          = Spell(198034),
  HolyWrath                             = Spell(210220),
  ShieldofVengeance                     = Spell(184662),
  AvengingWrath                         = Spell(31884),
  Crusade                               = Spell(224668),
  ExecutionSentence                     = Spell(213757),
  Judgment                              = Spell(20271),
  JudgmentDebuff                        = Spell(231663),
  DivineStorm                           = Spell(53385),
  DivinePurposeBuff                     = Spell(223819),
  JusticarsVengeance                    = Spell(215661),
  TemplarsVerdict                       = Spell(85256),
  ScarletInquisitorsExpurgationBuff     = Spell(248103),
  WakeofAshesDebuff                     = Spell(205273),
  LiadrinsFuryUnleashedBuff             = Spell(208408),
  AshesToAshes                          = Spell(),
  WakeofAshes                           = Spell(205273),
  WhisperoftheNathrezimBuff             = Spell(207633),
  ExecutionSentenceDebuff               = Spell(213757),
  Zeal                                  = Spell(217020),
  CrusaderStrike                        = Spell(35395),
  GreaterJudgment                       = Spell(218178),
  TheFiresofJustice                     = Spell(203316),
  Consecration                          = Spell(26573),
  HammerofJustice                       = Spell(853),
  Rebuke                                = Spell(96231)
};
local S = Spell.Paladin.Retribution;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Retribution = {
  OldWar                           = Item(127844),
  Item137048                       = Item(137048),
  Item137020                       = Item(137020),
  Item144358                       = Item(144358),
  Item137065                       = Item(137065)
};
local I = Item.Paladin.Retribution;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Paladin.Commons,
  Retribution = AR.GUISettings.APL.Paladin.Retribution
};

-- Variables
local VarDsCastable = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Precombat()
    -- flask,type=flask_of_the_countless_armies
    -- food,type=azshari_salad
    -- augmentation,type=defiled
    -- snapshot_stats
    -- potion,name=old_war
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.OldWar) then return ""; end
    end
  end
  local function Cooldowns()
    -- potion,name=old_war,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25|target.time_to_die<=40)
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and ((Player:HasHeroism() or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffRemainsP(S.CrusadeBuff) < 25 or Target:TimeToDie() <= 40)) then
      if AR.CastSuggested(I.OldWar) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Retribution.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Retribution.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=(buff.crusade.up|buff.avenging_wrath.up)&holy_power=2&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and ((Player:BuffP(S.CrusadeBuff) or Player:BuffP(S.AvengingWrathBuff)) and Player:HolyPower() == 2 and (S.BladeofJustice:CooldownRemainsP() > Player:GCD() or S.DivineHammer:CooldownRemainsP() > Player:GCD())) then
      if AR.Cast(S.ArcaneTorrent, Settings.Retribution.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- holy_wrath
    if S.HolyWrath:IsCastableP() and (true) then
      if AR.Cast(S.HolyWrath) then return ""; end
    end
    -- shield_of_vengeance
    if S.ShieldofVengeance:IsCastableP() and (true) then
      if AR.Cast(S.ShieldofVengeance) then return ""; end
    end
    -- avenging_wrath
    if S.AvengingWrath:IsCastableP() and (true) then
      if AR.Cast(S.AvengingWrath) then return ""; end
    end
    -- crusade,if=holy_power>=3|((equipped.137048|race.blood_elf)&holy_power>=2)
    if S.Crusade:IsCastableP() and (Player:HolyPower() >= 3 or ((I.Item137048:IsEquipped() or Player:IsRace("BloodElf")) and Player:HolyPower() >= 2)) then
      if AR.Cast(S.Crusade) then return ""; end
    end
  end
  local function Finishers()
    -- execution_sentence,if=spell_targets.divine_storm<=3&(cooldown.judgment.remains<gcd*4.25|debuff.judgment.remains>gcd*4.25)
    if S.ExecutionSentence:IsCastableP() and (Cache.EnemiesCount[8] <= 3 and (S.Judgment:CooldownRemainsP() < Player:GCD() * 4.25 or Target:DebuffRemainsP(S.JudgmentDebuff) > Player:GCD() * 4.25)) then
      if AR.Cast(S.ExecutionSentence) then return ""; end
    end
    -- divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.divine_purpose.react
    if S.DivineStorm:IsCastableP() and (Target:DebuffP(S.JudgmentDebuff) and bool(VarDsCastable) and bool(Player:BuffStackP(S.DivinePurposeBuff))) then
      if AR.Cast(S.DivineStorm) then return ""; end
    end
    -- divine_storm,if=debuff.judgment.up&variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
    if S.DivineStorm:IsCastableP() and (Target:DebuffP(S.JudgmentDebuff) and bool(VarDsCastable) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2)) then
      if AR.Cast(S.DivineStorm) then return ""; end
    end
    -- justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.react&!equipped.137020
    if S.JusticarsVengeance:IsCastableP() and (Target:DebuffP(S.JudgmentDebuff) and bool(Player:BuffStackP(S.DivinePurposeBuff)) and not I.Item137020:IsEquipped()) then
      if AR.Cast(S.JusticarsVengeance) then return ""; end
    end
    -- templars_verdict,if=debuff.judgment.up&buff.divine_purpose.react
    if S.TemplarsVerdict:IsCastableP() and (Target:DebuffP(S.JudgmentDebuff) and bool(Player:BuffStackP(S.DivinePurposeBuff))) then
      if AR.Cast(S.TemplarsVerdict) then return ""; end
    end
    -- templars_verdict,if=debuff.judgment.up&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
    if S.TemplarsVerdict:IsCastableP() and (Target:DebuffP(S.JudgmentDebuff) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemainsP() > Player:GCD())) then
      if AR.Cast(S.TemplarsVerdict) then return ""; end
    end
  end
  local function Generators()
    -- variable,name=ds_castable,value=spell_targets.divine_storm>=2|(buff.scarlet_inquisitors_expurgation.stack>=29&(equipped.144358&(dot.wake_of_ashes.ticking&time>10|dot.wake_of_ashes.remains<gcd))|(buff.scarlet_inquisitors_expurgation.stack>=29&(buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack>=15|cooldown.crusade.remains>15&!buff.crusade.up)|cooldown.avenging_wrath.remains>15)&!equipped.144358)
    if (true) then
      VarDsCastable = num(Cache.EnemiesCount[8] >= 2 or (Player:BuffStackP(S.ScarletInquisitorsExpurgationBuff) >= 29 and (I.Item144358:IsEquipped() and (Target:DebuffP(S.WakeofAshesDebuff) and AC.CombatTime() > 10 or Target:DebuffRemainsP(S.WakeofAshesDebuff) < Player:GCD())) or (Player:BuffStackP(S.ScarletInquisitorsExpurgationBuff) >= 29 and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) >= 15 or S.Crusade:CooldownRemainsP() > 15 and not Player:BuffP(S.CrusadeBuff)) or S.AvengingWrath:CooldownRemainsP() > 15) and not I.Item144358:IsEquipped()))
    end
    -- call_action_list,name=finishers,if=(buff.crusade.up&buff.crusade.stack<15|buff.liadrins_fury_unleashed.up)|(artifact.ashes_to_ashes.enabled&cooldown.wake_of_ashes.remains<gcd*2)
    if ((Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) < 15 or Player:BuffP(S.LiadrinsFuryUnleashedBuff)) or (S.AshesToAshes:ArtifactEnabled() and S.WakeofAshes:CooldownRemainsP() < Player:GCD() * 2)) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=finishers,if=talent.execution_sentence.enabled&(cooldown.judgment.remains<gcd*4.25|debuff.judgment.remains>gcd*4.25)&cooldown.execution_sentence.up|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd*1.5
    if (S.ExecutionSentence:IsAvailable() and (S.Judgment:CooldownRemainsP() < Player:GCD() * 4.25 or Target:DebuffRemainsP(S.JudgmentDebuff) > Player:GCD() * 4.25) and S.ExecutionSentence:CooldownUpP() or Player:BuffP(S.WhisperoftheNathrezimBuff) and Player:BuffRemainsP(S.WhisperoftheNathrezimBuff) < Player:GCD() * 1.5) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- judgment,if=dot.execution_sentence.ticking&dot.execution_sentence.remains<gcd*2&debuff.judgment.remains<gcd*2|set_bonus.tier21_4pc
    if S.Judgment:IsCastableP() and (Target:DebuffP(S.ExecutionSentenceDebuff) and Target:DebuffRemainsP(S.ExecutionSentenceDebuff) < Player:GCD() * 2 and Target:DebuffRemainsP(S.JudgmentDebuff) < Player:GCD() * 2 or AC.Tier21_4Pc) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- blade_of_justice,if=holy_power<=2&(set_bonus.tier20_2pc|set_bonus.tier20_4pc)
    if S.BladeofJustice:IsCastableP() and (Player:HolyPower() <= 2 and (AC.Tier20_2Pc or AC.Tier20_4Pc)) then
      if AR.Cast(S.BladeofJustice) then return ""; end
    end
    -- divine_hammer,if=holy_power<=2&(set_bonus.tier20_2pc|set_bonus.tier20_4pc)
    if S.DivineHammer:IsCastableP() and (Player:HolyPower() <= 2 and (AC.Tier20_2Pc or AC.Tier20_4Pc)) then
      if AR.Cast(S.DivineHammer) then return ""; end
    end
    -- wake_of_ashes,if=(!raid_event.adds.exists|raid_event.adds.in>15)&(holy_power<=0|holy_power=1&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)|holy_power=2&((cooldown.zeal.charges_fractional<=0.65|cooldown.crusader_strike.charges_fractional<=0.65)))
    if S.WakeofAshes:IsCastableP() and ((not bool(raid_event.adds.exists) or raid_event.adds.in > 15) and (Player:HolyPower() <= 0 or Player:HolyPower() == 1 and (S.BladeofJustice:CooldownRemainsP() > Player:GCD() or S.DivineHammer:CooldownRemainsP() > Player:GCD()) or Player:HolyPower() == 2 and ((S.Zeal:ChargesFractional() <= 0.65 or S.CrusaderStrike:ChargesFractional() <= 0.65)))) then
      if AR.Cast(S.WakeofAshes) then return ""; end
    end
    -- blade_of_justice,if=holy_power<=3&!set_bonus.tier20_4pc
    if S.BladeofJustice:IsCastableP() and (Player:HolyPower() <= 3 and not AC.Tier20_4Pc) then
      if AR.Cast(S.BladeofJustice) then return ""; end
    end
    -- divine_hammer,if=holy_power<=3&!set_bonus.tier20_4pc
    if S.DivineHammer:IsCastableP() and (Player:HolyPower() <= 3 and not AC.Tier20_4Pc) then
      if AR.Cast(S.DivineHammer) then return ""; end
    end
    -- judgment
    if S.Judgment:IsCastableP() and (true) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- call_action_list,name=finishers,if=buff.divine_purpose.up
    if (Player:BuffP(S.DivinePurposeBuff)) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- zeal,if=cooldown.zeal.charges_fractional>=1.65&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd
    if S.Zeal:IsCastableP() and (S.Zeal:ChargesFractional() >= 1.65 and Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 or S.DivineHammer:CooldownRemainsP() > Player:GCD() * 2) and Target:DebuffRemainsP(S.JudgmentDebuff) > Player:GCD()) then
      if AR.Cast(S.Zeal) then return ""; end
    end
    -- crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.65&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd&(talent.greater_judgment.enabled|!set_bonus.tier20_4pc&talent.the_fires_of_justice.enabled)
    if S.CrusaderStrike:IsCastableP() and (S.CrusaderStrike:ChargesFractional() >= 1.65 and Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemainsP() > Player:GCD() * 2 or S.DivineHammer:CooldownRemainsP() > Player:GCD() * 2) and Target:DebuffRemainsP(S.JudgmentDebuff) > Player:GCD() and (S.GreaterJudgment:IsAvailable() or not AC.Tier20_4Pc and S.TheFiresofJustice:IsAvailable())) then
      if AR.Cast(S.CrusaderStrike) then return ""; end
    end
    -- consecration
    if S.Consecration:IsCastableP() and (true) then
      if AR.Cast(S.Consecration) then return ""; end
    end
    -- hammer_of_justice,if=equipped.137065&target.health.pct>=75&holy_power<=4
    if S.HammerofJustice:IsCastableP() and (I.Item137065:IsEquipped() and Target:HealthPercentage() >= 75 and Player:HolyPower() <= 4) then
      if AR.Cast(S.HammerofJustice) then return ""; end
    end
    -- call_action_list,name=finishers
    if (true) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- zeal
    if S.Zeal:IsCastableP() and (true) then
      if AR.Cast(S.Zeal) then return ""; end
    end
    -- crusader_strike
    if S.CrusaderStrike:IsCastableP() and (true) then
      if AR.Cast(S.CrusaderStrike) then return ""; end
    end
  end
  local function Opener()
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Retribution.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Retribution.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=!set_bonus.tier20_2pc
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (not AC.Tier20_2Pc) then
      if AR.Cast(S.ArcaneTorrent, Settings.Retribution.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- judgment
    if S.Judgment:IsCastableP() and (true) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- blade_of_justice,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if S.BladeofJustice:IsCastableP() and (I.Item137048:IsEquipped() or Player:IsRace("BloodElf") or not S.WakeofAshes:CooldownUpP()) then
      if AR.Cast(S.BladeofJustice) then return ""; end
    end
    -- divine_hammer,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if S.DivineHammer:IsCastableP() and (I.Item137048:IsEquipped() or Player:IsRace("BloodElf") or not S.WakeofAshes:CooldownUpP()) then
      if AR.Cast(S.DivineHammer) then return ""; end
    end
    -- wake_of_ashes
    if S.WakeofAshes:IsCastableP() and (true) then
      if AR.Cast(S.WakeofAshes) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- rebuke
  if S.Rebuke:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR.CastAnnotated(S.Rebuke, false, "Interrupt") then return ""; end
  end
  -- call_action_list,name=opener,if=time<2
  if (AC.CombatTime() < 2) then
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