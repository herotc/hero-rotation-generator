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
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Unholy = {
  RaiseDead                             = Spell(46584),
  ArmyoftheDead                         = Spell(42650),
  DeathandDecay                         = Spell(43265),
  Apocalypse                            = Spell(275699),
  Defile                                = Spell(152280),
  Epidemic                              = Spell(207317),
  BurstingSores                         = Spell(207264),
  DeathCoil                             = Spell(47541),
  ScourgeStrike                         = Spell(55090),
  ClawingShadows                        = Spell(207311),
  FesteringStrike                       = Spell(85948),
  FesteringWoundDebuff                  = Spell(194310),
  SuddenDoomBuff                        = Spell(81340),
  UnholyFrenzyBuff                      = Spell(207289),
  MagusoftheDead                        = Spell(288417),
  UnholyFrenzy                          = Spell(207289),
  DarkTransformation                    = Spell(63560),
  SummonGargoyle                        = Spell(49206),
  SoulReaper                            = Spell(130736),
  UnholyBlight                          = Spell(115989),
  MemoryofLucidDreams                   = Spell(),
  BloodoftheEnemy                       = Spell(),
  GuardianofAzeroth                     = Spell(),
  CondensedLifeforce                    = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  RecklessForceCounterBuff              = Spell(),
  FocusedAzeriteBeam                    = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  PurifyingBlast                        = Spell(),
  WorldveinResonance                    = Spell(),
  ArmyoftheDamned                       = Spell(276837),
  UnholyStrengthBuff                    = Spell(53365),
  RippleInSpace                         = Spell(),
  ReapingFlames                         = Spell(),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  FestermightBuff                       = Spell(),
  AncestralCall                         = Spell(274738),
  ArcanePulse                           = Spell(),
  Fireblood                             = Spell(265221),
  BagofTricks                           = Spell(),
  RazorCoralDebuffDebuff                = Spell(),
  Outbreak                              = Spell(77575),
  VirulentPlagueDebuff                  = Spell(191587)
};
local S = Spell.DeathKnight.Unholy;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  BattlePotionofStrength           = Item(163224),
  AzsharasFontofPower              = Item(),
  IneffableTruth                   = Item(),
  IneffableTruthOh                 = Item(),
  AshvanesRazorCoral               = Item(),
  VisionofDemise                   = Item(),
  RampingAmplitudeGigavoltEngine   = Item(165580),
  BygoneBeeAlmanac                 = Item(163936),
  JesHowler                        = Item(159627),
  GalecallersBeak                  = Item(161379),
  GrongsPrimalRage                 = Item(165574)
};
local I = Item.DeathKnight.Unholy;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Unholy = HR.GUISettings.APL.DeathKnight.Unholy
};

-- Variables
local VarPoolingForGargoyle = 0;

HL:RegisterForEvent(function()
  VarPoolingForGargoyle = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {30}
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


local function EvaluateCycleFesteringStrike50(TargetUnit)
  return TargetUnit:DebuffStackP(S.FesteringWoundDebuff) <= 2 and bool(S.DeathandDecay:CooldownRemainsP()) and S.Apocalypse:CooldownRemainsP() > 5 and (S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd))
end

local function EvaluateCycleScourgeStrike83(TargetUnit)
  return ((S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd)) and (S.Apocalypse:CooldownRemainsP() > 5 and TargetUnit:DebuffStackP(S.FesteringWoundDebuff) > 0 or TargetUnit:DebuffStackP(S.FesteringWoundDebuff) > 4) and (target.1.time_to_die < S.DeathandDecay:CooldownRemainsP() + 10 or target.1.time_to_die > S.Apocalypse:CooldownRemainsP()))
end

local function EvaluateCycleClawingShadows102(TargetUnit)
  return ((S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd)) and (S.Apocalypse:CooldownRemainsP() > 5 and TargetUnit:DebuffStackP(S.FesteringWoundDebuff) > 0 or TargetUnit:DebuffStackP(S.FesteringWoundDebuff) > 4) and (target.1.time_to_die < S.DeathandDecay:CooldownRemainsP() + 10 or target.1.time_to_die > S.Apocalypse:CooldownRemainsP()))
end

local function EvaluateCycleSoulReaper193(TargetUnit)
  return TargetUnit:TimeToDie() < 8 and TargetUnit:TimeToDie() > 4
end

