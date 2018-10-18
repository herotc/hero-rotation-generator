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
  DarkSoulMisery                        = Spell(113860),
  SummonDarkglare                       = Spell(205180),
  DarkSoul                              = Spell(113860),
  Fireblood                             = Spell(265221),
  BloodFury                             = Spell(20572),
  CorruptionDebuff                      = Spell(146739),
  CreepingDeath                         = Spell(264000),
  WritheInAgony                         = Spell(196102),
  Agony                                 = Spell(980),
  AgonyDebuff                           = Spell(980),
  SiphonLife                            = Spell(63106),
  SiphonLifeDebuff                      = Spell(63106),
  UnstableAffliction                    = Spell(30108),
  UnstableAfflictionDebuff              = Spell(30108),
  Corruption                            = Spell(172),
  Deathbolt                             = Spell(264106),
  SuddenOnset                           = Spell(278721),
  NightfallBuff                         = Spell(264571),
  AbsoluteCorruption                    = Spell(196103),
  DrainLife                             = Spell(234153),
  InevitableDemiseBuff                  = Spell(273525),
  PhantomSingularity                    = Spell(205179),
  VileTaint                             = Spell(278350),
  DrainSoul                             = Spell(198590),
  ShadowEmbraceDebuff                   = Spell(32390),
  ShadowEmbrace                         = Spell(32388),
  DrainSoulDebuff                       = Spell(198590),
  CascadingCalamity                     = Spell(275372),
  CascadingCalamityBuff                 = Spell(275378),
  SowtheSeeds                           = Spell(196226),
  ActiveUasBuff                         = Spell(233490),
  Berserking                            = Spell(26297)
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
local VarUseSeed = 0;
local VarPadding = 0;

HL:RegisterForEvent(function()
  VarUseSeed = 0
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


local function EvaluateTargetIfFilterAgony74(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony107(TargetUnit)
  return S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 6 and TargetUnit:TimeToDie() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff))
end

local function EvaluateTargetIfFilterAgony113(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony146(TargetUnit)
  return not S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 8 and TargetUnit:TimeToDie() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff))
end

local function EvaluateTargetIfFilterSiphonLife152(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SiphonLifeDebuff)
end

local function EvaluateTargetIfSiphonLife185(TargetUnit)
  return (S.SiphonLifeDebuff:ActiveDot() < 8 - num(S.CreepingDeath:IsAvailable()) - Cache.EnemiesCount[5]) and TargetUnit:TimeToDie() > 10 and TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime())
end

local function EvaluateCycleCorruption192(TargetUnit)
  return Cache.EnemiesCount[40] < 3 + num(S.WritheInAgony:IsAvailable()) and (TargetUnit:DebuffRemainsP(S.CorruptionDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and TargetUnit:DebuffRefreshableCP(S.CorruptionDebuff)) and TargetUnit:TimeToDie() > 10
end

local function EvaluateCycleDrainSoul333(TargetUnit)
  return TargetUnit:TimeToDie() <= Player:GCD()
end

local function EvaluateTargetIfFilterDrainSoul339(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul358(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] == 2 and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff))
end

