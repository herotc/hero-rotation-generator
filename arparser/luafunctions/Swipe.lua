local function Swipe()
  if Player:Buff(S.CatForm)
    return S.SwipeCat;
  else
    return S.SwipeBear;
  end
end
