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
  LightningShield                       = Spell(),
  EarthenSpike                          = Spell(188089),
  CrashLightning                        = Spell(187874),
  CrashLightningBuff                    = Spell(187874),
  Rockbiter                             = Spell(193786),
  Landslide                             = Spell(197992),
  LandslideBuff                         = Spell(202004),
  Windstrike                            = Spell(115356),
  FuryofAir                             = Spell(197211),
  FuryofAirBuff                         = Spell(197211),
  Flametongue                           = Spell(193796),
  FlametongueBuff                       = Spell(194084),
  Frostbrand                            = Spell(196834),
  Hailstorm                             = Spell(210853),
  FrostbrandBuff                        = Spell(196834),
  TotemMastery                          = Spell(),
  ResonanceTotemBuff                    = Spell(),
  Bloodlust                             = Spell(2825),
  Berserking                            = Spell(26297),
  AscendanceBuff                        = Spell(114051),
  BloodFury                             = Spell(20572),
  Ascendance                            = Spell(114051),
  FeralSpirit                           = Spell(51533),
  Strike                                = Spell(),
  EarthElemental                        = Spell(),
  Sundering                             = Spell(197214),
  SunderingDebuff                       = Spell(197214),
  Stormstrike                           = Spell(17364),
  StormbringerBuff                      = Spell(201845),
  GatheringStormsBuff                   = Spell(),
  LightningBolt                         = Spell(187837),
  Overcharge                            = Spell(210727),
  ForcefulWinds                         = Spell(),
  SearingAssault                        = Spell(),
  LavaLash                              = Spell(60103),
  HotHandBuff                           = Spell(215785),
  CrashingStorm                         = Spell(192246),
  EarthenSpikeDebuff                    = Spell(188089),
  WindShear                             = Spell(57994)
};
local S = Spell.Shaman.Enhancement;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
  ProlongedPower                   = Item(142117)
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
local VarFurycheck45 = 0;
local VarFurycheck25 = 0;
local VarFurycheck35 = 0;
local VarFurycheck80 = 0;
local VarOcpool60 = 0;
local VarOcpool70 = 0;

