local function MetamorphosisCooldownAdjusted()
  -- TODO: Make this better by sampling the Fury expenses over time instead of approximating
  if I.ConvergenceofFates:IsEquipped() and I.DelusionsOfGrandeur:IsEquipped() then
    return S.Metamorphosis:CooldownRemainsP() * 0.56;
  elseif I.ConvergenceofFates:IsEquipped() then
    return S.Metamorphosis:CooldownRemainsP() * 0.78;
  elseif I.DelusionsOfGrandeur:IsEquipped() then
    return S.Metamorphosis:CooldownRemainsP() * 0.67;
  end
  return S.Metamorphosis:CooldownRemainsP()
end
