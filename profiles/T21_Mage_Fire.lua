--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC =     AethysCore
local Cache =  AethysCache
local Unit =   AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet =    Unit.Pet
local Spell =  AC.Spell
local Item =   AC.Item
-- AethysRotation
local AR =     AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Mage then Spell.Mage = {} end
Spell.Mage.Fire = {
  BlastWave                             = Spell(157981),
  CombustionBuff                        = Spell(190319),
  FireBlast                             = Spell(108853),
  PhoenixsFlames                        = Spell(194466),
  Meteor                                = Spell(153561),
  Combustion                            = Spell(190319),
  RuneofPowerBuff                       = Spell(116014),
  Cinderstorm                           = Spell(198929),
  RuneofPower                           = Spell(116011),
  DragonsBreath                         = Spell(31661),
  AlexstraszasFury                      = Spell(235870),
  HotStreakBuff                         = Spell(48108),
  LivingBomb                            = Spell(44457),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  UseItems                              = Spell(),
  Flamestrike                           = Spell(2120),
  FlamePatch                            = Spell(205037),
  Pyroblast                             = Spell(11366),
  KaelthasUltimateAbilityBuff           = Spell(209455),
  HeatingUpBuff                         = Spell(48107),
  Scorch                                = Spell(2948),
  BloodBoil                             = Spell(),
  Fireball                              = Spell(133),
  Kindling                              = Spell(155148),
  IncantersFlowBuff                     = Spell(1463),
  MirrorImage                           = Spell(55342),
  Counterspell                          = Spell(2139),
  TimeWarp                              = Spell(80353),
  EruptingInfernalCoreBuff              = Spell(248147),
  Firestarter                           = Spell(205026)
};
local S = Spell.Mage.Fire;

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Fire = {
  ProlongedPower                = Item(142117)
};
local I = Item.Mage.Fire;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Mage.Commons,
  Fire = AR.GUISettings.APL.Mage.Fire
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function ActiveTalents()
    -- blast_wave,if=(buff.combustion.down)|(buff.combustion.up&action.fire_blast.charges<1&action.phoenixs_flames.charges<1)
    if S.BlastWave:IsCastableP() and ((Player:BuffDownP(S.CombustionBuff)) or (Player:BuffP(S.CombustionBuff) and S.FireBlast:ChargesP() < 1 and S.PhoenixsFlames:ChargesP() < 1)) then
      if AR.Cast(S.BlastWave) then return ""; end
    end
    -- meteor,if=cooldown.combustion.remains>40|(cooldown.combustion.remains>target.time_to_die)|buff.rune_of_power.up|firestarter.active
    if S.Meteor:IsCastableP() and (S.Combustion:CooldownRemainsP() > 40 or (S.Combustion:CooldownRemainsP() > Target:TimeToDie()) or Player:BuffP(S.RuneofPowerBuff) or bool(firestarter.active)) then
      if AR.Cast(S.Meteor) then return ""; end
    end
    -- cinderstorm,if=cooldown.combustion.remains<cast_time&(buff.rune_of_power.up|!talent.rune_of_power.enabled)|cooldown.combustion.remains>10*spell_haste&!buff.combustion.up
    if S.Cinderstorm:IsCastableP() and (S.Combustion:CooldownRemainsP() < S.Cinderstorm:CastTime() and (Player:BuffP(S.RuneofPowerBuff) or not S.RuneofPower:IsAvailable()) or S.Combustion:CooldownRemainsP() > 10 * Player:SpellHaste() and not Player:BuffP(S.CombustionBuff)) then
      if AR.Cast(S.Cinderstorm) then return ""; end
    end
    -- dragons_breath,if=equipped.132863|(talent.alexstraszas_fury.enabled&!buff.hot_streak.react)
    if S.DragonsBreath:IsCastableP() and (Item(132863):IsEquipped() or (S.AlexstraszasFury:IsAvailable() and not bool(Player:BuffStackP(S.HotStreakBuff)))) then
      if AR.Cast(S.DragonsBreath) then return ""; end
    end
    -- living_bomb,if=active_enemies>1&buff.combustion.down
    if S.LivingBomb:IsCastableP() and (active_enemies > 1 and Player:BuffDownP(S.CombustionBuff)) then
      if AR.Cast(S.LivingBomb) then return ""; end
    end
  end
  local function CombustionPhase()
    -- rune_of_power,if=buff.combustion.down
    if S.RuneofPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      if AR.Cast(S.RuneofPower) then return ""; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion
    if S.Combustion:IsCastableP() and (true) then
      if AR.Cast(S.Combustion) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Fire.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Fire.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.ArcaneTorrent, Settings.Fire.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- use_items
    if S.UseItems:IsCastableP() and (true) then
      if AR.Cast(S.UseItems) then return ""; end
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and active_enemies > 2 or active_enemies > 4) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if AR.Cast(S.Flamestrike) then return ""; end
    end
    -- pyroblast,if=buff.kaelthas_ultimate_ability.react&buff.combustion.remains>execute_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.KaelthasUltimateAbilityBuff)) and Player:BuffRemainsP(S.CombustionBuff) > S.Pyroblast:ExecuteTime()) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff))) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- fire_blast,if=buff.heating_up.react
    if S.FireBlast:IsCastableP() and (bool(Player:BuffStackP(S.HeatingUpBuff))) then
      if AR.Cast(S.FireBlast) then return ""; end
    end
    -- phoenixs_flames
    if S.PhoenixsFlames:IsCastableP() and (true) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- scorch,if=buff.combustion.remains>cast_time
    if S.Scorch:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) > S.Scorch:CastTime()) then
      if AR.Cast(S.Scorch) then return ""; end
    end
    -- dragons_breath,if=!buff.hot_streak.react&action.fire_blast.charges<1&action.phoenixs_flames.charges<1
    if S.DragonsBreath:IsCastableP() and (not bool(Player:BuffStackP(S.HotStreakBuff)) and S.FireBlast:ChargesP() < 1 and S.PhoenixsFlames:ChargesP() < 1) then
      if AR.Cast(S.DragonsBreath) then return ""; end
    end
    -- scorch,if=target.health.pct<=30&equipped.132454
    if S.Scorch:IsCastableP() and (target.health.pct <= 30 and Item(132454):IsEquipped()) then
      if AR.Cast(S.Scorch) then return ""; end
    end
  end
  local function RopPhase()
    -- rune_of_power
    if S.RuneofPower:IsCastableP() and (true) then
      if AR.Cast(S.RuneofPower) then return ""; end
    end
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>3)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and active_enemies > 1) or active_enemies > 3) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if AR.Cast(S.Flamestrike) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff))) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains&buff.rune_of_power.remains>cast_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.KaelthasUltimateAbilityBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemainsP(S.KaelthasUltimateAbilityBuff) and Player:BuffRemainsP(S.RuneofPowerBuff) > S.Pyroblast:CastTime()) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- fire_blast,if=!prev_off_gcd.fire_blast&buff.heating_up.react&firestarter.active&charges_fractional>1.7
    if S.FireBlast:IsCastableP() and (not bool(prev_off_gcd.fire_blast) and bool(Player:BuffStackP(S.HeatingUpBuff)) and bool(firestarter.active) and S.BloodBoil:ChargesFractional() > 1.7) then
      if AR.Cast(S.FireBlast) then return ""; end
    end
    -- phoenixs_flames,if=!prev_gcd.1.phoenixs_flames&charges_fractional>2.7&firestarter.active
    if S.PhoenixsFlames:IsCastableP() and (not Player:PrevGCDP(1, S.PhoenixsFlames) and S.BloodBoil:ChargesFractional() > 2.7 and bool(firestarter.active)) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- fire_blast,if=!prev_off_gcd.fire_blast&!firestarter.active
    if S.FireBlast:IsCastableP() and (not bool(prev_off_gcd.fire_blast) and not bool(firestarter.active)) then
      if AR.Cast(S.FireBlast) then return ""; end
    end
    -- phoenixs_flames,if=!prev_gcd.1.phoenixs_flames
    if S.PhoenixsFlames:IsCastableP() and (not Player:PrevGCDP(1, S.PhoenixsFlames)) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- scorch,if=target.health.pct<=30&equipped.132454
    if S.Scorch:IsCastableP() and (target.health.pct <= 30 and Item(132454):IsEquipped()) then
      if AR.Cast(S.Scorch) then return ""; end
    end
    -- dragons_breath,if=active_enemies>2
    if S.DragonsBreath:IsCastableP() and (active_enemies > 2) then
      if AR.Cast(S.DragonsBreath) then return ""; end
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and active_enemies > 2) or active_enemies > 5) then
      if AR.Cast(S.Flamestrike) then return ""; end
    end
    -- fireball
    if S.Fireball:IsCastableP() and (true) then
      if AR.Cast(S.Fireball) then return ""; end
    end
  end
  local function StandardRotation()
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>3)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and active_enemies > 1) or active_enemies > 3) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if AR.Cast(S.Flamestrike) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and Player:BuffRemainsP(S.HotStreakBuff) < S.Fireball:ExecuteTime()) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react&firestarter.active&!talent.rune_of_power.enabled
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and bool(firestarter.active) and not S.RuneofPower:IsAvailable()) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- phoenixs_flames,if=charges_fractional>2.7&active_enemies>2
    if S.PhoenixsFlames:IsCastableP() and (S.BloodBoil:ChargesFractional() > 2.7 and active_enemies > 2) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react&(!prev_gcd.1.pyroblast|action.pyroblast.in_flight)
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and (not Player:PrevGCDP(1, S.Pyroblast) or bool(action.pyroblast.in_flight))) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- pyroblast,if=buff.hot_streak.react&target.health.pct<=30&equipped.132454
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and target.health.pct <= 30 and Item(132454):IsEquipped()) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.KaelthasUltimateAbilityBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemainsP(S.KaelthasUltimateAbilityBuff)) then
      if AR.Cast(S.Pyroblast) then return ""; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- fire_blast,if=!talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.4|cooldown.combustion.remains<40)&(3-charges_fractional)*(12*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
    if S.FireBlast:IsCastableP() and (not S.Kindling:IsAvailable() and bool(Player:BuffStackP(S.HeatingUpBuff)) and (not S.RuneofPower:IsAvailable() or S.BloodBoil:ChargesFractional() > 1.4 or S.Combustion:CooldownRemainsP() < 40) and (3 - S.BloodBoil:ChargesFractional()) * (12 * Player:SpellHaste()) < S.Combustion:CooldownRemainsP() + 3 or Target:TimeToDie() < 4) then
      if AR.Cast(S.FireBlast) then return ""; end
    end
    -- fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.5|cooldown.combustion.remains<40)&(3-charges_fractional)*(18*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
    if S.FireBlast:IsCastableP() and (S.Kindling:IsAvailable() and bool(Player:BuffStackP(S.HeatingUpBuff)) and (not S.RuneofPower:IsAvailable() or S.BloodBoil:ChargesFractional() > 1.5 or S.Combustion:CooldownRemainsP() < 40) and (3 - S.BloodBoil:ChargesFractional()) * (18 * Player:SpellHaste()) < S.Combustion:CooldownRemainsP() + 3 or Target:TimeToDie() < 4) then
      if AR.Cast(S.FireBlast) then return ""; end
    end
    -- phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up|buff.incanters_flow.stack>3|talent.mirror_image.enabled)&artifact.phoenix_reborn.enabled&(4-charges_fractional)*13<cooldown.combustion.remains+5|target.time_to_die<10
    if S.PhoenixsFlames:IsCastableP() and ((Player:BuffP(S.CombustionBuff) or Player:BuffP(S.RuneofPowerBuff) or Player:BuffStackP(S.IncantersFlowBuff) > 3 or S.MirrorImage:IsAvailable()) and bool(artifact.phoenix_reborn.enabled) and (4 - S.BloodBoil:ChargesFractional()) * 13 < S.Combustion:CooldownRemainsP() + 5 or Target:TimeToDie() < 10) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up)&(4-charges_fractional)*30<cooldown.combustion.remains+5
    if S.PhoenixsFlames:IsCastableP() and ((Player:BuffP(S.CombustionBuff) or Player:BuffP(S.RuneofPowerBuff)) and (4 - S.BloodBoil:ChargesFractional()) * 30 < S.Combustion:CooldownRemainsP() + 5) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- phoenixs_flames,if=charges_fractional>2.5&cooldown.combustion.remains>23
    if S.PhoenixsFlames:IsCastableP() and (S.BloodBoil:ChargesFractional() > 2.5 and S.Combustion:CooldownRemainsP() > 23) then
      if AR.Cast(S.PhoenixsFlames) then return ""; end
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>3)|active_enemies>5
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and active_enemies > 3) or active_enemies > 5) then
      if AR.Cast(S.Flamestrike) then return ""; end
    end
    -- scorch,if=target.health.pct<=30&equipped.132454
    if S.Scorch:IsCastableP() and (target.health.pct <= 30 and Item(132454):IsEquipped()) then
      if AR.Cast(S.Scorch) then return ""; end
    end
    -- fireball
    if S.Fireball:IsCastableP() and (true) then
      if AR.Cast(S.Fireball) then return ""; end
    end
    -- scorch
    if S.Scorch:IsCastableP() and (true) then
      if AR.Cast(S.Scorch) then return ""; end
    end
  end
  -- counterspell,if=target.debuff.casting.react
  if S.Counterspell:IsCastableP() and (bool(target.debuff.casting.react)) then
    if AR.Cast(S.Counterspell) then return ""; end
  end
  -- time_warp,if=(time=0&buff.bloodlust.down)|(buff.bloodlust.down&equipped.132410&(cooldown.combustion.remains<1|target.time_to_die<50))
  if S.TimeWarp:IsCastableP() and ((AC.CombatTime() == 0 and Player:HasNotHeroism()) or (Player:HasNotHeroism() and Item(132410):IsEquipped() and (S.Combustion:CooldownRemainsP() < 1 or Target:TimeToDie() < 50))) then
    if AR.Cast(S.TimeWarp) then return ""; end
  end
  -- mirror_image,if=buff.combustion.down
  if S.MirrorImage:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
    if AR.Cast(S.MirrorImage) then return ""; end
  end
  -- rune_of_power,if=firestarter.active&action.rune_of_power.charges=2|cooldown.combustion.remains>40&buff.combustion.down&!talent.kindling.enabled|target.time_to_die<11|talent.kindling.enabled&(charges_fractional>1.8|time<40)&cooldown.combustion.remains>40
  if S.RuneofPower:IsCastableP() and (bool(firestarter.active) and S.RuneofPower:ChargesP() == 2 or S.Combustion:CooldownRemainsP() > 40 and Player:BuffDownP(S.CombustionBuff) and not S.Kindling:IsAvailable() or Target:TimeToDie() < 11 or S.Kindling:IsAvailable() and (S.BloodBoil:ChargesFractional() > 1.8 or AC.CombatTime() < 40) and S.Combustion:CooldownRemainsP() > 40) then
    if AR.Cast(S.RuneofPower) then return ""; end
  end
  -- rune_of_power,if=(buff.kaelthas_ultimate_ability.react&(cooldown.combustion.remains>40|action.rune_of_power.charges>1))|(buff.erupting_infernal_core.up&(cooldown.combustion.remains>40|action.rune_of_power.charges>1))
  if S.RuneofPower:IsCastableP() and ((bool(Player:BuffStackP(S.KaelthasUltimateAbilityBuff)) and (S.Combustion:CooldownRemainsP() > 40 or S.RuneofPower:ChargesP() > 1)) or (Player:BuffP(S.EruptingInfernalCoreBuff) and (S.Combustion:CooldownRemainsP() > 40 or S.RuneofPower:ChargesP() > 1))) then
    if AR.Cast(S.RuneofPower) then return ""; end
  end
  -- call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)&(!talent.firestarter.enabled|!firestarter.active|active_enemies>=4|active_enemies>=2&talent.flame_patch.enabled)|buff.combustion.up
  if (S.Combustion:CooldownRemainsP() <= S.RuneofPower:CastTime() + (num(not S.Kindling:IsAvailable()) * Player:GCD()) and (not S.Firestarter:IsAvailable() or not bool(firestarter.active) or active_enemies >= 4 or active_enemies >= 2 and S.FlamePatch:IsAvailable()) or Player:BuffP(S.CombustionBuff)) then
    local ShouldReturn = CombustionPhase(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
  if (Player:BuffP(S.RuneofPowerBuff) and Player:BuffDownP(S.CombustionBuff)) then
    local ShouldReturn = RopPhase(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=standard_rotation
  if (true) then
    local ShouldReturn = StandardRotation(); if ShouldReturn then return ShouldReturn; end
  end
end