local function EvaluateCycleOutbreak483(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.VirulentPlagueDebuff) <= Player:GCD()
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cooldowns, Essences, Generic
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 4"; end
    end
    -- raise_dead
    if S.RaiseDead:IsCastableP() then
      if HR.Cast(S.RaiseDead) then return "raise_dead 6"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 8"; end
    end
    -- army_of_the_dead,delay=2
    if S.ArmyoftheDead:IsCastableP() then
      if HR.Cast(S.ArmyoftheDead) then return "army_of_the_dead 10"; end
    end
  end
  Aoe = function()
    -- death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.DeathandDecay) then return "death_and_decay 12"; end
    end
    -- defile,if=cooldown.apocalypse.remains
    if S.Defile:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.Defile) then return "defile 16"; end
    end
    -- epidemic,if=death_and_decay.ticking&runic_power.deficit<(14+death_knight.fwounded_targets*3)&!variable.pooling_for_gargoyle
    if S.Epidemic:IsReadyP() and (bool(death_and_decay.ticking) and Player:RunicPowerDeficit() < (14 + death_knight.fwounded_targets * 3) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return "epidemic 20"; end
    end
    -- epidemic,if=death_and_decay.ticking&(!death_knight.fwounded_targets&talent.bursting_sores.enabled)&!variable.pooling_for_gargoyle
    if S.Epidemic:IsReadyP() and (bool(death_and_decay.ticking) and (not bool(death_knight.fwounded_targets) and S.BurstingSores:IsAvailable()) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return "epidemic 24"; end
    end
    -- death_coil,if=death_and_decay.ticking&runic_power.deficit<14&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (bool(death_and_decay.ticking) and Player:RunicPowerDeficit() < 14 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 30"; end
    end
    -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 34"; end
    end
    -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ClawingShadows) then return "clawing_shadows 38"; end
    end
    -- epidemic,if=!variable.pooling_for_gargoyle
    if S.Epidemic:IsReadyP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return "epidemic 42"; end
    end
    -- festering_strike,target_if=debuff.festering_wound.stack<=2&cooldown.death_and_decay.remains&cooldown.apocalypse.remains>5&(cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)
    if S.FesteringStrike:IsCastableP() then
      if HR.CastCycle(S.FesteringStrike, 30, EvaluateCycleFesteringStrike50) then return "festering_strike 60" end
    end
    -- death_coil,if=buff.sudden_doom.react&rune.time_to_4>gcd
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:RuneTimeToX(4) > Player:GCD()) then
      if HR.Cast(S.DeathCoil) then return "death_coil 61"; end
    end
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(pet.gargoyle.active)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 65"; end
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 71"; end
    end
    -- scourge_strike,target_if=((cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)&(cooldown.apocalypse.remains>5&debuff.festering_wound.stack>0|debuff.festering_wound.stack>4)&(target.1.time_to_die<cooldown.death_and_decay.remains+10|target.1.time_to_die>cooldown.apocalypse.remains))
    if S.ScourgeStrike:IsCastableP() then
      if HR.CastCycle(S.ScourgeStrike, 30, EvaluateCycleScourgeStrike83) then return "scourge_strike 97" end
    end
    -- clawing_shadows,target_if=((cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)&(cooldown.apocalypse.remains>5&debuff.festering_wound.stack>0|debuff.festering_wound.stack>4)&(target.1.time_to_die<cooldown.death_and_decay.remains+10|target.1.time_to_die>cooldown.apocalypse.remains))
    if S.ClawingShadows:IsCastableP() then
      if HR.CastCycle(S.ClawingShadows, 30, EvaluateCycleClawingShadows102) then return "clawing_shadows 116" end
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 117"; end
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&(cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)
    if S.FesteringStrike:IsCastableP() and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd))) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 121"; end
    end
    -- scourge_strike,if=death_and_decay.ticking
    if S.ScourgeStrike:IsCastableP() and (bool(death_and_decay.ticking)) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 135"; end
    end
  end
  Cooldowns = function()
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() then
      if HR.Cast(S.ArmyoftheDead) then return "army_of_the_dead 137"; end
    end
    -- apocalypse,if=debuff.festering_wound.stack>=4&(active_enemies>=2|!essence.vision_of_perfection.enabled|!azerite.magus_of_the_dead.enabled|essence.vision_of_perfection.enabled&(talent.unholy_frenzy.enabled&cooldown.unholy_frenzy.remains<=3|!talent.unholy_frenzy.enabled))
    if S.Apocalypse:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 4 and (Cache.EnemiesCount[30] >= 2 or not bool(essence.vision_of_perfection.enabled) or not S.MagusoftheDead:AzeriteEnabled() or bool(essence.vision_of_perfection.enabled) and (S.UnholyFrenzy:IsAvailable() and S.UnholyFrenzy:CooldownRemainsP() <= 3 or not S.UnholyFrenzy:IsAvailable()))) then
      if HR.Cast(S.Apocalypse) then return "apocalypse 139"; end
    end
    -- dark_transformation,if=!raid_event.adds.exists|raid_event.adds.in>15
    if S.DarkTransformation:IsCastableP() and (not (Cache.EnemiesCount[30] > 1) or 10000000000 > 15) then
      if HR.Cast(S.DarkTransformation, Settings.Unholy.GCDasOffGCD.DarkTransformation) then return "dark_transformation 157"; end
    end
    -- summon_gargoyle,if=runic_power.deficit<14
    if S.SummonGargoyle:IsCastableP() and (Player:RunicPowerDeficit() < 14) then
      if HR.Cast(S.SummonGargoyle) then return "summon_gargoyle 161"; end
    end
    -- unholy_frenzy,if=essence.vision_of_perfection.enabled&pet.apoc_ghoul.active|debuff.festering_wound.stack<4&!essence.vision_of_perfection.enabled&(!azerite.magus_of_the_dead.enabled|azerite.magus_of_the_dead.enabled&pet.apoc_ghoul.active)
    if S.UnholyFrenzy:IsCastableP() and (bool(essence.vision_of_perfection.enabled) and bool(pet.apoc_ghoul.active) or Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not bool(essence.vision_of_perfection.enabled) and (not S.MagusoftheDead:AzeriteEnabled() or S.MagusoftheDead:AzeriteEnabled() and bool(pet.apoc_ghoul.active))) then
      if HR.Cast(S.UnholyFrenzy) then return "unholy_frenzy 163"; end
    end
    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if S.UnholyFrenzy:IsCastableP() and (Cache.EnemiesCount[30] >= 2 and ((S.DeathandDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
      if HR.Cast(S.UnholyFrenzy) then return "unholy_frenzy 171"; end
    end
    -- soul_reaper,target_if=target.time_to_die<8&target.time_to_die>4
    if S.SoulReaper:IsCastableP() then
      if HR.CastCycle(S.SoulReaper, 30, EvaluateCycleSoulReaper193) then return "soul_reaper 195" end
    end
    -- soul_reaper,if=(!raid_event.adds.exists|raid_event.adds.in>20)&rune<=(1-buff.unholy_frenzy.up)
    if S.SoulReaper:IsCastableP() and ((not (Cache.EnemiesCount[30] > 1) or 10000000000 > 20) and Player:Rune() <= (1 - num(Player:BuffP(S.UnholyFrenzyBuff)))) then
      if HR.Cast(S.SoulReaper) then return "soul_reaper 196"; end
    end
    -- unholy_blight
    if S.UnholyBlight:IsCastableP() then
      if HR.Cast(S.UnholyBlight) then return "unholy_blight 202"; end
    end
  end
  Essences = function()
    -- memory_of_lucid_dreams,if=rune.time_to_1>gcd&runic_power<40
    if S.MemoryofLucidDreams:IsCastableP() and (Player:RuneTimeToX(1) > Player:GCD() and Player:RunicPower() < 40) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 204"; end
    end
    -- blood_of_the_enemy,if=death_and_decay.ticking|pet.apoc_ghoul.active&active_enemies=1
    if S.BloodoftheEnemy:IsCastableP() and (bool(death_and_decay.ticking) or bool(pet.apoc_ghoul.active) and Cache.EnemiesCount[30] == 1) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 206"; end
    end
    -- guardian_of_azeroth,if=(cooldown.apocalypse.remains<6&cooldown.army_of_the_dead.remains>cooldown.condensed_lifeforce.remains)|cooldown.army_of_the_dead.remains<2|equipped.ineffable_truth|equipped.ineffable_truth_oh
    if S.GuardianofAzeroth:IsCastableP() and ((S.Apocalypse:CooldownRemainsP() < 6 and S.ArmyoftheDead:CooldownRemainsP() > S.CondensedLifeforce:CooldownRemainsP()) or S.ArmyoftheDead:CooldownRemainsP() < 2 or I.IneffableTruth:IsEquipped() or I.IneffableTruthOh:IsEquipped()) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 214"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 11) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 228"; end
    end
    -- focused_azerite_beam,if=!death_and_decay.ticking
    if S.FocusedAzeriteBeam:IsCastableP() and (not bool(death_and_decay.ticking)) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 234"; end
    end
    -- concentrated_flame,if=dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff) == 0) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 236"; end
    end
    -- purifying_blast,if=!death_and_decay.ticking
    if S.PurifyingBlast:IsCastableP() and (not bool(death_and_decay.ticking)) then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 240"; end
    end
    -- worldvein_resonance,if=talent.army_of_the_damned.enabled&essence.vision_of_perfection.minor&buff.unholy_strength.up|essence.vision_of_perfection.minor&pet.apoc_ghoul.active|talent.army_of_the_damned.enabled&pet.apoc_ghoul.active&cooldown.army_of_the_dead.remains>60|talent.army_of_the_damned.enabled&pet.army_ghoul.active
    if S.WorldveinResonance:IsCastableP() and (S.ArmyoftheDamned:IsAvailable() and bool(essence.vision_of_perfection.minor) and Player:BuffP(S.UnholyStrengthBuff) or bool(essence.vision_of_perfection.minor) and bool(pet.apoc_ghoul.active) or S.ArmyoftheDamned:IsAvailable() and bool(pet.apoc_ghoul.active) and S.ArmyoftheDead:CooldownRemainsP() > 60 or S.ArmyoftheDamned:IsAvailable() and bool(pet.army_ghoul.active)) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 242"; end
    end
    -- worldvein_resonance,if=!death_and_decay.ticking&buff.unholy_strength.up&!essence.vision_of_perfection.minor&!talent.army_of_the_damned.enabled|target.time_to_die<cooldown.apocalypse.remains
    if S.WorldveinResonance:IsCastableP() and (not bool(death_and_decay.ticking) and Player:BuffP(S.UnholyStrengthBuff) and not bool(essence.vision_of_perfection.minor) and not S.ArmyoftheDamned:IsAvailable() or Target:TimeToDie() < S.Apocalypse:CooldownRemainsP()) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 254"; end
    end
    -- ripple_in_space,if=!death_and_decay.ticking
    if S.RippleInSpace:IsCastableP() and (not bool(death_and_decay.ticking)) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 262"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 264"; end
    end
  end
  Generic = function()
    -- death_coil,if=buff.sudden_doom.react&rune.time_to_4>gcd&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:RuneTimeToX(4) > Player:GCD() and not bool(VarPoolingForGargoyle) or bool(pet.gargoyle.active)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 266"; end
    end
    -- death_coil,if=runic_power.deficit<14&rune.time_to_4>gcd&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and Player:RuneTimeToX(4) > Player:GCD() and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 272"; end
    end
    -- scourge_strike,if=((debuff.festering_wound.up&(cooldown.apocalypse.remains>5&(!essence.vision_of_perfection.enabled|!talent.unholy_frenzy.enabled)|essence.vision_of_perfection.enabled&talent.unholy_frenzy.enabled&cooldown.unholy_frenzy.remains>6))|debuff.festering_wound.stack>4)&(cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)
    if S.ScourgeStrike:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and (S.Apocalypse:CooldownRemainsP() > 5 and (not bool(essence.vision_of_perfection.enabled) or not S.UnholyFrenzy:IsAvailable()) or bool(essence.vision_of_perfection.enabled) and S.UnholyFrenzy:IsAvailable() and S.UnholyFrenzy:CooldownRemainsP() > 6)) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd))) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 276"; end
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&(cooldown.apocalypse.remains>5&(!essence.vision_of_perfection.enabled|!talent.unholy_frenzy.enabled)|essence.vision_of_perfection.enabled&talent.unholy_frenzy.enabled&cooldown.unholy_frenzy.remains>6))|debuff.festering_wound.stack>4)&(cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)
    if S.ClawingShadows:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and (S.Apocalypse:CooldownRemainsP() > 5 and (not bool(essence.vision_of_perfection.enabled) or not S.UnholyFrenzy:IsAvailable()) or bool(essence.vision_of_perfection.enabled) and S.UnholyFrenzy:IsAvailable() and S.UnholyFrenzy:CooldownRemainsP() > 6)) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd))) then
      if HR.Cast(S.ClawingShadows) then return "clawing_shadows 292"; end
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 308"; end
    end
    -- festering_strike,if=debuff.festering_wound.stack<4&(cooldown.apocalypse.remains<3&(!essence.vision_of_perfection.enabled|!talent.unholy_frenzy.enabled|essence.vision_of_perfection.enabled&talent.unholy_frenzy.enabled&cooldown.unholy_frenzy.remains<7))|debuff.festering_wound.stack<1&(cooldown.army_of_the_dead.remains>5|death_knight.disable_aotd)
    if S.FesteringStrike:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and (S.Apocalypse:CooldownRemainsP() < 3 and (not bool(essence.vision_of_perfection.enabled) or not S.UnholyFrenzy:IsAvailable() or bool(essence.vision_of_perfection.enabled) and S.UnholyFrenzy:IsAvailable() and S.UnholyFrenzy:CooldownRemainsP() < 7)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1 and (S.ArmyoftheDead:CooldownRemainsP() > 5 or bool(death_knight.disable_aotd))) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 312"; end
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 328"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- variable,name=pooling_for_gargoyle,value=cooldown.summon_gargoyle.remains<5&talent.summon_gargoyle.enabled
    if (true) then
      VarPoolingForGargoyle = num(S.SummonGargoyle:CooldownRemainsP() < 5 and S.SummonGargoyle:IsAvailable())
    end
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:RunicPowerDeficit() > 65 and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) and Player:RuneDeficit() >= 5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 340"; end
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 344"; end
    end
    -- berserking,if=buff.unholy_frenzy.up|pet.gargoyle.active|(talent.army_of_the_damned.enabled&pet.apoc_ghoul.active)
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.UnholyFrenzyBuff) or bool(pet.gargoyle.active) or (S.ArmyoftheDamned:IsAvailable() and bool(pet.apoc_ghoul.active))) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 348"; end
    end
    -- lights_judgment,if=(buff.unholy_strength.up&buff.festermight.remains<=5)|active_enemies>=2&(buff.unholy_strength.up|buff.festermight.remains<=5)
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and ((Player:BuffP(S.UnholyStrengthBuff) and Player:BuffRemainsP(S.FestermightBuff) <= 5) or Cache.EnemiesCount[30] >= 2 and (Player:BuffP(S.UnholyStrengthBuff) or Player:BuffRemainsP(S.FestermightBuff) <= 5)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 354"; end
    end
    -- ancestral_call,if=(pet.gargoyle.active&talent.summon_gargoyle.enabled)|pet.apoc_ghoul.active
    if S.AncestralCall:IsCastableP() and HR.CDsON() and ((bool(pet.gargoyle.active) and S.SummonGargoyle:IsAvailable()) or bool(pet.apoc_ghoul.active)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 370"; end
    end
    -- arcane_pulse,if=active_enemies>=2|(rune.deficit>=5&runic_power.deficit>=60)
    if S.ArcanePulse:IsCastableP() and (Cache.EnemiesCount[30] >= 2 or (Player:RuneDeficit() >= 5 and Player:RunicPowerDeficit() >= 60)) then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 374"; end
    end
    -- fireblood,if=(pet.gargoyle.active&talent.summon_gargoyle.enabled)|pet.apoc_ghoul.active
    if S.Fireblood:IsCastableP() and HR.CDsON() and ((bool(pet.gargoyle.active) and S.SummonGargoyle:IsAvailable()) or bool(pet.apoc_ghoul.active)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 382"; end
    end
    -- bag_of_tricks,if=buff.unholy_strength.up&active_enemies=1|buff.festermight.remains<gcd&active_enemies=1
    if S.BagofTricks:IsCastableP() and (Player:BuffP(S.UnholyStrengthBuff) and Cache.EnemiesCount[30] == 1 or Player:BuffRemainsP(S.FestermightBuff) < Player:GCD() and Cache.EnemiesCount[30] == 1) then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 386"; end
    end
    -- use_items,if=time>20|!equipped.ramping_amplitude_gigavolt_engine|!equipped.vision_of_demise
    -- use_item,name=azsharas_font_of_power,if=(essence.vision_of_perfection.enabled&!talent.unholy_frenzy.enabled)|(!essence.condensed_lifeforce.major&!essence.vision_of_perfection.enabled)
    if I.AzsharasFontofPower:IsReady() and ((bool(essence.vision_of_perfection.enabled) and not S.UnholyFrenzy:IsAvailable()) or (not bool(essence.condensed_lifeforce.major) and not bool(essence.vision_of_perfection.enabled))) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 405"; end
    end
    -- use_item,name=azsharas_font_of_power,if=cooldown.apocalypse.remains<14&(essence.condensed_lifeforce.major|essence.vision_of_perfection.enabled&talent.unholy_frenzy.enabled)
    if I.AzsharasFontofPower:IsReady() and (S.Apocalypse:CooldownRemainsP() < 14 and (bool(essence.condensed_lifeforce.major) or bool(essence.vision_of_perfection.enabled) and S.UnholyFrenzy:IsAvailable())) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 409"; end
    end
    -- use_item,name=azsharas_font_of_power,if=target.1.time_to_die<cooldown.apocalypse.remains+34
    if I.AzsharasFontofPower:IsReady() and (target.1.time_to_die < S.Apocalypse:CooldownRemainsP() + 34) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 415"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.stack<1
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffStackP(S.RazorCoralDebuffDebuff) < 1) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 419"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=pet.guardian_of_azeroth.active&pet.apoc_ghoul.active
    if I.AshvanesRazorCoral:IsReady() and (bool(pet.guardian_of_azeroth.active) and bool(pet.apoc_ghoul.active)) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 423"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=cooldown.apocalypse.ready&(essence.condensed_lifeforce.major&target.1.time_to_die<cooldown.condensed_lifeforce.remains+20|!essence.condensed_lifeforce.major)
    if I.AshvanesRazorCoral:IsReady() and (S.Apocalypse:CooldownUpP() and (bool(essence.condensed_lifeforce.major) and target.1.time_to_die < S.CondensedLifeforce:CooldownRemainsP() + 20 or not bool(essence.condensed_lifeforce.major))) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 425"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=target.1.time_to_die<cooldown.apocalypse.remains+20
    if I.AshvanesRazorCoral:IsReady() and (target.1.time_to_die < S.Apocalypse:CooldownRemainsP() + 20) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 431"; end
    end
    -- use_item,name=vision_of_demise,if=(cooldown.apocalypse.ready&debuff.festering_wound.stack>=4&essence.vision_of_perfection.enabled)|buff.unholy_frenzy.up|pet.gargoyle.active
    if I.VisionofDemise:IsReady() and ((S.Apocalypse:CooldownUpP() and Target:DebuffStackP(S.FesteringWoundDebuff) >= 4 and bool(essence.vision_of_perfection.enabled)) or Player:BuffP(S.UnholyFrenzyBuff) or bool(pet.gargoyle.active)) then
      if HR.CastSuggested(I.VisionofDemise) then return "vision_of_demise 435"; end
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine,if=cooldown.apocalypse.remains<2|talent.army_of_the_damned.enabled|raid_event.adds.in<5
    if I.RampingAmplitudeGigavoltEngine:IsReady() and (S.Apocalypse:CooldownRemainsP() < 2 or S.ArmyoftheDamned:IsAvailable() or 10000000000 < 5) then
      if HR.CastSuggested(I.RampingAmplitudeGigavoltEngine) then return "ramping_amplitude_gigavolt_engine 443"; end
    end
    -- use_item,name=bygone_bee_almanac,if=cooldown.summon_gargoyle.remains>60|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.BygoneBeeAlmanac:IsReady() and (S.SummonGargoyle:CooldownRemainsP() > 60 or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
      if HR.CastSuggested(I.BygoneBeeAlmanac) then return "bygone_bee_almanac 449"; end
    end
    -- use_item,name=jes_howler,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.JesHowler:IsReady() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
      if HR.CastSuggested(I.JesHowler) then return "jes_howler 457"; end
    end
    -- use_item,name=galecallers_beak,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.GalecallersBeak:IsReady() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
      if HR.CastSuggested(I.GalecallersBeak) then return "galecallers_beak 463"; end
    end
    -- use_item,name=grongs_primal_rage,if=rune<=3&(time>20|!equipped.ramping_amplitude_gigavolt_engine)
    if I.GrongsPrimalRage:IsReady() and (Player:Rune() <= 3 and (HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped())) then
      if HR.CastSuggested(I.GrongsPrimalRage) then return "grongs_primal_rage 469"; end
    end
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and (S.ArmyoftheDead:CooldownUpP() or bool(pet.gargoyle.active) or Player:BuffP(S.UnholyFrenzyBuff)) then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 473"; end
    end
    -- outbreak,target_if=dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsCastableP() then
      if HR.CastCycle(S.Outbreak, 30, EvaluateCycleOutbreak483) then return "outbreak 487" end
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
      return Aoe();
    end
    -- call_action_list,name=generic
    if (true) then
      local ShouldReturn = Generic(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(252, APL)
