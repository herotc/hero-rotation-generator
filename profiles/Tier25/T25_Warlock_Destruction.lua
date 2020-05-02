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
if not Spell.Warlock then Spell.Warlock = {} end
Spell.Warlock.Destruction = {
  SummonPet                             = Spell(688),
  GrimoireofSacrifice                   = Spell(108503),
  SoulFire                              = Spell(6353),
  Incinerate                            = Spell(29722),
  RainofFire                            = Spell(5740),
  CrashingChaosBuff                     = Spell(),
  GrimoireofSupremacy                   = Spell(266086),
  Havoc                                 = Spell(80240),
  RainofFireDebuff                      = Spell(5740),
  ChannelDemonfire                      = Spell(196447),
  ImmolateDebuff                        = Spell(157736),
  Immolate                              = Spell(348),
  Cataclysm                             = Spell(152108),
  HavocDebuff                           = Spell(80240),
  ChaosBolt                             = Spell(116858),
  Inferno                               = Spell(270545),
  FocusedAzeriteBeam                    = Spell(),
  PurifyingBlast                        = Spell(),
  FireandBrimstone                      = Spell(196408),
  BackdraftBuff                         = Spell(117828),
  Conflagrate                           = Spell(17962),
  Shadowburn                            = Spell(17877),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  SummonInfernal                        = Spell(1122),
  GuardianofAzeroth                     = Spell(),
  DarkSoulInstability                   = Spell(113858),
  DarkSoulInstabilityBuff               = Spell(113858),
  WorldveinResonance                    = Spell(),
  MemoryofLucidDreams                   = Spell(),
  BloodoftheEnemy                       = Spell(),
  RippleInSpace                         = Spell(),
  Berserking                            = Spell(26297),
  MemoryofLucidDreamsBuff               = Spell(),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  GrimoireofSupremacyBuff               = Spell(266091),
  InternalCombustion                    = Spell(266134),
  ShadowburnDebuff                      = Spell(17877),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  ReapingFlames                         = Spell(),
  Flashover                             = Spell(267115),
  CrashingChaos                         = Spell(),
  Eradication                           = Spell(196412),
  EradicationDebuff                     = Spell(196414)
};
local S = Spell.Warlock.Destruction;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Destruction = {
  BattlePotionofIntellect          = Item(163222),
  AzsharasFontofPower              = Item(),
  PocketsizedComputationDevice     = Item(),
  RotcrustedVoodooDoll             = Item(),
  ShiverVenomRelic                 = Item(),
  AquipotentNautilus               = Item(),
  TidestormCodex                   = Item(165576),
  VialofStorms                     = Item()
};
local I = Item.Warlock.Destruction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warlock.Commons,
  Destruction = HR.GUISettings.APL.Warlock.Destruction
};

-- Variables
local VarPoolSoulShards = 0;

HL:RegisterForEvent(function()
  VarPoolSoulShards = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.ConcentratedFlame:RegisterInFlight()
S.ChaosBolt:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function FutureShard ()
  local Shard = Player:SoulShards()
  if not Player:IsCasting() then
    return Shard
  else
    if Player:IsCasting(S.UnstableAffliction) 
        or Player:IsCasting(S.SeedOfCorruption) then
      return Shard - 1
    elseif Player:IsCasting(S.SummonDoomGuard) 
        or Player:IsCasting(S.SummonDoomGuardSuppremacy) 
        or Player:IsCasting(S.SummonInfernal) 
        or Player:IsCasting(S.SummonInfernalSuppremacy) 
        or Player:IsCasting(S.GrimoireFelhunter) 
        or Player:IsCasting(S.SummonFelhunter) then
      return Shard - 1
    else
      return Shard
    end
  end
end


local function EvaluateCycleImmolate46(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ImmolateDebuff) < 5 and (not S.Cataclysm:IsAvailable() or S.Cataclysm:CooldownRemainsP() > TargetUnit:DebuffRemainsP(S.ImmolateDebuff))
end

local function EvaluateCycleHavoc71(TargetUnit)
  return not (target == self.target) and Cache.EnemiesCount[40] < 4
end

local function EvaluateCycleHavoc106(TargetUnit)
  return not (target == self.target) and (not S.GrimoireofSupremacy:IsAvailable() or not S.Inferno:IsAvailable() or S.GrimoireofSupremacy:IsAvailable() and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10)
end

local function EvaluateCycleImmolate525(TargetUnit)
  return TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) and (not S.Cataclysm:IsAvailable() or S.Cataclysm:CooldownRemainsP() > TargetUnit:DebuffRemainsP(S.ImmolateDebuff))
