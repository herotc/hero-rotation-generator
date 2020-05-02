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
  WorldveinResonance                    = Spell(),
  GuardianofAzeroth                     = Spell(),
  MemoryofLucidDreams                   = Spell(),
  TrueshotBuff                          = Spell(288613),
  Trueshot                              = Spell(288613),
  AimedShot                             = Spell(19434),
  RapidFire                             = Spell(257044),
  Berserking                            = Spell(26297),
  BerserkingBuff                        = Spell(26297),
  CarefulAim                            = Spell(260228),
  BloodFury                             = Spell(20572),
  BloodFuryBuff                         = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  BagofTricks                           = Spell(),
  ReapingFlames                         = Spell(),
  WorldveinResonanceBuff                = Spell(),
  RippleInSpace                         = Spell(),
  PotionofUnbridledFuryBuff             = Spell(),
  UnbridledFuryBuff                     = Spell(),
  ExplosiveShot                         = Spell(212431),
  Barrage                               = Spell(120360),
  AMurderofCrows                        = Spell(131894),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  LethalShots                           = Spell(),
  IntheRhythmBuff                       = Spell(),
  BloodoftheEnemy                       = Spell(),
  UnerringVisionBuff                    = Spell(274447),
  UnerringVision                        = Spell(274444),
  FocusedAzeriteBeam                    = Spell(),
  ArcaneShot                            = Spell(185358),
  MasterMarksmanBuff                    = Spell(269576),
  MemoryofLucidDreamsBuff               = Spell(),
  DoubleTapBuff                         = Spell(),
  PreciseShotsBuff                      = Spell(260242),
  PiercingShot                          = Spell(198670),
  PurifyingBlast                        = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  RecklessForceCounterBuff              = Spell(),
  SteadyShot                            = Spell(56641),
  TrickShotsBuff                        = Spell(257622),
  FocusedFire                           = Spell(278531),
  IntheRhythm                           = Spell(264198),
  SurgingShots                          = Spell(287707),
  Streamline                            = Spell(260367),
  Multishot                             = Spell(257620),
  CallingtheShots                       = Spell(260404),
  GuardianofAzerothBuff                 = Spell(),
  RazorCoralDebuffDebuff                = Spell(),
  BloodoftheEnemyDebuff                 = Spell()
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  AzsharasFontofPower              = Item(),
  BattlePotionofAgility            = Item(163223),
  LurkersInsidiousGift             = Item(),
  LustrousGoldenPlumage            = Item(159617),
  GalecallersBoon                  = Item(),
  AshvanesRazorCoral               = Item(),
  PocketsizedComputationDevice     = Item()
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
S.ConcentratedFlame:RegisterInFlight()

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
    -- hunters_mark
    if S.HuntersMark:IsCastableP() and Player:DebuffDownP(S.HuntersMarkDebuff) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 4"; end
    end
    -- double_tap,precast_time=10
    if S.DoubleTap:IsCastableP() then
      if HR.Cast(S.DoubleTap) then return "double_tap 8"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 10"; end
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 12"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 14"; end
    end
    -- memory_of_lucid_dreams
    if S.MemoryofLucidDreams:IsCastableP() then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 16"; end
    end
    -- trueshot,precast_time=1.5,if=active_enemies>2
    if S.Trueshot:IsCastableP() and Player:BuffDownP(S.TrueshotBuff) and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 18"; end
    end
    -- potion,dynamic_prepot=1
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 36"; end
    end
    -- aimed_shot,if=active_enemies<3
    if S.AimedShot:IsReadyP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 38"; end
    end
  end
  Cds = function()
    -- hunters_mark,if=debuff.hunters_mark.down&!buff.trueshot.up
    if S.HuntersMark:IsCastableP() and (Target:DebuffDownP(S.HuntersMarkDebuff) and not Player:BuffP(S.TrueshotBuff)) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 46"; end
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd|cooldown.rapid_fire.remains<cooldown.aimed_shot.remains|target.time_to_die<20
    if S.DoubleTap:IsCastableP() and (S.RapidFire:CooldownRemainsP() < Player:GCD() or S.RapidFire:CooldownRemainsP() < S.AimedShot:CooldownRemainsP() or Target:TimeToDie() < 20) then
      if HR.Cast(S.DoubleTap) then return "double_tap 52"; end
    end
    -- berserking,if=prev_gcd.1.trueshot&(target.time_to_die>cooldown.berserking.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<13
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Trueshot) and (Target:TimeToDie() > S.Berserking:BaseDuration() + S.BerserkingBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 13) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 60"; end
    end
    -- blood_fury,if=prev_gcd.1.trueshot&(target.time_to_die>cooldown.blood_fury.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Trueshot) and (Target:TimeToDie() > S.BloodFury:BaseDuration() + S.BloodFuryBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 74"; end
    end
    -- ancestral_call,if=prev_gcd.1.trueshot&(target.time_to_die>cooldown.ancestral_call.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Trueshot) and (Target:TimeToDie() > S.AncestralCall:BaseDuration() + duration or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 88"; end
    end
    -- fireblood,if=prev_gcd.1.trueshot&(target.time_to_die>cooldown.fireblood.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<9
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Trueshot) and (Target:TimeToDie() > S.Fireblood:BaseDuration() + duration or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 9) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 100"; end
    end
    -- lights_judgment,if=buff.trueshot.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.TrueshotBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 112"; end
    end
    -- bag_of_tricks,if=buff.trueshot.down
    if S.BagofTricks:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff)) then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 116"; end
    end
    -- reaping_flames,if=buff.trueshot.down&(target.health.pct>80|target.health.pct<=20|target.time_to_pct_20>30)
    if S.ReapingFlames:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) and (Target:HealthPercentage() > 80 or Target:HealthPercentage() <= 20 or target.time_to_pct_20 > 30)) then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 120"; end
    end
    -- worldvein_resonance,if=(trinket.azsharas_font_of_power.cooldown.remains>20|!equipped.azsharas_font_of_power|target.time_to_die<trinket.azsharas_font_of_power.cooldown.duration+34&target.health.pct>20)&(cooldown.trueshot.remains_guess<3|(essence.vision_of_perfection.minor&target.time_to_die>cooldown+buff.worldvein_resonance.duration))|target.time_to_die<20
    if S.WorldveinResonance:IsCastableP() and ((trinket.azsharas_font_of_power.cooldown.remains > 20 or not I.AzsharasFontofPower:IsEquipped() or Target:TimeToDie() < trinket.azsharas_font_of_power.cooldown.duration + 34 and Target:HealthPercentage() > 20) and (cooldown.trueshot.remains_guess < 3 or (bool(essence.vision_of_perfection.minor) and Target:TimeToDie() > S.WorldveinResonance:Cooldown() + S.WorldveinResonanceBuff:BaseDuration())) or Target:TimeToDie() < 20) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 124"; end
    end
    -- guardian_of_azeroth,if=(ca_execute|target.time_to_die>cooldown+30)&(buff.trueshot.up|cooldown.trueshot.remains<16)|target.time_to_die<31
    if S.GuardianofAzeroth:IsCastableP() and ((bool(ca_execute) or Target:TimeToDie() > S.GuardianofAzeroth:Cooldown() + 30) and (Player:BuffP(S.TrueshotBuff) or S.Trueshot:CooldownRemainsP() < 16) or Target:TimeToDie() < 31) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 136"; end
    end
    -- ripple_in_space,if=cooldown.trueshot.remains<7
    if S.RippleInSpace:IsCastableP() and (S.Trueshot:CooldownRemainsP() < 7) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 146"; end
    end
    -- memory_of_lucid_dreams,if=!buff.trueshot.up
    if S.MemoryofLucidDreams:IsCastableP() and (not Player:BuffP(S.TrueshotBuff)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 150"; end
    end
    -- potion,if=buff.trueshot.react&buff.bloodlust.react|prev_gcd.1.trueshot&target.health.pct<20|((consumable.potion_of_unbridled_fury|consumable.unbridled_fury)&target.time_to_die<61|target.time_to_die<26)
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions and (bool(Player:BuffStackP(S.TrueshotBuff)) and Player:HasHeroism() or Player:PrevGCDP(1, S.Trueshot) and Target:HealthPercentage() < 20 or ((Player:Buff(S.PotionofUnbridledFuryBuff) or Player:Buff(S.UnbridledFuryBuff)) and Target:TimeToDie() < 61 or Target:TimeToDie() < 26)) then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 154"; end
    end
    -- trueshot,if=buff.trueshot.down&cooldown.rapid_fire.remains|target.time_to_die<15
    if S.Trueshot:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) and bool(S.RapidFire:CooldownRemainsP()) or Target:TimeToDie() < 15) then
      if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 164"; end
    end
  end
  St = function()
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 170"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsReadyP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return "barrage 172"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 180"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 182"; end
    end
    -- rapid_fire,if=buff.trueshot.down|focus<35|focus<60&!talent.lethal_shots.enabled|buff.in_the_rhythm.remains<execute_time
    if S.RapidFire:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) or Player:Focus() < 35 or Player:Focus() < 60 and not S.LethalShots:IsAvailable() or Player:BuffRemainsP(S.IntheRhythmBuff) < S.RapidFire:ExecuteTime()) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 196"; end
    end
    -- blood_of_the_enemy,if=buff.trueshot.up&(buff.unerring_vision.stack>4|!azerite.unerring_vision.enabled)|target.time_to_die<11
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.TrueshotBuff) and (Player:BuffStackP(S.UnerringVisionBuff) > 4 or not S.UnerringVision:AzeriteEnabled()) or Target:TimeToDie() < 11) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 208"; end
    end
    -- focused_azerite_beam,if=!buff.trueshot.up|target.time_to_die<5
    if S.FocusedAzeriteBeam:IsCastableP() and (not Player:BuffP(S.TrueshotBuff) or Target:TimeToDie() < 5) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 216"; end
    end
    -- arcane_shot,if=buff.trueshot.up&buff.master_marksman.up&!buff.memory_of_lucid_dreams.up
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.TrueshotBuff) and Player:BuffP(S.MasterMarksmanBuff) and not Player:BuffP(S.MemoryofLucidDreamsBuff)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 220"; end
    end
    -- aimed_shot,if=buff.trueshot.up|(buff.double_tap.down|ca_execute)&buff.precise_shots.down|full_recharge_time<cast_time&cooldown.trueshot.remains
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrueshotBuff) or (Player:BuffDownP(S.DoubleTapBuff) or bool(ca_execute)) and Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() and bool(S.Trueshot:CooldownRemainsP())) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 228"; end
    end
    -- arcane_shot,if=buff.trueshot.up&buff.master_marksman.up&buff.memory_of_lucid_dreams.up
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.TrueshotBuff) and Player:BuffP(S.MasterMarksmanBuff) and Player:BuffP(S.MemoryofLucidDreamsBuff)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 246"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 254"; end
    end
    -- purifying_blast,if=!buff.trueshot.up|target.time_to_die<8
    if S.PurifyingBlast:IsCastableP() and (not Player:BuffP(S.TrueshotBuff) or Target:TimeToDie() < 8) then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 256"; end
    end
    -- concentrated_flame,if=focus+focus.regen*gcd<focus.max&buff.trueshot.down&(!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight)|full_recharge_time<gcd|target.time_to_die<5
    if S.ConcentratedFlame:IsCastableP() and (Player:Focus() + Player:FocusRegen() * Player:GCD() < Player:FocusMax() and Player:BuffDownP(S.TrueshotBuff) and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight()) or S.ConcentratedFlame:FullRechargeTimeP() < Player:GCD() or Target:TimeToDie() < 5) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 260"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10|target.time_to_die<5
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 10 or Target:TimeToDie() < 5) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 274"; end
    end
    -- arcane_shot,if=buff.trueshot.down&(buff.precise_shots.up&(focus>55|buff.master_marksman.up)|focus>75|target.time_to_die<5)
    if S.ArcaneShot:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) and (Player:BuffP(S.PreciseShotsBuff) and (Player:Focus() > 55 or Player:BuffP(S.MasterMarksmanBuff)) or Player:Focus() > 75 or Target:TimeToDie() < 5)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 280"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 288"; end
    end
  end
  Trickshots = function()
    -- barrage
    if S.Barrage:IsReadyP() then
      if HR.Cast(S.Barrage) then return "barrage 290"; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 292"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&ca_execute&buff.double_tap.up
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrickShotsBuff) and bool(ca_execute) and Player:BuffP(S.DoubleTapBuff)) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 294"; end
    end
    -- rapid_fire,if=buff.trick_shots.up&(azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled)
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and (S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable())) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 300"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&(buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time|buff.trueshot.up)
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrickShotsBuff) and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() or Player:BuffP(S.TrueshotBuff))) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 312"; end
    end
    -- rapid_fire,if=buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 326"; end
    end
    -- multishot,if=buff.trick_shots.down|buff.precise_shots.up&!buff.trueshot.up|focus>70
    if S.Multishot:IsCastableP() and (Player:BuffDownP(S.TrickShotsBuff) or Player:BuffP(S.PreciseShotsBuff) and not Player:BuffP(S.TrueshotBuff) or Player:Focus() > 70) then
      if HR.Cast(S.Multishot) then return "multishot 330"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 338"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 340"; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 342"; end
    end
    -- blood_of_the_enemy
    if S.BloodoftheEnemy:IsCastableP() then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 344"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 10) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 346"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 352"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 354"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 356"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 370"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_item,name=lurkers_insidious_gift,if=cooldown.trueshot.remains_guess<15|target.time_to_die<30
    if I.LurkersInsidiousGift:IsReady() and (cooldown.trueshot.remains_guess < 15 or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.LurkersInsidiousGift) then return "lurkers_insidious_gift 374"; end
    end
    -- use_item,name=azsharas_font_of_power,if=(target.time_to_die>cooldown+34|target.health.pct<20|target.time_to_pct_20<15)&cooldown.trueshot.remains_guess<15|target.time_to_die<35
    if I.AzsharasFontofPower:IsReady() and ((Target:TimeToDie() > I.AzsharasFontofPower:Cooldown() + 34 or Target:HealthPercentage() < 20 or target.time_to_pct_20 < 15) and cooldown.trueshot.remains_guess < 15 or Target:TimeToDie() < 35) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 378"; end
    end
    -- use_item,name=lustrous_golden_plumage,if=cooldown.trueshot.remains_guess<5|target.time_to_die<20
    if I.LustrousGoldenPlumage:IsReady() and (cooldown.trueshot.remains_guess < 5 or Target:TimeToDie() < 20) then
      if HR.CastSuggested(I.LustrousGoldenPlumage) then return "lustrous_golden_plumage 386"; end
    end
    -- use_item,name=galecallers_boon,if=prev_gcd.1.trueshot|!talent.calling_the_shots.enabled|target.time_to_die<10
    if I.GalecallersBoon:IsReady() and (Player:PrevGCDP(1, S.Trueshot) or not S.CallingtheShots:IsAvailable() or Target:TimeToDie() < 10) then
      if HR.CastSuggested(I.GalecallersBoon) then return "galecallers_boon 390"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=prev_gcd.1.trueshot&(buff.guardian_of_azeroth.up|!essence.condensed_lifeforce.major&ca_execute)|debuff.razor_coral_debuff.down|target.time_to_die<20
    if I.AshvanesRazorCoral:IsReady() and (Player:PrevGCDP(1, S.Trueshot) and (Player:BuffP(S.GuardianofAzerothBuff) or not bool(essence.condensed_lifeforce.major) and bool(ca_execute)) or Target:DebuffDownP(S.RazorCoralDebuffDebuff) or Target:TimeToDie() < 20) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 396"; end
    end
    -- use_item,name=pocketsized_computation_device,if=!buff.trueshot.up&!essence.blood_of_the_enemy.major|debuff.blood_of_the_enemy.up|target.time_to_die<5
    if I.PocketsizedComputationDevice:IsReady() and (not Player:BuffP(S.TrueshotBuff) and not bool(essence.blood_of_the_enemy.major) or Target:DebuffP(S.BloodoftheEnemyDebuff) or Target:TimeToDie() < 5) then
      if HR.CastSuggested(I.PocketsizedComputationDevice) then return "pocketsized_computation_device 404"; end
    end
    -- use_items,if=prev_gcd.1.trueshot|!talent.calling_the_shots.enabled|target.time_to_die<20
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
