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
Spell.Hunter.Marksmanship = {
  HuntersMarkDebuff                     = Spell(185365),
  HuntersMark                           = Spell(),
  DoubleTap                             = Spell(),
  AimedShot                             = Spell(19434),
  ExplosiveShot                         = Spell(212431),
  CounterShot                           = Spell(147362),
  BuffSephuzsSecret                     = Spell(),
  SephuzsSecretBuff                     = Spell(208052),
  RapidFire                             = Spell(),
  Berserking                            = Spell(26297),
  Trueshot                              = Spell(193526),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  TrueshotBuff                          = Spell(193526),
  ProlongedPowerBuff                    = Spell(229206),
  Barrage                               = Spell(120360),
  Multishot                             = Spell(2643),
  PreciseShotsBuff                      = Spell(),
  ArcaneShot                            = Spell(185358),
  DoubleTapBuff                         = Spell(),
  TrickShotsBuff                        = Spell(),
  PiercingShot                          = Spell(198670),
  AMurderofCrows                        = Spell(131894),
  SteadyFocusBuff                       = Spell(),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  SteadyShot                            = Spell()
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  ProlongedPower                   = Item(142117),
  SephuzsSecret                    = Item(132452)
};
local I = Item.Hunter.Marksmanship;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  Marksmanship = HR.GUISettings.APL.Hunter.Marksmanship
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

local function TargetDebuffRemainsP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability and (S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true)) then
    return 7;
  else
    return DebuffRemainsP(Spell);
  end
end

local function TargetDebuffP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability then
    return DebuffP(Spell) or S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true);
  elseif Spell == S.HuntersMark then
    return DebuffP(Spell) or S.ArcaneShot:InFlight(S.MarkingTargets) or S.MultiShot:InFlight(S.MarkingTargets) or S.Sidewinders:InFlight(S.MarkingTargets);
  else
    return DebuffP(Spell);
  end
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
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- hunters_mark
    if S.HuntersMark:IsCastableP() and Player:DebuffDownP(S.HuntersMarkDebuff) then
      if HR.Cast(S.HuntersMark) then return ""; end
    end
    -- double_tap,precast_time=5
    if S.DoubleTap:IsCastableP() then
      if HR.Cast(S.DoubleTap) then return ""; end
    end
    -- aimed_shot,if=active_enemies<3
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- explosive_shot,if=active_enemies>2
    if S.ExplosiveShot:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.ExplosiveShot) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
    if S.CounterShot:IsCastableP() and (I.SephuzsSecret:IsEquipped() and Target:IsCasting() and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
      if HR.Cast(S.CounterShot) then return ""; end
    end
    -- use_items
    -- hunters_mark,if=debuff.hunters_mark.down
    if S.HuntersMark:IsCastableP() and (Target:DebuffDownP(S.HuntersMarkDebuff)) then
      if HR.Cast(S.HuntersMark) then return ""; end
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd
    if S.DoubleTap:IsCastableP() and (S.RapidFire:CooldownRemainsP() < Player:GCD()) then
      if HR.Cast(S.DoubleTap) then return ""; end
    end
    -- berserking,if=cooldown.trueshot.remains>30
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- blood_fury,if=cooldown.trueshot.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- ancestral_call,if=cooldown.trueshot.remains>30
    if S.AncestralCall:IsCastableP() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall) then return ""; end
    end
    -- fireblood,if=cooldown.trueshot.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return ""; end
    end
    -- potion,if=(buff.trueshot.react&buff.bloodlust.react)|((consumable.prolonged_power&target.time_to_die<62)|target.time_to_die<31)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((bool(Player:BuffStackP(S.TrueshotBuff)) and Player:HasHeroism()) or ((Player:Buff(S.ProlongedPowerBuff) and Target:TimeToDie() < 62) or Target:TimeToDie() < 31)) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- trueshot,if=cooldown.aimed_shot.charges<1
    if S.Trueshot:IsCastableP() and (S.AimedShot:ChargesP() < 1) then
      if HR.Cast(S.Trueshot) then return ""; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return ""; end
    end
    -- explosive_shot,if=active_enemies>1
    if S.ExplosiveShot:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ExplosiveShot) then return ""; end
    end
    -- multishot,if=active_enemies>2&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
      if HR.Cast(S.Multishot) then return ""; end
    end
    -- arcane_shot,if=active_enemies<3&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
    if S.ArcaneShot:IsCastableP() and (Cache.EnemiesCount[40] < 3 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
      if HR.Cast(S.ArcaneShot) then return ""; end
    end
    -- aimed_shot,if=buff.precise_shots.down&buff.double_tap.down&(active_enemies>2&buff.trick_shots.up|active_enemies<3&full_recharge_time<cast_time+gcd)
    if S.AimedShot:IsCastableP() and (Player:BuffDownP(S.PreciseShotsBuff) and Player:BuffDownP(S.DoubleTapBuff) and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.TrickShotsBuff) or Cache.EnemiesCount[40] < 3 and S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() + Player:GCD())) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- rapid_fire,if=active_enemies<3|buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Cache.EnemiesCount[40] < 3 or Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return ""; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return ""; end
    end
    -- barrage
    if S.Barrage:IsCastableP() then
      if HR.Cast(S.Barrage) then return ""; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return ""; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- multishot,if=active_enemies>2&buff.trick_shots.down
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and Player:BuffDownP(S.TrickShotsBuff)) then
      if HR.Cast(S.Multishot) then return ""; end
    end
    -- aimed_shot,if=buff.precise_shots.down&(focus>70|buff.steady_focus.down)
    if S.AimedShot:IsCastableP() and (Player:BuffDownP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff))) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- multishot,if=active_enemies>2&(focus>90|buff.precise_shots.up&(focus>70|buff.steady_focus.down&focus>45))
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and (Player:Focus() > 90 or Player:BuffP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and Player:Focus() > 45))) then
      if HR.Cast(S.Multishot) then return ""; end
    end
    -- arcane_shot,if=active_enemies<3&(focus>70|buff.steady_focus.down&(focus>60|buff.precise_shots.up))
    if S.ArcaneShot:IsCastableP() and (Cache.EnemiesCount[40] < 3 and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and (Player:Focus() > 60 or Player:BuffP(S.PreciseShotsBuff)))) then
      if HR.Cast(S.ArcaneShot) then return ""; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return ""; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return ""; end
    end
  end
end

HR.SetAPL(254, APL)
