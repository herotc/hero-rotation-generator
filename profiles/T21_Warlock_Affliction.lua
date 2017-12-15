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
if not Spell.Warlock then Spell.Warlock = {} end
Spell.Warlock.Affliction = {
  SummonPet                             = Spell(),
  GrimoireofSupremacy                   = Spell(152107),
  GrimoireofSacrifice                   = Spell(),
  DemonicPowerBuff                      = Spell(),
  SummonInfernal                        = Spell(1122),
  LordofFlames                          = Spell(),
  SummonDoomguard                       = Spell(18540),
  LifeTap                               = Spell(1454),
  EmpoweredLifeTap                      = Spell(235157),
  EmpoweredLifeTapBuff                  = Spell(235156),
  ReapSouls                             = Spell(216698),
  DeadwindHarvesterBuff                 = Spell(216708),
  TormentedSoulsBuff                    = Spell(216695),
  HauntDebuff                           = Spell(48181),
  SowtheSeeds                           = Spell(196226),
  Agony                                 = Spell(980),
  DrainSoul                             = Spell(198590),
  ServicePet                            = Spell(),
  CorruptionDebuff                      = Spell(172),
  AgonyDebuff                           = Spell(980),
  SindoreiSpiteIcd                      = Spell(),
  Berserking                            = Spell(26297),
  UnstableAffliction                    = Spell(30108),
  SoulHarvestBuff                       = Spell(196098),
  BloodFury                             = Spell(20572),
  SoulHarvest                           = Spell(196098),
  ActiveUasBuff                         = Spell(),
  Haunt                                 = Spell(48181),
  SiphonLife                            = Spell(63106),
  Corruption                            = Spell(172),
  PhantomSingularity                    = Spell(205179),
  MaleficGrasp                          = Spell(235155),
  UnstableAffliction1                   = Spell(),
  SeedofCorruption                      = Spell(27243),
  Contagion                             = Spell(196105),
  UnstableAffliction1Debuff             = Spell(),
  UnstableAffliction2Debuff             = Spell(),
  UnstableAffliction3Debuff             = Spell(),
  UnstableAffliction4Debuff             = Spell(),
  UnstableAffliction5Debuff             = Spell(),
  DeathsEmbrace                         = Spell(234876),
  ConcordanceoftheLegionfallBuff        = Spell(242586),
  WritheInAgony                         = Spell(196102)
};
local S = Spell.Warlock.Affliction;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Affliction = {
  ProlongedPower                   = Item(142117),
  Item144364                       = Item(144364),
  Item132379                       = Item(132379),
  Item132381                       = Item(132381),
  Item132457                       = Item(132457)
};
local I = Item.Warlock.Affliction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Warlock.Commons,
  Affliction = AR.GUISettings.APL.Warlock.Affliction
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
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
    if S.SummonPet:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and (not S.GrimoireofSacrifice:IsAvailable() or Player:BuffDownP(S.DemonicPowerBuff))) then
      if AR.Cast(S.SummonPet) then return ""; end
    end
    -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
    if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and S.LordofFlames:ArtifactRank() > 0) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>1
    if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 1) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies=1&artifact.lord_of_flames.rank=0
    if S.SummonDoomguard:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[40] == 1 and S.LordofFlames:ArtifactRank() == 0) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- snapshot_stats
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
      if AR.Cast(S.GrimoireofSacrifice) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&!buff.empowered_life_tap.remains
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and not bool(Player:BuffRemainsP(S.EmpoweredLifeTapBuff))) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Haunt()
    -- reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.tormented_souls.react>=5|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and AC.CombatTime() > 5 and (Player:BuffStackP(S.TormentedSoulsBuff) >= 5 or Target:TimeToDie() <= Player:BuffStackP(S.TormentedSoulsBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) + (Player:BuffRemainsP(S.DeadwindHarvesterBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) / 12 * (5 + 1.5 * num(I.Item144364:IsEquipped()))))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- reap_souls,if=debuff.haunt.remains&!buff.deadwind_harvester.remains
    if S.ReapSouls:IsCastableP() and (bool(Target:DebuffRemainsP(S.HauntDebuff)) and not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- reap_souls,if=active_enemies>1&!buff.deadwind_harvester.remains&time>5&soul_shard>0&((talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|spell_targets.seed_of_corruption>=5)
    if S.ReapSouls:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and AC.CombatTime() > 5 and soul_shard > 0 and ((S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3) or Cache.EnemiesCount[40] >= 5)) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- agony,cycle_targets=1,if=remains<=tick_time+gcd
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= S.Agony:TickTime() + Player:GCD()) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- drain_soul,cycle_targets=1,if=target.time_to_die<=gcd*2&soul_shard<5
    if S.DrainSoul:IsCastableP() and (Target:TimeToDie() <= Player:GCD() * 2 and soul_shard < 5) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- service_pet,if=dot.corruption.remains&dot.agony.remains
    if S.ServicePet:IsCastableP() and (bool(Target:DebuffRemainsP(S.CorruptionDebuff)) and bool(Target:DebuffRemainsP(S.AgonyDebuff))) then
      if AR.Cast(S.ServicePet) then return ""; end
    end
    -- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
    if S.SummonDoomguard:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] <= 2 and (Target:TimeToDie() > 180 or Target:HealthPercentage() <= 20 or Target:TimeToDie() < 30)) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
    if S.SummonInfernal:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 2) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonDoomguard:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] == 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:PrevGCDP(1, S.UnstableAffliction) or Player:BuffRemainsP(S.SoulHarvestBuff) >= 10) then
      if AR.Cast(S.Berserking, Settings.Affliction.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Affliction.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- soul_harvest,if=buff.soul_harvest.remains<=8&buff.active_uas.stack>=1&(raid_event.adds.in>20|active_enemies>1|!raid_event.adds.exists)
    if S.SoulHarvest:IsCastableP() and (Player:BuffRemainsP(S.SoulHarvestBuff) <= 8 and Player:BuffStackP(S.ActiveUasBuff) >= 1 and (10000000000 > 20 or Cache.EnemiesCount[40] > 1 or not false)) then
      if AR.Cast(S.SoulHarvest) then return ""; end
    end
    -- potion,if=!talent.soul_harvest.enabled&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|buff.active_uas.stack>2)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (not S.SoulHarvest:IsAvailable() and (bool(trinket.proc.any.react) or bool(trinket.stack_proc.any.react) or Target:TimeToDie() <= 70 or Player:BuffStackP(S.ActiveUasBuff) > 2)) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,if=talent.soul_harvest.enabled&buff.soul_harvest.remains&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.SoulHarvest:IsAvailable() and bool(Player:BuffRemainsP(S.SoulHarvestBuff)) and (bool(trinket.proc.any.react) or bool(trinket.stack_proc.any.react) or Target:TimeToDie() <= 70 or not bool(S.Haunt:CooldownRemainsP()) or Player:BuffStackP(S.ActiveUasBuff) > 2)) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- siphon_life,cycle_targets=1,if=remains<=tick_time+gcd
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:TickTime() + Player:GCD()) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,cycle_targets=1,if=remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<5)
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:TickTime() + Player:GCD() and (Cache.EnemiesCount[40] < 3 and S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 5)) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- reap_souls,if=(buff.deadwind_harvester.remains+buff.tormented_souls.react*(5+equipped.144364))>=(12*(5+1.5*equipped.144364))
    if S.ReapSouls:IsCastableP() and ((Player:BuffRemainsP(S.DeadwindHarvesterBuff) + Player:BuffStackP(S.TormentedSoulsBuff) * (5 + num(I.Item144364:IsEquipped()))) >= (12 * (5 + 1.5 * num(I.Item144364:IsEquipped())))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) <= Player:GCD()) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- phantom_singularity
    if S.PhantomSingularity:IsCastableP() and (true) then
      if AR.Cast(S.PhantomSingularity) then return ""; end
    end
    -- haunt
    if S.Haunt:IsCastableP() and (true) then
      if AR.Cast(S.Haunt) then return ""; end
    end
    -- agony,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= S.Agony:BaseDuration() * 0.3 and Target:TimeToDie() >= Target:DebuffRemainsP(S.Agony)) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) < S.LifeTap:BaseDuration() * 0.3 or S.MaleficGrasp:IsAvailable() and Target:TimeToDie() > 15 and Player:ManaPercentage() < 10) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- siphon_life,if=remains<=duration*0.3&target.time_to_die>=remains
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:BaseDuration() * 0.3 and Target:TimeToDie() >= Target:DebuffRemainsP(S.SiphonLife)) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- siphon_life,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*6&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*4
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:BaseDuration() * 0.3 and Target:TimeToDie() >= Target:DebuffRemainsP(S.SiphonLife) and Target:DebuffRemainsP(S.HauntDebuff) >= S.UnstableAffliction1:TickTime() * 6 and Target:DebuffRemainsP(S.HauntDebuff) >= S.UnstableAffliction1:TickTime() * 4) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3|spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=3&dot.corruption.remains<=cast_time+travel_time
    if S.SeedofCorruption:IsCastableP() and (S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3 or Cache.EnemiesCount[40] >= 5 or Cache.EnemiesCount[40] >= 3 and Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + S.SeedofCorruption:TravelTime()) then
      if AR.Cast(S.SeedofCorruption) then return ""; end
    end
    -- corruption,if=remains<=duration*0.3&target.time_to_die>=remains
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:BaseDuration() * 0.3 and Target:TimeToDie() >= Target:DebuffRemainsP(S.Corruption)) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- corruption,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*6&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*4
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:BaseDuration() * 0.3 and Target:TimeToDie() >= Target:DebuffRemainsP(S.Corruption) and Target:DebuffRemainsP(S.HauntDebuff) >= S.UnstableAffliction1:TickTime() * 6 and Target:DebuffRemainsP(S.HauntDebuff) >= S.UnstableAffliction1:TickTime() * 4) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&((soul_shard>=4&!talent.contagion.enabled)|soul_shard>=5|target.time_to_die<30)
    if S.UnstableAffliction:IsCastableP() and ((not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and Cache.EnemiesCount[40] < 5 and ((soul_shard >= 4 and not S.Contagion:IsAvailable()) or soul_shard >= 5 or Target:TimeToDie() < 30)) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,cycle_targets=1,if=active_enemies>1&(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&soul_shard>=4&talent.contagion.enabled&cooldown.haunt.remains<15&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if S.UnstableAffliction:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and soul_shard >= 4 and S.Contagion:IsAvailable() and S.Haunt:CooldownRemainsP() < 15 and Target:DebuffRemainsP(S.UnstableAffliction1Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction2Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction3Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction4Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction5Debuff) < S.UnstableAffliction:CastTime()) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,cycle_targets=1,if=active_enemies>1&(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&(equipped.132381|equipped.132457)&cooldown.haunt.remains<15&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if S.UnstableAffliction:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and (I.Item132381:IsEquipped() or I.Item132457:IsEquipped()) and S.Haunt:CooldownRemainsP() < 15 and Target:DebuffRemainsP(S.UnstableAffliction1Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction2Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction3Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction4Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction5Debuff) < S.UnstableAffliction:CastTime()) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&talent.contagion.enabled&soul_shard>=4&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if S.UnstableAffliction:IsCastableP() and ((not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and Cache.EnemiesCount[40] < 5 and S.Contagion:IsAvailable() and soul_shard >= 4 and Target:DebuffRemainsP(S.UnstableAffliction1Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction2Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction3Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction4Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction5Debuff) < S.UnstableAffliction:CastTime()) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*2
    if S.UnstableAffliction:IsCastableP() and ((not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and Cache.EnemiesCount[40] < 5 and Target:DebuffRemainsP(S.HauntDebuff) >= S.UnstableAffliction1:TickTime() * 2) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- reap_souls,if=!buff.deadwind_harvester.remains&(buff.active_uas.stack>1|(prev_gcd.1.unstable_affliction&buff.tormented_souls.react>1))
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and (Player:BuffStackP(S.ActiveUasBuff) > 1 or (Player:PrevGCDP(1, S.UnstableAffliction) and Player:BuffStackP(S.TormentedSoulsBuff) > 1))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- life_tap,if=mana.pct<=10
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() <= 10) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
    if S.LifeTap:IsCastableP() and (Player:PrevGCDP(1, S.LifeTap) and Player:BuffStackP(S.ActiveUasBuff) == 0 and Player:ManaPercentage() < 50) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- drain_soul,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() and (true) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- life_tap,moving=1,if=mana.pct<80
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() < 80) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- agony,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= S.Agony:BaseDuration() - (3 * S.Agony:TickTime())) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:BaseDuration() - (3 * S.SiphonLife:TickTime())) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:BaseDuration() - (3 * S.Corruption:TickTime())) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,moving=0
    if S.LifeTap:IsCastableP() and (true) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
  end
  local function Mg()
    -- reap_souls,if=!buff.deadwind_harvester.remains&time>5&((buff.tormented_souls.react>=4+active_enemies|buff.tormented_souls.react>=9)|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and AC.CombatTime() > 5 and ((Player:BuffStackP(S.TormentedSoulsBuff) >= 4 + Cache.EnemiesCount[40] or Player:BuffStackP(S.TormentedSoulsBuff) >= 9) or Target:TimeToDie() <= Player:BuffStackP(S.TormentedSoulsBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) + (Player:BuffRemainsP(S.DeadwindHarvesterBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) / 12 * (5 + 1.5 * num(I.Item144364:IsEquipped()))))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- agony,cycle_targets=1,max_cycle_targets=5,target_if=sim.target!=target&talent.soul_harvest.enabled&cooldown.soul_harvest.remains<cast_time*6&remains<=duration*0.3&target.time_to_die>=remains&time_to_die>tick_time*3
    if S.Agony:IsCastableP() and (true) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- agony,cycle_targets=1,max_cycle_targets=4,if=remains<=(tick_time+gcd)
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= (S.Agony:TickTime() + Player:GCD())) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3&soul_shard=5
    if S.SeedofCorruption:IsCastableP() and (S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3 and soul_shard == 5) then
      if AR.Cast(S.SeedofCorruption) then return ""; end
    end
    -- unstable_affliction,if=target=sim.target&soul_shard=5
    if S.UnstableAffliction:IsCastableP() and (target == sim.target and soul_shard == 5) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- drain_soul,cycle_targets=1,if=target.time_to_die<gcd*2&soul_shard<5
    if S.DrainSoul:IsCastableP() and (Target:TimeToDie() < Player:GCD() * 2 and soul_shard < 5) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) <= Player:GCD()) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- service_pet,if=dot.corruption.remains&dot.agony.remains
    if S.ServicePet:IsCastableP() and (bool(Target:DebuffRemainsP(S.CorruptionDebuff)) and bool(Target:DebuffRemainsP(S.AgonyDebuff))) then
      if AR.Cast(S.ServicePet) then return ""; end
    end
    -- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
    if S.SummonDoomguard:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] <= 2 and (Target:TimeToDie() > 180 or Target:HealthPercentage() <= 20 or Target:TimeToDie() < 30)) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
    if S.SummonInfernal:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 2) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonDoomguard:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] == 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:PrevGCDP(1, S.UnstableAffliction) or Player:BuffRemainsP(S.SoulHarvestBuff) >= 10) then
      if AR.Cast(S.Berserking, Settings.Affliction.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Affliction.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- siphon_life,cycle_targets=1,if=remains<=(tick_time+gcd)&target.time_to_die>tick_time*3
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= (S.SiphonLife:TickTime() + Player:GCD()) and Target:TimeToDie() > S.SiphonLife:TickTime() * 3) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,cycle_targets=1,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&remains<=(tick_time+gcd)&target.time_to_die>tick_time*3
    if S.Corruption:IsCastableP() and ((not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and Cache.EnemiesCount[40] < 5 and Target:DebuffRemainsP(S.Corruption) <= (S.Corruption:TickTime() + Player:GCD()) and Target:TimeToDie() > S.Corruption:TickTime() * 3) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- phantom_singularity
    if S.PhantomSingularity:IsCastableP() and (true) then
      if AR.Cast(S.PhantomSingularity) then return ""; end
    end
    -- soul_harvest,if=buff.active_uas.stack>1&buff.soul_harvest.remains<=8&sim.target=target&(!talent.deaths_embrace.enabled|target.time_to_die>=136|target.time_to_die<=40)
    if S.SoulHarvest:IsCastableP() and (Player:BuffStackP(S.ActiveUasBuff) > 1 and Player:BuffRemainsP(S.SoulHarvestBuff) <= 8 and sim.target == target and (not S.DeathsEmbrace:IsAvailable() or Target:TimeToDie() >= 136 or Target:TimeToDie() <= 40)) then
      if AR.Cast(S.SoulHarvest) then return ""; end
    end
    -- potion,if=target.time_to_die<=70
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Target:TimeToDie() <= 70) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,if=(!talent.soul_harvest.enabled|buff.soul_harvest.remains>12)&buff.active_uas.stack>=2
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((not S.SoulHarvest:IsAvailable() or Player:BuffRemainsP(S.SoulHarvestBuff) > 12) and Player:BuffStackP(S.ActiveUasBuff) >= 2) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- agony,cycle_targets=1,if=remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.agony)
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= (S.Agony:BaseDuration() * 0.3) and Target:TimeToDie() >= Target:DebuffRemainsP(S.Agony) and (Player:BuffStackP(S.ActiveUasBuff) == 0 or Player:PrevGCDP(1, S.Agony))) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,cycle_targets=1,if=remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.siphon_life)
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= (S.SiphonLife:BaseDuration() * 0.3) and Target:TimeToDie() >= Target:DebuffRemainsP(S.SiphonLife) and (Player:BuffStackP(S.ActiveUasBuff) == 0 or Player:PrevGCDP(1, S.SiphonLife))) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,cycle_targets=1,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.corruption)
    if S.Corruption:IsCastableP() and ((not S.SowtheSeeds:IsAvailable() or Cache.EnemiesCount[40] < 3) and Cache.EnemiesCount[40] < 5 and Target:DebuffRemainsP(S.Corruption) <= (S.Corruption:BaseDuration() * 0.3) and Target:TimeToDie() >= Target:DebuffRemainsP(S.Corruption) and (Player:BuffStackP(S.ActiveUasBuff) == 0 or Player:PrevGCDP(1, S.Corruption))) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) < S.LifeTap:BaseDuration() * 0.3 or S.MaleficGrasp:IsAvailable() and Target:TimeToDie() > 15 and Player:ManaPercentage() < 10) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- seed_of_corruption,if=(talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|(spell_targets.seed_of_corruption>=5&dot.corruption.remains<=cast_time+travel_time)
    if S.SeedofCorruption:IsCastableP() and ((S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3) or (Cache.EnemiesCount[40] >= 5 and Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + S.SeedofCorruption:TravelTime())) then
      if AR.Cast(S.SeedofCorruption) then return ""; end
    end
    -- unstable_affliction,if=target=sim.target&target.time_to_die<30
    if S.UnstableAffliction:IsCastableP() and (target == sim.target and Target:TimeToDie() < 30) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,if=target=sim.target&active_enemies>1&soul_shard>=4
    if S.UnstableAffliction:IsCastableP() and (target == sim.target and Cache.EnemiesCount[40] > 1 and soul_shard >= 4) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,if=target=sim.target&(buff.active_uas.stack=0|(!prev_gcd.3.unstable_affliction&prev_gcd.1.unstable_affliction))&dot.agony.remains>cast_time+(6.5*spell_haste)
    if S.UnstableAffliction:IsCastableP() and (target == sim.target and (Player:BuffStackP(S.ActiveUasBuff) == 0 or (not Player:PrevGCDP(3, S.UnstableAffliction) and Player:PrevGCDP(1, S.UnstableAffliction))) and Target:DebuffRemainsP(S.AgonyDebuff) > S.UnstableAffliction:CastTime() + (6.5 * Player:SpellHaste())) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- reap_souls,if=buff.deadwind_harvester.remains<dot.unstable_affliction_1.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_2.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_3.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_4.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_5.remains&buff.active_uas.stack>1
    if S.ReapSouls:IsCastableP() and (Player:BuffRemainsP(S.DeadwindHarvesterBuff) < Target:DebuffRemainsP(S.UnstableAffliction1Debuff) or Player:BuffRemainsP(S.DeadwindHarvesterBuff) < Target:DebuffRemainsP(S.UnstableAffliction2Debuff) or Player:BuffRemainsP(S.DeadwindHarvesterBuff) < Target:DebuffRemainsP(S.UnstableAffliction3Debuff) or Player:BuffRemainsP(S.DeadwindHarvesterBuff) < Target:DebuffRemainsP(S.UnstableAffliction4Debuff) or Player:BuffRemainsP(S.DeadwindHarvesterBuff) < Target:DebuffRemainsP(S.UnstableAffliction5Debuff) and Player:BuffStackP(S.ActiveUasBuff) > 1) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- life_tap,if=mana.pct<=10
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() <= 10) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
    if S.LifeTap:IsCastableP() and (Player:PrevGCDP(1, S.LifeTap) and Player:BuffStackP(S.ActiveUasBuff) == 0 and Player:ManaPercentage() < 50) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- drain_soul,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() and (true) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- life_tap,moving=1,if=mana.pct<80
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() < 80) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- agony,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) < S.Agony:BaseDuration() - (3 * S.Agony:TickTime())) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) < S.SiphonLife:BaseDuration() - (3 * S.SiphonLife:TickTime())) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) < S.Corruption:BaseDuration() - (3 * S.Corruption:TickTime())) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,moving=0
    if S.LifeTap:IsCastableP() and (true) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
  end
  local function Writhe()
    -- reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.tormented_souls.react>=5|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and AC.CombatTime() > 5 and (Player:BuffStackP(S.TormentedSoulsBuff) >= 5 or Target:TimeToDie() <= Player:BuffStackP(S.TormentedSoulsBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) + (Player:BuffRemainsP(S.DeadwindHarvesterBuff) * (5 + 1.5 * num(I.Item144364:IsEquipped())) / 12 * (5 + 1.5 * num(I.Item144364:IsEquipped()))))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.soul_harvest.remains>=(5+1.5*equipped.144364)&buff.active_uas.stack>1|buff.concordance_of_the_legionfall.react|trinket.proc.intellect.react|trinket.stacking_proc.intellect.react|trinket.proc.mastery.react|trinket.stacking_proc.mastery.react|trinket.proc.crit.react|trinket.stacking_proc.crit.react|trinket.proc.versatility.react|trinket.stacking_proc.versatility.react|trinket.proc.spell_power.react|trinket.stacking_proc.spell_power.react)
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and AC.CombatTime() > 5 and (Player:BuffRemainsP(S.SoulHarvestBuff) >= (5 + 1.5 * num(I.Item144364:IsEquipped())) and Player:BuffStackP(S.ActiveUasBuff) > 1 or bool(Player:BuffStackP(S.ConcordanceoftheLegionfallBuff)) or bool(trinket.proc.intellect.react) or bool(trinket.stacking_proc.intellect.react) or bool(trinket.proc.mastery.react) or bool(trinket.stacking_proc.mastery.react) or bool(trinket.proc.crit.react) or bool(trinket.stacking_proc.crit.react) or bool(trinket.proc.versatility.react) or bool(trinket.stacking_proc.versatility.react) or bool(trinket.proc.spell_power.react) or bool(trinket.stacking_proc.spell_power.react))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- agony,if=remains<=tick_time+gcd
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= S.Agony:TickTime() + Player:GCD()) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- agony,cycle_targets=1,max_cycle_targets=5,target_if=sim.target!=target&talent.soul_harvest.enabled&cooldown.soul_harvest.remains<cast_time*6&remains<=duration*0.3&target.time_to_die>=remains&time_to_die>tick_time*3
    if S.Agony:IsCastableP() and (true) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- agony,cycle_targets=1,max_cycle_targets=3,target_if=sim.target!=target&remains<=tick_time+gcd&time_to_die>tick_time*3
    if S.Agony:IsCastableP() and (true) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3&soul_shard=5
    if S.SeedofCorruption:IsCastableP() and (S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3 and soul_shard == 5) then
      if AR.Cast(S.SeedofCorruption) then return ""; end
    end
    -- unstable_affliction,if=soul_shard=5|(time_to_die<=((duration+cast_time)*soul_shard))
    if S.UnstableAffliction:IsCastableP() and (soul_shard == 5 or (Target:TimeToDie() <= ((S.UnstableAffliction:BaseDuration() + S.UnstableAffliction:CastTime()) * soul_shard))) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- drain_soul,cycle_targets=1,if=target.time_to_die<=gcd*2&soul_shard<5
    if S.DrainSoul:IsCastableP() and (Target:TimeToDie() <= Player:GCD() * 2 and soul_shard < 5) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) <= Player:GCD()) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- service_pet,if=dot.corruption.remains&dot.agony.remains
    if S.ServicePet:IsCastableP() and (bool(Target:DebuffRemainsP(S.CorruptionDebuff)) and bool(Target:DebuffRemainsP(S.AgonyDebuff))) then
      if AR.Cast(S.ServicePet) then return ""; end
    end
    -- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
    if S.SummonDoomguard:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] <= 2 and (Target:TimeToDie() > 180 or Target:HealthPercentage() <= 20 or Target:TimeToDie() < 30)) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
    if S.SummonInfernal:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 2) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonDoomguard:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] == 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonDoomguard) then return ""; end
    end
    -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
    if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[30] > 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
      if AR.Cast(S.SummonInfernal) then return ""; end
    end
    -- berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:PrevGCDP(1, S.UnstableAffliction) or Player:BuffRemainsP(S.SoulHarvestBuff) >= 10) then
      if AR.Cast(S.Berserking, Settings.Affliction.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Affliction.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- soul_harvest,if=sim.target=target&buff.soul_harvest.remains<=8&(raid_event.adds.in>20|active_enemies>1|!raid_event.adds.exists)&(buff.active_uas.stack>=2|active_enemies>3)&(!talent.deaths_embrace.enabled|time_to_die>120|time_to_die<30)
    if S.SoulHarvest:IsCastableP() and (sim.target == target and Player:BuffRemainsP(S.SoulHarvestBuff) <= 8 and (10000000000 > 20 or Cache.EnemiesCount[40] > 1 or not false) and (Player:BuffStackP(S.ActiveUasBuff) >= 2 or Cache.EnemiesCount[40] > 3) and (not S.DeathsEmbrace:IsAvailable() or Target:TimeToDie() > 120 or Target:TimeToDie() < 30)) then
      if AR.Cast(S.SoulHarvest) then return ""; end
    end
    -- potion,if=target.time_to_die<=70
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Target:TimeToDie() <= 70) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- potion,if=(!talent.soul_harvest.enabled|buff.soul_harvest.remains>12)&(trinket.proc.any.react|trinket.stack_proc.any.react|buff.active_uas.stack>=2)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((not S.SoulHarvest:IsAvailable() or Player:BuffRemainsP(S.SoulHarvestBuff) > 12) and (bool(trinket.proc.any.react) or bool(trinket.stack_proc.any.react) or Player:BuffStackP(S.ActiveUasBuff) >= 2)) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- siphon_life,cycle_targets=1,if=remains<=tick_time+gcd&time_to_die>tick_time*2
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:TickTime() + Player:GCD() and Target:TimeToDie() > S.SiphonLife:TickTime() * 2) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,cycle_targets=1,if=remains<=tick_time+gcd&((spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled)|spell_targets.seed_of_corruption<5)&time_to_die>tick_time*2
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:TickTime() + Player:GCD() and ((Cache.EnemiesCount[40] < 3 and S.SowtheSeeds:IsAvailable()) or Cache.EnemiesCount[40] < 5) and Target:TimeToDie() > S.Corruption:TickTime() * 2) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,if=mana.pct<40&(buff.active_uas.stack<1|!buff.deadwind_harvester.remains)
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() < 40 and (Player:BuffStackP(S.ActiveUasBuff) < 1 or not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)))) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- reap_souls,if=(buff.deadwind_harvester.remains+buff.tormented_souls.react*(5+equipped.144364))>=(12*(5+1.5*equipped.144364))
    if S.ReapSouls:IsCastableP() and ((Player:BuffRemainsP(S.DeadwindHarvesterBuff) + Player:BuffStackP(S.TormentedSoulsBuff) * (5 + num(I.Item144364:IsEquipped()))) >= (12 * (5 + 1.5 * num(I.Item144364:IsEquipped())))) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- phantom_singularity
    if S.PhantomSingularity:IsCastableP() and (true) then
      if AR.Cast(S.PhantomSingularity) then return ""; end
    end
    -- seed_of_corruption,if=(talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|(spell_targets.seed_of_corruption>3&dot.corruption.refreshable)
    if S.SeedofCorruption:IsCastableP() and ((S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[40] >= 3) or (Cache.EnemiesCount[40] > 3 and bool(dot.corruption.refreshable))) then
      if AR.Cast(S.SeedofCorruption) then return ""; end
    end
    -- unstable_affliction,if=talent.contagion.enabled&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if S.UnstableAffliction:IsCastableP() and (S.Contagion:IsAvailable() and Target:DebuffRemainsP(S.UnstableAffliction1Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction2Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction3Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction4Debuff) < S.UnstableAffliction:CastTime() and Target:DebuffRemainsP(S.UnstableAffliction5Debuff) < S.UnstableAffliction:CastTime()) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,cycle_targets=1,target_if=buff.deadwind_harvester.remains>=duration+cast_time&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if S.UnstableAffliction:IsCastableP() and (true) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- unstable_affliction,if=buff.deadwind_harvester.remains>tick_time*2&(!talent.contagion.enabled|soul_shard>1|buff.soul_harvest.remains)&(dot.unstable_affliction_1.ticking+dot.unstable_affliction_2.ticking+dot.unstable_affliction_3.ticking+dot.unstable_affliction_4.ticking+dot.unstable_affliction_5.ticking<5)
    if S.UnstableAffliction:IsCastableP() and (Player:BuffRemainsP(S.DeadwindHarvesterBuff) > S.UnstableAffliction:TickTime() * 2 and (not S.Contagion:IsAvailable() or soul_shard > 1 or bool(Player:BuffRemainsP(S.SoulHarvestBuff))) and (num(Target:DebuffP(S.UnstableAffliction1Debuff)) + num(Target:DebuffP(S.UnstableAffliction2Debuff)) + num(Target:DebuffP(S.UnstableAffliction3Debuff)) + num(Target:DebuffP(S.UnstableAffliction4Debuff)) + num(Target:DebuffP(S.UnstableAffliction5Debuff)) < 5)) then
      if AR.Cast(S.UnstableAffliction) then return ""; end
    end
    -- reap_souls,if=!buff.deadwind_harvester.remains&buff.active_uas.stack>1
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and Player:BuffStackP(S.ActiveUasBuff) > 1) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- reap_souls,if=!buff.deadwind_harvester.remains&prev_gcd.1.unstable_affliction&buff.tormented_souls.react>1
    if S.ReapSouls:IsCastableP() and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) and Player:PrevGCDP(1, S.UnstableAffliction) and Player:BuffStackP(S.TormentedSoulsBuff) > 1) then
      if AR.Cast(S.ReapSouls) then return ""; end
    end
    -- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3&(!buff.deadwind_harvester.remains|buff.active_uas.stack<1)
    if S.LifeTap:IsCastableP() and (S.EmpoweredLifeTap:IsAvailable() and Player:BuffRemainsP(S.EmpoweredLifeTapBuff) < S.LifeTap:BaseDuration() * 0.3 and (not bool(Player:BuffRemainsP(S.DeadwindHarvesterBuff)) or Player:BuffStackP(S.ActiveUasBuff) < 1)) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- agony,if=refreshable&time_to_die>=remains
    if S.Agony:IsCastableP() and (bool(refreshable) and Target:TimeToDie() >= Target:DebuffRemainsP(S.Agony)) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,if=refreshable&time_to_die>=remains
    if S.SiphonLife:IsCastableP() and (bool(refreshable) and Target:TimeToDie() >= Target:DebuffRemainsP(S.SiphonLife)) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,if=refreshable&time_to_die>=remains
    if S.Corruption:IsCastableP() and (bool(refreshable) and Target:TimeToDie() >= Target:DebuffRemainsP(S.Corruption)) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- agony,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
    if S.Agony:IsCastableP() and (true) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
    if S.SiphonLife:IsCastableP() and (true) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
    if S.Corruption:IsCastableP() and (true) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,if=mana.pct<=10
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() <= 10) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
    if S.LifeTap:IsCastableP() and (Player:PrevGCDP(1, S.LifeTap) and Player:BuffStackP(S.ActiveUasBuff) == 0 and Player:ManaPercentage() < 50) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- drain_soul,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() and (true) then
      if AR.Cast(S.DrainSoul) then return ""; end
    end
    -- life_tap,moving=1,if=mana.pct<80
    if S.LifeTap:IsCastableP() and (Player:ManaPercentage() < 80) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
    -- agony,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.Agony) <= S.Agony:BaseDuration() - (3 * S.Agony:TickTime())) then
      if AR.Cast(S.Agony) then return ""; end
    end
    -- siphon_life,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) <= S.SiphonLife:BaseDuration() - (3 * S.SiphonLife:TickTime())) then
      if AR.Cast(S.SiphonLife) then return ""; end
    end
    -- corruption,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
    if S.Corruption:IsCastableP() and (Target:DebuffRemainsP(S.Corruption) <= S.Corruption:BaseDuration() - (3 * S.Corruption:TickTime())) then
      if AR.Cast(S.Corruption) then return ""; end
    end
    -- life_tap,moving=0
    if S.LifeTap:IsCastableP() and (true) then
      if AR.Cast(S.LifeTap) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=mg,if=talent.malefic_grasp.enabled
  if (S.MaleficGrasp:IsAvailable()) then
    local ShouldReturn = Mg(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=writhe,if=talent.writhe_in_agony.enabled
  if (S.WritheInAgony:IsAvailable()) then
    local ShouldReturn = Writhe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=haunt,if=talent.haunt.enabled
  if (S.Haunt:IsAvailable()) then
    local ShouldReturn = Haunt(); if ShouldReturn then return ShouldReturn; end
  end
end