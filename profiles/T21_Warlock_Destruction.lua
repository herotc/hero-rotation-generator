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
  SummonPet                             = Spell(),
  GrimoireofSacrifice                   = Spell(),
  SoulFire                              = Spell(),
  Incinerate                            = Spell(29722),
  RainofFire                            = Spell(5740),
  Cataclysm                             = Spell(152108),
  Immolate                              = Spell(348),
  ChannelDemonfire                      = Spell(196447),
  ImmolateDebuff                        = Spell(157736),
  ChaosBolt                             = Spell(116858),
  Havoc                                 = Spell(80240),
  GrimoireofSupremacy                   = Spell(152107),
  HavocDebuff                           = Spell(80240),
  GrimoireofSupremacyBuff               = Spell(),
  ActiveHavocBuff                       = Spell(),
  Conflagrate                           = Spell(17962),
  Shadowburn                            = Spell(17877),
  ShadowburnDebuff                      = Spell(17877),
  BackdraftBuff                         = Spell(117828),
  SummonInfernal                        = Spell(1122),
  DarkSoulInstability                   = Spell(),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(),
  Flashover                             = Spell(),
  RoaringBlaze                          = Spell(205184),
  InternalCombustion                    = Spell(),
  Eradication                           = Spell(),
  FireandBrimstone                      = Spell(196408),
  Inferno                               = Spell(),
  EradicationDebuff                     = Spell(),
  DarkSoulInstabilityBuff               = Spell()
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

-- Variables

