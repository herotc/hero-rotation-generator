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
  PrimalInstincts                       = Spell(),
  BestialWrathBuff                      = Spell(19574),
  BestialWrath                          = Spell(19574),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  BarbedShot                            = Spell(),
  FrenzyBuff                            = Spell(),
  AMurderofCrows                        = Spell(131894),
  SpittingCobra                         = Spell(),
  Stampede                              = Spell(201430),
  Multishot                             = Spell(2643),
  BeastCleaveBuff                       = Spell(118455, "pet"),
  Barrage                               = Spell(120360),
  ChimaeraShot                          = Spell(53209),
  KillCommand                           = Spell(34026),
  DireBeast                             = Spell(120679),
  CobraShot                             = Spell(193455),
  ArcaneTorrent                         = Spell(50613)
};
local S = Spell.Hunter.BeastMastery;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.BeastMastery = {
  ProlongedPower                   = Item(142117)
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
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet) then return "summon_pet 3"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 6"; end
    end
    -- aspect_of_the_wild,if=!azerite.primal_instincts.enabled
    if S.AspectoftheWild:IsCastableP() and Player:BuffDownP(S.AspectoftheWildBuff) and (not S.PrimalInstincts:AzeriteEnabled()) then
      if HR.Cast(S.AspectoftheWild) then return "aspect_of_the_wild 8"; end
    end
    -- bestial_wrath,if=azerite.primal_instincts.enabled
    if S.BestialWrath:IsCastableP() and Player:BuffDownP(S.BestialWrathBuff) and (S.PrimalInstincts:AzeriteEnabled()) then
      if HR.Cast(S.BestialWrath) then return "bestial_wrath 14"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_items
    -- berserking,if=cooldown.bestial_wrath.remains>30
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 23"; end
    end
    -- blood_fury,if=cooldown.bestial_wrath.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 27"; end
    end
    -- ancestral_call,if=cooldown.bestial_wrath.remains>30
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 31"; end
    end
    -- fireblood,if=cooldown.bestial_wrath.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 35"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 39"; end
    end
    -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.BestialWrathBuff) and Player:BuffP(S.AspectoftheWildBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 41"; end
    end
    -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
    if S.BarbedShot:IsCastableP() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD()) then
      if HR.Cast(S.BarbedShot) then return "barbed_shot 47"; end
    end
    -- a_murder_of_crows,if=active_enemies=1
    if S.AMurderofCrows:IsCastableP() and (Cache.EnemiesCount[40] == 1) then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 53"; end
    end
    -- barbed_shot,if=full_recharge_time<gcd.max&cooldown.bestial_wrath.remains
    if S.BarbedShot:IsCastableP() and (S.BarbedShot:FullRechargeTimeP() < Player:GCD() and bool(S.BestialWrath:CooldownRemainsP())) then
      if HR.Cast(S.BarbedShot) then return "barbed_shot 61"; end
    end
    -- spitting_cobra
    if S.SpittingCobra:IsCastableP() then
      if HR.Cast(S.SpittingCobra) then return "spitting_cobra 69"; end
    end
    -- stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
    if S.Stampede:IsCastableP() and (Player:BuffP(S.BestialWrathBuff) or S.BestialWrath:CooldownRemainsP() < Player:GCD() or Target:TimeToDie() < 15) then
      if HR.Cast(S.Stampede) then return "stampede 71"; end
    end
    -- aspect_of_the_wild
    if S.AspectoftheWild:IsCastableP() then
      if HR.Cast(S.AspectoftheWild) then return "aspect_of_the_wild 77"; end
    end
    -- multishot,if=spell_targets>2&gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and Player:GCD() - Pet:BuffRemainsP(S.BeastCleaveBuff) > 0.25) then
      if HR.Cast(S.Multishot) then return "multishot 79"; end
    end
    -- bestial_wrath,if=!buff.bestial_wrath.up
    if S.BestialWrath:IsCastableP() and (not Player:BuffP(S.BestialWrathBuff)) then
      if HR.Cast(S.BestialWrath) then return "bestial_wrath 89"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return "barrage 93"; end
    end
    -- chimaera_shot,if=spell_targets>1
    if S.ChimaeraShot:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChimaeraShot) then return "chimaera_shot 101"; end
    end
    -- multishot,if=spell_targets>1&gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Player:GCD() - Pet:BuffRemainsP(S.BeastCleaveBuff) > 0.25) then
      if HR.Cast(S.Multishot) then return "multishot 109"; end
    end
    -- kill_command
    if S.KillCommand:IsCastableP() then
      if HR.Cast(S.KillCommand) then return "kill_command 119"; end
    end
    -- chimaera_shot
    if S.ChimaeraShot:IsCastableP() then
      if HR.Cast(S.ChimaeraShot) then return "chimaera_shot 121"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 123"; end
    end
    -- dire_beast
    if S.DireBeast:IsCastableP() then
      if HR.Cast(S.DireBeast) then return "dire_beast 125"; end
    end
    -- barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.8|target.time_to_die<9
    if S.BarbedShot:IsCastableP() and (Pet:BuffDownP(S.FrenzyBuff) and S.BarbedShot:ChargesFractionalP() > 1.8 or Target:TimeToDie() < 9) then
      if HR.Cast(S.BarbedShot) then return "barbed_shot 127"; end
    end
    -- barrage
    if S.Barrage:IsCastableP() then
      if HR.Cast(S.Barrage) then return "barrage 135"; end
    end
    -- cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost|cooldown.kill_command.remains>1+gcd)&cooldown.kill_command.remains>1
    if S.CobraShot:IsCastableP() and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) and (Player:Focus() - S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemainsP() - 1) > S.KillCommand:Cost() or S.KillCommand:CooldownRemainsP() > 1 + Player:GCD()) and S.KillCommand:CooldownRemainsP() > 1) then
      if HR.Cast(S.CobraShot) then return "cobra_shot 137"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 161"; end
    end
  end
end

HR.SetAPL(253, APL)
