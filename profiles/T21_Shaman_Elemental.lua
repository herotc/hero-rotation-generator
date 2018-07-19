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
Spell.Shaman.Elemental = {
  TotemMastery                          = Spell(210643),
  FireElemental                         = Spell(198067),
  ElementalBlast                        = Spell(117014),
  Stormkeeper                           = Spell(205495),
  Ascendance                            = Spell(114050),
  LiquidMagmaTotem                      = Spell(192222),
  FlameShock                            = Spell(188389),
  Earthquake                            = Spell(61882),
  LavaBurst                             = Spell(51505),
  FlameShockDebuff                      = Spell(188389),
  LavaSurgeBuff                         = Spell(77762),
  LightningRod                          = Spell(210689),
  LavaBeam                              = Spell(114074),
  ChainLightning                        = Spell(188443),
  AscendanceBuff                        = Spell(114050),
  StormkeeperBuff                       = Spell(205495),
  EchoesoftheGreatSunderingBuff         = Spell(208722),
  EarthenStrengthBuff                   = Spell(252141),
  EarthShock                            = Spell(8042),
  SwellingMaelstrom                     = Spell(238105),
  LightningBolt                         = Spell(188196),
  PoweroftheMaelstromBuff               = Spell(191877),
  ElementalFocusBuff                    = Spell(16246),
  Aftershock                            = Spell(210707),
  ResonanceTotemBuff                    = Spell(202192),
  FrostShock                            = Spell(196840),
  IcefuryBuff                           = Spell(210714),
  Icefury                               = Spell(210714),
  Bloodlust                             = Spell(2825),
  WindShear                             = Spell(57994),
  StormElemental                        = Spell(192249),
  ElementalMastery                      = Spell(16166),
  UseItems                              = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297)
};
local S = Spell.Shaman.Elemental;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Elemental = {
  ProlongedPower                   = Item(142117),
  TheDeceiversBloodPact            = Item(137035),
  EchoesoftheGreatSundering        = Item(137074),
  SmolderingHeart                  = Item(151819),
  GnawedThumbRing                  = Item(134526)
};
local I = Item.Shaman.Elemental;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Shaman.Commons,
  Elemental = HR.GUISettings.APL.Shaman.Elemental
};

-- Variables

