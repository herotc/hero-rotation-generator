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
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Balance = {
  MoonkinForm                           = Spell(24858),
  BlessingofElune                       = Spell(202737),
  NewMoon                               = Spell(202767),
  Starfall                              = Spell(191034),
  StellarEmpowermentDebuff              = Spell(197637),
  CelestialAlignmentBuff                = Spell(194223),
  IncarnationBuff                       = Spell(102560),
  StellarFlare                          = Spell(202347),
  Sunfire                               = Spell(93402),
  Moonfire                              = Spell(8921),
  ForceofNature                         = Spell(205636),
  Starsurge                             = Spell(78674),
  OnethsIntuitionBuff                   = Spell(209406),
  AstralAccelerationBuff                = Spell(242232),
  HalfMoon                              = Spell(202768),
  FullMoon                              = Spell(202771),
  LunarStrike                           = Spell(194153),
  WarriorofEluneBuff                    = Spell(202425),
  SolarWrath                            = Spell(190984),
  SolarEmpowermentBuff                  = Spell(164545),
  LunarEmpowermentBuff                  = Spell(164547),
  AstralCommunion                       = Spell(202359),
  TheEmeraldDreamcatcherBuff            = Spell(208190),
  Incarnation                           = Spell(102560),
  CelestialAlignment                    = Spell(194223),
  NaturesBalance                        = Spell(202430),
  OnethsOverconfidenceBuff              = Spell(209407),
  MoonfireDebuff                        = Spell(164812),
  SunfireDebuff                         = Spell(164815),
  FuryofElune                           = Spell(202770),
  FuryofEluneBuff                       = Spell(202770),
  WarriorofElune                        = Spell(202425),
  SolarSolsticeBuff                     = Spell(252767),
  BlessingoftheAncients                 = Spell(202360),
  BlessingofEluneBuff                   = Spell(202737),
  BlessingofAnsheBuff                   = Spell(202739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  UseItems                              = Spell(),
  StellarDrift                          = Spell(202354)
};
local S = Spell.Druid.Balance;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Balance = {
  ProlongedPower                   = Item(142117),
  TheEmeraldDreamcatcher           = Item(137062)
};
local I = Item.Druid.Balance;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Druid.Commons,
  Balance = AR.GUISettings.APL.Druid.Balance
};

-- Variables

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

local function FutureAstralPower()
  local AstralPower=Player:AstralPower()
  if not Player:IsCasting() then
    return AstralPower
  else
    if Player:IsCasting(S.NewMoon) then
      return AstralPower + 10
    elseif Player:IsCasting(S.HalfMoon) then
      return AstralPower + 20
    elseif Player:IsCasting(S.FullMoon) then
      return AstralPower + 40
    elseif Player:IsCasting(S.SolarWrath) then
      return AstralPower
        + (Player:Buff(S.BlessingofElune) and 10 or 8)
          * ((Player:BuffRemainsP(S.CelestialAlignment) > 0
            or Player:BuffRemainsP(S.IncarnationChosenOfElune) > 0) and 2 or 1)
    elseif Player:IsCasting(S.LunarStrike) then
      return AstralPower
        + (Player:Buff(S.BlessingofElune) and 15 or 10)
          * ((Player:BuffRemainsP(S.CelestialAlignment) > 0
            or Player:BuffRemainsP(S.IncarnationChosenOfElune) > 0) and 2 or 1)
    else
      return AstralPower
    end
  end
end

