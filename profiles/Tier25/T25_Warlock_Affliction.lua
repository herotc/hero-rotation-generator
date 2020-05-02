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
  WorldveinResonance                    = Spell(),
  PhantomSingularity                    = Spell(205179),
  SummonDarkglare                       = Spell(205180),
  DreadfulCalling                       = Spell(),
  AgonyDebuff                           = Spell(980),
  CorruptionDebuff                      = Spell(146739),
  SiphonLifeDebuff                      = Spell(63106),
  SiphonLife                            = Spell(63106),
  DarkSoulMisery                        = Spell(113860),
  DarkSoul                              = Spell(113860),
  Fireblood                             = Spell(265221),
  BloodFury                             = Spell(20572),
  MemoryofLucidDreams                   = Spell(),
  SowtheSeeds                           = Spell(196226),
  BloodoftheEnemy                       = Spell(),
  Deathbolt                             = Spell(264106),
  RippleInSpace                         = Spell(),
  Agony                                 = Spell(980),
  Corruption                            = Spell(172),
  CreepingDeath                         = Spell(264000),
  WritheInAgony                         = Spell(196102),
  PandemicInvocation                    = Spell(289364),
  UnstableAffliction                    = Spell(30108),
  UnstableAfflictionDebuff              = Spell(30108),
  NightfallBuff                         = Spell(264571),
  AbsoluteCorruption                    = Spell(196103),
  DrainLife                             = Spell(234153),
  InevitableDemiseBuff                  = Spell(273525),
  FocusedAzeriteBeam                    = Spell(),
  PurifyingBlast                        = Spell(),
  ReapingFlames                         = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  DrainSoul                             = Spell(198590),
  ShadowEmbraceDebuff                   = Spell(32390),
  ShadowEmbrace                         = Spell(32388),
  PhantomSingularityDebuff              = Spell(205179),
  VileTaintDebuff                       = Spell(278350),
  CascadingCalamity                     = Spell(275372),
  VileTaint                             = Spell(278350),
  CascadingCalamityBuff                 = Spell(275378),
  ActiveUasBuff                         = Spell(233490),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  GuardianofAzeroth                     = Spell(),
  Berserking                            = Spell(26297)
};
local S = Spell.Warlock.Affliction;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Affliction = {
  BattlePotionofIntellect          = Item(163222),
  AzsharasFontofPower              = Item(),
  Item169314                       = Item(169314),
  PocketsizedComputationDevice     = Item(),
  RotcrustedVoodooDoll             = Item(),
  ShiverVenomRelic                 = Item(),
  AquipotentNautilus               = Item(),
  TidestormCodex                   = Item(165576),
  VialofStorms                     = Item()
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
local VarMaintainSe = 0;
local VarUseSeed = 0;
local VarPadding = 0;

HL:RegisterForEvent(function()
  VarMaintainSe = 0
  VarUseSeed = 0
  VarPadding = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.SeedofCorruption:RegisterInFlight()
S.ConcentratedFlame:RegisterInFlight()
S.ShadowBolt:RegisterInFlight()

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


local function EvaluateTargetIfFilterAgony240(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony281(TargetUnit)
  return S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 6 and TargetUnit:TimeToDie() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) < 5 or not bool(S.PandemicInvocation:AzeriteRank()) and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff)))
end

local function EvaluateTargetIfFilterAgony287(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony328(TargetUnit)
  return not S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 8 and TargetUnit:TimeToDie() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and (TargetUnit:DebuffRemainsP(S.AgonyDebuff) < 5 or not bool(S.PandemicInvocation:AzeriteRank()) and TargetUnit:DebuffRefreshableCP(S.AgonyDebuff)))
end

local function EvaluateTargetIfFilterSiphonLife334(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SiphonLifeDebuff)
end

local function EvaluateTargetIfSiphonLife373(TargetUnit)
  return (S.SiphonLifeDebuff:ActiveDot() < 8 - num(S.CreepingDeath:IsAvailable()) - Cache.EnemiesCount[5]) and TargetUnit:TimeToDie() > 10 and TargetUnit:DebuffRefreshableCP(S.SiphonLifeDebuff) and (not bool(TargetUnit:DebuffRemainsP(S.SiphonLifeDebuff)) and Cache.EnemiesCount[5] == 1 or S.SummonDarkglare:CooldownRemainsP() > Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime())
end

