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
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Balance = {
  StreakingStars                        = Spell(),
  DawningSun                            = Spell(),
  Sunblaze                              = Spell(),
  PoweroftheMoon                        = Spell(),
  TwinMoons                             = Spell(279620),
  MoonkinForm                           = Spell(24858),
  SolarWrath                            = Spell(190984),
  CelestialAlignmentBuff                = Spell(194223),
  IncarnationBuff                       = Spell(102560),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  WarriorofElune                        = Spell(202425),
  Innervate                             = Spell(29166),
  LivelySpirit                          = Spell(),
  Incarnation                           = Spell(102560),
  CelestialAlignment                    = Spell(194223),
  LivelySpiritBuff                      = Spell(),
  FuryofElune                           = Spell(202770),
  ForceofNature                         = Spell(205636),
  Sunfire                               = Spell(93402),
  SunfireDebuff                         = Spell(164815),
  Moonfire                              = Spell(8921),
  MoonfireDebuff                        = Spell(164812),
  StellarFlare                          = Spell(202347),
  StellarFlareDebuff                    = Spell(202347),
  LunarStrike                           = Spell(194153),
  LunarEmpowermentBuff                  = Spell(164547),
  SolarEmpowermentBuff                  = Spell(164545),
  SunblazeBuff                          = Spell(),
  Starsurge                             = Spell(78674),
  StarlordBuff                          = Spell(279709),
  Starfall                              = Spell(191034),
  NewMoon                               = Spell(274281),
  HalfMoon                              = Spell(274282),
  FullMoon                              = Spell(274283),
  WarriorofEluneBuff                    = Spell(202425),
  DawningSunBuff                        = Spell()
};
local S = Spell.Druid.Balance;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Balance = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Druid.Balance;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Druid.Commons,
  Balance = HR.GUISettings.APL.Druid.Balance
};

