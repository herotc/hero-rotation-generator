local function FutureAstralPower()
  local AstralPower=Player:AstralPower()
  if not Player:IsCasting() then
    return AstralPower
  else
    if Player:IsCasting(S.NewMoon) then
      return AstralPower + 10
    elseif Player:IsCasting(S.HalfMoon) then
      return AstralPower + 20
    elseif Player:IsCasting(S.FullMoon) then
      return AstralPower + 40
    elseif Player:IsCasting(S.SolarWrath) then
      return AstralPower
        + (Player:Buff(S.BlessingofElune) and 10 or 8)
          * ((Player:BuffRemainsP(S.CelestialAlignment) > 0
            or Player:BuffRemainsP(S.IncarnationChosenOfElune) > 0) and 2 or 1)
    elseif Player:IsCasting(S.LunarStrike) then
      return AstralPower
        + (Player:Buff(S.BlessingofElune) and 15 or 10)
          * ((Player:BuffRemainsP(S.CelestialAlignment) > 0
            or Player:BuffRemainsP(S.IncarnationChosenOfElune) > 0) and 2 or 1)
    else
      return AstralPower
    end
  end
end