local EnemyRanges = {5, 40}
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
  UpdateRanges()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- totem_mastery
    if S.TotemMastery:IsCastableP() and (true) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- fire_elemental
    if S.FireElemental:IsCastableP() and (true) then
      if HR.Cast(S.FireElemental) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
  end
  local function Aoe()
    -- stormkeeper
    if S.Stormkeeper:IsCastableP() and (true) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- ascendance
    if S.Ascendance:IsCastableP() and (true) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- liquid_magma_totem
    if S.LiquidMagmaTotem:IsCastableP() and (true) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- flame_shock,if=spell_targets.chain_lightning<4&maelstrom>=20,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Cache.EnemiesCount[40] < 4 and Player:Maelstrom() >= 20) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake
    if S.Earthquake:IsCastableP() and (true) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and Player:BuffP(S.LavaSurgeBuff) and not S.LightningRod:IsAvailable() and Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- elemental_blast,if=!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
    if S.ElementalBlast:IsCastableP() and (not S.LightningRod:IsAvailable() and Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- lava_beam,target_if=debuff.lightning_rod.down
    if S.LavaBeam:IsCastableP() and (true) then
      if HR.Cast(S.LavaBeam) then return ""; end
    end
    -- lava_beam
    if S.LavaBeam:IsCastableP() and (true) then
      if HR.Cast(S.LavaBeam) then return ""; end
    end
    -- chain_lightning,target_if=debuff.lightning_rod.down
    if S.ChainLightning:IsCastableP() and (true) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- chain_lightning
    if S.ChainLightning:IsCastableP() and (true) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lava_burst,moving=1
    if S.LavaBurst:IsCastableP() and (true) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleAsc()
    -- ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
    if S.Ascendance:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.AscendanceBuff:BaseDuration() and (HL.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and not Player:BuffP(S.StormkeeperBuff)) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Target:DebuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Target:DebuffRemainsP(S.FlameShock) <= S.AscendanceBuff:BaseDuration() and S.Ascendance:CooldownRemainsP() + S.AscendanceBuff:BaseDuration() <= S.FlameShock:BaseDuration()) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up&(buff.earthen_strength.up|buff.echoes_of_the_great_sundering.duration<=3|maelstrom>=117)|!buff.ascendance.up&buff.earthen_strength.up&spell_targets.earthquake>1
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff) and (Player:BuffP(S.EarthenStrengthBuff) or S.EchoesoftheGreatSunderingBuff:BaseDuration() <= 3 or Player:Maelstrom() >= 117) or not Player:BuffP(S.AscendanceBuff) and Player:BuffP(S.EarthenStrengthBuff) and Cache.EnemiesCount[5] > 1) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=(raid_event.adds.count<3|raid_event.adds.in>50)&time>5&!buff.ascendance.up
    if S.Stormkeeper:IsCastableP() and ((0 < 3 or 10000000000 > 50) and HL.CombatTime() > 5 and not Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (0 < 3 or 10000000000 > 50) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and (bool(cooldown_react) or Player:BuffP(S.AscendanceBuff))) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&maelstrom>85&talent.aftershock.enabled)
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 85 and S.Aftershock:IsAvailable())) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&talent.aftershock.enabled&(maelstrom>85&equipped.echoes_of_the_great_sundering|maelstrom>70&equipped.smoldering_heart)
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and S.Aftershock:IsAvailable() and (Player:Maelstrom() > 85 and I.EchoesoftheGreatSundering:IsEquipped() or Player:Maelstrom() > 70 and I.SmolderingHeart:IsEquipped())) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15)) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
    if S.LavaBeam:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.LavaBeam) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleIf()
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Target:DebuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up&(buff.earthen_strength.up|buff.echoes_of_the_great_sundering.duration<=3|maelstrom>=117)|!buff.ascendance.up&buff.earthen_strength.up&spell_targets.earthquake>1
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff) and (Player:BuffP(S.EarthenStrengthBuff) or S.EchoesoftheGreatSunderingBuff:BaseDuration() <= 3 or Player:Maelstrom() >= 117) or not Player:BuffP(S.AscendanceBuff) and Player:BuffP(S.EarthenStrengthBuff) and Cache.EnemiesCount[5] > 1) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- earth_shock,if=(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=92)&buff.earthen_strength.up
    if S.EarthShock:IsCastableP() and ((Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) and Player:BuffP(S.EarthenStrengthBuff)) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- frost_shock,if=buff.icefury.up&maelstrom>=20&!buff.ascendance.up&buff.earthen_strength.up
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff) and Player:Maelstrom() >= 20 and not Player:BuffP(S.AscendanceBuff) and Player:BuffP(S.EarthenStrengthBuff)) then
      if HR.Cast(S.FrostShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=(raid_event.adds.count<3|raid_event.adds.in>50)&!buff.ascendance.up
    if S.Stormkeeper:IsCastableP() and ((0 < 3 or 10000000000 > 50) and not Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- icefury,if=(raid_event.movement.in<5|maelstrom<=101&artifact.swelling_maelstrom.enabled|!artifact.swelling_maelstrom.enabled&maelstrom<=76)&!buff.ascendance.up
    if S.Icefury:IsCastableP() and ((10000000000 < 5 or Player:Maelstrom() <= 101 and S.SwellingMaelstrom:ArtifactEnabled() or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() <= 76) and not Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.Icefury) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (0 < 3 or 10000000000 > 50) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and bool(cooldown_react)) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- frost_shock,if=buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack+1))
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff) and ((Player:Maelstrom() >= 20 and 10000000000 > Player:BuffRemainsP(S.IcefuryBuff)) or Player:BuffRemainsP(S.IcefuryBuff) < (1.5 * Player:SpellHaste() * Player:BuffStackP(S.IcefuryBuff) + 1))) then
      if HR.Cast(S.FrostShock) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&maelstrom>85&talent.aftershock.enabled)
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 85 and S.Aftershock:IsAvailable())) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- frost_shock,moving=1,if=buff.icefury.up
    if S.FrostShock:IsCastableP() and (Player:BuffP(S.IcefuryBuff)) then
      if HR.Cast(S.FrostShock) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&talent.aftershock.enabled&(maelstrom>85&equipped.echoes_of_the_great_sundering|maelstrom>70&equipped.smoldering_heart)
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and S.Aftershock:IsAvailable() and (Player:Maelstrom() > 85 and I.EchoesoftheGreatSundering:IsEquipped() or Player:Maelstrom() > 70 and I.SmolderingHeart:IsEquipped())) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
  end
  local function SingleLr()
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Target:DebuffP(S.FlameShock) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() and (true) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up&(buff.earthen_strength.up|buff.echoes_of_the_great_sundering.duration<=3|maelstrom>=117)|!buff.ascendance.up&buff.earthen_strength.up&spell_targets.earthquake>1
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and not Player:BuffP(S.AscendanceBuff) and (Player:BuffP(S.EarthenStrengthBuff) or S.EchoesoftheGreatSunderingBuff:BaseDuration() <= 3 or Player:Maelstrom() >= 117) or not Player:BuffP(S.AscendanceBuff) and Player:BuffP(S.EarthenStrengthBuff) and Cache.EnemiesCount[5] > 1) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 117 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 92) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- stormkeeper,if=(raid_event.adds.count<3|raid_event.adds.in>50)&!buff.ascendance.up
    if S.Stormkeeper:IsCastableP() and ((0 < 3 or 10000000000 > 50) and not Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsCastableP() and (0 < 3 or 10000000000 > 50) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
    if S.LavaBurst:IsCastableP() and (Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:CastTime() and bool(cooldown_react)) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Player:Maelstrom() >= 20 and Player:BuffP(S.ElementalFocusBuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake,if=buff.echoes_of_the_great_sundering.up&(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&maelstrom>85&talent.aftershock.enabled)
    if S.Earthquake:IsCastableP() and (Player:BuffP(S.EchoesoftheGreatSunderingBuff) and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and Player:Maelstrom() > 85 and S.Aftershock:IsAvailable())) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.the_deceivers_blood_pact&talent.aftershock.enabled&(maelstrom>85&equipped.echoes_of_the_great_sundering|maelstrom>70&equipped.smoldering_heart)
    if S.EarthShock:IsCastableP() and (Player:Maelstrom() >= 111 or not S.SwellingMaelstrom:ArtifactEnabled() and Player:Maelstrom() >= 86 or I.TheDeceiversBloodPact:IsEquipped() and S.Aftershock:IsAvailable() and (Player:Maelstrom() > 85 and I.EchoesoftheGreatSundering:IsEquipped() or Player:Maelstrom() > 70 and I.SmolderingHeart:IsEquipped())) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
    if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 10 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15)) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3,target_if=debuff.lightning_rod.down
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.PoweroftheMaelstromBuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=debuff.lightning_rod.down
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt,target_if=debuff.lightning_rod.down
    if S.LightningBolt:IsCastableP() and (true) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and (true) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (true) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earth_shock,moving=1
    if S.EarthShock:IsCastableP() and (true) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- bloodlust,if=target.health.pct<25|time>0.500
  if S.Bloodlust:IsCastableP() and (Target:HealthPercentage() < 25 or HL.CombatTime() > 0.500) then
    if HR.Cast(S.Bloodlust) then return ""; end
  end
  -- potion,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.FireElemental:CooldownRemainsP() > 280 or Target:TimeToDie() <= 60) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- wind_shear
  if S.WindShear:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if HR.CastAnnotated(S.WindShear, false, "Interrupt") then return ""; end
  end
  -- totem_mastery,if=buff.resonance_totem.remains<2
  if S.TotemMastery:IsCastableP() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
    if HR.Cast(S.TotemMastery) then return ""; end
  end
  -- fire_elemental
  if S.FireElemental:IsCastableP() and (true) then
    if HR.Cast(S.FireElemental) then return ""; end
  end
  -- storm_elemental
  if S.StormElemental:IsCastableP() and (true) then
    if HR.Cast(S.StormElemental) then return ""; end
  end
  -- elemental_mastery
  if S.ElementalMastery:IsCastableP() and (true) then
    if HR.Cast(S.ElementalMastery) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if HR.Cast(S.UseItems) then return ""; end
  end
  -- use_item,name=gnawed_thumb_ring,if=equipped.gnawed_thumb_ring&(talent.ascendance.enabled&!buff.ascendance.up|!talent.ascendance.enabled)
  if I.GnawedThumbRing:IsReady() and (I.GnawedThumbRing:IsEquipped() and (S.Ascendance:IsAvailable() and not Player:BuffP(S.AscendanceBuff) or not S.Ascendance:IsAvailable())) then
    if HR.CastSuggested(I.GnawedThumbRing) then return ""; end
  end
  -- blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
  if S.BloodFury:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
    if HR.Cast(S.BloodFury, Settings.Elemental.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=!talent.ascendance.enabled|buff.ascendance.up
  if S.Berserking:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff)) then
    if HR.Cast(S.Berserking, Settings.Elemental.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
  if (Cache.EnemiesCount[40] > 2 and (Cache.EnemiesCount[40] > 2 or Cache.EnemiesCount[40] > 2)) then
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

HR.SetAPL(262, APL)
