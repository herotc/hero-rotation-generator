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
if not Spell.Shaman then Spell.Shaman = {} end
Spell.Shaman.Enhancement = {
  LightningShield                       = Spell(192106),
  CrashLightning                        = Spell(187874),
  CrashLightningBuff                    = Spell(187874),
  Rockbiter                             = Spell(193786),
  Landslide                             = Spell(197992),
  LandslideBuff                         = Spell(202004),
  Windstrike                            = Spell(115356),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  AscendanceBuff                        = Spell(114051),
  Ascendance                            = Spell(114051),
  FeralSpirit                           = Spell(51533),
  --Strike                                = Spell(),
  EarthenSpike                          = Spell(188089),
  Stormstrike                           = Spell(17364),
  LightningConduit                      = Spell(275388),
  LightningConduitDebuff                = Spell(275391),
  StormbringerBuff                      = Spell(201845),
  GatheringStormsBuff                   = Spell(198300),
  LightningBolt                         = Spell(187837),
  Overcharge                            = Spell(210727),
  Sundering                             = Spell(197214),
  ForcefulWinds                         = Spell(262647),
  Flametongue                           = Spell(193796),
  SearingAssault                        = Spell(192087),
  LavaLash                              = Spell(60103),
  HotHand                               = Spell(201900),
  HotHandBuff                           = Spell(215785),
  StrengthofEarthBuff                   = Spell(273465),
  CrashingStorm                         = Spell(192246),
  Frostbrand                            = Spell(196834),
  Hailstorm                             = Spell(210853),
  FrostbrandBuff                        = Spell(196834),
  PrimalPrimerDebuff                    = Spell(273006),
  PrimalPrimer                          = Spell(272992),
  FlametongueBuff                       = Spell(194084),
  FuryofAir                             = Spell(197211),
  FuryofAirBuff                         = Spell(197211),
  TotemMastery                          = Spell(262395),
  ResonanceTotemBuff                    = Spell(262419),
  SunderingDebuff                       = Spell(197214),
  NaturalHarmony                        = Spell(278697),
  NaturalHarmonyFrostBuff               = Spell(279029),
  NaturalHarmonyFireBuff                = Spell(279028),
  NaturalHarmonyNatureBuff              = Spell(279033),
  WindShear                             = Spell(57994),
  EarthenSpikeDebuff                    = Spell(188089),
  Boulderfist                           = Spell(246035),
  StrengthofEarth                       = Spell(273461)
};
local S = Spell.Shaman.Enhancement;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
  BattlePotionofAgility            = Item(163223)
};
local I = Item.Shaman.Enhancement;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Shaman.Commons,
  Enhancement = HR.GUISettings.APL.Shaman.Enhancement
};

-- Variables
local VarFurycheckCl = 0;
local VarCooldownSync = 0;
local VarFurycheckEs = 0;
local VarFurycheckSs = 0;
local VarFurycheckLb = 0;
local VarOcpoolSs = 0;
local VarOcpoolCl = 0;
local VarOcpoolLl = 0;
local VarFurycheckLl = 0;
local VarFurycheckFb = 0;
local VarClpoolLl = 0;
local VarClpoolSs = 0;
local VarFreezerburnEnabled = 0;
local VarOcpool = 0;
local VarOcpoolFb = 0;
local VarRockslideEnabled = 0;

