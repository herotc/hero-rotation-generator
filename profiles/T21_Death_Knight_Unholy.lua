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
  RaiseDead                             = Spell(),
  ArmyoftheDead                         = Spell(42650),
  BlightedRuneWeapon                    = Spell(194918),
  DeathandDecay                         = Spell(43265),
  Epidemic                              = Spell(207317),
  ScourgeStrike                         = Spell(55090),
  ClawingShadows                        = Spell(207311),
  ChainsofIce                           = Spell(45524),
  UnholyStrengthBuff                    = Spell(53365),
  ColdHeartBuff                         = Spell(235599),
  MasterofGhoulsBuff                    = Spell(246995),
  SoulReaperDebuff                      = Spell(130736),
  Apocalypse                            = Spell(220143),
  FesteringWoundDebuff                  = Spell(194310),
  DarkArbiter                           = Spell(207349),
  DarkTransformation                    = Spell(63560),
  SummonGargoyle                        = Spell(49206),
  SoulReaper                            = Spell(130736),
  ShadowInfusion                        = Spell(198943),
  DeathCoil                             = Spell(47541),
  NecrosisBuff                          = Spell(216974),
  SuddenDoomBuff                        = Spell(81340),
  FesteringStrike                       = Spell(85948),
  Defile                                = Spell(152280),
  BlightedRuneWeaponBuff                = Spell(194918),
  Castigator                            = Spell(207305),
  Necrosis                              = Spell(207346),
  MindFreeze                            = Spell(47528),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  UseItems                              = Spell(),
  TemptationBuff                        = Spell(234143),
  Outbreak                              = Spell(77575)
};
local S = Spell.DeathKnight.Unholy;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  ProlongedPower                   = Item(142117),
  ColdHeart                        = Item(151796),
  Item137075                       = Item(137075),
  Item140806                       = Item(140806),
  Item132448                       = Item(132448),
  FeloiledInfernalMachine          = Item(144482),
  RingofCollapsingFutures          = Item(142173)
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

