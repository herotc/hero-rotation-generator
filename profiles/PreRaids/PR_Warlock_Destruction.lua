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
  Cataclysm                             = Spell(152108),
  Immolate                              = Spell(348),
  ChannelDemonfire                      = Spell(196447),
  ImmolateDebuff                        = Spell(157736),
  ChaosBolt                             = Spell(116858),
  Havoc                                 = Spell(80240),
  GrimoireofSupremacy                   = Spell(266086),
  HavocDebuff                           = Spell(80240),
  GrimoireofSupremacyBuff               = Spell(266091),
  ActiveHavocBuff                       = Spell(80240),
  Conflagrate                           = Spell(17962),
  Shadowburn                            = Spell(17877),
  ShadowburnDebuff                      = Spell(17877),
  BackdraftBuff                         = Spell(117828),
  SummonInfernal                        = Spell(1122),
  DarkSoulInstability                   = Spell(113858),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  Flashover                             = Spell(267115),
  RoaringBlaze                          = Spell(205184),
  InternalCombustion                    = Spell(266134),
  Eradication                           = Spell(196412),
  FireandBrimstone                      = Spell(196408),
  Inferno                               = Spell(270545),
  EradicationDebuff                     = Spell(196414),
  DarkSoulInstabilityBuff               = Spell(113858)
};
local S = Spell.Warlock.Destruction;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Destruction = {
  ProlongedPower                   = Item(142117)
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


local EnemyRanges = {40, 35, 5}
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


local function EvaluateCycleHavoc46(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 8 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt71(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 8 and ((108 * Cache.EnemiesCount[35] / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc104(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4
end

local function EvaluateCycleChaosBolt113(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4
end

local function EvaluateCycleImmolate128(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) and TargetUnit:DebuffRemainsP(S.ImmolateDebuff) <= S.Cataclysm:CooldownRemainsP()
end

local function EvaluateCycleSoulFire153(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleConflagrate162(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleShadowburn171(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate196(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleHavoc244(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt269(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 4 and ((108 * Cache.EnemiesCount[35] / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc302(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4
end

local function EvaluateCycleChaosBolt311(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4
end

local function EvaluateCycleImmolate326(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) and Cache.EnemiesCount[5] <= 8
end

local function EvaluateCycleSoulFire343(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Cache.EnemiesCount[5] == 3
end

local function EvaluateCycleConflagrate352(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and (S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2 or Cache.EnemiesCount[5] <= 7 or S.RoaringBlaze:IsAvailable() and Cache.EnemiesCount[5] <= 9)
end

local function EvaluateCycleIncinerate367(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleHavoc400(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt429(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and ((108 * Cache.EnemiesCount[35] / (3 - 0.16 * Cache.EnemiesCount[35])) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc458(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())
end

local function EvaluateCycleChaosBolt475(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())
end

local function EvaluateCycleImmolate494(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff)
end

local function EvaluateCycleSoulFire511(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleConflagrate520(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleShadowburn529(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate554(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleImmolate578(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and (TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) or S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and TargetUnit:DebuffRemainsP(S.ImmolateDebuff) - S.ChaosBolt:TravelTime() - 5 < S.ImmolateDebuff:BaseDuration() * 0.3)
end

local function EvaluateCycleHavoc619(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10
end

local function EvaluateCycleSoulFire636(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleChaosBolt645(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < TargetUnit:TimeToDie() and (S.InternalCombustion:IsAvailable() or not S.InternalCombustion:IsAvailable() and Player:SoulShardsP() >= 4 or (S.Eradication:IsAvailable() and TargetUnit:DebuffRemainsP(S.EradicationDebuff) <= S.ChaosBolt:CastTime()) or Player:BuffRemainsP(S.DarkSoulInstabilityBuff) > S.ChaosBolt:CastTime() or bool(pet.infernal.active) and S.GrimoireofSupremacy:IsAvailable())
end

local function EvaluateCycleConflagrate682(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2) or (not S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) < 2))
end

local function EvaluateCycleShadowburn699(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate724(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cata, Cds, Fnb, Inf
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
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 10"; end
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
  Cata = function()
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (Player:SoulShardsP() >= 4.5) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 20"; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
      if HR.Cast(S.Cataclysm) then return "cataclysm 22"; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return "immolate 24"; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 40"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc46) then return "havoc 56" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 8 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 57"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=8&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt71) then return "chaos_bolt 99" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc104) then return "havoc 106" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4) then
      if HR.Cast(S.Havoc) then return "havoc 107"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt113) then return "chaos_bolt 123" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&remains<=cooldown.cataclysm.remains
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate128) then return "immolate 146" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 147"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire153) then return "soul_fire 157" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate162) then return "conflagrate 166" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn171) then return "shadowburn 191" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate196) then return "incinerate 200" end
    end
  end
  Cds = function()
    -- summon_infernal,if=target.time_to_die>=210|!cooldown.dark_soul_instability.remains|target.time_to_die<=30+gcd|!talent.dark_soul_instability.enabled
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() >= 210 or not bool(S.DarkSoulInstability:CooldownRemainsP()) or Target:TimeToDie() <= 30 + Player:GCD() or not S.DarkSoulInstability:IsAvailable()) then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 201"; end
    end
    -- dark_soul_instability,if=target.time_to_die>=140|pet.infernal.active|target.time_to_die<=20+gcd
    if S.DarkSoulInstability:IsCastableP() and (Target:TimeToDie() >= 140 or bool(pet.infernal.active) or Target:TimeToDie() <= 20 + Player:GCD()) then
      if HR.Cast(S.DarkSoulInstability) then return "dark_soul_instability 207"; end
    end
    -- potion,if=pet.infernal.active|target.time_to_die<65
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(pet.infernal.active) or Target:TimeToDie() < 65) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 209"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 211"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 213"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 215"; end
    end
    -- use_items
  end
  Fnb = function()
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (Player:SoulShardsP() >= 4.5) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 220"; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return "immolate 222"; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 238"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc244) then return "havoc 254" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 255"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=4&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt269) then return "chaos_bolt 297" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc302) then return "havoc 304" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4) then
      if HR.Cast(S.Havoc) then return "havoc 305"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt311) then return "chaos_bolt 321" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&spell_targets.incinerate<=8
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate326) then return "immolate 336" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 337"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains&spell_targets.incinerate=3
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire343) then return "soul_fire 347" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&(talent.flashover.enabled&buff.backdraft.stack<=2|spell_targets.incinerate<=7|talent.roaring_blaze.enabled&spell_targets.incinerate<=9)
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate352) then return "conflagrate 362" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate367) then return "incinerate 371" end
    end
  end
  Inf = function()
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (Player:SoulShardsP() >= 4.5) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 374"; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
      if HR.Cast(S.Cataclysm) then return "cataclysm 376"; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return "immolate 378"; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 394"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc400) then return "havoc 412" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 413"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&((108*spell_targets.rain_of_fire%(3-0.16*spell_targets.rain_of_fire))<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt429) then return "chaos_bolt 453" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc458) then return "havoc 464" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())) then
      if HR.Cast(S.Havoc) then return "havoc 465"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt475) then return "chaos_bolt 489" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate494) then return "immolate 504" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 505"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire511) then return "soul_fire 515" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate520) then return "conflagrate 524" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn529) then return "shadowburn 549" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate554) then return "incinerate 558" end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- run_action_list,name=cata,if=spell_targets.infernal_awakening>=3&talent.cataclysm.enabled
    if (Cache.EnemiesCount[5] >= 3 and S.Cataclysm:IsAvailable()) then
      return Cata();
    end
    -- run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3&talent.fire_and_brimstone.enabled
    if (Cache.EnemiesCount[5] >= 3 and S.FireandBrimstone:IsAvailable()) then
      return Fnb();
    end
    -- run_action_list,name=inf,if=spell_targets.infernal_awakening>=3&talent.inferno.enabled
    if (Cache.EnemiesCount[5] >= 3 and S.Inferno:IsAvailable()) then
      return Inf();
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
      if HR.Cast(S.Cataclysm) then return "cataclysm 572"; end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&(refreshable|talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains-action.chaos_bolt.travel_time-5<duration*0.3)
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate578) then return "immolate 610" end
    end
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 613"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc619) then return "havoc 621" end
    end
    -- havoc,if=active_enemies>1
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Havoc) then return "havoc 622"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire636) then return "soul_fire 640" end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(talent.internal_combustion.enabled|!talent.internal_combustion.enabled&soul_shard>=4|(talent.eradication.enabled&debuff.eradication.remains<=cast_time)|buff.dark_soul_instability.remains>cast_time|pet.infernal.active&talent.grimoire_of_supremacy.enabled)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt645) then return "chaos_bolt 677" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&((talent.flashover.enabled&buff.backdraft.stack<=2)|(!talent.flashover.enabled&buff.backdraft.stack<2))
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate682) then return "conflagrate 694" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn699) then return "shadowburn 719" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate724) then return "incinerate 728" end
    end
  end
end

HR.SetAPL(267, APL)
