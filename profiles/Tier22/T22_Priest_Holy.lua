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
if not Spell.Priest then Spell.Priest = {} end
Spell.Priest.Holy = {
  Smite                                 = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  HolyFire                              = Spell(),
  HolyFireDebuff                        = Spell(),
  HolyWordChastise                      = Spell(),
  Apotheosis                            = Spell(),
  DivineStar                            = Spell(),
  Halo                                  = Spell(),
  HolyNova                              = Spell()
};
local S = Spell.Priest.Holy;

-- Items
if not Item.Priest then Item.Priest = {} end
Item.Priest.Holy = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Priest.Holy;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Priest.Commons,
  Holy = HR.GUISettings.APL.Priest.Holy
};

-- Variables

local EnemyRanges = {40}
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
  local Precombat
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
    -- smite
    if S.Smite:IsCastableP() then
      if HR.Cast(S.Smite) then return "smite 6"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- use_items
    -- potion,if=buff.bloodlust.react|target.time_to_die<=80
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 80) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 10"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 12"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 14"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 16"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 18"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 20"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 22"; end
    end
    -- holy_fire,if=refreshable&dot.holy_fire.ticking&dot.holy_fire.stack>1|dot.holy_fire.stack<2
    if S.HolyFire:IsCastableP() and (bool(refreshable) and Target:DebuffP(S.HolyFireDebuff) and Target:DebuffStackP(S.HolyFireDebuff) > 1 or Target:DebuffStackP(S.HolyFireDebuff) < 2) then
      if HR.Cast(S.HolyFire) then return "holy_fire 24"; end
    end
    -- holy_word_chastise
    if S.HolyWordChastise:IsCastableP() then
      if HR.Cast(S.HolyWordChastise) then return "holy_word_chastise 36"; end
    end
    -- apotheosis
    if S.Apotheosis:IsCastableP() then
      if HR.Cast(S.Apotheosis) then return "apotheosis 38"; end
    end
    -- divine_star
    if S.DivineStar:IsCastableP() then
      if HR.Cast(S.DivineStar) then return "divine_star 40"; end
    end
    -- halo,if=!dot.holy_fire.stack=2
    if S.Halo:IsCastableP() and (num(not bool(Target:DebuffStackP(S.HolyFireDebuff))) == 2) then
      if HR.Cast(S.Halo) then return "halo 42"; end
    end
    -- holy_nova,if=active_enemies>2
    if S.HolyNova:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.HolyNova) then return "holy_nova 46"; end
    end
    -- smite
    if S.Smite:IsCastableP() then
      if HR.Cast(S.Smite) then return "smite 54"; end
    end
  end
end

HR.SetAPL(257, APL)