local function EvaluateCycleCorruption380(TargetUnit)
  return Cache.EnemiesCount[5] < 3 + raid_event.invulnerable.up + num(S.WritheInAgony:IsAvailable()) and (TargetUnit:DebuffRemainsP(S.CorruptionDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and TargetUnit:DebuffRefreshableCP(S.CorruptionDebuff)) and TargetUnit:TimeToDie() > 10
end

local function EvaluateCycleDrainSoul565(TargetUnit)
  return TargetUnit:TimeToDie() <= Player:GCD()
end

local function EvaluateTargetIfFilterDrainSoul571(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul584(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff))
end

local function EvaluateTargetIfFilterDrainSoul590(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul601(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe)
end

local function EvaluateCycleShadowBolt610(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and not bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and not S.ShadowBolt:InFlight()
end

local function EvaluateTargetIfFilterShadowBolt626(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfShadowBolt637(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe)
end

local function EvaluateCycleUnstableAffliction732(TargetUnit)
  return not bool(VarUseSeed) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() > time_to_shard or Player:SoulShardsP() > 1) and (not S.VileTaint:IsAvailable() or Player:SoulShardsP() > 1) and contagion <= S.UnstableAffliction:CastTime() + VarPadding and (not S.CascadingCalamity:AzeriteEnabled() or Player:BuffRemainsP(S.CascadingCalamityBuff) > time_to_shard)
end

local function EvaluateCycleDrainSoul803(TargetUnit)
  return TargetUnit:TimeToDie() <= Player:GCD() and Player:SoulShardsP() < 5
end

local function EvaluateTargetIfFilterAgony845(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff)
end

local function EvaluateTargetIfAgony862(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() + S.ShadowBolt:ExecuteTime() and TargetUnit:TimeToDie() > 8
end

local function EvaluateCycleUnstableAffliction893(TargetUnit)
  return not bool(contagion) and TargetUnit:TimeToDie() <= 8
end

local function EvaluateTargetIfFilterDrainSoul899(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfDrainSoul914(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= Player:GCD() * 2
end

local function EvaluateTargetIfFilterShadowBolt920(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)
end

local function EvaluateTargetIfShadowBolt947(TargetUnit)
  return S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and bool(TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff)) and TargetUnit:DebuffRemainsP(S.ShadowEmbraceDebuff) <= S.ShadowBolt:ExecuteTime() * 2 + S.ShadowBolt:TravelTime() and not S.ShadowBolt:InFlight()
end

local function EvaluateTargetIfFilterPhantomSingularity953(TargetUnit)
  return TargetUnit:TimeToDie()
end

local function EvaluateTargetIfPhantomSingularity966(TargetUnit)
  return HL.CombatTime() > 35 and TargetUnit:TimeToDie() > 16 * Player:SpellHaste() and (not bool(essence.vision_of_perfection.minor) and not bool(S.DreadfulCalling:AzeriteRank()) or S.SummonDarkglare:CooldownRemainsP() > 45 + Player:SoulShardsP() * S.DreadfulCalling:AzeriteRank() or S.SummonDarkglare:CooldownRemainsP() < 15 * Player:SpellHaste() + Player:SoulShardsP() * S.DreadfulCalling:AzeriteRank())
end

local function EvaluateTargetIfFilterUnstableAffliction972(TargetUnit)
  return min:contagion
end

local function EvaluateTargetIfUnstableAffliction977(TargetUnit)
  return not bool(VarUseSeed) and Player:SoulShardsP() == 5
end

local function EvaluateTargetIfFilterVileTaint989(TargetUnit)
  return TargetUnit:TimeToDie()
end

local function EvaluateTargetIfVileTaint1004(TargetUnit)
  return HL.CombatTime() > 15 and TargetUnit:TimeToDie() >= 10 and (S.SummonDarkglare:CooldownRemainsP() > 30 or S.SummonDarkglare:CooldownRemainsP() < 10 and TargetUnit:DebuffRemainsP(S.AgonyDebuff) >= 10 and TargetUnit:DebuffRemainsP(S.CorruptionDebuff) >= 10 and (TargetUnit:DebuffRemainsP(S.SiphonLifeDebuff) >= 10 or not S.SiphonLife:IsAvailable()))
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cooldowns, DbRefresh, Dots, Fillers, Spenders
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
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 14"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 16"; end
    end
    -- seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3&!equipped.169314
    if S.SeedofCorruption:IsCastableP() and Player:DebuffDownP(S.SeedofCorruptionDebuff) and (Cache.EnemiesCount[5] >= 3 and not I.Item169314:IsEquipped()) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 18"; end
    end
    -- haunt
    if S.Haunt:IsCastableP() and Player:DebuffDownP(S.HauntDebuff) then
      if HR.Cast(S.Haunt) then return "haunt 24"; end
    end
    -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3&!equipped.169314
    if S.ShadowBolt:IsCastableP() and (not S.Haunt:IsAvailable() and Cache.EnemiesCount[5] < 3 and not I.Item169314:IsEquipped()) then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 28"; end
    end
  end
  Cooldowns = function()
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 36"; end
    end
    -- use_item,name=azsharas_font_of_power,if=(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains<4*spell_haste|!cooldown.phantom_singularity.remains)&cooldown.summon_darkglare.remains<19*spell_haste+soul_shard*azerite.dreadful_calling.rank&dot.agony.remains&dot.corruption.remains&(dot.siphon_life.remains|!talent.siphon_life.enabled)
    if I.AzsharasFontofPower:IsReady() and ((not S.PhantomSingularity:IsAvailable() or S.PhantomSingularity:CooldownRemainsP() < 4 * Player:SpellHaste() or not bool(S.PhantomSingularity:CooldownRemainsP())) and S.SummonDarkglare:CooldownRemainsP() < 19 * Player:SpellHaste() + Player:SoulShardsP() * S.DreadfulCalling:AzeriteRank() and bool(Target:DebuffRemainsP(S.AgonyDebuff)) and bool(Target:DebuffRemainsP(S.CorruptionDebuff)) and (bool(Target:DebuffRemainsP(S.SiphonLifeDebuff)) or not S.SiphonLife:IsAvailable())) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 38"; end
    end
    -- potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions and ((S.DarkSoulMisery:IsAvailable() and S.SummonDarkglare:CooldownUpP() and S.DarkSoul:CooldownUpP()) or S.SummonDarkglare:CooldownUpP() or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 58"; end
    end
    -- use_items,if=cooldown.summon_darkglare.remains>70|time_to_die<20|((buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains)&!cooldown.summon_darkglare.remains)
    -- fireblood,if=!cooldown.summon_darkglare.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 69"; end
    end
    -- blood_fury,if=!cooldown.summon_darkglare.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 73"; end
    end
    -- memory_of_lucid_dreams,if=time>30
    if S.MemoryofLucidDreams:IsCastableP() and (HL.CombatTime() > 30) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 77"; end
    end
    -- dark_soul,if=target.time_to_die<20+gcd|talent.sow_the_seeds.enabled&cooldown.summon_darkglare.remains>=cooldown.summon_darkglare.duration-10
    if S.DarkSoul:IsCastableP() and HR.CDsON() and (Target:TimeToDie() < 20 + Player:GCD() or S.SowtheSeeds:IsAvailable() and S.SummonDarkglare:CooldownRemainsP() >= S.SummonDarkglare:BaseDuration() - 10) then
      if HR.Cast(S.DarkSoul, Settings.Affliction.GCDasOffGCD.DarkSoul) then return "dark_soul 79"; end
    end
    -- blood_of_the_enemy,if=pet.darkglare.remains|(!cooldown.deathbolt.remains|!talent.deathbolt.enabled)&cooldown.summon_darkglare.remains>=80&essence.blood_of_the_enemy.rank>1
    if S.BloodoftheEnemy:IsCastableP() and (bool(pet.darkglare.remains) or (not bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable()) and S.SummonDarkglare:CooldownRemainsP() >= 80 and essence.blood_of_the_enemy.rank > 1) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 87"; end
    end
    -- use_item,name=pocketsized_computation_device,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.PocketsizedComputationDevice:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.PocketsizedComputationDevice) then return "pocketsized_computation_device 99"; end
    end
    -- use_item,name=rotcrusted_voodoo_doll,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.RotcrustedVoodooDoll:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.RotcrustedVoodooDoll) then return "rotcrusted_voodoo_doll 107"; end
    end
    -- use_item,name=shiver_venom_relic,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.ShiverVenomRelic:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.ShiverVenomRelic) then return "shiver_venom_relic 115"; end
    end
    -- use_item,name=aquipotent_nautilus,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.AquipotentNautilus:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.AquipotentNautilus) then return "aquipotent_nautilus 123"; end
    end
    -- use_item,name=tidestorm_codex,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.TidestormCodex:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.TidestormCodex) then return "tidestorm_codex 131"; end
    end
    -- use_item,name=vial_of_storms,if=(cooldown.summon_darkglare.remains>=25|target.time_to_die<=30)&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.VialofStorms:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30) and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
      if HR.CastSuggested(I.VialofStorms) then return "vial_of_storms 139"; end
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 147"; end
    end
  end
  DbRefresh = function()
    -- siphon_life,line_cd=15,if=(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.corruption.remains%dot.corruption.duration)&dot.siphon_life.remains<dot.siphon_life.duration*1.3
    if S.SiphonLife:IsCastableP() and ((Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) and Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 1.3) then
      if HR.Cast(S.SiphonLife) then return "siphon_life 149"; end
    end
    -- agony,line_cd=15,if=(dot.agony.remains%dot.agony.duration)<=(dot.corruption.remains%dot.corruption.duration)&(dot.agony.remains%dot.agony.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.agony.remains<dot.agony.duration*1.3
    if S.Agony:IsCastableP() and ((Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) and Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 1.3) then
      if HR.Cast(S.Agony) then return "agony 171"; end
    end
    -- corruption,line_cd=15,if=(dot.corruption.remains%dot.corruption.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.corruption.remains%dot.corruption.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.corruption.remains<dot.corruption.duration*1.3
    if S.Corruption:IsCastableP() and ((Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) and Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 1.3) then
      if HR.Cast(S.Corruption) then return "corruption 193"; end
    end
  end
  Dots = function()
    -- seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
    if S.SeedofCorruption:IsCastableP() and (Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + time_to_shard + 4.2 * (1 - num(S.CreepingDeath:IsAvailable()) * 0.15) and Cache.EnemiesCount[5] >= 3 + raid_event.invulnerable.up + num(S.WritheInAgony:IsAvailable()) and not bool(Target:DebuffRemainsP(S.SeedofCorruptionDebuff)) and not S.SeedofCorruption:InFlight()) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 215"; end
    end
    -- agony,target_if=min:remains,if=talent.creeping_death.enabled&active_dot.agony<6&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony240, EvaluateTargetIfAgony281) then return "agony 283" end
    end
    -- agony,target_if=min:remains,if=!talent.creeping_death.enabled&active_dot.agony<8&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony287, EvaluateTargetIfAgony328) then return "agony 330" end
    end
    -- siphon_life,target_if=min:remains,if=(active_dot.siphon_life<8-talent.creeping_death.enabled-spell_targets.sow_the_seeds_aoe)&target.time_to_die>10&refreshable&(!remains&spell_targets.seed_of_corruption_aoe=1|cooldown.summon_darkglare.remains>soul_shard*action.unstable_affliction.execute_time)
    if S.SiphonLife:IsCastableP() then
      if HR.CastTargetIf(S.SiphonLife, 40, "min", EvaluateTargetIfFilterSiphonLife334, EvaluateTargetIfSiphonLife373) then return "siphon_life 375" end
    end
    -- corruption,cycle_targets=1,if=spell_targets.seed_of_corruption_aoe<3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)&target.time_to_die>10
    if S.Corruption:IsCastableP() then
      if HR.CastCycle(S.Corruption, 40, EvaluateCycleCorruption380) then return "corruption 398" end
    end
  end
  Fillers = function()
    -- unstable_affliction,line_cd=15,if=cooldown.deathbolt.remains<=gcd*2&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains>20
    if S.UnstableAffliction:IsReadyP() and (S.Deathbolt:CooldownRemainsP() <= Player:GCD() * 2 and Cache.EnemiesCount[5] == 1 + raid_event.invulnerable.up and S.SummonDarkglare:CooldownRemainsP() > 20) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 399"; end
    end
    -- call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(dot.agony.remains<dot.agony.duration*0.75|dot.corruption.remains<dot.corruption.duration*0.75|dot.siphon_life.remains<dot.siphon_life.duration*0.75)&cooldown.deathbolt.remains<=action.agony.gcd*4&cooldown.summon_darkglare.remains>20
    if (S.Deathbolt:IsAvailable() and Cache.EnemiesCount[5] == 1 + raid_event.invulnerable.up and (Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 0.75 or Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 0.75 or Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 0.75) and S.Deathbolt:CooldownRemainsP() <= action.agony.gcd * 4 and S.SummonDarkglare:CooldownRemainsP() > 20) then
      local ShouldReturn = DbRefresh(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains<=soul_shard*action.agony.gcd+action.agony.gcd*3&(dot.agony.remains<dot.agony.duration*1|dot.corruption.remains<dot.corruption.duration*1|dot.siphon_life.remains<dot.siphon_life.duration*1)
    if (S.Deathbolt:IsAvailable() and Cache.EnemiesCount[5] == 1 + raid_event.invulnerable.up and S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * action.agony.gcd + action.agony.gcd * 3 and (Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 1 or Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 1 or Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 1)) then
      local ShouldReturn = DbRefresh(); if ShouldReturn then return ShouldReturn; end
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
    if S.Deathbolt:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 140) then
      if HR.Cast(S.Deathbolt) then return "deathbolt 461"; end
    end
    -- shadow_bolt,if=buff.movement.up&buff.nightfall.remains
    if S.ShadowBolt:IsCastableP() and (Player:IsMoving() and bool(Player:BuffRemainsP(S.NightfallBuff))) then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 467"; end
    end
    -- agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
    if S.Agony:IsCastableP() and (Player:IsMoving() and not (S.SiphonLife:IsAvailable() and (Player:PrevGCDP(1, S.Agony) and Player:PrevGCDP(2, S.Agony) and Player:PrevGCDP(3, S.Agony)) or Player:PrevGCDP(1, S.Agony))) then
      if HR.Cast(S.Agony) then return "agony 471"; end
    end
    -- siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
    if S.SiphonLife:IsCastableP() and (Player:IsMoving() and not (Player:PrevGCDP(1, S.SiphonLife) and Player:PrevGCDP(2, S.SiphonLife) and Player:PrevGCDP(3, S.SiphonLife))) then
      if HR.Cast(S.SiphonLife) then return "siphon_life 483"; end
    end
    -- corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
    if S.Corruption:IsCastableP() and (Player:IsMoving() and not Player:PrevGCDP(1, S.Corruption) and not S.AbsoluteCorruption:IsAvailable()) then
      if HR.Cast(S.Corruption) then return "corruption 491"; end
    end
    -- drain_life,if=buff.inevitable_demise.stack>10&target.time_to_die<=10
    if S.DrainLife:IsCastableP() and HR.CDsON() and (Player:BuffStackP(S.InevitableDemiseBuff) > 10 and Target:TimeToDie() <= 10) then
      if HR.Cast(S.DrainLife) then return "drain_life 497"; end
    end
    -- drain_life,if=talent.siphon_life.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=2)&dot.agony.remains>5*spell_haste&dot.corruption.remains>gcd&(dot.siphon_life.remains>gcd|!talent.siphon_life.enabled)&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and HR.CDsON() and (S.SiphonLife:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num((Cache.EnemiesCount[5] - raid_event.invulnerable.up >= 2)) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and Target:DebuffRemainsP(S.CorruptionDebuff) > Player:GCD() and (Target:DebuffRemainsP(S.SiphonLifeDebuff) > Player:GCD() or not S.SiphonLife:IsAvailable()) and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      if HR.Cast(S.DrainLife) then return "drain_life 501"; end
    end
    -- drain_life,if=talent.writhe_in_agony.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=3)-5*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up=2)&dot.agony.remains>5*spell_haste&dot.corruption.remains>gcd&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and HR.CDsON() and (S.WritheInAgony:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num((Cache.EnemiesCount[5] - raid_event.invulnerable.up >= 3)) - 5 * num((Cache.EnemiesCount[5] - raid_event.invulnerable.up == 2)) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and Target:DebuffRemainsP(S.CorruptionDebuff) > Player:GCD() and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      if HR.Cast(S.DrainLife) then return "drain_life 519"; end
    end
    -- drain_life,if=talent.absolute_corruption.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=4)&dot.agony.remains>5*spell_haste&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and HR.CDsON() and (S.AbsoluteCorruption:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num((Cache.EnemiesCount[5] - raid_event.invulnerable.up >= 4)) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      if HR.Cast(S.DrainLife) then return "drain_life 533"; end
    end
    -- haunt
    if S.Haunt:IsCastableP() then
      if HR.Cast(S.Haunt) then return "haunt 545"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 547"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 549"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 551"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight()) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 553"; end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1,cycle_targets=1,if=target.time_to_die<=gcd
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, EvaluateCycleDrainSoul565) then return "drain_soul 567" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul571, EvaluateTargetIfDrainSoul584) then return "drain_soul 586" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul590, EvaluateTargetIfDrainSoul601) then return "drain_soul 603" end
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() then
      if HR.Cast(S.DrainSoul) then return "drain_soul 604"; end
    end
    -- shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastCycle(S.ShadowBolt, 40, EvaluateCycleShadowBolt610) then return "shadow_bolt 622" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", EvaluateTargetIfFilterShadowBolt626, EvaluateTargetIfShadowBolt637) then return "shadow_bolt 639" end
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 640"; end
    end
  end
  Spenders = function()
    -- unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*(execute_time+azerite.dreadful_calling.rank)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=soul_shard*execute_time)&(talent.sow_the_seeds.enabled|dot.phantom_singularity.remains|dot.vile_taint.remains)
    if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * (S.UnstableAffliction:ExecuteTime() + S.DreadfulCalling:AzeriteRank()) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and (S.SowtheSeeds:IsAvailable() or bool(Target:DebuffRemainsP(S.PhantomSingularityDebuff)) or bool(Target:DebuffRemainsP(S.VileTaintDebuff)))) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 642"; end
    end
    -- call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
    if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
    -- seed_of_corruption,if=variable.use_seed
    if S.SeedofCorruption:IsCastableP() and (bool(VarUseSeed)) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 682"; end
    end
    -- unstable_affliction,if=!variable.use_seed&!prev_gcd.1.summon_darkglare&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|(soul_shard>=5&spell_targets.seed_of_corruption_aoe<2|soul_shard>=2&spell_targets.seed_of_corruption_aoe>=2)&target.time_to_die>4+execute_time&spell_targets.seed_of_corruption_aoe=1|target.time_to_die<=8+execute_time*soul_shard)
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and not Player:PrevGCDP(1, S.SummonDarkglare) and (S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= S.UnstableAffliction:ExecuteTime() and not S.CascadingCalamity:AzeriteEnabled() or (Player:SoulShardsP() >= 5 and Cache.EnemiesCount[5] < 2 or Player:SoulShardsP() >= 2 and Cache.EnemiesCount[5] >= 2) and Target:TimeToDie() > 4 + S.UnstableAffliction:ExecuteTime() and Cache.EnemiesCount[5] == 1 or Target:TimeToDie() <= 8 + S.UnstableAffliction:ExecuteTime() * Player:SoulShardsP())) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 686"; end
    end
    -- unstable_affliction,if=!variable.use_seed&contagion<=cast_time+variable.padding
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and contagion <= S.UnstableAffliction:CastTime() + VarPadding) then
      if HR.Cast(S.UnstableAffliction) then return "unstable_affliction 716"; end
    end
    -- unstable_affliction,cycle_targets=1,if=!variable.use_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&(!talent.vile_taint.enabled|soul_shard>1)&contagion<=cast_time+variable.padding&(!azerite.cascading_calamity.enabled|buff.cascading_calamity.remains>time_to_shard)
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastCycle(S.UnstableAffliction, 40, EvaluateCycleUnstableAffliction732) then return "unstable_affliction 754" end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5+raid_event.invulnerable.up|spell_targets.seed_of_corruption>=8+raid_event.invulnerable.up
    if (true) then
      VarUseSeed = num(S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[5] >= 3 + raid_event.invulnerable.up or S.SiphonLife:IsAvailable() and Cache.EnemiesCount[40] >= 5 + raid_event.invulnerable.up or Cache.EnemiesCount[40] >= 8 + raid_event.invulnerable.up)
    end
    -- variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
    if (true) then
      VarPadding = S.ShadowBolt:ExecuteTime() * num(S.CascadingCalamity:AzeriteEnabled())
    end
    -- variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
    if (S.CascadingCalamity:AzeriteEnabled() and (S.DrainSoul:IsAvailable() or S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= Player:GCD())) then
      VarPadding = 0
    end
    -- variable,name=maintain_se,value=spell_targets.seed_of_corruption_aoe<=1+talent.writhe_in_agony.enabled+talent.absolute_corruption.enabled*2+(talent.writhe_in_agony.enabled&talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>2)+(talent.siphon_life.enabled&!talent.creeping_death.enabled&!talent.drain_soul.enabled)+raid_event.invulnerable.up
    if (true) then
      VarMaintainSe = num(Cache.EnemiesCount[5] <= 1 + num(S.WritheInAgony:IsAvailable()) + num(S.AbsoluteCorruption:IsAvailable()) * 2 + num((S.WritheInAgony:IsAvailable() and S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[5] > 2)) + num((S.SiphonLife:IsAvailable() and not S.CreepingDeath:IsAvailable() and not S.DrainSoul:IsAvailable())) + raid_event.invulnerable.up)
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
    if S.DrainSoul:IsCastableP() then
      if HR.CastCycle(S.DrainSoul, 40, EvaluateCycleDrainSoul803) then return "drain_soul 805" end
    end
    -- haunt,if=spell_targets.seed_of_corruption_aoe<=2+raid_event.invulnerable.up
    if S.Haunt:IsCastableP() and (Cache.EnemiesCount[5] <= 2 + raid_event.invulnerable.up) then
      if HR.Cast(S.Haunt) then return "haunt 806"; end
    end
    -- summon_darkglare,if=summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0|dot.phantom_singularity.remains&dot.phantom_singularity.remains<=gcd)&(!talent.phantom_singularity.enabled|dot.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains|spell_targets.seed_of_corruption_aoe>1+raid_event.invulnerable.up)
    if S.SummonDarkglare:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and (ActiveUAs() == 5 or Player:SoulShardsP() == 0 or bool(Target:DebuffRemainsP(S.PhantomSingularityDebuff)) and Target:DebuffRemainsP(S.PhantomSingularityDebuff) <= Player:GCD()) and (not S.PhantomSingularity:IsAvailable() or bool(Target:DebuffRemainsP(S.PhantomSingularityDebuff))) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() <= Player:GCD() or not bool(S.Deathbolt:CooldownRemainsP()) or Cache.EnemiesCount[5] > 1 + raid_event.invulnerable.up)) then
      if HR.Cast(S.SummonDarkglare, Settings.Affliction.GCDasOffGCD.SummonDarkglare) then return "summon_darkglare 808"; end
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(!essence.vision_of_perfection.minor&!azerite.dreadful_calling.rank|cooldown.summon_darkglare.remains>30)
    if S.Deathbolt:IsCastableP() and (bool(S.SummonDarkglare:CooldownRemainsP()) and Cache.EnemiesCount[5] == 1 + raid_event.invulnerable.up and (not bool(essence.vision_of_perfection.minor) and not bool(S.DreadfulCalling:AzeriteRank()) or S.SummonDarkglare:CooldownRemainsP() > 30)) then
      if HR.Cast(S.Deathbolt) then return "deathbolt 830"; end
    end
    -- the_unbound_force,if=buff.reckless_force.remains
    if S.TheUnboundForce:IsCastableP() and (bool(Player:BuffRemainsP(S.RecklessForceBuff))) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 838"; end
    end
    -- agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time&target.time_to_die>8
    if S.Agony:IsCastableP() then
      if HR.CastTargetIf(S.Agony, 40, "min", EvaluateTargetIfFilterAgony845, EvaluateTargetIfAgony862) then return "agony 864" end
    end
    -- memory_of_lucid_dreams,if=time<30
    if S.MemoryofLucidDreams:IsCastableP() and (HL.CombatTime() < 30) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 865"; end
    end
    -- agony,line_cd=30,if=time>30&cooldown.summon_darkglare.remains<=15&equipped.169314
    if S.Agony:IsCastableP() and (HL.CombatTime() > 30 and S.SummonDarkglare:CooldownRemainsP() <= 15 and I.Item169314:IsEquipped()) then
      if HR.Cast(S.Agony) then return "agony 867"; end
    end
    -- corruption,line_cd=30,if=time>30&cooldown.summon_darkglare.remains<=15&equipped.169314&!talent.absolute_corruption.enabled&(talent.siphon_life.enabled|spell_targets.seed_of_corruption_aoe>1&spell_targets.seed_of_corruption_aoe<=3)
    if S.Corruption:IsCastableP() and (HL.CombatTime() > 30 and S.SummonDarkglare:CooldownRemainsP() <= 15 and I.Item169314:IsEquipped() and not S.AbsoluteCorruption:IsAvailable() and (S.SiphonLife:IsAvailable() or Cache.EnemiesCount[5] > 1 and Cache.EnemiesCount[5] <= 3)) then
      if HR.Cast(S.Corruption) then return "corruption 873"; end
    end
    -- siphon_life,line_cd=30,if=time>30&cooldown.summon_darkglare.remains<=15&equipped.169314
    if S.SiphonLife:IsCastableP() and (HL.CombatTime() > 30 and S.SummonDarkglare:CooldownRemainsP() <= 15 and I.Item169314:IsEquipped()) then
      if HR.Cast(S.SiphonLife) then return "siphon_life 883"; end
    end
    -- unstable_affliction,target_if=!contagion&target.time_to_die<=8
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastCycle(S.UnstableAffliction, 40, EvaluateCycleUnstableAffliction893) then return "unstable_affliction 895" end
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,cancel_if=ticks_remain<5,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=gcd*2
    if S.DrainSoul:IsCastableP() then
      if HR.CastTargetIf(S.DrainSoul, 40, "min", EvaluateTargetIfFilterDrainSoul899, EvaluateTargetIfDrainSoul914) then return "drain_soul 916" end
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() then
      if HR.CastTargetIf(S.ShadowBolt, 40, "min", EvaluateTargetIfFilterShadowBolt920, EvaluateTargetIfShadowBolt947) then return "shadow_bolt 949" end
    end
    -- phantom_singularity,target_if=max:target.time_to_die,if=time>35&target.time_to_die>16*spell_haste&(!essence.vision_of_perfection.minor&!azerite.dreadful_calling.rank|cooldown.summon_darkglare.remains>45+soul_shard*azerite.dreadful_calling.rank|cooldown.summon_darkglare.remains<15*spell_haste+soul_shard*azerite.dreadful_calling.rank)
    if S.PhantomSingularity:IsCastableP() then
      if HR.CastTargetIf(S.PhantomSingularity, 40, "max", EvaluateTargetIfFilterPhantomSingularity953, EvaluateTargetIfPhantomSingularity966) then return "phantom_singularity 968" end
    end
    -- unstable_affliction,target_if=min:contagion,if=!variable.use_seed&soul_shard=5
    if S.UnstableAffliction:IsReadyP() then
      if HR.CastTargetIf(S.UnstableAffliction, 40, "min", EvaluateTargetIfFilterUnstableAffliction972, EvaluateTargetIfUnstableAffliction977) then return "unstable_affliction 979" end
    end
    -- seed_of_corruption,if=variable.use_seed&soul_shard=5
    if S.SeedofCorruption:IsCastableP() and (bool(VarUseSeed) and Player:SoulShardsP() == 5) then
      if HR.Cast(S.SeedofCorruption) then return "seed_of_corruption 980"; end
    end
    -- call_action_list,name=dots
    if (true) then
      local ShouldReturn = Dots(); if ShouldReturn then return ShouldReturn; end
    end
    -- vile_taint,target_if=max:target.time_to_die,if=time>15&target.time_to_die>=10&(cooldown.summon_darkglare.remains>30|cooldown.summon_darkglare.remains<10&dot.agony.remains>=10&dot.corruption.remains>=10&(dot.siphon_life.remains>=10|!talent.siphon_life.enabled))
    if S.VileTaint:IsCastableP() then
      if HR.CastTargetIf(S.VileTaint, 40, "max", EvaluateTargetIfFilterVileTaint989, EvaluateTargetIfVileTaint1004) then return "vile_taint 1006" end
    end
    -- use_item,name=azsharas_font_of_power,if=time<=3
    if I.AzsharasFontofPower:IsReady() and (HL.CombatTime() <= 3) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 1007"; end
    end
    -- phantom_singularity,if=time<=35
    if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 35) then
      if HR.Cast(S.PhantomSingularity, Settings.Affliction.GCDasOffGCD.PhantomSingularity) then return "phantom_singularity 1009"; end
    end
    -- vile_taint,if=time<15
    if S.VileTaint:IsCastableP() and (HL.CombatTime() < 15) then
      if HR.Cast(S.VileTaint) then return "vile_taint 1011"; end
    end
    -- guardian_of_azeroth,if=(cooldown.summon_darkglare.remains<15+soul_shard*azerite.dreadful_calling.enabled|(azerite.dreadful_calling.rank|essence.vision_of_perfection.rank)&time>30&target.time_to_die>=210)&(dot.phantom_singularity.remains|dot.vile_taint.remains|!talent.phantom_singularity.enabled&!talent.vile_taint.enabled)|target.time_to_die<30+gcd
    if S.GuardianofAzeroth:IsCastableP() and ((S.SummonDarkglare:CooldownRemainsP() < 15 + Player:SoulShardsP() * num(S.DreadfulCalling:AzeriteEnabled()) or (bool(S.DreadfulCalling:AzeriteRank()) or bool(essence.vision_of_perfection.rank)) and HL.CombatTime() > 30 and Target:TimeToDie() >= 210) and (bool(Target:DebuffRemainsP(S.PhantomSingularityDebuff)) or bool(Target:DebuffRemainsP(S.VileTaintDebuff)) or not S.PhantomSingularity:IsAvailable() and not S.VileTaint:IsAvailable()) or Target:TimeToDie() < 30 + Player:GCD()) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 1013"; end
    end
    -- dark_soul,if=cooldown.summon_darkglare.remains<15+soul_shard*azerite.dreadful_calling.enabled&(dot.phantom_singularity.remains|dot.vile_taint.remains)
    if S.DarkSoul:IsCastableP() and HR.CDsON() and (S.SummonDarkglare:CooldownRemainsP() < 15 + Player:SoulShardsP() * num(S.DreadfulCalling:AzeriteEnabled()) and (bool(Target:DebuffRemainsP(S.PhantomSingularityDebuff)) or bool(Target:DebuffRemainsP(S.VileTaintDebuff)))) then
      if HR.Cast(S.DarkSoul, Settings.Affliction.GCDasOffGCD.DarkSoul) then return "dark_soul 1029"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 1039"; end
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
