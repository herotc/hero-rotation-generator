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
if not Spell.DemonHunter then Spell.DemonHunter = {} end
Spell.DemonHunter.Havoc = {
  Metamorphosis                         = Spell(191427),
  DemonReborn                           = Spell(193897),
  Demonic                               = Spell(213410),
  MetamorphosisBuff                     = Spell(162264),
  Nemesis                               = Spell(206491),
  NemesisDebuff                         = Spell(206491),
  ChaosBladesBuff                       = Spell(247938),
  ChaosBlades                           = Spell(247938),
  PickUpFragment                        = Spell(),
  EyeBeam                               = Spell(198013),
  VengefulRetreat                       = Spell(198793),
  Prepared                              = Spell(203551),
  Momentum                              = Spell(206476),
  PreparedBuff                          = Spell(203650),
  MomentumBuff                          = Spell(208628),
  FelRush                               = Spell(195072),
  FelMastery                            = Spell(192939),
  ThrowGlaive                           = Spell(185123),
  Bloodlet                              = Spell(206473),
  DeathSweep                            = Spell(210152),
  FelEruption                           = Spell(211881),
  FuryoftheIllidari                     = Spell(201467),
  BladeDance                            = Spell(188499),
  MasteroftheGlaive                     = Spell(203556),
  Felblade                              = Spell(232893),
  Annihilation                          = Spell(201427),
  ChaosStrike                           = Spell(162794),
  DemonBlades                           = Spell(203555),
  DemonsBite                            = Spell(162243),
  OutofRangeBuff                        = Spell(),
  DemonicAppetite                       = Spell(206478),
  FelBarrage                            = Spell(211053),
  BlindFury                             = Spell(203550),
  FirstBlood                            = Spell(206416),
  ChaosCleave                           = Spell(206475),
  ConsumeMagic                          = Spell(183752)
};
local S = Spell.DemonHunter.Havoc;

-- Items
if not Item.DemonHunter then Item.DemonHunter = {} end
Item.DemonHunter.Havoc = {
  ProlongedPower                   = Item(142117)
};
local I = Item.DemonHunter.Havoc;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.DemonHunter.Commons,
  Havoc = AR.GUISettings.APL.DemonHunter.Havoc
};

