local function Apl()
  local function WaitingForNemesis()
    return not (not S.Nemesis:IsAvailable() or S.Nemesis:IsReady() or S.Nemesis:CooldownRemainsP() > target.time_to_die or S.Nemesis:CooldownRemainsP() > 60);
  end
  if S.MindFreeze:IsCastable("melee") and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR:CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  if S.ArcaneTorrent:IsCastable() and (Player:RunicPowerDeficit() > 20) then
    if AR:Cast(S.ArcaneTorrent, Settings.Blood.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  if S.BloodFury:IsCastable() and (true) then
    if AR:Cast(S.BloodFury) then return ""; end
  end
  if S.Berserking:IsCastable() and (Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR:Cast(S.Berserking) then return ""; end
  end
  if S.UseItems:IsCastable() and (true) then
    if AR:Cast(S.UseItems) then return ""; end
  end
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR:CastSuggested(I.ProlongedPower) then return ""; end
  end
  if S.DancingRuneWeapon:IsCastable() and ((not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:IsReady()) and not S.DeathandDecay:IsReady()) then
    if AR:Cast(S.DancingRuneWeapon, Settings.Blood.OffGCDasOffGCD.DancingRuneWeapon) then return ""; end
  end
  if S.VampiricBlood:IsCastable() and (true) then
    if AR:Cast(S.VampiricBlood) then return ""; end
  end
  if (true) then
    local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
  end
end
local function Standard()
  if S.DeathStrike:IsUsable() and (Player:RunicPowerDeficit() < 10) then
    if AR:Cast(S.DeathStrike) then return ""; end
  end
  if S.DeathandDecay:IsUsable() and (S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR:Cast(S.DeathandDecay) then return ""; end
  end
  if S.BloodDrinker:IsCastable() and (not Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR:Cast(S.BloodDrinker) then return ""; end
  end
  if S.Marrowrend:IsCastable() and (Player:BuffRemains(S.BoneShieldBuff) <= Player:GCD() * 2) then
    if AR:Cast(S.Marrowrend) then return ""; end
  end
  if S.BloodBoil:IsCastable() and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
    if AR:Cast(S.BloodBoil) then return ""; end
  end
  if S.Marrowrend:IsCastable() and ((Player:BuffStack(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemains(S.BoneShieldBuff) < Player:GCD() * 3) then
    if AR:Cast(S.Marrowrend) then return ""; end
  end
  if S.Bonestorm:IsCastable() and (Player:RunicPower() >= 100 and spell_targets.bonestorm >= 3) then
    if AR:Cast(S.Bonestorm) then return ""; end
  end
  if S.DeathStrike:IsUsable() and (Player:Buff(S.BloodShieldBuff) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
    if AR:Cast(S.DeathStrike) then return ""; end
  end
  if S.Consumption:IsCastable() and (true) then
    if AR:Cast(S.Consumption) then return ""; end
  end
  if S.HeartStrike:IsCastable() and (Player:Buff(S.DancingRuneWeaponBuff)) then
    if AR:Cast(S.HeartStrike) then return ""; end
  end
  if S.DeathandDecay:IsUsable() and (Player:Buff(S.CrimsonScourgeBuff)) then
    if AR:Cast(S.DeathandDecay) then return ""; end
  end
  if S.BloodBoil:IsCastable() and (Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
    if AR:Cast(S.BloodBoil) then return ""; end
  end
  if S.DeathandDecay:IsUsable() and (true) then
    if AR:Cast(S.DeathandDecay) then return ""; end
  end
  if S.HeartStrike:IsCastable() and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStack(S.BoneShieldBuff) > 6) then
    if AR:Cast(S.HeartStrike) then return ""; end
  end
end