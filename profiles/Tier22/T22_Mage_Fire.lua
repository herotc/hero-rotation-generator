--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Mage then Spell.Mage = {} end
Spell.Mage.Fire = {
  ArcaneIntellectBuff                   = Spell(1459),
  ArcaneIntellect                       = Spell(1459),
  MirrorImage                           = Spell(55342),
  Pyroblast                             = Spell(11366),
  LivingBomb                            = Spell(44457),
  CombustionBuff                        = Spell(190319),
  Combustion                            = Spell(190319),
  Meteor                                = Spell(153561),
  RuneofPowerBuff                       = Spell(116014),
  RuneofPower                           = Spell(116011),
  DragonsBreath                         = Spell(31661),
  AlexstraszasFury                      = Spell(235870),
  HotStreakBuff                         = Spell(48108),
  FireBlast                             = Spell(108853),
  LightsJudgment                        = Spell(255647),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Flamestrike                           = Spell(2120),
  FlamePatch                            = Spell(205037),
  PyroclasmBuff                         = Spell(269651),
  HeatingUpBuff                         = Spell(48107),
  PhoenixFlames                         = Spell(257541),
  Scorch                                = Spell(2948),
  SearingTouch                          = Spell(269644),
  Fireball                              = Spell(133),
  Kindling                              = Spell(155148),
  Preheat                               = Spell(273331),
  PreheatDebuff                         = Spell(273333),
  Firestarter                           = Spell(205026)
};
local S = Spell.Mage.Fire;

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Fire = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Mage.Fire;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Mage.Commons,
  Fire = HR.GUISettings.APL.Mage.Fire
};

-- Variables
local VarCombustionRopCutoff = 0;
local VarPhoenixPooling = 0;
local VarFireBlastPooling = 0;

