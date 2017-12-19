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
Spell.Paladin.Protection = {
  Seraphim                              = Spell(152262),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  ShieldoftheRighteous                  = Spell(53600),
  EyeofTyrDebuff                        = Spell(209202),
  AegisofLightBuff                      = Spell(204150),
  ArdentDefenderBuff                    = Spell(31850),
  GuardianofAncientKingsBuff            = Spell(86659),
  DivineShieldBuff                      = Spell(642),
  ProlongedPowerBuff                    = Spell(229206),
  BastionofLight                        = Spell(204035),
  LightoftheProtector                   = Spell(184092),
  HandoftheProtector                    = Spell(213652),
  RighteousProtector                    = Spell(204074),
  DivineSteed                           = Spell(190784),
  KnightTemplar                         = Spell(204139),
  EyeofTyr                              = Spell(209202),
  AegisofLight                          = Spell(204150),
  GuardianofAncientKings                = Spell(86659),
  DivineShield                          = Spell(642),
  FinalStand                            = Spell(204077),
  ArdentDefender                        = Spell(31850),
  LayOnHands                            = Spell(),
  AvengingWrathBuff                     = Spell(31884),
  Stoneform                             = Spell(20594),
  AvengingWrath                         = Spell(31884),
  Judgment                              = Spell(20271),
  AvengersShield                        = Spell(31935),
  CrusadersJudgment                     = Spell(),
  GrandCrusaderBuff                     = Spell(85043),
  BlessedHammer                         = Spell(204019),
  Consecration                          = Spell(26573),
  HammeroftheRighteous                  = Spell(53595),
  SeraphimBuff                          = Spell(152262)
};
local S = Spell.Paladin.Protection;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Protection = {
  ProlongedPower                   = Item(142117),
  Item151812                       = Item(151812)
};
local I = Item.Paladin.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Paladin.Commons,
  Protection = AR.GUISettings.APL.Paladin.Protection
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local function Precombat()
    -- flask,type=flask_of_ten_thousand_scars,if=!talent.seraphim.enabled
    -- flask,type=flask_of_the_countless_armies,if=(role.attack|talent.seraphim.enabled)
    -- food,type=seedbattered_fish_plate,if=!talent.seraphim.enabled
    -- food,type=lavish_suramar_feast,if=(role.attack|talent.seraphim.enabled)
    -- snapshot_stats
    -- potion,name=unbending_potion,if=!talent.seraphim.enabled
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (not S.Seraphim:IsAvailable()) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,name=old_war,if=(role.attack|talent.seraphim.enabled)&active_enemies<3
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((bool(role.attack) or S.Seraphim:IsAvailable()) and Cache.EnemiesCount[30] < 3) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,name=prolonged_power,if=(role.attack|talent.seraphim.enabled)&active_enemies>=3
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((bool(role.attack) or S.Seraphim:IsAvailable()) and Cache.EnemiesCount[30] >= 3) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function MaxDps()
    -- auto_attack
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Protection.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Protection.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.ArcaneTorrent, Settings.Protection.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  local function MaxSurvival()
    -- auto_attack
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Protection.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Protection.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.ArcaneTorrent, Settings.Protection.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  local function Prot()
    -- shield_of_the_righteous,if=!talent.seraphim.enabled&(action.shield_of_the_righteous.charges>2)&!(debuff.eye_of_tyr.up&buff.aegis_of_light.up&buff.ardent_defender.up&buff.guardian_of_ancient_kings.up&buff.divine_shield.up&buff.potion.up)
    if S.ShieldoftheRighteous:IsCastableP() and (not S.Seraphim:IsAvailable() and (S.ShieldoftheRighteous:ChargesP() > 2) and not (Target:DebuffP(S.EyeofTyrDebuff) and Player:BuffP(S.AegisofLightBuff) and Player:BuffP(S.ArdentDefenderBuff) and Player:BuffP(S.GuardianofAncientKingsBuff) and Player:BuffP(S.DivineShieldBuff) and Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.ShieldoftheRighteous) then return ""; end
    end
    -- bastion_of_light,if=!talent.seraphim.enabled&talent.bastion_of_light.enabled&action.shield_of_the_righteous.charges<1
    if S.BastionofLight:IsCastableP() and (not S.Seraphim:IsAvailable() and S.BastionofLight:IsAvailable() and S.ShieldoftheRighteous:ChargesP() < 1) then
      if AR.Cast(S.BastionofLight) then return ""; end
    end
    -- light_of_the_protector,if=(health.pct<40)
    if S.LightoftheProtector:IsCastableP() and ((health.pct < 40)) then
      if AR.Cast(S.LightoftheProtector) then return ""; end
    end
    -- hand_of_the_protector,if=(health.pct<40)
    if S.HandoftheProtector:IsCastableP() and ((health.pct < 40)) then
      if AR.Cast(S.HandoftheProtector) then return ""; end
    end
    -- light_of_the_protector,if=(incoming_damage_10000ms<health.max*1.25)&health.pct<55&talent.righteous_protector.enabled
    if S.LightoftheProtector:IsCastableP() and ((incoming_damage_10000ms < health.max * 1.25) and health.pct < 55 and S.RighteousProtector:IsAvailable()) then
      if AR.Cast(S.LightoftheProtector) then return ""; end
    end
    -- light_of_the_protector,if=(incoming_damage_13000ms<health.max*1.6)&health.pct<55
    if S.LightoftheProtector:IsCastableP() and ((incoming_damage_13000ms < health.max * 1.6) and health.pct < 55) then
      if AR.Cast(S.LightoftheProtector) then return ""; end
    end
    -- hand_of_the_protector,if=(incoming_damage_6000ms<health.max*0.7)&health.pct<65&talent.righteous_protector.enabled
    if S.HandoftheProtector:IsCastableP() and ((incoming_damage_6000ms < health.max * 0.7) and health.pct < 65 and S.RighteousProtector:IsAvailable()) then
      if AR.Cast(S.HandoftheProtector) then return ""; end
    end
    -- hand_of_the_protector,if=(incoming_damage_9000ms<health.max*1.2)&health.pct<55
    if S.HandoftheProtector:IsCastableP() and ((incoming_damage_9000ms < health.max * 1.2) and health.pct < 55) then
      if AR.Cast(S.HandoftheProtector) then return ""; end
    end
    -- divine_steed,if=!talent.seraphim.enabled&talent.knight_templar.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.DivineSteed:IsCastableP() and (not S.Seraphim:IsAvailable() and S.KnightTemplar:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.DivineSteed) then return ""; end
    end
    -- eye_of_tyr,if=!talent.seraphim.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.EyeofTyr:IsCastableP() and (not S.Seraphim:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.EyeofTyr) then return ""; end
    end
    -- aegis_of_light,if=!talent.seraphim.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.AegisofLight:IsCastableP() and (not S.Seraphim:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.AegisofLight) then return ""; end
    end
    -- guardian_of_ancient_kings,if=!talent.seraphim.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.GuardianofAncientKings:IsCastableP() and (not S.Seraphim:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.GuardianofAncientKings) then return ""; end
    end
    -- divine_shield,if=!talent.seraphim.enabled&talent.final_stand.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.DivineShield:IsCastableP() and (not S.Seraphim:IsAvailable() and S.FinalStand:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.DivineShield) then return ""; end
    end
    -- ardent_defender,if=!talent.seraphim.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.ArdentDefender:IsCastableP() and (not S.Seraphim:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.ArdentDefender) then return ""; end
    end
    -- lay_on_hands,if=!talent.seraphim.enabled&health.pct<15
    if S.LayOnHands:IsCastableP() and (not S.Seraphim:IsAvailable() and health.pct < 15) then
      if AR.Cast(S.LayOnHands) then return ""; end
    end
    -- potion,name=old_war,if=buff.avenging_wrath.up&talent.seraphim.enabled&active_enemies<3
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvengingWrathBuff) and S.Seraphim:IsAvailable() and Cache.EnemiesCount[30] < 3) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,name=prolonged_power,if=buff.avenging_wrath.up&talent.seraphim.enabled&active_enemies>=3
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvengingWrathBuff) and S.Seraphim:IsAvailable() and Cache.EnemiesCount[30] >= 3) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,name=unbending_potion,if=!talent.seraphim.enabled
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (not S.Seraphim:IsAvailable()) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,name=draenic_strength,if=incoming_damage_2500ms>health.max*0.4&&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)|target.time_to_die<=25
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (incoming_damage_2500ms > health.max * 0.4 and true and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff)) or Target:TimeToDie() <= 25) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- stoneform,if=!talent.seraphim.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
    if S.Stoneform:IsCastableP() and (not S.Seraphim:IsAvailable() and incoming_damage_2500ms > health.max * 0.4 and not (Target:DebuffP(S.EyeofTyrDebuff) or Player:BuffP(S.AegisofLightBuff) or Player:BuffP(S.ArdentDefenderBuff) or Player:BuffP(S.GuardianofAncientKingsBuff) or Player:BuffP(S.DivineShieldBuff) or Player:BuffP(S.ProlongedPowerBuff))) then
      if AR.Cast(S.Stoneform) then return ""; end
    end
    -- avenging_wrath,if=!talent.seraphim.enabled
    if S.AvengingWrath:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.AvengingWrath) then return ""; end
    end
    -- judgment,if=!talent.seraphim.enabled
    if S.Judgment:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- avengers_shield,if=!talent.seraphim.enabled&talent.crusaders_judgment.enabled&buff.grand_crusader.up
    if S.AvengersShield:IsCastableP() and (not S.Seraphim:IsAvailable() and S.CrusadersJudgment:IsAvailable() and Player:BuffP(S.GrandCrusaderBuff)) then
      if AR.Cast(S.AvengersShield) then return ""; end
    end
    -- blessed_hammer,if=!talent.seraphim.enabled
    if S.BlessedHammer:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.BlessedHammer) then return ""; end
    end
    -- avengers_shield,if=!talent.seraphim.enabled
    if S.AvengersShield:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.AvengersShield) then return ""; end
    end
    -- consecration,if=!talent.seraphim.enabled
    if S.Consecration:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.Consecration) then return ""; end
    end
    -- hammer_of_the_righteous,if=!talent.seraphim.enabled
    if S.HammeroftheRighteous:IsCastableP() and (not S.Seraphim:IsAvailable()) then
      if AR.Cast(S.HammeroftheRighteous) then return ""; end
    end
    -- seraphim,if=talent.seraphim.enabled&action.shield_of_the_righteous.charges>=2
    if S.Seraphim:IsCastableP() and (S.Seraphim:IsAvailable() and S.ShieldoftheRighteous:ChargesP() >= 2) then
      if AR.Cast(S.Seraphim) then return ""; end
    end
    -- avenging_wrath,if=talent.seraphim.enabled&(buff.seraphim.up|cooldown.seraphim.remains<4)
    if S.AvengingWrath:IsCastableP() and (S.Seraphim:IsAvailable() and (Player:BuffP(S.SeraphimBuff) or S.Seraphim:CooldownRemainsP() < 4)) then
      if AR.Cast(S.AvengingWrath) then return ""; end
    end
    -- ardent_defender,if=talent.seraphim.enabled&buff.seraphim.up
    if S.ArdentDefender:IsCastableP() and (S.Seraphim:IsAvailable() and Player:BuffP(S.SeraphimBuff)) then
      if AR.Cast(S.ArdentDefender) then return ""; end
    end
    -- shield_of_the_righteous,if=talent.seraphim.enabled&(cooldown.consecration.remains>=0.1&(action.shield_of_the_righteous.charges>2.5&cooldown.seraphim.remains>3)|(buff.seraphim.up))
    if S.ShieldoftheRighteous:IsCastableP() and (S.Seraphim:IsAvailable() and (S.Consecration:CooldownRemainsP() >= 0.1 and (S.ShieldoftheRighteous:ChargesP() > 2.5 and S.Seraphim:CooldownRemainsP() > 3) or (Player:BuffP(S.SeraphimBuff)))) then
      if AR.Cast(S.ShieldoftheRighteous) then return ""; end
    end
    -- eye_of_tyr,if=talent.seraphim.enabled&equipped.151812&buff.seraphim.up
    if S.EyeofTyr:IsCastableP() and (S.Seraphim:IsAvailable() and I.Item151812:IsEquipped() and Player:BuffP(S.SeraphimBuff)) then
      if AR.Cast(S.EyeofTyr) then return ""; end
    end
    -- avengers_shield,if=talent.seraphim.enabled
    if S.AvengersShield:IsCastableP() and (S.Seraphim:IsAvailable()) then
      if AR.Cast(S.AvengersShield) then return ""; end
    end
    -- judgment,if=talent.seraphim.enabled&(active_enemies<2|set_bonus.tier20_2pc)
    if S.Judgment:IsCastableP() and (S.Seraphim:IsAvailable() and (Cache.EnemiesCount[30] < 2 or AC.Tier20_2Pc)) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- consecration,if=talent.seraphim.enabled&(buff.seraphim.remains>6|buff.seraphim.down)
    if S.Consecration:IsCastableP() and (S.Seraphim:IsAvailable() and (Player:BuffRemainsP(S.SeraphimBuff) > 6 or Player:BuffDownP(S.SeraphimBuff))) then
      if AR.Cast(S.Consecration) then return ""; end
    end
    -- judgment,if=talent.seraphim.enabled
    if S.Judgment:IsCastableP() and (S.Seraphim:IsAvailable()) then
      if AR.Cast(S.Judgment) then return ""; end
    end
    -- consecration,if=talent.seraphim.enabled
    if S.Consecration:IsCastableP() and (S.Seraphim:IsAvailable()) then
      if AR.Cast(S.Consecration) then return ""; end
    end
    -- eye_of_tyr,if=talent.seraphim.enabled&!equipped.151812
    if S.EyeofTyr:IsCastableP() and (S.Seraphim:IsAvailable() and not I.Item151812:IsEquipped()) then
      if AR.Cast(S.EyeofTyr) then return ""; end
    end
    -- blessed_hammer,if=talent.seraphim.enabled
    if S.BlessedHammer:IsCastableP() and (S.Seraphim:IsAvailable()) then
      if AR.Cast(S.BlessedHammer) then return ""; end
    end
    -- hammer_of_the_righteous,if=talent.seraphim.enabled
    if S.HammeroftheRighteous:IsCastableP() and (S.Seraphim:IsAvailable()) then
      if AR.Cast(S.HammeroftheRighteous) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Protection.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.Berserking, Settings.Protection.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.ArcaneTorrent, Settings.Protection.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Protection.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.Berserking, Settings.Protection.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.ArcaneTorrent, Settings.Protection.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- call_action_list,name=prot
  if (true) then
    local ShouldReturn = Prot(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(66, APL)
