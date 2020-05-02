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
Spell.DeathKnight.Frost = {
  RemorselessWinter                     = Spell(196770),
  GatheringStorm                        = Spell(194912),
  FrozenTempest                         = Spell(),
  RimeBuff                              = Spell(),
  GlacialAdvance                        = Spell(194913),
  Frostscythe                           = Spell(207230),
  FrostStrike                           = Spell(49143),
  RazoriceDebuff                        = Spell(51714),
  HowlingBlast                          = Spell(49184),
  KillingMachineBuff                    = Spell(51124),
  RunicAttenuation                      = Spell(207104),
  Obliterate                            = Spell(49020),
  HornofWinter                          = Spell(57330),
  ArcaneTorrent                         = Spell(50613),
  PillarofFrost                         = Spell(51271),
  ChainsofIce                           = Spell(45524),
  ColdHeartBuff                         = Spell(),
  SeethingRageBuff                      = Spell(),
  PillarofFrostBuff                     = Spell(),
  FrostwyrmsFury                        = Spell(279302),
  IcyCitadel                            = Spell(),
  BreathofSindragosaBuff                = Spell(155166),
  Icecap                                = Spell(207126),
  UnholyStrengthBuff                    = Spell(53365),
  IcyCitadelBuff                        = Spell(),
  EmpoweredRuneWeapon                   = Spell(),
  BreathofSindragosa                    = Spell(152279),
  RazorCoralDebuffDebuff                = Spell(),
  EmpowerRuneWeapon                     = Spell(47568),
  EmpowerRuneWeaponBuff                 = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcanePulse                           = Spell(),
  LightsJudgment                        = Spell(255647),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  BagofTricks                           = Spell(),
  ColdHeart                             = Spell(),
  Obliteration                          = Spell(281238),
  BloodoftheEnemy                       = Spell(),
  GuardianofAzeroth                     = Spell(),
  ChillStreak                           = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  RecklessForceCounterBuff              = Spell(),
  FocusedAzeriteBeam                    = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  PurifyingBlast                        = Spell(),
  WorldveinResonance                    = Spell(),
  RippleInSpace                         = Spell(),
  MemoryofLucidDreams                   = Spell(),
  ReapingFlames                         = Spell(),
  FrozenPulseBuff                       = Spell(),
  FrozenPulse                           = Spell(194909),
  FrostFeverDebuff                      = Spell(),
  IcyTalonsBuff                         = Spell(194879)
};
local S = Spell.DeathKnight.Frost;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  BattlePotionofStrength           = Item(163224),
  AzsharasFontofPower              = Item(),
  NotoriousGladiatorsBadge         = Item(),
  CorruptedGladiatorsBadge         = Item(),
  CorruptedGladiatorsMedallion     = Item(),
  VialofAnimatedBlood              = Item(),
  FirstMatesSpyglass               = Item(),
  JesHowler                        = Item(159627),
  NotoriousGladiatorsMedallion     = Item(),
  AshvanesRazorCoral               = Item(),
  LurkersInsidiousGift             = Item(),
  CyclotronicBlast                 = Item(),
  KnotofAncientFury                = Item(),
  GrongsPrimalRage                 = Item(165574),
  RazdunksBigRedButton             = Item(),
  MerekthasFang                    = Item(),
  IneffableTruth                   = Item(),
  IneffableTruthOh                 = Item()
};
local I = Item.DeathKnight.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Frost = HR.GUISettings.APL.DeathKnight.Frost
};

-- Variables
local VarOtherOnUseEquipped = 0;

