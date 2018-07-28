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
if not Spell.Monk then Spell.Monk = {} end
Spell.Monk.Windwalker = {
  ChiBurst                              = Spell(123986),
  ChiWave                               = Spell(115098),
  EnergizingElixir                      = Spell(115288),
  TigerPalm                             = Spell(100780),
  RisingSunKick                         = Spell(107428),
  FistoftheWhiteTiger                   = Spell(),
  ArcaneTorrent                         = Spell(50613),
  FistsofFury                           = Spell(113656),
  Serenity                              = Spell(152173),
  WhirlingDragonPunch                   = Spell(152175),
  SpinningCraneKick                     = Spell(107270),
  BokProcBuff                           = Spell(),
  BlackoutKick                          = Spell(100784),
  CracklingJadeLightning                = Spell(117952),
  TheEmperorsCapacitorBuff              = Spell(235054),
  InvokeXuentheWhiteTiger               = Spell(123904),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  TouchofDeath                          = Spell(115080),
  StormEarthandFire                     = Spell(137639),
  StormEarthandFireBuff                 = Spell(137639),
  SerenityBuff                          = Spell(152173),
  RushingJadeWind                       = Spell(116847),
  RushingJadeWindBuff                   = Spell(116847),
  SpearHandStrike                       = Spell(116705),
  TouchofKarma                          = Spell(122470),
  GoodKarma                             = Spell()
};
local S = Spell.Monk.Windwalker;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Windwalker = {
  ProlongedPower                   = Item(142117),
  DrinkingHornCover                = Item(137097),
  TheEmperorsCapacitor             = Item(144239),
  HiddenMastersForbiddenTouch      = Item(137057)
};
local I = Item.Monk.Windwalker;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Monk.Commons,
  Windwalker = HR.GUISettings.APL.Monk.Windwalker
};

-- Variables

