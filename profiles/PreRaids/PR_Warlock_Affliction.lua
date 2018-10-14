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
Spell.Warlock.Affliction = {
  SummonPet                             = Spell(691),
  GrimoireofSacrificeBuff               = Spell(196099),
  GrimoireofSacrifice                   = Spell(108503),
  SeedofCorruptionDebuff                = Spell(27243),
  SeedofCorruption                      = Spell(27243),
  HauntDebuff                           = Spell(48181),
  Haunt                                 = Spell(48181),
  ShadowBolt                            = Spell(232670),
  Agony                                 = Spell(980),
  Deathbolt                             = Spell(264106),
  SummonDarkglare                       = Spell(205180),
  WritheInAgony                         = Spell(196102),
  SuddenOnset                           = Spell(278721),
  AgonyDebuff                           = Spell(980),
  NightfallBuff                         = Spell(264571),
  SiphonLife                            = Spell(63106),
  Corruption                            = Spell(172),
  AbsoluteCorruption                    = Spell(196103),
  DrainLife                             = Spell(234153),
  InevitableDemiseBuff                  = Spell(273525),
  PhantomSingularity                    = Spell(205179),
  DarkSoul                              = Spell(113860),
  DarkSoulMisery                        = Spell(113860),
  VileTaint                             = Spell(278350),
  DrainSoul                             = Spell(198590),
  ShadowEmbraceDebuff                   = Spell(32390),
  ShadowEmbrace                         = Spell(32388),
  DrainSoulDebuff                       = Spell(198590),
  SowtheSeeds                           = Spell(196226),
  CascadingCalamity                     = Spell(275372),
  Fireblood                             = Spell(265221),
  BloodFury                             = Spell(20572),
  CorruptionDebuff                      = Spell(146739),
  ActiveUasBuff                         = Spell(233490),
  CreepingDeath                         = Spell(264000),
  SiphonLifeDebuff                      = Spell(63106),
  UnstableAffliction                    = Spell(30108),
  UnstableAfflictionDebuff              = Spell(30108),
  Berserking                            = Spell(26297),
  CascadingCalamityBuff                 = Spell(275378)
};
local S = Spell.Warlock.Affliction;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Affliction = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Warlock.Affliction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warlock.Commons,
  Affliction = HR.GUISettings.APL.Warlock.Affliction
};

-- Variables
local VarSpammableSeed = 0;
local VarPadding = 0;

HL:RegisterForEvent(function()
  VarSpammableSeed = 0
  VarPadding = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40, 5}
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

local function TimeToShard()
  local ActiveAgony = S.Agony:ActiveDot()
  if ActiveAgony == 0 then
    return 10000 
  end
  return 1 / (0.16 / math.sqrt(ActiveAgony) * (ActiveAgony == 1 and 1.15 or 1) * ActiveAgony / S.Agony:TickTime())
end

local UnstableAfflictionDebuffs = {
  Spell(233490),
  Spell(233496),
  Spell(233497),
  Spell(233498),
  Spell(233499)
};

local function ActiveUAs ()
  local UACount = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    if Target:DebuffRemainsP(UADebuff) > 0 then UACount = UACount + 1 end
  end
  return UACount
end

local function Contagion()
  local MaximumDuration = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    local UARemains = Target:DebuffRemainsP(UADebuff)
    if UARemains > MaximumDuration then
      MaximumDuration = UARemains
    end
  end
  return MaximumDuration
end

