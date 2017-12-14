--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- AethysCore
local AC     = AethysCore
local Cache  = AethysCache
local Unit   = AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = AC.Spell
local Item   = AC.Item
-- AethysRotation
local AR     = AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Shaman then Spell.Shaman = {} end
Spell.Shaman.Enhancement = {
  LightningShield                       = Spell(),
  EarthenSpike                          = Spell(188089),
  DoomWinds                             = Spell(204945),
  Strike                                = Spell(),
  Windstrike                            = Spell(115356),
  Rockbiter                             = Spell(193786),
  Landslide                             = Spell(197992),
  LandslideBuff                         = Spell(202004),
  FuryofAir                             = Spell(197211),
  CrashLightning                        = Spell(187874),
  AlphaWolf                             = Spell(198434),
  FeralSpirit                           = Spell(51533),
  Flametongue                           = Spell(193796),
  FlametongueBuff                       = Spell(194084),
  Frostbrand                            = Spell(196834),
  Hailstorm                             = Spell(210853),
  FrostbrandBuff                        = Spell(196834),
  Bloodlust                             = Spell(2825),
  Berserking                            = Spell(26297),
  AscendanceBuff                        = Spell(114051),
  BloodFury                             = Spell(20572),
  Ascendance                            = Spell(114051),
  Boulderfist                           = Spell(246035),
  EarthenSpikeDebuff                    = Spell(188089),
  CrashLightningBuff                    = Spell(187874),
  Windsong                              = Spell(201898),
  CrashingStorm                         = Spell(192246),
  ForceoftheMountainBuff                = Spell(),
  Stormstrike                           = Spell(17364),
  StormbringerBuff                      = Spell(201845),
  LightningBolt                         = Spell(187837),
  Overcharge                            = Spell(210727),
  LavaLash                              = Spell(60103),
  ExposedElementsDebuff                 = Spell(252151),
  LashingFlamesDebuff                   = Spell(240842),
  HotHandBuff                           = Spell(215785),
  Sundering                             = Spell(197214),
  WindShear                             = Spell(57994),
  LightningCrashBuff                    = Spell(242284),
  AlphaWolfBuff                         = Spell(198434),
  UseItems                              = Spell()
};
local S = Spell.Shaman.Enhancement;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
  ProlongedPower                   = Item(142117),
  Item151819                       = Item(151819),
  Item137084                       = Item(137084)
};
local I = Item.Shaman.Enhancement;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Shaman.Commons,
  Enhancement = AR.GUISettings.APL.Shaman.Enhancement
};

