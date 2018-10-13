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
  Berserking                            = Spell(26297),
  Ascendance                            = Spell(114051),
  AscendanceBuff                        = Spell(114051),
  ElementalSpirits                      = Spell(),
  BloodFury                             = Spell(20572),
  FeralSpirit                           = Spell(51533),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Strike                                = Spell(),
  EarthenSpike                          = Spell(188089),
  Sundering                             = Spell(197214),
  SunderingDebuff                       = Spell(197214),
  Stormstrike                           = Spell(17364),
  LightningConduit                      = Spell(),
  LightningConduitDebuff                = Spell(),
  StormbringerBuff                      = Spell(201845),
  GatheringStormsBuff                   = Spell(),
  LightningBolt                         = Spell(187837),
  Overcharge                            = Spell(210727),
  ForcefulWinds                         = Spell(),
  SearingAssault                        = Spell(),
  LavaLash                              = Spell(60103),
  HotHand                               = Spell(201900),
  HotHandBuff                           = Spell(215785),
  CrashingStorm                         = Spell(192246),
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
local VarFurycheck25 = 0;
local VarOcpool70 = 0;
local VarFurycheck35 = 0;
local VarFurycheck45 = 0;
local VarOcpool60 = 0;
local VarOcpool80 = 0;

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
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
    -- lightning_shield
    if S.LightningShield:IsCastableP() then
      if HR.Cast(S.LightningShield) then return "lightning_shield 6"; end
    end
  end
  Asc = function()
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1 and bool(VarFurycheck25)) then
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
  Buffs = function()
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] > 1 and bool(VarFurycheck25)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 34"; end
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractionalP() > 1.7) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 48"; end
    end
    -- fury_of_air,if=!ticking&maelstrom>=20
    if S.FuryofAir:IsCastableP() and (not Player:BuffP(S.FuryofAirBuff) and Player:Maelstrom() >= 20) then
      if HR.Cast(S.FuryofAir) then return "fury_of_air 58"; end
    end
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      if HR.Cast(S.Flametongue) then return "flametongue 66"; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck25
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(VarFurycheck25)) then
      if HR.Cast(S.Frostbrand) then return "frostbrand 70"; end
    end
    -- flametongue,if=buff.flametongue.remains<4.8+gcd
    if S.Flametongue:IsCastableP() and (Player:BuffRemainsP(S.FlametongueBuff) < 4.8 + Player:GCD()) then
      if HR.Cast(S.Flametongue) then return "flametongue 78"; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8+gcd&variable.furyCheck25
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 + Player:GCD() and bool(VarFurycheck25)) then
      if HR.Cast(S.Frostbrand) then return "frostbrand 82"; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<2
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
      if HR.Cast(S.TotemMastery) then return "totem_mastery 90"; end
    end
  end
  Cds = function()
    -- bloodlust,if=azerite.ancestral_resonance.enabled
    -- berserking,if=(talent.ascendance.enabled&buff.ascendance.up)|(talent.elemental_spirits.enabled&feral_spirit.remains>5)|(!talent.ascendance.enabled&!talent.elemental_spirits.enabled)
    if S.Berserking:IsCastableP() and HR.CDsON() and ((S.Ascendance:IsAvailable() and Player:BuffP(S.AscendanceBuff)) or (S.ElementalSpirits:IsAvailable() and feral_spirit.remains > 5) or (not S.Ascendance:IsAvailable() and not S.ElementalSpirits:IsAvailable())) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 95"; end
    end
    -- blood_fury,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
    if S.BloodFury:IsCastableP() and HR.CDsON() and ((S.Ascendance:IsAvailable() and (Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50)) or (not S.Ascendance:IsAvailable() and (feral_spirit.remains > 5 or S.FeralSpirit:CooldownRemainsP() > 50))) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 107"; end
    end
    -- fireblood,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
    if S.Fireblood:IsCastableP() and HR.CDsON() and ((S.Ascendance:IsAvailable() and (Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50)) or (not S.Ascendance:IsAvailable() and (feral_spirit.remains > 5 or S.FeralSpirit:CooldownRemainsP() > 50))) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 119"; end
    end
    -- ancestral_call,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
    if S.AncestralCall:IsCastableP() and HR.CDsON() and ((S.Ascendance:IsAvailable() and (Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50)) or (not S.Ascendance:IsAvailable() and (feral_spirit.remains > 5 or S.FeralSpirit:CooldownRemainsP() > 50))) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 131"; end
    end
    -- potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable() and feral_spirit.remains > 5 or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 143"; end
    end
    -- feral_spirit
    if S.FeralSpirit:IsCastableP() then
      if HR.Cast(S.FeralSpirit) then return "feral_spirit 149"; end
    end
    -- ascendance,if=cooldown.strike.remains>0
    if S.Ascendance:IsCastableP() and (S.Strike:CooldownRemainsP() > 0) then
      if HR.Cast(S.Ascendance) then return "ascendance 151"; end
    end
    -- earth_elemental
  end
  Core = function()
    -- earthen_spike,if=variable.furyCheck25
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheck25)) then
      if HR.Cast(S.EarthenSpike) then return "earthen_spike 156"; end
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if HR.Cast(S.Sundering) then return "sundering 160"; end
    end
    -- stormstrike,cycle_targets=1,if=azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&active_enemies>1&(buff.stormbringer.up|(variable.OCPool70&variable.furyCheck35))
    if S.Stormstrike:IsCastableP() and (S.LightningConduit:AzeriteEnabled() and not Target:DebuffP(S.LightningConduitDebuff) and Cache.EnemiesCount[8] > 1 and (Player:BuffP(S.StormbringerBuff) or (bool(VarOcpool70) and bool(VarFurycheck35)))) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 170"; end
    end
    -- stormstrike,if=buff.stormbringer.up|(buff.gathering_storms.up&variable.OCPool70&variable.furyCheck35)
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or (Player:BuffP(S.GatheringStormsBuff) and bool(VarOcpool70) and bool(VarFurycheck35))) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 188"; end
    end
    -- crash_lightning,if=active_enemies>=3&variable.furyCheck25
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and bool(VarFurycheck25)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 198"; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck45&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and bool(VarFurycheck45) and Player:Maelstrom() >= 40) then
      if HR.Cast(S.LightningBolt) then return "lightning_bolt 210"; end
    end
    -- stormstrike,if=variable.OCPool70&variable.furyCheck35
    if S.Stormstrike:IsCastableP() and (bool(VarOcpool70) and bool(VarFurycheck35)) then
      if HR.Cast(S.Stormstrike) then return "stormstrike 222"; end
    end
    -- sundering
    if S.Sundering:IsCastableP() then
      if HR.Cast(S.Sundering) then return "sundering 228"; end
    end
    -- crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsCastableP() and (S.ForcefulWinds:IsAvailable() and Cache.EnemiesCount[8] > 1 and bool(VarFurycheck25)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 230"; end
    end
    -- flametongue,if=talent.searing_assault.enabled
    if S.Flametongue:IsCastableP() and (S.SearingAssault:IsAvailable()) then
      if HR.Cast(S.Flametongue) then return "flametongue 244"; end
    end
    -- lava_lash,if=talent.hot_hand.enabled&buff.hot_hand.react
    if S.LavaLash:IsCastableP() and (S.HotHand:IsAvailable() and bool(Player:BuffStackP(S.HotHandBuff))) then
      if HR.Cast(S.LavaLash) then return "lava_lash 248"; end
    end
    -- crash_lightning,if=active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] > 1 and bool(VarFurycheck25)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 254"; end
    end
  end
  Filler = function()
    -- rockbiter,if=maelstrom<70
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 70) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 266"; end
    end
    -- crash_lightning,if=talent.crashing_storm.enabled&variable.OCPool60
    if S.CrashLightning:IsCastableP() and (S.CrashingStorm:IsAvailable() and bool(VarOcpool60)) then
      if HR.Cast(S.CrashLightning) then return "crash_lightning 268"; end
    end
    -- lava_lash,if=variable.OCPool80&variable.furyCheck45
    if S.LavaLash:IsCastableP() and (bool(VarOcpool80) and bool(VarFurycheck45)) then
      if HR.Cast(S.LavaLash) then return "lava_lash 274"; end
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() then
      if HR.Cast(S.Rockbiter) then return "rockbiter 280"; end
    end
    -- flametongue
    if S.Flametongue:IsCastableP() then
      if HR.Cast(S.Flametongue) then return "flametongue 282"; end
    end
  end
  Opener = function()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 15 and HL.CombatTime() < Player:GCD()) then
      if HR.Cast(S.Rockbiter) then return "rockbiter 284"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled then
      if HR.CastAnnotated(S.WindShear, false, "Interrupt") then return "wind_shear 287"; end
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
    -- variable,name=OCPool80,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>80)))
    if (true) then
      VarOcpool80 = num((not S.Overcharge:IsAvailable() or Cache.EnemiesCount[8] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 80))))
    end
    -- variable,name=OCPool70,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>70)))
    if (true) then
      VarOcpool70 = num((not S.Overcharge:IsAvailable() or Cache.EnemiesCount[8] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 70))))
    end
    -- variable,name=OCPool60,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>60)))
    if (true) then
      VarOcpool60 = num((not S.Overcharge:IsAvailable() or Cache.EnemiesCount[8] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[8] == 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 60))))
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
end

HR.SetAPL(263, APL)
