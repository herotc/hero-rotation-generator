function S.FerociousBiteMaxEnergy:CustomCost()
  return (Player:BuffP(S.IncarnationBuff) or Player:BuffP(S.BerserkBuff)) and 25 or 50
end

S.Rip:RegisterPMultiplier({S.BloodtalonsBuff, 1.2}, {S.SavageRoar, 1.15}, {S.TigersFury, 1.15})
S.Rake:RegisterPMultiplier(
  S.RakeDebuff,
  {function ()
    return Player:IsStealthed(true, true) and 2 or 1;
  end},
  {S.BloodtalonsBuff, 1.2}, {S.SavageRoar, 1.15}, {S.TigersFury, 1.15}
)