-- Variables
local VarPoolingForMeta = 0;
local VarWaitingForNemesis = 0;
local VarWaitingForChaosBlades = 0;
local VarBladeDance = 0;
local VarPoolingForBladeDance = 0;
local VarPoolingForChaosStrike = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function IsInMeleeRange()
  if S.Felblade:TimeSinceLastCast() <= Player:GCD() then
    return true
  elseif S.VengefulRetreat:TimeSinceLastCast() < 1.0 then
    return false
  end
  return Target:IsInRange("Melee")
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Precombat()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- metamorphosis,if=!(talent.demon_reborn.enabled&talent.demonic.enabled)
    if S.Metamorphosis:IsCastableP() and (not (S.DemonReborn:IsAvailable() and S.Demonic:IsAvailable())) then
      if AR.Cast(S.Metamorphosis) then return ""; end
    end
  end
  local function Cooldown()
    -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis|variable.waiting_for_chaos_blades)|target.time_to_die<25
    if S.Metamorphosis:IsCastableP() and (not (S.Demonic:IsAvailable() or bool(VarPoolingForMeta) or bool(VarWaitingForNemesis) or bool(VarWaitingForChaosBlades)) or Target:TimeToDie() < 25) then
      if AR.Cast(S.Metamorphosis) then return ""; end
    end
    -- metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up&fury<40
    if S.Metamorphosis:IsCastableP() and (S.Demonic:IsAvailable() and Player:BuffP(S.MetamorphosisBuff) and Player:Fury() < 40) then
      if AR.Cast(S.Metamorphosis) then return ""; end
    end
    -- nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
    if S.Nemesis:IsCastableP() and (bool(raid_event.adds.exists) and Target:DebuffDownP(S.NemesisDebuff) and (Cache.EnemiesCount[40] > desired_targets or raid_event.adds.in > 60)) then
      if AR.Cast(S.Nemesis) then return ""; end
    end
    -- nemesis,if=!raid_event.adds.exists&(buff.chaos_blades.up|buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains<20|target.time_to_die<=60)
    if S.Nemesis:IsCastableP() and (not bool(raid_event.adds.exists) and (Player:BuffP(S.ChaosBladesBuff) or Player:BuffP(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains < 20 or Target:TimeToDie() <= 60)) then
      if AR.Cast(S.Nemesis) then return ""; end
    end
    -- chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains>60|target.time_to_die<=duration
    if S.ChaosBlades:IsCastableP() and (Player:BuffP(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains > 60 or Target:TimeToDie() <= S.ChaosBlades:BaseDuration()) then
      if AR.Cast(S.ChaosBlades) then return ""; end
    end
    -- potion,if=buff.metamorphosis.remains>25|target.time_to_die<30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffRemainsP(S.MetamorphosisBuff) > 25 or Target:TimeToDie() < 30) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Demonic()
    -- pick_up_fragment,if=fury.deficit>=35&(cooldown.eye_beam.remains>5|buff.metamorphosis.up)
    if S.PickUpFragment:IsCastableP() and (Player:FuryDeficit() >= 35 and (S.EyeBeam:CooldownRemainsP() > 5 or Player:BuffP(S.MetamorphosisBuff))) then
      if AR.Cast(S.PickUpFragment) then return ""; end
    end
    -- vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
    if S.VengefulRetreat:IsCastableP() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDownP(S.PreparedBuff) and Player:BuffDownP(S.MomentumBuff)) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastableP() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDownP(S.MomentumBuff)) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- death_sweep,if=variable.blade_dance
    if S.DeathSweep:IsCastableP() and (bool(VarBladeDance)) then
      if AR.Cast(S.DeathSweep) then return ""; end
    end
    -- fel_eruption
    if S.FelEruption:IsCastableP() and (true) then
      if AR.Cast(S.FelEruption) then return ""; end
    end
    -- fury_of_the_illidari,if=(active_enemies>desired_targets)|(raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up))
    if S.FuryoftheIllidari:IsCastableP() and ((Cache.EnemiesCount[40] > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)))) then
      if AR.Cast(S.FuryoftheIllidari) then return ""; end
    end
    -- blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
    if S.BladeDance:IsCastableP() and (bool(VarBladeDance) and S.EyeBeam:CooldownRemainsP() > 5 and not S.Metamorphosis:CooldownUpP()) then
      if AR.Cast(S.BladeDance) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and Cache.EnemiesCount[30] >= 2 and (not S.MasteroftheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (Cache.EnemiesCount[30] >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown())) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury.deficit>=30&(fury<40|buff.metamorphosis.down)
    if S.Felblade:IsCastableP() and (Player:FuryDeficit() >= 30 and (Player:Fury() < 40 or Player:BuffDownP(S.MetamorphosisBuff))) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- eye_beam,if=spell_targets.eye_beam_tick>desired_targets|!buff.metamorphosis.extended_by_demonic|(set_bonus.tier21_4pc&buff.metamorphosis.remains>16)
    if S.EyeBeam:IsCastableP() and (Cache.EnemiesCount[20] > desired_targets or not bool(buff.metamorphosis.extended_by_demonic) or (AC.Tier21_4Pc and Player:BuffRemainsP(S.MetamorphosisBuff) > 16)) then
      if AR.Cast(S.EyeBeam) then return ""; end
    end
    -- annihilation,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
    if S.Annihilation:IsCastableP() and IsInMeleeRange() and ((not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(VarPoolingForBladeDance)) then
      if AR.Cast(S.Annihilation) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and (not S.MasteroftheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- chaos_strike,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
    if S.ChaosStrike:IsCastableP() and IsInMeleeRange() and ((not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8) and not bool(VarPoolingForChaosStrike) and not bool(VarPoolingForMeta) and not bool(VarPoolingForBladeDance)) then
      if AR.Cast(S.ChaosStrike) then return ""; end
    end
    -- fel_rush,if=!talent.momentum.enabled&!cooldown.eye_beam.ready&(buff.metamorphosis.down|talent.demon_blades.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastableP() and (not S.Momentum:IsAvailable() and not S.EyeBeam:CooldownUpP() and (Player:BuffDownP(S.MetamorphosisBuff) or S.DemonBlades:IsAvailable()) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- demons_bite
    if S.DemonsBite:IsCastableP() and IsInMeleeRange() and (true) then
      if AR.Cast(S.DemonsBite) then return ""; end
    end
    -- throw_glaive,if=buff.out_of_range.up|!talent.bloodlet.enabled
    if S.ThrowGlaive:IsCastableP() and (Player:BuffP(S.OutofRangeBuff) or not S.Bloodlet:IsAvailable()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    if S.FelRush:IsCastableP() and (movement.distance > 15 or (Player:BuffP(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- vengeful_retreat,if=movement.distance>15
    if S.VengefulRetreat:IsCastableP() and (movement.distance > 15) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
  end
  local function Normal()
    -- pick_up_fragment,if=talent.demonic_appetite.enabled&fury.deficit>=35
    if S.PickUpFragment:IsCastableP() and (S.DemonicAppetite:IsAvailable() and Player:FuryDeficit() >= 35) then
      if AR.Cast(S.PickUpFragment) then return ""; end
    end
    -- vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
    if S.VengefulRetreat:IsCastableP() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDownP(S.PreparedBuff) and Player:BuffDownP(S.MomentumBuff)) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastableP() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDownP(S.MomentumBuff)) and (not S.FelMastery:IsAvailable() or Player:FuryDeficit() >= 25) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- fel_barrage,if=(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
    if S.FelBarrage:IsCastableP() and ((Player:BuffP(S.MomentumBuff) or not S.Momentum:IsAvailable()) and (Cache.EnemiesCount[30] > desired_targets or raid_event.adds.in > 30)) then
      if AR.Cast(S.FelBarrage) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury<15&(cooldown.death_sweep.remains<2*gcd|cooldown.blade_dance.remains<2*gcd)
    if S.Felblade:IsCastableP() and (Player:Fury() < 15 and (S.DeathSweep:CooldownRemainsP() < 2 * Player:GCD() or S.BladeDance:CooldownRemainsP() < 2 * Player:GCD())) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- death_sweep,if=variable.blade_dance
    if S.DeathSweep:IsCastableP() and (bool(VarBladeDance)) then
      if AR.Cast(S.DeathSweep) then return ""; end
    end
    -- fel_rush,if=charges=2&!talent.momentum.enabled&!talent.fel_mastery.enabled&!buff.metamorphosis.up
    if S.FelRush:IsCastableP() and (S.FelRush:ChargesP() == 2 and not S.Momentum:IsAvailable() and not S.FelMastery:IsAvailable() and not Player:BuffP(S.MetamorphosisBuff)) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- fel_eruption
    if S.FelEruption:IsCastableP() and (true) then
      if AR.Cast(S.FelEruption) then return ""; end
    end
    -- fury_of_the_illidari,if=(active_enemies>desired_targets)|(raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)&(!talent.chaos_blades.enabled|buff.chaos_blades.up|cooldown.chaos_blades.remains>30|target.time_to_die<cooldown.chaos_blades.remains))
    if S.FuryoftheIllidari:IsCastableP() and ((Cache.EnemiesCount[40] > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (not S.ChaosBlades:IsAvailable() or Player:BuffP(S.ChaosBladesBuff) or S.ChaosBlades:CooldownRemainsP() > 30 or Target:TimeToDie() < S.ChaosBlades:CooldownRemainsP()))) then
      if AR.Cast(S.FuryoftheIllidari) then return ""; end
    end
    -- blade_dance,if=variable.blade_dance
    if S.BladeDance:IsCastableP() and (bool(VarBladeDance)) then
      if AR.Cast(S.BladeDance) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and Cache.EnemiesCount[30] >= 2 and (not S.MasteroftheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (Cache.EnemiesCount[30] >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown())) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury.deficit>=30+buff.prepared.up*8
    if S.Felblade:IsCastableP() and (Player:FuryDeficit() >= 30 + num(Player:BuffP(S.PreparedBuff)) * 8) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- eye_beam,if=spell_targets.eye_beam_tick>desired_targets|(spell_targets.eye_beam_tick>=3&raid_event.adds.in>cooldown)|(talent.blind_fury.enabled&fury.deficit>=35)|set_bonus.tier21_2pc
    if S.EyeBeam:IsCastableP() and (Cache.EnemiesCount[20] > desired_targets or (Cache.EnemiesCount[20] >= 3 and raid_event.adds.in > S.EyeBeam:Cooldown()) or (S.BlindFury:IsAvailable() and Player:FuryDeficit() >= 35) or AC.Tier21_2Pc) then
      if AR.Cast(S.EyeBeam) then return ""; end
    end
    -- annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
    if S.Annihilation:IsCastableP() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(VarPoolingForBladeDance)) then
      if AR.Cast(S.Annihilation) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
    if S.ThrowGlaive:IsCastableP() and (S.Bloodlet:IsAvailable() and (not S.MasteroftheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- throw_glaive,if=!talent.bloodlet.enabled&buff.metamorphosis.down&spell_targets>=3
    if S.ThrowGlaive:IsCastableP() and (not S.Bloodlet:IsAvailable() and Player:BuffDownP(S.MetamorphosisBuff) and Cache.EnemiesCount[30] >= 3) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
    if S.ChaosStrike:IsCastableP() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8) and not bool(VarPoolingForChaosStrike) and not bool(VarPoolingForMeta) and not bool(VarPoolingForBladeDance)) then
      if AR.Cast(S.ChaosStrike) then return ""; end
    end
    -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&(talent.demon_blades.enabled|buff.metamorphosis.down)
    if S.FelRush:IsCastableP() and (not S.Momentum:IsAvailable() and raid_event.movement.in > S.FelRush:ChargesP() * 10 and (S.DemonBlades:IsAvailable() or Player:BuffDownP(S.MetamorphosisBuff))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- demons_bite
    if S.DemonsBite:IsCastableP() and IsInMeleeRange() and (true) then
      if AR.Cast(S.DemonsBite) then return ""; end
    end
    -- throw_glaive,if=buff.out_of_range.up
    if S.ThrowGlaive:IsCastableP() and (Player:BuffP(S.OutofRangeBuff)) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=movement.distance>15|buff.out_of_range.up
    if S.Felblade:IsCastableP() and (movement.distance > 15 or Player:BuffP(S.OutofRangeBuff)) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    if S.FelRush:IsCastableP() and (movement.distance > 15 or (Player:BuffP(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- vengeful_retreat,if=movement.distance>15
    if S.VengefulRetreat:IsCastableP() and (movement.distance > 15) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- throw_glaive,if=!talent.bloodlet.enabled
    if S.ThrowGlaive:IsCastableP() and (not S.Bloodlet:IsAvailable()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
  if (true) then
    VarWaitingForNemesis = num(not (not S.Nemesis:IsAvailable() or S.Nemesis:CooldownUpP() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60))
  end
  -- variable,name=waiting_for_chaos_blades,value=!(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready|cooldown.chaos_blades.remains>target.time_to_die|cooldown.chaos_blades.remains>60)
  if (true) then
    VarWaitingForChaosBlades = num(not (not S.ChaosBlades:IsAvailable() or S.ChaosBlades:CooldownUpP() or S.ChaosBlades:CooldownRemainsP() > Target:TimeToDie() or S.ChaosBlades:CooldownRemainsP() > 60))
  end
  -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)&(!variable.waiting_for_chaos_blades|cooldown.chaos_blades.remains<6)
  if (true) then
    VarPoolingForMeta = num(not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not bool(VarWaitingForNemesis) or S.Nemesis:CooldownRemainsP() < 10) and (not bool(VarWaitingForChaosBlades) or S.ChaosBlades:CooldownRemainsP() < 6))
  end
  -- variable,name=blade_dance,value=talent.first_blood.enabled|set_bonus.tier20_4pc|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*3)
  if (true) then
    VarBladeDance = num(S.FirstBlood:IsAvailable() or AC.Tier20_4Pc or Cache.EnemiesCount[8] >= 3 + (num(S.ChaosCleave:IsAvailable()) * 3))
  end
  -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
  if (true) then
    VarPoolingForBladeDance = num(bool(VarBladeDance) and (Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20))
  end
  -- variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
  if (true) then
    VarPoolingForChaosStrike = num(S.ChaosCleave:IsAvailable() and Player:FuryDeficit() > 40 and not bool(raid_event.adds.up) and raid_event.adds.in < 2 * Player:GCD())
  end
  -- consume_magic
  if S.ConsumeMagic:IsCastableP() and (true) then
    if AR.Cast(S.ConsumeMagic) then return ""; end
  end
  -- call_action_list,name=cooldown,if=gcd.remains=0
  if (Player:GCDRemains() == 0) then
    local ShouldReturn = Cooldown(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=demonic,if=talent.demonic.enabled
  if (S.Demonic:IsAvailable()) then
    return Demonic();
  end
  -- run_action_list,name=normal
  if (true) then
    return Normal();
  end
end