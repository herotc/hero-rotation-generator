local function Apl()
  local function Cooldown()
    if S.Metamorphosis:IsCastable() and (not (S.Demonic:IsAvailable() or PoolingForMeta() or WaitingForNemesis() or WaitingForChaosBlades()) or Target:TimeToDie() < 25) then
      if AR:Cast(S.Metamorphosis) then return ""; end
    end
    if S.Metamorphosis:IsCastable() and (S.Demonic:IsAvailable() and Player:Buff(S.MetamorphosisBuff) and Player:Fury() < 40) then
      if AR:Cast(S.Metamorphosis) then return ""; end
    end
    if S.Nemesis:IsCastable() and (raid_event.adds.exists and debuff.nemesis.down and (active_enemies > desired_targets or raid_event.adds.in > 60)) then
      if AR:Cast(S.Nemesis) then return ""; end
    end
    if S.Nemesis:IsCastable() and (not raid_event.adds.exists and (Player:Buff(S.ChaosBladesBuff) or Player:Buff(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains < 20 or Target:TimeToDie() <= 60)) then
      if AR:Cast(S.Nemesis) then return ""; end
    end
    if S.ChaosBlades:IsCastable() and (Player:Buff(S.MetamorphosisBuff) or cooldown.metamorphosis.adjusted_remains > 60 or Target:TimeToDie() <= duration) then
      if AR:Cast(S.ChaosBlades) then return ""; end
    end
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffRemains(S.MetamorphosisBuff) > 25 or Target:TimeToDie() < 30) then
      if AR:CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Demonic()
    if S.PickUpFragment:IsCastable() and (Player:FuryDeficit() >= 35 and (S.EyeBeam:CooldownRemainsP() > 5 or Player:Buff(S.MetamorphosisBuff))) then
      if AR:Cast(S.PickUpFragment) then return ""; end
    end
    if S.VengefulRetreat:IsCastable() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDown(S.PreparedBuff) and Player:BuffDown(S.MomentumBuff)) then
      if AR:Cast(S.VengefulRetreat) then return ""; end
    end
    if S.FelRush:IsCastable() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDown(S.MomentumBuff)) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.DeathSweep:IsCastable() and (BladeDance()) then
      if AR:Cast(S.DeathSweep) then return ""; end
    end
    if S.FelEruption:IsCastable() and (true) then
      if AR:Cast(S.FelEruption) then return ""; end
    end
    if S.FuryofTheIllidari:IsCastable() and ((active_enemies > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)))) then
      if AR:Cast(S.FuryofTheIllidari) then return ""; end
    end
    if S.BladeDance:IsCastable() and (BladeDance() and S.EyeBeam:CooldownRemainsP() > 5 and not S.Metamorphosis:IsReady()) then
      if AR:Cast(S.BladeDance) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and spell_targets >= 2 and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and (spell_targets >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:CooldownRemainsP())) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 30) then
      if AR:Cast(S.Felblade) then return ""; end
    end
    if S.EyeBeam:IsCastable() and (spell_targets.eye_beam_tick > desired_targets or not buff.metamorphosis.extended_by_demonic or (set_bonus.tier21_4pc and Player:BuffRemains(S.MetamorphosisBuff) > 8)) then
      if AR:Cast(S.EyeBeam) then return ""; end
    end
    if S.Annihilation:IsCastable() and ((not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff) or Player:FuryDeficit() < 30 + Player:Buff(S.PreparedBuff) * 8 or Player:BuffRemains(S.MetamorphosisBuff) < 5) and not PoolingForBladeDance()) then
      if AR:Cast(S.Annihilation) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:CooldownRemainsP()) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.ChaosStrike:IsCastable() and ((not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff) or Player:FuryDeficit() < 30 + Player:Buff(S.PreparedBuff) * 8) and not PoolingForChaosStrike() and not PoolingForMeta() and not PoolingForBladeDance()) then
      if AR:Cast(S.ChaosStrike) then return ""; end
    end
    if S.FelRush:IsCastable() and (not S.Momentum:IsAvailable() and (Player:BuffDown(S.MetamorphosisBuff) or S.DemonBlades:IsAvailable()) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.DemonsBite:IsCastable() and (true) then
      if AR:Cast(S.DemonsBite) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (Player:Buff(S.OutofRangeBuff) or not S.Bloodlet:IsAvailable()) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.FelRush:IsCastable() and (movement.distance > 15 or (Player:Buff(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.VengefulRetreat:IsCastable() and (movement.distance > 15) then
      if AR:Cast(S.VengefulRetreat) then return ""; end
    end
  end
  local function Normal()
    if S.PickUpFragment:IsCastable() and (S.DemonicAppetite:IsAvailable() and Player:FuryDeficit() >= 35) then
      if AR:Cast(S.PickUpFragment) then return ""; end
    end
    if S.VengefulRetreat:IsCastable() and ((S.Prepared:IsAvailable() or S.Momentum:IsAvailable()) and Player:BuffDown(S.PreparedBuff) and Player:BuffDown(S.MomentumBuff)) then
      if AR:Cast(S.VengefulRetreat) then return ""; end
    end
    if S.FelRush:IsCastable() and ((S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) and (not S.Momentum:IsAvailable() or (S.FelRush:ChargesP() == 2 or S.VengefulRetreat:CooldownRemainsP() > 4) and Player:BuffDown(S.MomentumBuff)) and (not S.FelMastery:IsAvailable() or Player:FuryDeficit() >= 25) and (S.FelRush:ChargesP() == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.FelBarrage:IsCastable() and ((Player:Buff(S.MomentumBuff) or not S.Momentum:IsAvailable()) and (active_enemies > desired_targets or raid_event.adds.in > 30)) then
      if AR:Cast(S.FelBarrage) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and S.ThrowGlaive:ChargesP() == 2) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.Felblade:IsCastable() and (Player:Fury() < 15 and (S.DeathSweep:CooldownRemainsP() < 2 * Player:GCD() or S.BladeDance:CooldownRemainsP() < 2 * Player:GCD())) then
      if AR:Cast(S.Felblade) then return ""; end
    end
    if S.DeathSweep:IsCastable() and (BladeDance()) then
      if AR:Cast(S.DeathSweep) then return ""; end
    end
    if S.FelRush:IsCastable() and (S.FelRush:ChargesP() == 2 and not S.Momentum:IsAvailable() and not S.FelMastery:IsAvailable() and not Player:Buff(S.MetamorphosisBuff)) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.FelEruption:IsCastable() and (true) then
      if AR:Cast(S.FelEruption) then return ""; end
    end
    if S.FuryofTheIllidari:IsCastable() and ((active_enemies > desired_targets) or (raid_event.adds.in > 55 and (not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and (not S.ChaosBlades:IsAvailable() or Player:Buff(S.ChaosBladesBuff) or S.ChaosBlades:CooldownRemainsP() > 30 or Target:TimeToDie() < S.ChaosBlades:CooldownRemainsP()))) then
      if AR:Cast(S.FuryofTheIllidari) then return ""; end
    end
    if S.BladeDance:IsCastable() and (BladeDance()) then
      if AR:Cast(S.BladeDance) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and spell_targets >= 2 and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and (spell_targets >= 3 or raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:CooldownRemainsP())) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 30 + Player:Buff(S.PreparedBuff) * 8) then
      if AR:Cast(S.Felblade) then return ""; end
    end
    if S.EyeBeam:IsCastable() and (spell_targets.eye_beam_tick > desired_targets or (spell_targets.eye_beam_tick >= 3 and raid_event.adds.in > S.EyeBeam:CooldownRemainsP()) or (S.BlindFury:IsAvailable() and Player:FuryDeficit() >= 35) or set_bonus.tier21_2pc) then
      if AR:Cast(S.EyeBeam) then return ""; end
    end
    if S.Annihilation:IsCastable() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff) or Player:FuryDeficit() < 30 + Player:Buff(S.PreparedBuff) * 8 or Player:BuffRemains(S.MetamorphosisBuff) < 5) and not PoolingForBladeDance()) then
      if AR:Cast(S.Annihilation) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (S.Bloodlet:IsAvailable() and (not S.MasterofTheGlaive:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff)) and raid_event.adds.in > S.ThrowGlaive:RechargeP() + S.ThrowGlaive:CooldownRemainsP()) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (not S.Bloodlet:IsAvailable() and Player:BuffDown(S.MetamorphosisBuff) and spell_targets >= 3) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.ChaosStrike:IsCastable() and ((S.DemonBlades:IsAvailable() or not S.Momentum:IsAvailable() or Player:Buff(S.MomentumBuff) or Player:FuryDeficit() < 30 + Player:Buff(S.PreparedBuff) * 8) and not PoolingForChaosStrike() and not PoolingForMeta() and not PoolingForBladeDance()) then
      if AR:Cast(S.ChaosStrike) then return ""; end
    end
    if S.FelRush:IsCastable() and (not S.Momentum:IsAvailable() and raid_event.movement.in > S.FelRush:ChargesP() * 10 and (S.DemonBlades:IsAvailable() or Player:BuffDown(S.MetamorphosisBuff))) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.DemonsBite:IsCastable() and (true) then
      if AR:Cast(S.DemonsBite) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (Player:Buff(S.OutofRangeBuff)) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
    if S.Felblade:IsCastable() and (movement.distance > 15 or Player:Buff(S.OutofRangeBuff)) then
      if AR:Cast(S.Felblade) then return ""; end
    end
    if S.FelRush:IsCastable() and (movement.distance > 15 or (Player:Buff(S.OutofRangeBuff) and not S.Momentum:IsAvailable())) then
      if AR:Cast(S.FelRush) then return ""; end
    end
    if S.VengefulRetreat:IsCastable() and (movement.distance > 15) then
      if AR:Cast(S.VengefulRetreat) then return ""; end
    end
    if S.ThrowGlaive:IsCastable() and (not S.Bloodlet:IsAvailable()) then
      if AR:Cast(S.ThrowGlaive) then return ""; end
    end
  end
  if S.AutoAttack:IsCastable() and (true) then
    if AR:Cast(S.AutoAttack) then return ""; end
  end
  local function WaitingForNemesis()
    return not (not S.Nemesis:IsAvailable() or S.Nemesis:IsReady() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60);
  end
  local function WaitingForChaosBlades()
    return not (not S.ChaosBlades:IsAvailable() or S.ChaosBlades:IsReady() or S.ChaosBlades:CooldownRemainsP() > Target:TimeToDie() or S.ChaosBlades:CooldownRemainsP() > 60);
  end
  local function PoolingForMeta()
    return not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not WaitingForNemesis() or S.Nemesis:CooldownRemainsP() < 10) and (not WaitingForChaosBlades() or S.ChaosBlades:CooldownRemainsP() < 6);
  end
  local function BladeDance()
    return S.FirstBlood:IsAvailable() or set_bonus.tier20_4pc or spell_targets.blade_dance1 >= 3 + (S.ChaosCleave:IsAvailable() * 3);
  end
  local function PoolingForBladeDance()
    return BladeDance() and (Player:Fury() < 75 - S.FirstBlood:IsAvailable() * 20);
  end
  local function PoolingForChaosStrike()
    return S.ChaosCleave:IsAvailable() and Player:FuryDeficit() > 40 and not raid_event.adds.up and raid_event.adds.in < 2 * Player:GCD();
  end
  if S.ConsumeMagic:IsCastable() and (true) then
    if AR:Cast(S.ConsumeMagic) then return ""; end
  end
  if (Player:GCDRemains() == 0) then
    local ShouldReturn = Cooldown(); if ShouldReturn then return ShouldReturn; end
  end
  if (S.Demonic:IsAvailable()) then
    return Demonic();
  end
  if (true) then
    return Normal();
  end
end