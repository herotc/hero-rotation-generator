--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC=AethysCore
local Cache=AethysCache
local Unit=AC.Unit
local Player=Unit.Player
local Target=Unit.Target
local Spell=AC.Spell
local Item=AC.Item
-- AethysRotation
local AR=AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.DemonHunter then Spell.DemonHunter={} end
Spell.DemonHunter.Havoc={
  Metamorphosis                 = Spell(),
  Demonic                       = Spell(),
  Nemesis                       = Spell(),
  ChaosBladesBuff               = Spell(),
  PickUpFragment                = Spell(),
  EyeBeam                       = Spell(),
  VengefulRetreat               = Spell(),
  Prepared                      = Spell(),
  Momentum                      = Spell(),
  FelRush                       = Spell(),
  FelMastery                    = Spell(),
  ThrowGlaive                   = Spell(),
  Bloodlet                      = Spell(),
  DeathSweep                    = Spell(),
  FelEruption                   = Spell(),
  FuryofTheIllidari             = Spell(),
  BladeDance                    = Spell(),
  MasterofTheGlaive             = Spell(),
  Felblade                      = Spell(),
  Annihilation                  = Spell(),
  ChaosStrike                   = Spell(),
  DemonBlades                   = Spell(),
  DemonsBite                    = Spell(),
  OutofRangeBuff                = Spell(),
  DemonicAppetite               = Spell(),
  FelBarrage                    = Spell(),
  BlindFury                     = Spell(),
  AutoAttack                    = Spell(),
  FirstBlood                    = Spell(),
  ChaosCleave                   = Spell(),
  ConsumeMagic                  = Spell(),
  -- Misc
  PoolEnergy                    = Spell(9999000010),
};
local S = Spell.DemonHunter.Havoc;

-- Items
if not Item.DemonHunter then Item.DemonHunter={} end
Item.DemonHunter.Havoc={
  ProlongedPower                = Item(),
};
local I = Item.DemonHunter.Havoc;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.DemonHunter.Commons,
  Havoc = AR.GUISettings.APL.DemonHunter.Havoc,
};

