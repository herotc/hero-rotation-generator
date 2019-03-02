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
  HuntersMarkDebuff                     = Spell(257284),
  HuntersMark                           = Spell(257284),
  DoubleTap                             = Spell(260402),
  TrueshotBuff                          = Spell(288613),
  Trueshot                              = Spell(288613),
  AimedShot                             = Spell(19434),
  UnerringVisionBuff                    = Spell(274447),
  UnerringVision                        = Spell(274444),
  CallingtheShots                       = Spell(260404),
  SurgingShots                          = Spell(287707),
  Streamline                            = Spell(260367),
  FocusedFire                           = Spell(278531),
  RapidFire                             = Spell(257044),
  Berserking                            = Spell(26297),
  BerserkingBuff                        = Spell(26297),
  CarefulAim                            = Spell(260228),
  BloodFury                             = Spell(20572),
  BloodFuryBuff                         = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  ExplosiveShot                         = Spell(212431),
  Barrage                               = Spell(120360),
  AMurderofCrows                        = Spell(131894),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  ArcaneShot                            = Spell(185358),
  MasterMarksmanBuff                    = Spell(269576),
  PreciseShotsBuff                      = Spell(260242),
  IntheRhythm                           = Spell(264198),
  PiercingShot                          = Spell(198670),
  SteadyShot                            = Spell(56641),
  TrickShotsBuff                        = Spell(257622),
  Multishot                             = Spell(257620)
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  BattlePotionofAgility            = Item(163223)
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


