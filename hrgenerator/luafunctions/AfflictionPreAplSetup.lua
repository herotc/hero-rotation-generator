HL.UnstableAfflictionDebuffsPrev = {
    [UnstableAfflictionDebuffs[2]] = UnstableAfflictionDebuffs[1],
    [UnstableAfflictionDebuffs[3]] = UnstableAfflictionDebuffs[2],
    [UnstableAfflictionDebuffs[4]] = UnstableAfflictionDebuffs[3],
    [UnstableAfflictionDebuffs[5]] = UnstableAfflictionDebuffs[4]
  };

local function NbAffected (SpellAffected)
    local nbaff = 0
    for Key, Value in pairs(Cache.Enemies[40]) do
      if Value:DebuffRemainsP(SpellAffected) > 0 then nbaff = nbaff + 1; end
    end
    return nbaff;
end

local function TimeToShard()
    local agony_count = NbAffected(S.Agony)
    if agony_count == 0 then
        return 10000 
    end
    return 1 / (0.16 / math.sqrt(agony_count) * (agony_count == 1 and 1.15 or 1) * agony_count / S.Agony:TickTime())
end

S.ShadowBolt:RegisterInFlight()
S.SeedofCorruption:RegisterInFlight()