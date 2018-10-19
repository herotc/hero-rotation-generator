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
  HolyFire                              = Spell(),
  HolyFireDebuff                        = Spell(),
  HolyWordChastise                      = Spell(),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  DivineStar                            = Spell(),
  Halo                                  = Spell(),
  LightsJudgment                        = Spell(255647),
  ArcanePulse                           = Spell(),
  HolyNova                              = Spell(),
  Apotheosis                            = Spell()
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


local EnemyRanges = {40, 5}
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
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- use_items
    -- potion,if=buff.bloodlust.react|(raid_event.adds.up&(raid_event.adds.remains>20|raid_event.adds.duration<20))|target.time_to_die<=30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or ((Cache.EnemiesCount[40] > 1) and (0 > 20 or raid_event.adds.duration < 20)) or Target:TimeToDie() <= 30) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 10"; end
    end
    -- holy_fire,if=dot.holy_fire.ticking&(dot.holy_fire.remains<=gcd|dot.holy_fire.stack<2)&spell_targets.holy_nova<7
    if S.HolyFire:IsCastableP() and (Target:DebuffP(S.HolyFireDebuff) and (Target:DebuffRemainsP(S.HolyFireDebuff) <= Player:GCD() or Target:DebuffStackP(S.HolyFireDebuff) < 2) and Cache.EnemiesCount[5] < 7) then
      if HR.Cast(S.HolyFire) then return "holy_fire 14"; end
    end
    -- holy_word_chastise,if=spell_targets.holy_nova<5
    if S.HolyWordChastise:IsCastableP() and (Cache.EnemiesCount[5] < 5) then
      if HR.Cast(S.HolyWordChastise) then return "holy_word_chastise 22"; end
    end
    -- holy_fire,if=dot.holy_fire.ticking&(dot.holy_fire.refreshable|dot.holy_fire.stack<2)&spell_targets.holy_nova<7
    if S.HolyFire:IsCastableP() and (Target:DebuffP(S.HolyFireDebuff) and (Target:DebuffRefreshableCP(S.HolyFireDebuff) or Target:DebuffStackP(S.HolyFireDebuff) < 2) and Cache.EnemiesCount[5] < 7) then
      if HR.Cast(S.HolyFire) then return "holy_fire 24"; end
    end
    -- berserking,if=raid_event.adds.in>30|raid_event.adds.remains>8|raid_event.adds.duration<8
    if S.Berserking:IsCastableP() and HR.CDsON() and (10000000000 > 30 or 0 > 8 or raid_event.adds.duration < 8) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 32"; end
    end
    -- fireblood,if=raid_event.adds.in>20|raid_event.adds.remains>6|raid_event.adds.duration<6
    if S.Fireblood:IsCastableP() and HR.CDsON() and (10000000000 > 20 or 0 > 6 or raid_event.adds.duration < 6) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 34"; end
    end
    -- ancestral_call,if=raid_event.adds.in>20|raid_event.adds.remains>10|raid_event.adds.duration<10
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (10000000000 > 20 or 0 > 10 or raid_event.adds.duration < 10) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 36"; end
    end
    -- divine_star,if=(raid_event.adds.in>5|raid_event.adds.remains>2|raid_event.adds.duration<2)&spell_targets.divine_star>1
    if S.DivineStar:IsCastableP() and ((10000000000 > 5 or 0 > 2 or raid_event.adds.duration < 2) and Cache.EnemiesCount[5] > 1) then
      if HR.Cast(S.DivineStar) then return "divine_star 38"; end
    end
    -- halo,if=(raid_event.adds.in>14|raid_event.adds.remains>2|raid_event.adds.duration<2)&spell_targets.halo>0
    if S.Halo:IsCastableP() and ((10000000000 > 14 or 0 > 2 or raid_event.adds.duration < 2) and Cache.EnemiesCount[5] > 0) then
      if HR.Cast(S.Halo) then return "halo 40"; end
    end
    -- lights_judgment,if=raid_event.adds.in>50|raid_event.adds.remains>4|raid_event.adds.duration<4
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (10000000000 > 50 or 0 > 4 or raid_event.adds.duration < 4) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 42"; end
    end
    -- arcane_pulse,if=(raid_event.adds.in>40|raid_event.adds.remains>2|raid_event.adds.duration<2)&spell_targets.arcane_pulse>2
    if S.ArcanePulse:IsCastableP() and ((10000000000 > 40 or 0 > 2 or raid_event.adds.duration < 2) and Cache.EnemiesCount[5] > 2) then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 44"; end
    end
    -- holy_fire,if=!dot.holy_fire.ticking&spell_targets.holy_nova<7
    if S.HolyFire:IsCastableP() and (not Target:DebuffP(S.HolyFireDebuff) and Cache.EnemiesCount[5] < 7) then
      if HR.Cast(S.HolyFire) then return "holy_fire 46"; end
    end
    -- holy_nova,if=spell_targets.holy_nova>3
    if S.HolyNova:IsCastableP() and (Cache.EnemiesCount[5] > 3) then
      if HR.Cast(S.HolyNova) then return "holy_nova 50"; end
    end
    -- apotheosis,if=active_enemies<5&(raid_event.adds.in>15|raid_event.adds.in>raid_event.adds.cooldown-5)
    if S.Apotheosis:IsCastableP() and (Cache.EnemiesCount[40] < 5 and (10000000000 > 15 or 10000000000 > raid_event.adds.cooldown - 5)) then
      if HR.Cast(S.Apotheosis) then return "apotheosis 52"; end
    end
    -- smite
    if S.Smite:IsCastableP() then
      if HR.Cast(S.Smite) then return "smite 60"; end
    end
    -- holy_fire
    if S.HolyFire:IsCastableP() then
      if HR.Cast(S.HolyFire) then return "holy_fire 62"; end
    end
    -- divine_star,if=(raid_event.adds.in>5|raid_event.adds.remains>2|raid_event.adds.duration<2)&spell_targets.divine_star>0
    if S.DivineStar:IsCastableP() and ((10000000000 > 5 or 0 > 2 or raid_event.adds.duration < 2) and Cache.EnemiesCount[5] > 0) then
      if HR.Cast(S.DivineStar) then return "divine_star 64"; end
    end
    -- holy_nova,if=raid_event.movement.remains>gcd*0.3&spell_targets.holy_nova>0
    if S.HolyNova:IsCastableP() and (raid_event.movement.remains > Player:GCD() * 0.3 and Cache.EnemiesCount[5] > 0) then
      if HR.Cast(S.HolyNova) then return "holy_nova 66"; end
    end
  end
end

HR.SetAPL(257, APL)
