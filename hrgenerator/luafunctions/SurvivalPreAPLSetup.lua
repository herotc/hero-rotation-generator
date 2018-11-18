S.WildfireBombNormal  = Spell(259495)
S.ShrapnelBomb        = Spell(270335)
S.PheromoneBomb       = Spell(270323)
S.VolatileBomb        = Spell(271045)

local WildfireInfusions = {
  S.ShrapnelBomb,
  S.PheromoneBomb,
  S.VolatileBomb,
}

local function CurrentWildfireInfusion ()
  if S.WildfireInfusion:IsAvailable() then
    for _, infusion in pairs(WildfireInfusions) do
      if infusion:IsLearned() then return infusion end
    end
  end
  return S.WildfireBombNormal
end

S.RaptorStrikeNormal  = Spell(186270)
S.RaptorStrikeEagle   = Spell(265189)
S.MongooseBiteNormal  = Spell(259387)
S.MongooseBiteEagle   = Spell(265888)

local function CurrentRaptorStrike ()
  return S.RaptorStrikeEagle:IsLearned() and S.RaptorStrikeEagle or S.RaptorStrikeNormal
end

local function CurrentMongooseBite ()
  return S.MongooseBiteEagle:IsLearned() and S.MongooseBiteEagle or S.MongooseBiteNormal
end