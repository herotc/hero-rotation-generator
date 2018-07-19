local function Thrash()
  if Player:Buff(S.CatForm)
    return S.ThrashCat;
  else
    return S.ThrashBear;
  end
end