local EnemyRanges = {8}
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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cd, Sef, Serenity, St
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() and (true) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if HR.Cast(S.ChiWave) then return ""; end
    end
  end
  Aoe = function()
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&(cooldown.rising_sun_kick.remains=0|(talent.fist_of_the_white_tiger.enabled&cooldown.fist_of_the_white_tiger.remains=0)|energy<50)
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 1 and (S.RisingSunKick:CooldownRemainsP() == 0 or (S.FistoftheWhiteTiger:IsAvailable() and S.FistoftheWhiteTiger:CooldownRemainsP() == 0) or Player:Energy() < 50)) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and Player:EnergyTimeToMaxPredicted() > 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and Player:EnergyTimeToMaxPredicted() > 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (not S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=cooldown.rising_sun_kick.remains>=3.5&chi<=5
    if S.FistsofFury:IsCastableP() and (S.RisingSunKick:CooldownRemainsP() >= 3.5 and Player:Chi() <= 5) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() and (true) then
      if HR.Cast(S.WhirlingDragonPunch) then return ""; end
    end
    -- rising_sun_kick,target_if=cooldown.whirling_dragon_punch.remains>=gcd&!prev_gcd.1.rising_sun_kick&cooldown.fists_of_fury.remains>gcd
    if S.RisingSunKick:IsCastableP() and (true) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- chi_burst,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
    if S.ChiBurst:IsCastableP() and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() and (true) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi.max-chi>=0))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
    if S.SpinningCraneKick:IsCastableP() and ((Cache.EnemiesCount[8] >= 3 or (Player:BuffP(S.BokProcBuff) and Player:ChiMax() - Player:Chi() >= 0)) and not Player:PrevGCDP(1, S.SpinningCraneKick) and HL.Tier21_4Pc) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled)
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and (not HL.Tier19_2Pc or S.Serenity:IsAvailable())) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!talent.fist_of_the_white_tiger.enabled|cooldown.fist_of_the_white_tiger.remains>1)|chi>4)&(cooldown.fists_of_fury.remains>1|chi>2)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsCastableP() and ((Player:Chi() > 1 or Player:BuffP(S.BokProcBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemainsP() < S.FistsofFury:CooldownRemainsP())) and ((S.RisingSunKick:CooldownRemainsP() > 1 and (not S.FistoftheWhiteTiger:IsAvailable() or S.FistoftheWhiteTiger:CooldownRemainsP() > 1) or Player:Chi() > 4) and (S.FistsofFury:CooldownRemainsP() > 1 or Player:Chi() > 2) or Player:PrevGCDP(1, S.TigerPalm)) and not Player:PrevGCDP(1, S.BlackoutKick)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BokProcBuff)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyTimeToMaxPredicted() <= 1 and Player:ChiMax() - Player:Chi() >= 2) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- chi_wave,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
    if S.ChiWave:IsCastableP() and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.ChiWave) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if HR.Cast(S.ChiWave) then return ""; end
    end
  end
  Cd = function()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.LightsJudgment) then return ""; end
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=equipped.hidden_masters_forbidden_touch&!prev_gcd.1.touch_of_death
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (I.HiddenMastersForbiddenTouch:IsEquipped() and not Player:PrevGCDP(1, S.TouchofDeath)) then
      if HR.Cast(S.TouchofDeath) then return ""; end
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=((talent.serenity.enabled&cooldown.serenity.remains<=1)&cooldown.fists_of_fury.remains<=4)&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 1) and S.FistsofFury:CooldownRemainsP() <= 4) and S.RisingSunKick:CooldownRemainsP() < 7 and not Player:PrevGCDP(1, S.TouchofDeath)) then
      if HR.Cast(S.TouchofDeath) then return ""; end
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=((!talent.serenity.enabled&cooldown.storm_earth_and_fire.remains<=1)|chi>=2)&cooldown.fists_of_fury.remains<=4&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (((not S.Serenity:IsAvailable() and S.StormEarthandFire:CooldownRemainsP() <= 1) or Player:Chi() >= 2) and S.FistsofFury:CooldownRemainsP() <= 4 and S.RisingSunKick:CooldownRemainsP() < 7 and not Player:PrevGCDP(1, S.TouchofDeath)) then
      if HR.Cast(S.TouchofDeath) then return ""; end
    end
  end
  Sef = function()
    -- tiger_palm,target_if=debuff.mark_of_the_crane.down,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
    if S.StormEarthandFire:IsCastableP() and HR.CDsON() and (not Player:BuffP(S.StormEarthandFireBuff)) then
      if HR.Cast(S.StormEarthandFire, Settings.Windwalker.OffGCDasOffGCD.StormEarthandFire) then return ""; end
    end
    -- call_action_list,name=aoe,if=active_enemies>3
    if (Cache.EnemiesCount[8] > 3) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<=3
    if (Cache.EnemiesCount[8] <= 3) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
  end
  Serenity = function()
    -- fist_of_the_white_tiger,if=buff.bloodlust.up&!buff.serenity.up
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:HasHeroism() and not Player:BuffP(S.SerenityBuff)) then
      if HR.Cast(S.FistoftheWhiteTiger) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.SerenityBuff)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- rushing_jade_wind,if=talent.rushing_jade_wind.enabled&!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsCastableP() and (S.RushingJadeWind:IsAvailable() and not Player:PrevGCDP(1, S.RushingJadeWind) and Player:BuffDownP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- serenity
    if S.Serenity:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.Serenity, Settings.Windwalker.OffGCDasOffGCD.Serenity) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsCastableP() and (true) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- fists_of_fury,if=prev_gcd.1.rising_sun_kick&prev_gcd.2.serenity
    if S.FistsofFury:IsCastableP() and (Player:PrevGCDP(1, S.RisingSunKick) and Player:PrevGCDP(2, S.Serenity)) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsCastableP() and (true) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsofFury:CooldownRemainsP() >= 2) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- fists_of_fury,if=((!equipped.drinking_horn_cover|buff.bloodlust.up|buff.serenity.remains<1)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
    if S.FistsofFury:IsCastableP() and (((not I.DrinkingHornCover:IsEquipped() or Player:HasHeroism() or Player:BuffRemainsP(S.SerenityBuff) < 1) and (S.RisingSunKick:CooldownRemainsP() > 1 or Cache.EnemiesCount[8] > 1))) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies>=3
    if S.RisingSunKick:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick)) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
  end
  St = function()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() and (true) then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return ""; end
    end
    -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
    if S.StormEarthandFire:IsCastableP() and HR.CDsON() and (not Player:BuffP(S.StormEarthandFireBuff)) then
      if HR.Cast(S.StormEarthandFire, Settings.Windwalker.OffGCDasOffGCD.StormEarthandFire) then return ""; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&!prev_gcd.1.rushing_jade_wind
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff) and not Player:PrevGCDP(1, S.RushingJadeWind)) then
      if HR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (not Player:PrevGCDP(1, S.TigerPalm)) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BokProcBuff)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2&!buff.serenity.up
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyTimeToMaxPredicted() <= 1 and Player:ChiMax() - Player:Chi() >= 2 and not Player:BuffP(S.SerenityBuff)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- fist_of_the_white_tiger,if=chi.max-chi>=3
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 3) then
      if HR.Cast(S.FistoftheWhiteTiger) then return ""; end
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() and (true) then
      if HR.Cast(S.WhirlingDragonPunch) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=((chi>=3&energy>=40)|chi>=5)&(talent.serenity.enabled|cooldown.serenity.remains>=6)
    if S.RisingSunKick:IsCastableP() and (((Player:Chi() >= 3 and Player:Energy() >= 40) or Player:Chi() >= 5) and (S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 6)) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and Player:EnergyTimeToMaxPredicted() > 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and Player:EnergyTimeToMaxPredicted() > 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fists_of_fury,if=!talent.serenity.enabled
    if S.FistsofFury:IsCastableP() and (not S.Serenity:IsAvailable()) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=cooldown.serenity.remains>=5|(!talent.serenity.enabled)
    if S.RisingSunKick:IsCastableP() and (S.Serenity:CooldownRemainsP() >= 5 or (not S.Serenity:IsAvailable())) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1
    if S.BlackoutKick:IsCastableP() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
    if S.CracklingJadeLightning:IsCastableP() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.CracklingJadeLightning) then return ""; end
    end
    -- blackout_kick
    if S.BlackoutKick:IsCastableP() and (true) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if HR.Cast(S.ChiWave) then return ""; end
    end
    -- chi_burst,if=energy.time_to_max>1&talent.serenity.enabled
    if S.ChiBurst:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 1 and S.Serenity:IsAvailable()) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)&!buff.serenity.up
    if S.TigerPalm:IsCastableP() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3) and not Player:BuffP(S.SerenityBuff)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- chi_burst,if=chi.max-chi>=3&energy.time_to_max>1&!talent.serenity.enabled
    if S.ChiBurst:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 3 and Player:EnergyTimeToMaxPredicted() > 1 and not S.Serenity:IsAvailable()) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- spear_hand_strike,if=target.debuff.casting.react
  if S.SpearHandStrike:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (Target:IsCasting()) then
    if HR.CastAnnotated(S.SpearHandStrike, false, "Interrupt") then return ""; end
  end
  -- touch_of_karma,interval=90,pct_health=0.5,if=!talent.Good_Karma.enabled,interval=90,pct_health=0.5
  if S.TouchofKarma:IsCastableP() and (not S.GoodKarma:IsAvailable()) then
    if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return ""; end
  end
  -- touch_of_karma,interval=90,pct_health=1.0
  if S.TouchofKarma:IsCastableP() and (true) then
    if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return ""; end
  end
  -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.SerenityBuff) or Player:BuffP(S.StormEarthandFireBuff) or (not S.Serenity:IsAvailable() and bool(trinket.proc.agility.react)) or Player:HasHeroism() or Target:TimeToDie() <= 60) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- touch_of_death,if=target.time_to_die<=9
  if S.TouchofDeath:IsCastableP() and HR.CDsON() and (Target:TimeToDie() <= 9) then
    if HR.Cast(S.TouchofDeath) then return ""; end
  end
  -- call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
  if ((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0) or Player:BuffP(S.SerenityBuff)) then
    local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
  if (not S.Serenity:IsAvailable() and (Player:BuffP(S.StormEarthandFireBuff) or S.StormEarthandFire:ChargesP() == 2)) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=(!talent.serenity.enabled&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=25|cooldown.touch_of_death.remains>112
  if ((not S.Serenity:IsAvailable() and S.FistsofFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchofDeath:CooldownRemainsP() > 112) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=(!talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
  if ((not S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.FistsofFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15 or S.TouchofDeath:CooldownRemainsP() > 112 and S.StormEarthandFire:ChargesP() == 1) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=sef,if=(!talent.serenity.enabled&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=25|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
  if ((not S.Serenity:IsAvailable() and S.FistsofFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchofDeath:CooldownRemainsP() > 112 and S.StormEarthandFire:ChargesP() == 1) then
    local ShouldReturn = Sef(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=aoe,if=active_enemies>3
  if (Cache.EnemiesCount[8] > 3) then
    local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=st,if=active_enemies<=3
  if (Cache.EnemiesCount[8] <= 3) then
    local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(269, APL)
