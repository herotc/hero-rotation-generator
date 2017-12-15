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
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Blood = {
  DeathStrike                           = Spell(49998),
  DeathandDecay                         = Spell(43265),
  RapidDecomposition                    = Spell(194662),
  DancingRuneWeaponBuff                 = Spell(81256),
  BloodDrinker                          = Spell(206931),
  Marrowrend                            = Spell(195182),
  BoneShieldBuff                        = Spell(195181),
  BloodBoil                             = Spell(50842),
  HaemostasisBuff                       = Spell(235558),
  Ossuary                               = Spell(219786),
  Bonestorm                             = Spell(194844),
  BloodShieldBuff                       = Spell(77535),
  Consumption                           = Spell(205223),
  HeartStrike                           = Spell(206930),
  CrimsonScourgeBuff                    = Spell(81141),
  MindFreeze                            = Spell(47528),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  UseItems                              = Spell(),
  DancingRuneWeapon                     = Spell(49028),
  VampiricBlood                         = Spell(55233)
};
local S = Spell.DeathKnight.Blood;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Blood = {
  ProlongedPower                   = Item(142117)
};
local I = Item.DeathKnight.Blood;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.DeathKnight.Commons,
  Blood = AR.GUISettings.APL.DeathKnight.Blood
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
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Standard()
    -- death_strike,if=runic_power.deficit<10
    if S.DeathStrike:IsUsable() and (Player:RunicPowerDeficit() < 10) then
      if AR.Cast(S.DeathStrike) then return ""; end
    end
    -- death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
    if S.DeathandDecay:IsUsable() and (S.RapidDecomposition:IsAvailable() and not Player:BuffP(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.BloodDrinker:IsCastableP() and (not Player:BuffP(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.BloodDrinker, Settings.Blood.GCDasOffGCD.BloodDrinker) then return ""; end
    end
    -- marrowrend,if=buff.bone_shield.remains<=gcd*2
    if S.Marrowrend:IsCastableP() and (Player:BuffRemainsP(S.BoneShieldBuff) <= Player:GCD() * 2) then
      if AR.Cast(S.Marrowrend) then return ""; end
    end
    -- blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsCastableP() and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStackP(S.HaemostasisBuff) < 5 and (Player:BuffStackP(S.HaemostasisBuff) < 3 or not Player:BuffP(S.DancingRuneWeaponBuff))) then
      if AR.Cast(S.BloodBoil) then return ""; end
    end
    -- marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsCastableP() and ((Player:BuffStackP(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemainsP(S.BoneShieldBuff) < Player:GCD() * 3) then
      if AR.Cast(S.Marrowrend) then return ""; end
    end
    -- bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    if S.Bonestorm:IsCastableP() and (Player:RunicPower() >= 100 and Cache.EnemiesCount[8] >= 3) then
      if AR.Cast(S.Bonestorm) then return ""; end
    end
    -- death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
    if S.DeathStrike:IsUsable() and (Player:BuffP(S.BloodShieldBuff) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:BuffP(S.DancingRuneWeaponBuff)))) then
      if AR.Cast(S.DeathStrike) then return ""; end
    end
    -- consumption
    if S.Consumption:IsCastableP() and (true) then
      if AR.Cast(S.Consumption) then return ""; end
    end
    -- heart_strike,if=buff.dancing_rune_weapon.up
    if S.HeartStrike:IsCastableP() and (Player:BuffP(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.HeartStrike) then return ""; end
    end
    -- death_and_decay,if=buff.crimson_scourge.up
    if S.DeathandDecay:IsUsable() and (Player:BuffP(S.CrimsonScourgeBuff)) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsCastableP() and (Player:BuffStackP(S.HaemostasisBuff) < 5 and (Player:BuffStackP(S.HaemostasisBuff) < 3 or not Player:BuffP(S.DancingRuneWeaponBuff))) then
      if AR.Cast(S.BloodBoil) then return ""; end
    end
    -- death_and_decay
    if S.DeathandDecay:IsUsable() and (true) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsCastableP() and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
      if AR.Cast(S.HeartStrike) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- mind_freeze
  if S.MindFreeze:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR.CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  -- arcane_torrent,if=runic_power.deficit>20
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:RunicPowerDeficit() > 20) then
    if AR.Cast(S.ArcaneTorrent, Settings.Blood.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Blood.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=buff.dancing_rune_weapon.up
  if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.DancingRuneWeaponBuff)) then
    if AR.Cast(S.Berserking, Settings.Blood.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- potion,if=buff.dancing_rune_weapon.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.DancingRuneWeaponBuff)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- dancing_rune_weapon,if=(!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready)&!cooldown.death_and_decay.ready
  if S.DancingRuneWeapon:IsCastableP() and AR.CDsON() and ((not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:CooldownUpP()) and not S.DeathandDecay:CooldownUpP()) then
    if AR.Cast(S.DancingRuneWeapon, Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon) then return ""; end
  end
  -- vampiric_blood
  if S.VampiricBlood:IsCastableP() and (true) then
    if AR.Cast(S.VampiricBlood) then return ""; end
  end
  -- call_action_list,name=standard
  if (true) then
    local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(250, APL)
