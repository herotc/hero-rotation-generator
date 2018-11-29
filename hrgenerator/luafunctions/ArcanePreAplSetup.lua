Player.ArcaneBurnPhase = {}
local BurnPhase = Player.ArcaneBurnPhase

function BurnPhase:Reset()
  self.state = false
  self.last_start = HL.GetTime()
  self.last_stop = HL.GetTime()
end
BurnPhase:Reset()

function BurnPhase:Start()
  if Player:AffectingCombat() then
    self.state = true
    self.last_start = HL.GetTime()
  end
end

function BurnPhase:Stop()
  self.state = false
  self.last_stop = HL.GetTime()
end

function BurnPhase:On()
  return self.state or (not Player:AffectingCombat() and Player:IsCasting() and ((S.ArcanePower:CooldownRemainsP() == 0 and S.Evocation:CooldownRemainsP() <= VarAverageBurnLength and (Player:ArcaneChargesP() == Player:ArcaneChargesMax() or (S.ChargedUp:IsAvailable() and S.ChargedUp:CooldownRemainsP() == 0)))))
end

function BurnPhase:Duration()
  return self.state and (HL.GetTime() - self.last_start) or 0
end

HL:RegisterForEvent(function()
  BurnPhase:Reset()
end, "PLAYER_REGEN_DISABLED")

local function PresenceOfMindMax ()
  return 2
end

local function ArcaneMissilesProcMax ()
  return 3
end

function Player:ArcaneChargesP()
  return math.min(self:ArcaneCharges() + num(self:IsCasting(S.ArcaneBlast)),4)
end