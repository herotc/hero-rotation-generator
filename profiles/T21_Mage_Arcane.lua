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
if not Spell.Mage then Spell.Mage = {} end
Spell.Mage.Arcane = {
  ArcaneOrb                             = Spell(153626),
  ArcaneMissiles                        = Spell(5143),
  ArcaneMissilesBuff                    = Spell(79683),
  ArcaneChargeBuff                      = Spell(36032),
  ArcaneExplosion                       = Spell(1449),
  ArcaneBlast                           = Spell(30451),
  StartBurnPhase                        = Spell(),
  StopBurnPhase                         = Spell(),
  Evocation                             = Spell(12051),
  NetherTempest                         = Spell(114923),
  MarkofAluneth                         = Spell(224968),
  MirrorImage                           = Spell(55342),
  RuneofPower                           = Spell(116011),
  ArcanePowerBuff                       = Spell(12042),
  ArcanePower                           = Spell(12042),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  BerserkingBuff                        = Spell(26297),
  BloodFuryBuff                         = Spell(20572),
  UseItems                              = Spell(),
  ArcaneBarrage                         = Spell(44425),
  PresenceofMind                        = Spell(205025),
  ChargedUp                             = Spell(205032),
  ExpandingMindBuff                     = Spell(253262),
  RuneofPowerBuff                       = Spell(116014),
  PresenceofMindBuff                    = Spell(205025),
  StrictSequence                        = Spell(),
  Supernova                             = Spell(157980),
  RhoninsAssaultingArmwrapsBuff         = Spell(208081),
  Counterspell                          = Spell(2139),
  TimeWarp                              = Spell(80353),
  PotionBuff                            = Spell(),
  Potion                                = Spell()
};
local S = Spell.Mage.Arcane;

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Arcane = {
  DeadlyGrace                      = Item(127843),
  MantleoftheFirstKirinTor         = Item(248098),
  MysticKiltoftheRuneMaster        = Item(209280)
};
local I = Item.Mage.Arcane;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Mage.Commons,
  Arcane = AR.GUISettings.APL.Mage.Arcane
};