--- ======= ACTION LISTS =======
local function APL()
  UpdateRanges()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- moonkin_form
    if S.MoonkinForm:IsCastableP() and (true) then
      if AR.Cast(S.MoonkinForm) then return ""; end
    end
    -- blessing_of_elune
    if S.BlessingofElune:IsCastableP() and Player:BuffDownP(S.BlessingofElune) and (true) then
      if AR.Cast(S.BlessingofElune) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- new_moon
    if S.NewMoon:IsCastableP() and (true) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
  end
  local function Aoe()
    -- starfall,if=debuff.stellar_empowerment.remains<gcd.max*2|astral_power.deficit<22.5|(buff.celestial_alignment.remains>8|buff.incarnation.remains>8)|target.time_to_die<8
    if S.Starfall:IsCastableP() and (Target:DebuffRemainsP(S.StellarEmpowermentDebuff) < Player:GCD() * 2 or Player:AstralPowerDeficit() < 22.5 or (Player:BuffRemainsP(S.CelestialAlignmentBuff) > 8 or Player:BuffRemainsP(S.IncarnationBuff) > 8) or Target:TimeToDie() < 8) then
      if AR.Cast(S.Starfall) then return ""; end
    end
    -- stellar_flare,target_if=refreshable,if=target.time_to_die>10
    if S.StellarFlare:IsCastableP() and (Target:TimeToDie() > 10) then
      if AR.Cast(S.StellarFlare) then return ""; end
    end
    -- sunfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
    if S.Sunfire:IsCastableP() and (Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 4) then
      if AR.Cast(S.Sunfire) then return ""; end
    end
    -- moonfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
    if S.Moonfire:IsCastableP() and (Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 4) then
      if AR.Cast(S.Moonfire) then return ""; end
    end
    -- force_of_nature
    if S.ForceofNature:IsCastableP() and (true) then
      if AR.Cast(S.ForceofNature) then return ""; end
    end
    -- starsurge,if=buff.oneths_intuition.react&(!buff.astral_acceleration.up|buff.astral_acceleration.remains>5|astral_power.deficit<44)
    if S.Starsurge:IsCastableP() and (bool(Player:BuffStackP(S.OnethsIntuitionBuff)) and (not Player:BuffP(S.AstralAccelerationBuff) or Player:BuffRemainsP(S.AstralAccelerationBuff) > 5 or Player:AstralPowerDeficit() < 44)) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- new_moon,if=astral_power.deficit>14&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
    if S.NewMoon:IsCastableP() and (Player:AstralPowerDeficit() > 14 and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.NewMoon:ChargesP() == 2 and S.NewMoon:RechargeP() < 5) or S.NewMoon:ChargesP() == 3)) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power.deficit>24
    if S.HalfMoon:IsCastableP() and (Player:AstralPowerDeficit() > 24) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power.deficit>44
    if S.FullMoon:IsCastableP() and (Player:AstralPowerDeficit() > 44) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- lunar_strike,if=buff.warrior_of_elune.up
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.WarriorofEluneBuff)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.up
    if S.SolarWrath:IsCastableP() and (Player:BuffP(S.SolarEmpowermentBuff)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.up
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.LunarEmpowermentBuff)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- lunar_strike,if=spell_targets.lunar_strike>=4|spell_haste<0.45
    if S.LunarStrike:IsCastableP() and (Cache.EnemiesCount[40] >= 4 or Player:SpellHaste() < 0.45) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath
    if S.SolarWrath:IsCastableP() and (true) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
  end
  local function Ed()
    -- astral_communion,if=astral_power.deficit>=75&buff.the_emerald_dreamcatcher.up
    if S.AstralCommunion:IsCastableP() and (Player:AstralPowerDeficit() >= 75 and Player:BuffP(S.TheEmeraldDreamcatcherBuff)) then
      if AR.Cast(S.AstralCommunion) then return ""; end
    end
    -- incarnation,if=astral_power>=60|buff.bloodlust.up
    if S.Incarnation:IsCastableP() and (FutureAstralPower() >= 60 or Player:HasHeroism()) then
      if AR.Cast(S.Incarnation) then return ""; end
    end
    -- celestial_alignment,if=astral_power>=60&!buff.the_emerald_dreamcatcher.up
    if S.CelestialAlignment:IsCastableP() and (FutureAstralPower() >= 60 and not Player:BuffP(S.TheEmeraldDreamcatcherBuff)) then
      if AR.Cast(S.CelestialAlignment) then return ""; end
    end
    -- starsurge,if=(gcd.max*astral_power%26)>target.time_to_die
    if S.Starsurge:IsCastableP() and ((Player:GCD() * FutureAstralPower() / 26) > Target:TimeToDie()) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.2
    if S.StellarFlare:IsCastableP() and (Cache.EnemiesCount[40] < 4 and Player:BuffRemainsP(S.StellarFlare) < 7.2) then
      if AR.Cast(S.StellarFlare) then return ""; end
    end
    -- moonfire,if=((talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
    if S.Moonfire:IsCastableP() and (((S.NaturesBalance:IsAvailable() and Target:DebuffRemainsP(S.Moonfire) < 3) or (Target:DebuffRemainsP(S.Moonfire) < 6.6 and not S.NaturesBalance:IsAvailable())) and (Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:BuffP(S.TheEmeraldDreamcatcherBuff))) then
      if AR.Cast(S.Moonfire) then return ""; end
    end
    -- sunfire,if=((talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
    if S.Sunfire:IsCastableP() and (((S.NaturesBalance:IsAvailable() and Target:DebuffRemainsP(S.Sunfire) < 3) or (Target:DebuffRemainsP(S.Sunfire) < 5.4 and not S.NaturesBalance:IsAvailable())) and (Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:BuffP(S.TheEmeraldDreamcatcherBuff))) then
      if AR.Cast(S.Sunfire) then return ""; end
    end
    -- force_of_nature,if=buff.the_emerald_dreamcatcher.remains>execute_time
    if S.ForceofNature:IsCastableP() and (Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.ForceofNature:ExecuteTime()) then
      if AR.Cast(S.ForceofNature) then return ""; end
    end
    -- starfall,if=buff.oneths_overconfidence.react&buff.the_emerald_dreamcatcher.remains>execute_time
    if S.Starfall:IsCastableP() and (bool(Player:BuffStackP(S.OnethsOverconfidenceBuff)) and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.Starfall:ExecuteTime()) then
      if AR.Cast(S.Starfall) then return ""; end
    end
    -- new_moon,if=astral_power.deficit>=10&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16
    if S.NewMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 10 and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.NewMoon:ExecuteTime() and FutureAstralPower() >= 16) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power.deficit>=20&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=6
    if S.HalfMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 20 and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.HalfMoon:ExecuteTime() and FutureAstralPower() >= 6) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power.deficit>=40&buff.the_emerald_dreamcatcher.remains>execute_time
    if S.FullMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 40 and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.FullMoon:ExecuteTime()) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- lunar_strike,if=(buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5))&spell_haste<0.4
    if S.LunarStrike:IsCastableP() and ((Player:BuffP(S.LunarEmpowermentBuff) and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.LunarStrike:ExecuteTime() and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 15 or (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 22.5)) and Player:SpellHaste() < 0.4) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.stack>1&buff.the_emerald_dreamcatcher.remains>2*execute_time&astral_power>=6&(dot.moonfire.remains>5|(dot.sunfire.remains<5.4&dot.moonfire.remains>6.6))&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
    if S.SolarWrath:IsCastableP() and (Player:BuffStackP(S.SolarEmpowermentBuff) > 1 and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > 2 * S.SolarWrath:ExecuteTime() and FutureAstralPower() >= 6 and (Target:DebuffRemainsP(S.MoonfireDebuff) > 5 or (Target:DebuffRemainsP(S.SunfireDebuff) < 5.4 and Target:DebuffRemainsP(S.MoonfireDebuff) > 6.6)) and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 10 or (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 15)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=11&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5)
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.LunarEmpowermentBuff) and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.LunarStrike:ExecuteTime() and FutureAstralPower() >= 11 and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 15 or (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 22.5)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
    if S.SolarWrath:IsCastableP() and (Player:BuffP(S.SolarEmpowermentBuff) and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) > S.SolarWrath:ExecuteTime() and FutureAstralPower() >= 16 and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 10 or (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and Player:AstralPowerDeficit() >= 15)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- starsurge,if=(buff.the_emerald_dreamcatcher.up&buff.the_emerald_dreamcatcher.remains<gcd.max)|astral_power>85|((buff.celestial_alignment.up|buff.incarnation.up)&astral_power>30)
    if S.Starsurge:IsCastableP() and ((Player:BuffP(S.TheEmeraldDreamcatcherBuff) and Player:BuffRemainsP(S.TheEmeraldDreamcatcherBuff) < Player:GCD()) or FutureAstralPower() > 85 or ((Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) and FutureAstralPower() > 30)) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- starfall,if=buff.oneths_overconfidence.up
    if S.Starfall:IsCastableP() and (Player:BuffP(S.OnethsOverconfidenceBuff)) then
      if AR.Cast(S.Starfall) then return ""; end
    end
    -- new_moon,if=astral_power.deficit>=10
    if S.NewMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 10) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power.deficit>=20
    if S.HalfMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 20) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power.deficit>=40
    if S.FullMoon:IsCastableP() and (Player:AstralPowerDeficit() >= 40) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.up
    if S.SolarWrath:IsCastableP() and (Player:BuffP(S.SolarEmpowermentBuff)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.up
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.LunarEmpowermentBuff)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath
    if S.SolarWrath:IsCastableP() and (true) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
  end
  local function FuryofElune()
    -- incarnation,if=astral_power>=95&cooldown.fury_of_elune.remains<=gcd
    if S.Incarnation:IsCastableP() and (FutureAstralPower() >= 95 and S.FuryofElune:CooldownRemainsP() <= Player:GCD()) then
      if AR.Cast(S.Incarnation) then return ""; end
    end
    -- force_of_nature,if=!buff.fury_of_elune.up
    if S.ForceofNature:IsCastableP() and (not Player:BuffP(S.FuryofEluneBuff)) then
      if AR.Cast(S.ForceofNature) then return ""; end
    end
    -- fury_of_elune,if=astral_power>=95
    if S.FuryofElune:IsCastableP() and (FutureAstralPower() >= 95) then
      if AR.Cast(S.FuryofElune) then return ""; end
    end
    -- new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
    if S.NewMoon:IsCastableP() and (((S.NewMoon:ChargesP() == 2 and S.NewMoon:RechargeP() < 5) or S.NewMoon:ChargesP() == 3) and true and (Player:BuffP(S.FuryofEluneBuff) or (S.FuryofElune:CooldownRemainsP() > Player:GCD() * 3 and FutureAstralPower() <= 90))) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
    if S.HalfMoon:IsCastableP() and (((S.HalfMoon:ChargesP() == 2 and S.HalfMoon:RechargeP() < 5) or S.HalfMoon:ChargesP() == 3) and true and (Player:BuffP(S.FuryofEluneBuff) or (S.FuryofElune:CooldownRemainsP() > Player:GCD() * 3 and FutureAstralPower() <= 80))) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
    if S.FullMoon:IsCastableP() and (((S.FullMoon:ChargesP() == 2 and S.FullMoon:RechargeP() < 5) or S.FullMoon:ChargesP() == 3) and true and (Player:BuffP(S.FuryofEluneBuff) or (S.FuryofElune:CooldownRemainsP() > Player:GCD() * 3 and FutureAstralPower() <= 60))) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- astral_communion,if=buff.fury_of_elune.up&astral_power<=25
    if S.AstralCommunion:IsCastableP() and (Player:BuffP(S.FuryofEluneBuff) and FutureAstralPower() <= 25) then
      if AR.Cast(S.AstralCommunion) then return ""; end
    end
    -- warrior_of_elune,if=buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.up)
    if S.WarriorofElune:IsCastableP() and (Player:BuffP(S.FuryofEluneBuff) or (S.FuryofElune:CooldownRemainsP() >= 35 and Player:BuffP(S.LunarEmpowermentBuff))) then
      if AR.Cast(S.WarriorofElune) then return ""; end
    end
    -- lunar_strike,if=buff.warrior_of_elune.up&(astral_power<=90|(astral_power<=85&buff.incarnation.up))
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.WarriorofEluneBuff) and (FutureAstralPower() <= 90 or (FutureAstralPower() <= 85 and Player:BuffP(S.IncarnationBuff)))) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- new_moon,if=astral_power<=90&buff.fury_of_elune.up
    if S.NewMoon:IsCastableP() and (FutureAstralPower() <= 90 and Player:BuffP(S.FuryofEluneBuff)) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power<=80&buff.fury_of_elune.up&astral_power>cast_time*12
    if S.HalfMoon:IsCastableP() and (FutureAstralPower() <= 80 and Player:BuffP(S.FuryofEluneBuff) and FutureAstralPower() > S.HalfMoon:CastTime() * 12) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power<=60&buff.fury_of_elune.up&astral_power>cast_time*12
    if S.FullMoon:IsCastableP() and (FutureAstralPower() <= 60 and Player:BuffP(S.FuryofEluneBuff) and FutureAstralPower() > S.FullMoon:CastTime() * 12) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- moonfire,if=buff.fury_of_elune.down&remains<=6.6
    if S.Moonfire:IsCastableP() and (Player:BuffDownP(S.FuryofEluneBuff) and Target:DebuffRemainsP(S.Moonfire) <= 6.6) then
      if AR.Cast(S.Moonfire) then return ""; end
    end
    -- sunfire,if=buff.fury_of_elune.down&remains<5.4
    if S.Sunfire:IsCastableP() and (Player:BuffDownP(S.FuryofEluneBuff) and Target:DebuffRemainsP(S.Sunfire) < 5.4) then
      if AR.Cast(S.Sunfire) then return ""; end
    end
    -- stellar_flare,if=remains<7.2&active_enemies=1
    if S.StellarFlare:IsCastableP() and (Player:BuffRemainsP(S.StellarFlare) < 7.2 and Cache.EnemiesCount[40] == 1) then
      if AR.Cast(S.StellarFlare) then return ""; end
    end
    -- starfall,if=(active_enemies>=2&talent.stellar_flare.enabled|active_enemies>=3)&buff.fury_of_elune.down&cooldown.fury_of_elune.remains>10
    if S.Starfall:IsCastableP() and ((Cache.EnemiesCount[40] >= 2 and S.StellarFlare:IsAvailable() or Cache.EnemiesCount[40] >= 3) and Player:BuffDownP(S.FuryofEluneBuff) and S.FuryofElune:CooldownRemainsP() > 10) then
      if AR.Cast(S.Starfall) then return ""; end
    end
    -- starsurge,if=active_enemies<=2&buff.fury_of_elune.down&cooldown.fury_of_elune.remains>7
    if S.Starsurge:IsCastableP() and (Cache.EnemiesCount[40] <= 2 and Player:BuffDownP(S.FuryofEluneBuff) and S.FuryofElune:CooldownRemainsP() > 7) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- starsurge,if=buff.fury_of_elune.down&((astral_power>=92&cooldown.fury_of_elune.remains>gcd*3)|(cooldown.warrior_of_elune.remains<=5&cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.stack<2))
    if S.Starsurge:IsCastableP() and (Player:BuffDownP(S.FuryofEluneBuff) and ((FutureAstralPower() >= 92 and S.FuryofElune:CooldownRemainsP() > Player:GCD() * 3) or (S.WarriorofElune:CooldownRemainsP() <= 5 and S.FuryofElune:CooldownRemainsP() >= 35 and Player:BuffStackP(S.LunarEmpowermentBuff) < 2))) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.up
    if S.SolarWrath:IsCastableP() and (Player:BuffP(S.SolarEmpowermentBuff)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.stack=3|(buff.lunar_empowerment.remains<5&buff.lunar_empowerment.up)|active_enemies>=2
    if S.LunarStrike:IsCastableP() and (Player:BuffStackP(S.LunarEmpowermentBuff) == 3 or (Player:BuffRemainsP(S.LunarEmpowermentBuff) < 5 and Player:BuffP(S.LunarEmpowermentBuff)) or Cache.EnemiesCount[40] >= 2) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath
    if S.SolarWrath:IsCastableP() and (true) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
  end
  local function SingleTarget()
    -- force_of_nature
    if S.ForceofNature:IsCastableP() and (true) then
      if AR.Cast(S.ForceofNature) then return ""; end
    end
    -- stellar_flare,target_if=refreshable,if=target.time_to_die>10
    if S.StellarFlare:IsCastableP() and (Target:TimeToDie() > 10) then
      if AR.Cast(S.StellarFlare) then return ""; end
    end
    -- moonfire,target_if=refreshable,if=((talent.natures_balance.enabled&remains<3)|remains<6.6)&astral_power.deficit>7&target.time_to_die>8
    if S.Moonfire:IsCastableP() and (((S.NaturesBalance:IsAvailable() and Target:DebuffRemainsP(S.Moonfire) < 3) or Target:DebuffRemainsP(S.Moonfire) < 6.6) and Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 8) then
      if AR.Cast(S.Moonfire) then return ""; end
    end
    -- sunfire,target_if=refreshable,if=((talent.natures_balance.enabled&remains<3)|remains<5.4)&astral_power.deficit>7&target.time_to_die>8
    if S.Sunfire:IsCastableP() and (((S.NaturesBalance:IsAvailable() and Target:DebuffRemainsP(S.Sunfire) < 3) or Target:DebuffRemainsP(S.Sunfire) < 5.4) and Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 8) then
      if AR.Cast(S.Sunfire) then return ""; end
    end
    -- starfall,if=buff.oneths_overconfidence.react&(!buff.astral_acceleration.up|buff.astral_acceleration.remains>5|astral_power.deficit<44)
    if S.Starfall:IsCastableP() and (bool(Player:BuffStackP(S.OnethsOverconfidenceBuff)) and (not Player:BuffP(S.AstralAccelerationBuff) or Player:BuffRemainsP(S.AstralAccelerationBuff) > 5 or Player:AstralPowerDeficit() < 44)) then
      if AR.Cast(S.Starfall) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.stack=3
    if S.SolarWrath:IsCastableP() and (Player:BuffStackP(S.SolarEmpowermentBuff) == 3) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.stack=3
    if S.LunarStrike:IsCastableP() and (Player:BuffStackP(S.LunarEmpowermentBuff) == 3) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- starsurge,if=astral_power.deficit<44|(buff.celestial_alignment.up|buff.incarnation.up|buff.astral_acceleration.remains>5|(set_bonus.tier21_4pc&!buff.solar_solstice.up))|(gcd.max*(astral_power%40))>target.time_to_die
    if S.Starsurge:IsCastableP() and (Player:AstralPowerDeficit() < 44 or (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff) or Player:BuffRemainsP(S.AstralAccelerationBuff) > 5 or (AC.Tier21_4Pc and not Player:BuffP(S.SolarSolsticeBuff))) or (Player:GCD() * (FutureAstralPower() / 40)) > Target:TimeToDie()) then
      if AR.Cast(S.Starsurge) then return ""; end
    end
    -- new_moon,if=astral_power.deficit>14&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
    if S.NewMoon:IsCastableP() and (Player:AstralPowerDeficit() > 14 and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.NewMoon:ChargesP() == 2 and S.NewMoon:RechargeP() < 5) or S.NewMoon:ChargesP() == 3)) then
      if AR.Cast(S.NewMoon) then return ""; end
    end
    -- half_moon,if=astral_power.deficit>24&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
    if S.HalfMoon:IsCastableP() and (Player:AstralPowerDeficit() > 24 and (not (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.HalfMoon:ChargesP() == 2 and S.HalfMoon:RechargeP() < 5) or S.HalfMoon:ChargesP() == 3)) then
      if AR.Cast(S.HalfMoon) then return ""; end
    end
    -- full_moon,if=astral_power.deficit>44
    if S.FullMoon:IsCastableP() and (Player:AstralPowerDeficit() > 44) then
      if AR.Cast(S.FullMoon) then return ""; end
    end
    -- lunar_strike,if=buff.warrior_of_elune.up&buff.lunar_empowerment.up
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.WarriorofEluneBuff) and Player:BuffP(S.LunarEmpowermentBuff)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath,if=buff.solar_empowerment.up
    if S.SolarWrath:IsCastableP() and (Player:BuffP(S.SolarEmpowermentBuff)) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
    -- lunar_strike,if=buff.lunar_empowerment.up
    if S.LunarStrike:IsCastableP() and (Player:BuffP(S.LunarEmpowermentBuff)) then
      if AR.Cast(S.LunarStrike) then return ""; end
    end
    -- solar_wrath
    if S.SolarWrath:IsCastableP() and (true) then
      if AR.Cast(S.SolarWrath) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- potion,name=potion_of_prolonged_power,if=buff.celestial_alignment.up|buff.incarnation.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- blessing_of_elune,if=active_enemies<=2&talent.blessing_of_the_ancients.enabled&buff.blessing_of_elune.down
  if S.BlessingofElune:IsCastableP() and (Cache.EnemiesCount[40] <= 2 and S.BlessingoftheAncients:IsAvailable() and Player:BuffDownP(S.BlessingofEluneBuff)) then
    if AR.Cast(S.BlessingofElune) then return ""; end
  end
  -- blessing_of_elune,if=active_enemies>=3&talent.blessing_of_the_ancients.enabled&buff.blessing_of_anshe.down
  if S.BlessingofElune:IsCastableP() and (Cache.EnemiesCount[40] >= 3 and S.BlessingoftheAncients:IsAvailable() and Player:BuffDownP(S.BlessingofAnsheBuff)) then
    if AR.Cast(S.BlessingofElune) then return ""; end
  end
  -- blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
  if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
    if AR.Cast(S.BloodFury, Settings.Balance.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=buff.celestial_alignment.up|buff.incarnation.up
  if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
    if AR.Cast(S.Berserking, Settings.Balance.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
    if AR.Cast(S.ArcaneTorrent, Settings.Balance.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains<target.time_to_die
  if (S.FuryofElune:IsAvailable() and S.FuryofElune:CooldownRemainsP() < Target:TimeToDie()) then
    local ShouldReturn = FuryofElune(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher&active_enemies<=1
  if (I.TheEmeraldDreamcatcher:IsEquipped() and Cache.EnemiesCount[40] <= 1) then
    local ShouldReturn = Ed(); if ShouldReturn then return ShouldReturn; end
  end
  -- astral_communion,if=astral_power.deficit>=79
  if S.AstralCommunion:IsCastableP() and (Player:AstralPowerDeficit() >= 79) then
    if AR.Cast(S.AstralCommunion) then return ""; end
  end
  -- warrior_of_elune
  if S.WarriorofElune:IsCastableP() and (true) then
    if AR.Cast(S.WarriorofElune) then return ""; end
  end
  -- incarnation,if=astral_power>=40
  if S.Incarnation:IsCastableP() and (FutureAstralPower() >= 40) then
    if AR.Cast(S.Incarnation) then return ""; end
  end
  -- celestial_alignment,if=astral_power>=40
  if S.CelestialAlignment:IsCastableP() and (FutureAstralPower() >= 40) then
    if AR.Cast(S.CelestialAlignment) then return ""; end
  end
  -- call_action_list,name=AoE,if=(spell_targets.starfall>=2&talent.stellar_drift.enabled)|spell_targets.starfall>=3
  if ((Cache.EnemiesCount[40] >= 2 and S.StellarDrift:IsAvailable()) or Cache.EnemiesCount[40] >= 3) then
    local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=single_target
  if (true) then
    local ShouldReturn = SingleTarget(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(102, APL)