local function EvaluateTargetIfFilterDrainSoul364(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul381(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] == 2
end

local function EvaluateCycleShadowBolt390(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] == 2 and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and not S.ShadowBolt:InFlight()
end

local function EvaluateTargetIfFilterShadowBolt412(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfShadowBolt429(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] == 2
end

local function EvaluateCycleUnstableAffliction514(TargetUnit)
  return not bool(VarUseSeed) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() > time_to_shard or Player:SoulShardsP() > 1) and contagion <= S.UnstableAffliction:CastTime() + VarPadding and (not S.CascadingCalamity:AzeriteEnabled() or Player:BuffRemainsP(S.CascadingCalamityBuff) > time_to_shard)
end

local function EvaluateCycleDrainSoul567(TargetUnit)
  return TargetUnit:TimeToDie() <= Player:GCD() and Player:SoulShardsP() < 5
end

local function EvaluateTargetIfFilterAgony587(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony604(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() + S.ShadowBolt:ExecuteTime() and TargetUnit:TimeToDie() > 8
end

local function EvaluateCycleUnstableAffliction611(TargetUnit)
  return not bool(contagion) and TargetUnit:TimeToDie() <= 8
end

local function EvaluateTargetIfFilterDrainSoul617(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul638(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and Cache.EnemiesCount[40] <= 2 and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= Player:GCD() * 2
end

local function EvaluateTargetIfFilterShadowBolt644(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfShadowBolt677(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[40] <= 2 and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= S.ShadowBolt:ExecuteTime() * 2 + S.ShadowBolt:TravelTime() and not S.ShadowBolt:InFlight()
end

local function EvaluateTargetIfFilterPhantomSingularity683(TargetUnit)
  return TargetUnit:TimeToDie()
end

local function EvaluateTargetIfPhantomSingularity690(TargetUnit)
  return HL.CombatTime() > 35 and (S.SummonDarkglare:CooldownRemainsP() >= 45 or S.SummonDarkglare:CooldownRemainsP() < 8) and TargetUnit:TimeToDie() > 16 * Player:SpellHaste()
end

local function EvaluateTargetIfFilterVileTaint696(TargetUnit)
  return TargetUnit:TimeToDie()
end

local function EvaluateTargetIfVileTaint699(TargetUnit)
  return HL.CombatTime() > 15 and TargetUnit:TimeToDie() >= 10
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cooldowns, Dots, Fillers, Spenders
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
  Cooldowns = function()
    -- potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((S.DarkSoulMisery:IsAvailable() and S.SummonDarkglare:CooldownUpP() and S.DarkSoul:CooldownUpP()) or S.SummonDarkglare:CooldownUpP() or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 30"; end
    end
    -- use_items,if=!cooldown.summon_darkglare.up
    -- fireblood,if=!cooldown.summon_darkglare.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 41"; end
    end
    -- blood_fury,if=!cooldown.summon_darkglare.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 45"; end
    end
  end
  Dots = function()
    -- seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
    if S.SeedofCorruption:IsCastableP() and (Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + time_to_shard + 4.2 * (1 - num(S.CreepingDeath:IsAvailable()) * 0.15) and Cache.EnemiesCount[5] >= 3 + num(S.WritheInAgony:IsAvailable()) and not bool(Target:DebuffRemainsP(S.SeedofCorruptionDebuff)) and not S.SeedofCorruption:InFlight()) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 49"; end
    end
    -- agony,target_if=min:remains,if=talent.creeping_death.enabled&active_dot.agony<6&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony74, EvaluateTargetIfAgony107) then return "agony 109" end
    end
    -- agony,target_if=min:remains,if=!talent.creeping_death.enabled&active_dot.agony<8&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony113, EvaluateTargetIfAgony146) then return "agony 148" end
    end
    -- siphon_life,target_if=min:remains,if=(active_dot.siphon_life<8-talent.creeping_death.enabled-spell_targets.sow_the_seeds_aoe)&target.time_to_die>10&refreshable&!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)
    if S.SiphonLife:IsCastableP() then
      if HR.CastTargetIf(S.SiphonLife, 40, "min", EvaluateTargetIfFilterSiphonLife152, EvaluateTargetIfSiphonLife185) then return "siphon_life 187" end
    end
    -- corruption,cycle_targets=1,if=active_enemies<3+talent.writhe_in_agony.enabled&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)&target.time_to_die>10
    if S.Corruption:IsCastableP() then
      if HR.CastCycle(S.Corruption, 40, EvaluateCycleCorruption192) then return "corruption 218" end
    end
  end
  Fillers = function()
    -- agony,if=talent.deathbolt.enabled&cooldown.summon_darkglare.remains>=30+gcd&cooldown.deathbolt.remains<=gcd&!prev_gcd.1.summon_darkglare&!prev_gcd.1.agony&talent.writhe_in_agony.enabled&azerite.sudden_onset.enabled&remains<duration*0.5
    if S.Agony:IsCastableP() and (S.Deathbolt:IsAvailable() and S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() and S.Deathbolt:CooldownRemainsP() <= Player:GCD() and not Player:PrevGCDP(1, S.SummonDarkglare) and not Player:PrevGCDP(1, S.Agony) and S.WritheInAgony:IsAvailable() and S.SuddenOnset:AzeriteEnabled() and Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 0.5) then
      if HR.Cast(S.Agony) then return "agony 219"; end
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
    if S.Deathbolt:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 140) then
      if HR.Cast(S.Deathbolt) then return "deathbolt 247"; end
    end
    -- shadow_bolt,if=buff.movement.up&buff.nightfall.remains
    if S.ShadowBolt:IsCastableP() and (Player:IsMoving() and bool(Player:BuffRemainsP(S.NightfallBuff))) then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 253"; end
    end
    -- agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
    if S.Agony:IsCastableP() and (Player:IsMoving() and not (S.SiphonLife:IsAvailable() and (Player:PrevGCDP(1, S.Agony) and Player:PrevGCDP(2, S.Agony) and Player:PrevGCDP(3, S.Agony)) or Player:PrevGCDP(1, S.Agony))) then
      if HR.Cast(S.Agony) then return "agony 257"; end
    end
    -- siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
    if S.SiphonLife:IsCastableP() and (Player:IsMoving() and not (Player:PrevGCDP(1, S.SiphonLife) and Player:PrevGCDP(2, S.SiphonLife) and Player:PrevGCDP(3, S.SiphonLife))) then
      if HR.Cast(S.SiphonLife) then return "siphon_life 269"; end
    end
    -- corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
    if S.Corruption:IsCastableP() and (Player:IsMoving() and not Player:PrevGCDP(1, S.Corruption) and not S.AbsoluteCorruption:IsAvailable()) then
      if HR.Cast(S.Corruption) then return "corruption 277"; end
    end
    -- drain_life,if=(buff.inevitable_demise.stack>=90&(cooldown.deathbolt.remains>execute_time|!talent.deathbolt.enabled)&(cooldown.phantom_singularity.remains>execute_time|!talent.phantom_singularity.enabled)&(cooldown.dark_soul.remains>execute_time|!talent.dark_soul_misery.enabled)&(cooldown.vile_taint.remains>execute_time|!talent.vile_taint.enabled)&cooldown.summon_darkglare.remains>execute_time+10|buff.inevitable_demise.stack>30&target.time_to_die<=10)
    if S.DrainLife:IsCastableP() and HR.CDsON() and ((Player:BuffStackP(S.InevitableDemiseBuff) >= 90 and (S.Deathbolt:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.Deathbolt:IsAvailable()) and (S.PhantomSingularity:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.PhantomSingularity:IsAvailable()) and (S.DarkSoul:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.DarkSoulMisery:IsAvailable()) and (S.VileTaint:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.VileTaint:IsAvailable()) and S.SummonDarkglare:CooldownRemainsP() > S.DrainLife:ExecuteTime() + 10 or Player:BuffStackP(S.InevitableDemiseBuff) > 30 and Target:TimeToDie() <= 10)) then
      if HR.Cast(S.DrainLife) then return "drain_life 283"; end
    end
    -- haunt
    if S.Haunt:IsCastableP() then
      if HR.Cast(S.Haunt) then return "haunt 327"; end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1,cycle_targets=1,if=target.time_to_die<=gcd
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, EvaluateCycleDrainSoul333) then return "drain_soul 335" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&active_enemies=2&!debuff.shadow_embrace.remains
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul339, EvaluateTargetIfDrainSoul358) then return "drain_soul 360" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&active_enemies=2
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul364, EvaluateTargetIfDrainSoul381) then return "drain_soul 383" end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() then
      if HR.Cast(S.DrainSoul) then return "drain_soul 384"; end
    end
    -- shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastCycle(S.ShadowBolt, 40, EvaluateCycleShadowBolt390) then return "shadow_bolt 408" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", EvaluateTargetIfFilterShadowBolt412, EvaluateTargetIfShadowBolt429) then return "shadow_bolt 431" end
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 432"; end
    end
  end
  Spenders = function()
    -- unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*execute_time
    if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 434"; end
    end
    -- call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
    if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
    -- seed_of_corruption,if=variable.use_seed
    if S.SeedofCorruption:IsCastableP() and (bool(VarUseSeed)) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 456"; end
    end
    -- unstable_affliction,if=!variable.use_seed&!prev_gcd.1.summon_darkglare&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|soul_shard>=2&target.time_to_die>4+execute_time&active_enemies=1|target.time_to_die<=8+execute_time*soul_shard)
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and not Player:PrevGCDP(1, S.SummonDarkglare) and (S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= S.UnstableAffliction:ExecuteTime() and not S.CascadingCalamity:AzeriteEnabled() or Player:SoulShardsP() >= 2 and Target:TimeToDie() > 4 + S.UnstableAffliction:ExecuteTime() and Cache.EnemiesCount[40] == 1 or Target:TimeToDie() <= 8 + S.UnstableAffliction:ExecuteTime() * Player:SoulShardsP())) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 460"; end
    end
    -- unstable_affliction,if=!variable.use_seed&contagion<=cast_time+variable.padding
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and contagion <= S.UnstableAffliction:CastTime() + VarPadding) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 498"; end
    end
    -- unstable_affliction,cycle_targets=1,if=!variable.use_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&contagion<=cast_time+variable.padding&(!azerite.cascading_calamity.enabled|buff.cascading_calamity.remains>time_to_shard)
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastCycle(S.UnstableAffliction, 40, EvaluateCycleUnstableAffliction514) then return "unstable_affliction 534" end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=8
    if (true) then
      VarUseSeed = num(S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[5] >= 3 or S.SiphonLife:IsAvailable() and Cache.EnemiesCount[40] >= 5 or Cache.EnemiesCount[40] >= 8)
    end
    -- variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
    if (true) then
      VarPadding = S.ShadowBolt:ExecuteTime() * num(S.CascadingCalamity:AzeriteEnabled())
    end
    -- variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
    if (S.CascadingCalamity:AzeriteEnabled() and (S.DrainSoul:IsAvailable() or S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= Player:GCD())) then
      VarPadding = 0
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, EvaluateCycleDrainSoul567) then return "drain_soul 569" end
    end
    -- haunt,if=spell_targets.seed_of_corruption_aoe<=2
    if S.Haunt:IsCastableP() and (Cache.EnemiesCount[5] <= 2) then
      if HR.Cast(S.Haunt) then return "haunt 570"; end
    end
    -- summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)
    if S.SummonDarkglare:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and (ActiveUAs() == 5 or Player:SoulShardsP() == 0) and (not S.PhantomSingularity:IsAvailable() or bool(S.PhantomSingularity:CooldownRemainsP()))) then
      if HR.Cast(S.SummonDarkglare, Settings.Affliction.GCDasOffGCD.SummonDarkglare) then return "summon_darkglare 572"; end
    end
    -- agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time&target.time_to_die>8
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony587, EvaluateTargetIfAgony604) then return "agony 606" end
    end
    -- unstable_affliction,target_if=!contagion&target.time_to_die<=8
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastCycle(S.UnstableAffliction, 40, EvaluateCycleUnstableAffliction611) then return "unstable_affliction 613" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,interrupt_immediate=1,interrupt_if=ticks_remain<5,if=talent.shadow_embrace.enabled&active_enemies<=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=gcd*2
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul617, EvaluateTargetIfDrainSoul638) then return "drain_soul 640" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies<=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", EvaluateTargetIfFilterShadowBolt644, EvaluateTargetIfShadowBolt677) then return "shadow_bolt 679" end
    end
    -- phantom_singularity,target_if=max:target.time_to_die,if=time>35&(cooldown.summon_darkglare.remains>=45|cooldown.summon_darkglare.remains<8)&target.time_to_die>16*spell_haste
    if S.PhantomSingularity:IsCastableP() then
      if HR.CastTargetIf(S.PhantomSingularity, 40, "max", EvaluateTargetIfFilterPhantomSingularity683, EvaluateTargetIfPhantomSingularity690) then return "phantom_singularity 692" end
    end
    -- vile_taint,target_if=max:target.time_to_die,if=time>15&target.time_to_die>=10
    if S.VileTaint:IsCastableP() then
      if HR.CastTargetIf(S.VileTaint, 40, "max", EvaluateTargetIfFilterVileTaint696, EvaluateTargetIfVileTaint699) then return "vile_taint 701" end
    end
    -- unstable_affliction,if=!variable.use_seed&soul_shard=5
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and Player:SoulShardsP() == 5) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 702"; end
    end
    -- seed_of_corruption,if=variable.use_seed&soul_shard=5
    if S.SeedofCorruption:IsCastableP() and (bool(VarUseSeed) and Player:SoulShardsP() == 5) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 706"; end
    end
    -- call_action_list,name=dots
    if (true) then
      local ShouldReturn = Dots(); if ShouldReturn then return ShouldReturn; end
    end
    -- phantom_singularity,if=time<=35
    if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 35) then
      if HR.Cast(S.PhantomSingularity, Settings.Affliction.GCDasOffGCD.PhantomSingularity) then return "phantom_singularity 712"; end
    end
    -- vile_taint,if=time<15
    if S.VileTaint:IsCastableP() and (HL.CombatTime() < 15) then
      if HR.Cast(S.VileTaint) then return "vile_taint 714"; end
    end
    -- dark_soul
    if S.DarkSoul:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.DarkSoul, Settings.Affliction.GCDasOffGCD.DarkSoul) then return "dark_soul 716"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 718"; end
    end
    -- call_action_list,name=spenders
    if (true) then
      local ShouldReturn = Spenders(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=fillers
    if (true) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(265, APL)
