local function StartBurnPhase ()
  varBurnPhase = 1
  varBurnPhaseStart = AC.GetTime()
end

local function StopBurnPhase ()
  varBurnPhase = 0
end