HL:RegisterForEvent(function()
  VarFurycheckCl = 0
  VarCooldownSync = 0
  VarFurycheckEs = 0
  VarFurycheckSs = 0
  VarFurycheckLb = 0
  VarOcpoolSs = 0
  VarOcpoolCl = 0
  VarOcpoolLl = 0
  VarFurycheckLl = 0
  VarFurycheckFb = 0
  VarClpoolLl = 0
  VarClpoolSs = 0
  VarFreezerburnEnabled = 0
  VarOcpool = 0
  VarOcpoolFb = 0
  VarRockslideEnabled = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {8, 5}
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


local function EvaluateCycleStormstrike72(TargetUnit)
  return Cache.EnemiesCount[8] > 1 and S.LightningConduit:AzeriteEnabled() and not TargetUnit:DebuffP(S.LightningConduitDebuff) and bool(VarFurycheckSs)
end

local function EvaluateTargetIfFilterLavaLash200(TargetUnit)
  return TargetUnit:DebuffStackP(S.PrimalPrimerDebuff)
end

local function EvaluateTargetIfLavaLash215(TargetUnit)
  return S.PrimalPrimer:AzeriteRank() >= 2 and TargetUnit:DebuffStackP(S.PrimalPrimerDebuff) == 10 and bool(VarFurycheckLl) and bool(VarClpoolLl)
end

local function EvaluateCycleStormstrike226(TargetUnit)
  return Cache.EnemiesCount[8] > 1 and S.LightningConduit:AzeriteEnabled() and not TargetUnit:DebuffP(S.LightningConduitDebuff) and bool(VarFurycheckSs)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Asc, Cds, DefaultCore, Filler, FreezerburnCore, Maintenance, Opener, Priority
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 4"; end
    end
    -- lightning_shield
    if S.LightningShield:IsCastableP() then
      if HR.Cast(S.LightningShield) then return "lightning_shield 6"; end
    end
  end
  Asc = function()
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 8"; end
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractionalP() > 1.7) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 22"; end
    end
    -- windstrike
    if S.Windstrike:IsCastableP() then
      if HR.Cast(S.Windstrike) then return "windstrike 32"; end
    end
  end
  Cds = function()
    -- bloodlust,if=azerite.ancestral_resonance.enabled
    -- berserking,if=variable.cooldown_sync
    if S.Berserking:IsCastableP() and HR.CDsON() and (bool(VarCooldownSync)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 35"; end
    end
    -- blood_fury,if=variable.cooldown_sync
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(VarCooldownSync)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 39"; end
    end
    -- fireblood,if=variable.cooldown_sync
    if S.Fireblood:IsCastableP() and HR.CDsON() and (bool(VarCooldownSync)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 43"; end
    end
    -- ancestral_call,if=variable.cooldown_sync
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (bool(VarCooldownSync)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 47"; end
    end
    -- potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable() and feral_spirit.remains > 5 or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 51"; end
    end
    -- feral_spirit
    if S.FeralSpirit:IsCastableP() then
      if HR.Cast(S.FeralSpirit) then return "feral_spirit 57"; end
    end
    -- ascendance,if=cooldown.strike.remains>0
    if S.Ascendance:IsCastableP() and (S.WindStrike:CooldownRemainsP() > 0 or S.Stormstrike:CooldownRemainsP() > 0) then
      if HR.Cast(S.Ascendance) then return "ascendance 59"; end
    end
    -- earth_elemental
  end
  DefaultCore = function()
    -- earthen_spike,if=variable.furyCheck_ES
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheckEs)) then
      if HR.Cast(S.EarthenSpike) then return "earthen_spike 64"; end
    end
    -- stormstrike,cycle_targets=1,if=active_enemies>1&azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() then
      if HR.CastCycle(S.Stormstrike, 8, EvaluateCycleStormstrike72) then return "stormstrike 86" end
    end
    -- stormstrike,if=buff.stormbringer.up|(active_enemies>1&buff.gathering_storms.up&variable.furyCheck_SS)
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or (Cache.EnemiesCount[8] > 1 and Player:BuffP(S.GatheringStormsBuff) and bool(VarFurycheckSs))) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 87"; end
    end
    -- crash_lightning,if=active_enemies>=3&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 101"; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck_LB&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and bool(VarFurycheckLb) and Player:Maelstrom() >= 40) then
      if HR.Cast(S.LightningBolt) then return "lightning_bolt 113"; end
    end
    -- stormstrike,if=variable.OCPool_SS&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() and (bool(VarOcpoolSs) and bool(VarFurycheckSs)) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 125"; end
    end
  end
  Filler = function()
    -- sundering
    if S.Sundering:IsCastableP() then
      if HR.Cast(S.Sundering) then return "sundering 131"; end
    end
    -- crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (S.ForcefulWinds:IsAvailable() and Cache.EnemiesCount[8] > 1 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 133"; end
    end
    -- flametongue,if=talent.searing_assault.enabled
    if S.Flametongue:IsCastableP() and (S.SearingAssault:IsAvailable()) then
      if HR.Cast(S.Flametongue) then return "flametongue 147"; end
    end
    -- lava_lash,if=talent.hot_hand.enabled&buff.hot_hand.react
    if S.LavaLash:IsCastableP() and (S.HotHand:IsAvailable() and bool(Player:BuffStackP(S.HotHandBuff))) then
      if HR.Cast(S.LavaLash) then return "lava_lash 151"; end
    end
    -- crash_lightning,if=active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] > 1 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 157"; end
    end
    -- rockbiter,if=maelstrom<70&!buff.strength_of_earth.up
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 70 and not Player:BuffP(S.StrengthofEarthBuff)) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 169"; end
    end
    -- crash_lightning,if=talent.crashing_storm.enabled&variable.OCPool_CL
    if S.CrashLightning:IsCastableP() and (S.CrashingStorm:IsAvailable() and bool(VarOcpoolCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 173"; end
    end
    -- lava_lash,if=variable.OCPool_LL&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (bool(VarOcpoolLl) and bool(VarFurycheckLl)) then
      if HR.Cast(S.LavaLash) then return "lava_lash 179"; end
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() then
      if HR.Cast(S.Rockbiter) then return "rockbiter 185"; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8+gcd&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 + Player:GCD() and bool(VarFurycheckFb)) then
      if HR.Cast(S.Frostbrand) then return "frostbrand 187"; end
    end
    -- flametongue
    if S.Flametongue:IsCastableP() then
      if HR.Cast(S.Flametongue) then return "flametongue 195"; end
    end
  end
  FreezerburnCore = function()
    -- lava_lash,target_if=max:debuff.primal_primer.stack,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack=10&variable.furyCheck_LL&variable.CLPool_LL
    if S.LavaLash:IsCastableP() then
      if HR.CastTargetIf(S.LavaLash, 8, "max", EvaluateTargetIfFilterLavaLash200, EvaluateTargetIfLavaLash215) then return "lava_lash 217" end
    end
    -- earthen_spike,if=variable.furyCheck_ES
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheckEs)) then
      if HR.Cast(S.EarthenSpike) then return "earthen_spike 218"; end
    end
    -- stormstrike,cycle_targets=1,if=active_enemies>1&azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() then
      if HR.CastCycle(S.Stormstrike, 8, EvaluateCycleStormstrike226) then return "stormstrike 240" end
    end
    -- stormstrike,if=buff.stormbringer.up|(active_enemies>1&buff.gathering_storms.up&variable.furyCheck_SS)
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or (Cache.EnemiesCount[8] > 1 and Player:BuffP(S.GatheringStormsBuff) and bool(VarFurycheckSs))) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 241"; end
    end
    -- crash_lightning,if=active_enemies>=3&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 255"; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck_LB&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and bool(VarFurycheckLb) and Player:Maelstrom() >= 40) then
      if HR.Cast(S.LightningBolt) then return "lightning_bolt 267"; end
    end
    -- lava_lash,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack>7&variable.furyCheck_LL&variable.CLPool_LL
    if S.LavaLash:IsCastableP() and (S.PrimalPrimer:AzeriteRank() >= 2 and Target:DebuffStackP(S.PrimalPrimerDebuff) > 7 and bool(VarFurycheckLl) and bool(VarClpoolLl)) then
      if HR.Cast(S.LavaLash) then return "lava_lash 279"; end
    end
    -- stormstrike,if=variable.OCPool_SS&variable.furyCheck_SS&variable.CLPool_SS
    if S.Stormstrike:IsCastableP() and (bool(VarOcpoolSs) and bool(VarFurycheckSs) and bool(VarClpoolSs)) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 289"; end
    end
    -- lava_lash,if=debuff.primal_primer.stack=10&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (Target:DebuffStackP(S.PrimalPrimerDebuff) == 10 and bool(VarFurycheckLl)) then
      if HR.Cast(S.LavaLash) then return "lava_lash 297"; end
    end
  end
  Maintenance = function()
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      if HR.Cast(S.Flametongue) then return "flametongue 303"; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(VarFurycheckFb)) then
      if HR.Cast(S.Frostbrand) then return "frostbrand 307"; end
    end
  end
  Opener = function()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 15 and HL.CombatTime() < Player:GCD()) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 315"; end
    end
  end
  Priority = function()
    -- crash_lightning,if=active_enemies>=(8-(talent.forceful_winds.enabled*3))&variable.freezerburn_enabled&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= (8 - (num(S.ForcefulWinds:IsAvailable()) * 3)) and bool(VarFreezerburnEnabled) and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 317"; end
    end
    -- lava_lash,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack=10&active_enemies=1&variable.freezerburn_enabled&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (S.PrimalPrimer:AzeriteRank() >= 2 and Target:DebuffStackP(S.PrimalPrimerDebuff) == 10 and Cache.EnemiesCount[8] == 1 and bool(VarFreezerburnEnabled) and bool(VarFurycheckLl)) then
      if HR.Cast(S.LavaLash) then return "lava_lash 333"; end
    end
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1 and bool(VarFurycheckCl)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 349"; end
    end
    -- fury_of_air,if=!buff.fury_of_air.up&maelstrom>=20&spell_targets.fury_of_air_damage>=(1+variable.freezerburn_enabled)
    if S.FuryofAir:IsCastableP() and (not Player:BuffP(S.FuryofAirBuff) and Player:Maelstrom() >= 20 and Cache.EnemiesCount[5] >= (1 + VarFreezerburnEnabled)) then
      if HR.Cast(S.FuryofAir) then return "fury_of_air 363"; end
    end
    -- fury_of_air,if=buff.fury_of_air.up&&spell_targets.fury_of_air_damage<(1+variable.freezerburn_enabled)
    if S.FuryofAir:IsCastableP() and (Player:BuffP(S.FuryofAirBuff) and true and Cache.EnemiesCount[5] < (1 + VarFreezerburnEnabled)) then
      if HR.Cast(S.FuryofAir) then return "fury_of_air 369"; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<=2*gcd
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) <= 2 * Player:GCD()) then
      if HR.Cast(S.TotemMastery) then return "totem_mastery 375"; end
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if HR.Cast(S.Sundering) then return "sundering 379"; end
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractionalP() > 1.7) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 389"; end
    end
    -- frostbrand,if=(azerite.natural_harmony.enabled&buff.natural_harmony_frost.remains<=2*gcd)&talent.hailstorm.enabled&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyFrostBuff) <= 2 * Player:GCD()) and S.Hailstorm:IsAvailable() and bool(VarFurycheckFb)) then
      if HR.Cast(S.Frostbrand) then return "frostbrand 399"; end
    end
    -- flametongue,if=(azerite.natural_harmony.enabled&buff.natural_harmony_fire.remains<=2*gcd)
    if S.Flametongue:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyFireBuff) <= 2 * Player:GCD())) then
      if HR.Cast(S.Flametongue) then return "flametongue 409"; end
    end
    -- rockbiter,if=(azerite.natural_harmony.enabled&buff.natural_harmony_nature.remains<=2*gcd)&maelstrom<70
    if S.Rockbiter:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyNatureBuff) <= 2 * Player:GCD()) and Player:Maelstrom() < 70) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 415"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled then
      if HR.CastAnnotated(S.WindShear, false, "Interrupt") then return "wind_shear 422"; end
    end
    -- variable,name=cooldown_sync,value=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
    if (true) then
      VarCooldownSync = num((S.Ascendance:IsAvailable() and (Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50)) or (not S.Ascendance:IsAvailable() and (feral_spirit.remains > 5 or S.FeralSpirit:CooldownRemainsP() > 50)))
    end
    -- variable,name=furyCheck_SS,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.stormstrike.cost))
    if (true) then
      VarFurycheckSs = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.Stormstrike:Cost())))
    end
    -- variable,name=furyCheck_LL,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.lava_lash.cost))
    if (true) then
      VarFurycheckLl = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.LavaLash:Cost())))
    end
    -- variable,name=furyCheck_CL,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.crash_lightning.cost))
    if (true) then
      VarFurycheckCl = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.CrashLightning:Cost())))
    end
    -- variable,name=furyCheck_FB,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.frostbrand.cost))
    if (true) then
      VarFurycheckFb = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.Frostbrand:Cost())))
    end
    -- variable,name=furyCheck_ES,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.earthen_spike.cost))
    if (true) then
      VarFurycheckEs = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.EarthenSpike:Cost())))
    end
    -- variable,name=furyCheck_LB,value=maelstrom>=(talent.fury_of_air.enabled*(6+40))
    if (true) then
      VarFurycheckLb = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + 40)))
    end
    -- variable,name=OCPool,value=(active_enemies>1|(cooldown.lightning_bolt.remains>=2*gcd))
    if (true) then
      VarOcpool = num((Cache.EnemiesCount[8] > 1 or (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD())))
    end
    -- variable,name=OCPool_SS,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.stormstrike.cost)))
    if (true) then
      VarOcpoolSs = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.Stormstrike:Cost()))))
    end
    -- variable,name=OCPool_LL,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.lava_lash.cost)))
    if (true) then
      VarOcpoolLl = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.LavaLash:Cost()))))
    end
    -- variable,name=OCPool_CL,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.crash_lightning.cost)))
    if (true) then
      VarOcpoolCl = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.CrashLightning:Cost()))))
    end
    -- variable,name=OCPool_FB,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.frostbrand.cost)))
    if (true) then
      VarOcpoolFb = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.Frostbrand:Cost()))))
    end
    -- variable,name=CLPool_LL,value=active_enemies=1|maelstrom>=(action.crash_lightning.cost+action.lava_lash.cost)
    if (true) then
      VarClpoolLl = num(Cache.EnemiesCount[8] == 1 or Player:Maelstrom() >= (S.CrashLightning:Cost() + S.LavaLash:Cost()))
    end
    -- variable,name=CLPool_SS,value=active_enemies=1|maelstrom>=(action.crash_lightning.cost+action.stormstrike.cost)
    if (true) then
      VarClpoolSs = num(Cache.EnemiesCount[8] == 1 or Player:Maelstrom() >= (S.CrashLightning:Cost() + S.Stormstrike:Cost()))
    end
    -- variable,name=freezerburn_enabled,value=(talent.hot_hand.enabled&talent.hailstorm.enabled&azerite.primal_primer.enabled)
    if (true) then
      VarFreezerburnEnabled = num((S.HotHand:IsAvailable() and S.Hailstorm:IsAvailable() and S.PrimalPrimer:AzeriteEnabled()))
    end
    -- variable,name=rockslide_enabled,value=(!variable.freezerburn_enabled&(talent.boulderfist.enabled&talent.landslide.enabled&azerite.strength_of_earth.enabled))
    if (true) then
      VarRockslideEnabled = num((not bool(VarFreezerburnEnabled) and (S.Boulderfist:IsAvailable() and S.Landslide:IsAvailable() and S.StrengthofEarth:AzeriteEnabled())))
    end
    -- auto_attack
    -- use_items
    -- call_action_list,name=opener
    if (true) then
      local ShouldReturn = Opener(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=asc,if=buff.ascendance.up
    if (Player:BuffP(S.AscendanceBuff)) then
      local ShouldReturn = Asc(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=priority
    if (true) then
      local ShouldReturn = Priority(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=maintenance,if=active_enemies<3
    if (Cache.EnemiesCount[8] < 3) then
      local ShouldReturn = Maintenance(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=freezerburn_core,if=variable.freezerburn_enabled
    if (bool(VarFreezerburnEnabled)) then
      local ShouldReturn = FreezerburnCore(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=default_core,if=!variable.freezerburn_enabled
    if (not bool(VarFreezerburnEnabled)) then
      local ShouldReturn = DefaultCore(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=maintenance,if=active_enemies>=3
    if (Cache.EnemiesCount[8] >= 3) then
      local ShouldReturn = Maintenance(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=filler
    if (true) then
      local ShouldReturn = Filler(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(263, APL)
