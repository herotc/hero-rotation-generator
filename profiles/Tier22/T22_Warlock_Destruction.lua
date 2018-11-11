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
  ActiveHavocBuff                       = Spell(80240),
  Havoc                                 = Spell(80240),
  GrimoireofSupremacy                   = Spell(266086),
  HavocDebuff                           = Spell(80240),
  GrimoireofSupremacyBuff               = Spell(266091),
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


local function EvaluateCycleHavoc48(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 8 + raid_event.invulnerable.up and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt73(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 8 + raid_event.invulnerable.up and ((108 * (Cache.EnemiesCount[35] + raid_event.invulnerable.up) / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc106(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up
end

local function EvaluateCycleChaosBolt115(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up
end

local function EvaluateCycleImmolate130(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) and TargetUnit:DebuffRemainsP(S.ImmolateDebuff) <= S.Cataclysm:CooldownRemainsP()
end

local function EvaluateCycleSoulFire155(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleConflagrate164(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleShadowburn173(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate198(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleHavoc248(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt273(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 4 + raid_event.invulnerable.up and ((108 * (Cache.EnemiesCount[35] + raid_event.invulnerable.up) / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc306(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up
end

local function EvaluateCycleChaosBolt315(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up
end

local function EvaluateCycleImmolate330(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) and Cache.EnemiesCount[5] <= 8 + raid_event.invulnerable.up
end

local function EvaluateCycleSoulFire347(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Cache.EnemiesCount[5] <= 3 + raid_event.invulnerable.up
end

local function EvaluateCycleConflagrate356(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and (S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2 or Cache.EnemiesCount[5] <= 7 + raid_event.invulnerable.up or S.RoaringBlaze:IsAvailable() and Cache.EnemiesCount[5] <= 9 + raid_event.invulnerable.up)
end

local function EvaluateCycleIncinerate371(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleHavoc406(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and TargetUnit:DebuffRemainsP(S.HavocDebuff) <= 10
end

local function EvaluateCycleChaosBolt435(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up + num(S.InternalCombustion:IsAvailable()) and ((108 * (Cache.EnemiesCount[35] + raid_event.invulnerable.up) / (3 - 0.16 * (Cache.EnemiesCount[35] + raid_event.invulnerable.up))) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))
end

local function EvaluateCycleHavoc464(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 3 + raid_event.invulnerable.up and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())
end

local function EvaluateCycleChaosBolt481(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 3 + raid_event.invulnerable.up and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())
end

local function EvaluateCycleImmolate500(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff)
end

local function EvaluateCycleSoulFire517(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleConflagrate526(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleShadowburn535(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate560(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleImmolate584(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and (TargetUnit:DebuffRefreshableCP(S.ImmolateDebuff) or S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and TargetUnit:DebuffRemainsP(S.ImmolateDebuff) - S.ChaosBolt:TravelTime() - 5 < S.ImmolateDebuff:BaseDuration() * 0.3)
end

local function EvaluateCycleHavoc627(TargetUnit)
  return not (target == sim.target) and TargetUnit:TimeToDie() > 10 and Cache.EnemiesCount[40] > 1 + raid_event.invulnerable.up
end

local function EvaluateCycleSoulFire652(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff))
end

local function EvaluateCycleChaosBolt661(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < TargetUnit:TimeToDie() and (bool(trinket.proc.intellect.react) and trinket.proc.intellect.remains > S.ChaosBolt:CastTime() or bool(trinket.proc.mastery.react) and trinket.proc.mastery.remains > S.ChaosBolt:CastTime() or bool(trinket.proc.versatility.react) and trinket.proc.versatility.remains > S.ChaosBolt:CastTime() or bool(trinket.proc.crit.react) and trinket.proc.crit.remains > S.ChaosBolt:CastTime() or bool(trinket.proc.spell_power.react) and trinket.proc.spell_power.remains > S.ChaosBolt:CastTime())
end

local function EvaluateCycleChaosBolt698(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < TargetUnit:TimeToDie() and (bool(trinket.stacking_proc.intellect.react) and trinket.stacking_proc.intellect.remains > S.ChaosBolt:CastTime() or bool(trinket.stacking_proc.mastery.react) and trinket.stacking_proc.mastery.remains > S.ChaosBolt:CastTime() or bool(trinket.stacking_proc.versatility.react) and trinket.stacking_proc.versatility.remains > S.ChaosBolt:CastTime() or bool(trinket.stacking_proc.crit.react) and trinket.stacking_proc.crit.remains > S.ChaosBolt:CastTime() or bool(trinket.stacking_proc.spell_power.react) and trinket.stacking_proc.spell_power.remains > S.ChaosBolt:CastTime())
end

local function EvaluateCycleChaosBolt735(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < TargetUnit:TimeToDie() and (S.SummonInfernal:CooldownRemainsP() >= 20 or not S.GrimoireofSupremacy:IsAvailable()) and (S.DarkSoulInstability:CooldownRemainsP() >= 20 or not S.DarkSoulInstability:IsAvailable()) and (S.Eradication:IsAvailable() and TargetUnit:DebuffRemainsP(S.EradicationDebuff) <= S.ChaosBolt:CastTime() or bool(Player:BuffRemainsP(S.BackdraftBuff)) or S.InternalCombustion:IsAvailable())
end

local function EvaluateCycleChaosBolt772(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < TargetUnit:TimeToDie() and (Player:SoulShardsP() >= 4 or Player:BuffRemainsP(S.DarkSoulInstabilityBuff) > S.ChaosBolt:CastTime() or bool(pet.infernal.active) or Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:CastTime())
end

local function EvaluateCycleConflagrate801(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2) or (not S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) < 2))
end

local function EvaluateCycleShadowburn818(TargetUnit)
  return not bool(TargetUnit:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))
end

local function EvaluateCycleIncinerate843(TargetUnit)
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
    -- channel_demonfire,if=!buff.active_havoc.remains
    if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 40"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=8+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc48) then return "havoc 58" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=8+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 8 + raid_event.invulnerable.up and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 59"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=8+raid_event.invulnerable.up&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt73) then return "chaos_bolt 101" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc106) then return "havoc 108" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up) then
      if HR.Cast(S.Havoc) then return "havoc 109"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt115) then return "chaos_bolt 125" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&remains<=cooldown.cataclysm.remains
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate130) then return "immolate 148" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 149"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire155) then return "soul_fire 159" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate164) then return "conflagrate 168" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn173) then return "shadowburn 193" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate198) then return "incinerate 202" end
    end
  end
  Cds = function()
    -- summon_infernal,if=target.time_to_die>=210|!cooldown.dark_soul_instability.remains|target.time_to_die<=30+gcd|!talent.dark_soul_instability.enabled
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() >= 210 or not bool(S.DarkSoulInstability:CooldownRemainsP()) or Target:TimeToDie() <= 30 + Player:GCD() or not S.DarkSoulInstability:IsAvailable()) then
      if HR.Cast(S.SummonInfernal) then return "summon_infernal 203"; end
    end
    -- dark_soul_instability,if=target.time_to_die>=140|pet.infernal.active|target.time_to_die<=20+gcd
    if S.DarkSoulInstability:IsCastableP() and (Target:TimeToDie() >= 140 or bool(pet.infernal.active) or Target:TimeToDie() <= 20 + Player:GCD()) then
      if HR.Cast(S.DarkSoulInstability) then return "dark_soul_instability 209"; end
    end
    -- potion,if=pet.infernal.active|target.time_to_die<65
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(pet.infernal.active) or Target:TimeToDie() < 65) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 211"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 213"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 215"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 217"; end
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
      if HR.Cast(S.RainofFire) then return "rain_of_fire 222"; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return "immolate 224"; end
    end
    -- channel_demonfire,if=!buff.active_havoc.remains
    if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 240"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc248) then return "havoc 258" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 259"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=4+raid_event.invulnerable.up&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt273) then return "chaos_bolt 301" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc306) then return "havoc 308" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up) then
      if HR.Cast(S.Havoc) then return "havoc 309"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt315) then return "chaos_bolt 325" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&spell_targets.incinerate<=8+raid_event.invulnerable.up
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate330) then return "immolate 340" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 341"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains&spell_targets.incinerate<=3+raid_event.invulnerable.up
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire347) then return "soul_fire 351" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&(talent.flashover.enabled&buff.backdraft.stack<=2|spell_targets.incinerate<=7+raid_event.invulnerable.up|talent.roaring_blaze.enabled&spell_targets.incinerate<=9+raid_event.invulnerable.up)
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate356) then return "conflagrate 366" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate371) then return "incinerate 375" end
    end
  end
  Inf = function()
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (Player:SoulShardsP() >= 4.5) then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 378"; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
      if HR.Cast(S.Cataclysm) then return "cataclysm 380"; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return "immolate 382"; end
    end
    -- channel_demonfire,if=!buff.active_havoc.remains
    if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 398"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc406) then return "havoc 418" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + raid_event.invulnerable.up + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return "havoc 419"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%(3-0.16*(spell_targets.rain_of_fire+raid_event.invulnerable.up)))<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt435) then return "chaos_bolt 459" end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc464) then return "havoc 470" end
    end
    -- havoc,if=spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 3 + raid_event.invulnerable.up and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())) then
      if HR.Cast(S.Havoc) then return "havoc 471"; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt481) then return "chaos_bolt 495" end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate500) then return "immolate 510" end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() then
      if HR.Cast(S.RainofFire) then return "rain_of_fire 511"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire517) then return "soul_fire 521" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate526) then return "conflagrate 530" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn535) then return "shadowburn 555" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate560) then return "incinerate 564" end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- run_action_list,name=cata,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.cataclysm.enabled
    if (Cache.EnemiesCount[5] >= 3 + raid_event.invulnerable.up and S.Cataclysm:IsAvailable()) then
      return Cata();
    end
    -- run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.fire_and_brimstone.enabled
    if (Cache.EnemiesCount[5] >= 3 + raid_event.invulnerable.up and S.FireandBrimstone:IsAvailable()) then
      return Fnb();
    end
    -- run_action_list,name=inf,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.inferno.enabled
    if (Cache.EnemiesCount[5] >= 3 + raid_event.invulnerable.up and S.Inferno:IsAvailable()) then
      return Inf();
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
      if HR.Cast(S.Cataclysm) then return "cataclysm 578"; end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&(refreshable|talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains-action.chaos_bolt.travel_time-5<duration*0.3)
    if S.Immolate:IsCastableP() then
      if HR.CastCycle(S.Immolate, 40, EvaluateCycleImmolate584) then return "immolate 616" end
    end
    -- call_action_list,name=cds
    if HR.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- channel_demonfire,if=!buff.active_havoc.remains
    if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
      if HR.Cast(S.ChannelDemonfire) then return "channel_demonfire 619"; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&active_enemies>1+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() then
      if HR.CastCycle(S.Havoc, 40, EvaluateCycleHavoc627) then return "havoc 637" end
    end
    -- havoc,if=active_enemies>1+raid_event.invulnerable.up
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[40] > 1 + raid_event.invulnerable.up) then
      if HR.Cast(S.Havoc) then return "havoc 638"; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() then
      if HR.CastCycle(S.SoulFire, 40, EvaluateCycleSoulFire652) then return "soul_fire 656" end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(trinket.proc.intellect.react&trinket.proc.intellect.remains>cast_time|trinket.proc.mastery.react&trinket.proc.mastery.remains>cast_time|trinket.proc.versatility.react&trinket.proc.versatility.remains>cast_time|trinket.proc.crit.react&trinket.proc.crit.remains>cast_time|trinket.proc.spell_power.react&trinket.proc.spell_power.remains>cast_time)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt661) then return "chaos_bolt 693" end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(trinket.stacking_proc.intellect.react&trinket.stacking_proc.intellect.remains>cast_time|trinket.stacking_proc.mastery.react&trinket.stacking_proc.mastery.remains>cast_time|trinket.stacking_proc.versatility.react&trinket.stacking_proc.versatility.remains>cast_time|trinket.stacking_proc.crit.react&trinket.stacking_proc.crit.remains>cast_time|trinket.stacking_proc.spell_power.react&trinket.stacking_proc.spell_power.remains>cast_time)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt698) then return "chaos_bolt 730" end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(cooldown.summon_infernal.remains>=20|!talent.grimoire_of_supremacy.enabled)&(cooldown.dark_soul_instability.remains>=20|!talent.dark_soul_instability.enabled)&(talent.eradication.enabled&debuff.eradication.remains<=cast_time|buff.backdraft.remains|talent.internal_combustion.enabled)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt735) then return "chaos_bolt 767" end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(soul_shard>=4|buff.dark_soul_instability.remains>cast_time|pet.infernal.active|buff.active_havoc.remains>cast_time)
    if S.ChaosBolt:IsCastableP() then
      if HR.CastCycle(S.ChaosBolt, 40, EvaluateCycleChaosBolt772) then return "chaos_bolt 796" end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&((talent.flashover.enabled&buff.backdraft.stack<=2)|(!talent.flashover.enabled&buff.backdraft.stack<2))
    if S.Conflagrate:IsCastableP() then
      if HR.CastCycle(S.Conflagrate, 40, EvaluateCycleConflagrate801) then return "conflagrate 813" end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() then
      if HR.CastCycle(S.Shadowburn, 40, EvaluateCycleShadowburn818) then return "shadowburn 838" end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() then
      if HR.CastCycle(S.Incinerate, 40, EvaluateCycleIncinerate843) then return "incinerate 847" end
    end
  end
end

HR.SetAPL(267, APL)
