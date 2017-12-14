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
if not Spell.Rogue then Spell.Rogue = {} end
Spell.Rogue.Assassination = {
  Hemorrhage                            = Spell(16511),
  RuptureDebuff                         = Spell(1943),
  FanofKnives                           = Spell(51723),
  TheDreadlordsDeceitBuff               = Spell(208692),
  Mutilate                              = Spell(1329),
  DeadlyPoisonDotDebuff                 = Spell(177918),
  VendettaDebuff                        = Spell(79140),
  Vanish                                = Spell(1856),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  KingsbaneDebuff                       = Spell(192759),
  EnvenomBuff                           = Spell(32645),
  MarkedForDeath                        = Spell(137619),
  Vendetta                              = Spell(79140),
  Exsanguinate                          = Spell(200806),
  Rupture                               = Spell(1943),
  GarroteDebuff                         = Spell(703),
  SubterfugeBuff                        = Spell(108208),
  Nightstalker                          = Spell(14062),
  Subterfuge                            = Spell(108208),
  ShadowFocus                           = Spell(108209),
  ToxicBlade                            = Spell(245388),
  DeathFromAbove                        = Spell(152150),
  Envenom                               = Spell(32645),
  DeeperStratagem                       = Spell(193531),
  SurgeofToxinsDebuff                   = Spell(192424),
  ElaboratePlanning                     = Spell(193640),
  ElaboratePlanningBuff                 = Spell(193641),
  Kingsbane                             = Spell(192759),
  SinisterCirculation                   = Spell(),
  MasterAssassin                        = Spell(),
  Garrote                               = Spell(703),
  ToxicBladeDebuff                      = Spell(245389),
  UrgeToKill                            = Spell(),
  Exanguinate                           = Spell(),
  PoolResource                          = Spell(9999000010),
  VenomRush                             = Spell(152152)
};
local S = Spell.Rogue.Assassination;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Assassination = {
  InsigniaofRavenholdt             = Item(137049),
  ProlongedPower                   = Item(142117),
  MantleoftheMasterAssassin        = Item(144236),
  DuskwalkersFootpads              = Item(137030),
  ConvergenceofFates               = Item(140806)
};
local I = Item.Rogue.Assassination;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Rogue.Commons,
  Assassination = AR.GUISettings.APL.Rogue.Assassination
};