HL:RegisterForEvent(function()
  VarOtherOnUseEquipped = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {30, 10, 8}
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


local function EvaluateCycleFrostStrike42(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleFrostStrike77(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate102(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleFrostStrike123(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate146(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and true and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleFrostStrike165(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < 20 and not S.Frostscythe:IsAvailable() and S.PillarofFrost:CooldownRemainsP() > 5
end

local function EvaluateCycleObliterate194(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleFrostStrike217(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate236(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 32 and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate259(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45 and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate284(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > 25 or Player:Rune() > 3 and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate726(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3
end

local function EvaluateCycleObliterate759(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))
end

local function EvaluateCycleFrostStrike800(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable()
end

local function EvaluateCycleObliterate823(TargetUnit)
  return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, BosPooling, BosTicking, ColdHeart, Cooldowns, Essences, Obliteration, Standard
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 4"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 6"; end
    end
    -- variable,name=other_on_use_equipped,value=(equipped.notorious_gladiators_badge|equipped.corrupted_gladiators_badge|equipped.corrupted_gladiators_medallion|equipped.vial_of_animated_blood|equipped.first_mates_spyglass|equipped.jes_howler|equipped.notorious_gladiators_medallion|equipped.ashvanes_razor_coral)
    if (true) then
      VarOtherOnUseEquipped = num((I.NotoriousGladiatorsBadge:IsEquipped() or I.CorruptedGladiatorsBadge:IsEquipped() or I.CorruptedGladiatorsMedallion:IsEquipped() or I.VialofAnimatedBlood:IsEquipped() or I.FirstMatesSpyglass:IsEquipped() or I.JesHowler:IsEquipped() or I.NotoriousGladiatorsMedallion:IsEquipped() or I.AshvanesRazorCoral:IsEquipped()))
    end
  end
  Aoe = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled|(azerite.frozen_tempest.rank&spell_targets.remorseless_winter>=3&!buff.rime.up)
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable() or (bool(S.FrozenTempest:AzeriteRank()) and Cache.EnemiesCount[8] >= 3 and not Player:BuffP(S.RimeBuff))) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 26"; end
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if S.GlacialAdvance:IsCastableP() and (S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 34"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike42) then return "frost_strike 54" end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 55"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 61"; end
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff)) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 65"; end
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 69"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike77) then return "frost_strike 87" end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 88"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 94"; end
    end
    -- frostscythe
    if S.Frostscythe:IsCastableP() then
      if HR.Cast(S.Frostscythe) then return "frostscythe 96"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>(25+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate102) then return "obliterate 112" end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 113"; end
    end
    -- glacial_advance
    if S.GlacialAdvance:IsCastableP() then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 117"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike123) then return "frost_strike 131" end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() then
      if HR.Cast(S.FrostStrike) then return "frost_strike 132"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 134"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 136"; end
    end
  end
  BosPooling = function()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 138"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&&runic_power.deficit>=25&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate146) then return "obliterate 154" end
    end
    -- obliterate,if=runic_power.deficit>=25
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() >= 25) then
      if HR.Cast(S.Obliterate) then return "obliterate 155"; end
    end
    -- glacial_advance,if=runic_power.deficit<20&spell_targets.glacial_advance>=2&cooldown.pillar_of_frost.remains>5
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < 20 and Cache.EnemiesCount[30] >= 2 and S.PillarofFrost:CooldownRemainsP() > 5) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 157"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&!talent.frostscythe.enabled&cooldown.pillar_of_frost.remains>5
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike165) then return "frost_strike 175" end
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>5
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > 5) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 176"; end
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 180"; end
    end
    -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 186"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate194) then return "obliterate 204" end
    end
    -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 205"; end
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 209"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike217) then return "frost_strike 227" end
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsUsableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 228"; end
    end
  end
  BosTicking = function()
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=32&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate236) then return "obliterate 244" end
    end
    -- obliterate,if=runic_power<=32
    if S.Obliterate:IsCastableP() and (Player:RunicPower() <= 32) then
      if HR.Cast(S.Obliterate) then return "obliterate 245"; end
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 247"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 251"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_5<gcd|runic_power<=45&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate259) then return "obliterate 267" end
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
      if HR.Cast(S.Obliterate) then return "obliterate 268"; end
    end
    -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 270"; end
    end
    -- horn_of_winter,if=runic_power.deficit>=32&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 32 and Player:RuneTimeToX(3) > Player:GCD()) then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 274"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 276"; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 278"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate284) then return "obliterate 292" end
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 293"; end
    end
    -- arcane_torrent,if=runic_power.deficit>50
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:RunicPowerDeficit() > 50) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 295"; end
    end
  end
  ColdHeart = function()
    -- chains_of_ice,if=buff.cold_heart.stack>5&target.1.time_to_die<gcd
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 5 and target.1.time_to_die < Player:GCD()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 297"; end
    end
    -- chains_of_ice,if=(buff.seething_rage.remains<gcd)&buff.seething_rage.up
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.SeethingRageBuff) < Player:GCD()) and Player:BuffP(S.SeethingRageBuff)) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 301"; end
    end
    -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up&(azerite.icy_citadel.rank<=1|buff.breath_of_sindragosa.up)&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff) and (S.IcyCitadel:AzeriteRank() <= 1 or Player:BuffP(S.BreathofSindragosaBuff)) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 307"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.pillar_of_frost.up&(azerite.icy_citadel.rank<=1|buff.breath_of_sindragosa.up)&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and bool(Player:BuffRemainsP(S.UnholyStrengthBuff)) and Player:BuffP(S.PillarofFrostBuff) and (S.IcyCitadel:AzeriteRank() <= 1 or Player:BuffP(S.BreathofSindragosaBuff)) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 323"; end
    end
    -- chains_of_ice,if=(buff.icy_citadel.remains<4|buff.icy_citadel.remains<rune.time_to_3)&buff.icy_citadel.up&azerite.icy_citadel.rank>=2&!buff.breath_of_sindragosa.up&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.IcyCitadelBuff) < 4 or Player:BuffRemainsP(S.IcyCitadelBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() >= 2 and not Player:BuffP(S.BreathofSindragosaBuff) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 341"; end
    end
    -- chains_of_ice,if=buff.icy_citadel.up&buff.unholy_strength.up&azerite.icy_citadel.rank>=2&!buff.breath_of_sindragosa.up&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and (Player:BuffP(S.IcyCitadelBuff) and Player:BuffP(S.UnholyStrengthBuff) and S.IcyCitadel:AzeriteRank() >= 2 and not Player:BuffP(S.BreathofSindragosaBuff) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 355"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<4&buff.pillar_of_frost.up&talent.icecap.enabled&buff.cold_heart.stack>=18&azerite.icy_citadel.rank<=1
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 4 and Player:BuffP(S.PillarofFrostBuff) and S.Icecap:IsAvailable() and Player:BuffStackP(S.ColdHeartBuff) >= 18 and S.IcyCitadel:AzeriteRank() <= 1) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 367"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.up&talent.icecap.enabled&azerite.icy_citadel.rank>=2&(buff.cold_heart.stack>=19&buff.icy_citadel.remains<gcd&buff.icy_citadel.up|buff.unholy_strength.up&buff.cold_heart.stack>=18)
    if S.ChainsofIce:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and S.Icecap:IsAvailable() and S.IcyCitadel:AzeriteRank() >= 2 and (Player:BuffStackP(S.ColdHeartBuff) >= 19 and Player:BuffRemainsP(S.IcyCitadelBuff) < Player:GCD() and Player:BuffP(S.IcyCitadelBuff) or Player:BuffP(S.UnholyStrengthBuff) and Player:BuffStackP(S.ColdHeartBuff) >= 18)) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 379"; end
    end
  end
  Cooldowns = function()
    -- use_item,name=azsharas_font_of_power,if=(cooldown.empowered_rune_weapon.ready&!variable.other_on_use_equipped)|(cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)
    if I.AzsharasFontofPower:IsReady() and ((S.EmpoweredRuneWeapon:CooldownUpP() and not bool(VarOtherOnUseEquipped)) or (S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOtherOnUseEquipped))) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 397"; end
    end
    -- use_item,name=lurkers_insidious_gift,if=talent.breath_of_sindragosa.enabled&((cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)|(buff.pillar_of_frost.up&!variable.other_on_use_equipped))|(buff.pillar_of_frost.up&!talent.breath_of_sindragosa.enabled)
    if I.LurkersInsidiousGift:IsReady() and (S.BreathofSindragosa:IsAvailable() and ((S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOtherOnUseEquipped)) or (Player:BuffP(S.PillarofFrostBuff) and not bool(VarOtherOnUseEquipped))) or (Player:BuffP(S.PillarofFrostBuff) and not S.BreathofSindragosa:IsAvailable())) then
      if HR.CastSuggested(I.LurkersInsidiousGift) then return "lurkers_insidious_gift 407"; end
    end
    -- use_item,name=cyclotronic_blast,if=!buff.pillar_of_frost.up
    if I.CyclotronicBlast:IsReady() and (not Player:BuffP(S.PillarofFrostBuff)) then
      if HR.CastSuggested(I.CyclotronicBlast) then return "cyclotronic_blast 423"; end
    end
    -- use_items,if=(cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuffDebuff)) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 428"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=cooldown.empower_rune_weapon.remains>90&debuff.razor_coral_debuff.up&variable.other_on_use_equipped|buff.breath_of_sindragosa.up&debuff.razor_coral_debuff.up&!variable.other_on_use_equipped|buff.empower_rune_weapon.up&debuff.razor_coral_debuff.up&!talent.breath_of_sindragosa.enabled|target.1.time_to_die<21
    if I.AshvanesRazorCoral:IsReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 90 and Target:DebuffP(S.RazorCoralDebuffDebuff) and bool(VarOtherOnUseEquipped) or Player:BuffP(S.BreathofSindragosaBuff) and Target:DebuffP(S.RazorCoralDebuffDebuff) and not bool(VarOtherOnUseEquipped) or Player:BuffP(S.EmpowerRuneWeaponBuff) and Target:DebuffP(S.RazorCoralDebuffDebuff) and not S.BreathofSindragosa:IsAvailable() or target.1.time_to_die < 21) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 432"; end
    end
    -- use_item,name=jes_howler,if=(equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains)|(!equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains<12&buff.pillar_of_frost.up)
    if I.JesHowler:IsReady() and ((I.LurkersInsidiousGift:IsEquipped() and bool(Player:BuffRemainsP(S.PillarofFrostBuff))) or (not I.LurkersInsidiousGift:IsEquipped() and Player:BuffRemainsP(S.PillarofFrostBuff) < 12 and Player:BuffP(S.PillarofFrostBuff))) then
      if HR.CastSuggested(I.JesHowler) then return "jes_howler 452"; end
    end
    -- use_item,name=knot_of_ancient_fury,if=cooldown.empower_rune_weapon.remains>40
    if I.KnotofAncientFury:IsReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 40) then
      if HR.CastSuggested(I.KnotofAncientFury) then return "knot_of_ancient_fury 464"; end
    end
    -- use_item,name=grongs_primal_rage,if=rune<=3&!buff.pillar_of_frost.up&(!buff.breath_of_sindragosa.up|!talent.breath_of_sindragosa.enabled)
    if I.GrongsPrimalRage:IsReady() and (Player:Rune() <= 3 and not Player:BuffP(S.PillarofFrostBuff) and (not Player:BuffP(S.BreathofSindragosaBuff) or not S.BreathofSindragosa:IsAvailable())) then
      if HR.CastSuggested(I.GrongsPrimalRage) then return "grongs_primal_rage 468"; end
    end
    -- use_item,name=razdunks_big_red_button
    if I.RazdunksBigRedButton:IsReady() then
      if HR.CastSuggested(I.RazdunksBigRedButton) then return "razdunks_big_red_button 476"; end
    end
    -- use_item,name=merekthas_fang,if=!buff.breath_of_sindragosa.up&!buff.pillar_of_frost.up
    if I.MerekthasFang:IsReady() and (not Player:BuffP(S.BreathofSindragosaBuff) and not Player:BuffP(S.PillarofFrostBuff)) then
      if HR.CastSuggested(I.MerekthasFang) then return "merekthas_fang 478"; end
    end
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 484"; end
    end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 490"; end
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 496"; end
    end
    -- arcane_pulse,if=(!buff.pillar_of_frost.up&active_enemies>=2)|!buff.pillar_of_frost.up&(rune.deficit>=5&runic_power.deficit>=60)
    if S.ArcanePulse:IsCastableP() and ((not Player:BuffP(S.PillarofFrostBuff) and Cache.EnemiesCount[10] >= 2) or not Player:BuffP(S.PillarofFrostBuff) and (Player:RuneDeficit() >= 5 and Player:RunicPowerDeficit() >= 60)) then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 500"; end
    end
    -- lights_judgment,if=buff.pillar_of_frost.up
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 512"; end
    end
    -- ancestral_call,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 516"; end
    end
    -- fireblood,if=buff.pillar_of_frost.remains<=8&buff.empower_rune_weapon.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffRemainsP(S.PillarofFrostBuff) <= 8 and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 522"; end
    end
    -- bag_of_tricks,if=buff.pillar_of_frost.up&(buff.pillar_of_frost.remains<5&talent.cold_heart.enabled|!talent.cold_heart.enabled&buff.pillar_of_frost.remains<3)&active_enemies=1|buff.seething_rage.up&active_enemies=1
    if S.BagofTricks:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 and S.ColdHeart:IsAvailable() or not S.ColdHeart:IsAvailable() and Player:BuffRemainsP(S.PillarofFrostBuff) < 3) and Cache.EnemiesCount[10] == 1 or Player:BuffP(S.SeethingRageBuff) and Cache.EnemiesCount[10] == 1) then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 528"; end
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains|talent.icecap.enabled
    if S.PillarofFrost:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) or S.Icecap:IsAvailable()) then
      if HR.Cast(S.PillarofFrost, Settings.Frost.GCDasOffGCD.PillarofFrost) then return "pillar_of_frost 554"; end
    end
    -- breath_of_sindragosa,use_off_gcd=1,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if S.BreathofSindragosa:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
      if HR.Cast(S.BreathofSindragosa, Settings.Frost.GCDasOffGCD.BreathofSindragosa) then return "breath_of_sindragosa 560"; end
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.obliteration.enabled&rune.time_to_5>gcd&runic_power.deficit>=10|target.1.time_to_die<20
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and S.Obliteration:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10 or target.1.time_to_die < 20) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 566"; end
    end
    -- empower_rune_weapon,if=(cooldown.pillar_of_frost.ready|target.1.time_to_die<20)&talent.breath_of_sindragosa.enabled&runic_power>60
    if S.EmpowerRuneWeapon:IsCastableP() and ((S.PillarofFrost:CooldownUpP() or target.1.time_to_die < 20) and S.BreathofSindragosa:IsAvailable() and Player:RunicPower() > 60) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 572"; end
    end
    -- empower_rune_weapon,if=talent.icecap.enabled&rune<3
    if S.EmpowerRuneWeapon:IsCastableP() and (S.Icecap:IsAvailable() and Player:Rune() < 3) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 578"; end
    end
    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.1.time_to_die<=gcd)
    if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or target.1.time_to_die <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.up&azerite.icy_citadel.rank<=1&(buff.pillar_of_frost.remains<=gcd|buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 1 and (Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() or Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff)))) then
      if HR.Cast(S.FrostwyrmsFury) then return "frostwyrms_fury 590"; end
    end
    -- frostwyrms_fury,if=(buff.icy_citadel.up&!talent.icecap.enabled&(buff.unholy_strength.up|buff.icy_citadel.remains<=gcd))|buff.icy_citadel.up&buff.icy_citadel.remains<=gcd&talent.icecap.enabled&buff.pillar_of_frost.up
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffP(S.IcyCitadelBuff) and not S.Icecap:IsAvailable() and (Player:BuffP(S.UnholyStrengthBuff) or Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD())) or Player:BuffP(S.IcyCitadelBuff) and Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() and S.Icecap:IsAvailable() and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.FrostwyrmsFury) then return "frostwyrms_fury 602"; end
    end
    -- frostwyrms_fury,if=target.1.time_to_die<gcd|(target.1.time_to_die<cooldown.pillar_of_frost.remains&buff.unholy_strength.up)
    if S.FrostwyrmsFury:IsCastableP() and (target.1.time_to_die < Player:GCD() or (target.1.time_to_die < S.PillarofFrost:CooldownRemainsP() and Player:BuffP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.FrostwyrmsFury) then return "frostwyrms_fury 620"; end
    end
  end
  Essences = function()
    -- blood_of_the_enemy,if=buff.pillar_of_frost.up&(buff.pillar_of_frost.remains<10&(buff.breath_of_sindragosa.up|talent.obliteration.enabled|talent.icecap.enabled&!azerite.icy_citadel.enabled)|buff.icy_citadel.up&talent.icecap.enabled)
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and (Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and (Player:BuffP(S.BreathofSindragosaBuff) or S.Obliteration:IsAvailable() or S.Icecap:IsAvailable() and not S.IcyCitadel:AzeriteEnabled()) or Player:BuffP(S.IcyCitadelBuff) and S.Icecap:IsAvailable())) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 626"; end
    end
    -- guardian_of_azeroth,if=!talent.icecap.enabled|talent.icecap.enabled&azerite.icy_citadel.enabled&buff.pillar_of_frost.remains<6&buff.pillar_of_frost.up|talent.icecap.enabled&!azerite.icy_citadel.enabled
    if S.GuardianofAzeroth:IsCastableP() and (not S.Icecap:IsAvailable() or S.Icecap:IsAvailable() and S.IcyCitadel:AzeriteEnabled() and Player:BuffRemainsP(S.PillarofFrostBuff) < 6 and Player:BuffP(S.PillarofFrostBuff) or S.Icecap:IsAvailable() and not S.IcyCitadel:AzeriteEnabled()) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 644"; end
    end
    -- chill_streak,if=buff.pillar_of_frost.remains<5&buff.pillar_of_frost.up|target.1.time_to_die<5
    if S.ChillStreak:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 and Player:BuffP(S.PillarofFrostBuff) or target.1.time_to_die < 5) then
      if HR.Cast(S.ChillStreak) then return "chill_streak 660"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 11) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 666"; end
    end
    -- focused_azerite_beam,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.FocusedAzeriteBeam:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 672"; end
    end
    -- concentrated_flame,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff) and Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff) == 0) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 678"; end
    end
    -- purifying_blast,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.PurifyingBlast:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 686"; end
    end
    -- worldvein_resonance,if=buff.pillar_of_frost.up|buff.empower_rune_weapon.up|cooldown.breath_of_sindragosa.remains>60+15|equipped.ineffable_truth|equipped.ineffable_truth_oh
    if S.WorldveinResonance:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) or Player:BuffP(S.EmpowerRuneWeaponBuff) or S.BreathofSindragosa:CooldownRemainsP() > 60 + 15 or I.IneffableTruth:IsEquipped() or I.IneffableTruthOh:IsEquipped()) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 692"; end
    end
    -- ripple_in_space,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.RippleInSpace:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 704"; end
    end
    -- memory_of_lucid_dreams,if=buff.empower_rune_weapon.remains<5&buff.breath_of_sindragosa.up|(rune.time_to_2>gcd&runic_power<50)
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffRemainsP(S.EmpowerRuneWeaponBuff) < 5 and Player:BuffP(S.BreathofSindragosaBuff) or (Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 50)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 710"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 716"; end
    end
  end
  Obliteration = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 718"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate726) then return "obliterate 736" end
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP() and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 737"; end
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 743"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate759) then return "obliterate 775" end
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      if HR.Cast(S.Obliterate) then return "obliterate 776"; end
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 788"; end
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 792"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, EvaluateCycleFrostStrike800) then return "frost_strike 810" end
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsUsableP() and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 811"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 815"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, EvaluateCycleObliterate823) then return "obliterate 831" end
    end
    -- obliterate
    if S.Obliterate:IsCastableP() then
      if HR.Cast(S.Obliterate) then return "obliterate 832"; end
    end
  end
  Standard = function()
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 834"; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 836"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 842"; end
    end
    -- obliterate,if=talent.icecap.enabled&buff.pillar_of_frost.up&azerite.icy_citadel.rank>=2
    if S.Obliterate:IsCastableP() and (S.Icecap:IsAvailable() and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() >= 2) then
      if HR.Cast(S.Obliterate) then return "obliterate 846"; end
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsCastableP() and (not Player:BuffP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 854"; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 860"; end
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 864"; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 868"; end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() then
      if HR.Cast(S.FrostStrike) then return "frost_strike 872"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 874"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 876"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsCastableP() and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 880"; end
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsCastableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 888"; end
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsUsableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 898"; end
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=bos_ticking,if=buff.breath_of_sindragosa.up
    if (Player:BuffP(S.BreathofSindragosaBuff)) then
      return BosTicking();
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&((cooldown.breath_of_sindragosa.remains=0&cooldown.pillar_of_frost.remains<10)|(cooldown.breath_of_sindragosa.remains<20&target.1.time_to_die<35))
    if (S.BreathofSindragosa:IsAvailable() and ((S.BreathofSindragosa:CooldownRemainsP() == 0 and S.PillarofFrost:CooldownRemainsP() < 10) or (S.BreathofSindragosa:CooldownRemainsP() < 20 and target.1.time_to_die < 35))) then
      return BosPooling();
    end
    -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:BuffP(S.PillarofFrostBuff) and S.Obliteration:IsAvailable()) then
      return Obliteration();
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[10] >= 2) then
      return Aoe();
    end
    -- call_action_list,name=standard
    if (true) then
      local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(251, APL)
