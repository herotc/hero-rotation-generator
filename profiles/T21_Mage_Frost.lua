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
if not Spell.Mage then Spell.Mage = {} end
Spell.Mage.Frost = {
  WaterElemental                        = Spell(),
  MirrorImage                           = Spell(55342),
  Frostbolt                             = Spell(116),
  FrozenOrb                             = Spell(84714),
  Blizzard                              = Spell(190356),
  CometStorm                            = Spell(153595),
  IceNova                               = Spell(157997),
  WaterJet                              = Spell(135029, "pet"),
  FingersofFrostBuff                    = Spell(44544),
  BrainFreezeBuff                       = Spell(190446),
  Flurry                                = Spell(44614),
  Ebonbolt                              = Spell(214634),
  GlacialSpike                          = Spell(199786),
  FrostBomb                             = Spell(112948),
  FrostBombDebuff                       = Spell(112948),
  IceLance                              = Spell(30455),
  ConeofCold                            = Spell(120),
  RuneofPower                           = Spell(116011),
  IcyVeins                              = Spell(12472),
  IcyVeinsBuff                          = Spell(12472),
  UseItems                              = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  Blink                                 = Spell(1953),
  IceFloes                              = Spell(108839),
  IceFloesBuff                          = Spell(108839),
  WintersChillDebuff                    = Spell(228358),
  RayofFrost                            = Spell(205021),
  RuneofPowerBuff                       = Spell(116014),
  IciclesBuff                           = Spell(205473),
  ZannesuJourneyBuff                    = Spell(206397),
  FrozenMassBuff                        = Spell(242253),
  Counterspell                          = Spell(2139),
  TimeWarp                              = Spell(80353),
  ExhaustionBuff                        = Spell(57723)
};
local S = Spell.Mage.Frost;

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Frost = {
  ProlongedPower                   = Item(142117),
  ShardoftheExodar                 = Item(132410)
};
local I = Item.Mage.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Mage.Commons,
  Frost = AR.GUISettings.APL.Mage.Frost
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
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- water_elemental
    if S.WaterElemental:IsCastableP() and (true) then
      if AR.Cast(S.WaterElemental) then return ""; end
    end
    -- snapshot_stats
    -- mirror_image
    if S.MirrorImage:IsCastableP() and (true) then
      if AR.Cast(S.MirrorImage) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- frostbolt
    if S.Frostbolt:IsCastableP() and (true) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
  end
  local function Aoe()
    -- frostbolt,if=prev_off_gcd.water_jet
    if S.Frostbolt:IsCastableP() and (bool(prev_off_gcd.water_jet)) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
    -- frozen_orb
    if S.FrozenOrb:IsCastableP() and (true) then
      if AR.Cast(S.FrozenOrb) then return ""; end
    end
    -- blizzard
    if S.Blizzard:IsCastableP() and (true) then
      if AR.Cast(S.Blizzard) then return ""; end
    end
    -- comet_storm
    if S.CometStorm:IsCastableP() and (true) then
      if AR.Cast(S.CometStorm) then return ""; end
    end
    -- ice_nova
    if S.IceNova:IsCastableP() and (true) then
      if AR.Cast(S.IceNova) then return ""; end
    end
    -- water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<3&!buff.brain_freeze.react
    if S.WaterJet:IsCastableP() and (Player:PrevGCDP(1, S.Frostbolt) and Player:BuffStackP(S.FingersofFrostBuff) < 3 and not bool(Player:BuffStackP(S.BrainFreezeBuff))) then
      if AR.Cast(S.WaterJet) then return ""; end
    end
    -- flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt)
    if S.Flurry:IsCastableP() and (Player:PrevGCDP(1, S.Ebonbolt) or bool(Player:BuffStackP(S.BrainFreezeBuff)) and (Player:PrevGCDP(1, S.GlacialSpike) or Player:PrevGCDP(1, S.Frostbolt))) then
      if AR.Cast(S.Flurry) then return ""; end
    end
    -- frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&buff.fingers_of_frost.react
    if S.FrostBomb:IsCastableP() and (Target:DebuffRemainsP(S.FrostBombDebuff) < S.IceLance:TravelTime() and bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      if AR.Cast(S.FrostBomb) then return ""; end
    end
    -- ice_lance,if=buff.fingers_of_frost.react
    if S.IceLance:IsCastableP() and (bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      if AR.Cast(S.IceLance) then return ""; end
    end
    -- ebonbolt
    if S.Ebonbolt:IsCastableP() and (true) then
      if AR.Cast(S.Ebonbolt) then return ""; end
    end
    -- glacial_spike
    if S.GlacialSpike:IsCastableP() and (true) then
      if AR.Cast(S.GlacialSpike) then return ""; end
    end
    -- frostbolt
    if S.Frostbolt:IsCastableP() and (true) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
    -- cone_of_cold
    if S.ConeofCold:IsCastableP() and (true) then
      if AR.Cast(S.ConeofCold) then return ""; end
    end
    -- ice_lance
    if S.IceLance:IsCastableP() and (true) then
      if AR.Cast(S.IceLance) then return ""; end
    end
  end
  local function Cooldowns()
    -- rune_of_power,if=cooldown.icy_veins.remains<cast_time|charges_fractional>1.9&cooldown.icy_veins.remains>10|buff.icy_veins.up|target.time_to_die+5<charges_fractional*10
    if S.RuneofPower:IsCastableP() and (S.IcyVeins:CooldownRemainsP() < S.RuneofPower:CastTime() or S.RuneofPower:ChargesFractional() > 1.9 and S.IcyVeins:CooldownRemainsP() > 10 or Player:BuffP(S.IcyVeinsBuff) or Target:TimeToDie() + 5 < S.RuneofPower:ChargesFractional() * 10) then
      if AR.Cast(S.RuneofPower) then return ""; end
    end
    -- potion,if=cooldown.icy_veins.remains<1|target.time_to_die<70
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.IcyVeins:CooldownRemainsP() < 1 or Target:TimeToDie() < 70) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- icy_veins
    if S.IcyVeins:IsCastableP() and (true) then
      if AR.Cast(S.IcyVeins) then return ""; end
    end
    -- mirror_image
    if S.MirrorImage:IsCastableP() and (true) then
      if AR.Cast(S.MirrorImage) then return ""; end
    end
    -- use_items
    if S.UseItems:IsCastableP() and (true) then
      if AR.Cast(S.UseItems) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Frost.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Frost.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.ArcaneTorrent, Settings.Frost.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  local function Movement()
    -- blink,if=movement.distance>10
    if S.Blink:IsCastableP() and (movement.distance > 10) then
      if AR.Cast(S.Blink) then return ""; end
    end
    -- ice_floes,if=buff.ice_floes.down&!buff.fingers_of_frost.react
    if S.IceFloes:IsCastableP() and (Player:BuffDownP(S.IceFloesBuff) and not bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      if AR.Cast(S.IceFloes) then return ""; end
    end
  end
  local function Single()
    -- ice_nova,if=debuff.winters_chill.up
    if S.IceNova:IsCastableP() and (Target:DebuffP(S.WintersChillDebuff)) then
      if AR.Cast(S.IceNova) then return ""; end
    end
    -- frostbolt,if=prev_off_gcd.water_jet
    if S.Frostbolt:IsCastableP() and (bool(prev_off_gcd.water_jet)) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
    -- water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<3&!buff.brain_freeze.react
    if S.WaterJet:IsCastableP() and (Player:PrevGCDP(1, S.Frostbolt) and Player:BuffStackP(S.FingersofFrostBuff) < 3 and not bool(Player:BuffStackP(S.BrainFreezeBuff))) then
      if AR.Cast(S.WaterJet) then return ""; end
    end
    -- ray_of_frost,if=buff.icy_veins.up|cooldown.icy_veins.remains>action.ray_of_frost.cooldown&buff.rune_of_power.down
    if S.RayofFrost:IsCastableP() and (Player:BuffP(S.IcyVeinsBuff) or S.IcyVeins:CooldownRemainsP() > S.RayofFrost:Cooldown() and Player:BuffDownP(S.RuneofPowerBuff)) then
      if AR.Cast(S.RayofFrost) then return ""; end
    end
    -- flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt&(!talent.glacial_spike.enabled|buff.icicles.stack<=4|cooldown.frozen_orb.remains<=10&set_bonus.tier20_2pc))
    if S.Flurry:IsCastableP() and (Player:PrevGCDP(1, S.Ebonbolt) or bool(Player:BuffStackP(S.BrainFreezeBuff)) and (Player:PrevGCDP(1, S.GlacialSpike) or Player:PrevGCDP(1, S.Frostbolt) and (not S.GlacialSpike:IsAvailable() or Player:BuffStackP(S.IciclesBuff) <= 4 or S.FrozenOrb:CooldownRemainsP() <= 10 and AC.Tier20_2Pc))) then
      if AR.Cast(S.Flurry) then return ""; end
    end
    -- frozen_orb,if=set_bonus.tier20_2pc&buff.fingers_of_frost.react<3
    if S.FrozenOrb:IsCastableP() and (AC.Tier20_2Pc and Player:BuffStackP(S.FingersofFrostBuff) < 3) then
      if AR.Cast(S.FrozenOrb) then return ""; end
    end
    -- blizzard,if=cast_time=0&active_enemies>1&buff.fingers_of_frost.react<3
    if S.Blizzard:IsCastableP() and (S.Blizzard:CastTime() == 0 and Cache.EnemiesCount[35] > 1 and Player:BuffStackP(S.FingersofFrostBuff) < 3) then
      if AR.Cast(S.Blizzard) then return ""; end
    end
    -- frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&buff.fingers_of_frost.react
    if S.FrostBomb:IsCastableP() and (Target:DebuffRemainsP(S.FrostBombDebuff) < S.IceLance:TravelTime() and bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      if AR.Cast(S.FrostBomb) then return ""; end
    end
    -- ice_lance,if=buff.fingers_of_frost.react
    if S.IceLance:IsCastableP() and (bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      if AR.Cast(S.IceLance) then return ""; end
    end
    -- ebonbolt
    if S.Ebonbolt:IsCastableP() and (true) then
      if AR.Cast(S.Ebonbolt) then return ""; end
    end
    -- frozen_orb
    if S.FrozenOrb:IsCastableP() and (true) then
      if AR.Cast(S.FrozenOrb) then return ""; end
    end
    -- ice_nova
    if S.IceNova:IsCastableP() and (true) then
      if AR.Cast(S.IceNova) then return ""; end
    end
    -- comet_storm
    if S.CometStorm:IsCastableP() and (true) then
      if AR.Cast(S.CometStorm) then return ""; end
    end
    -- blizzard,if=active_enemies>1|buff.zannesu_journey.stack=5&buff.zannesu_journey.remains>cast_time
    if S.Blizzard:IsCastableP() and (Cache.EnemiesCount[35] > 1 or Player:BuffStackP(S.ZannesuJourneyBuff) == 5 and Player:BuffRemainsP(S.ZannesuJourneyBuff) > S.Blizzard:CastTime()) then
      if AR.Cast(S.Blizzard) then return ""; end
    end
    -- frostbolt,if=buff.frozen_mass.remains>execute_time+action.glacial_spike.execute_time+action.glacial_spike.travel_time&!buff.brain_freeze.react&talent.glacial_spike.enabled
    if S.Frostbolt:IsCastableP() and (Player:BuffRemainsP(S.FrozenMassBuff) > S.Frostbolt:ExecuteTime() + S.GlacialSpike:ExecuteTime() + S.GlacialSpike:TravelTime() and not bool(Player:BuffStackP(S.BrainFreezeBuff)) and S.GlacialSpike:IsAvailable()) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
    -- glacial_spike,if=cooldown.frozen_orb.remains>10|!set_bonus.tier20_2pc
    if S.GlacialSpike:IsCastableP() and (S.FrozenOrb:CooldownRemainsP() > 10 or not AC.Tier20_2Pc) then
      if AR.Cast(S.GlacialSpike) then return ""; end
    end
    -- frostbolt
    if S.Frostbolt:IsCastableP() and (true) then
      if AR.Cast(S.Frostbolt) then return ""; end
    end
    -- blizzard
    if S.Blizzard:IsCastableP() and (true) then
      if AR.Cast(S.Blizzard) then return ""; end
    end
    -- ice_lance
    if S.IceLance:IsCastableP() and (true) then
      if AR.Cast(S.IceLance) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- counterspell
  if S.Counterspell:IsCastableP() and (true) then
    if AR.Cast(S.Counterspell) then return ""; end
  end
  -- ice_lance,if=!buff.fingers_of_frost.react&prev_gcd.1.flurry
  if S.IceLance:IsCastableP() and (not bool(Player:BuffStackP(S.FingersofFrostBuff)) and Player:PrevGCDP(1, S.Flurry)) then
    if AR.Cast(S.IceLance) then return ""; end
  end
  -- time_warp,if=buff.bloodlust.down&(buff.exhaustion.down|equipped.shard_of_the_exodar)&(cooldown.icy_veins.remains<1|target.time_to_die<50)
  if S.TimeWarp:IsCastableP() and (Player:HasNotHeroism() and (Player:BuffDownP(S.ExhaustionBuff) or I.ShardoftheExodar:IsEquipped()) and (S.IcyVeins:CooldownRemainsP() < 1 or Target:TimeToDie() < 50)) then
    if AR.Cast(S.TimeWarp) then return ""; end
  end
  -- call_action_list,name=movement,moving=1
  if (true) then
    local ShouldReturn = Movement(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=aoe,if=active_enemies>=3
  if (Cache.EnemiesCount[35] >= 3) then
    local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=single
  if (true) then
    local ShouldReturn = Single(); if ShouldReturn then return ShouldReturn; end
  end
end