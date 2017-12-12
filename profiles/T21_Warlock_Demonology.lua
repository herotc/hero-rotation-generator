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
if not Spell.Warlock then Spell.Warlock = {} end
Spell.Warlock.Demonology = {
  Implosion                             = Spell(),
  ShadowBolt                            = Spell(),
  DemonicSynergyBuff                    = Spell(),
  SoulConduit                           = Spell(),
  HandofGuldan                          = Spell(),
  Shadowflame                           = Spell(),
  ShadowflameDebuff                     = Spell(),
  SummonInfernal                        = Spell(),
  GrimoireofSupremacy                   = Spell(),
  SummonDoomguard                       = Spell(),
  CallDreadstalkers                     = Spell(),
  SummonDarkglare                       = Spell(),
  PowerTrip                             = Spell(),
  DemonicCallingBuff                    = Spell(),
  Doom                                  = Spell(),
  HandofDoom                            = Spell(),
  ServicePet                            = Spell(),
  SindoreiSpiteIcd                      = Spell(),
  ShadowyInspirationBuff                = Spell(),
  ShadowyInspiration                    = Spell(),
  ThalkielsAscendance                   = Spell(),
  DemonicEmpowerment                    = Spell(),
  UseItems                              = Spell(),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  SoulHarvest                           = Spell(),
  SoulHarvestBuff                       = Spell(),
  ThalkielsConsumption                  = Spell(),
  LifeTap                               = Spell(),
  Demonwrath                            = Spell(),
  Demonbolt                             = Spell()
};
local S = Spell.Warlock.Demonology;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Demonology = {
  Item132369                       = Item(132369),
  Item132379                       = Item(132379),
  ProlongedPower                   = Item(142117)
};
local I = Item.Warlock.Demonology;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Warlock.Commons,
  Demonology = AR.GUISettings.APL.Warlock.Demonology
};