end

local function EvaluateCycleHavoc592(TargetUnit)
  return not (target == self.target) and (TargetUnit:DebuffRemainsP(S.ImmolateDebuff) > S.ImmolateDebuff:BaseDuration() * 0.5 or not S.InternalCombustion:IsAvailable()) and (not S.SummonInfernal:CooldownUpP() or not S.GrimoireofSupremacy:IsAvailable() or S.GrimoireofSupremacy:IsAvailable() and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cds, GosupInfernal, Havoc
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet) then return "summon_pet 3"; end
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
      if HR.Cast(S.GrimoireofSacrifice) then return "grimoire_of_sacrifice 5"; end
    end
    -- snapshot_stats
    -- potion
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 10"; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      if HR.Cast(S.SoulFire) then return "soul_fire 12"; end
    end
    -- incinerate,if=!talent.soul_fire.enabled
    if S.Incinerate:IsCastableP() and (not S.SoulFire:IsAvailable()) then
      if HR.Cast(S.Incinerate) then return "incinerate 14"; end
    end
  end
  Aoe = function()
    -- rain_of_fire,if=pet.infernal.active&(buff.crashing_chaos.down|!talent.grimoire_of_supremacy.enabled)&(!cooldown.havoc.ready|active_enemies>3)
    if S.RainofFire:IsCastableP() and (bool(pet.infernal.active) and (Player:BuffDownP(S.CrashingChaosBuff) or not S.GrimoireofSupremacy:IsAvailable()) and (not S.Havoc:CooldownUpP() or Cache.EnemiesCount[40] > 3)) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 18"; end
    end
    -- channel_demonfire,if=dot.immolate.remains>cast_time
    if S.ChannelDemonfire:IsCastableP() and (Target:DebuffRemainsP(S.ImmolateDebuff) > S.ChannelDemonfire:CastTime()) then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 34"; end
    end
    -- immolate,cycle_targets=1,if=remains<5&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>remains)
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate46) then return "immolate 64" end
    end
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&active_enemies<4
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc71) then return "havoc 81" end
    end
    -- chaos_bolt,if=talent.grimoire_of_supremacy.enabled&pet.infernal.active&(havoc_active|talent.cataclysm.enabled|talent.inferno.enabled&active_enemies<4)
    if S.ChaosBolt:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and (bool(havoc_active) or S.Cataclysm:IsAvailable() or S.Inferno:IsAvailable() and Cache.EnemiesCount[40] < 4)) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 82"; end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 96"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 98"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 100"; end
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&(!talent.grimoire_of_supremacy.enabled|!talent.inferno.enabled|talent.grimoire_of_supremacy.enabled&pet.infernal.remains<=10)
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc106) then return "havoc 120" end
    end
    -- incinerate,if=talent.fire_and_brimstone.enabled&buff.backdraft.up&soul_shard<5-0.2*active_enemies
    if S.Incinerate:IsCastableP() and (S.FireandBrimstone:IsAvailable() and Player:BuffP(S.BackdraftBuff) and Player:SoulShardsP() < 5 - 0.2 * Cache.EnemiesCount[40]) then
      if HR.Cast(S.Incinerate) then return "incinerate 121"; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      if HR.Cast(S.SoulFire) then return "soul_fire 133"; end
    end
    -- conflagrate,if=buff.backdraft.down
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff)) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 135"; end
    end
    -- shadowburn,if=!talent.fire_and_brimstone.enabled
    if S.Shadowburn:IsCastableP() and (not S.FireandBrimstone:IsAvailable()) then
      if HR.Cast(S.Shadowburn) then return "shadowburn 139"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight&active_enemies<5
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight() and Cache.EnemiesCount[40] < 5) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 143"; end
    end
    -- incinerate
    if S.Incinerate:IsCastableP() then
      if HR.Cast(S.Incinerate) then return "incinerate 157"; end
    end
  end
  Cds = function()
    -- immolate,if=talent.grimoire_of_supremacy.enabled&remains<8&cooldown.summon_infernal.remains<4.5
    if S.Immolate:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Target:DebuffRemainsP(S.ImmolateDebuff) < 8 and S.SummonInfernal:CooldownRemainsP() < 4.5) then
      if HR.Cast(S.Immolate) then return "immolate 159"; end
    end
    -- conflagrate,if=talent.grimoire_of_supremacy.enabled&cooldown.summon_infernal.remains<4.5&!buff.backdraft.up&soul_shard<4.3
    if S.Conflagrate:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and S.SummonInfernal:CooldownRemainsP() < 4.5 and not Player:BuffP(S.BackdraftBuff) and Player:SoulShardsP() < 4.3) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 171"; end
    end
    -- use_item,name=azsharas_font_of_power,if=cooldown.summon_infernal.up|cooldown.summon_infernal.remains<=4
    if I.AzsharasFontofPower:IsReady() and (S.SummonInfernal:CooldownUpP() or S.SummonInfernal:CooldownRemainsP() <= 4) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 179"; end
    end
    -- summon_infernal
    if S.SummonInfernal:IsCastableP() then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 185"; end
    end
    -- guardian_of_azeroth,if=pet.infernal.active
    if S.GuardianofAzeroth:IsCastableP() and (bool(pet.infernal.active)) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 187"; end
    end
    -- dark_soul_instability,if=pet.infernal.active&(pet.infernal.remains<20.5|pet.infernal.remains<22&soul_shard>=3.6|!talent.grimoire_of_supremacy.enabled)
    if S.DarkSoulInstability:IsCastableP() and (bool(pet.infernal.active) and (Player:BuffRemainsP(S.DarkSoulInstabilityBuff) < 20.5 or Player:BuffRemainsP(S.DarkSoulInstabilityBuff) < 22 and Player:SoulShardsP() >= 3.6 or not S.GrimoireofSupremacy:IsAvailable())) then
      if HR.Cast(S.DarkSoulInstability) then return "dark_soul_instability 189"; end
    end
    -- worldvein_resonance,if=pet.infernal.active&(pet.infernal.remains<18.5|pet.infernal.remains<20&soul_shard>=3.6|!talent.grimoire_of_supremacy.enabled)
    if S.WorldveinResonance:IsCastableP() and (bool(pet.infernal.active) and (pet.infernal.remains < 18.5 or pet.infernal.remains < 20 and Player:SoulShardsP() >= 3.6 or not S.GrimoireofSupremacy:IsAvailable())) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 205"; end
    end
    -- memory_of_lucid_dreams,if=pet.infernal.active&(pet.infernal.remains<15.5|soul_shard<3.5&(buff.dark_soul_instability.up|!talent.grimoire_of_supremacy.enabled&dot.immolate.remains>12))
    if S.MemoryofLucidDreams:IsCastableP() and (bool(pet.infernal.active) and (pet.infernal.remains < 15.5 or Player:SoulShardsP() < 3.5 and (Player:BuffP(S.DarkSoulInstabilityBuff) or not S.GrimoireofSupremacy:IsAvailable() and Target:DebuffRemainsP(S.ImmolateDebuff) > 12))) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 217"; end
    end
    -- summon_infernal,if=target.time_to_die>cooldown.summon_infernal.duration+30
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() > S.SummonInfernal:BaseDuration() + 30) then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 229"; end
    end
    -- guardian_of_azeroth,if=time>30&target.time_to_die>cooldown.guardian_of_azeroth.duration+30
    if S.GuardianofAzeroth:IsCastableP() and (HL.CombatTime() > 30 and Target:TimeToDie() > S.GuardianofAzeroth:BaseDuration() + 30) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 233"; end
    end
    -- summon_infernal,if=talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains>target.time_to_die
    if S.SummonInfernal:IsCastableP() and (S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() > Target:TimeToDie()) then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 237"; end
    end
    -- guardian_of_azeroth,if=cooldown.summon_infernal.remains>target.time_to_die
    if S.GuardianofAzeroth:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie()) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 243"; end
    end
    -- dark_soul_instability,if=cooldown.summon_infernal.remains>target.time_to_die&pet.infernal.remains<20.5
    if S.DarkSoulInstability:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie() and Player:BuffRemainsP(S.DarkSoulInstabilityBuff) < 20.5) then
      if HR.Cast(S.DarkSoulInstability) then return "dark_soul_instability 247"; end
    end
    -- worldvein_resonance,if=cooldown.summon_infernal.remains>target.time_to_die&pet.infernal.remains<18.5
    if S.WorldveinResonance:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie() and pet.infernal.remains < 18.5) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 257"; end
    end
    -- memory_of_lucid_dreams,if=cooldown.summon_infernal.remains>target.time_to_die&(pet.infernal.remains<15.5|buff.dark_soul_instability.up&soul_shard<3)
    if S.MemoryofLucidDreams:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie() and (pet.infernal.remains < 15.5 or Player:BuffP(S.DarkSoulInstabilityBuff) and Player:SoulShardsP() < 3)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 265"; end
    end
    -- summon_infernal,if=target.time_to_die<30
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() < 30) then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 275"; end
    end
    -- guardian_of_azeroth,if=target.time_to_die<30
    if S.GuardianofAzeroth:IsCastableP() and (Target:TimeToDie() < 30) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 277"; end
    end
    -- dark_soul_instability,if=target.time_to_die<21&target.time_to_die>4
    if S.DarkSoulInstability:IsCastableP() and (Target:TimeToDie() < 21 and Target:TimeToDie() > 4) then
      if HR.Cast(S.DarkSoulInstability) then return "dark_soul_instability 279"; end
    end
    -- worldvein_resonance,if=target.time_to_die<19&target.time_to_die>4
    if S.WorldveinResonance:IsCastableP() and (Target:TimeToDie() < 19 and Target:TimeToDie() > 4) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 281"; end
    end
    -- memory_of_lucid_dreams,if=target.time_to_die<16&target.time_to_die>6
    if S.MemoryofLucidDreams:IsCastableP() and (Target:TimeToDie() < 16 and Target:TimeToDie() > 6) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 283"; end
    end
    -- blood_of_the_enemy
    if S.BloodoftheEnemy:IsCastableP() then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 285"; end
    end
    -- worldvein_resonance,if=cooldown.summon_infernal.remains>=60-12&!pet.infernal.active
    if S.WorldveinResonance:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() >= 60 - 12 and not bool(pet.infernal.active)) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 287"; end
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 291"; end
    end
    -- potion,if=pet.infernal.active|target.time_to_die<30
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions and (bool(pet.infernal.active) or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 293"; end
    end
    -- berserking,if=pet.infernal.active&(!talent.grimoire_of_supremacy.enabled|(!essence.memory_of_lucid_dreams.major|buff.memory_of_lucid_dreams.remains)&(!talent.dark_soul_instability.enabled|buff.dark_soul_instability.remains))|target.time_to_die<=15
    if S.Berserking:IsCastableP() and HR.CDsON() and (bool(pet.infernal.active) and (not S.GrimoireofSupremacy:IsAvailable() or (not bool(essence.memory_of_lucid_dreams.major) or bool(Player:BuffRemainsP(S.MemoryofLucidDreamsBuff))) and (not S.DarkSoulInstability:IsAvailable() or bool(Player:BuffRemainsP(S.DarkSoulInstabilityBuff)))) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 295"; end
    end
    -- blood_fury,if=pet.infernal.active&(!talent.grimoire_of_supremacy.enabled|(!essence.memory_of_lucid_dreams.major|buff.memory_of_lucid_dreams.remains)&(!talent.dark_soul_instability.enabled|buff.dark_soul_instability.remains))|target.time_to_die<=15
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(pet.infernal.active) and (not S.GrimoireofSupremacy:IsAvailable() or (not bool(essence.memory_of_lucid_dreams.major) or bool(Player:BuffRemainsP(S.MemoryofLucidDreamsBuff))) and (not S.DarkSoulInstability:IsAvailable() or bool(Player:BuffRemainsP(S.DarkSoulInstabilityBuff)))) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 305"; end
    end
    -- fireblood,if=pet.infernal.active&(!talent.grimoire_of_supremacy.enabled|(!essence.memory_of_lucid_dreams.major|buff.memory_of_lucid_dreams.remains)&(!talent.dark_soul_instability.enabled|buff.dark_soul_instability.remains))|target.time_to_die<=15
    if S.Fireblood:IsCastableP() and HR.CDsON() and (bool(pet.infernal.active) and (not S.GrimoireofSupremacy:IsAvailable() or (not bool(essence.memory_of_lucid_dreams.major) or bool(Player:BuffRemainsP(S.MemoryofLucidDreamsBuff))) and (not S.DarkSoulInstability:IsAvailable() or bool(Player:BuffRemainsP(S.DarkSoulInstabilityBuff)))) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 315"; end
    end
    -- use_items,if=pet.infernal.active&(!talent.grimoire_of_supremacy.enabled|pet.infernal.remains<=20)|target.time_to_die<=20
    -- use_item,name=pocketsized_computation_device,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.PocketsizedComputationDevice:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.PocketsizedComputationDevice) then return "pocketsized_computation_device 326"; end
    end
    -- use_item,name=rotcrusted_voodoo_doll,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.RotcrustedVoodooDoll:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.RotcrustedVoodooDoll) then return "rotcrusted_voodoo_doll 332"; end
    end
    -- use_item,name=shiver_venom_relic,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.ShiverVenomRelic:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.ShiverVenomRelic) then return "shiver_venom_relic 338"; end
    end
    -- use_item,name=aquipotent_nautilus,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.AquipotentNautilus:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.AquipotentNautilus) then return "aquipotent_nautilus 344"; end
    end
    -- use_item,name=tidestorm_codex,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.TidestormCodex:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.TidestormCodex) then return "tidestorm_codex 350"; end
    end
    -- use_item,name=vial_of_storms,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.VialofStorms:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
      if HR.CastSuggested(I.VialofStorms) then return "vial_of_storms 356"; end
    end
  end
  GosupInfernal = function()
    -- rain_of_fire,if=soul_shard=5&!buff.backdraft.up&buff.memory_of_lucid_dreams.up&buff.grimoire_of_supremacy.stack<=10
    if S.RainofFire:IsCastableP() and (Player:SoulShardsP() == 5 and not Player:BuffP(S.BackdraftBuff) and Player:BuffP(S.MemoryofLucidDreamsBuff) and Player:BuffStackP(S.GrimoireofSupremacyBuff) <= 10) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 362"; end
    end
    -- chaos_bolt,if=buff.backdraft.up
    if S.ChaosBolt:IsCastableP() and (Player:BuffP(S.BackdraftBuff)) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 370"; end
    end
    -- chaos_bolt,if=soul_shard>=4.2-buff.memory_of_lucid_dreams.up
    if S.ChaosBolt:IsCastableP() and (Player:SoulShardsP() >= 4.2 - num(Player:BuffP(S.MemoryofLucidDreamsBuff))) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 374"; end
    end
    -- chaos_bolt,if=!cooldown.conflagrate.up
    if S.ChaosBolt:IsCastableP() and (not S.Conflagrate:CooldownUpP()) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 378"; end
    end
    -- chaos_bolt,if=cast_time<pet.infernal.remains&pet.infernal.remains<cast_time+gcd
    if S.ChaosBolt:IsCastableP() and (S.ChaosBolt:CastTime() < pet.infernal.remains and pet.infernal.remains < S.ChaosBolt:CastTime() + Player:GCD()) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 382"; end
    end
    -- conflagrate,if=buff.backdraft.down&buff.memory_of_lucid_dreams.up&soul_shard>=1.3
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and Player:BuffP(S.MemoryofLucidDreamsBuff) and Player:SoulShardsP() >= 1.3) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 400"; end
    end
    -- conflagrate,if=buff.backdraft.down&!buff.memory_of_lucid_dreams.up&(soul_shard>=2.8|charges_fractional>1.9&soul_shard>=1.3)
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and not Player:BuffP(S.MemoryofLucidDreamsBuff) and (Player:SoulShardsP() >= 2.8 or S.Conflagrate:ChargesFractionalP() > 1.9 and Player:SoulShardsP() >= 1.3)) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 406"; end
    end
    -- conflagrate,if=pet.infernal.remains<5
    if S.Conflagrate:IsCastableP() and (pet.infernal.remains < 5) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 416"; end
    end
    -- conflagrate,if=charges>1
    if S.Conflagrate:IsCastableP() and (S.Conflagrate:ChargesP() > 1) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 422"; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      if HR.Cast(S.SoulFire) then return "soul_fire 428"; end
    end
    -- shadowburn
    if S.Shadowburn:IsCastableP() then
      if HR.Cast(S.Shadowburn) then return "shadowburn 430"; end
    end
    -- incinerate
    if S.Incinerate:IsCastableP() then
      if HR.Cast(S.Incinerate) then return "incinerate 432"; end
    end
  end
  Havoc = function()
    -- conflagrate,if=buff.backdraft.down&soul_shard>=1&soul_shard<=4
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and Player:SoulShardsP() >= 1 and Player:SoulShardsP() <= 4) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 434"; end
    end
    -- immolate,if=talent.internal_combustion.enabled&remains<duration*0.5|!talent.internal_combustion.enabled&refreshable
    if S.Immolate:IsCastableP() and (S.InternalCombustion:IsAvailable() and Target:DebuffRemainsP(S.ImmolateDebuff) < S.ImmolateDebuff:BaseDuration() * 0.5 or not S.InternalCombustion:IsAvailable() and Target:DebuffRefreshableCP(S.ImmolateDebuff)) then
      if HR.Cast(S.Immolate) then return "immolate 438"; end
    end
    -- chaos_bolt,if=cast_time<havoc_remains
    if S.ChaosBolt:IsCastableP() and (S.ChaosBolt:CastTime() < havoc_remains) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 462"; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      if HR.Cast(S.SoulFire) then return "soul_fire 468"; end
    end
    -- shadowburn,if=active_enemies<3|!talent.fire_and_brimstone.enabled
    if S.Shadowburn:IsCastableP() and (Cache.EnemiesCount[40] < 3 or not S.FireandBrimstone:IsAvailable()) then
      if HR.Cast(S.Shadowburn) then return "shadowburn 470"; end
    end
    -- incinerate,if=cast_time<havoc_remains
    if S.Incinerate:IsCastableP() and (S.Incinerate:CastTime() < havoc_remains) then
      if HR.Cast(S.Incinerate) then return "incinerate 482"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- call_action_list,name=havoc,if=havoc_active&active_enemies<5-talent.inferno.enabled+(talent.inferno.enabled&talent.internal_combustion.enabled)
    if (bool(havoc_active) and Cache.EnemiesCount[40] < 5 - num(S.Inferno:IsAvailable()) + num((S.Inferno:IsAvailable() and S.InternalCombustion:IsAvailable()))) then
      local ShouldReturn = Havoc(); if ShouldReturn then return ShouldReturn; end
    end
    -- cataclysm,if=!(pet.infernal.active&dot.immolate.remains+1>pet.infernal.remains)|spell_targets.cataclysm>1|!talent.grimoire_of_supremacy.enabled
    if S.Cataclysm:IsCastableP() and (not (bool(pet.infernal.active) and Target:DebuffRemainsP(S.ImmolateDebuff) + 1 > pet.infernal.remains) or Cache.EnemiesCount[40] > 1 or not S.GrimoireofSupremacy:IsAvailable()) then
      if HR.Cast(S.Cataclysm) then return "cataclysm 503"; end
    end
    -- call_action_list,name=aoe,if=active_enemies>2
    if (Cache.EnemiesCount[40] > 2) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    -- immolate,cycle_targets=1,if=refreshable&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>remains)
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate525) then return "immolate 543" end
    end
    -- immolate,if=talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains<duration*0.5
    if S.Immolate:IsCastableP() and (S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and Target:DebuffRemainsP(S.ImmolateDebuff) < S.ImmolateDebuff:BaseDuration() * 0.5) then
      if HR.Cast(S.Immolate) then return "immolate 544"; end
    end
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- focused_azerite_beam,if=!pet.infernal.active|!talent.grimoire_of_supremacy.enabled
    if S.FocusedAzeriteBeam:IsCastableP() and (not bool(pet.infernal.active) or not S.GrimoireofSupremacy:IsAvailable()) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 566"; end
    end
    -- the_unbound_force,if=buff.reckless_force.react
    if S.TheUnboundForce:IsCastableP() and (bool(Player:BuffStackP(S.RecklessForceBuff))) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 570"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 574"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight()) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 576"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 584"; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 586"; end
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&(dot.immolate.remains>dot.immolate.duration*0.5|!talent.internal_combustion.enabled)&(!cooldown.summon_infernal.ready|!talent.grimoire_of_supremacy.enabled|talent.grimoire_of_supremacy.enabled&pet.infernal.remains<=10)
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc592) then return "havoc 612" end
    end
    -- call_action_list,name=gosup_infernal,if=talent.grimoire_of_supremacy.enabled&pet.infernal.active
    if (S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active)) then
      local ShouldReturn = GosupInfernal(); if ShouldReturn then return ShouldReturn; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      if HR.Cast(S.SoulFire) then return "soul_fire 617"; end
    end
    -- variable,name=pool_soul_shards,value=active_enemies>1&cooldown.havoc.remains<=10|cooldown.summon_infernal.remains<=15&(talent.grimoire_of_supremacy.enabled|talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains<=15)|talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains<=15&(cooldown.summon_infernal.remains>target.time_to_die|cooldown.summon_infernal.remains+cooldown.summon_infernal.duration>target.time_to_die)
    if (true) then
      VarPoolSoulShards = num(Cache.EnemiesCount[40] > 1 and S.Havoc:CooldownRemainsP() <= 10 or S.SummonInfernal:CooldownRemainsP() <= 15 and (S.GrimoireofSupremacy:IsAvailable() or S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() <= 15) or S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() <= 15 and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie() or S.SummonInfernal:CooldownRemainsP() + S.SummonInfernal:BaseDuration() > Target:TimeToDie()))
    end
    -- conflagrate,if=buff.backdraft.down&soul_shard>=1.5-0.3*talent.flashover.enabled&!variable.pool_soul_shards
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and Player:SoulShardsP() >= 1.5 - 0.3 * num(S.Flashover:IsAvailable()) and not bool(VarPoolSoulShards)) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 647"; end
    end
    -- shadowburn,if=soul_shard<2&(!variable.pool_soul_shards|charges>1)
    if S.Shadowburn:IsCastableP() and (Player:SoulShardsP() < 2 and (not bool(VarPoolSoulShards) or S.Shadowburn:ChargesP() > 1)) then
      if HR.Cast(S.Shadowburn) then return "shadowburn 655"; end
    end
    -- chaos_bolt,if=(talent.grimoire_of_supremacy.enabled|azerite.crashing_chaos.enabled)&pet.infernal.active|buff.dark_soul_instability.up|buff.reckless_force.react&buff.reckless_force.remains>cast_time
    if S.ChaosBolt:IsCastableP() and ((S.GrimoireofSupremacy:IsAvailable() or S.CrashingChaos:AzeriteEnabled()) and bool(pet.infernal.active) or Player:BuffP(S.DarkSoulInstabilityBuff) or bool(Player:BuffStackP(S.RecklessForceBuff)) and Player:BuffRemainsP(S.RecklessForceBuff) > S.ChaosBolt:CastTime()) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 665"; end
    end
    -- chaos_bolt,if=buff.backdraft.up&!variable.pool_soul_shards&!talent.eradication.enabled
    if S.ChaosBolt:IsCastableP() and (Player:BuffP(S.BackdraftBuff) and not bool(VarPoolSoulShards) and not S.Eradication:IsAvailable()) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 681"; end
    end
    -- chaos_bolt,if=!variable.pool_soul_shards&talent.eradication.enabled&(debuff.eradication.remains<cast_time|buff.backdraft.up)
    if S.ChaosBolt:IsCastableP() and (not bool(VarPoolSoulShards) and S.Eradication:IsAvailable() and (Target:DebuffRemainsP(S.EradicationDebuff) < S.ChaosBolt:CastTime() or Player:BuffP(S.BackdraftBuff))) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 689"; end
    end
    -- chaos_bolt,if=(soul_shard>=4.5-0.2*active_enemies)&(!talent.grimoire_of_supremacy.enabled|cooldown.summon_infernal.remains>7)
    if S.ChaosBolt:IsCastableP() and ((Player:SoulShardsP() >= 4.5 - 0.2 * Cache.EnemiesCount[40]) and (not S.GrimoireofSupremacy:IsAvailable() or S.SummonInfernal:CooldownRemainsP() > 7)) then
      if HR.Cast(S.ChaosBolt) then return "chaos_bolt 703"; end
    end
    -- conflagrate,if=charges>1
    if S.Conflagrate:IsCastableP() and (S.Conflagrate:ChargesP() > 1) then
      if HR.Cast(S.Conflagrate) then return "conflagrate 715"; end
    end
    -- incinerate
    if S.Incinerate:IsCastableP() then
      if HR.Cast(S.Incinerate) then return "incinerate 721"; end
    end
  end
end

HR.SetAPL(267, APL)
