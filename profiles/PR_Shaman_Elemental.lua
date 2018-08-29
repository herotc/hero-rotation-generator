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
  StormElemental                        = Spell(192249),
  LiquidMagmaTotem                      = Spell(192222),
  FlameShock                            = Spell(188389),
  FlameShockDebuff                      = Spell(188389),
  Earthquake                            = Spell(61882),
  LavaBurst                             = Spell(51505),
  LavaSurgeBuff                         = Spell(77762),
  AscendanceBuff                        = Spell(114050),
  LavaBeam                              = Spell(114074),
  ChainLightning                        = Spell(188443),
  FrostShock                            = Spell(196840),
  MasteroftheElements                   = Spell(),
  MasteroftheElementsBuff               = Spell(),
  ExposedElements                       = Spell(),
  LightningBolt                         = Spell(188196),
  ExposedElementsDebuff                 = Spell(),
  EarthShock                            = Spell(8042),
  ResonanceTotemBuff                    = Spell(202192),
  Icefury                               = Spell(210714),
  IcefuryBuff                           = Spell(210714),
  Bloodlust                             = Spell(2825),
  WindShear                             = Spell(57994),
  EarthElemental                        = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738)
};
local S = Spell.Shaman.Elemental;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Elemental = {
  ProlongedPower                   = Item(142117)
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

local EnemyRanges = {40}
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
  local Precombat, Aoe, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- totem_mastery
    if S.TotemMastery:IsCastableP() then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- fire_elemental
    if S.FireElemental:IsCastableP() then
      if HR.Cast(S.FireElemental) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- elemental_blast
    if S.ElementalBlast:IsCastableP() then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
  end
  Aoe = function()
    -- stormkeeper,if=talent.stormkeeper.enabled
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable()) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- ascendance,if=talent.ascendance.enabled&(talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120&cooldown.storm_elemental.remains>15|!talent.storm_elemental.enabled)
    if S.Ascendance:IsCastableP() and (S.Ascendance:IsAvailable() and (S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 120 and S.StormElemental:CooldownRemainsP() > 15 or not S.StormElemental:IsAvailable())) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled
    if S.LiquidMagmaTotem:IsCastableP() and (S.LiquidMagmaTotem:IsAvailable()) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- flame_shock,if=spell_targets.chain_lightning<4,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Target:DebuffRefreshableCP(S.FlameShockDebuff)) and (Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- earthquake
    if S.Earthquake:IsCastableP() then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- lava_burst,if=(buff.lava_surge.up|buff.ascendance.up)&spell_targets.chain_lightning<4
    if S.LavaBurst:IsCastableP() and ((Player:BuffP(S.LavaSurgeBuff) or Player:BuffP(S.AscendanceBuff)) and Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&spell_targets.chain_lightning<4
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- lava_beam,if=talent.ascendance.enabled
    if S.LavaBeam:IsCastableP() and (S.Ascendance:IsAvailable()) then
      if HR.Cast(S.LavaBeam) then return ""; end
    end
    -- chain_lightning
    if S.ChainLightning:IsCastableP() then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lava_burst,moving=1,if=talent.ascendance.enabled
    if S.LavaBurst:IsCastableP() and (S.Ascendance:IsAvailable()) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Target:DebuffRefreshableCP(S.FlameShockDebuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() then
      if HR.Cast(S.FrostShock) then return ""; end
    end
  end
  SingleTarget = function()
    -- flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsCastableP() and (not Target:DebuffP(S.FlameShockDebuff) or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD()) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!talent.storm_elemental.enabled
    if S.Ascendance:IsCastableP() and (S.Ascendance:IsAvailable() and (HL.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and not S.StormElemental:IsAvailable()) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&cooldown.storm_elemental.remains<=120
    if S.Ascendance:IsCastableP() and (S.Ascendance:IsAvailable() and (HL.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and S.StormElemental:CooldownRemainsP() <= 120) then
      if HR.Cast(S.Ascendance) then return ""; end
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&(talent.master_of_the_elements.enabled&buff.master_of_the_elements.up&maelstrom<60|!talent.master_of_the_elements.enabled)
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and (S.MasteroftheElements:IsAvailable() and Player:BuffP(S.MasteroftheElementsBuff) and Player:Maelstrom() < 60 or not S.MasteroftheElements:IsAvailable())) then
      if HR.Cast(S.ElementalBlast) then return ""; end
    end
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable() and (0 < 3 or 10000000000 > 50)) then
      if HR.Cast(S.Stormkeeper) then return ""; end
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.LiquidMagmaTotem:IsCastableP() and (S.LiquidMagmaTotem:IsAvailable() and (0 < 3 or 10000000000 > 50)) then
      if HR.Cast(S.LiquidMagmaTotem) then return ""; end
    end
    -- earthquake,if=active_enemies>1&spell_targets.chain_lightning>1&!talent.exposed_elements.enabled
    if S.Earthquake:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1 and not S.ExposedElements:IsAvailable()) then
      if HR.Cast(S.Earthquake) then return ""; end
    end
    -- lightning_bolt,if=talent.exposed_elements.enabled&debuff.exposed_elements.up&maelstrom>=60&!buff.ascendance.up
    if S.LightningBolt:IsCastableP() and (S.ExposedElements:IsAvailable() and Target:DebuffP(S.ExposedElementsDebuff) and Player:Maelstrom() >= 60 and not Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- earth_shock,if=talent.master_of_the_elements.enabled&(buff.master_of_the_elements.up|maelstrom>=92)|!talent.master_of_the_elements.enabled
    if S.EarthShock:IsCastableP() and (S.MasteroftheElements:IsAvailable() and (Player:BuffP(S.MasteroftheElementsBuff) or Player:Maelstrom() >= 92) or not S.MasteroftheElements:IsAvailable()) then
      if HR.Cast(S.EarthShock) then return ""; end
    end
    -- lava_burst,if=cooldown_react|buff.ascendance.up
    if S.LavaBurst:IsCastableP() and (bool(cooldown_react) or Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.LavaBurst) then return ""; end
    end
    -- flame_shock,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Target:DebuffRefreshableCP(S.FlameShockDebuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- totem_mastery,if=talent.totem_mastery.enabled&(buff.resonance_totem.remains<6|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15))
    if S.TotemMastery:IsCastableP() and (S.TotemMastery:IsAvailable() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 6 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15))) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- frost_shock,if=talent.icefury.enabled&buff.icefury.up
    if S.FrostShock:IsCastableP() and (S.Icefury:IsAvailable() and Player:BuffP(S.IcefuryBuff)) then
      if HR.Cast(S.FrostShock) then return ""; end
    end
    -- icefury,if=talent.icefury.enabled
    if S.Icefury:IsCastableP() and (S.Icefury:IsAvailable()) then
      if HR.Cast(S.Icefury) then return ""; end
    end
    -- lava_beam,if=talent.ascendance.enabled&active_enemies>1&spell_targets.lava_beam>1
    if S.LavaBeam:IsCastableP() and (S.Ascendance:IsAvailable() and Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.LavaBeam) then return ""; end
    end
    -- chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.ChainLightning) then return ""; end
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() then
      if HR.Cast(S.LightningBolt) then return ""; end
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and (Target:DebuffRefreshableCP(S.FlameShockDebuff)) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and (movement.distance > 6) then
      if HR.Cast(S.FlameShock) then return ""; end
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() then
      if HR.Cast(S.FrostShock) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- bloodlust,if=target.health.pct<25|time>0.500
    if S.Bloodlust:IsCastableP() and (Target:HealthPercentage() < 25 or HL.CombatTime() > 0.500) then
      if HR.Cast(S.Bloodlust) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled then
      if HR.CastAnnotated(S.WindShear, false, "Interrupt") then return ""; end
    end
    -- totem_mastery,if=talent.totem_mastery.enabled&buff.resonance_totem.remains<2
    if S.TotemMastery:IsCastableP() and (S.TotemMastery:IsAvailable() and Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
      if HR.Cast(S.TotemMastery) then return ""; end
    end
    -- fire_elemental,if=!talent.storm_elemental.enabled
    if S.FireElemental:IsCastableP() and (not S.StormElemental:IsAvailable()) then
      if HR.Cast(S.FireElemental) then return ""; end
    end
    -- storm_elemental,if=talent.storm_elemental.enabled
    if S.StormElemental:IsCastableP() and (S.StormElemental:IsAvailable()) then
      if HR.Cast(S.StormElemental) then return ""; end
    end
    -- earth_elemental,if=cooldown.fire_elemental.remains<120&!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120&talent.storm_elemental.enabled
    if S.EarthElemental:IsCastableP() and (S.FireElemental:CooldownRemainsP() < 120 and not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120 and S.StormElemental:IsAvailable()) then
      if HR.Cast(S.EarthElemental) then return ""; end
    end
    -- use_items
    -- blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.BloodFury:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- berserking,if=!talent.ascendance.enabled|buff.ascendance.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- fireblood,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.Fireblood:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- ancestral_call,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
    if (Cache.EnemiesCount[40] > 2 and (Cache.EnemiesCount[40] > 2 or Cache.EnemiesCount[40] > 2)) then
      return Aoe();
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

HR.SetAPL(262, APL)