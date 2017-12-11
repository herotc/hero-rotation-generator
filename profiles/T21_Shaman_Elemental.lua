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
Spell.Shaman.Elemental = {
  Stormkeeper                           = Spell(),
  Ascendance                            = Spell(),
  LiquidMagmaTotem                      = Spell(),
  FlameShock                            = Spell(),
  Earthquake                            = Spell(),
  LavaBurst                             = Spell(),
  FlameShockDebuff                      = Spell(),
  LavaSurgeBuff                         = Spell(),
  LightningRod                          = Spell(),
  ElementalBlast                        = Spell(),
  LavaBeam                              = Spell(),
  ChainLightning                        = Spell(),
  AscendanceBuff                        = Spell(),
  StormkeeperBuff                       = Spell(),
  EchoesoftheGreatSunderingBuff         = Spell(),
  EarthShock                            = Spell(),
  SwellingMaelstrom                     = Spell(),
  LightningBolt                         = Spell(),
  PoweroftheMaelstromBuff               = Spell(),
  ElementalFocusBuff                    = Spell(),
  Aftershock                            = Spell(),
  TotemMastery                          = Spell(),
  ResonanceTotemBuff                    = Spell(),
  EarthenStrengthBuff                   = Spell(),
  FrostShock                            = Spell(),
  IcefuryBuff                           = Spell(),
  Icefury                               = Spell(),
  Bloodlust                             = Spell(),
  FireElemental                         = Spell(),
  WindShear                             = Spell(),
  StormElemental                        = Spell(),
  ElementalMastery                      = Spell(),
  UseItems                              = Spell(),
  UseItem                               = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297)
};
local S = Spell.Shaman.Elemental;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Elemental = {
  SmolderingHeart                  = Item(),
  TheDeceiversBloodPact            = Item(),
  ProlongedPower                   = Item(142117),
  GnawedThumbRing                  = Item()
};
local I = Item.Shaman.Elemental;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Shaman.Commons,
  Elemental = AR.GUISettings.APL.Shaman.Elemental
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Aoe()
    -- stormkeeper
    if S.Stormkeeper:IsCastableP() and (true) then
      if AR.Cast(S.Stormkeeper) then return ""; end
    end
    -- ascendance
    if S.Ascendance:IsCastableP() and (true) then
      if AR.Cast(S.Ascendance) then return ""; end
    end
    -- liquid_magma_totem
    if S.LiquidMagmaTotem:IsCastableP() and (true) then
      if AR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- flame_shock,if=spell_targets.chain_lightning<4&maelstrom>=20,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Cache.EnemiesCount[0] < 4 and Player:Maelstrom() >= 20) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake
    if S.Earthquake:IsCastableP() and (true) then
      if AR.Cast(S.Earthquake) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and Player:BuffP(S.LavaSurgeBuff) and not S.LightningRod:IsAvailable() and Cache.EnemiesCount[0] < 4) then
      if AR.Cast(S.LavaBurst) then return ""; end
    end
    -- elemental_blast,if=!talent.lightning_rod.enabled&spell_targets.chain_lightning<5|talent.lightning_rod.enabled&spell_targets.chain_lightning<4
    if S.ElementalBlast:IsCastableP() and (not S.LightningRod:IsAvailable() and Cache.EnemiesCount[0] < 5 or S.LightningRod:IsAvailable() and Cache.EnemiesCount[0] < 4) then
      if AR.Cast(S.ElementalBlast) then return ""; end
    end
    -- lava_beam
    if S.LavaBeam:IsCastableP() and (true) then
      if AR.Cast(S.LavaBeam) then return ""; end
    end
    -- chain_lightning,target_if=debuff.lightning_rod.down
    if S.ChainLightning:IsCastableP() and (true) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- chain_lightning
    if S.ChainLightning:IsCastableP() and (true) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- lava_burst,moving=1
    if S.LavaBurst:IsCastableP() and (true) then
      if AR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleAsc()
    -- ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
    if S.Ascendance:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.AscendanceBuff:BaseDuration() and (AC.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and not Player:BuffP(S.StormkeeperBuff)) then
      if AR.Cast(S.Ascendance) then return ""; end
    end
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Player:BuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffRemainsP(S.FlameShock) <= S.AscendanceBuff:BaseDuration() and S.Ascendance:CooldownRemainsP() + S.AscendanceBuff:BaseDuration() <= S.FlameShock:BaseDuration()) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff)) then
      if AR.Cast(S.Earthquake) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if AR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.Stormkeeper:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.Stormkeeper) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and (bool(cooldown_react) or Player:BuffP(S.AscendanceBuff))) then
      if AR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.SmolderingHeart:IsEquipped() and I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 70 and S.Aftershock:IsAvailable()) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15)) then
      if AR.Cast(S.TotemMastery) then return ""; end
    end
    -- lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
    if S.LavaBeam:IsCastableP() and (active_enemies > 1 and Cache.EnemiesCount[0] > 1) then
      if AR.Cast(S.LavaBeam) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (active_enemies > 1 and Cache.EnemiesCount[0] > 1) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleIf()
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Player:BuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff)) then
      if AR.Cast(S.Earthquake) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if AR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earth_shock,if=(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=92)&buff.earthen_strength.up
    if S.EarthShock:IsCastableP() and ((Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) and Player:BuffP(S.EarthenStrengthBuff)) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- frost_shock,if=buff.icefury.up&maelstrom>=20&!buff.ascendance.up&buff.earthen_strength.up
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff) and Player:Maelstrom() >= 20 and not Player:BuffP(S.AscendanceBuff) and Player:BuffP(S.EarthenStrengthBuff)) then
      if AR.Cast(S.FrostShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.Stormkeeper:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.Stormkeeper) then return ""; end
    end
    -- icefury,if=(raid_event.movement.in<5|maelstrom<=101&artifact.swelling_maelstrom.enabled|!artifact.swelling_maelstrom.enabled&maelstrom<=76)&!buff.ascendance.up
    if S.Icefury:IsCastableP() and ((raid_event.movement.in < 5 or Player:Maelstrom() <= 101 and S.SwellingMaelstrom:ArtifactEnabled() or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() <= 76) and not Player:BuffP(S.AscendanceBuff)) then
      if AR.Cast(S.Icefury) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and bool(cooldown_react)) then
      if AR.Cast(S.LavaBurst) then return ""; end
    end
    -- frost_shock,if=buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack+1))
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff) and ((Player:Maelstrom() >= 20 and raid_event.movement.in > Player:BuffRemainsP(S.IcefuryBuff)) or Player:BuffRemainsP(S.IcefuryBuff) < (1.5 * Player:SpellHaste() * Player:BuffStackP(S.IcefuryBuff) + 1))) then
      if AR.Cast(S.FrostShock) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- frost_shock,moving=1,if=buff.icefury.up
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff)) then
      if AR.Cast(S.FrostShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled&buff.earthen_strength.up
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.SmolderingHeart:IsEquipped() and I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 70 and S.Aftershock:IsAvailable() and Player:BuffP(S.EarthenStrengthBuff)) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10) then
      if AR.Cast(S.TotemMastery) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (active_enemies > 1 and Cache.EnemiesCount[0] > 1) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleLr()
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Player:BuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff)) then
      if AR.Cast(S.Earthquake) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if AR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.Stormkeeper:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.Stormkeeper) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (raid_event.adds.count < 3 or raid_event.adds.in > 50) then
      if AR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and bool(cooldown_react)) then
      if AR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.SmolderingHeart:IsEquipped() and I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 70 and S.Aftershock:IsAvailable()) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15)) then
      if AR.Cast(S.TotemMastery) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3,target_if=debuff.lightning_rod.down
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[0] < 3) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=debuff.lightning_rod.down
    if S.ChainLightning:IsCastableP() and (active_enemies > 1 and Cache.EnemiesCount[0] > 1) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (active_enemies > 1 and Cache.EnemiesCount[0] > 1) then
      if AR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt,target_if=debuff.lightning_rod.down
    if S.LightningBolt:IsCastableP() and (true) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if AR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if AR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if AR.Cast(S.FlameShock) then return ""; end
    end
  end
  -- bloodlust,if=target.health.pct<25|time>0.500
  if S.Bloodlust:IsCastableP() and (Target:HealthPercentage() < 25 or AC.CombatTime() > 0.500) then
    if AR.Cast(S.Bloodlust) then return ""; end
  end
  -- potion,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.FireElemental:CooldownRemainsP() > 280 or Target:TimeToDie() <= 60) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- wind_shear
  if S.WindShear:IsCastableP() and (true) then
    if AR.Cast(S.WindShear) then return ""; end
  end
  -- totem_mastery,if=buff.resonance_totem.remains<2
  if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
    if AR.Cast(S.TotemMastery) then return ""; end
  end
  -- fire_elemental
  if S.FireElemental:IsCastableP() and (true) then
    if AR.Cast(S.FireElemental) then return ""; end
  end
  -- storm_elemental
  if S.StormElemental:IsCastableP() and (true) then
    if AR.Cast(S.StormElemental) then return ""; end
  end
  -- elemental_mastery
  if S.ElementalMastery:IsCastableP() and (true) then
    if AR.Cast(S.ElementalMastery) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- use_item,name=gnawed_thumb_ring,if=equipped.gnawed_thumb_ring&(talent.ascendance.enabled&!buff.ascendance.up|!talent.ascendance.enabled)
  if S.UseItem:IsCastableP() and (I.GnawedThumbRing:IsEquipped() and (S.Ascendance:IsAvailable() and not Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable())) then
    if AR.Cast(S.UseItem) then return ""; end
  end
  -- blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
  if S.BloodFury:IsCastableP() and AR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
    if AR.Cast(S.BloodFury, Settings.Elemental.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=!talent.ascendance.enabled|buff.ascendance.up
  if S.Berserking:IsCastableP() and AR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff)) then
    if AR.Cast(S.Berserking, Settings.Elemental.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
  if (active_enemies > 2 and (Cache.EnemiesCount[0] > 2 or Cache.EnemiesCount[0] > 2)) then
    return Aoe();
  end
  -- run_action_list,name=single_asc,if=talent.ascendance.enabled
  if (S.Ascendance:IsAvailable()) then
    return SingleAsc();
  end
  -- run_action_list,name=single_if,if=talent.icefury.enabled
  if (S.Icefury:IsAvailable()) then
    return SingleIf();
  end
  -- run_action_list,name=single_lr,if=talent.lightning_rod.enabled
  if (S.LightningRod:IsAvailable()) then
    return SingleLr();
  end
end