local function ActiveUAs ()
  local UAcount = 0
  for _, v in pairs(UnstableAfflictionDebuffs) do
    if Target:DebuffRemainsP(v) > 0 then UAcount = UAcount + 1 end
  end
  return UAcount
end