local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.SerpentSting:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
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
    -- snapshot_stats
    -- potion
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 4"; end
    end
    -- hunters_mark
    if S.HuntersMark:IsCastableP() and Player:DebuffDownP(S.HuntersMarkDebuff) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 6"; end
    end
    -- double_tap,precast_time=10
    if S.DoubleTap:IsCastableP() then
      if HR.Cast(S.DoubleTap) then return "double_tap 10"; end
    end
    -- trueshot,precast_time=1.5,if=active_enemies>2
    if S.Trueshot:IsCastableP() and Player:BuffDownP(S.TrueshotBuff) and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 12"; end
    end
    -- aimed_shot,if=active_enemies<3
    if S.AimedShot:IsReadyP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 30"; end
    end
  end
  Cds = function()
    -- hunters_mark,if=debuff.hunters_mark.down
    if S.HuntersMark:IsCastableP() and (Target:DebuffDownP(S.HuntersMarkDebuff)) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 38"; end
    end
    -- double_tap,if=target.time_to_die<15|cooldown.aimed_shot.remains<gcd&(buff.trueshot.up&(buff.unerring_vision.stack>6|!azerite.unerring_vision.enabled)|!talent.calling_the_shots.enabled)&(!azerite.surging_shots.enabled&!talent.streamline.enabled&!azerite.focused_fire.enabled)
    if S.DoubleTap:IsCastableP() and (Target:TimeToDie() < 15 or S.AimedShot:CooldownRemainsP() < Player:GCD() and (Player:BuffP(S.TrueshotBuff) and (Player:BuffStackP(S.UnerringVisionBuff) > 6 or not S.UnerringVision:AzeriteEnabled()) or not S.CallingtheShots:IsAvailable()) and (not S.SurgingShots:AzeriteEnabled() and not S.Streamline:IsAvailable() and not S.FocusedFire:AzeriteEnabled())) then
      if HR.Cast(S.DoubleTap) then return "double_tap 42"; end
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd&(buff.trueshot.up&(buff.unerring_vision.stack>6|!azerite.unerring_vision.enabled)|!talent.calling_the_shots.enabled)&(azerite.surging_shots.enabled|talent.streamline.enabled|azerite.focused_fire.enabled)
    if S.DoubleTap:IsCastableP() and (S.RapidFire:CooldownRemainsP() < Player:GCD() and (Player:BuffP(S.TrueshotBuff) and (Player:BuffStackP(S.UnerringVisionBuff) > 6 or not S.UnerringVision:AzeriteEnabled()) or not S.CallingtheShots:IsAvailable()) and (S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable() or S.FocusedFire:AzeriteEnabled())) then
      if HR.Cast(S.DoubleTap) then return "double_tap 60"; end
    end
    -- berserking,if=buff.trueshot.up&(target.time_to_die>cooldown.berserking.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<13
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.Berserking:BaseDuration() + S.BerserkingBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 13) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 78"; end
    end
    -- blood_fury,if=buff.trueshot.up&(target.time_to_die>cooldown.blood_fury.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.BloodFury:BaseDuration() + S.BloodFuryBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 92"; end
    end
    -- ancestral_call,if=buff.trueshot.up&(target.time_to_die>cooldown.ancestral_call.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.AncestralCall:BaseDuration() + duration or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 106"; end
    end
    -- fireblood,if=buff.trueshot.up&(target.time_to_die>cooldown.fireblood.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<9
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.Fireblood:BaseDuration() + duration or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 9) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 118"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 130"; end
    end
    -- potion,if=buff.trueshot.react&buff.bloodlust.react|buff.trueshot.up&ca_execute|target.time_to_die<25
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions and (bool(Player:BuffStackP(S.TrueshotBuff)) and Player:HasHeroism() or Player:BuffP(S.TrueshotBuff) and bool(ca_execute) or Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 132"; end
    end
    -- trueshot,if=cooldown.rapid_fire.remains&target.time_to_die>cooldown.trueshot.duration_guess+duration|(target.health.pct<20|!talent.careful_aim.enabled)|target.time_to_die<15
    if S.Trueshot:IsCastableP() and (bool(S.RapidFire:CooldownRemainsP()) and Target:TimeToDie() > cooldown.trueshot.duration_guess + S.TrueshotBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable()) or Target:TimeToDie() < 15) then
      if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 138"; end
    end
  end
  St = function()
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 152"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsReadyP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return "barrage 154"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 162"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 164"; end
    end
    -- rapid_fire,if=focus<50&(buff.bloodlust.up&buff.trueshot.up|buff.trueshot.down)
    if S.RapidFire:IsCastableP() and (Player:Focus() < 50 and (Player:HasHeroism() and Player:BuffP(S.TrueshotBuff) or Player:BuffDownP(S.TrueshotBuff))) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 178"; end
    end
    -- arcane_shot,if=buff.master_marksman.up&buff.trueshot.up&focus+cast_regen<focus.max
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.MasterMarksmanBuff) and Player:BuffP(S.TrueshotBuff) and Player:Focus() + Player:FocusCastRegen(S.ArcaneShot:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 184"; end
    end
    -- aimed_shot,if=buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time|buff.trueshot.up
    if S.AimedShot:IsReadyP() and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() or Player:BuffP(S.TrueshotBuff)) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 196"; end
    end
    -- rapid_fire,if=focus+cast_regen<focus.max|azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled
    if S.RapidFire:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.RapidFire:ExecuteTime()) < Player:FocusMax() or S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable()) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 208"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 224"; end
    end
    -- arcane_shot,if=focus>85|(buff.precise_shots.up|focus>45&cooldown.trueshot.remains&target.time_to_die<25)&buff.trueshot.down|target.time_to_die<5
    if S.ArcaneShot:IsCastableP() and (Player:Focus() > 85 or (Player:BuffP(S.PreciseShotsBuff) or Player:Focus() > 45 and bool(S.Trueshot:CooldownRemainsP()) and Target:TimeToDie() < 25) and Player:BuffDownP(S.TrueshotBuff) or Target:TimeToDie() < 5) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 226"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 234"; end
    end
  end
  Trickshots = function()
    -- barrage
    if S.Barrage:IsReadyP() then
      if HR.Cast(S.Barrage) then return "barrage 236"; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 238"; end
    end
    -- rapid_fire,if=buff.trick_shots.up&(azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled)
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and (S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable())) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 240"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&(buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time)
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrickShotsBuff) and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime())) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 252"; end
    end
    -- rapid_fire,if=buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 264"; end
    end
    -- multishot,if=buff.trick_shots.down|buff.precise_shots.up|focus>70
    if S.Multishot:IsCastableP() and (Player:BuffDownP(S.TrickShotsBuff) or Player:BuffP(S.PreciseShotsBuff) or Player:Focus() > 70) then
      if HR.Cast(S.Multishot) then return "multishot 268"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 274"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 276"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 278"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 292"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_items,if=buff.trueshot.up|!talent.calling_the_shots.enabled|target.time_to_die<20
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
