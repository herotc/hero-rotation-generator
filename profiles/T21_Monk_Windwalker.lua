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
if not Spell.Monk then Spell.Monk = {} end
Spell.Monk.Windwalker = {
  ChiBurst                              = Spell(123986),
  ChiWave                               = Spell(115098),
  InvokeXuentheWhiteTiger               = Spell(123904),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  TouchofDeath                          = Spell(115080),
  GaleBurst                             = Spell(),
  Serenity                              = Spell(152173),
  StrikeoftheWindlord                   = Spell(205320),
  FistsofFury                           = Spell(113656),
  RisingSunKick                         = Spell(107428),
  TigerPalm                             = Spell(100780),
  StormEarthandFire                     = Spell(137639),
  StormEarthandFireBuff                 = Spell(137639),
  SerenityBuff                          = Spell(152173),
  BlackoutKick                          = Spell(100784),
  PressurePointBuff                     = Spell(247255),
  SpinningCraneKick                     = Spell(107270),
  RushingJadeWind                       = Spell(116847),
  RushingJadeWindBuff                   = Spell(116847),
  EnergizingElixir                      = Spell(115288),
  WhirlingDragonPunch                   = Spell(152175),
  BokProcBuff                           = Spell(),
  CracklingJadeLightning                = Spell(117952),
  TheEmperorsCapacitorBuff              = Spell(235054),
  SpearHandStrike                       = Spell(116705),
  TouchofKarma                          = Spell(122470)
};
local S = Spell.Monk.Windwalker;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Windwalker = {
  ProlongedPower                   = Item(142117),
  HiddenMastersForbiddenTouch      = Item(137057),
  DrinkingHornCover                = Item(137097),
  TheEmperorsCapacitor             = Item(144239)
};
local I = Item.Monk.Windwalker;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Monk.Commons,
  Windwalker = AR.GUISettings.APL.Monk.Windwalker
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() and (true) then
      if AR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if AR.Cast(S.ChiWave) then return ""; end
    end
  end
  local function Cd()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and (true) then
      if AR.Cast(S.InvokeXuentheWhiteTiger) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Windwalker.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Windwalker.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and energy.time_to_max >= 0.5) then
      if AR.Cast(S.ArcaneTorrent, Settings.Windwalker.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- touch_of_death,cycle_targets=1,max_cycle_targets=2,if=!artifact.gale_burst.enabled&equipped.hidden_masters_forbidden_touch&!prev_gcd.1.touch_of_death
    if S.TouchofDeath:IsCastableP() and (not S.GaleBurst:ArtifactEnabled() and I.HiddenMastersForbiddenTouch:IsEquipped() and not Player:PrevGCDP(1, S.TouchofDeath)) then
      if AR.Cast(S.TouchofDeath) then return ""; end
    end
    -- touch_of_death,if=!artifact.gale_burst.enabled&!equipped.hidden_masters_forbidden_touch
    if S.TouchofDeath:IsCastableP() and (not S.GaleBurst:ArtifactEnabled() and not I.HiddenMastersForbiddenTouch:IsEquipped()) then
      if AR.Cast(S.TouchofDeath) then return ""; end
    end
    -- touch_of_death,cycle_targets=1,max_cycle_targets=2,if=artifact.gale_burst.enabled&((talent.serenity.enabled&cooldown.serenity.remains<=1)|chi>=2)&(cooldown.strike_of_the_windlord.remains<8|cooldown.fists_of_fury.remains<=4)&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
    if S.TouchofDeath:IsCastableP() and (S.GaleBurst:ArtifactEnabled() and ((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 1) or Player:Chi() >= 2) and (S.StrikeoftheWindlord:CooldownRemainsP() < 8 or S.FistsofFury:CooldownRemainsP() <= 4) and S.RisingSunKick:CooldownRemainsP() < 7 and not Player:PrevGCDP(1, S.TouchofDeath)) then
      if AR.Cast(S.TouchofDeath) then return ""; end
    end
  end
  local function Sef()
    -- tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and energy.time_to_max >= 0.5) then
      if AR.Cast(S.ArcaneTorrent, Settings.Windwalker.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
    if S.StormEarthandFire:IsCastableP() and (not Player:BuffP(S.StormEarthandFireBuff)) then
      if AR.Cast(S.StormEarthandFire) then return ""; end
    end
    -- call_action_list,name=st
    if (true) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
  end
  local function Serenity()
    -- tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1&!buff.serenity.up
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.SerenityBuff)) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- serenity
    if S.Serenity:IsCastableP() and (true) then
      if AR.Cast(S.Serenity) then return ""; end
    end
    -- rising_sun_kick,cycle_targets=1,if=active_enemies<3
    if S.RisingSunKick:IsCastableP() and (Cache.EnemiesCount[8] < 3) then
      if AR.Cast(S.RisingSunKick) then return ""; end
    end
    -- strike_of_the_windlord
    if S.StrikeoftheWindlord:IsCastableP() and (true) then
      if AR.Cast(S.StrikeoftheWindlord) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=(!prev_gcd.1.blackout_kick)&(prev_gcd.1.strike_of_the_windlord|prev_gcd.1.fists_of_fury)&active_enemies<2
    if S.BlackoutKick:IsCastableP() and ((not Player:PrevGCDP(1, S.BlackoutKick)) and (Player:PrevGCDP(1, S.StrikeoftheWindlord) or Player:PrevGCDP(1, S.FistsofFury)) and Cache.EnemiesCount[8] < 2) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
    -- fists_of_fury,if=((equipped.drinking_horn_cover&buff.pressure_point.remains<=2&set_bonus.tier20_4pc)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
    if S.FistsofFury:IsCastableP() and (((I.DrinkingHornCover:IsEquipped() and Player:BuffRemainsP(S.PressurePointBuff) <= 2 and AC.Tier20_4Pc) and (S.RisingSunKick:CooldownRemainsP() > 1 or Cache.EnemiesCount[8] > 1))) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=((!equipped.drinking_horn_cover|buff.bloodlust.up|buff.serenity.remains<1)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
    if S.FistsofFury:IsCastableP() and (((not I.DrinkingHornCover:IsEquipped() or Player:HasHeroism() or Player:BuffRemainsP(S.SerenityBuff) < 1) and (S.RisingSunKick:CooldownRemainsP() > 1 or Cache.EnemiesCount[8] > 1))) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if AR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- rushing_jade_wind,if=!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down&buff.serenity.remains>=4
    if S.RushingJadeWind:IsCastableP() and (not Player:PrevGCDP(1, S.RushingJadeWind) and Player:BuffDownP(S.RushingJadeWindBuff) and Player:BuffRemainsP(S.SerenityBuff) >= 4) then
      if AR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- rising_sun_kick,cycle_targets=1,if=active_enemies>=3
    if S.RisingSunKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if AR.Cast(S.RisingSunKick) then return ""; end
    end
    -- rushing_jade_wind,if=!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down&active_enemies>1
    if S.RushingJadeWind:IsCastableP() and (not Player:PrevGCDP(1, S.RushingJadeWind) and Player:BuffDownP(S.RushingJadeWindBuff) and Cache.EnemiesCount[8] > 1) then
      if AR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if AR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick)) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
  end
  local function SerenityOpener()
    -- tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1&!buff.serenity.up&cooldown.fists_of_fury.remains<=0
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.SerenityBuff) and S.FistsofFury:CooldownRemainsP() <= 0) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and energy.time_to_max >= 0.5) then
      if AR.Cast(S.ArcaneTorrent, Settings.Windwalker.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- call_action_list,name=cd,if=cooldown.fists_of_fury.remains>1
    if (S.FistsofFury:CooldownRemainsP() > 1) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- serenity,if=cooldown.fists_of_fury.remains>1
    if S.Serenity:IsCastableP() and (S.FistsofFury:CooldownRemainsP() > 1) then
      if AR.Cast(S.Serenity) then return ""; end
    end
    -- rising_sun_kick,cycle_targets=1,if=active_enemies<3&buff.serenity.up
    if S.RisingSunKick:IsCastableP() and (Cache.EnemiesCount[8] < 3 and Player:BuffP(S.SerenityBuff)) then
      if AR.Cast(S.RisingSunKick) then return ""; end
    end
    -- strike_of_the_windlord,if=buff.serenity.up
    if S.StrikeoftheWindlord:IsCastableP() and (Player:BuffP(S.SerenityBuff)) then
      if AR.Cast(S.StrikeoftheWindlord) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=(!prev_gcd.1.blackout_kick)&(prev_gcd.1.strike_of_the_windlord)
    if S.BlackoutKick:IsCastableP() and ((not Player:PrevGCDP(1, S.BlackoutKick)) and (Player:PrevGCDP(1, S.StrikeoftheWindlord))) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
    -- fists_of_fury,if=cooldown.rising_sun_kick.remains>1|buff.serenity.down,interrupt=1
    if S.FistsofFury:IsCastableP() and (S.RisingSunKick:CooldownRemainsP() > 1 or Player:BuffDownP(S.SerenityBuff)) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=buff.serenity.down&chi<=2&cooldown.serenity.remains<=0&prev_gcd.1.tiger_palm
    if S.BlackoutKick:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and Player:Chi() <= 2 and S.Serenity:CooldownRemainsP() <= 0 and Player:PrevGCDP(1, S.TigerPalm)) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
    -- tiger_palm,cycle_targets=1,if=chi=1
    if S.TigerPalm:IsCastableP() and (Player:Chi() == 1) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
  end
  local function St()
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- energizing_elixir,if=chi<=1&(cooldown.rising_sun_kick.remains=0|(artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains=0)|energy<50)
    if S.EnergizingElixir:IsCastableP() and (Player:Chi() <= 1 and (S.RisingSunKick:CooldownRemainsP() == 0 or (S.StrikeoftheWindlord:ArtifactEnabled() and S.StrikeoftheWindlord:CooldownRemainsP() == 0) or Player:Energy() < 50)) then
      if AR.Cast(S.EnergizingElixir) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and energy.time_to_max >= 0.5) then
      if AR.Cast(S.ArcaneTorrent, Settings.Windwalker.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy.time_to_max<=0.5&chi.max-chi>=2
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and energy.time_to_max <= 0.5 and Player:ChiMax() - Player:Chi() >= 2) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
    -- strike_of_the_windlord,if=!talent.serenity.enabled|cooldown.serenity.remains>=10
    if S.StrikeoftheWindlord:IsCastableP() and (not S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 10) then
      if AR.Cast(S.StrikeoftheWindlord) then return ""; end
    end
    -- rising_sun_kick,cycle_targets=1,if=((chi>=3&energy>=40)|chi>=5)&(!talent.serenity.enabled|cooldown.serenity.remains>=6)
    if S.RisingSunKick:IsCastableP() and (((Player:Chi() >= 3 and Player:Energy() >= 40) or Player:Chi() >= 5) and (not S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 6)) then
      if AR.Cast(S.RisingSunKick) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and energy.time_to_max > 2) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and energy.time_to_max > 2) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (not S.Serenity:IsAvailable() and energy.time_to_max > 2) then
      if AR.Cast(S.FistsofFury) then return ""; end
    end
    -- rising_sun_kick,cycle_targets=1,if=!talent.serenity.enabled|cooldown.serenity.remains>=5
    if S.RisingSunKick:IsCastableP() and (not S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 5) then
      if AR.Cast(S.RisingSunKick) then return ""; end
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() and (true) then
      if AR.Cast(S.WhirlingDragonPunch) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled|buff.bok_proc.up)
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and AC.Tier21_4Pc and (not AC.Tier19_2Pc or S.Serenity:IsAvailable() or Player:BuffP(S.BokProcBuff))) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
    -- spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi.max-chi>=0))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
    if S.SpinningCraneKick:IsCastableP() and ((Cache.EnemiesCount[8] >= 3 or (Player:BuffP(S.BokProcBuff) and Player:ChiMax() - Player:Chi() >= 0)) and not Player:PrevGCDP(1, S.SpinningCraneKick) and AC.Tier21_4Pc) then
      if AR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 19 and energy.time_to_max > 3) then
      if AR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and energy.time_to_max > 3) then
      if AR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if AR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.1.rushing_jade_wind
    if S.RushingJadeWind:IsCastableP() and (Player:ChiMax() - Player:Chi() > 1 and not Player:PrevGCDP(1, S.RushingJadeWind)) then
      if AR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- blackout_kick,cycle_targets=1,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!artifact.strike_of_the_windlord.enabled|cooldown.strike_of_the_windlord.remains>1)|chi>2)&(cooldown.fists_of_fury.remains>1|chi>3)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsCastableP() and ((Player:Chi() > 1 or Player:BuffP(S.BokProcBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemainsP() < S.FistsofFury:CooldownRemainsP())) and ((S.RisingSunKick:CooldownRemainsP() > 1 and (not S.StrikeoftheWindlord:ArtifactEnabled() or S.StrikeoftheWindlord:CooldownRemainsP() > 1) or Player:Chi() > 2) and (S.FistsofFury:CooldownRemainsP() > 1 or Player:Chi() > 3) or Player:PrevGCDP(1, S.TigerPalm)) and not Player:PrevGCDP(1, S.BlackoutKick)) then
      if AR.Cast(S.BlackoutKick) then return ""; end
    end
    -- chi_wave,if=energy.time_to_max>1
    if S.ChiWave:IsCastableP() and (energy.time_to_max > 1) then
      if AR.Cast(S.ChiWave) then return ""; end
    end
    -- chi_burst,if=energy.time_to_max>1
    if S.ChiBurst:IsCastableP() and (energy.time_to_max > 1) then
      if AR.Cast(S.ChiBurst) then return ""; end
    end
    -- tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&(chi.max-chi>=2|energy.time_to_max<1)
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and (Player:ChiMax() - Player:Chi() >= 2 or energy.time_to_max < 1)) then
      if AR.Cast(S.TigerPalm) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if AR.Cast(S.ChiWave) then return ""; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() and (true) then
      if AR.Cast(S.ChiBurst) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- spear_hand_strike,if=target.debuff.casting.react
  if S.SpearHandStrike:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (bool(target.debuff.casting.react)) then
    if AR.CastAnnotated(S.SpearHandStrike, false, "Interrupt") then return ""; end
  end
  -- touch_of_karma,interval=90,pct_health=0.5
  if S.TouchofKarma:IsCastableP() and (true) then
    if AR.Cast(S.TouchofKarma) then return ""; end
  end
  -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.SerenityBuff) or Player:BuffP(S.StormEarthandFireBuff) or (not S.Serenity:IsAvailable() and bool(trinket.proc.agility.react)) or Player:HasHeroism() or Target:TimeToDie() <= 60) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- touch_of_death,if=target.time_to_die<=9
  if S.TouchofDeath:IsCastableP() and (Target:TimeToDie() <= 9) then
    if AR.Cast(S.TouchofDeath) then return ""; end
  end
  -- call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
  if ((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0) or Player:BuffP(S.SerenityBuff)) then
    local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
  if (not S.Serenity:IsAvailable() and (Player:BuffP(S.StormEarthandFireBuff) or S.StormEarthandFire:ChargesP() == 2)) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=!talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=18&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=25|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
  if (not S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.StrikeoftheWindlord:CooldownRemainsP() <= 18 and S.FistsofFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1 or Target:TimeToDie() <= 25 or S.TouchofDeath:CooldownRemainsP() > 112) and S.StormEarthandFire:ChargesP() == 1) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=!talent.serenity.enabled&!equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=15|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
  if (not S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and (S.StrikeoftheWindlord:CooldownRemainsP() <= 14 and S.FistsofFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1 or Target:TimeToDie() <= 15 or S.TouchofDeath:CooldownRemainsP() > 112) and S.StormEarthandFire:ChargesP() == 1) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=st
  if (true) then
    local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
  end
end