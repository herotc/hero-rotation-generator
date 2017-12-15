local function FutureShard ()
  local Shard = Player:SoulShards()
  if not Player:IsCasting() then
    return Shard
  else
    if Player:IsCasting(S.UnstableAffliction) 
        or Player:IsCasting(S.SeedOfCorruption) then
      return Shard - 1
    elseif Player:IsCasting(S.SummonDoomGuard) 
        or Player:IsCasting(S.SummonDoomGuardSuppremacy) 
        or Player:IsCasting(S.SummonInfernal) 
        or Player:IsCasting(S.SummonInfernalSuppremacy) 
        or Player:IsCasting(S.GrimoireFelhunter) 
        or Player:IsCasting(S.SummonFelhunter) then
      return Shard - 1
    else
      return Shard
    end
  end
end
