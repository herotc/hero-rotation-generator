local function StartBurnPhase ()
  VarBurnPhase = 1
  VarBurnPhaseStart = HL.GetTime()
end

local function StopBurnPhase ()
  VarBurnPhase = 0
  VarBurnPhaseEnd = HL.GetTime()
  VarBurnPhaseDuration = VarBurnPhaseEnd - VarBurnPhaseStart
  VarAverageBurnLength = (VarAverageBurnLength * VarTotalBurns - VarAverageBurnLength + (VarBurnPhaseDuration)) / VarTotalBurns
end