local EnemyRanges = {8, 10, 30}
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
  UpdateRanges()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- raise_dead
    if S.RaiseDead:IsCastableP() and (true) then
      if HR.Cast(S.RaiseDead) then return ""; end
    end
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() and (true) then
      if HR.Cast(S.ArmyoftheDead) then return ""; end
    end
    -- blighted_rune_weapon
    if S.BlightedRuneWeapon:IsCastableP() and Player:BuffDownP(S.BlightedRuneWeapon) and (true) then
      if HR.Cast(S.BlightedRuneWeapon) then return ""; end
    end
  end
  local function Aoe()
    -- death_and_decay,if=spell_targets.death_and_decay>=2
    if S.DeathandDecay:IsUsableP() and (Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.DeathandDecay) then return ""; end
    end
    -- epidemic,if=spell_targets.epidemic>4
    if S.Epidemic:IsCastableP() and (Cache.EnemiesCount[10] > 4) then
      if HR.Cast(S.Epidemic) then return ""; end
    end
    -- scourge_strike,if=spell_targets.scourge_strike>=2&(death_and_decay.ticking|defile.ticking)
    if S.ScourgeStrike:IsCastableP() and (Cache.EnemiesCount[8] >= 2 and (bool(death_and_decay.ticking) or bool(defile.ticking))) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=spell_targets.clawing_shadows>=2&(death_and_decay.ticking|defile.ticking)
    if S.ClawingShadows:IsCastableP() and (Cache.EnemiesCount[8] >= 2 and (bool(death_and_decay.ticking) or bool(defile.ticking))) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
    -- epidemic,if=spell_targets.epidemic>2
    if S.Epidemic:IsCastableP() and (Cache.EnemiesCount[10] > 2) then
      if HR.Cast(S.Epidemic) then return ""; end
    end
  end
  local function ColdHeart()
    -- chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart.stack>16
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Player:BuffStackP(S.ColdHeartBuff) > 16) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart.stack>17
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.MasterofGhoulsBuff) < Player:GCD() and Player:BuffP(S.MasterofGhoulsBuff) and Player:BuffStackP(S.ColdHeartBuff) > 17) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) == 20 and bool(Player:BuffStackP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
  end
  local function Cooldowns()
    -- call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart.stack>10&!debuff.soul_reaper.up
    if (I.ColdHeart:IsEquipped() and Player:BuffStackP(S.ColdHeartBuff) > 10 and not Target:DebuffP(S.SoulReaperDebuff)) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() and (true) then
      if HR.Cast(S.ArmyoftheDead) then return ""; end
    end
    -- apocalypse,if=debuff.festering_wound.stack>=6
    if S.Apocalypse:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 6) then
      if HR.Cast(S.Apocalypse) then return ""; end
    end
    -- dark_arbiter,if=(!equipped.137075|cooldown.dark_transformation.remains<2)&runic_power.deficit<30
    if S.DarkArbiter:IsCastableP() and ((not I.Item137075:IsEquipped() or S.DarkTransformation:CooldownRemainsP() < 2) and Player:RunicPowerDeficit() < 30) then
      if HR.Cast(S.DarkArbiter) then return ""; end
    end
    -- summon_gargoyle,if=(!equipped.137075|cooldown.dark_transformation.remains<10)&rune.time_to_4>=gcd
    if S.SummonGargoyle:IsCastableP() and ((not I.Item137075:IsEquipped() or S.DarkTransformation:CooldownRemainsP() < 10) and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.SummonGargoyle) then return ""; end
    end
    -- soul_reaper,if=(debuff.festering_wound.stack>=6&cooldown.apocalypse.remains<=gcd)|(debuff.festering_wound.stack>=3&rune>=3&cooldown.apocalypse.remains>20)
    if S.SoulReaper:IsCastableP() and ((Target:DebuffStackP(S.FesteringWoundDebuff) >= 6 and S.Apocalypse:CooldownRemainsP() <= Player:GCD()) or (Target:DebuffStackP(S.FesteringWoundDebuff) >= 3 and Player:Rune() >= 3 and S.Apocalypse:CooldownRemainsP() > 20)) then
      if HR.Cast(S.SoulReaper) then return ""; end
    end
    -- call_action_list,name=dt,if=cooldown.dark_transformation.ready
    if (S.DarkTransformation:CooldownUpP()) then
      local ShouldReturn = Dt(); if ShouldReturn then return ShouldReturn; end
    end
  end
  local function Dt()
    -- dark_transformation,if=equipped.137075&talent.dark_arbiter.enabled&(talent.shadow_infusion.enabled|cooldown.dark_arbiter.remains>52)&cooldown.dark_arbiter.remains>30&!equipped.140806
    if S.DarkTransformation:IsCastableP() and (I.Item137075:IsEquipped() and S.DarkArbiter:IsAvailable() and (S.ShadowInfusion:IsAvailable() or S.DarkArbiter:CooldownRemainsP() > 52) and S.DarkArbiter:CooldownRemainsP() > 30 and not I.Item140806:IsEquipped()) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- dark_transformation,if=equipped.137075&(talent.shadow_infusion.enabled|cooldown.dark_arbiter.remains>(52*1.333))&equipped.140806&cooldown.dark_arbiter.remains>(30*1.333)
    if S.DarkTransformation:IsCastableP() and (I.Item137075:IsEquipped() and (S.ShadowInfusion:IsAvailable() or S.DarkArbiter:CooldownRemainsP() > (52 * 1.333)) and I.Item140806:IsEquipped() and S.DarkArbiter:CooldownRemainsP() > (30 * 1.333)) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- dark_transformation,if=equipped.137075&target.time_to_die<cooldown.dark_arbiter.remains-8
    if S.DarkTransformation:IsCastableP() and (I.Item137075:IsEquipped() and Target:TimeToDie() < S.DarkArbiter:CooldownRemainsP() - 8) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- dark_transformation,if=equipped.137075&(talent.shadow_infusion.enabled|cooldown.summon_gargoyle.remains>55)&cooldown.summon_gargoyle.remains>35
    if S.DarkTransformation:IsCastableP() and (I.Item137075:IsEquipped() and (S.ShadowInfusion:IsAvailable() or S.SummonGargoyle:CooldownRemainsP() > 55) and S.SummonGargoyle:CooldownRemainsP() > 35) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- dark_transformation,if=equipped.137075&target.time_to_die<cooldown.summon_gargoyle.remains-8
    if S.DarkTransformation:IsCastableP() and (I.Item137075:IsEquipped() and Target:TimeToDie() < S.SummonGargoyle:CooldownRemainsP() - 8) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- dark_transformation,if=!equipped.137075&rune.time_to_4>=gcd
    if S.DarkTransformation:IsCastableP() and (not I.Item137075:IsEquipped() and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
  end
  local function Generic()
    -- scourge_strike,if=debuff.soul_reaper.up&debuff.festering_wound.up
    if S.ScourgeStrike:IsCastableP() and (Target:DebuffP(S.SoulReaperDebuff) and Target:DebuffP(S.FesteringWoundDebuff)) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=debuff.soul_reaper.up&debuff.festering_wound.up
    if S.ClawingShadows:IsCastableP() and (Target:DebuffP(S.SoulReaperDebuff) and Target:DebuffP(S.FesteringWoundDebuff)) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
    -- death_coil,if=runic_power.deficit<22&(talent.shadow_infusion.enabled|(!talent.dark_arbiter.enabled|cooldown.dark_arbiter.remains>5))
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 22 and (S.ShadowInfusion:IsAvailable() or (not S.DarkArbiter:IsAvailable() or S.DarkArbiter:CooldownRemainsP() > 5))) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- death_coil,if=!buff.necrosis.up&buff.sudden_doom.react&((!talent.dark_arbiter.enabled&rune<=3)|cooldown.dark_arbiter.remains>5)
    if S.DeathCoil:IsUsableP() and (not Player:BuffP(S.NecrosisBuff) and bool(Player:BuffStackP(S.SuddenDoomBuff)) and ((not S.DarkArbiter:IsAvailable() and Player:Rune() <= 3) or S.DarkArbiter:CooldownRemainsP() > 5)) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- festering_strike,if=debuff.festering_wound.stack<6&cooldown.apocalypse.remains<=6
    if S.FesteringStrike:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 6 and S.Apocalypse:CooldownRemainsP() <= 6) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- defile
    if S.Defile:IsCastableP() and (true) then
      if HR.Cast(S.Defile) then return ""; end
    end
    -- call_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    -- festering_strike,if=(buff.blighted_rune_weapon.stack*2+debuff.festering_wound.stack)<=2|((buff.blighted_rune_weapon.stack*2+debuff.festering_wound.stack)<=4&talent.castigator.enabled)&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
    if S.FesteringStrike:IsCastableP() and ((Player:BuffStackP(S.BlightedRuneWeaponBuff) * 2 + Target:DebuffStackP(S.FesteringWoundDebuff)) <= 2 or ((Player:BuffStackP(S.BlightedRuneWeaponBuff) * 2 + Target:DebuffStackP(S.FesteringWoundDebuff)) <= 4 and S.Castigator:IsAvailable()) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or Player:RuneTimeToX(4) <= Player:GCD())) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune.time_to_4>=gcd
    if S.DeathCoil:IsUsableP() and (not Player:BuffP(S.NecrosisBuff) and S.Necrosis:IsAvailable() and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- scourge_strike,if=(buff.necrosis.up|buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&(debuff.festering_wound.stack>=3|!(talent.castigator.enabled|equipped.132448))&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
    if S.ScourgeStrike:IsCastableP() and ((Player:BuffP(S.NecrosisBuff) or bool(Player:BuffStackP(S.UnholyStrengthBuff)) or Player:Rune() >= 2) and Target:DebuffStackP(S.FesteringWoundDebuff) >= 1 and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 3 or not (S.Castigator:IsAvailable() or I.Item132448:IsEquipped())) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or Player:RuneTimeToX(4) <= Player:GCD())) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=(buff.necrosis.up|buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&(debuff.festering_wound.stack>=3|!equipped.132448)&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
    if S.ClawingShadows:IsCastableP() and ((Player:BuffP(S.NecrosisBuff) or bool(Player:BuffStackP(S.UnholyStrengthBuff)) or Player:Rune() >= 2) and Target:DebuffStackP(S.FesteringWoundDebuff) >= 1 and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 3 or not I.Item132448:IsEquipped()) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or Player:RuneTimeToX(4) <= Player:GCD())) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
    -- death_coil,if=(talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>10)|!talent.dark_arbiter.enabled
    if S.DeathCoil:IsUsableP() and ((S.DarkArbiter:IsAvailable() and S.DarkArbiter:CooldownRemainsP() > 10) or not S.DarkArbiter:IsAvailable()) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
  end
  local function Valkyr()
    -- death_coil
    if S.DeathCoil:IsUsableP() and (true) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- festering_strike,if=debuff.festering_wound.stack<6&cooldown.apocalypse.remains<3
    if S.FesteringStrike:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 6 and S.Apocalypse:CooldownRemainsP() < 3) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- call_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    -- festering_strike,if=debuff.festering_wound.stack<=4
    if S.FesteringStrike:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) <= 4) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- scourge_strike,if=debuff.festering_wound.up
    if S.ScourgeStrike:IsCastableP() and (Target:DebuffP(S.FesteringWoundDebuff)) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=debuff.festering_wound.up
    if S.ClawingShadows:IsCastableP() and (Target:DebuffP(S.FesteringWoundDebuff)) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- mind_freeze
  if S.MindFreeze:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if HR.CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  -- arcane_torrent,if=runic_power.deficit>20&(pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled)
  if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:RunicPowerDeficit() > 20 and (bool(pet.valkyr_battlemaiden.active) or not S.DarkArbiter:IsAvailable())) then
    if HR.Cast(S.ArcaneTorrent, Settings.Unholy.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- blood_fury,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
  if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(pet.valkyr_battlemaiden.active) or not S.DarkArbiter:IsAvailable()) then
    if HR.Cast(S.BloodFury, Settings.Unholy.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
  if S.Berserking:IsCastableP() and HR.CDsON() and (bool(pet.valkyr_battlemaiden.active) or not S.DarkArbiter:IsAvailable()) then
    if HR.Cast(S.Berserking, Settings.Unholy.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if HR.Cast(S.UseItems) then return ""; end
  end
  -- use_item,name=feloiled_infernal_machine,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
  if I.FeloiledInfernalMachine:IsReady() and (bool(pet.valkyr_battlemaiden.active) or not S.DarkArbiter:IsAvailable()) then
    if HR.CastSuggested(I.FeloiledInfernalMachine) then return ""; end
  end
  -- use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
  if I.RingofCollapsingFutures:IsReady() and ((Player:BuffStackP(S.TemptationBuff) == 0 and Target:TimeToDie() > 60) or Target:TimeToDie() < 60) then
    if HR.CastSuggested(I.RingofCollapsingFutures) then return ""; end
  end
  -- potion,if=buff.unholy_strength.react
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(Player:BuffStackP(S.UnholyStrengthBuff))) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- blighted_rune_weapon,if=debuff.festering_wound.stack<=4
  if S.BlightedRuneWeapon:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) <= 4) then
    if HR.Cast(S.BlightedRuneWeapon) then return ""; end
  end
  -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
  if S.Outbreak:IsCastableP() and (true) then
    if HR.Cast(S.Outbreak) then return ""; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=valkyr,if=pet.valkyr_battlemaiden.active&talent.dark_arbiter.enabled
  if (bool(pet.valkyr_battlemaiden.active) and S.DarkArbiter:IsAvailable()) then
    return Valkyr();
  end
  -- call_action_list,name=generic
  if (true) then
    local ShouldReturn = Generic(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(252, APL)
