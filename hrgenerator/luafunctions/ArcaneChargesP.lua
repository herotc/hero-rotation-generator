function Player:ArcaneChargesP()
    return math.min(self:ArcaneCharges() + num(self:IsCasting(S.ArcaneBlast)),4)
end