-- Variables
local VarFurycheck45 = 0;
local VarFurycheck25 = 0;
local VarOcpool70 = 0;
local VarFurycheck80 = 0;
local VarAkainuequipped = 0;
local VarAkainuas = 0;
local VarLightningcrashnotup = 0;
local VarAlphawolfcheck = 0;
local VarOcpool60 = 0;
local VarHailstormcheck = 0;
local VarFurycheck70 = 0;
local VarHeartequipped = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- lightning_shield
    if S.LightningShield:IsCastableP() and (true) then
      if AR.Cast(S.LightningShield) then return ""; end
    end
  end
  local function Asc()
    -- earthen_spike
    if S.EarthenSpike:IsCastableP() and (true) then
      if AR.Cast(S.EarthenSpike) then return ""; end
    end
    -- doom_winds,if=cooldown.strike.up
    if S.DoomWinds:IsCastableP() and (S.Strike:CooldownUpP()) then
      if AR.Cast(S.DoomWinds) then return ""; end
    end
    -- windstrike
    if S.Windstrike:IsCastableP() and (true) then
      if AR.Cast(S.Windstrike) then return ""; end
    end
  end
  local function Buffs()
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff)) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- fury_of_air,if=!ticking&maelstrom>22
    if S.FuryofAir:IsCastableP() and (not Player:BuffP(S.FuryofAir) and Player:Maelstrom() > 22) then
      if AR.Cast(S.FuryofAir) then return ""; end
    end
    -- crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
    if S.CrashLightning:IsCastableP() and (bool(S.AlphaWolf:ArtifactRank()) and Player:PrevGCDP(1, S.FeralSpirit)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(VarFurycheck45)) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- flametongue,if=buff.flametongue.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
    if S.Flametongue:IsCastableP() and (Player:BuffRemainsP(S.FlametongueBuff) < 6 + Player:GCD() and S.DoomWinds:CooldownRemainsP() < Player:GCD() * 2) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 6 + Player:GCD() and S.DoomWinds:CooldownRemainsP() < Player:GCD() * 2) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
  end
  local function Cds()
    -- bloodlust,if=target.health.pct<25|time>0.500
    if S.Bloodlust:IsCastableP() and (Target:HealthPercentage() < 25 or AC.CombatTime() > 0.500) then
      if AR.Cast(S.Bloodlust) then return ""; end
    end
    -- berserking,if=buff.ascendance.up|(cooldown.doom_winds.up)|level<100
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (S.DoomWinds:CooldownUpP()) or Player:level() < 100) then
      if AR.Cast(S.Berserking, Settings.Enhancement.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (feral_spirit.remains > 5) or Player:level() < 100) then
      if AR.Cast(S.BloodFury, Settings.Enhancement.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable() and feral_spirit.remains > 5 or Target:TimeToDie() <= 60) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- feral_spirit
    if S.FeralSpirit:IsCastableP() and (true) then
      if AR.Cast(S.FeralSpirit) then return ""; end
    end
    -- doom_winds,if=cooldown.ascendance.remains>6|talent.boulderfist.enabled|debuff.earthen_spike.up
    if S.DoomWinds:IsCastableP() and (S.Ascendance:CooldownRemainsP() > 6 or S.Boulderfist:IsAvailable() or Target:DebuffP(S.EarthenSpikeDebuff)) then
      if AR.Cast(S.DoomWinds) then return ""; end
    end
    -- ascendance,if=(cooldown.strike.remains>0)&buff.ascendance.down
    if S.Ascendance:IsCastableP() and ((S.Strike:CooldownRemainsP() > 0) and Player:BuffDownP(S.AscendanceBuff)) then
      if AR.Cast(S.Ascendance) then return ""; end
    end
  end
  local function Core()
    -- earthen_spike,if=variable.furyCheck25
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheck25)) then
      if AR.Cast(S.EarthenSpike) then return ""; end
    end
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and Cache.EnemiesCount[8] >= 2) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- windsong
    if S.Windsong:IsCastableP() and (true) then
      if AR.Cast(S.Windsong) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 8 or (Cache.EnemiesCount[8] >= 6 and S.CrashingStorm:IsAvailable())) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- windstrike
    if S.Windstrike:IsCastableP() and (true) then
      if AR.Cast(S.Windstrike) then return ""; end
    end
    -- rockbiter,if=buff.force_of_the_mountain.up&charges_fractional>1.7&active_enemies<=4
    if S.Rockbiter:IsCastableP() and (Player:BuffP(S.ForceoftheMountainBuff) and S.Rockbiter:ChargesFractional() > 1.7 and Cache.EnemiesCount[8] <= 4) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- stormstrike,if=buff.stormbringer.up&variable.furyCheck25
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) and bool(VarFurycheck25)) then
      if AR.Cast(S.Stormstrike) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 4 or (Cache.EnemiesCount[8] >= 2 and S.CrashingStorm:IsAvailable())) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- rockbiter,if=buff.force_of_the_mountain.up
    if S.Rockbiter:IsCastableP() and (Player:BuffP(S.ForceoftheMountainBuff)) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and bool(VarFurycheck45) and Player:Maelstrom() >= 40) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- lava_lash,if=(maelstrom>=50&variable.OCPool70&variable.furyCheck80&debuff.exposed_elements.up&debuff.lashing_flames.stack>90)|(buff.hot_hand.react&((variable.akainuEquipped&buff.frostbrand.up)|(!variable.akainuEquipped)))
    if S.LavaLash:IsCastableP() and ((Player:Maelstrom() >= 50 and bool(VarOcpool70) and bool(VarFurycheck80) and Target:DebuffP(S.ExposedElementsDebuff) and Target:DebuffStackP(S.LashingFlamesDebuff) > 90) or (bool(Player:BuffStackP(S.HotHandBuff)) and ((bool(VarAkainuequipped) and Player:BuffP(S.FrostbrandBuff)) or (not bool(VarAkainuequipped))))) then
      if AR.Cast(S.LavaLash) then return ""; end
    end
    -- stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck45)|(talent.overcharge.enabled&variable.furyCheck80)
    if S.Stormstrike:IsCastableP() and ((not S.Overcharge:IsAvailable() and bool(VarFurycheck45)) or (S.Overcharge:IsAvailable() and bool(VarFurycheck80))) then
      if AR.Cast(S.Stormstrike) then return ""; end
    end
    -- frostbrand,if=variable.akainuAS
    if S.Frostbrand:IsCastableP() and (bool(VarAkainuas)) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if AR.Cast(S.Sundering) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=3|variable.LightningCrashNotUp|variable.alphaWolfCheck
    if S.CrashLightning:IsCastableP() and (Cache.EnemiesCount[8] >= 3 or bool(VarLightningcrashnotup) or bool(VarAlphawolfcheck)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
  end
  local function Filler()
    -- rockbiter,if=maelstrom<120&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 120 and S.Rockbiter:ChargesFractional() > 1.7) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- flametongue,if=buff.flametongue.remains<4.8
    if S.Flametongue:IsCastableP() and (Player:BuffRemainsP(S.FlametongueBuff) < 4.8) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
    -- crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
    if S.CrashLightning:IsCastableP() and ((S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) and Target:DebuffP(S.EarthenSpikeDebuff) and Player:Maelstrom() >= 40 and bool(VarOcpool60)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 and Player:Maelstrom() > 40) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- frostbrand,if=variable.akainuEquipped&!buff.frostbrand.up&maelstrom>=75
    if S.Frostbrand:IsCastableP() and (bool(VarAkainuequipped) and not Player:BuffP(S.FrostbrandBuff) and Player:Maelstrom() >= 75) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- sundering
    if S.Sundering:IsCastableP() and (true) then
      if AR.Cast(S.Sundering) then return ""; end
    end
    -- lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
    if S.LavaLash:IsCastableP() and (Player:Maelstrom() >= 50 and bool(VarOcpool70) and bool(VarFurycheck80)) then
      if AR.Cast(S.LavaLash) then return ""; end
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() and (true) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
    if S.CrashLightning:IsCastableP() and ((Player:Maelstrom() >= 65 or S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) and bool(VarOcpool60) and bool(VarFurycheck45)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue
    if S.Flametongue:IsCastableP() and (true) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
  end
  local function Opener()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 15 and AC.CombatTime() < Player:GCD()) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- wind_shear
  if S.WindShear:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR.CastAnnotated(S.WindShear, false, "Interrupt") then return ""; end
  end
  -- variable,name=hailstormCheck,value=((talent.hailstorm.enabled&!buff.frostbrand.up)|!talent.hailstorm.enabled)
  if (true) then
    VarHailstormcheck = num(((S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff)) or not S.Hailstorm:IsAvailable()))
  end
  -- variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
  if (true) then
    VarFurycheck80 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 80)))
  end
  -- variable,name=furyCheck70,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>70))
  if (true) then
    VarFurycheck70 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 70)))
  end
  -- variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
  if (true) then
    VarFurycheck45 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and Player:Maelstrom() > 45)))
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
  -- variable,name=heartEquipped,value=(equipped.151819)
  if (true) then
    VarHeartequipped = num((I.Item151819:IsEquipped()))
  end
  -- variable,name=akainuEquipped,value=(equipped.137084)
  if (true) then
    VarAkainuequipped = num((I.Item137084:IsEquipped()))
  end
  -- variable,name=akainuAS,value=(variable.akainuEquipped&buff.hot_hand.react&!buff.frostbrand.up)
  if (true) then
    VarAkainuas = num((bool(VarAkainuequipped) and bool(Player:BuffStackP(S.HotHandBuff)) and not Player:BuffP(S.FrostbrandBuff)))
  end
  -- variable,name=LightningCrashNotUp,value=(!buff.lightning_crash.up&set_bonus.tier20_2pc)
  if (true) then
    VarLightningcrashnotup = num((not Player:BuffP(S.LightningCrashBuff) and AC.Tier20_2Pc))
  end
  -- variable,name=alphaWolfCheck,value=((pet.frost_wolf.buff.alpha_wolf.remains<2&pet.fiery_wolf.buff.alpha_wolf.remains<2&pet.lightning_wolf.buff.alpha_wolf.remains<2)&feral_spirit.remains>4)
  if (true) then
    VarAlphawolfcheck = num(((Pet:BuffRemainsP(S.AlphaWolfBuff) < 2 and Pet:BuffRemainsP(S.AlphaWolfBuff) < 2 and Pet:BuffRemainsP(S.AlphaWolfBuff) < 2) and feral_spirit.remains > 4))
  end
  -- auto_attack
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
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