-- Variables
local TotalBurns = 0;
local AverageBurnLength = 0;
local ArcaneMissilesProcs = 0;
local TimeUntilBurn = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Build()
    -- arcane_orb
    if S.ArcaneOrb:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneOrb) then return ""; end
    end
    -- arcane_missiles,if=active_enemies<3&(variable.arcane_missiles_procs=buff.arcane_missiles.max_stack|(variable.arcane_missiles_procs&mana.pct<=50&buff.arcane_charge.stack=3)),chain=1
    if S.ArcaneMissiles:IsCastableP() and (active_enemies < 3 and (ArcaneMissilesProcs == buff.arcane_missiles.max_stack or (bool(ArcaneMissilesProcs) and Player:ManaPercentage() <= 50 and Player:BuffStackP(S.ArcaneChargeBuff) == 3))) then
      if AR.Cast(S.ArcaneMissiles) then return ""; end
    end
    -- arcane_explosion,if=active_enemies>1
    if S.ArcaneExplosion:IsCastableP() and (active_enemies > 1) then
      if AR.Cast(S.ArcaneExplosion) then return ""; end
    end
    -- arcane_blast
    if S.ArcaneBlast:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneBlast) then return ""; end
    end
  end
  local function Burn()
    -- variable,name=total_burns,op=add,value=1,if=!burn_phase
    if (not bool(burn_phase)) then
      TotalBurns = TotalBurns + 1
    end
    -- start_burn_phase,if=!burn_phase
    if S.StartBurnPhase:IsCastableP() and (not bool(burn_phase)) then
      if AR.Cast(S.StartBurnPhase) then return ""; end
    end
    -- stop_burn_phase,if=prev_gcd.1.evocation&cooldown.evocation.charges=0&burn_phase_duration>0
    if S.StopBurnPhase:IsCastableP() and (Player:PrevGCDP(1, S.Evocation) and S.Evocation:ChargesP() == 0 and burn_phase_duration > 0) then
      if AR.Cast(S.StopBurnPhase) then return ""; end
    end
    -- nether_tempest,if=refreshable|!ticking
    if S.NetherTempest:IsCastableP() and (bool(refreshable) or not bool(ticking)) then
      if AR.Cast(S.NetherTempest) then return ""; end
    end
    -- mark_of_aluneth
    if S.MarkofAluneth:IsCastableP() and (true) then
      if AR.Cast(S.MarkofAluneth) then return ""; end
    end
    -- mirror_image
    if S.MirrorImage:IsCastableP() and (true) then
      if AR.Cast(S.MirrorImage) then return ""; end
    end
    -- rune_of_power,if=mana.pct>30|(buff.arcane_power.up|cooldown.arcane_power.up)
    if S.RuneofPower:IsCastableP() and (Player:ManaPercentage() > 30 or (Player:BuffP(S.ArcanePowerBuff) or S.ArcanePower:CooldownUpP())) then
      if AR.Cast(S.RuneofPower) then return ""; end
    end
    -- arcane_power
    if S.ArcanePower:IsCastableP() and (true) then
      if AR.Cast(S.ArcanePower) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Arcane.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Arcane.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.ArcaneTorrent, Settings.Arcane.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- potion,if=buff.arcane_power.up&(buff.berserking.up|buff.blood_fury.up|!(race.troll|race.orc))
    if I.DeadlyGrace:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.ArcanePowerBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not ((Player:Race() == "Troll") or (Player:Race() == "Orc")))) then
      if AR.CastSuggested(I.DeadlyGrace) then return ""; end
    end
    -- use_items,if=buff.arcane_power.up|target.time_to_die<cooldown.arcane_power.remains
    if S.UseItems:IsCastableP() and (Player:BuffP(S.ArcanePowerBuff) or Target:TimeToDie() < S.ArcanePower:CooldownRemainsP()) then
      if AR.Cast(S.UseItems) then return ""; end
    end
    -- arcane_barrage,if=set_bonus.tier21_2pc&((set_bonus.tier20_2pc&cooldown.presence_of_mind.up)|(talent.charged_up.enabled&cooldown.charged_up.up))&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.expanding_mind.down
    if S.ArcaneBarrage:IsCastableP() and (AC.Tier21_2Pc and ((AC.Tier20_2Pc and S.PresenceofMind:CooldownUpP()) or (S.ChargedUp:IsAvailable() and S.ChargedUp:CooldownUpP())) and Player:BuffStackP(S.ArcaneChargeBuff) == buff.arcane_charge.max_stack and Player:BuffDownP(S.ExpandingMindBuff)) then
      if AR.Cast(S.ArcaneBarrage) then return ""; end
    end
    -- presence_of_mind,if=((mana.pct>30|buff.arcane_power.up)&set_bonus.tier20_2pc)|buff.rune_of_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time|buff.arcane_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time
    if S.PresenceofMind:IsCastableP() and (((Player:ManaPercentage() > 30 or Player:BuffP(S.ArcanePowerBuff)) and AC.Tier20_2Pc) or Player:BuffRemainsP(S.RuneofPowerBuff) <= buff.presence_of_mind.max_stack * S.ArcaneBlast:ExecuteTime() or Player:BuffRemainsP(S.ArcanePowerBuff) <= buff.presence_of_mind.max_stack * S.ArcaneBlast:ExecuteTime()) then
      if AR.Cast(S.PresenceofMind) then return ""; end
    end
    -- charged_up,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack
    if S.ChargedUp:IsCastableP() and (Player:BuffStackP(S.ArcaneChargeBuff) < buff.arcane_charge.max_stack) then
      if AR.Cast(S.ChargedUp) then return ""; end
    end
    -- arcane_orb
    if S.ArcaneOrb:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneOrb) then return ""; end
    end
    -- arcane_barrage,if=active_enemies>4&equipped.mantle_of_the_first_kirin_tor&buff.arcane_charge.stack=buff.arcane_charge.max_stack
    if S.ArcaneBarrage:IsCastableP() and (active_enemies > 4 and I.MantleoftheFirstKirinTor:IsEquipped() and Player:BuffStackP(S.ArcaneChargeBuff) == buff.arcane_charge.max_stack) then
      if AR.Cast(S.ArcaneBarrage) then return ""; end
    end
    -- arcane_missiles,if=variable.arcane_missiles_procs=buff.arcane_missiles.max_stack&active_enemies<3,chain=1
    if S.ArcaneMissiles:IsCastableP() and (ArcaneMissilesProcs == buff.arcane_missiles.max_stack and active_enemies < 3) then
      if AR.Cast(S.ArcaneMissiles) then return ""; end
    end
    -- arcane_blast,if=buff.presence_of_mind.up
    if S.ArcaneBlast:IsCastableP() and (Player:BuffP(S.PresenceofMindBuff)) then
      if AR.Cast(S.ArcaneBlast) then return ""; end
    end
    -- arcane_explosion,if=active_enemies>1
    if S.ArcaneExplosion:IsCastableP() and (active_enemies > 1) then
      if AR.Cast(S.ArcaneExplosion) then return ""; end
    end
    -- arcane_missiles,if=variable.arcane_missiles_procs>1,chain=1
    if S.ArcaneMissiles:IsCastableP() and (ArcaneMissilesProcs > 1) then
      if AR.Cast(S.ArcaneMissiles) then return ""; end
    end
    -- arcane_blast
    if S.ArcaneBlast:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneBlast) then return ""; end
    end
    -- variable,name=average_burn_length,op=set,value=(variable.average_burn_length*variable.total_burns-variable.average_burn_length+burn_phase_duration)%variable.total_burns
    if (true) then
      AverageBurnLength = (AverageBurnLength * TotalBurns - AverageBurnLength + burn_phase_duration) / TotalBurns
    end
    -- evocation,interrupt_if=ticks=2|mana.pct>=85,interrupt_immediate=1
    if S.Evocation:IsCastableP() and (true) then
      if AR.Cast(S.Evocation) then return ""; end
    end
  end
  local function Conserve()
    -- mirror_image,if=variable.time_until_burn>recharge_time|variable.time_until_burn>target.time_to_die
    if S.MirrorImage:IsCastableP() and (TimeUntilBurn > S.MirrorImage:RechargeP() or TimeUntilBurn > Target:TimeToDie()) then
      if AR.Cast(S.MirrorImage) then return ""; end
    end
    -- mark_of_aluneth,if=mana.pct<85
    if S.MarkofAluneth:IsCastableP() and (Player:ManaPercentage() < 85) then
      if AR.Cast(S.MarkofAluneth) then return ""; end
    end
    -- strict_sequence,name=miniburn,if=talent.rune_of_power.enabled&set_bonus.tier20_4pc&variable.time_until_burn>30:rune_of_power:arcane_barrage:presence_of_mind
    if S.StrictSequence:IsCastableP() and (S.RuneofPower:IsAvailable() and AC.Tier20_4Pc and TimeUntilBurn > 30:rune_of_power:arcane_barrage:presence_of_mind) then
      if AR.Cast(S.StrictSequence) then return ""; end
    end
    -- rune_of_power,if=full_recharge_time<=execute_time|prev_gcd.1.mark_of_aluneth
    if S.RuneofPower:IsCastableP() and (S.RuneofPower:FullRechargeTimeP() <= S.RuneofPower:ExecuteTime() or Player:PrevGCDP(1, S.MarkofAluneth)) then
      if AR.Cast(S.RuneofPower) then return ""; end
    end
    -- strict_sequence,name=abarr_cu_combo,if=talent.charged_up.enabled&cooldown.charged_up.recharge_time<variable.time_until_burn:arcane_barrage:charged_up
    if S.StrictSequence:IsCastableP() and (S.ChargedUp:IsAvailable() and S.ChargedUp:RechargeP() < TimeUntilBurn:ArcaneBarrage:ChargedUp) then
      if AR.Cast(S.StrictSequence) then return ""; end
    end
    -- arcane_missiles,if=variable.arcane_missiles_procs=buff.arcane_missiles.max_stack&active_enemies<3,chain=1
    if S.ArcaneMissiles:IsCastableP() and (ArcaneMissilesProcs == buff.arcane_missiles.max_stack and active_enemies < 3) then
      if AR.Cast(S.ArcaneMissiles) then return ""; end
    end
    -- supernova
    if S.Supernova:IsCastableP() and (true) then
      if AR.Cast(S.Supernova) then return ""; end
    end
    -- nether_tempest,if=refreshable|!ticking
    if S.NetherTempest:IsCastableP() and (bool(refreshable) or not bool(ticking)) then
      if AR.Cast(S.NetherTempest) then return ""; end
    end
    -- arcane_explosion,if=active_enemies>1&(mana.pct>=70-(10*equipped.mystic_kilt_of_the_rune_master))
    if S.ArcaneExplosion:IsCastableP() and (active_enemies > 1 and (Player:ManaPercentage() >= 70 - (10 * num(I.MysticKiltoftheRuneMaster:IsEquipped())))) then
      if AR.Cast(S.ArcaneExplosion) then return ""; end
    end
    -- arcane_blast,if=mana.pct>=90|buff.rhonins_assaulting_armwraps.up|(buff.rune_of_power.remains>=cast_time&equipped.mystic_kilt_of_the_rune_master)
    if S.ArcaneBlast:IsCastableP() and (Player:ManaPercentage() >= 90 or Player:BuffP(S.RhoninsAssaultingArmwrapsBuff) or (Player:BuffRemainsP(S.RuneofPowerBuff) >= S.ArcaneBlast:CastTime() and I.MysticKiltoftheRuneMaster:IsEquipped())) then
      if AR.Cast(S.ArcaneBlast) then return ""; end
    end
    -- arcane_missiles,if=variable.arcane_missiles_procs,chain=1
    if S.ArcaneMissiles:IsCastableP() and (bool(ArcaneMissilesProcs)) then
      if AR.Cast(S.ArcaneMissiles) then return ""; end
    end
    -- arcane_barrage
    if S.ArcaneBarrage:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneBarrage) then return ""; end
    end
    -- arcane_explosion,if=active_enemies>1
    if S.ArcaneExplosion:IsCastableP() and (active_enemies > 1) then
      if AR.Cast(S.ArcaneExplosion) then return ""; end
    end
    -- arcane_blast
    if S.ArcaneBlast:IsCastableP() and (true) then
      if AR.Cast(S.ArcaneBlast) then return ""; end
    end
  end
  local function Variables()
    -- variable,name=arcane_missiles_procs,op=set,value=buff.arcane_missiles.react
    if (true) then
      ArcaneMissilesProcs = Player:BuffStackP(S.ArcaneMissilesBuff)
    end
    -- variable,name=time_until_burn,op=set,value=cooldown.arcane_power.remains
    if (true) then
      TimeUntilBurn = S.ArcanePower:CooldownRemainsP()
    end
    -- variable,name=time_until_burn,op=max,value=cooldown.evocation.remains-variable.average_burn_length
    if (true) then
      TimeUntilBurn = math.max(TimeUntilBurn, S.Evocation:CooldownRemainsP() - AverageBurnLength)
    end
    -- variable,name=time_until_burn,op=max,value=cooldown.presence_of_mind.remains,if=set_bonus.tier20_2pc
    if (AC.Tier20_2Pc) then
      TimeUntilBurn = math.max(TimeUntilBurn, S.PresenceofMind:CooldownRemainsP())
    end
    -- variable,name=time_until_burn,op=max,value=action.rune_of_power.usable_in,if=talent.rune_of_power.enabled
    if (S.RuneofPower:IsAvailable()) then
      TimeUntilBurn = math.max(TimeUntilBurn, S.RuneofPower:UsableInP())
    end
    -- variable,name=time_until_burn,op=max,value=cooldown.charged_up.remains,if=talent.charged_up.enabled&set_bonus.tier21_2pc
    if (S.ChargedUp:IsAvailable() and AC.Tier21_2Pc) then
      TimeUntilBurn = math.max(TimeUntilBurn, S.ChargedUp:CooldownRemainsP())
    end
    -- variable,name=time_until_burn,op=reset,if=target.time_to_die<variable.average_burn_length
    if (Target:TimeToDie() < AverageBurnLength) then
      TimeUntilBurn = 0
    end
  end
  -- counterspell,if=target.debuff.casting.react
  if S.Counterspell:IsCastableP() and (bool(target.debuff.casting.react)) then
    if AR.Cast(S.Counterspell) then return ""; end
  end
  -- time_warp,if=buff.bloodlust.down&(time=0|(buff.arcane_power.up&(buff.potion.up|!action.potion.usable))|target.time_to_die<=buff.bloodlust.duration)
  if S.TimeWarp:IsCastableP() and (Player:HasNotHeroism() and (AC.CombatTime() == 0 or (Player:BuffP(S.ArcanePowerBuff) and (Player:BuffP(S.PotionBuff) or not bool(action.potion.usable))) or Target:TimeToDie() <= bloodlust:BaseDuration())) then
    if AR.Cast(S.TimeWarp) then return ""; end
  end
  -- call_action_list,name=variables
  if (true) then
    local ShouldReturn = Variables(); if ShouldReturn then return ShouldReturn; end
  end
  -- cancel_buff,name=presence_of_mind,if=active_enemies>1&set_bonus.tier20_2pc
  if (active_enemies > 1 and AC.Tier20_2Pc) then
    -- if AR.Cancel(S.PresenceofMindBuff) then return ""; end
  end
  -- call_action_list,name=build,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack&!burn_phase
  if (Player:BuffStackP(S.ArcaneChargeBuff) < buff.arcane_charge.max_stack and not bool(burn_phase)) then
    local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=burn,if=(buff.arcane_charge.stack=buff.arcane_charge.max_stack&variable.time_until_burn=0)|burn_phase
  if ((Player:BuffStackP(S.ArcaneChargeBuff) == buff.arcane_charge.max_stack and TimeUntilBurn == 0) or bool(burn_phase)) then
    local ShouldReturn = Burn(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=conserve
  if (true) then
    local ShouldReturn = Conserve(); if ShouldReturn then return ShouldReturn; end
  end
end