S.ShadowBolt:RegisterInFlight()
S.SeedofCorruption:RegisterInFlight()

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Fillers
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  time_to_shard = TimeToShard()
  contagion = Contagion()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet, Settings.Affliction.GCDasOffGCD.SummonPet) then return "summon_pet 3"; end
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and Player:BuffDownP(S.GrimoireofSacrificeBuff) and (S.GrimoireofSacrifice:IsAvailable()) then
      if HR.Cast(S.GrimoireofSacrifice, Settings.Affliction.GCDasOffGCD.GrimoireofSacrifice) then return "grimoire_of_sacrifice 5"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 14"; end
    end
    -- seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3
    if S.SeedofCorruption:IsCastableP() and Player:DebuffDownP(S.SeedofCorruptionDebuff) and (Cache.EnemiesCount[5] >= 3) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 16"; end
    end
    -- haunt
    if S.Haunt:IsCastableP() and Player:DebuffDownP(S.HauntDebuff) then
      if HR.Cast(S.Haunt) then return "haunt 20"; end
    end
    -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
    if S.ShadowBolt:IsCastableP() and (not S.Haunt:IsAvailable() and Cache.EnemiesCount[5] < 3) then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 24"; end
    end
  end
  Fillers = function()
    -- agony,if=talent.deathbolt.enabled&cooldown.summon_darkglare.remains>=30+gcd&cooldown.deathbolt.remains<=gcd&!prev_gcd.1.summon_darkglare&!prev_gcd.1.agony&talent.writhe_in_agony.enabled&azerite.sudden_onset.enabled&remains<duration*0.5
    if S.Agony:IsCastableP() and (S.Deathbolt:IsAvailable() and S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() and S.Deathbolt:CooldownRemainsP() <= Player:GCD() and not Player:PrevGCDP(1, S.SummonDarkglare) and not Player:PrevGCDP(1, S.Agony) and S.WritheInAgony:IsAvailable() and S.SuddenOnset:AzeriteEnabled() and Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 0.5) then
      if HR.Cast(S.Agony) then return "agony 30"; end
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
    if S.Deathbolt:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 140) then
      if HR.Cast(S.Deathbolt) then return "deathbolt 58"; end
    end
    -- shadow_bolt,if=buff.movement.up&buff.nightfall.remains
    if S.ShadowBolt:IsCastableP() and (Player:IsMoving() and bool(Player:BuffRemainsP(S.NightfallBuff))) then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 64"; end
    end
    -- agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
    if S.Agony:IsCastableP() and (Player:IsMoving() and not (S.SiphonLife:IsAvailable() and (Player:PrevGCDP(1, S.Agony) and Player:PrevGCDP(2, S.Agony) and Player:PrevGCDP(3, S.Agony)) or Player:PrevGCDP(1, S.Agony))) then
      if HR.Cast(S.Agony) then return "agony 68"; end
    end
    -- siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
    if S.SiphonLife:IsCastableP() and (Player:IsMoving() and not (Player:PrevGCDP(1, S.SiphonLife) and Player:PrevGCDP(2, S.SiphonLife) and Player:PrevGCDP(3, S.SiphonLife))) then
      if HR.Cast(S.SiphonLife) then return "siphon_life 80"; end
    end
    -- corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
    if S.Corruption:IsCastableP() and (Player:IsMoving() and not Player:PrevGCDP(1, S.Corruption) and not S.AbsoluteCorruption:IsAvailable()) then
      if HR.Cast(S.Corruption) then return "corruption 88"; end
    end
    -- drain_life,if=(buff.inevitable_demise.stack>=90&(cooldown.deathbolt.remains>execute_time|!talent.deathbolt.enabled)&(cooldown.phantom_singularity.remains>execute_time|!talent.phantom_singularity.enabled)&(cooldown.dark_soul.remains>execute_time|!talent.dark_soul_misery.enabled)&(cooldown.vile_taint.remains>execute_time|!talent.vile_taint.enabled)&cooldown.summon_darkglare.remains>execute_time+10|buff.inevitable_demise.stack>30&target.time_to_die<=10)
    if S.DrainLife:IsCastableP() and HR.CDsON() and ((Player:BuffStackP(S.InevitableDemiseBuff) >= 90 and (S.Deathbolt:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.Deathbolt:IsAvailable()) and (S.PhantomSingularity:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.PhantomSingularity:IsAvailable()) and (S.DarkSoul:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.DarkSoulMisery:IsAvailable()) and (S.VileTaint:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.VileTaint:IsAvailable()) and S.SummonDarkglare:CooldownRemainsP() > S.DrainLife:ExecuteTime() + 10 or Player:BuffStackP(S.InevitableDemiseBuff) > 30 and Target:TimeToDie() <= 10)) then
      if HR.Cast(S.DrainLife) then return "drain_life 94"; end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1,cycle_targets=1,if=target.time_to_die<=gcd
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, function(TargetUnit) return TargetUnit:TimeToDie() <= Player:GCD() end) then return "drain_soul 142" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&active_enemies=2&!debuff.shadow_embrace.remains
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) end, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] == 2 and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) end) then return "drain_soul 163" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&active_enemies=2
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) end, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] == 2 end) then return "drain_soul 182" end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() then
      if HR.Cast(S.DrainSoul) then return "drain_soul 183"; end
    end
    -- shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastCycle(S.ShadowBolt, 40, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] == 2 and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and not S.ShadowBolt:InFlight() end) then return "shadow_bolt 205" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) end, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] == 2 end) then return "shadow_bolt 224" end
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 225"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- variable,name=spammable_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=8
    if (true) then
      VarSpammableSeed = num(S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[5] >= 3 or S.SiphonLife:IsAvailable() and Cache.EnemiesCount[40] >= 5 or Cache.EnemiesCount[40] >= 8)
    end
    -- variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
    if (true) then
      VarPadding = S.ShadowBolt:ExecuteTime() * num(S.CascadingCalamity:AzeriteEnabled())
    end
    -- variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
    if (S.CascadingCalamity:AzeriteEnabled() and (S.DrainSoul:IsAvailable() or S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= Player:GCD())) then
      VarPadding = 0
    end
    -- potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((S.DarkSoulMisery:IsAvailable() and S.SummonDarkglare:CooldownUpP() and S.DarkSoul:CooldownUpP()) or S.SummonDarkglare:CooldownUpP() or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 253"; end
    end
    -- use_items,if=!cooldown.summon_darkglare.up
    -- fireblood,if=!cooldown.summon_darkglare.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 264"; end
    end
    -- blood_fury,if=!cooldown.summon_darkglare.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 268"; end
    end
    -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, function(TargetUnit) return TargetUnit:TimeToDie() <= Player:GCD() and Player:SoulShardsP() < 5 end) then return "drain_soul 276" end
    end
    -- haunt
    if S.Haunt:IsCastableP() then
      if HR.Cast(S.Haunt) then return "haunt 277"; end
    end
    -- summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)
    if S.SummonDarkglare:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and (ActiveUAs() == 5 or Player:SoulShardsP() == 0) and (not S.PhantomSingularity:IsAvailable() or bool(S.PhantomSingularity:CooldownRemainsP()))) then
      if HR.Cast(S.SummonDarkglare, Settings.Affliction.GCDasOffGCD.SummonDarkglare) then return "summon_darkglare 279"; end
    end
    -- agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.AgonyDebuff) end, function(TargetUnit) return TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() + S.ShadowBolt:ExecuteTime() end) then return "agony 309" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,interrupt_immediate=1,interrupt_if=ticks_remain<5,if=talent.shadow_embrace.enabled&active_enemies<=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=gcd*2
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) end, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] <= 2 and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= Player:GCD() * 2 end) then return "drain_soul 332" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies<=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) end, function(TargetUnit) return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] <= 2 and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= S.ShadowBolt:ExecuteTime() * 2 + S.ShadowBolt:TravelTime() and not S.ShadowBolt:InFlight() end) then return "shadow_bolt 367" end
    end
    -- phantom_singularity,if=time>40&(cooldown.summon_darkglare.remains>=45|cooldown.summon_darkglare.remains<8)
    if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() > 40 and (S.SummonDarkglare:CooldownRemainsP() >= 45 or S.SummonDarkglare:CooldownRemainsP() < 8)) then
      if HR.Cast(S.PhantomSingularity, Settings.Affliction.GCDasOffGCD.PhantomSingularity) then return "phantom_singularity 368"; end
    end
    -- vile_taint,if=time>20
    if S.VileTaint:IsCastableP() and (HL.CombatTime() > 20) then
      if HR.Cast(S.VileTaint) then return "vile_taint 374"; end
    end
    -- seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
    if S.SeedofCorruption:IsCastableP() and (Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + time_to_shard + 4.2 * (1 - num(S.CreepingDeath:IsAvailable()) * 0.15) and Cache.EnemiesCount[5] >= 3 + num(S.WritheInAgony:IsAvailable()) and not bool(Target:DebuffRemainsP(S.SeedofCorruptionDebuff)) and not S.SeedofCorruption:InFlight()) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 376"; end
    end
    -- agony,cycle_targets=1,max_cycle_targets=6,if=talent.creeping_death.enabled&target.time_to_die>10&refreshable
    if S.Agony:IsCastableP() then
      if HR.CastCycle(S.Agony, 40, function(TargetUnit) return S.CreepingDeath:IsAvailable() and TargetUnit:TimeToDie() > 10 and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff) end) then return "agony 410" end
    end
    -- agony,cycle_targets=1,max_cycle_targets=8,if=(!talent.creeping_death.enabled)&target.time_to_die>10&refreshable
    if S.Agony:IsCastableP() then
      if HR.CastCycle(S.Agony, 40, function(TargetUnit) return (not S.CreepingDeath:IsAvailable()) and TargetUnit:TimeToDie() > 10 and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff) end) then return "agony 423" end
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=1,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies>=8)|active_enemies=1)
    if S.SiphonLife:IsCastableP() then
      if HR.CastCycle(S.SiphonLife, 40, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and TargetUnit:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[40] >= 8) or Cache.EnemiesCount[40] == 1) end) then return "siphon_life 458" end
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=2,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=7)|active_enemies=2)
    if S.SiphonLife:IsCastableP() then
      if HR.CastCycle(S.SiphonLife, 40, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and TargetUnit:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[40] == 7) or Cache.EnemiesCount[40] == 2) end) then return "siphon_life 493" end
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=3,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=6)|active_enemies=3)
    if S.SiphonLife:IsCastableP() then
      if HR.CastCycle(S.SiphonLife, 40, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and TargetUnit:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[40] == 6) or Cache.EnemiesCount[40] == 3) end) then return "siphon_life 528" end
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=4,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=5)|active_enemies=4)
    if S.SiphonLife:IsCastableP() then
      if HR.CastCycle(S.SiphonLife, 40, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and TargetUnit:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[40] == 5) or Cache.EnemiesCount[40] == 4) end) then return "siphon_life 563" end
    end
    -- corruption,cycle_targets=1,if=active_enemies<3+talent.writhe_in_agony.enabled&refreshable&target.time_to_die>10
    if S.Corruption:IsCastableP() then
      if HR.CastCycle(S.Corruption, 40, function(TargetUnit) return Cache.EnemiesCount[40] < 3 + num(S.WritheInAgony:IsAvailable()) and TargetUnit:DebuffRefreshableCP(S.CorruptionDebuff) and TargetUnit:TimeToDie() > 10 end) then return "corruption 584" end
    end
    -- phantom_singularity,if=time<=40
    if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 40) then
      if HR.Cast(S.PhantomSingularity, Settings.Affliction.GCDasOffGCD.PhantomSingularity) then return "phantom_singularity 585"; end
    end
    -- vile_taint
    if S.VileTaint:IsCastableP() then
      if HR.Cast(S.VileTaint) then return "vile_taint 587"; end
    end
    -- dark_soul
    if S.DarkSoul:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.DarkSoul, Settings.Affliction.GCDasOffGCD.DarkSoul) then return "dark_soul 589"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 591"; end
    end
    -- unstable_affliction,if=soul_shard>=5
    if S.UnstableAffliction:IsReadyP() and (Player:SoulShardsP() >= 5) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 593"; end
    end
    -- unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*execute_time
    if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 595"; end
    end
    -- call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
    if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
    -- seed_of_corruption,if=variable.spammable_seed
    if S.SeedofCorruption:IsCastableP() and (bool(VarSpammableSeed)) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 617"; end
    end
    -- unstable_affliction,if=!prev_gcd.1.summon_darkglare&!variable.spammable_seed&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|soul_shard>=2&target.time_to_die>4+execute_time&active_enemies=1|target.time_to_die<=8+execute_time*soul_shard)
    if S.UnstableAffliction:IsReadyP() and (not Player:PrevGCDP(1, S.SummonDarkglare) and not bool(VarSpammableSeed) and (S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= S.UnstableAffliction:ExecuteTime() and not S.CascadingCalamity:AzeriteEnabled() or Player:SoulShardsP() >= 2 and Target:TimeToDie() > 4 + S.UnstableAffliction:ExecuteTime() and Cache.EnemiesCount[40] == 1 or Target:TimeToDie() <= 8 + S.UnstableAffliction:ExecuteTime() * Player:SoulShardsP())) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 621"; end
    end
    -- unstable_affliction,if=!variable.spammable_seed&contagion<=cast_time+variable.padding
    if S.UnstableAffliction:IsReadyP() and (not bool(VarSpammableSeed) and contagion <= S.UnstableAffliction:CastTime() + VarPadding) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 659"; end
    end
    -- unstable_affliction,cycle_targets=1,if=!variable.spammable_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&contagion<=cast_time+variable.padding&(!azerite.cascading_calamity.enabled|buff.cascading_calamity.remains>time_to_shard)
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastCycle(S.UnstableAffliction, 40, function(TargetUnit) return not bool(VarSpammableSeed) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() > time_to_shard or Player:SoulShardsP() > 1) and contagion <= S.UnstableAffliction:CastTime() + VarPadding and (not S.CascadingCalamity:AzeriteEnabled() or Player:BuffRemainsP(S.CascadingCalamityBuff) > time_to_shard) end) then return "unstable_affliction 693" end
    end
    -- call_action_list,name=fillers
    if (true) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(265, APL)