HL:RegisterForEvent(function()
  VarCombustionRopCutoff = 0
  VarPhoenixPooling = 0
  VarFireBlastPooling = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.Pyroblast:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

S.PhoenixFlames:RegisterInFlight();
S.Pyroblast:RegisterInFlight(S.CombustionBuff);
S.Fireball:RegisterInFlight(S.CombustionBuff);

function S.Firestarter:ActiveStatus()
    return (S.Firestarter:IsAvailable() and (Target:HealthPercentage() > 90)) and 1 or 0
end

function S.Firestarter:ActiveRemains()
    return S.Firestarter:IsAvailable() and ((Target:HealthPercentage() > 90) and Target:TimeToX(90, 3) or 0)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, ActiveTalents, CombustionPhase, RopPhase, StandardRotation
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
      if HR.Cast(S.ArcaneIntellect) then return "arcane_intellect 3"; end
    end
    -- variable,name=combustion_rop_cutoff,op=set,value=60
    if (true) then
      VarCombustionRopCutoff = 60
    end
    -- snapshot_stats
    -- mirror_image
    if S.MirrorImage:IsCastableP() then
      if HR.Cast(S.MirrorImage) then return "mirror_image 10"; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 12"; end
    end
    -- pyroblast
    if S.Pyroblast:IsCastableP() and Everyone.TargetIsValid() then
      if HR.Cast(S.Pyroblast) then return "pyroblast 14"; end
    end
  end
  ActiveTalents = function()
    -- living_bomb,if=active_enemies>1&buff.combustion.down&(cooldown.combustion.remains>cooldown.living_bomb.duration|cooldown.combustion.ready)
    if S.LivingBomb:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Player:BuffDownP(S.CombustionBuff) and (S.Combustion:CooldownRemainsP() > S.LivingBomb:BaseDuration() or S.Combustion:CooldownUpP())) then
      if HR.Cast(S.LivingBomb) then return "living_bomb 16"; end
    end
    -- meteor,if=buff.rune_of_power.up&(firestarter.remains>cooldown.meteor.duration|!firestarter.active)|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1|(cooldown.meteor.duration<cooldown.combustion.remains|cooldown.combustion.ready)&!talent.rune_of_power.enabled
    if S.Meteor:IsCastableP() and (Player:BuffP(S.RuneofPowerBuff) and (S.Firestarter:ActiveRemains() > S.Meteor:BaseDuration() or not bool(S.Firestarter:ActiveStatus())) or S.RuneofPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneofPower:ChargesP() < 1 or (S.Meteor:BaseDuration() < S.Combustion:CooldownRemainsP() or S.Combustion:CooldownUpP()) and not S.RuneofPower:IsAvailable()) then
      if HR.Cast(S.Meteor) then return "meteor 32"; end
    end
    -- dragons_breath,if=talent.alexstraszas_fury.enabled&(buff.combustion.down&!buff.hot_streak.react|buff.combustion.up&action.fire_blast.charges<action.fire_blast.max_charges&!buff.hot_streak.react)
    if S.DragonsBreath:IsCastableP() and (S.AlexstraszasFury:IsAvailable() and (Player:BuffDownP(S.CombustionBuff) and not bool(Player:BuffStackP(S.HotStreakBuff)) or Player:BuffP(S.CombustionBuff) and S.FireBlast:ChargesP() < S.FireBlast:MaxCharges() and not bool(Player:BuffStackP(S.HotStreakBuff)))) then
      if HR.Cast(S.DragonsBreath) then return "dragons_breath 54"; end
    end
  end
  CombustionPhase = function()
    -- lights_judgment,if=buff.combustion.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.CombustionBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 74"; end
    end
    -- rune_of_power,if=buff.combustion.down
    if S.RuneofPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      if HR.Cast(S.RuneofPower, Settings.Fire.GCDasOffGCD.RuneofPower) then return "rune_of_power 78"; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion
    if S.Combustion:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Combustion, Settings.Fire.OffGCDasOffGCD.Combustion) then return "combustion 84"; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 86"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 88"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 90"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 92"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 94"; end
    end
    -- use_items
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>2)|active_enemies>6)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2) or Cache.EnemiesCount[40] > 6) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if HR.Cast(S.Flamestrike) then return "flamestrike 97"; end
    end
    -- pyroblast,if=buff.pyroclasm.react&buff.combustion.remains>cast_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.PyroclasmBuff)) and Player:BuffRemainsP(S.CombustionBuff) > S.Pyroblast:CastTime()) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 115"; end
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff))) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 125"; end
    end
    -- fire_blast,if=buff.heating_up.react
    if S.FireBlast:IsCastableP() and (bool(Player:BuffStackP(S.HeatingUpBuff))) then
      if HR.Cast(S.FireBlast) then return "fire_blast 129"; end
    end
    -- phoenix_flames
    if S.PhoenixFlames:IsCastableP() then
      if HR.Cast(S.PhoenixFlames) then return "phoenix_flames 133"; end
    end
    -- scorch,if=buff.combustion.remains>cast_time
    if S.Scorch:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) > S.Scorch:CastTime()) then
      if HR.Cast(S.Scorch) then return "scorch 135"; end
    end
    -- living_bomb,if=buff.combustion.remains<gcd.max&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.LivingBomb) then return "living_bomb 143"; end
    end
    -- dragons_breath,if=buff.combustion.remains<gcd.max
    if S.DragonsBreath:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD()) then
      if HR.Cast(S.DragonsBreath) then return "dragons_breath 153"; end
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      if HR.Cast(S.Scorch) then return "scorch 157"; end
    end
  end
  RopPhase = function()
    -- rune_of_power
    if S.RuneofPower:IsCastableP() then
      if HR.Cast(S.RuneofPower, Settings.Fire.GCDasOffGCD.RuneofPower) then return "rune_of_power 161"; end
    end
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1) or Cache.EnemiesCount[40] > 4) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if HR.Cast(S.Flamestrike) then return "flamestrike 163"; end
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff))) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 181"; end
    end
    -- fire_blast,if=!buff.heating_up.react&!buff.hot_streak.react&!prev_off_gcd.fire_blast&(action.fire_blast.charges>=2|action.phoenix_flames.charges>=1|talent.alexstraszas_fury.enabled&cooldown.dragons_breath.ready|talent.searing_touch.enabled&target.health.pct<=30|firestarter.active)
    if S.FireBlast:IsCastableP() and (not bool(Player:BuffStackP(S.HeatingUpBuff)) and not bool(Player:BuffStackP(S.HotStreakBuff)) and not Player:PrevOffGCDP(1, S.FireBlast) and (S.FireBlast:ChargesP() >= 2 or S.PhoenixFlames:ChargesP() >= 1 or S.AlexstraszasFury:IsAvailable() and S.DragonsBreath:CooldownUpP() or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 or bool(S.Firestarter:ActiveStatus()))) then
      if HR.Cast(S.FireBlast) then return "fire_blast 185"; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains&buff.rune_of_power.remains>cast_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.PyroclasmBuff)) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff) and Player:BuffRemainsP(S.RuneofPowerBuff) > S.Pyroblast:CastTime()) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 209"; end
    end
    -- fire_blast,if=!prev_off_gcd.fire_blast&buff.heating_up.react
    if S.FireBlast:IsCastableP() and (not Player:PrevOffGCDP(1, S.FireBlast) and bool(Player:BuffStackP(S.HeatingUpBuff))) then
      if HR.Cast(S.FireBlast) then return "fire_blast 225"; end
    end
    -- phoenix_flames,if=!prev_gcd.1.phoenix_flames&buff.heating_up.react
    if S.PhoenixFlames:IsCastableP() and (not Player:PrevGCDP(1, S.PhoenixFlames) and bool(Player:BuffStackP(S.HeatingUpBuff))) then
      if HR.Cast(S.PhoenixFlames) then return "phoenix_flames 231"; end
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      if HR.Cast(S.Scorch) then return "scorch 237"; end
    end
    -- dragons_breath,if=active_enemies>2
    if S.DragonsBreath:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.DragonsBreath) then return "dragons_breath 241"; end
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2) or Cache.EnemiesCount[40] > 5) then
      if HR.Cast(S.Flamestrike) then return "flamestrike 249"; end
    end
    -- fireball
    if S.Fireball:IsCastableP() then
      if HR.Cast(S.Fireball) then return "fireball 265"; end
    end
  end
  StandardRotation = function()
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1&!firestarter.active)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1 and not bool(S.Firestarter:ActiveStatus())) or Cache.EnemiesCount[40] > 4) and bool(Player:BuffStackP(S.HotStreakBuff))) then
      if HR.Cast(S.Flamestrike) then return "flamestrike 267"; end
    end
    -- pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and Player:BuffRemainsP(S.HotStreakBuff) < S.Fireball:ExecuteTime()) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 285"; end
    end
    -- pyroblast,if=buff.hot_streak.react&(prev_gcd.1.fireball|firestarter.active|action.pyroblast.in_flight)
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and (Player:PrevGCDP(1, S.Fireball) or bool(S.Firestarter:ActiveStatus()) or S.Pyroblast:InFlight())) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 295"; end
    end
    -- phoenix_flames,if=charges>=3&active_enemies>2&!variable.phoenix_pooling
    if S.PhoenixFlames:IsCastableP() and (S.PhoenixFlames:ChargesP() >= 3 and Cache.EnemiesCount[40] > 2 and not bool(VarPhoenixPooling)) then
      if HR.Cast(S.PhoenixFlames) then return "phoenix_flames 305"; end
    end
    -- pyroblast,if=buff.hot_streak.react&target.health.pct<=30&talent.searing_touch.enabled
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.HotStreakBuff)) and Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 319"; end
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.PyroclasmBuff)) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff)) then
      if HR.Cast(S.Pyroblast) then return "pyroblast 325"; end
    end
    -- fire_blast,if=!talent.kindling.enabled&buff.heating_up.react&!variable.fire_blast_pooling|target.time_to_die<4
    if S.FireBlast:IsCastableP() and (not S.Kindling:IsAvailable() and bool(Player:BuffStackP(S.HeatingUpBuff)) and not bool(VarFireBlastPooling) or Target:TimeToDie() < 4) then
      if HR.Cast(S.FireBlast) then return "fire_blast 335"; end
    end
    -- fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(cooldown.combustion.remains>full_recharge_time+2+talent.kindling.enabled|firestarter.remains>full_recharge_time|(!talent.rune_of_power.enabled|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1)&cooldown.combustion.remains>target.time_to_die)
    if S.FireBlast:IsCastableP() and (S.Kindling:IsAvailable() and bool(Player:BuffStackP(S.HeatingUpBuff)) and (S.Combustion:CooldownRemainsP() > S.FireBlast:FullRechargeTimeP() + 2 + num(S.Kindling:IsAvailable()) or S.Firestarter:ActiveRemains() > S.FireBlast:FullRechargeTimeP() or (not S.RuneofPower:IsAvailable() or S.RuneofPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneofPower:ChargesP() < 1) and S.Combustion:CooldownRemainsP() > Target:TimeToDie())) then
      if HR.Cast(S.FireBlast) then return "fire_blast 343"; end
    end
    -- phoenix_flames,if=(buff.heating_up.react|(!buff.hot_streak.react&(action.fire_blast.charges>0|talent.searing_touch.enabled&target.health.pct<=30)))&!variable.phoenix_pooling
    if S.PhoenixFlames:IsCastableP() and ((bool(Player:BuffStackP(S.HeatingUpBuff)) or (not bool(Player:BuffStackP(S.HotStreakBuff)) and (S.FireBlast:ChargesP() > 0 or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30))) and not bool(VarPhoenixPooling)) then
      if HR.Cast(S.PhoenixFlames) then return "phoenix_flames 373"; end
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- dragons_breath,if=active_enemies>1
    if S.DragonsBreath:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.DragonsBreath) then return "dragons_breath 389"; end
    end
    -- scorch,if=(target.health.pct<=30&talent.searing_touch.enabled)|(azerite.preheat.enabled&debuff.preheat.down)
    if S.Scorch:IsCastableP() and ((Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) or (S.Preheat:AzeriteEnabled() and Target:DebuffDownP(S.PreheatDebuff))) then
      if HR.Cast(S.Scorch) then return "scorch 397"; end
    end
    -- fireball
    if S.Fireball:IsCastableP() then
      if HR.Cast(S.Fireball) then return "fireball 405"; end
    end
    -- scorch
    if S.Scorch:IsCastableP() then
      if HR.Cast(S.Scorch) then return "scorch 407"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- counterspell
    -- mirror_image,if=buff.combustion.down
    if S.MirrorImage:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      if HR.Cast(S.MirrorImage) then return "mirror_image 411"; end
    end
    -- rune_of_power,if=talent.firestarter.enabled&firestarter.remains>full_recharge_time|cooldown.combustion.remains>variable.combustion_rop_cutoff&buff.combustion.down|target.time_to_die<cooldown.combustion.remains&buff.combustion.down
    if S.RuneofPower:IsCastableP() and (S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > S.RuneofPower:FullRechargeTimeP() or S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and Player:BuffDownP(S.CombustionBuff) or Target:TimeToDie() < S.Combustion:CooldownRemainsP() and Player:BuffDownP(S.CombustionBuff)) then
      if HR.Cast(S.RuneofPower, Settings.Fire.GCDasOffGCD.RuneofPower) then return "rune_of_power 415"; end
    end
    -- call_action_list,name=combustion_phase,if=(talent.rune_of_power.enabled&cooldown.combustion.remains<=action.rune_of_power.cast_time|cooldown.combustion.ready)&!firestarter.active|buff.combustion.up
    if HR.CDsON() and ((S.RuneofPower:IsAvailable() and S.Combustion:CooldownRemainsP() <= S.RuneofPower:CastTime() or S.Combustion:CooldownUpP()) and not bool(S.Firestarter:ActiveStatus()) or Player:BuffP(S.CombustionBuff)) then
      local ShouldReturn = CombustionPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
    if (Player:BuffP(S.RuneofPowerBuff) and Player:BuffDownP(S.CombustionBuff)) then
      local ShouldReturn = RopPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- variable,name=fire_blast_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.fire_blast.full_recharge_time&(cooldown.combustion.remains>variable.combustion_rop_cutoff|firestarter.active)&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.fire_blast.full_recharge_time&!firestarter.active&cooldown.combustion.remains<target.time_to_die|talent.firestarter.enabled&firestarter.active&firestarter.remains<cooldown.fire_blast.full_recharge_time
    if (true) then
      VarFireBlastPooling = num(S.RuneofPower:IsAvailable() and S.RuneofPower:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() and (S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff or bool(S.Firestarter:ActiveStatus())) and (S.RuneofPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneofPower:ChargesP() > 0) or S.Combustion:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() and not bool(S.Firestarter:ActiveStatus()) and S.Combustion:CooldownRemainsP() < Target:TimeToDie() or S.Firestarter:IsAvailable() and bool(S.Firestarter:ActiveStatus()) and S.Firestarter:ActiveRemains() < S.FireBlast:FullRechargeTimeP())
    end
    -- variable,name=phoenix_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.phoenix_flames.full_recharge_time&cooldown.combustion.remains>variable.combustion_rop_cutoff&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.phoenix_flames.full_recharge_time&cooldown.combustion.remains<target.time_to_die
    if (true) then
      VarPhoenixPooling = num(S.RuneofPower:IsAvailable() and S.RuneofPower:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and (S.RuneofPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneofPower:ChargesP() > 0) or S.Combustion:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() < Target:TimeToDie())
    end
    -- call_action_list,name=standard_rotation
    if (true) then
      local ShouldReturn = StandardRotation(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(63, APL)
