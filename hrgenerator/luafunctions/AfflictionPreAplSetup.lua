HL.UnstableAfflictionDebuffsPrev = {
    [S.UnstableAffliction2Debuff] = S.UnstableAffliction1Debuff,
    [S.UnstableAffliction3Debuff] = S.UnstableAffliction2Debuff,
    [S.UnstableAffliction4Debuff] = S.UnstableAffliction3Debuff,
    [S.UnstableAffliction5Debuff] = S.UnstableAffliction4Debuff
  };

local function NbAffected (SpellAffected)
    local nbaff = 0
    for Key, Value in pairs(Cache.Enemies[EnemyRanges[2]]) do
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