-- Variables
local 3Min = 0;
local NoDe1 = 0;
local NoDe2 = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()

  -- implosion,if=wild_imp_remaining_duration<=action.shadow_bolt.execute_time&(buff.demonic_synergy.remains|talent.soul_conduit.enabled|(!talent.soul_conduit.enabled&spell_targets.implosion>1)|wild_imp_count<=4)
  if S.Implosion:IsCastableP() and (wild_imp_remaining_duration <= S.ShadowBolt:ExecuteTime() and (bool(Player:BuffRemainsP(S.DemonicSynergyBuff)) or S.SoulConduit:IsAvailable() or (not S.SoulConduit:IsAvailable() and Cache.EnemiesCount[5] > 1) or wild_imp_count <= 4)) then
    if AR.Cast(S.Implosion) then return ""; end
  end
  -- variable,name=3min,value=doomguard_no_de>0|infernal_no_de>0
  if (true) then
    3Min = num(doomguard_no_de > 0 or infernal_no_de > 0)
  end
  -- variable,name=no_de1,value=dreadstalker_no_de>0|darkglare_no_de>0|doomguard_no_de>0|infernal_no_de>0|service_no_de>0
  if (true) then
    NoDe1 = num(dreadstalker_no_de > 0 or darkglare_no_de > 0 or doomguard_no_de > 0 or infernal_no_de > 0 or service_no_de > 0)
  end
  -- variable,name=no_de2,value=(variable.3min&service_no_de>0)|(variable.3min&wild_imp_no_de>0)|(variable.3min&dreadstalker_no_de>0)|(service_no_de>0&dreadstalker_no_de>0)|(service_no_de>0&wild_imp_no_de>0)|(dreadstalker_no_de>0&wild_imp_no_de>0)|(prev_gcd.1.hand_of_guldan&variable.no_de1)
  if (true) then
    NoDe2 = num((bool(3Min) and service_no_de > 0) or (bool(3Min) and wild_imp_no_de > 0) or (bool(3Min) and dreadstalker_no_de > 0) or (service_no_de > 0 and dreadstalker_no_de > 0) or (service_no_de > 0 and wild_imp_no_de > 0) or (dreadstalker_no_de > 0 and wild_imp_no_de > 0) or (Player:PrevGCDP(1, S.HandofGuldan) and bool(NoDe1)))
  end
  -- implosion,if=prev_gcd.1.hand_of_guldan&((wild_imp_remaining_duration<=3&buff.demonic_synergy.remains)|(wild_imp_remaining_duration<=4&spell_targets.implosion>2))
  if S.Implosion:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) and ((wild_imp_remaining_duration <= 3 and bool(Player:BuffRemainsP(S.DemonicSynergyBuff))) or (wild_imp_remaining_duration <= 4 and Cache.EnemiesCount[5] > 2))) then
    if AR.Cast(S.Implosion) then return ""; end
  end
  -- shadowflame,if=(debuff.shadowflame.stack>0&remains<action.shadow_bolt.cast_time+travel_time)&spell_targets.demonwrath<5
  if S.Shadowflame:IsCastableP() and ((Target:DebuffStackP(S.ShadowflameDebuff) > 0 and Player:BuffRemainsP(S.Shadowflame) < S.ShadowBolt:CastTime() + S.Shadowflame:TravelTime()) and Cache.EnemiesCount[5] < 5) then
    if AR.Cast(S.Shadowflame) then return ""; end
  end
  -- summon_infernal,if=(!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>2)&equipped.132369
  if S.SummonInfernal:IsCastableP() and ((not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] > 2) and I.Item132369:IsEquipped()) then
    if AR.Cast(S.SummonInfernal) then return ""; end
  end
  -- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<=2&equipped.132369
  if S.SummonDoomguard:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] <= 2 and I.Item132369:IsEquipped()) then
    if AR.Cast(S.SummonDoomguard) then return ""; end
  end
  -- call_dreadstalkers,if=((!talent.summon_darkglare.enabled|talent.power_trip.enabled)&(spell_targets.implosion<3|!talent.implosion.enabled))&!(soul_shard=5&buff.demonic_calling.remains)
  if S.CallDreadstalkers:IsCastableP() and (((not S.SummonDarkglare:IsAvailable() or S.PowerTrip:IsAvailable()) and (Cache.EnemiesCount[5] < 3 or not S.Implosion:IsAvailable())) and not (soul_shard == 5 and bool(Player:BuffRemainsP(S.DemonicCallingBuff)))) then
    if AR.Cast(S.CallDreadstalkers) then return ""; end
  end
  -- doom,cycle_targets=1,if=(!talent.hand_of_doom.enabled&target.time_to_die>duration&(!ticking|remains<duration*0.3))&!(variable.no_de1|prev_gcd.1.hand_of_guldan)
  if S.Doom:IsCastableP() and ((not S.HandofDoom:IsAvailable() and Target:TimeToDie() > S.Doom:BaseDuration() and (not Player:BuffP(S.Doom) or Player:BuffRemainsP(S.Doom) < S.Doom:BaseDuration() * 0.3)) and not (bool(NoDe1) or Player:PrevGCDP(1, S.HandofGuldan))) then
    if AR.Cast(S.Doom) then return ""; end
  end
  -- shadowflame,if=(charges=2&soul_shard<5)&spell_targets.demonwrath<5&!variable.no_de1
  if S.Shadowflame:IsCastableP() and ((S.Shadowflame:ChargesP() == 2 and soul_shard < 5) and Cache.EnemiesCount[5] < 5 and not bool(NoDe1)) then
    if AR.Cast(S.Shadowflame) then return ""; end
  end
  -- service_pet
  if S.ServicePet:IsCastableP() and (true) then
    if AR.Cast(S.ServicePet) then return ""; end
  end
  -- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
  if S.SummonDoomguard:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] <= 2 and (Target:TimeToDie() > 180 or Target:HealthPercentage() <= 20 or Target:TimeToDie() < 30)) then
    if AR.Cast(S.SummonDoomguard) then return ""; end
  end
  -- summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>2
  if S.SummonInfernal:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] > 2) then
    if AR.Cast(S.SummonInfernal) then return ""; end
  end
  -- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  if S.SummonDoomguard:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] == 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
    if AR.Cast(S.SummonDoomguard) then return ""; end
  end
  -- summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  if S.SummonInfernal:IsCastableP() and (S.GrimoireofSupremacy:IsAvailable() and Cache.EnemiesCount[5] > 1 and I.Item132379:IsEquipped() and not bool(S.SindoreiSpiteIcd:CooldownRemainsP())) then
    if AR.Cast(S.SummonInfernal) then return ""; end
  end
  -- shadow_bolt,if=buff.shadowy_inspiration.remains&soul_shard<5&!prev_gcd.1.doom&!variable.no_de2
  if S.ShadowBolt:IsCastableP() and (bool(Player:BuffRemainsP(S.ShadowyInspirationBuff)) and soul_shard < 5 and not Player:PrevGCDP(1, S.Doom) and not bool(NoDe2)) then
    if AR.Cast(S.ShadowBolt) then return ""; end
  end
  -- summon_darkglare,if=prev_gcd.1.hand_of_guldan|prev_gcd.1.call_dreadstalkers|talent.power_trip.enabled
  if S.SummonDarkglare:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) or Player:PrevGCDP(1, S.CallDreadstalkers) or S.PowerTrip:IsAvailable()) then
    if AR.Cast(S.SummonDarkglare) then return ""; end
  end
  -- summon_darkglare,if=cooldown.call_dreadstalkers.remains>5&soul_shard<3
  if S.SummonDarkglare:IsCastableP() and (S.CallDreadstalkers:CooldownRemainsP() > 5 and soul_shard < 3) then
    if AR.Cast(S.SummonDarkglare) then return ""; end
  end
  -- summon_darkglare,if=cooldown.call_dreadstalkers.remains<=action.summon_darkglare.cast_time&(soul_shard>=3|soul_shard>=1&buff.demonic_calling.react)
  if S.SummonDarkglare:IsCastableP() and (S.CallDreadstalkers:CooldownRemainsP() <= S.SummonDarkglare:CastTime() and (soul_shard >= 3 or soul_shard >= 1 and bool(Player:BuffStackP(S.DemonicCallingBuff)))) then
    if AR.Cast(S.SummonDarkglare) then return ""; end
  end
  -- call_dreadstalkers,if=talent.summon_darkglare.enabled&(spell_targets.implosion<3|!talent.implosion.enabled)&(cooldown.summon_darkglare.remains>2|prev_gcd.1.summon_darkglare|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=3|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=1&buff.demonic_calling.react)
  if S.CallDreadstalkers:IsCastableP() and (S.SummonDarkglare:IsAvailable() and (Cache.EnemiesCount[5] < 3 or not S.Implosion:IsAvailable()) and (S.SummonDarkglare:CooldownRemainsP() > 2 or Player:PrevGCDP(1, S.SummonDarkglare) or S.SummonDarkglare:CooldownRemainsP() <= S.CallDreadstalkers:CastTime() and soul_shard >= 3 or S.SummonDarkglare:CooldownRemainsP() <= S.CallDreadstalkers:CastTime() and soul_shard >= 1 and bool(Player:BuffStackP(S.DemonicCallingBuff)))) then
    if AR.Cast(S.CallDreadstalkers) then return ""; end
  end
  -- hand_of_guldan,if=soul_shard>=4&(((!(variable.no_de1|prev_gcd.1.hand_of_guldan)&(pet_count>=13&!talent.shadowy_inspiration.enabled|pet_count>=6&talent.shadowy_inspiration.enabled))|!variable.no_de2|soul_shard=5)&talent.power_trip.enabled)
  if S.HandofGuldan:IsCastableP() and (soul_shard >= 4 and (((not (bool(NoDe1) or Player:PrevGCDP(1, S.HandofGuldan)) and (pet_count >= 13 and not S.ShadowyInspiration:IsAvailable() or pet_count >= 6 and S.ShadowyInspiration:IsAvailable())) or not bool(NoDe2) or soul_shard == 5) and S.PowerTrip:IsAvailable())) then
    if AR.Cast(S.HandofGuldan) then return ""; end
  end
  -- hand_of_guldan,if=(soul_shard>=3&prev_gcd.1.call_dreadstalkers&!artifact.thalkiels_ascendance.rank)|soul_shard>=5|(soul_shard>=4&cooldown.summon_darkglare.remains>2)
  if S.HandofGuldan:IsCastableP() and ((soul_shard >= 3 and Player:PrevGCDP(1, S.CallDreadstalkers) and not bool(S.ThalkielsAscendance:ArtifactRank())) or soul_shard >= 5 or (soul_shard >= 4 and S.SummonDarkglare:CooldownRemainsP() > 2)) then
    if AR.Cast(S.HandofGuldan) then return ""; end
  end
  -- demonic_empowerment,if=(((talent.power_trip.enabled&(!talent.implosion.enabled|spell_targets.demonwrath<=1))|!talent.implosion.enabled|(talent.implosion.enabled&!talent.soul_conduit.enabled&spell_targets.demonwrath<=3))&(wild_imp_no_de>3|prev_gcd.1.hand_of_guldan))|(prev_gcd.1.hand_of_guldan&wild_imp_no_de=0&wild_imp_remaining_duration<=0)|(prev_gcd.1.implosion&wild_imp_no_de>0)
  if S.DemonicEmpowerment:IsCastableP() and ((((S.PowerTrip:IsAvailable() and (not S.Implosion:IsAvailable() or Cache.EnemiesCount[5] <= 1)) or not S.Implosion:IsAvailable() or (S.Implosion:IsAvailable() and not S.SoulConduit:IsAvailable() and Cache.EnemiesCount[5] <= 3)) and (wild_imp_no_de > 3 or Player:PrevGCDP(1, S.HandofGuldan))) or (Player:PrevGCDP(1, S.HandofGuldan) and wild_imp_no_de == 0 and wild_imp_remaining_duration <= 0) or (Player:PrevGCDP(1, S.Implosion) and wild_imp_no_de > 0)) then
    if AR.Cast(S.DemonicEmpowerment) then return ""; end
  end
  -- demonic_empowerment,if=variable.no_de1|prev_gcd.1.hand_of_guldan
  if S.DemonicEmpowerment:IsCastableP() and (bool(NoDe1) or Player:PrevGCDP(1, S.HandofGuldan)) then
    if AR.Cast(S.DemonicEmpowerment) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.Berserking, Settings.Demonology.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Demonology.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- soul_harvest,if=!buff.soul_harvest.remains
  if S.SoulHarvest:IsCastableP() and (not bool(Player:BuffRemainsP(S.SoulHarvestBuff))) then
    if AR.Cast(S.SoulHarvest) then return ""; end
  end
  -- potion,name=prolonged_power,if=buff.soul_harvest.remains|target.time_to_die<=70|trinket.proc.any.react
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(Player:BuffRemainsP(S.SoulHarvestBuff)) or Target:TimeToDie() <= 70 or bool(trinket.proc.any.react)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- shadowflame,if=charges=2&spell_targets.demonwrath<5
  if S.Shadowflame:IsCastableP() and (S.Shadowflame:ChargesP() == 2 and Cache.EnemiesCount[5] < 5) then
    if AR.Cast(S.Shadowflame) then return ""; end
  end
  -- thalkiels_consumption,if=(dreadstalker_remaining_duration>execute_time|talent.implosion.enabled&spell_targets.implosion>=3)&(wild_imp_count>3&dreadstalker_count<=2|wild_imp_count>5)&wild_imp_remaining_duration>execute_time
  if S.ThalkielsConsumption:IsCastableP() and ((dreadstalker_remaining_duration > S.ThalkielsConsumption:ExecuteTime() or S.Implosion:IsAvailable() and Cache.EnemiesCount[5] >= 3) and (wild_imp_count > 3 and dreadstalker_count <= 2 or wild_imp_count > 5) and wild_imp_remaining_duration > S.ThalkielsConsumption:ExecuteTime()) then
    if AR.Cast(S.ThalkielsConsumption) then return ""; end
  end
  -- life_tap,if=mana.pct<=15|(mana.pct<=65&((cooldown.call_dreadstalkers.remains<=0.75&soul_shard>=2)|((cooldown.call_dreadstalkers.remains<gcd*2)&(cooldown.summon_doomguard.remains<=0.75|cooldown.service_pet.remains<=0.75)&soul_shard>=3)))
  if S.LifeTap:IsCastableP() and (Player:ManaPercentage() <= 15 or (Player:ManaPercentage() <= 65 and ((S.CallDreadstalkers:CooldownRemainsP() <= 0.75 and soul_shard >= 2) or ((S.CallDreadstalkers:CooldownRemainsP() < Player:GCD() * 2) and (S.SummonDoomguard:CooldownRemainsP() <= 0.75 or S.ServicePet:CooldownRemainsP() <= 0.75) and soul_shard >= 3)))) then
    if AR.Cast(S.LifeTap) then return ""; end
  end
  -- demonwrath,chain=1,interrupt=1,if=spell_targets.demonwrath>=3
  if S.Demonwrath:IsCastableP() and (Cache.EnemiesCount[5] >= 3) then
    if AR.Cast(S.Demonwrath) then return ""; end
  end
  -- demonwrath,moving=1,chain=1,interrupt=1
  if S.Demonwrath:IsCastableP() and (true) then
    if AR.Cast(S.Demonwrath) then return ""; end
  end
  -- demonbolt
  if S.Demonbolt:IsCastableP() and (true) then
    if AR.Cast(S.Demonbolt) then return ""; end
  end
  -- shadow_bolt,if=buff.shadowy_inspiration.remains
  if S.ShadowBolt:IsCastableP() and (bool(Player:BuffRemainsP(S.ShadowyInspirationBuff))) then
    if AR.Cast(S.ShadowBolt) then return ""; end
  end
  -- demonic_empowerment,if=artifact.thalkiels_ascendance.rank&talent.power_trip.enabled&!talent.demonbolt.enabled&talent.shadowy_inspiration.enabled
  if S.DemonicEmpowerment:IsCastableP() and (bool(S.ThalkielsAscendance:ArtifactRank()) and S.PowerTrip:IsAvailable() and not S.Demonbolt:IsAvailable() and S.ShadowyInspiration:IsAvailable()) then
    if AR.Cast(S.DemonicEmpowerment) then return ""; end
  end
  -- shadow_bolt
  if S.ShadowBolt:IsCastableP() and (true) then
    if AR.Cast(S.ShadowBolt) then return ""; end
  end
  -- life_tap
  if S.LifeTap:IsCastableP() and (true) then
    if AR.Cast(S.LifeTap) then return ""; end
  end
end