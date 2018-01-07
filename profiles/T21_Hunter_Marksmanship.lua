--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- AethysCore
local AC     = AethysCore
local Cache  = AethysCache
local Unit   = AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = AC.Spell
local Item   = AC.Item
-- AethysRotation
local AR     = AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.Marksmanship = {
  SummonPet                             = Spell(),
  Windburst                             = Spell(204147),
  ArcaneTorrent                         = Spell(50613),
  Sidewinders                           = Spell(214579),
  Berserking                            = Spell(26297),
  TrueshotBuff                          = Spell(193526),
  BloodFury                             = Spell(20572),
  BullseyeBuff                          = Spell(204090),
  ProlongedPowerBuff                    = Spell(229206),
  Trueshot                              = Spell(193526),
  Sentinel                              = Spell(206817),
  MarkingTargetsBuff                    = Spell(223138),
  ExplosiveShot                         = Spell(212431),
  PiercingShot                          = Spell(198670),
  VulnerabilityDebuff                   = Spell(187131),
  AimedShot                             = Spell(19434),
  TrickShot                             = Spell(199522),
  LockandLoadBuff                       = Spell(194594),
  SentinelsSightBuff                    = Spell(208913),
  T202PCriticalAimedDamageBuff          = Spell(242242),
  MarkedShot                            = Spell(185901),
  Multishot                             = Spell(2643),
  HuntersMarkDebuff                     = Spell(185365),
  BlackArrow                            = Spell(194599),
  AMurderofCrows                        = Spell(131894),
  Barrage                               = Spell(120360),
  ArcaneShot                            = Spell(185358),
  CounterShot                           = Spell(147362),
  UseItems                              = Spell(),
  Volley                                = Spell(194386),
  PatientSniper                         = Spell(234588)
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Hunter.Marksmanship;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Hunter.Commons,
  Marksmanship = AR.GUISettings.APL.Hunter.Marksmanship
};

-- Variables
local VarWaitingForSentinel = 0;
local VarPoolingForPiercing = 0;
local VarVulnWindow = 0;
local VarVulnAimCasts = 0;
local VarCanGcd = 0;

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    AC.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function TargetDebuffRemainsP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability and (S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true)) then
    return 7;
  else
    return DebuffRemainsP(Spell);
  end
end

local function TargetDebuffP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability then
    return DebuffP(Spell) or S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true);
  elseif Spell == S.HuntersMark then
    return DebuffP(Spell) or S.ArcaneShot:InFlight(S.MarkingTargets) or S.MultiShot:InFlight(S.MarkingTargets) or S.Sidewinders:InFlight(S.MarkingTargets);
  else
    return DebuffP(Spell);
  end
end