-- Variables
local VarAzStreak = 0;
local VarAzDs = 0;
local VarAzSb = 0;
local VarAzPotm = 0;

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function FutureAstralPower()
  local AstralPower=Player:AstralPower()
  if not Player:IsCasting() then
    return AstralPower
  else
    if Player:IsCasting(S.NewnMoon) then
      return AstralPower + 10
    elseif Player:IsCasting(S.HalfMoon) then
      return AstralPower + 20
    elseif Player:IsCasting(S.FullMoon) then
      return AstralPower + 40
    elseif Player:IsCasting(S.StellarFlare) then
      return AstralPower + 8
    elseif Player:IsCasting(S.SolarWrath) then
      return AstralPower + 8
    elseif Player:IsCasting(S.LunarStrike) then
      return AstralPower + 12
    else
      return AstralPower
    end
  end
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- variable,name=az_streak,value=azerite.streaking_stars.rank
    if (true) then
      VarAzStreak = S.StreakingStars:AzeriteRank()
    end
    -- variable,name=az_ds,value=azerite.dawning_sun.rank
    if (true) then
      VarAzDs = S.DawningSun:AzeriteRank()
    end
    -- variable,name=az_sb,value=azerite.sunblaze.rank
    if (true) then
      VarAzSb = S.Sunblaze:AzeriteRank()
    end
    -- variable,name=az_potm,value=azerite.power_of_the_moon.rank,if=talent.twin_moons.enabled
    if (S.TwinMoons:IsAvailable()) then
      VarAzPotm = S.PoweroftheMoon:AzeriteRank()
    end
    -- moonkin_form
    if S.MoonkinForm:IsCastableP() then
      if HR.Cast(S.MoonkinForm) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- solar_wrath
    if S.SolarWrath:IsCastableP() then
      if HR.Cast(S.SolarWrath) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- potion,if=buff.celestial_alignment.up|buff.incarnation.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- berserking,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- lights_judgment,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.LightsJudgment) then return ""; end
    end
    -- fireblood,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- ancestral_call,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- use_items
    -- warrior_of_elune
    if S.WarriorofElune:IsCastableP() then
      if HR.Cast(S.WarriorofElune) then return ""; end
    end
    -- innervate,if=azerite.lively_spirit.enabled&(cooldown.incarnation.up|cooldown.celestial_alignment.remains<12)&(((raid_event.adds.duration%15)*(4)<(raid_event.adds.in%180))|(raid_event.adds.up))
    if S.Innervate:IsCastableP() and (S.LivelySpirit:AzeriteEnabled() and (S.Incarnation:CooldownUpP() or S.CelestialAlignment:CooldownRemainsP() < 12) and (((raid_event.adds.duration / 15) * (4) < (10000000000 / 180)) or (false))) then
      if HR.Cast(S.Innervate) then return ""; end
    end
    -- incarnation,if=astral_power>=40&(((raid_event.adds.duration%30)*(4)<(raid_event.adds.in%180))|(raid_event.adds.up))
    if S.Incarnation:IsCastableP() and (FutureAstralPower() >= 40 and (((raid_event.adds.duration / 30) * (4) < (10000000000 / 180)) or (false))) then
      if HR.Cast(S.Incarnation) then return ""; end
    end
    -- celestial_alignment,if=astral_power>=40&(!azerite.lively_spirit.enabled|buff.lively_spirit.up)&(((raid_event.adds.duration%15)*(4)<(raid_event.adds.in%180))|(raid_event.adds.up))
    if S.CelestialAlignment:IsCastableP() and (FutureAstralPower() >= 40 and (not S.LivelySpirit:AzeriteEnabled() or Player:BuffP(S.LivelySpiritBuff)) and (((raid_event.adds.duration / 15) * (4) < (10000000000 / 180)) or (false))) then
      if HR.Cast(S.CelestialAlignment) then return ""; end
    end
    -- fury_of_elune,if=(((raid_event.adds.duration%8)*(4)<(raid_event.adds.in%60))|(raid_event.adds.up))&((buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30))
    if S.FuryofElune:IsCastableP() and ((((raid_event.adds.duration / 8) * (4) < (10000000000 / 60)) or (false)) and ((Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemainsP() > 30 or S.Incarnation:CooldownRemainsP() > 30))) then
      if HR.Cast(S.FuryofElune) then return ""; end
    end
    -- force_of_nature,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
    if S.ForceofNature:IsCastableP() and ((Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemainsP() > 30 or S.Incarnation:CooldownRemainsP() > 30)) then
      if HR.Cast(S.ForceofNature) then return ""; end
    end
    -- sunfire,target_if=refreshable,if=astral_power.deficit>=7&target.time_to_die>5.4&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.sunfire)&(movement.distance>0|raid_event.movement.in>remains|remains<=execute_time*2)
    if S.Sunfire:IsCastableP() and (Target:DebuffRefreshableCP(S.SunfireDebuff)) and (Player:AstralPowerDeficit() >= 7 and Target:TimeToDie() > 5.4 and (not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or not bool(VarAzStreak) or not Player:PrevGCDP(1, S.Sunfire)) and (movement.distance > 0 or 10000000000 > Target:DebuffRemainsP(S.SunfireDebuff) or Target:DebuffRemainsP(S.SunfireDebuff) <= S.Sunfire:ExecuteTime() * 2)) then
      if HR.Cast(S.Sunfire) then return ""; end
    end
    -- moonfire,target_if=refreshable,if=astral_power.deficit>=7&target.time_to_die>6.6&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.moonfire)&(movement.distance>0|raid_event.movement.in>remains|remains<=execute_time*2)
    if S.Moonfire:IsCastableP() and (Target:DebuffRefreshableCP(S.MoonfireDebuff)) and (Player:AstralPowerDeficit() >= 7 and Target:TimeToDie() > 6.6 and (not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or not bool(VarAzStreak) or not Player:PrevGCDP(1, S.Moonfire)) and (movement.distance > 0 or 10000000000 > Target:DebuffRemainsP(S.MoonfireDebuff) or Target:DebuffRemainsP(S.MoonfireDebuff) <= S.Moonfire:ExecuteTime() * 2)) then
      if HR.Cast(S.Moonfire) then return ""; end
    end
    -- stellar_flare,target_if=refreshable,if=astral_power.deficit>=12&target.time_to_die>7.2&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.stellar_flare)
    if S.StellarFlare:IsCastableP() and (Target:DebuffRefreshableCP(S.StellarFlareDebuff)) and (Player:AstralPowerDeficit() >= 12 and Target:TimeToDie() > 7.2 and (not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or not bool(VarAzStreak) or not Player:PrevGCDP(1, S.StellarFlare))) then
      if HR.Cast(S.StellarFlare) then return ""; end
    end
    -- lunar_strike,if=astral_power.deficit>=16&(buff.lunar_empowerment.stack=3|(spell_targets<3&astral_power>=40&(buff.lunar_empowerment.stack=2&buff.solar_empowerment.stack=2)))&!(spell_targets.moonfire>=2&variable.az_potm=3&active_enemies=2)
    if S.LunarStrike:IsCastableP() and (Player:AstralPowerDeficit() >= 16 and (Player:BuffStackP(S.LunarEmpowermentBuff) == 3 or (Cache.EnemiesCount[40] < 3 and FutureAstralPower() >= 40 and (Player:BuffStackP(S.LunarEmpowermentBuff) == 2 and Player:BuffStackP(S.SolarEmpowermentBuff) == 2))) and not (Cache.EnemiesCount[40] >= 2 and VarAzPotm == 3 and Cache.EnemiesCount[40] == 2)) then
      if HR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=astral_power.deficit>=12&(buff.solar_empowerment.stack=3|(variable.az_sb>1&spell_targets.starfall<3&astral_power>=32&!buff.sunblaze.up))&!(spell_targets.moonfire>=2&active_enemies<=4&variable.az_potm=3)|(variable.az_streak&(buff.celestial_alignment.up|buff.incarnation.up)&!prev_gcd.1.solar_wrath&astral_power.deficit>=12)
    if S.SolarWrath:IsCastableP() and (Player:AstralPowerDeficit() >= 12 and (Player:BuffStackP(S.SolarEmpowermentBuff) == 3 or (VarAzSb > 1 and Cache.EnemiesCount[40] < 3 and FutureAstralPower() >= 32 and not Player:BuffP(S.SunblazeBuff))) and not (Cache.EnemiesCount[40] >= 2 and Cache.EnemiesCount[40] <= 4 and VarAzPotm == 3) or (bool(VarAzStreak) and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and not Player:PrevGCDP(1, S.SolarWrath) and Player:AstralPowerDeficit() >= 12)) then
      if HR.Cast(S.SolarWrath) then return ""; end
    end
    -- starsurge,if=(spell_targets.starfall<3&(!buff.starlord.up|buff.starlord.remains>=4)|execute_time*(astral_power%40)>target.time_to_die)&(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.starsurge)&(raid_event.movement.in>(buff.lunar_empowerment.stack*action.lunar_strike.execute_time+buff.solar_empowerment.stack*action.solar_wrath.execute_time)|(astral_power+buff.lunar_empowerment.stack*12+buff.solar_empowerment.stack*8)>=96)
    if S.Starsurge:IsCastableP() and ((Cache.EnemiesCount[40] < 3 and (not Player:BuffP(S.StarlordBuff) or Player:BuffRemainsP(S.StarlordBuff) >= 4) or S.Starsurge:ExecuteTime() * (FutureAstralPower() / 40) > Target:TimeToDie()) and (not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or VarAzStreak < 2 or not Player:PrevGCDP(1, S.Starsurge)) and (10000000000 > (Player:BuffStackP(S.LunarEmpowermentBuff) * S.LunarStrike:ExecuteTime() + Player:BuffStackP(S.SolarEmpowermentBuff) * S.SolarWrath:ExecuteTime()) or (FutureAstralPower() + Player:BuffStackP(S.LunarEmpowermentBuff) * 12 + Player:BuffStackP(S.SolarEmpowermentBuff) * 8) >= 96)) then
      if HR.Cast(S.Starsurge) then return ""; end
    end
    -- starfall,if=spell_targets.starfall>=3&(!buff.starlord.up|buff.starlord.remains>=4)
    if S.Starfall:IsCastableP() and (Cache.EnemiesCount[40] >= 3 and (not Player:BuffP(S.StarlordBuff) or Player:BuffRemainsP(S.StarlordBuff) >= 4)) then
      if HR.Cast(S.Starfall) then return ""; end
    end
    -- new_moon,if=astral_power.deficit>10+execute_time%1.5
    if S.NewMoon:IsCastableP() and (Player:AstralPowerDeficit() > 10 + S.NewMoon:ExecuteTime() / 1.5) then
      if HR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power.deficit>20+execute_time%1.5
    if S.HalfMoon:IsCastableP() and (Player:AstralPowerDeficit() > 20 + S.HalfMoon:ExecuteTime() / 1.5) then
      if HR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power.deficit>40+execute_time%1.5
    if S.FullMoon:IsCastableP() and (Player:AstralPowerDeficit() > 40 + S.FullMoon:ExecuteTime() / 1.5) then
      if HR.Cast(S.FullMoon) then return ""; end
    end
    -- lunar_strike,if=((buff.warrior_of_elune.up|buff.lunar_empowerment.up|spell_targets>=3&!buff.solar_empowerment.up)&(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.lunar_strike)|(variable.az_ds&!buff.dawning_sun.up))&!(spell_targets.moonfire>=2&active_enemies<=4&(variable.az_potm=3|variable.az_potm=2&active_enemies=2))
    if S.LunarStrike:IsCastableP() and (((Player:BuffP(S.WarriorofEluneBuff) or Player:BuffP(S.LunarEmpowermentBuff) or Cache.EnemiesCount[40] >= 3 and not Player:BuffP(S.SolarEmpowermentBuff)) and (not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or VarAzStreak < 2 or not Player:PrevGCDP(1, S.LunarStrike)) or (bool(VarAzDs) and not Player:BuffP(S.DawningSunBuff))) and not (Cache.EnemiesCount[40] >= 2 and Cache.EnemiesCount[40] <= 4 and (VarAzPotm == 3 or VarAzPotm == 2 and Cache.EnemiesCount[40] == 2))) then
      if HR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.solar_wrath)&!(spell_targets.moonfire>=2&active_enemies<=4&(variable.az_potm=3|variable.az_potm=2&active_enemies=2))
    if S.SolarWrath:IsCastableP() and ((not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or VarAzStreak < 2 or not Player:PrevGCDP(1, S.SolarWrath)) and not (Cache.EnemiesCount[40] >= 2 and Cache.EnemiesCount[40] <= 4 and (VarAzPotm == 3 or VarAzPotm == 2 and Cache.EnemiesCount[40] == 2))) then
      if HR.Cast(S.SolarWrath) then return ""; end
    end
    -- sunfire,if=(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.sunfire)&!(variable.az_potm>=2&spell_targets.moonfire>=2)
    if S.Sunfire:IsCastableP() and ((not Player:BuffP(S.CelestialAlignmentBuff) and not Player:BuffP(S.IncarnationBuff) or not bool(VarAzStreak) or not Player:PrevGCDP(1, S.Sunfire)) and not (VarAzPotm >= 2 and Cache.EnemiesCount[40] >= 2)) then
      if HR.Cast(S.Sunfire) then return ""; end
    end
    -- moonfire
    if S.Moonfire:IsCastableP() then
      if HR.Cast(S.Moonfire) then return ""; end
    end
  end
end

HR.SetAPL(102, APL)
