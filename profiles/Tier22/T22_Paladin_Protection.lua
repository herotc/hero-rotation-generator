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
if not Spell.Paladin then Spell.Paladin = {} end
Spell.Paladin.Protection = {
  Fireblood                             = Spell(265221),
  AvengingWrathBuff                     = Spell(31884),
  Seraphim                              = Spell(152262),
  ShieldoftheRighteous                  = Spell(53600),
  AvengingWrath                         = Spell(31884),
  SeraphimBuff                          = Spell(152262),
  AvengersValorBuff                     = Spell(),
  AvengerShield                         = Spell(),
  LightsJudgment                        = Spell(255647),
  AvengersShield                        = Spell(31935),
  Judgment                              = Spell(20271),
  CrusadersJudgment                     = Spell(),
  Consecration                          = Spell(26573),
  BlessedHammer                         = Spell(204019),
  HammeroftheRighteous                  = Spell(53595)
};
local S = Spell.Paladin.Protection;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Protection = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Paladin.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Paladin.Commons,
  Protection = HR.GUISettings.APL.Paladin.Protection
};

-- Variables

local EnemyRanges = {30}
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
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4205"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- fireblood,if=buff.avenging_wrath.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 4209"; end
    end
    -- seraphim,if=cooldown.shield_of_the_righteous.charges_fractional>=2
    if S.Seraphim:IsCastableP() and (S.ShieldoftheRighteous:ChargesFractionalP() >= 2) then
      if HR.Cast(S.Seraphim) then return "seraphim 4213"; end
    end
    -- avenging_wrath,if=buff.seraphim.up|cooldown.seraphim.remains<2|!talent.seraphim.enabled
    if S.AvengingWrath:IsCastableP() and (Player:BuffP(S.SeraphimBuff) or S.Seraphim:CooldownRemainsP() < 2 or not S.Seraphim:IsAvailable()) then
      if HR.Cast(S.AvengingWrath) then return "avenging_wrath 4217"; end
    end
    -- potion,if=buff.avenging_wrath.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4225"; end
    end
    -- shield_of_the_righteous,if=(buff.avengers_valor.up&cooldown.shield_of_the_righteous.charges_fractional>=2.5)&(cooldown.seraphim.remains>gcd|!talent.seraphim.enabled)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengersValorBuff) and S.ShieldoftheRighteous:ChargesFractionalP() >= 2.5) and (S.Seraphim:CooldownRemainsP() > Player:GCD() or not S.Seraphim:IsAvailable())) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 4229"; end
    end
    -- shield_of_the_righteous,if=(cooldown.shield_of_the_righteous.charges_fractional=3&cooldown.avenger_shield.remains>(2*gcd))
    if S.ShieldoftheRighteous:IsCastableP() and ((S.ShieldoftheRighteous:ChargesFractionalP() == 3 and S.AvengerShield:CooldownRemainsP() > (2 * Player:GCD()))) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 4239"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&!talent.seraphim.enabled)|buff.seraphim.up&buff.avengers_valor.up
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and not S.Seraphim:IsAvailable()) or Player:BuffP(S.SeraphimBuff) and Player:BuffP(S.AvengersValorBuff)) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 4245"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&buff.avenging_wrath.remains<4&!talent.seraphim.enabled)|(buff.seraphim.remains<4&buff.seraphim.up)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and Player:BuffRemainsP(S.AvengingWrathBuff) < 4 and not S.Seraphim:IsAvailable()) or (Player:BuffRemainsP(S.SeraphimBuff) < 4 and Player:BuffP(S.SeraphimBuff))) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 4255"; end
    end
    -- use_items,if=buff.seraphim.up|!talent.seraphim.enabled
    -- lights_judgment,if=buff.seraphim.up&buff.seraphim.remains<3
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SeraphimBuff) and Player:BuffRemainsP(S.SeraphimBuff) < 3) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 4268"; end
    end
    -- avengers_shield,if=((cooldown.shield_of_the_righteous.charges_fractional>2.5&!buff.avengers_valor.up)|active_enemies>=2)&cooldown_react
    if S.AvengersShield:IsCastableP() and (((S.ShieldoftheRighteous:ChargesFractionalP() > 2.5 and not Player:BuffP(S.AvengersValorBuff)) or Cache.EnemiesCount[30] >= 2) and S.AvengersShield:CooldownUpP()) then
      if HR.Cast(S.AvengersShield) then return "avengers_shield 4274"; end
    end
    -- judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and ((S.Judgment:CooldownRemainsP() < Player:GCD() and S.Judgment:ChargesFractionalP() > 1 and S.Judgment:CooldownUpP()) or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 4290"; end
    end
    -- avengers_shield,,if=cooldown_react
    if S.AvengersShield:IsCastableP() and (S.AvengersShield:CooldownUpP()) then
      if HR.Cast(S.AvengersShield) then return "avengers_shield 4302"; end
    end
    -- consecration,if=(cooldown.judgment.remains<=gcd&!talent.crusaders_judgment.enabled)|cooldown.avenger_shield.remains<=gcd&consecration.remains<gcd
    if S.Consecration:IsCastableP() and ((S.Judgment:CooldownRemainsP() <= Player:GCD() and not S.CrusadersJudgment:IsAvailable()) or S.AvengerShield:CooldownRemainsP() <= Player:GCD() and consecration.remains < Player:GCD()) then
      if HR.Cast(S.Consecration) then return "consecration 4308"; end
    end
    -- consecration,if=!talent.crusaders_judgment.enabled&consecration.remains<(cooldown.judgment.remains+cooldown.avengers_shield.remains)&consecration.remains<3*gcd
    if S.Consecration:IsCastableP() and (not S.CrusadersJudgment:IsAvailable() and consecration.remains < (S.Judgment:CooldownRemainsP() + S.AvengersShield:CooldownRemainsP()) and consecration.remains < 3 * Player:GCD()) then
      if HR.Cast(S.Consecration) then return "consecration 4316"; end
    end
    -- judgment,if=cooldown_react|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and (S.Judgment:CooldownUpP() or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 4324"; end
    end
    -- lights_judgment,if=!talent.seraphim.enabled|buff.seraphim.up
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (not S.Seraphim:IsAvailable() or Player:BuffP(S.SeraphimBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 4332"; end
    end
    -- blessed_hammer
    if S.BlessedHammer:IsCastableP() then
      if HR.Cast(S.BlessedHammer) then return "blessed_hammer 4338"; end
    end
    -- hammer_of_the_righteous
    if S.HammeroftheRighteous:IsCastableP() then
      if HR.Cast(S.HammeroftheRighteous) then return "hammer_of_the_righteous 4340"; end
    end
    -- consecration
    if S.Consecration:IsCastableP() then
      if HR.Cast(S.Consecration) then return "consecration 4342"; end
    end
  end
end

HR.SetAPL(66, APL)
