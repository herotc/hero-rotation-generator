S.ShrapnelBomb = Spell(270335)
S.PheromoneBomb = Spell(270323)
S.VolatileBomb = Spell(271045)
S.WildfireBombNormal = Spell(259495)

local function CurrentWildfireInfusion ()
  if S.WildfireInfusion:IsAvailable() then
    for _, infusion in pairs(WildfireInfusions) do
      if infusion:IsLearned() then return infusion end
    end
  end
  return S.WildfireBombNormal
end