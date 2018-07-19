local function StartBurnPhase ()
  varBurnPhase = 1
  varBurnPhaseStart = HL.GetTime()
end

local function StopBurnPhase ()
  varBurnPhase = 0
end
