--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC=AethysCore
local Cache=AethysCache
local Unit=AC.Unit
local Player=Unit.Player
local Target=Unit.Target
local Spell=AC.Spell
local Item=AC.Item
-- AethysRotation
local AR=AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.DeathKnight then Spell.DeathKnight={} end
Spell.DeathKnight.Blood={
  DeathStrike                   = Spell(),
  DeathandDecay                 = Spell(),
  RapidDecomposition            = Spell(),
  DancingRuneWeaponBuff         = Spell(),
  BloodDrinker                  = Spell(),
  Marrowrend                    = Spell(),
  BoneShieldBuff                = Spell(),
  BloodBoil                     = Spell(),
  HaemostasisBuff               = Spell(),
  Ossuary                       = Spell(),
  Bonestorm                     = Spell(),
  BloodShieldBuff               = Spell(),
  Consumption                   = Spell(),
  HeartStrike                   = Spell(),
  CrimsonScourgeBuff            = Spell(),
  Nemesis                       = Spell(),
  MindFreeze                    = Spell(),
  ArcaneTorrent                 = Spell(),
  BloodFury                     = Spell(),
  Berserking                    = Spell(),
  UseItems                      = Spell(),
  VampiricBlood                 = Spell(),
  -- Misc
  PoolEnergy                    = Spell(9999000010),
};
local S = Spell.DeathKnight.Blood;

-- Items
if not Item.DeathKnight then Item.DeathKnight={} end
Item.DeathKnight.Blood={
  ProlongedPower                = Item(),
};
local I = Item.DeathKnight.Blood;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.DeathKnight.Commons,
  Blood = AR.GUISettings.APL.DeathKnight.Blood,
};

-- Variables
local WaitingForNemesis = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Standard()
    -- death_strike,if=runic_power.deficit<10
    if S.DeathStrike:IsUsable() and (Player:RunicPowerDeficit() < 10) then
      if AR.Cast(S.DeathStrike) then return ""; end
    end
    -- death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
    if S.DeathandDecay:IsUsable() and (S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.BloodDrinker:IsCastable() and (not Player:Buff(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.BloodDrinker) then return ""; end
    end
    -- marrowrend,if=buff.bone_shield.remains<=gcd*2
    if S.Marrowrend:IsCastable() and (Player:BuffRemainsP(S.BoneShieldBuff) <= Player:GCD() * 2) then
      if AR.Cast(S.Marrowrend) then return ""; end
    end
    -- blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsCastable() and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStackP(S.HaemostasisBuff) < 5 and (Player:BuffStackP(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
      if AR.Cast(S.BloodBoil) then return ""; end
    end
    -- marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsCastable() and ((Player:BuffStackP(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemainsP(S.BoneShieldBuff) < Player:GCD() * 3) then
      if AR.Cast(S.Marrowrend) then return ""; end
    end
    -- bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    if S.Bonestorm:IsCastable() and (Player:RunicPower() >= 100 and spell_targets.bonestorm >= 3) then
      if AR.Cast(S.Bonestorm) then return ""; end
    end
    -- death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
    if S.DeathStrike:IsUsable() and (Player:Buff(S.BloodShieldBuff) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
      if AR.Cast(S.DeathStrike) then return ""; end
    end
    -- consumption
    if S.Consumption:IsCastable() and (true) then
      if AR.Cast(S.Consumption) then return ""; end
    end
    -- heart_strike,if=buff.dancing_rune_weapon.up
    if S.HeartStrike:IsCastable() and (Player:Buff(S.DancingRuneWeaponBuff)) then
      if AR.Cast(S.HeartStrike) then return ""; end
    end
    -- death_and_decay,if=buff.crimson_scourge.up
    if S.DeathandDecay:IsUsable() and (Player:Buff(S.CrimsonScourgeBuff)) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsCastable() and (Player:BuffStackP(S.HaemostasisBuff) < 5 and (Player:BuffStackP(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
      if AR.Cast(S.BloodBoil) then return ""; end
    end
    -- death_and_decay
    if S.DeathandDecay:IsUsable() and (true) then
      if AR.Cast(S.DeathandDecay) then return ""; end
    end
    -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsCastable() and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
      if AR.Cast(S.HeartStrike) then return ""; end
    end
  end
  -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
  if (true) then
    WaitingForNemesis = num(not (not S.Nemesis:IsAvailable() or S.Nemesis:IsReady() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60))
  end
  -- mind_freeze
  if S.MindFreeze:IsCastable() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR.CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  -- arcane_torrent,if=runic_power.deficit>20
  if S.ArcaneTorrent:IsCastable() and (Player:RunicPowerDeficit() > 20) then
    if AR.Cast(S.ArcaneTorrent, Settings.Blood.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastable() and (true) then
    if AR.Cast(S.BloodFury) then return ""; end
  end
  -- berserking,if=buff.dancing_rune_weapon.up
  if S.Berserking:IsCastable() and (Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR.Cast(S.Berserking) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastable() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- potion,if=buff.dancing_rune_weapon.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- dancing_rune_weapon,if=(!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready)&!cooldown.death_and_decay.ready
  if S.DancingRuneWeapon:IsCastable() and ((not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:IsReady()) and not S.DeathandDecay:IsReady()) then
    if AR.Cast(S.DancingRuneWeapon, Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon) then return ""; end
  end
  -- vampiric_blood
  if S.VampiricBlood:IsCastable() and (true) then
    if AR.Cast(S.VampiricBlood) then return ""; end
  end
  -- call_action_list,name=standard
  if (true) then
    local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
  end
end