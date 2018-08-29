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
  SummonPet                             = Spell(),
  HuntersMarkDebuff                     = Spell(185365),
  HuntersMark                           = Spell(),
  DoubleTap                             = Spell(),
  AimedShot                             = Spell(19434),
  ExplosiveShot                         = Spell(212431),
  RapidFire                             = Spell(),
  Berserking                            = Spell(26297),
  Trueshot                              = Spell(193526),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  TrueshotBuff                          = Spell(193526),
  ProlongedPowerBuff                    = Spell(229206),
  Barrage                               = Spell(120360),
  ArcaneShot                            = Spell(185358),
  PreciseShotsBuff                      = Spell(),
  LethalShotsBuff                       = Spell(),
  LethalShots                           = Spell(),
  FocusedFire                           = Spell(),
  IntheRhythm                           = Spell(),
  DoubleTapBuff                         = Spell(),
  PiercingShot                          = Spell(198670),
  AMurderofCrows                        = Spell(131894),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  SteadyFocus                           = Spell(),
  SteadyShot                            = Spell(),
  TrickShotsBuff                        = Spell(),
  Multishot                             = Spell(2643),
  SteadyFocusBuff                       = Spell()
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  ProlongedPower                   = Item(142117)
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
  local Precombat, Cds, St, Trickshots
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet,if=active_enemies<3
    if S.SummonPet:IsCastableP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.SummonPet) then return ""; end
    end
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
  Cds = function()
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
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
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
    -- trueshot,if=cooldown.aimed_shot.charges<1|talent.barrage.enabled&cooldown.aimed_shot.charges_fractional<1.3
    if S.Trueshot:IsCastableP() and (S.AimedShot:ChargesP() < 1 or S.Barrage:IsAvailable() and S.AimedShot:ChargesFractional() < 1.3) then
      if HR.Cast(S.Trueshot) then return ""; end
    end
  end
  St = function()
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return ""; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return ""; end
    end
    -- arcane_shot,if=buff.precise_shots.up&(cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time|buff.lethal_shots.up)
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.PreciseShotsBuff) and (S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime() or Player:BuffP(S.LethalShotsBuff))) then
      if HR.Cast(S.ArcaneShot) then return ""; end
    end
    -- rapid_fire,if=(!talent.lethal_shots.enabled|buff.lethal_shots.up)&azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1
    if S.RapidFire:IsCastableP() and ((not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff)) and S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1) then
      if HR.Cast(S.RapidFire) then return ""; end
    end
    -- aimed_shot,if=buff.precise_shots.down&(buff.double_tap.down&full_recharge_time<cast_time+gcd|buff.lethal_shots.up)
    if S.AimedShot:IsCastableP() and (Player:BuffDownP(S.PreciseShotsBuff) and (Player:BuffDownP(S.DoubleTapBuff) and S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() + Player:GCD() or Player:BuffP(S.LethalShotsBuff))) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- rapid_fire,if=!talent.lethal_shots.enabled|buff.lethal_shots.up
    if S.RapidFire:IsCastableP() and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff)) then
      if HR.Cast(S.RapidFire) then return ""; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return ""; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return ""; end
    end
    -- aimed_shot,if=buff.precise_shots.down&(!talent.steady_focus.enabled&focus>70|!talent.lethal_shots.enabled|buff.lethal_shots.up)
    if S.AimedShot:IsCastableP() and (Player:BuffDownP(S.PreciseShotsBuff) and (not S.SteadyFocus:IsAvailable() and Player:Focus() > 70 or not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff))) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- arcane_shot,if=buff.precise_shots.up|focus>60&(!talent.lethal_shots.enabled|buff.lethal_shots.up)
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.PreciseShotsBuff) or Player:Focus() > 60 and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff))) then
      if HR.Cast(S.ArcaneShot) then return ""; end
    end
    -- steady_shot,if=focus+cast_regen<focus.max|(talent.lethal_shots.enabled&buff.lethal_shots.down)
    if S.SteadyShot:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteadyShot:ExecuteTime()) < Player:FocusMax() or (S.LethalShots:IsAvailable() and Player:BuffDownP(S.LethalShotsBuff))) then
      if HR.Cast(S.SteadyShot) then return ""; end
    end
    -- arcane_shot
    if S.ArcaneShot:IsCastableP() then
      if HR.Cast(S.ArcaneShot) then return ""; end
    end
  end
  Trickshots = function()
    -- barrage
    if S.Barrage:IsCastableP() then
      if HR.Cast(S.Barrage) then return ""; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return ""; end
    end
    -- rapid_fire,if=buff.trick_shots.up&!talent.barrage.enabled
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and not S.Barrage:IsAvailable()) then
      if HR.Cast(S.RapidFire) then return ""; end
    end
    -- aimed_shot,if=buff.trick_shots.up&buff.precise_shots.down&buff.double_tap.down&(!talent.lethal_shots.enabled|buff.lethal_shots.up|focus>60)
    if S.AimedShot:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and Player:BuffDownP(S.PreciseShotsBuff) and Player:BuffDownP(S.DoubleTapBuff) and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff) or Player:Focus() > 60)) then
      if HR.Cast(S.AimedShot) then return ""; end
    end
    -- rapid_fire,if=buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return ""; end
    end
    -- multishot,if=buff.trick_shots.down|(buff.precise_shots.up|buff.lethal_shots.up)&(!talent.barrage.enabled&buff.steady_focus.down&focus>45|focus>70)
    if S.Multishot:IsCastableP() and (Player:BuffDownP(S.TrickShotsBuff) or (Player:BuffP(S.PreciseShotsBuff) or Player:BuffP(S.LethalShotsBuff)) and (not S.Barrage:IsAvailable() and Player:BuffDownP(S.SteadyFocusBuff) and Player:Focus() > 45 or Player:Focus() > 70)) then
      if HR.Cast(S.Multishot) then return ""; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return ""; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return ""; end
    end
    -- steady_shot,if=focus+cast_regen<focus.max|(talent.lethal_shots.enabled&buff.lethal_shots.down)
    if S.SteadyShot:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteadyShot:ExecuteTime()) < Player:FocusMax() or (S.LethalShots:IsAvailable() and Player:BuffDownP(S.LethalShotsBuff))) then
      if HR.Cast(S.SteadyShot) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_items
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3
    if (Cache.EnemiesCount[40] < 3) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=trickshots,if=active_enemies>2
    if (Cache.EnemiesCount[40] > 2) then
      local ShouldReturn = Trickshots(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(254, APL)
