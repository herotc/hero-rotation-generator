local function TimeToShard()
  local ActiveAgony = S.Agony:ActiveDot()
  if ActiveAgony == 0 then
    return 10000 
  end
  return 1 / (0.16 / math.sqrt(ActiveAgony) * (ActiveAgony == 1 and 1.15 or 1) * ActiveAgony / S.Agony:TickTime())
end

local UnstableAfflictionDebuffs = {
  Spell(233490),
  Spell(233496),
  Spell(233497),
  Spell(233498),
  Spell(233499)
};

local function ActiveUAs ()
  local UACount = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    if Target:DebuffRemainsP(UADebuff) > 0 then UACount = UACount + 1 end
  end
  return UACount
end

local function Contagion()
  local MaximumDuration = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    local UARemains = Target:DebuffRemainsP(UADebuff)
    if UARemains > MaximumDuration then
      MaximumDuration = UARemains
    end
  end
  return MaximumDuration
end

S.ShadowBolt:RegisterInFlight()
S.SeedofCorruption:RegisterInFlight()