-- Variables
local VarEnergyRegenCombined = 0;
local VarEnergyTimeToMaxCombined = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Build()
    -- hemorrhage,if=refreshable
    if S.Hemorrhage:IsCastableP() and (bool(refreshable)) then
      if AR.Cast(S.Hemorrhage) then return ""; end
    end
    -- hemorrhage,cycle_targets=1,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<2+equipped.insignia_of_ravenholdt
    if S.Hemorrhage:IsCastableP() and (bool(refreshable) and Target:DebuffP(S.RuptureDebuff) and Cache.EnemiesCount[10] < 2 + num(I.InsigniaofRavenholdt:IsEquipped())) then
      if AR.Cast(S.Hemorrhage) then return ""; end
    end
    -- fan_of_knives,if=spell_targets>=2+equipped.insignia_of_ravenholdt|buff.the_dreadlords_deceit.stack>=29
    if S.FanofKnives:IsCastableP() and (Cache.EnemiesCount[10] >= 2 + num(I.InsigniaofRavenholdt:IsEquipped()) or Player:BuffStackP(S.TheDreadlordsDeceitBuff) >= 29) then
      if AR.Cast(S.FanofKnives) then return ""; end
    end
    -- mutilate,cycle_targets=1,if=dot.deadly_poison_dot.refreshable
    if S.Mutilate:IsCastableP() and (bool(dot.deadly_poison_dot.refreshable)) then
      if AR.Cast(S.Mutilate) then return ""; end
    end
    -- mutilate
    if S.Mutilate:IsCastableP() and (true) then
      if AR.Cast(S.Mutilate) then return ""; end
    end
  end
  local function Cds()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or Target:DebuffP(S.VendettaDebuff) and S.Vanish:CooldownRemainsP() < 5) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury,if=debuff.vendetta.up
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if AR.Cast(S.BloodFury, Settings.Assassination.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking,if=debuff.vendetta.up
    if S.Berserking:IsCastableP() and AR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if AR.Cast(S.Berserking, Settings.Assassination.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=dot.kingsbane.ticking&!buff.envenom.up&energy.deficit>=15+variable.energy_regen_combined*gcd.remains*1.1
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Target:DebuffP(S.KingsbaneDebuff) and not Player:BuffP(S.EnvenomBuff) and Player:EnergyDeficit() >= 15 + VarEnergyRegenCombined * Player:GCDRemains() * 1.1) then
      if AR.Cast(S.ArcaneTorrent, Settings.Assassination.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
    if S.MarkedForDeath:IsCastableP() and (Target:TimeToDie() < Player:ComboPointsDeficit() * 1.5 or (raid_event.adds.in > 40 and Player:ComboPointsDeficit() >= cp_max_spend)) then
      if AR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- vendetta,if=!talent.exsanguinate.enabled|dot.rupture.ticking
    if S.Vendetta:IsCastableP() and (not S.Exsanguinate:IsAvailable() or Target:DebuffP(S.RuptureDebuff)) then
      if AR.Cast(S.Vendetta) then return ""; end
    end
    -- exsanguinate,if=!set_bonus.tier20_4pc&(prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend&!stealthed.rogue|dot.garrote.pmultiplier>1&!cooldown.vanish.up&buff.subterfuge.up)
    if S.Exsanguinate:IsCastableP() and (not AC.Tier20_4Pc and (Player:PrevGCDP(1, S.Rupture) and Target:DebuffRemainsP(S.RuptureDebuff) > 4 + 4 * cp_max_spend and not bool(stealthed.rogue) or dot.garrote.pmultiplier > 1 and not S.Vanish:CooldownUpP() and Player:BuffP(S.SubterfugeBuff))) then
      if AR.Cast(S.Exsanguinate) then return ""; end
    end
    -- exsanguinate,if=set_bonus.tier20_4pc&dot.garrote.remains>20&dot.rupture.remains>4+4*cp_max_spend
    if S.Exsanguinate:IsCastableP() and (AC.Tier20_4Pc and Target:DebuffRemainsP(S.GarroteDebuff) > 20 and Target:DebuffRemainsP(S.RuptureDebuff) > 4 + 4 * cp_max_spend) then
      if AR.Cast(S.Exsanguinate) then return ""; end
    end
    -- vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&!talent.exsanguinate.enabled&mantle_duration=0&((equipped.mantle_of_the_master_assassin&set_bonus.tier19_4pc)|((!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&(dot.rupture.refreshable|debuff.vendetta.up)))
    if S.Vanish:IsCastableP() and (S.Nightstalker:IsAvailable() and Player:ComboPoints() >= cp_max_spend and not S.Exsanguinate:IsAvailable() and mantle_duration == 0 and ((I.MantleoftheMasterAssassin:IsEquipped() and AC.Tier19_4Pc) or ((not I.MantleoftheMasterAssassin:IsEquipped() or not AC.Tier19_4Pc) and (bool(dot.rupture.refreshable) or Target:DebuffP(S.VendettaDebuff))))) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&(dot.rupture.ticking|time>10)
    if S.Vanish:IsCastableP() and (S.Nightstalker:IsAvailable() and Player:ComboPoints() >= cp_max_spend and S.Exsanguinate:IsAvailable() and S.Exsanguinate:CooldownRemainsP() < 1 and (Target:DebuffP(S.RuptureDebuff) or AC.CombatTime() > 10)) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- vanish,if=talent.subterfuge.enabled&equipped.mantle_of_the_master_assassin&(debuff.vendetta.up|target.time_to_die<10)&mantle_duration=0
    if S.Vanish:IsCastableP() and (S.Subterfuge:IsAvailable() and I.MantleoftheMasterAssassin:IsEquipped() and (Target:DebuffP(S.VendettaDebuff) or Target:TimeToDie() < 10) and mantle_duration == 0) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- vanish,if=talent.subterfuge.enabled&!equipped.mantle_of_the_master_assassin&!stealthed.rogue&dot.garrote.refreshable&((spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives)|(spell_targets.fan_of_knives>=4&combo_points.deficit>=4))
    if S.Vanish:IsCastableP() and (S.Subterfuge:IsAvailable() and not I.MantleoftheMasterAssassin:IsEquipped() and not bool(stealthed.rogue) and bool(dot.garrote.refreshable) and ((Cache.EnemiesCount[10] <= 3 and Player:ComboPointsDeficit() >= 1 + Cache.EnemiesCount[10]) or (Cache.EnemiesCount[10] >= 4 and Player:ComboPointsDeficit() >= 4))) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- vanish,if=talent.shadow_focus.enabled&variable.energy_time_to_max_combined>=2&combo_points.deficit>=4
    if S.Vanish:IsCastableP() and (S.ShadowFocus:IsAvailable() and VarEnergyTimeToMaxCombined >= 2 and Player:ComboPointsDeficit() >= 4) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- toxic_blade,if=combo_points.deficit>=1+(mantle_duration>=0.2)&dot.rupture.remains>8&cooldown.vendetta.remains>10
    if S.ToxicBlade:IsCastableP() and (Player:ComboPointsDeficit() >= 1 + num((mantle_duration >= 0.2)) and Target:DebuffRemainsP(S.RuptureDebuff) > 8 and S.Vendetta:CooldownRemainsP() > 10) then
      if AR.Cast(S.ToxicBlade) then return ""; end
    end
  end
  local function Finish()
    -- death_from_above,if=combo_points>=5
    if S.DeathFromAbove:IsCastableP() and (Player:ComboPoints() >= 5) then
      if AR.Cast(S.DeathFromAbove) then return ""; end
    end
    -- envenom,if=combo_points>=4+(talent.deeper_stratagem.enabled&!set_bonus.tier19_4pc)&(debuff.vendetta.up|mantle_duration>=0.2|debuff.surge_of_toxins.remains<0.2|energy.deficit<=25+variable.energy_regen_combined)
    if S.Envenom:IsCastableP() and (Player:ComboPoints() >= 4 + num((S.DeeperStratagem:IsAvailable() and not AC.Tier19_4Pc)) and (Target:DebuffP(S.VendettaDebuff) or mantle_duration >= 0.2 or Target:DebuffRemainsP(S.SurgeofToxinsDebuff) < 0.2 or Player:EnergyDeficit() <= 25 + VarEnergyRegenCombined)) then
      if AR.Cast(S.Envenom) then return ""; end
    end
    -- envenom,if=talent.elaborate_planning.enabled&combo_points>=3+!talent.exsanguinate.enabled&buff.elaborate_planning.remains<0.2
    if S.Envenom:IsCastableP() and (S.ElaboratePlanning:IsAvailable() and Player:ComboPoints() >= 3 + num(not S.Exsanguinate:IsAvailable()) and Player:BuffRemainsP(S.ElaboratePlanningBuff) < 0.2) then
      if AR.Cast(S.Envenom) then return ""; end
    end
  end
  local function Kb()
    -- kingsbane,if=artifact.sinister_circulation.enabled&!(equipped.duskwalkers_footpads&equipped.convergence_of_fates&artifact.master_assassin.rank>=6)&(time>25|!equipped.mantle_of_the_master_assassin|(debuff.vendetta.up&debuff.surge_of_toxins.up))&(talent.subterfuge.enabled|!stealthed.rogue|(talent.nightstalker.enabled&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)))
    if S.Kingsbane:IsCastableP() and (S.SinisterCirculation:ArtifactEnabled() and not (I.DuskwalkersFootpads:IsEquipped() and I.ConvergenceofFates:IsEquipped() and S.MasterAssassin:ArtifactRank() >= 6) and (AC.CombatTime() > 25 or not I.MantleoftheMasterAssassin:IsEquipped() or (Target:DebuffP(S.VendettaDebuff) and Target:DebuffP(S.SurgeofToxinsDebuff))) and (S.Subterfuge:IsAvailable() or not bool(stealthed.rogue) or (S.Nightstalker:IsAvailable() and (not I.MantleoftheMasterAssassin:IsEquipped() or not AC.Tier19_4Pc)))) then
      if AR.Cast(S.Kingsbane) then return ""; end
    end
    -- kingsbane,if=buff.envenom.up&((debuff.vendetta.up&debuff.surge_of_toxins.up)|cooldown.vendetta.remains<=5.8|cooldown.vendetta.remains>=10)
    if S.Kingsbane:IsCastableP() and (Player:BuffP(S.EnvenomBuff) and ((Target:DebuffP(S.VendettaDebuff) and Target:DebuffP(S.SurgeofToxinsDebuff)) or S.Vendetta:CooldownRemainsP() <= 5.8 or S.Vendetta:CooldownRemainsP() >= 10)) then
      if AR.Cast(S.Kingsbane) then return ""; end
    end
  end
  local function Maintain()
    -- rupture,if=talent.nightstalker.enabled&stealthed.rogue&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&(talent.exsanguinate.enabled|target.time_to_die-remains>4)
    if S.Rupture:IsCastableP() and (S.Nightstalker:IsAvailable() and bool(stealthed.rogue) and (not I.MantleoftheMasterAssassin:IsEquipped() or not AC.Tier19_4Pc) and (S.Exsanguinate:IsAvailable() or Target:TimeToDie() - Target:DebuffRemainsP(S.Rupture) > 4)) then
      if AR.Cast(S.Rupture) then return ""; end
    end
    -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&set_bonus.tier20_4pc&((dot.garrote.remains<=13&!debuff.toxic_blade.up)|pmultiplier<=1)&!exsanguinated
    if S.Garrote:IsCastableP() and (S.Subterfuge:IsAvailable() and bool(stealthed.rogue) and Player:ComboPointsDeficit() >= 1 and AC.Tier20_4Pc and ((Target:DebuffRemainsP(S.GarroteDebuff) <= 13 and not Target:DebuffP(S.ToxicBladeDebuff)) or pmultiplier <= 1) and not bool(exsanguinated)) then
      if AR.Cast(S.Garrote) then return ""; end
    end
    -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
    if S.Garrote:IsCastableP() and (S.Subterfuge:IsAvailable() and bool(stealthed.rogue) and Player:ComboPointsDeficit() >= 1 and not AC.Tier20_4Pc and bool(refreshable) and (not bool(exsanguinated) or Target:DebuffRemainsP(S.Garrote) <= S.Garrote:TickTime() * 2) and Target:TimeToDie() - Target:DebuffRemainsP(S.Garrote) > 2) then
      if AR.Cast(S.Garrote) then return ""; end
    end
    -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
    if S.Garrote:IsCastableP() and (S.Subterfuge:IsAvailable() and bool(stealthed.rogue) and Player:ComboPointsDeficit() >= 1 and not AC.Tier20_4Pc and Target:DebuffRemainsP(S.Garrote) <= 10 and pmultiplier <= 1 and not bool(exsanguinated) and Target:TimeToDie() - Target:DebuffRemainsP(S.Garrote) > 2) then
      if AR.Cast(S.Garrote) then return ""; end
    end
    -- rupture,if=!talent.exsanguinate.enabled&combo_points>=3&!ticking&mantle_duration<=0.2&target.time_to_die>6
    if S.Rupture:IsCastableP() and (not S.Exsanguinate:IsAvailable() and Player:ComboPoints() >= 3 and not Target:DebuffP(S.Rupture) and mantle_duration <= 0.2 and Target:TimeToDie() > 6) then
      if AR.Cast(S.Rupture) then return ""; end
    end
    -- rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled)))
    if S.Rupture:IsCastableP() and (S.Exsanguinate:IsAvailable() and ((Player:ComboPoints() >= cp_max_spend and S.Exsanguinate:CooldownRemainsP() < 1) or (not Target:DebuffP(S.Rupture) and (AC.CombatTime() > 10 or Player:ComboPoints() >= 2 + num(S.UrgeToKill:ArtifactEnabled()))))) then
      if AR.Cast(S.Rupture) then return ""; end
    end
    -- rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>6
    if S.Rupture:IsCastableP() and (Player:ComboPoints() >= 4 and bool(refreshable) and (pmultiplier <= 1 or Target:DebuffRemainsP(S.Rupture) <= S.Rupture:TickTime()) and (not bool(exsanguinated) or Target:DebuffRemainsP(S.Rupture) <= S.Rupture:TickTime() * 2) and Target:TimeToDie() - Target:DebuffRemainsP(S.Rupture) > 6) then
      if AR.Cast(S.Rupture) then return ""; end
    end
    -- call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
    if (Player:ComboPointsDeficit() >= 1 + num((mantle_duration >= 0.2)) and (not S.Exsanguinate:IsAvailable() or not S.Exanguinate:CooldownUpP() or AC.CombatTime() > 9)) then
      local ShouldReturn = Kb(); if ShouldReturn then return ShouldReturn; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
    if S.Garrote:IsCastableP() and ((not S.Subterfuge:IsAvailable() or not (S.Vanish:CooldownUpP() and S.Vendetta:CooldownRemainsP() <= 4)) and Player:ComboPointsDeficit() >= 1 and bool(refreshable) and (pmultiplier <= 1 or Target:DebuffRemainsP(S.Garrote) <= S.Garrote:TickTime()) and (not bool(exsanguinated) or Target:DebuffRemainsP(S.Garrote) <= S.Garrote:TickTime() * 2) and Target:TimeToDie() - Target:DebuffRemainsP(S.Garrote) > 4) then
      if AR.Cast(S.Garrote) then return ""; end
    end
    -- garrote,if=set_bonus.tier20_4pc&talent.exsanguinate.enabled&prev_gcd.1.rupture&cooldown.exsanguinate.remains<1&(!cooldown.vanish.up|time>12)
    if S.Garrote:IsCastableP() and (AC.Tier20_4Pc and S.Exsanguinate:IsAvailable() and Player:PrevGCDP(1, S.Rupture) and S.Exsanguinate:CooldownRemainsP() < 1 and (not S.Vanish:CooldownUpP() or AC.CombatTime() > 12)) then
      if AR.Cast(S.Garrote) then return ""; end
    end
  end
  -- variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
  if (true) then
    VarEnergyRegenCombined = Player:EnergyRegen() + poisoned_bleeds * (7 + num(S.VenomRush:IsAvailable()) * 3) / 2
  end
  -- variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
  if (true) then
    VarEnergyTimeToMaxCombined = Player:EnergyDeficit() / VarEnergyRegenCombined
  end
  -- call_action_list,name=cds
  if (true) then
    local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=maintain
  if (true) then
    local ShouldReturn = Maintain(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
  if ((not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemainsP() > 2) and (not bool(dot.rupture.refreshable) or (bool(dot.rupture.exsanguinated) and Target:DebuffRemainsP(S.RuptureDebuff) >= 3.5) or Target:TimeToDie() - Target:DebuffRemainsP(S.RuptureDebuff) <= 6) and active_dot.rupture >= Cache.EnemiesCount[5]) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
  if (Player:ComboPointsDeficit() > 1 or Player:EnergyDeficit() <= 25 + VarEnergyRegenCombined) then
    local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
  end
end