local function FutureAstralPower()
  local AstralPower=Player:AstralPower()
  if not Player:IsCasting() then
    return AstralPower
  else
    if Player:IsCasting(S.NewnMoon) then
      return AstralPower + 10
    elseif Player:IsCasting(S.HalfMoon) then
      return AstralPower + 20
    elseif Player:IsCasting(S.FullMoon) then
      return AstralPower + 40
    elseif Player:IsCasting(S.StellarFlare) then
      return AstralPower + 8
    elseif Player:IsCasting(S.SolarWrath) then
      return AstralPower + 8
    elseif Player:IsCasting(S.LunarStrike) then
      return AstralPower + 12
    else
      return AstralPower
    end
  end
end