--- ======= ACTION LISTS =======
local function APL()
  UpdateRanges()
  local function Precombat()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() and (true) then
      if AR.Cast(S.SummonPet) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- windburst
    if S.Windburst:IsCastableP() and (true) then
      if AR.Cast(S.Windburst) then return ""; end
    end
  end
  local function Cooldowns()
    -- arcane_torrent,if=focus.deficit>=30&(!talent.sidewinders.enabled|cooldown.sidewinders.charges<2)
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:FocusDeficit() >= 30 and (not S.Sidewinders:IsAvailable() or S.Sidewinders:ChargesP() < 2)) then
      if AR.Cast(S.ArcaneTorrent, Settings.Marksmanship.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- berserking,if=buff.trueshot.up
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.TrueshotBuff)) then
      if AR.Cast(S.Berserking, Settings.Marksmanship.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury,if=buff.trueshot.up
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.TrueshotBuff)) then
      if AR.Cast(S.BloodFury, Settings.Marksmanship.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- potion,if=(buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react=30|((consumable.prolonged_power&target.time_to_die<62)|target.time_to_die<31)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((bool(Player:BuffStackP(S.TrueshotBuff)) and Player:HasHeroism()) or Player:BuffStackP(S.BullseyeBuff) == 30 or ((Player:Buff(S.ProlongedPowerBuff) and Target:TimeToDie() < 62) or Target:TimeToDie() < 31)) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- trueshot,if=time=0|buff.bloodlust.up|(target.time_to_die>(cooldown.trueshot.duration_guess+duration))|buff.bullseye.react=30|target.time_to_die<16
    if S.Trueshot:IsCastableP() and (AC.CombatTime() == 0 or Player:HasHeroism() or (Target:TimeToDie() > (cooldown.trueshot.duration_guess + S.Trueshot:BaseDuration())) or Player:BuffStackP(S.BullseyeBuff) == 30 or Target:TimeToDie() < 16) then
      if AR.Cast(S.Trueshot) then return ""; end
    end
  end
  local function NonPatientSniper()
    -- variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&action.sentinel.marks_next_gcd
    if (true) then
      VarWaitingForSentinel = num(S.Sentinel:IsAvailable() and (Player:BuffP(S.MarkingTargetsBuff) or Player:BuffP(S.TrueshotBuff)) and bool(action.sentinel.marks_next_gcd))
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() and (true) then
      if AR.Cast(S.ExplosiveShot) then return ""; end
    end
    -- piercing_shot,if=lowest_vuln_within.5>0&focus>100
    if S.PiercingShot:IsCastableP() and (TargetDebuffRemainsP(S.VulnerabilityDebuff) > 0 and Player:Focus() > 100) then
      if AR.Cast(S.PiercingShot) then return ""; end
    end
    -- aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&(talent.trick_shot.enabled|buff.lock_and_load.up)&buff.sentinels_sight.stack=20
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() and (S.TrickShot:IsAvailable() or Player:BuffP(S.LockandLoadBuff)) and Player:BuffStackP(S.SentinelsSightBuff) == 20) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&set_bonus.tier20_2pc&!buff.t20_2p_critical_aimed_damage.up&action.aimed_shot.in_flight
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() and S.TrickShot:IsAvailable() and AC.Tier20_2Pc and not Player:BuffP(S.T202PCriticalAimedDamageBuff) and S.AimedShot:InFlight()) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- marked_shot,if=spell_targets>1
    if S.MarkedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (Player:BuffP(S.MarkingTargetsBuff) or Player:BuffP(S.TrueshotBuff))) then
      if AR.Cast(S.Multishot) then return ""; end
    end
    -- sentinel,if=!debuff.hunters_mark.up
    if S.Sentinel:IsCastableP() and (not TargetDebuffP(S.HuntersMarkDebuff)) then
      if AR.Cast(S.Sentinel) then return ""; end
    end
    -- black_arrow,if=talent.sidewinders.enabled|spell_targets.multishot<6
    if S.BlackArrow:IsCastableP() and (S.Sidewinders:IsAvailable() or Cache.EnemiesCount[40] < 6) then
      if AR.Cast(S.BlackArrow) then return ""; end
    end
    -- a_murder_of_crows,if=target.time_to_die>=cooldown+duration|target.health.pct<20
    if S.AMurderofCrows:IsCastableP() and (Target:TimeToDie() >= S.AMurderofCrows:Cooldown() + S.AMurderofCrows:BaseDuration() or Target:HealthPercentage() < 20) then
      if AR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- windburst
    if S.Windburst:IsCastableP() and (true) then
      if AR.Cast(S.Windburst) then return ""; end
    end
    -- barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 2 or (Target:HealthPercentage() < 20 and Player:BuffStackP(S.BullseyeBuff) < 25)) then
      if AR.Cast(S.Barrage) then return ""; end
    end
    -- marked_shot,if=buff.marking_targets.up|buff.trueshot.up
    if S.MarkedShot:IsCastableP() and (Player:BuffP(S.MarkingTargetsBuff) or Player:BuffP(S.TrueshotBuff)) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- sidewinders,if=!variable.waiting_for_sentinel&(debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down))&((buff.marking_targets.up|buff.trueshot.up)|charges_fractional>1.8)&(focus.deficit>cast_regen)
    if S.Sidewinders:IsCastableP() and (not bool(VarWaitingForSentinel) and (Target:DebuffDownP(S.HuntersMarkDebuff) or (Player:BuffDownP(S.TrueshotBuff) and Player:BuffDownP(S.MarkingTargetsBuff))) and ((Player:BuffP(S.MarkingTargetsBuff) or Player:BuffP(S.TrueshotBuff)) or S.Sidewinders:ChargesFractional() > 1.8) and (Player:FocusDeficit() > Player:FocusCastRegen(S.Sidewinders:ExecuteTime()))) then
      if AR.Cast(S.Sidewinders) then return ""; end
    end
    -- aimed_shot,if=talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time
    if S.AimedShot:IsCastableP() and (S.Sidewinders:IsAvailable() and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime()) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(buff.lock_and_load.up&lowest_vuln_within.5>gcd.max))&(spell_targets.multishot<5|talent.trick_shot.enabled|buff.sentinels_sight.stack=20)
    if S.AimedShot:IsCastableP() and (not S.Sidewinders:IsAvailable() and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() and (not bool(VarPoolingForPiercing) or (Player:BuffP(S.LockandLoadBuff) and TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) and (Cache.EnemiesCount[40] < 5 or S.TrickShot:IsAvailable() or Player:BuffStackP(S.SentinelsSightBuff) == 20)) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- marked_shot
    if S.MarkedShot:IsCastableP() and (true) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- aimed_shot,if=focus+cast_regen>focus.max&!buff.sentinels_sight.up
    if S.AimedShot:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) > Player:FocusMax() and not Player:BuffP(S.SentinelsSightBuff)) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- multishot,if=spell_targets.multishot>1&!variable.waiting_for_sentinel
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not bool(VarWaitingForSentinel)) then
      if AR.Cast(S.Multishot) then return ""; end
    end
    -- arcane_shot,if=spell_targets.multishot=1&!variable.waiting_for_sentinel
    if S.ArcaneShot:IsCastableP() and (Cache.EnemiesCount[40] == 1 and not bool(VarWaitingForSentinel)) then
      if AR.Cast(S.ArcaneShot) then return ""; end
    end
  end
  local function PatientSniper()
    -- variable,name=vuln_window,op=setif,value=cooldown.sidewinders.full_recharge_time,value_else=debuff.vulnerability.remains,condition=talent.sidewinders.enabled&cooldown.sidewinders.full_recharge_time<debuff.vulnerability.remains
    if (S.Sidewinders:IsAvailable() and S.Sidewinders:FullRechargeTime() < TargetDebuffRemainsP(S.VulnerabilityDebuff)) then
      VarVulnWindow = S.Sidewinders:FullRechargeTime()
    else
      VarVulnWindow = TargetDebuffRemainsP(S.VulnerabilityDebuff)
    end
    -- variable,name=vuln_aim_casts,op=set,value=floor(variable.vuln_window%action.aimed_shot.execute_time)
    if (true) then
      VarVulnAimCasts = math.floor (VarVulnWindow / S.AimedShot:ExecuteTime())
    end
    -- variable,name=vuln_aim_casts,op=set,value=floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost),if=variable.vuln_aim_casts>0&variable.vuln_aim_casts>floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost)
    if (VarVulnAimCasts > 0 and VarVulnAimCasts > math.floor ((Player:Focus() + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) * (VarVulnAimCasts - 1)) / S.AimedShot:Cost())) then
      VarVulnAimCasts = math.floor ((Player:Focus() + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) * (VarVulnAimCasts - 1)) / S.AimedShot:Cost())
    end
    -- variable,name=can_gcd,value=variable.vuln_window<action.aimed_shot.cast_time|variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max+0.1
    if (true) then
      VarCanGcd = num(VarVulnWindow < S.AimedShot:CastTime() or VarVulnWindow > VarVulnAimCasts * S.AimedShot:ExecuteTime() + Player:GCD() + 0.1)
    end
    -- call_action_list,name=targetdie,if=target.time_to_die<variable.vuln_window&spell_targets.multishot=1
    if (Target:TimeToDie() < VarVulnWindow and Cache.EnemiesCount[40] == 1) then
      local ShouldReturn = Targetdie(); if ShouldReturn then return ShouldReturn; end
    end
    -- piercing_shot,if=cooldown.piercing_shot.up&spell_targets=1&lowest_vuln_within.5>0&lowest_vuln_within.5<1
    if S.PiercingShot:IsCastableP() and (S.PiercingShot:CooldownUpP() and Cache.EnemiesCount[40] == 1 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > 0 and TargetDebuffRemainsP(S.VulnerabilityDebuff) < 1) then
      if AR.Cast(S.PiercingShot) then return ""; end
    end
    -- piercing_shot,if=cooldown.piercing_shot.up&spell_targets>1&lowest_vuln_within.5>0&((!buff.trueshot.up&focus>80&(lowest_vuln_within.5<1|debuff.hunters_mark.up))|(buff.trueshot.up&focus>105&lowest_vuln_within.5<6))
    if S.PiercingShot:IsCastableP() and (S.PiercingShot:CooldownUpP() and Cache.EnemiesCount[40] > 1 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > 0 and ((not Player:BuffP(S.TrueshotBuff) and Player:Focus() > 80 and (TargetDebuffRemainsP(S.VulnerabilityDebuff) < 1 or TargetDebuffP(S.HuntersMarkDebuff))) or (Player:BuffP(S.TrueshotBuff) and Player:Focus() > 105 and TargetDebuffRemainsP(S.VulnerabilityDebuff) < 6))) then
      if AR.Cast(S.PiercingShot) then return ""; end
    end
    -- aimed_shot,if=spell_targets>1&talent.trick_shot.enabled&debuff.vulnerability.remains>cast_time&(buff.sentinels_sight.stack>=spell_targets.multishot*5|buff.sentinels_sight.stack+(spell_targets.multishot%2)>20|buff.lock_and_load.up|(set_bonus.tier20_2pc&!buff.t20_2p_critical_aimed_damage.up&action.aimed_shot.in_flight))
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and S.TrickShot:IsAvailable() and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() and (Player:BuffStackP(S.SentinelsSightBuff) >= Cache.EnemiesCount[40] * 5 or Player:BuffStackP(S.SentinelsSightBuff) + (Cache.EnemiesCount[40] / 2) > 20 or Player:BuffP(S.LockandLoadBuff) or (AC.Tier20_2Pc and not Player:BuffP(S.T202PCriticalAimedDamageBuff) and S.AimedShot:InFlight()))) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- marked_shot,if=spell_targets>1
    if S.MarkedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (Player:BuffP(S.MarkingTargetsBuff) or Player:BuffP(S.TrueshotBuff))) then
      if AR.Cast(S.Multishot) then return ""; end
    end
    -- windburst,if=variable.vuln_aim_casts<1&!variable.pooling_for_piercing
    if S.Windburst:IsCastableP() and (VarVulnAimCasts < 1 and not bool(VarPoolingForPiercing)) then
      if AR.Cast(S.Windburst) then return ""; end
    end
    -- black_arrow,if=variable.can_gcd&(!variable.pooling_for_piercing|(lowest_vuln_within.5>gcd.max&focus>85))
    if S.BlackArrow:IsCastableP() and (bool(VarCanGcd) and (not bool(VarPoolingForPiercing) or (TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD() and Player:Focus() > 85))) then
      if AR.Cast(S.BlackArrow) then return ""; end
    end
    -- a_murder_of_crows,if=(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(target.time_to_die>=cooldown+duration|target.health.pct<20|target.time_to_die<16)&variable.vuln_aim_casts=0
    if S.AMurderofCrows:IsCastableP() and ((not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD()) and (Target:TimeToDie() >= S.AMurderofCrows:Cooldown() + S.AMurderofCrows:BaseDuration() or Target:HealthPercentage() < 20 or Target:TimeToDie() < 16) and VarVulnAimCasts == 0) then
      if AR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 2 or (Target:HealthPercentage() < 20 and Player:BuffStackP(S.BullseyeBuff) < 25)) then
      if AR.Cast(S.Barrage) then return ""; end
    end
    -- aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
    if S.AimedShot:IsCastableP() and (TargetDebuffP(S.VulnerabilityDebuff) and Player:BuffP(S.LockandLoadBuff) and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- aimed_shot,if=spell_targets.multishot>1&debuff.vulnerability.remains>execute_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:ExecuteTime() and (not bool(VarPoolingForPiercing) or (Player:Focus() > 100 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > (S.AimedShot:ExecuteTime() + Player:GCD())))) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- multishot,if=spell_targets>1&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and bool(VarCanGcd) and Player:Focus() + Player:FocusCastRegen(S.Multishot:ExecuteTime()) + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) < Player:FocusMax() and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) then
      if AR.Cast(S.Multishot) then return ""; end
    end
    -- arcane_shot,if=spell_targets.multishot=1&(!set_bonus.tier20_2pc|!action.aimed_shot.in_flight|buff.t20_2p_critical_aimed_damage.remains>action.aimed_shot.cast_time+gcd)&(variable.vuln_aim_casts>0|action.windburst.in_flight&!set_bonus.tier21_4pc)&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd)
    if S.ArcaneShot:IsCastableP() and (Cache.EnemiesCount[40] == 1 and (not AC.Tier20_2Pc or not S.AimedShot:InFlight() or Player:BuffRemainsP(S.T202PCriticalAimedDamageBuff) > S.AimedShot:CastTime() + Player:GCD()) and (VarVulnAimCasts > 0 or S.Windburst:InFlight() and not AC.Tier21_4Pc) and bool(VarCanGcd) and Player:Focus() + Player:FocusCastRegen(S.ArcaneShot:ExecuteTime()) + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) < Player:FocusMax() and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) then
      if AR.Cast(S.ArcaneShot) then return ""; end
    end
    -- aimed_shot,if=talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight))&(variable.vuln_window-(execute_time*variable.vuln_aim_casts)<1|focus.deficit<=cast_regen|buff.trueshot.up)&(spell_targets.multishot=1|focus>100)
    if S.AimedShot:IsCastableP() and (S.Sidewinders:IsAvailable() and (TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() or (Player:BuffDownP(S.LockandLoadBuff) and S.Windburst:InFlight())) and (VarVulnWindow - (S.AimedShot:ExecuteTime() * VarVulnAimCasts) < 1 or Player:FocusDeficit() <= Player:FocusCastRegen(S.AimedShot:ExecuteTime()) or Player:BuffP(S.TrueshotBuff)) and (Cache.EnemiesCount[40] == 1 or Player:Focus() > 100)) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- aimed_shot,if=!talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight&(!set_bonus.tier21_4pc|debuff.hunters_mark.down)))&(!variable.pooling_for_piercing|lowest_vuln_within.5>execute_time+gcd.max)
    if S.AimedShot:IsCastableP() and (not S.Sidewinders:IsAvailable() and (TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() or (Player:BuffDownP(S.LockandLoadBuff) and S.Windburst:InFlight() and (not AC.Tier21_4Pc or Target:DebuffDownP(S.HuntersMarkDebuff)))) and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:ExecuteTime() + Player:GCD())) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- marked_shot,if=!talent.sidewinders.enabled&!variable.pooling_for_piercing&(!action.windburst.in_flight|set_bonus.tier21_4pc)&((focus>65|buff.trueshot.up|(1%attack_haste)>1.217|(1%attack_haste)>1.171&set_bonus.tier20_4pc)|set_bonus.tier21_4pc&!set_bonus.tier20_2pc)
    if S.MarkedShot:IsCastableP() and (not S.Sidewinders:IsAvailable() and not bool(VarPoolingForPiercing) and (not S.Windburst:InFlight() or AC.Tier21_4Pc) and ((Player:Focus() > 65 or Player:BuffP(S.TrueshotBuff) or (1 / attack_haste) > 1.217 or (1 / attack_haste) > 1.171 and AC.Tier20_4Pc) or AC.Tier21_4Pc and not AC.Tier20_2Pc)) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- marked_shot,if=talent.sidewinders.enabled&(variable.vuln_aim_casts<1|buff.trueshot.up|variable.vuln_window<action.aimed_shot.cast_time)
    if S.MarkedShot:IsCastableP() and (S.Sidewinders:IsAvailable() and (VarVulnAimCasts < 1 or Player:BuffP(S.TrueshotBuff) or VarVulnWindow < S.AimedShot:CastTime())) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- aimed_shot,if=focus+cast_regen>focus.max&buff.lock_and_load.down&!buff.sentinels_sight.up
    if S.AimedShot:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.AimedShot:ExecuteTime()) > Player:FocusMax() and Player:BuffDownP(S.LockandLoadBuff) and not Player:BuffP(S.SentinelsSightBuff)) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- sidewinders,if=(!debuff.hunters_mark.up|(!buff.marking_targets.up&!buff.trueshot.up))&((buff.marking_targets.up&variable.vuln_aim_casts<1)|buff.trueshot.up|charges_fractional>1.9)
    if S.Sidewinders:IsCastableP() and ((not TargetDebuffP(S.HuntersMarkDebuff) or (not Player:BuffP(S.MarkingTargetsBuff) and not Player:BuffP(S.TrueshotBuff))) and ((Player:BuffP(S.MarkingTargetsBuff) and VarVulnAimCasts < 1) or Player:BuffP(S.TrueshotBuff) or S.Sidewinders:ChargesFractional() > 1.9)) then
      if AR.Cast(S.Sidewinders) then return ""; end
    end
    -- arcane_shot,if=spell_targets.multishot=1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
    if S.ArcaneShot:IsCastableP() and (Cache.EnemiesCount[40] == 1 and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) then
      if AR.Cast(S.ArcaneShot) then return ""; end
    end
    -- multishot,if=spell_targets>1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (not bool(VarPoolingForPiercing) or TargetDebuffRemainsP(S.VulnerabilityDebuff) > Player:GCD())) then
      if AR.Cast(S.Multishot) then return ""; end
    end
  end
  local function Targetdie()
    -- piercing_shot,if=debuff.vulnerability.up
    if S.PiercingShot:IsCastableP() and (TargetDebuffP(S.VulnerabilityDebuff)) then
      if AR.Cast(S.PiercingShot) then return ""; end
    end
    -- windburst
    if S.Windburst:IsCastableP() and (true) then
      if AR.Cast(S.Windburst) then return ""; end
    end
    -- aimed_shot,if=debuff.vulnerability.remains>cast_time&target.time_to_die>cast_time
    if S.AimedShot:IsCastableP() and (TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.AimedShot:CastTime() and Target:TimeToDie() > S.AimedShot:CastTime()) then
      if AR.Cast(S.AimedShot) then return ""; end
    end
    -- marked_shot
    if S.MarkedShot:IsCastableP() and (true) then
      if AR.Cast(S.MarkedShot) then return ""; end
    end
    -- arcane_shot
    if S.ArcaneShot:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneShot) then return ""; end
    end
    -- sidewinders
    if S.Sidewinders:IsCastableP() and (true) then
      if AR.Cast(S.Sidewinders) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_shot
  -- counter_shot,if=target.debuff.casting.react
  if S.CounterShot:IsCastableP() and (Target:IsCasting()) then
    if AR.Cast(S.CounterShot) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- volley,toggle=on
  if S.Volley:IsCastableP() and (true) then
    if AR.Cast(S.Volley) then return ""; end
  end
  -- variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
  if (true) then
    VarPoolingForPiercing = num(S.PiercingShot:IsAvailable() and S.PiercingShot:CooldownRemainsP() < 5 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > 0 and TargetDebuffRemainsP(S.VulnerabilityDebuff) > S.PiercingShot:CooldownRemainsP() and (Player:BuffDownP(S.TrueshotBuff) or Cache.EnemiesCount[40] == 1))
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
  if (S.PatientSniper:IsAvailable()) then
    local ShouldReturn = PatientSniper(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
  if (not S.PatientSniper:IsAvailable()) then
    local ShouldReturn = NonPatientSniper(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(254, APL)
