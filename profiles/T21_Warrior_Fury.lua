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
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Fury = {
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(),
  RecklessnessBuff                      = Spell(),
  Recklessness                          = Spell(),
  Rampage                               = Spell(184367),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
  Execute                               = Spell(5308),
  Bloodthirst                           = Spell(23881),
  RagingBlow                            = Spell(85288),
  RagingBlowBuff                        = Spell(),
  Bladestorm                            = Spell(46924),
  SiegebreakerDebuff                    = Spell(),
  DragonRoar                            = Spell(118000),
  FuriousSlash                          = Spell(100130),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  FuriousSlashBuff                      = Spell(),
  FujiedasFuryBuff                      = Spell(207775),
  BloodthirstBuff                       = Spell(),
  MeatCleaverBuff                       = Spell(85739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell()
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  OldWar                           = Item(127844),
  KazzalaxFujiedasFury             = Item(137053)
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Fury = HR.GUISettings.APL.Warrior.Fury
};

-- Variables

local EnemyRanges = {8}
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
  local function Movement()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() and (true) then
      if HR.Cast(S.HeroicLeap) then return ""; end
    end
  end
  local function SingleTarget()
    -- siegebreaker,if=buff.recklessness.up|cooldown.recklessness.remains>28
    if S.Siegebreaker:IsCastableP() and (Player:BuffP(S.RecklessnessBuff) or S.Recklessness:CooldownRemainsP() > 28) then
      if HR.Cast(S.Siegebreaker) then return ""; end
    end
    -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsCastableP() and (Player:BuffP(S.RecklessnessBuff) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      if HR.Cast(S.Rampage) then return ""; end
    end
    -- execute,if=buff.enrage.up
    if S.Execute:IsCastableP() and (Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.Execute) then return ""; end
    end
    -- bloodthirst,if=buff.enrage.down
    if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff)) then
      if HR.Cast(S.Bloodthirst) then return ""; end
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP() and (S.RagingBlow:ChargesP() == 2) then
      if HR.Cast(S.RagingBlow) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if HR.Cast(S.Bloodthirst) then return ""; end
    end
    -- bladestorm,if=prev_gcd.1.rampage&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if S.Bladestorm:IsCastableP() and (Player:PrevGCDP(1, S.Rampage) and (Target:DebuffP(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable())) then
      if HR.Cast(S.Bladestorm) then return ""; end
    end
    -- dragon_roar,if=buff.enrage.up&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if S.DragonRoar:IsCastableP() and (Player:BuffP(S.EnrageBuff) and (Target:DebuffP(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable())) then
      if HR.Cast(S.DragonRoar) then return ""; end
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      if HR.Cast(S.RagingBlow) then return ""; end
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable()) then
      if HR.Cast(S.FuriousSlash) then return ""; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() and (true) then
      if HR.Cast(S.Whirlwind) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- charge
  if S.Charge:IsCastableP() and (true) then
    if HR.Cast(S.Charge) then return ""; end
  end
  -- run_action_list,name=movement,if=movement.distance>5
  if (movement.distance > 5) then
    return Movement();
  end
  -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)|!raid_event.movement.exists
  if S.HeroicLeap:IsCastableP() and ((raid_event.movement.distance > 25 and 10000000000 > 45) or not false) then
    if HR.Cast(S.HeroicLeap) then return ""; end
  end
  -- potion
  if I.OldWar:IsReady() and Settings.Commons.UsePotions and (true) then
    if HR.CastSuggested(I.OldWar) then return ""; end
  end
  -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
  if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
    if HR.Cast(S.FuriousSlash) then return ""; end
  end
  -- bloodthirst,if=equipped.kazzalax_fujiedas_fury&(buff.fujiedas_fury.down|remains<2)
  if S.Bloodthirst:IsCastableP() and (I.KazzalaxFujiedasFury:IsEquipped() and (Player:BuffDownP(S.FujiedasFuryBuff) or Player:BuffRemainsP(S.BloodthirstBuff) < 2)) then
    if HR.Cast(S.Bloodthirst) then return ""; end
  end
  -- rampage,if=cooldown.recklessness.remains<3
  if S.Rampage:IsCastableP() and (S.Recklessness:CooldownRemainsP() < 3) then
    if HR.Cast(S.Rampage) then return ""; end
  end
  -- recklessness
  if S.Recklessness:IsCastableP() and (true) then
    if HR.Cast(S.Recklessness) then return ""; end
  end
  -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
  if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff)) then
    if HR.Cast(S.Whirlwind) then return ""; end
  end
  -- blood_fury,if=buff.recklessness.up
  if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
    if HR.Cast(S.BloodFury, Settings.Fury.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=buff.recklessness.up
  if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
    if HR.Cast(S.Berserking, Settings.Fury.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent,if=rage<40&!buff.recklessness.up
  if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:Rage() < 40 and not Player:BuffP(S.RecklessnessBuff)) then
    if HR.Cast(S.ArcaneTorrent, Settings.Fury.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- lights_judgment,if=cooldown.recklessness.remains<3
  if S.LightsJudgment:IsCastableP() and (S.Recklessness:CooldownRemainsP() < 3) then
    if HR.Cast(S.LightsJudgment) then return ""; end
  end
  -- run_action_list,name=single_target
  if (true) then
    return SingleTarget();
  end
end

HR.SetAPL(72, APL)
