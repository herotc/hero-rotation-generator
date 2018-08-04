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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.BeastMastery = {
  SummonPet                             = Spell(),
  AspectoftheWildBuff                   = Spell(193530),
  AspectoftheWild                       = Spell(193530),
  CounterShot                           = Spell(147362),
  BuffSephuzsSecret                     = Spell(),
  SephuzsSecretBuff                     = Spell(208052),
  Berserking                            = Spell(26297),
  BestialWrath                          = Spell(19574),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  BestialWrathBuff                      = Spell(19574),
  BarbedShot                            = Spell(),
  FrenzyBuff                            = Spell(),
  AMurderofCrows                        = Spell(131894),
  SpittingCobra                         = Spell(),
  Stampede                              = Spell(201430),
  Multishot                             = Spell(2643),
  BeastCleaveBuff                       = Spell(118455, "pet"),
  ChimaeraShot                          = Spell(53209),
  KillCommand                           = Spell(34026),
  DireBeast                             = Spell(120679),
  Barrage                               = Spell(120360),
  CobraShot                             = Spell(193455)
};
local S = Spell.Hunter.BeastMastery;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.BeastMastery = {
  ProlongedPower                   = Item(142117),
  SephuzsSecret                    = Item(132452)
};
local I = Item.Hunter.BeastMastery;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  BeastMastery = HR.GUISettings.APL.Hunter.BeastMastery
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
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() and (true) then
      if HR.Cast(S.SummonPet) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- aspect_of_the_wild
    if S.AspectoftheWild:IsCastableP() and Player:BuffDownP(S.AspectoftheWildBuff) and (true) then
      if HR.Cast(S.AspectoftheWild) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_shot
  -- counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
  if S.CounterShot:IsCastableP() and (I.SephuzsSecret:IsEquipped() and Target:IsCasting() and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
    if HR.Cast(S.CounterShot) then return ""; end
  end
  -- use_items
  -- berserking,if=cooldown.bestial_wrath.remains>30
  if S.Berserking:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
    if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- blood_fury,if=cooldown.bestial_wrath.remains>30
  if S.BloodFury:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
    if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- ancestral_call,if=cooldown.bestial_wrath.remains>30
  if S.AncestralCall:IsCastableP() and (S.BestialWrath:CooldownRemainsP() > 30) then
    if HR.Cast(S.AncestralCall) then return ""; end
  end
  -- fireblood,if=cooldown.bestial_wrath.remains>30
  if S.Fireblood:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
    if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- lights_judgment
  if S.LightsJudgment:IsCastableP() and HR.CDsON() and (true) then
    if HR.Cast(S.LightsJudgment) then return ""; end
  end
  -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.BestialWrathBuff) and Player:BuffP(S.AspectoftheWildBuff)) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
  if S.BarbedShot:IsCastableP() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD()) then
    if HR.Cast(S.BarbedShot) then return ""; end
  end
  -- a_murder_of_crows
  if S.AMurderofCrows:IsCastableP() and (true) then
    if HR.Cast(S.AMurderofCrows) then return ""; end
  end
  -- spitting_cobra
  if S.SpittingCobra:IsCastableP() and (true) then
    if HR.Cast(S.SpittingCobra) then return ""; end
  end
  -- stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
  if S.Stampede:IsCastableP() and (Player:BuffP(S.BestialWrathBuff) or S.BestialWrath:CooldownRemainsP() < Player:GCD() or Target:TimeToDie() < 15) then
    if HR.Cast(S.Stampede) then return ""; end
  end
  -- aspect_of_the_wild
  if S.AspectoftheWild:IsCastableP() and (true) then
    if HR.Cast(S.AspectoftheWild) then return ""; end
  end
  -- bestial_wrath,if=!buff.bestial_wrath.up
  if S.BestialWrath:IsCastableP() and (not Player:BuffP(S.BestialWrathBuff)) then
    if HR.Cast(S.BestialWrath) then return ""; end
  end
  -- multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
  if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
    if HR.Cast(S.Multishot) then return ""; end
  end
  -- chimaera_shot
  if S.ChimaeraShot:IsCastableP() and (true) then
    if HR.Cast(S.ChimaeraShot) then return ""; end
  end
  -- kill_command
  if S.KillCommand:IsCastableP() and (true) then
    if HR.Cast(S.KillCommand) then return ""; end
  end
  -- dire_beast
  if S.DireBeast:IsCastableP() and (true) then
    if HR.Cast(S.DireBeast) then return ""; end
  end
  -- barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
  if S.BarbedShot:IsCastableP() and (Pet:BuffDownP(S.FrenzyBuff) and S.BarbedShot:ChargesFractional() > 1.4 or S.BarbedShot:FullRechargeTimeP() < Player:GCD() or Target:TimeToDie() < 9) then
    if HR.Cast(S.BarbedShot) then return ""; end
  end
  -- barrage
  if S.Barrage:IsCastableP() and (true) then
    if HR.Cast(S.Barrage) then return ""; end
  end
  -- multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
  if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
    if HR.Cast(S.Multishot) then return ""; end
  end
  -- cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
  if S.CobraShot:IsCastableP() and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) and (Player:BuffP(S.BestialWrathBuff) and Cache.EnemiesCount[40] > 1 or S.KillCommand:CooldownRemainsP() > 1 + Player:GCD() and S.BestialWrath:CooldownRemainsP() > Player:FocusTimeToMaxPredicted() or Player:Focus() - S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemainsP() - 1) > S.KillCommand:Cost())) then
    if HR.Cast(S.CobraShot) then return ""; end
  end
end

HR.SetAPL(253, APL)
