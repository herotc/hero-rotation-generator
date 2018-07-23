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
  DeathandDecay                         = Spell(43265),
  Apocalypse                            = Spell(275699),
  Defile                                = Spell(152280),
  Epidemic                              = Spell(207317),
  DeathCoil                             = Spell(47541),
  ScourgeStrike                         = Spell(55090),
  ClawingShadows                        = Spell(207311),
  FesteringStrike                       = Spell(85948),
  BurstingSores                         = Spell(),
  FesteringWoundDebuff                  = Spell(194310),
  SuddenDoomBuff                        = Spell(81340),
  ChainsofIce                           = Spell(45524),
  UnholyStrengthBuff                    = Spell(53365),
  ColdHeartItemBuff                     = Spell(235599),
  MasterofGhoulsBuff                    = Spell(246995),
  DarkTransformation                    = Spell(63560),
  SummonGargoyle                        = Spell(49206),
  UnholyFrenzy                          = Spell(207289),
  UnholyFrenzyBuff                      = Spell(),
  SoulReaper                            = Spell(130736),
  UnholyBlight                          = Spell(115989),
  Pestilence                            = Spell(277234),
  MindFreeze                            = Spell(47528),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  UseItems                              = Spell(),
  TemptationBuff                        = Spell(234143),
  Outbreak                              = Spell(77575),
  AoeBuff                               = Spell()
};
local S = Spell.DeathKnight.Unholy;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  ProlongedPower                   = Item(142117),
  ColdHeart                        = Item(151796),
  Item137075                       = Item(137075),
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
local VarPoolingForGargoyle = 0;

local EnemyRanges = {5, 30}
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
      if HR.Cast(S.ArmyoftheDead, Settings.Unholy.GCDasOffGCD.ArmyoftheDead) then return ""; end
    end
  end
  local function Aoe()
    -- death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.DeathandDecay) then return ""; end
    end
    -- defile
    if S.Defile:IsCastableP() and (true) then
      if HR.Cast(S.Defile) then return ""; end
    end
    -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.Epidemic:IsUsableP() and (bool(death_and_decay.ticking) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return ""; end
    end
    -- death_coil,if=death_and_decay.ticking&rune<2&!talent.epidemic.enabled&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (bool(death_and_decay.ticking) and Player:Rune() < 2 and not S.Epidemic:IsAvailable() and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
    -- epidemic,if=!variable.pooling_for_gargoyle
    if S.Epidemic:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return ""; end
    end
    -- festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
    if S.FesteringStrike:IsCastableP() and (S.BurstingSores:IsAvailable() and Cache.EnemiesCount[5] >= 2 and Target:DebuffStackP(S.FesteringWoundDebuff) <= 1) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- death_coil,if=buff.sudden_doom.react&rune.deficit>=4
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:RuneDeficit() >= 4) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
  end
  local function ColdHeart()
    -- chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart_item.stack>16
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Player:BuffStackP(S.ColdHeartItemBuff) > 16) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart_item.stack>17
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.MasterofGhoulsBuff) < Player:GCD() and Player:BuffP(S.MasterofGhoulsBuff) and Player:BuffStackP(S.ColdHeartItemBuff) > 17) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.cold_heart_item.stack=20&buff.unholy_strength.react
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartItemBuff) == 20 and bool(Player:BuffStackP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
  end
  local function Cooldowns()
    -- call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
    if (I.ColdHeart:IsEquipped() and Player:BuffStackP(S.ColdHeartItemBuff) > 10) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() and (true) then
      if HR.Cast(S.ArmyoftheDead, Settings.Unholy.GCDasOffGCD.ArmyoftheDead) then return ""; end
    end
    -- apocalypse,if=debuff.festering_wound.stack>=4
    if S.Apocalypse:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 4) then
      if HR.Cast(S.Apocalypse) then return ""; end
    end
    -- dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
    if S.DarkTransformation:IsCastableP() and ((I.Item137075:IsEquipped() and S.SummonGargoyle:CooldownRemainsP() > 40) or (not I.Item137075:IsEquipped() or not S.SummonGargoyle:IsAvailable())) then
      if HR.Cast(S.DarkTransformation) then return ""; end
    end
    -- summon_gargoyle,if=runic_power.deficit<14
    if S.SummonGargoyle:IsCastableP() and (Player:RunicPowerDeficit() < 14) then
      if HR.Cast(S.SummonGargoyle) then return ""; end
    end
    -- unholy_frenzy,if=debuff.festering_wound.stack<4
    if S.UnholyFrenzy:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 4) then
      if HR.Cast(S.UnholyFrenzy) then return ""; end
    end
    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if S.UnholyFrenzy:IsCastableP() and (Cache.EnemiesCount[30] >= 2 and ((S.DeathandDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
      if HR.Cast(S.UnholyFrenzy) then return ""; end
    end
    -- soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
    if S.SoulReaper:IsCastableP() and (true) then
      if HR.Cast(S.SoulReaper) then return ""; end
    end
    -- unholy_blight
    if S.UnholyBlight:IsCastableP() and (true) then
      if HR.Cast(S.UnholyBlight) then return ""; end
    end
  end
  local function Generic()
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(pet.gargoyle.active)) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (S.Pestilence:IsAvailable() and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.DeathandDecay) then return ""; end
    end
    -- defile,if=cooldown.apocalypse.remains
    if S.Defile:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.Defile) then return ""; end
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ScourgeStrike) then return ""; end
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ClawingShadows) then return ""; end
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return ""; end
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsCastableP() and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.FesteringStrike) then return ""; end
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return ""; end
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
  -- variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
  if (true) then
    VarPoolingForGargoyle = num((S.SummonGargoyle:CooldownRemainsP() < 5 and (S.DarkTransformation:CooldownRemainsP() < 5 or not I.Item137075:IsEquipped())) and S.SummonGargoyle:IsAvailable())
  end
  -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
  if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 65 and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) and Player:RuneDeficit() >= 5) then
    if HR.Cast(S.ArcaneTorrent, Settings.Unholy.GCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  if S.BloodFury:IsCastableP() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
    if HR.Cast(S.BloodFury, Settings.Unholy.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  if S.Berserking:IsCastableP() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
    if HR.Cast(S.Berserking, Settings.Unholy.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if HR.Cast(S.UseItems) then return ""; end
  end
  -- use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  if I.FeloiledInfernalMachine:IsReady() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
    if HR.CastSuggested(I.FeloiledInfernalMachine) then return ""; end
  end
  -- use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
  if I.RingofCollapsingFutures:IsReady() and ((Player:BuffStackP(S.TemptationBuff) == 0 and Target:TimeToDie() > 60) or Target:TimeToDie() < 60) then
    if HR.CastSuggested(I.RingofCollapsingFutures) then return ""; end
  end
  -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.ArmyoftheDead:CooldownUpP() or bool(pet.gargoyle.active) or Player:BuffP(S.UnholyFrenzyBuff)) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
  if S.Outbreak:IsCastableP() and (true) then
    if HR.Cast(S.Outbreak) then return ""; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=aoe,if=active_enemies>=2
  if (Cache.EnemiesCount[30] >= 2) then
    local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=generic
  if (true) then
    local ShouldReturn = Generic(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(252, APL)