-- Variables
local WaitingForNemesis = 0;
local WaitingForChaosBlades = 0;
local PoolingForMeta = 0;
local BladeDance = 0;
local PoolingForBladeDance = 0;
local PoolingForChaosStrike = 0;

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
  local function Cooldown()
    -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis|variable.waiting_for_chaos_blades)|target.time_to_die<25
    if S.Metamorphosis:IsCastable() and (not (S.Demonic:IsAvailable() or bool(PoolingForMeta) or bool(WaitingForNemesis) or bool(WaitingForChaosBlades)) or Target:TimeToDie() < 25) then
      if AR.Cast(S.Metamorphosis) then return ""; end
    end
    -- metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up&fury<40
    if S.Metamorphosis:IsCastable() and (S.Demonic:IsAvailable() and Player:BuffP(S.MetamorphosisBuff) and Player:Fury() < 40) then
      if AR.Cast(S.Metamorphosis) then return ""; end
    end
    -- nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
    if S.Nemesis:IsCastable() and (bool(raid_event.adds.exists) and Target:DebuffDownP(S.NemesisDebuff) and (active_enemies > desired_targets or raid_event.adds.in > 60)) then
      if AR.Cast(S.Nemesis) then return ""; end
    end
    -- nemesis,if=!raid_event.adds.exists&(buff.chaos_blades.up|buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains<20|target.time_to_die<=60)
    if S.Nemesis:IsCastable() and (not bool(raid_event.adds.exists) and (Player:BuffP(S.ChaosBladesBuff) or Player:BuffP(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains < 20 or Target:TimeToDie() <= 60)) then
      if AR.Cast(S.Nemesis) then return ""; end
    end
    -- chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains>60|target.time_to_die<=duration
    if S.ChaosBlades:IsCastable() and (Player:BuffP(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains > 60 or Target:TimeToDie() <= duration) then
      if AR.Cast(S.ChaosBlades) then return ""; end
    end
    -- potion,if=buff.metamorphosis.remains>25|target.time_to_die<30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffRemainsP(S.MetamorphosisBuff) > 25 or Target:TimeToDie() < 30) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Demonic()
    -- pick_up_fragment,if=fury.deficit>=35&(cooldown.eye_beam.remains>5|buff.metamorphosis.up)
    if S.PickUpFragment:IsCastable() and (Player:FuryDeficit() >= 35 and (S.EyeBeam:CooldownRemainsP() > 5 or Player:BuffP(S.MetamorphosisBuff))) then
      if AR.Cast(S.PickUpFragment) then return ""; end
    end
    -- vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
    if S.VengefulRetreat:IsCastable() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDownP(S.PreparedBuff) and Player:BuffDownP(S.MomentumBuff)) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastable() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDownP(S.MomentumBuff)) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- death_sweep,if=variable.blade_dance
    if S.DeathSweep:IsCastable() and (bool(BladeDance)) then
      if AR.Cast(S.DeathSweep) then return ""; end
    end
    -- fel_eruption
    if S.FelEruption:IsCastable() and (true) then
      if AR.Cast(S.FelEruption) then return ""; end
    end
    -- fury_of_the_illidari,if=(active_enemies>desired_targets)|(raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up))
    if S.FuryofTheIllidari:IsCastable() and ((active_enemies > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)))) then
      if AR.Cast(S.FuryofTheIllidari) then return ""; end
    end
    -- blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
    if S.BladeDance:IsCastable() and (bool(BladeDance) and S.EyeBeam:CooldownRemainsP() > 5 and not S.Metamorphosis:CooldownUpP()) then
      if AR.Cast(S.BladeDance) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and spell_targets >= 2 and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (spell_targets >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown())) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury.deficit>=30
    if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 30) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- eye_beam,if=spell_targets.eye_beam_tick>desired_targets|!buff.metamorphosis.extended_by_demonic|(set_bonus.tier21_4pc&buff.metamorphosis.remains>8)
    if S.EyeBeam:IsCastable() and (spell_targets.eye_beam_tick > desired_targets or not bool(buff.metamorphosis.extended_by_demonic) or (AC.Tier21_4Pc and Player:BuffRemainsP(S.MetamorphosisBuff) > 8)) then
      if AR.Cast(S.EyeBeam) then return ""; end
    end
    -- annihilation,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
    if S.Annihilation:IsCastable() and IsInMeleeRange() and ((not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(PoolingForBladeDance)) then
      if AR.Cast(S.Annihilation) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- chaos_strike,if=(!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
    if S.ChaosStrike:IsCastable() and IsInMeleeRange() and ((not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8) and not bool(PoolingForChaosStrike) and not bool(PoolingForMeta) and not bool(PoolingForBladeDance)) then
      if AR.Cast(S.ChaosStrike) then return ""; end
    end
    -- fel_rush,if=!talent.momentum.enabled&(buff.metamorphosis.down|talent.demon_blades.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastable() and (not S.Momentum:IsAvailable() and (Player:BuffDownP(S.MetamorphosisBuff) or S.DemonBlades:IsAvailable()) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- demons_bite
    if S.DemonsBite:IsCastable() and IsInMeleeRange() and (true) then
      if AR.Cast(S.DemonsBite) then return ""; end
    end
    -- throw_glaive,if=buff.out_of_range.up|!talent.bloodlet.enabled
    if S.ThrowGlaive:IsCastable() and (Player:BuffP(S.OutofRangeBuff) or not S.Bloodlet:IsAvailable()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    if S.FelRush:IsCastable() and (movement.distance > 15 or (Player:BuffP(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- vengeful_retreat,if=movement.distance>15
    if S.VengefulRetreat:IsCastable() and (movement.distance > 15) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
  end
  local function Normal()
    -- pick_up_fragment,if=talent.demonic_appetite.enabled&fury.deficit>=35
    if S.PickUpFragment:IsCastable() and (S.DemonicAppetite:IsAvailable() and Player:FuryDeficit() >= 35) then
      if AR.Cast(S.PickUpFragment) then return ""; end
    end
    -- vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
    if S.VengefulRetreat:IsCastable() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDownP(S.PreparedBuff) and Player:BuffDownP(S.MomentumBuff)) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsCastable() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDownP(S.MomentumBuff)) and (not S.FelMastery:IsAvailable() or Player:FuryDeficit() >= 25) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- fel_barrage,if=(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
    if S.FelBarrage:IsCastable() and ((Player:BuffP(S.MomentumBuff) or not S.Momentum:IsAvailable()) and (active_enemies > desired_targets or raid_event.adds.in > 30)) then
      if AR.Cast(S.FelBarrage) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury<15&(cooldown.death_sweep.remains<2*gcd|cooldown.blade_dance.remains<2*gcd)
    if S.Felblade:IsCastable() and (Player:Fury() < 15 and (S.DeathSweep:CooldownRemainsP() < 2 * Player:GCD() or S.BladeDance:CooldownRemainsP() < 2 * Player:GCD())) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- death_sweep,if=variable.blade_dance
    if S.DeathSweep:IsCastable() and (bool(BladeDance)) then
      if AR.Cast(S.DeathSweep) then return ""; end
    end
    -- fel_rush,if=charges=2&!talent.momentum.enabled&!talent.fel_mastery.enabled&!buff.metamorphosis.up
    if S.FelRush:IsCastable() and (S.FelRush:ChargesP() == 2 and not S.Momentum:IsAvailable() and not S.FelMastery:IsAvailable() and not Player:BuffP(S.MetamorphosisBuff)) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- fel_eruption
    if S.FelEruption:IsCastable() and (true) then
      if AR.Cast(S.FelEruption) then return ""; end
    end
    -- fury_of_the_illidari,if=(active_enemies>desired_targets)|(raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)&(!talent.chaos_blades.enabled|buff.chaos_blades.up|cooldown.chaos_blades.remains>30|target.time_to_die<cooldown.chaos_blades.remains))
    if S.FuryofTheIllidari:IsCastable() and ((active_enemies > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (not S.ChaosBlades:IsAvailable() or Player:BuffP(S.ChaosBladesBuff) or S.ChaosBlades:CooldownRemainsP() > 30 or Target:TimeToDie() < S.ChaosBlades:CooldownRemainsP()))) then
      if AR.Cast(S.FuryofTheIllidari) then return ""; end
    end
    -- blade_dance,if=variable.blade_dance
    if S.BladeDance:IsCastable() and (bool(BladeDance)) then
      if AR.Cast(S.BladeDance) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and spell_targets >= 2 and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and (spell_targets >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown())) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=fury.deficit>=30+buff.prepared.up*8
    if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 30 + num(Player:BuffP(S.PreparedBuff)) * 8) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- eye_beam,if=spell_targets.eye_beam_tick>desired_targets|(spell_targets.eye_beam_tick>=3&raid_event.adds.in>cooldown)|(talent.blind_fury.enabled&fury.deficit>=35)|set_bonus.tier21_2pc
    if S.EyeBeam:IsCastable() and (spell_targets.eye_beam_tick > desired_targets or (spell_targets.eye_beam_tick >= 3 and raid_event.adds.in > S.EyeBeam:Cooldown()) or (S.BlindFury:IsAvailable() and Player:FuryDeficit() >= 35) or AC.Tier21_2Pc) then
      if AR.Cast(S.EyeBeam) then return ""; end
    end
    -- annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
    if S.Annihilation:IsCastable() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(PoolingForBladeDance)) then
      if AR.Cast(S.Annihilation) then return ""; end
    end
    -- throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:Cooldown()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- throw_glaive,if=!talent.bloodlet.enabled&buff.metamorphosis.down&spell_targets>=3
    if S.ThrowGlaive:IsCastable() and (not S.Bloodlet:IsAvailable() and Player:BuffDownP(S.MetamorphosisBuff) and spell_targets >= 3) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
    if S.ChaosStrike:IsCastable() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:BuffP(S.MomentumBuff) or Player:FuryDeficit() < 30 + num(Player:BuffP(S.PreparedBuff)) * 8) and not bool(PoolingForChaosStrike) and not bool(PoolingForMeta) and not bool(PoolingForBladeDance)) then
      if AR.Cast(S.ChaosStrike) then return ""; end
    end
    -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&(talent.demon_blades.enabled|buff.metamorphosis.down)
    if S.FelRush:IsCastable() and (not S.Momentum:IsAvailable() and raid_event.movement.in > S.FelRush:ChargesP() * 10 and (S.DemonBlades:IsAvailable() or Player:BuffDownP(S.MetamorphosisBuff))) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- demons_bite
    if S.DemonsBite:IsCastable() and IsInMeleeRange() and (true) then
      if AR.Cast(S.DemonsBite) then return ""; end
    end
    -- throw_glaive,if=buff.out_of_range.up
    if S.ThrowGlaive:IsCastable() and (Player:BuffP(S.OutofRangeBuff)) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
    -- felblade,if=movement.distance>15|buff.out_of_range.up
    if S.Felblade:IsCastable() and (movement.distance > 15 or Player:BuffP(S.OutofRangeBuff)) then
      if AR.Cast(S.Felblade) then return ""; end
    end
    -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    if S.FelRush:IsCastable() and (movement.distance > 15 or (Player:BuffP(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR.Cast(S.FelRush) then return ""; end
    end
    -- vengeful_retreat,if=movement.distance>15
    if S.VengefulRetreat:IsCastable() and (movement.distance > 15) then
      if AR.Cast(S.VengefulRetreat) then return ""; end
    end
    -- throw_glaive,if=!talent.bloodlet.enabled
    if S.ThrowGlaive:IsCastable() and (not S.Bloodlet:IsAvailable()) then
      if AR.Cast(S.ThrowGlaive) then return ""; end
    end
  end
  -- auto_attack
  if S.AutoAttack:IsCastable() and (true) then
    if AR.Cast(S.AutoAttack) then return ""; end
  end
  -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
  if (true) then
    WaitingForNemesis = num(not (not S.Nemesis:IsAvailable() or S.Nemesis:CooldownUpP() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60))
  end
  -- variable,name=waiting_for_chaos_blades,value=!(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready|cooldown.chaos_blades.remains>target.time_to_die|cooldown.chaos_blades.remains>60)
  if (true) then
    WaitingForChaosBlades = num(not (not S.ChaosBlades:IsAvailable() or S.ChaosBlades:CooldownUpP() or S.ChaosBlades:CooldownRemainsP() > Target:TimeToDie() or S.ChaosBlades:CooldownRemainsP() > 60))
  end
  -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)&(!variable.waiting_for_chaos_blades|cooldown.chaos_blades.remains<6)
  if (true) then
    PoolingForMeta = num(not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not bool(WaitingForNemesis) or S.Nemesis:CooldownRemainsP() < 10) and (not bool(WaitingForChaosBlades) or S.ChaosBlades:CooldownRemainsP() < 6))
  end
  -- variable,name=blade_dance,value=talent.first_blood.enabled|set_bonus.tier20_4pc|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*3)
  if (true) then
    BladeDance = num(S.FirstBlood:IsAvailable() or AC.Tier20_4Pc or spell_targets.blade_dance1 >= 3 + (num(S.ChaosCleave:IsAvailable()) * 3))
  end
  -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
  if (true) then
    PoolingForBladeDance = num(bool(BladeDance) and (Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20))
  end
  -- variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
  if (true) then
    PoolingForChaosStrike = num(S.ChaosCleave:IsAvailable() and Player:FuryDeficit() > 40 and not bool(raid_event.adds.up) and raid_event.adds.in < 2 * Player:GCD())
  end
  -- consume_magic
  if S.ConsumeMagic:IsCastable() and (true) then
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