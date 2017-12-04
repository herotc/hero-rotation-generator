--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC =     AethysCore
local Cache =  AethysCache
local Unit =   AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet =    Unit.Pet
local Spell =  AC.Spell
local Item =   AC.Item
-- AethysRotation
local AR =     AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Shaman then Spell.Shaman = {} end
Spell.Shaman.Enhancement = {
  EarthenSpike                          = Spell(),
  DoomWinds                             = Spell(),
  Strike                                = Spell(),
  Windstrike                            = Spell(),
  Rockbiter                             = Spell(),
  Landslide                             = Spell(),
  LandslideBuff                         = Spell(),
  FuryofAir                             = Spell(),
  CrashLightning                        = Spell(),
  FeralSpirit                           = Spell(),
  Flametongue                           = Spell(),
  FlametongueBuff                       = Spell(),
  Frostbrand                            = Spell(),
  Hailstorm                             = Spell(),
  FrostbrandBuff                        = Spell(),
  Bloodlust                             = Spell(),
  Berserking                            = Spell(26297),
  AscendanceBuff                        = Spell(),
  BloodFury                             = Spell(20572),
  Ascendance                            = Spell(),
  Boulderfist                           = Spell(),
  EarthenSpikeDebuff                    = Spell(),
  CrashLightningBuff                    = Spell(),
  Windsong                              = Spell(),
  CrashingStorm                         = Spell(),
  Stormstrike                           = Spell(),
  StormbringerBuff                      = Spell(),
  ForceoftheMountainBuff                = Spell(),
  LightningBolt                         = Spell(),
  Overcharge                            = Spell(),
  LavaLash                              = Spell(),
  HotHandBuff                           = Spell(),
  Sundering                             = Spell(),
  WindShear                             = Spell(),
  LightningCrashBuff                    = Spell(),
  AlphaWolfBuff                         = Spell(),
  AutoAttack                            = Spell(),
  UseItems                              = Spell()
};
local S = Spell.Shaman.Enhancement;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
  ProlongedPower                = Item(142117)
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
local Hailstormcheck = 0;
local Furycheck80 = 0;
local Furycheck70 = 0;
local Furycheck45 = 0;
local Furycheck25 = 0;
local Ocpool70 = 0;
local Ocpool60 = 0;
local Heartequipped = 0;
local Akainuequipped = 0;
local Akainuas = 0;
local Lightningcrashnotup = 0;
local Alphawolfcheck = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
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
    if S.FuryofAir:IsCastableP() and (not bool(ticking) and maelstrom > 22) then
      if AR.Cast(S.FuryofAir) then return ""; end
    end
    -- crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
    if S.CrashLightning:IsCastableP() and (bool(artifact.alpha_wolf.rank) and Player:PrevGCDP(1, S.FeralSpirit)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(Furycheck45)) then
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
    if S.Bloodlust:IsCastableP() and (target.health.pct < 25 or AC.CombatTime() > 0.500) then
      if AR.Cast(S.Bloodlust) then return ""; end
    end
    -- berserking,if=buff.ascendance.up|(cooldown.doom_winds.up)|level<100
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (S.DoomWinds:CooldownUpP()) or level < 100) then
      if AR.Cast(S.Berserking, Settings.Enhancement.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AscendanceBuff) or (feral_spirit.remains > 5) or level < 100) then
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
    if S.EarthenSpike:IsCastableP() and (bool(Furycheck25)) then
      if AR.Cast(S.EarthenSpike) then return ""; end
    end
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
    if S.CrashLightning:IsCastableP() and (not Player:BuffP(S.CrashLightningBuff) and active_enemies >= 2) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- windsong
    if S.Windsong:IsCastableP() and (true) then
      if AR.Cast(S.Windsong) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
    if S.CrashLightning:IsCastableP() and (active_enemies >= 8 or (active_enemies >= 6 and S.CrashingStorm:IsAvailable())) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- windstrike
    if S.Windstrike:IsCastableP() and (true) then
      if AR.Cast(S.Windstrike) then return ""; end
    end
    -- stormstrike,if=buff.stormbringer.up&variable.furyCheck25
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) and bool(Furycheck25)) then
      if AR.Cast(S.Stormstrike) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
    if S.CrashLightning:IsCastableP() and (active_enemies >= 4 or (active_enemies >= 2 and S.CrashingStorm:IsAvailable())) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- rockbiter,if=buff.force_of_the_mountain.up
    if S.Rockbiter:IsCastableP() and (Player:BuffP(S.ForceoftheMountainBuff)) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and bool(Furycheck45) and maelstrom >= 40) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck45)|(talent.overcharge.enabled&variable.furyCheck80)
    if S.Stormstrike:IsCastableP() and ((not S.Overcharge:IsAvailable() and bool(Furycheck45)) or (S.Overcharge:IsAvailable() and bool(Furycheck80))) then
      if AR.Cast(S.Stormstrike) then return ""; end
    end
    -- frostbrand,if=variable.akainuAS
    if S.Frostbrand:IsCastableP() and (bool(Akainuas)) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- lava_lash,if=buff.hot_hand.react&((variable.akainuEquipped&buff.frostbrand.up)|!variable.akainuEquipped)
    if S.LavaLash:IsCastableP() and (bool(Player:BuffStackP(S.HotHandBuff)) and ((bool(Akainuequipped) and Player:BuffP(S.FrostbrandBuff)) or not bool(Akainuequipped))) then
      if AR.Cast(S.LavaLash) then return ""; end
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (active_enemies >= 3) then
      if AR.Cast(S.Sundering) then return ""; end
    end
    -- crash_lightning,if=active_enemies>=3|variable.LightningCrashNotUp|variable.alphaWolfCheck
    if S.CrashLightning:IsCastableP() and (active_enemies >= 3 or bool(Lightningcrashnotup) or bool(Alphawolfcheck)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
  end
  local function Filler()
    -- rockbiter,if=maelstrom<120
    if S.Rockbiter:IsCastableP() and (maelstrom < 120) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- flametongue,if=buff.flametongue.remains<4.8
    if S.Flametongue:IsCastableP() and (Player:BuffRemainsP(S.FlametongueBuff) < 4.8) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
    -- crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
    if S.CrashLightning:IsCastableP() and ((S.CrashingStorm:IsAvailable() or active_enemies >= 2) and Target:DebuffP(S.EarthenSpikeDebuff) and maelstrom >= 40 and bool(Ocpool60)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 and maelstrom > 40) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- frostbrand,if=variable.akainuEquipped&!buff.frostbrand.up&maelstrom>=75
    if S.Frostbrand:IsCastableP() and (bool(Akainuequipped) and not Player:BuffP(S.FrostbrandBuff) and maelstrom >= 75) then
      if AR.Cast(S.Frostbrand) then return ""; end
    end
    -- sundering
    if S.Sundering:IsCastableP() and (true) then
      if AR.Cast(S.Sundering) then return ""; end
    end
    -- lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
    if S.LavaLash:IsCastableP() and (maelstrom >= 50 and bool(Ocpool70) and bool(Furycheck80)) then
      if AR.Cast(S.LavaLash) then return ""; end
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() and (true) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
    -- crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
    if S.CrashLightning:IsCastableP() and ((maelstrom >= 65 or S.CrashingStorm:IsAvailable() or active_enemies >= 2) and bool(Ocpool60) and bool(Furycheck45)) then
      if AR.Cast(S.CrashLightning) then return ""; end
    end
    -- flametongue
    if S.Flametongue:IsCastableP() and (true) then
      if AR.Cast(S.Flametongue) then return ""; end
    end
  end
  local function Opener()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (maelstrom < 15 and AC.CombatTime() < Player:GCD()) then
      if AR.Cast(S.Rockbiter) then return ""; end
    end
  end
  -- wind_shear
  if S.WindShear:IsCastableP() and (true) then
    if AR.Cast(S.WindShear) then return ""; end
  end
  -- variable,name=hailstormCheck,value=((talent.hailstorm.enabled&!buff.frostbrand.up)|!talent.hailstorm.enabled)
  if (true) then
    Hailstormcheck = num(((S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff)) or not S.Hailstorm:IsAvailable()))
  end
  -- variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
  if (true) then
    Furycheck80 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and maelstrom > 80)))
  end
  -- variable,name=furyCheck70,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>70))
  if (true) then
    Furycheck70 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and maelstrom > 70)))
  end
  -- variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
  if (true) then
    Furycheck45 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and maelstrom > 45)))
  end
  -- variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
  if (true) then
    Furycheck25 = num((not S.FuryofAir:IsAvailable() or (S.FuryofAir:IsAvailable() and maelstrom > 25)))
  end
  -- variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
  if (true) then
    Ocpool70 = num((not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and maelstrom > 70)))
  end
  -- variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
  if (true) then
    Ocpool60 = num((not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and maelstrom > 60)))
  end
  -- variable,name=heartEquipped,value=(equipped.151819)
  if (true) then
    Heartequipped = num((Item(151819):IsEquipped()))
  end
  -- variable,name=akainuEquipped,value=(equipped.137084)
  if (true) then
    Akainuequipped = num((Item(137084):IsEquipped()))
  end
  -- variable,name=akainuAS,value=(variable.akainuEquipped&buff.hot_hand.react&!buff.frostbrand.up)
  if (true) then
    Akainuas = num((bool(Akainuequipped) and bool(Player:BuffStackP(S.HotHandBuff)) and not Player:BuffP(S.FrostbrandBuff)))
  end
  -- variable,name=LightningCrashNotUp,value=(!buff.lightning_crash.up&set_bonus.tier20_2pc)
  if (true) then
    Lightningcrashnotup = num((not Player:BuffP(S.LightningCrashBuff) and AC.Tier20_2Pc))
  end
  -- variable,name=alphaWolfCheck,value=((pet.frost_wolf.buff.alpha_wolf.remains<2&pet.fiery_wolf.buff.alpha_wolf.remains<2&pet.lightning_wolf.buff.alpha_wolf.remains<2)&feral_spirit.remains>4)
  if (true) then
    Alphawolfcheck = num(((Pet:BuffRemainsP(S.AlphaWolfBuff) < 2 and Pet:BuffRemainsP(S.AlphaWolfBuff) < 2 and Pet:BuffRemainsP(S.AlphaWolfBuff) < 2) and feral_spirit.remains > 4))
  end
  -- auto_attack
  if S.AutoAttack:IsCastableP() and (true) then
    if AR.Cast(S.AutoAttack) then return ""; end
  end
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