local EnemyRanges = {5, 35, 40}
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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cata, Cds, Fnb, Inf
  UpdateRanges()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() and (true) then
      if HR.Cast(S.SummonPet) then return ""; end
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
      if HR.Cast(S.GrimoireofSacrifice) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() and (true) then
      if HR.Cast(S.SoulFire) then return ""; end
    end
    -- incinerate,if=!talent.soul_fire.enabled
    if S.Incinerate:IsCastableP() and (not S.SoulFire:IsAvailable()) then
      if HR.Cast(S.Incinerate) then return ""; end
    end
  end
  Cata = function()
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (FutureShard() >= 4.5) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() and (true) then
      if HR.Cast(S.Cataclysm) then return ""; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() and (true) then
      if HR.Cast(S.ChannelDemonfire) then return ""; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 8 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- havoc,if=spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 8 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=8&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 8 and ((108 * Cache.EnemiesCount[35] / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))) then
      if HR.Cast(S.ChaosBolt) then return ""; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4
    if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4) then
      if HR.Cast(S.ChaosBolt) then return ""; end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&remains<=cooldown.cataclysm.remains
    if S.Immolate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff) and Target:DebuffRemainsP(S.ImmolateDebuff) <= S.Cataclysm:CooldownRemainsP()) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() and (true) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.SoulFire) then return ""; end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.Conflagrate) then return ""; end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))) then
      if HR.Cast(S.Shadowburn) then return ""; end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.Incinerate) then return ""; end
    end
  end
  Cds = function()
    -- summon_infernal,if=target.time_to_die>=210|!cooldown.dark_soul_instability.remains|target.time_to_die<=30+gcd|!talent.dark_soul_instability.enabled
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() >= 210 or not bool(S.DarkSoulInstability:CooldownRemainsP()) or Target:TimeToDie() <= 30 + Player:GCD() or not S.DarkSoulInstability:IsAvailable()) then
      if HR.Cast(S.SummonInfernal) then return ""; end
    end
    -- dark_soul_instability,if=target.time_to_die>=140|pet.infernal.active|target.time_to_die<=20+gcd
    if S.DarkSoulInstability:IsCastableP() and (Target:TimeToDie() >= 140 or bool(pet.infernal.active) or Target:TimeToDie() <= 20 + Player:GCD()) then
      if HR.Cast(S.DarkSoulInstability) then return ""; end
    end
    -- potion,if=pet.infernal.active|target.time_to_die<65
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(pet.infernal.active) or Target:TimeToDie() < 65) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.Berserking, Settings.Destruction.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.BloodFury, Settings.Destruction.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and (true) then
      if HR.Cast(S.Fireblood) then return ""; end
    end
    -- use_items
  end
  Fnb = function()
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (FutureShard() >= 4.5) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() and (true) then
      if HR.Cast(S.ChannelDemonfire) then return ""; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=4&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 4 and ((108 * Cache.EnemiesCount[35] / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))) then
      if HR.Cast(S.ChaosBolt) then return ""; end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&spell_targets.incinerate<=8
    if S.Immolate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff) and Cache.EnemiesCount[5] <= 8) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() and (true) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains&spell_targets.incinerate=3
    if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Cache.EnemiesCount[5] == 3) then
      if HR.Cast(S.SoulFire) then return ""; end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&(talent.flashover.enabled&buff.backdraft.stack<=2|spell_targets.incinerate<=7|talent.roaring_blaze.enabled&spell_targets.incinerate<=9)
    if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and (S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2 or Cache.EnemiesCount[5] <= 7 or S.RoaringBlaze:IsAvailable() and Cache.EnemiesCount[5] <= 9)) then
      if HR.Cast(S.Conflagrate) then return ""; end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.Incinerate) then return ""; end
    end
  end
  Inf = function()
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- rain_of_fire,if=soul_shard>=4.5
    if S.RainofFire:IsCastableP() and (FutureShard() >= 4.5) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() and (true) then
      if HR.Cast(S.Cataclysm) then return ""; end
    end
    -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
    if S.Immolate:IsCastableP() and (S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime()) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() and (true) then
      if HR.Cast(S.ChannelDemonfire) then return ""; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- havoc,if=spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and bool(pet.infernal.active) and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&((108*spell_targets.rain_of_fire%(3-0.16*spell_targets.rain_of_fire))<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
    if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and pet.infernal.remains > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 + num(S.InternalCombustion:IsAvailable()) and ((108 * Cache.EnemiesCount[35] / (3 - 0.16 * Cache.EnemiesCount[35])) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime()))))) then
      if HR.Cast(S.ChaosBolt) then return ""; end
    end
    -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- havoc,if=spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.Havoc:IsCastableP() and (Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())) then
      if HR.Cast(S.Havoc) then return ""; end
    end
    -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 3 and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable())) then
      if HR.Cast(S.ChaosBolt) then return ""; end
    end
    -- immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable
    if S.Immolate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff)) then
      if HR.Cast(S.Immolate) then return ""; end
    end
    -- rain_of_fire
    if S.RainofFire:IsCastableP() and (true) then
      if HR.Cast(S.RainofFire) then return ""; end
    end
    -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
    if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.SoulFire) then return ""; end
    end
    -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.Conflagrate) then return ""; end
    end
    -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
    if S.Shadowburn:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))) then
      if HR.Cast(S.Shadowburn) then return ""; end
    end
    -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
    if S.Incinerate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
      if HR.Cast(S.Incinerate) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=cata,if=spell_targets.infernal_awakening>=3&talent.cataclysm.enabled
  if (Cache.EnemiesCount[40] >= 3 and S.Cataclysm:IsAvailable()) then
    return Cata();
  end
  -- run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3&talent.fire_and_brimstone.enabled
  if (Cache.EnemiesCount[40] >= 3 and S.FireandBrimstone:IsAvailable()) then
    return Fnb();
  end
  -- run_action_list,name=inf,if=spell_targets.infernal_awakening>=3&talent.inferno.enabled
  if (Cache.EnemiesCount[40] >= 3 and S.Inferno:IsAvailable()) then
    return Inf();
  end
  -- immolate,cycle_targets=1,if=!debuff.havoc.remains&(refreshable|talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains-action.chaos_bolt.travel_time-5<duration*0.3)
  if S.Immolate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and (Target:DebuffRefreshableCP(S.ImmolateDebuff) or S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and Target:DebuffRemainsP(S.ImmolateDebuff) - S.ChaosBolt:TravelTime() - 5 < S.ImmolateDebuff:BaseDuration() * 0.3)) then
    if HR.Cast(S.Immolate) then return ""; end
  end
  -- call_action_list,name=cds
  if (true) then
    local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
  end
  -- havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10
  if S.Havoc:IsCastableP() and (not (target == sim.target) and Target:TimeToDie() > 10) then
    if HR.Cast(S.Havoc) then return ""; end
  end
  -- havoc,if=active_enemies>1
  if S.Havoc:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
    if HR.Cast(S.Havoc) then return ""; end
  end
  -- channel_demonfire
  if S.ChannelDemonfire:IsCastableP() and (true) then
    if HR.Cast(S.ChannelDemonfire) then return ""; end
  end
  -- cataclysm
  if S.Cataclysm:IsCastableP() and (true) then
    if HR.Cast(S.Cataclysm) then return ""; end
  end
  -- soul_fire,cycle_targets=1,if=!debuff.havoc.remains
  if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
    if HR.Cast(S.SoulFire) then return ""; end
  end
  -- chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(talent.internal_combustion.enabled|!talent.internal_combustion.enabled&soul_shard>=4|(talent.eradication.enabled&debuff.eradication.remains<=cast_time)|buff.dark_soul_instability.remains>cast_time|pet.infernal.active&talent.grimoire_of_supremacy.enabled)
  if S.ChaosBolt:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < Target:TimeToDie() and (S.InternalCombustion:IsAvailable() or not S.InternalCombustion:IsAvailable() and FutureShard() >= 4 or (S.Eradication:IsAvailable() and Target:DebuffRemainsP(S.EradicationDebuff) <= S.ChaosBolt:CastTime()) or Player:BuffRemainsP(S.DarkSoulInstabilityBuff) > S.ChaosBolt:CastTime() or bool(pet.infernal.active) and S.GrimoireofSupremacy:IsAvailable())) then
    if HR.Cast(S.ChaosBolt) then return ""; end
  end
  -- conflagrate,cycle_targets=1,if=!debuff.havoc.remains&((talent.flashover.enabled&buff.backdraft.stack<=2)|(!talent.flashover.enabled&buff.backdraft.stack<2))
  if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2) or (not S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) < 2))) then
    if HR.Cast(S.Conflagrate) then return ""; end
  end
  -- shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
  if S.Shadowburn:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime()))) then
    if HR.Cast(S.Shadowburn) then return ""; end
  end
  -- incinerate,cycle_targets=1,if=!debuff.havoc.remains
  if S.Incinerate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
    if HR.Cast(S.Incinerate) then return ""; end
  end
end

HR.SetAPL(267, APL)
