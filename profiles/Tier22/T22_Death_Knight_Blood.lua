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
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Blood = {
  DeathStrike                           = Spell(49998),
  BloodDrinker                          = Spell(206931),
  DancingRuneWeaponBuff                 = Spell(81256),
  Marrowrend                            = Spell(195182),
  BoneShieldBuff                        = Spell(195181),
  BloodBoil                             = Spell(50842),
  HemostasisBuff                        = Spell(),
  Ossuary                               = Spell(219786),
  Bonestorm                             = Spell(194844),
  Heartbreaker                          = Spell(),
  DeathandDecay                         = Spell(),
  RuneStrike                            = Spell(),
  HeartStrike                           = Spell(206930),
  CrimsonScourgeBuff                    = Spell(81141),
  RapidDecomposition                    = Spell(194662),
  Consumption                           = Spell(205223),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  DancingRuneWeapon                     = Spell(49028),
  Berserking                            = Spell(26297),
  Tombstone                             = Spell()
};
local S = Spell.DeathKnight.Blood;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Blood = {
  ProlongedPower                   = Item(142117),
  RazdunksBigRedButton             = Item(),
  MerekthasFang                    = Item()
};
local I = Item.DeathKnight.Blood;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Blood = HR.GUISettings.APL.DeathKnight.Blood
};


local EnemyRanges = {5}
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
  local Precombat, Standard
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
  end
  Standard = function()
    -- death_strike,if=runic_power.deficit<=10
    if S.DeathStrike:IsUsableP() and (Player:RunicPowerDeficit() <= 10) then
      if HR.Cast(S.DeathStrike) then return "death_strike 6"; end
    end
    -- blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.BloodDrinker:IsCastableP() and (not Player:BuffP(S.DancingRuneWeaponBuff)) then
      if HR.Cast(S.BloodDrinker, Settings.Blood.GCDasOffGCD.BloodDrinker) then return "blooddrinker 8"; end
    end
    -- marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
    if S.Marrowrend:IsCastableP() and ((Player:BuffRemainsP(S.BoneShieldBuff) <= Player:RuneTimeToX(3) or Player:BuffRemainsP(S.BoneShieldBuff) <= (Player:GCD() + num(S.BloodDrinker:CooldownUpP()) * num(S.BloodDrinker:IsAvailable()) * 2) or Player:BuffStackP(S.BoneShieldBuff) < 3) and Player:RunicPowerDeficit() >= 20) then
      if HR.Cast(S.Marrowrend) then return "marrowrend 12"; end
    end
    -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
    if S.BloodBoil:IsCastableP() and (S.BloodBoil:ChargesFractionalP() >= 1.8 and (Player:BuffStackP(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[5]) or Cache.EnemiesCount[5] > 2)) then
      if HR.Cast(S.BloodBoil) then return "blood_boil 24"; end
    end
    -- marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
    if S.Marrowrend:IsCastableP() and (Player:BuffStackP(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable() and Player:RunicPowerDeficit() >= 15) then
      if HR.Cast(S.Marrowrend) then return "marrowrend 32"; end
    end
    -- bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
    if S.Bonestorm:IsCastableP() and (Player:RunicPower() >= 100 and not Player:BuffP(S.DancingRuneWeaponBuff)) then
      if HR.Cast(S.Bonestorm) then return "bonestorm 38"; end
    end
    -- death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.time_to_die<10
    if S.DeathStrike:IsUsableP() and (Player:RunicPowerDeficit() <= (15 + num(Player:BuffP(S.DancingRuneWeaponBuff)) * 5 + Cache.EnemiesCount[5] * num(S.Heartbreaker:IsAvailable()) * 2) or Target:TimeToDie() < 10) then
      if HR.Cast(S.DeathStrike) then return "death_strike 42"; end
    end
    -- death_and_decay,if=spell_targets.death_and_decay>=3
    if S.DeathandDecay:IsCastableP() and (Cache.EnemiesCount[5] >= 3) then
      if HR.Cast(S.DeathandDecay) then return "death_and_decay 48"; end
    end
    -- rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
    if S.RuneStrike:IsCastableP() and ((S.RuneStrike:ChargesFractionalP() >= 1.8 or Player:BuffP(S.DancingRuneWeaponBuff)) and Player:RuneTimeToX(3) >= Player:GCD()) then
      if HR.Cast(S.RuneStrike) then return "rune_strike 50"; end
    end
    -- heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
    if S.HeartStrike:IsCastableP() and (Player:BuffP(S.DancingRuneWeaponBuff) or Player:RuneTimeToX(4) < Player:GCD()) then
      if HR.Cast(S.HeartStrike) then return "heart_strike 58"; end
    end
    -- blood_boil,if=buff.dancing_rune_weapon.up
    if S.BloodBoil:IsCastableP() and (Player:BuffP(S.DancingRuneWeaponBuff)) then
      if HR.Cast(S.BloodBoil) then return "blood_boil 62"; end
    end
    -- death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
    if S.DeathandDecay:IsCastableP() and (Player:BuffP(S.CrimsonScourgeBuff) or S.RapidDecomposition:IsAvailable() or Cache.EnemiesCount[5] >= 2) then
      if HR.Cast(S.DeathandDecay) then return "death_and_decay 66"; end
    end
    -- consumption
    if S.Consumption:IsCastableP() then
      if HR.Cast(S.Consumption) then return "consumption 72"; end
    end
    -- blood_boil
    if S.BloodBoil:IsCastableP() then
      if HR.Cast(S.BloodBoil) then return "blood_boil 74"; end
    end
    -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsCastableP() and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
      if HR.Cast(S.HeartStrike) then return "heart_strike 76"; end
    end
    -- rune_strike
    if S.RuneStrike:IsCastableP() then
      if HR.Cast(S.RuneStrike) then return "rune_strike 80"; end
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 20) then
      if HR.Cast(S.ArcaneTorrent, Settings.Blood.GCDasOffGCD.ArcaneTorrent) then return "arcane_torrent 82"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- blood_fury,if=cooldown.dancing_rune_weapon.ready&(!cooldown.blooddrinker.ready|!talent.blooddrinker.enabled)
    if S.BloodFury:IsCastableP() and (S.DancingRuneWeapon:CooldownUpP() and (not S.BloodDrinker:CooldownUpP() or not S.BloodDrinker:IsAvailable())) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 86"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 94"; end
    end
    -- use_items,if=cooldown.dancing_rune_weapon.remains>90
    -- use_item,name=razdunks_big_red_button
    if I.RazdunksBigRedButton:IsReady() then
      if HR.CastSuggested(I.RazdunksBigRedButton) then return "razdunks_big_red_button 97"; end
    end
    -- use_item,name=merekthas_fang
    if I.MerekthasFang:IsReady() then
      if HR.CastSuggested(I.MerekthasFang) then return "merekthas_fang 99"; end
    end
    -- potion,if=buff.dancing_rune_weapon.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.DancingRuneWeaponBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 101"; end
    end
    -- dancing_rune_weapon,if=!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready
    if S.DancingRuneWeapon:IsCastableP() and HR.CDsON() and (not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:CooldownUpP()) then
      if HR.Cast(S.DancingRuneWeapon, Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon) then return "dancing_rune_weapon 105"; end
    end
    -- tombstone,if=buff.bone_shield.stack>=7
    if S.Tombstone:IsCastableP() and (Player:BuffStackP(S.BoneShieldBuff) >= 7) then
      if HR.Cast(S.Tombstone) then return "tombstone 111"; end
    end
    -- call_action_list,name=standard
    if (true) then
      local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(250, APL)