local EnemyRanges = {8}
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
  local Precombat, Asc, Buffs, Cds, Core, Filler, Opener
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- lightning_shield
    if S.LightningShield:IsCastableP() and (true) then
      if HR.Cast(S.LightningShield) then return ""; end
    end
  end
  Asc = function()
    -- earthen_spike
    if S.EarthenSpike:IsCastableP() and (true) then
      if HR.Cast(S.EarthenSpike) then return ""; end
    end
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractional() > 1.7) then
      if HR.Cast(S.Rockbiter) then return ""; end
    end
    -- windstrike
    if S.Windstrike:IsCastableP() and (true) then
      if HR.Cast(S.Windstrike) then return ""; end
    end
  end
  Buffs = function()
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractional() > 1.7) then
      if HR.Cast(S.Rockbiter) then return ""; end
    end
    -- fury_of_air,if=!ticking&maelstrom>22
    if S.FuryofAir:IsCastableP() and (not Player:BuffP(S.FuryofAirBuff) and Player:Maelstrom() > 22) then
      if HR.Cast(S.FuryofAir) then return ""; end
    end
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      if HR.Cast(S.Flametongue) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(VarFurycheck45)) then
      if HR.Cast(S.Frostbrand) then return ""; end
    end
    -- flametongue,if=buff.flametongue.remains<6+gcd
    if S.Flametongue:IsCastableP() and (Player:BuffRemainsP(S.FlametongueBuff) < 6 + Player:GCD()) then
      if HR.Cast(S.Flametongue) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 6 + Player:GCD()) then
      if HR.Cast(S.Frostbrand) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<2
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
  end
  Cds = function()
    -- bloodlust,if=target.health.pct<25|time>0.500
    if S.Bloodlust:IsCastableP() and (Target:HealthPercentage() < 25 or HL.CombatTime() > 0.500) then
      if HR.Cast(S.Bloodlust) then return ""; end
    end
    -- berserking,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (feral_spirit.remains > 5) or Player:level() < 100) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (feral_spirit.remains > 5) or Player:level() < 100) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable() and feral_spirit.remains > 5 or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- feral_spirit
    if S.FeralSpirit:IsCastableP() and (true) then
      if HR.Cast(S.FeralSpirit) then return ""; end
    end
    -- ascendance,if=cooldown.strike.remains>0
    if S.Ascendance:IsCastableP() and (S.Strike:CooldownRemainsP() > 0) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- earth_elemental
    if S.EarthElemental:IsCastableP() and (true) then
      if HR.Cast(S.EarthElemental) then return ""; end
    end
  end
  Core = function()
    -- earthen_spike,if=variable.furyCheck25
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheck25)) then
      if HR.Cast(S.EarthenSpike) then return ""; end
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if HR.Cast(S.Sundering) then return ""; end
    end
    -- stormstrike,if=buff.stormbringer.up|buff.gathering_storms.up
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or Player:BuffP(S.GatheringStormsBuff)) then
      if HR.Cast(S.Stormstrike) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=3
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and bool(VarFurycheck45) and Player:Maelstrom() >= 40) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck35)|(talent.overcharge.enabled&variable.furyCheck80)
    if S.Stormstrike:IsCastableP() and ((not S.Overcharge:IsAvailable() and bool(VarFurycheck35)) or (S.Overcharge:IsAvailable() and bool(VarFurycheck80))) then
      if HR.Cast(S.Stormstrike) then return ""; end
    end
    -- sundering
    if S.Sundering:IsCastableP() and (true) then
      if HR.Cast(S.Sundering) then return ""; end
    end
    -- crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1
    if S.CrashLightning:IsCastableP() and (S.ForcefulWinds:IsAvailable() and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue,if=talent.searing_assault.enabled
    if S.Flametongue:IsCastableP() and (S.SearingAssault:IsAvailable()) then
      if HR.Cast(S.Flametongue) then return ""; end
    end
    -- lava_lash,if=buff.hot_hand.react
    if S.LavaLash:IsCastableP() and (bool(Player:BuffStackP(S.HotHandBuff))) then
      if HR.Cast(S.LavaLash) then return ""; end
    end
    -- crash_lightning,if=active_enemies>1
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
  end
  Filler = function()
    -- rockbiter,if=maelstrom<70
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 70) then
      if HR.Cast(S.Rockbiter) then return ""; end
    end
    -- flametongue,if=talent.searing_assault.enabled|buff.flametongue.remains<4.8
    if S.Flametongue:IsCastableP() and (S.SearingAssault:IsAvailable() or Player:BuffRemainsP(S.FlametongueBuff) < 4.8) then
      if HR.Cast(S.Flametongue) then return ""; end
    end
    -- crash_lightning,if=talent.crashing_storm.enabled&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
    if S.CrashLightning:IsCastableP() and (S.CrashingStorm:IsAvailable() and Target:DebuffP(S.EarthenSpikeDebuff) and Player:Maelstrom() >= 40 and bool(VarOcpool60)) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 and Player:Maelstrom() > 40) then
      if HR.Cast(S.Frostbrand) then return ""; end
    end
    -- lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
    if S.LavaLash:IsCastableP() and (Player:Maelstrom() >= 50 and bool(VarOcpool70) and bool(VarFurycheck80)) then
      if HR.Cast(S.LavaLash) then return ""; end
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() and (true) then
      if HR.Cast(S.Rockbiter) then return ""; end
    end
    -- crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled)&variable.OCPool60&variable.furyCheck45
    if S.CrashLightning:IsCastableP() and ((Player:Maelstrom() >= 65 or S.CrashingStorm:IsAvailable()) and bool(VarOcpool60) and bool(VarFurycheck45)) then
      if HR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue
    if S.Flametongue:IsCastableP() and (true) then
      if HR.Cast(S.Flametongue) then return ""; end
    end
  end
  Opener = function()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 15 and HL.CombatTime() < Player:GCD()) then
      if HR.Cast(S.Rockbiter) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- wind_shear
  if S.WindShear:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled and (true) then
    if HR.CastAnnotated(S.WindShear, false, "Interrupt") then return ""; end
  end
  -- variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&((maelstrom>35&cooldown.lightning_bolt.remains>=3*gcd)|maelstrom>80)))
  if (true) then
    VarFurycheck80 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and ((Player:Maelstrom() > 35 and S.LightningBolt:CooldownRemainsP() >= 3 * Player:GCD()) or Player:Maelstrom() > 80))))
  end
  -- variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
  if (true) then
    VarFurycheck45 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 45)))
  end
  -- variable,name=furyCheck35,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>35))
  if (true) then
    VarFurycheck35 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 35)))
  end
  -- variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
  if (true) then
    VarFurycheck25 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 25)))
  end
  -- variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
  if (true) then
    VarOcpool70 = num((not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 70)))
  end
  -- variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
  if (true) then
    VarOcpool60 = num((not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 60)))
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
  -- call_action_list,name=buffs
  if (true) then
    local ShouldReturn = Buffs(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=cds
  if (true) then
    local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=core
  if (true) then
    local ShouldReturn = Core(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=filler
  if (true) then
    local ShouldReturn = Filler(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(263, APL)
