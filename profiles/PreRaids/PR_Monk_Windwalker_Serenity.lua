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
  SerenityBuff                          = Spell(152173),
  Serenity                              = Spell(152173),
  FistoftheWhiteTiger                   = Spell(261947),
  ChiWave                               = Spell(115098),
  RisingSunKick                         = Spell(107428),
  MarkoftheCraneDebuff                  = Spell(228287),
  WhirlingDragonPunch                   = Spell(152175),
  FistsofFury                           = Spell(113656),
  EnergizingElixir                      = Spell(115288),
  TigerPalm                             = Spell(100780),
  RushingJadeWind                       = Spell(261715),
  RushingJadeWindBuff                   = Spell(261715),
  SpinningCraneKick                     = Spell(101546),
  HitCombo                              = Spell(196741),
  FlyingSerpentKick                     = Spell(101545),
  BokProcBuff                           = Spell(116768),
  BlackoutKick                          = Spell(100784),
  InvokeXuentheWhiteTiger               = Spell(123904),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  TouchofDeath                          = Spell(115080),
  StormEarthandFire                     = Spell(137639),
  DanceofChijiBuff                      = Spell(),
  SwiftRoundhouseBuff                   = Spell(278710),
  SpearHandStrike                       = Spell(116705),
  TouchofKarma                          = Spell(122470),
  StormEarthandFireBuff                 = Spell(137639)
};
local S = Spell.Monk.Windwalker;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Windwalker = {
  ProlongedPower                   = Item(142117),
  LustrousGoldenPlumage            = Item(159617)
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


local function EvaluateTargetIfFilterRisingSunKick19(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick32(TargetUnit)
  return (S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < 5) and S.FistsofFury:CooldownRemainsP() > 3
end

local function EvaluateTargetIfFilterTigerPalm62(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm73(TargetUnit)
  return Player:ChiMax() - Player:Chi() >= 2 and (not S.HitCombo:IsAvailable() or not Player:PrevGCDP(1, S.TigerPalm))
end

local function EvaluateTargetIfFilterBlackoutKick85(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick100(TargetUnit)
  return not Player:PrevGCDP(1, S.BlackoutKick) and (Player:BuffP(S.BokProcBuff) or (S.HitCombo:IsAvailable() and Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() < 4))
end

local function EvaluateTargetIfFilterRisingSunKick136(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick151(TargetUnit)
  return Cache.EnemiesCount[8] < 3 or Player:PrevGCDP(1, S.SpinningCraneKick)
end

local function EvaluateTargetIfFilterBlackoutKick193(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFilterRisingSunKick206(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick213(TargetUnit)
  return Player:Chi() >= 5
end

local function EvaluateTargetIfFilterRisingSunKick221(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFilterBlackoutKick254(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick271(TargetUnit)
  return not Player:PrevGCDP(1, S.BlackoutKick) and (S.RisingSunKick:CooldownRemainsP() > 3 or Player:Chi() >= 3) and (S.FistsofFury:CooldownRemainsP() > 4 or Player:Chi() >= 4 or (Player:Chi() == 2 and Player:PrevGCDP(1, S.TigerPalm))) and Player:BuffStackP(S.SwiftRoundhouseBuff) < 2
end

local function EvaluateTargetIfFilterTigerPalm287(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm296(TargetUnit)
  return not Player:PrevGCDP(1, S.TigerPalm) and Player:ChiMax() - Player:Chi() >= 2
end

local function EvaluateTargetIfFilterTigerPalm332(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm345(TargetUnit)
  return (Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiMax() - Player:Chi() >= 2 and not Player:PrevGCDP(1, S.TigerPalm)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cd, Serenity, St
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
    -- chi_burst,if=(!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled)
    if S.ChiBurst:IsCastableP() and ((not S.Serenity:IsAvailable() or not S.FistoftheWhiteTiger:IsAvailable())) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 6"; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 14"; end
    end
  end
  Aoe = function()
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<5)&cooldown.fists_of_fury.remains>3
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick19, EvaluateTargetIfRisingSunKick32) then return "rising_sun_kick 34" end
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return "whirling_dragon_punch 35"; end
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return "energizing_elixir 37"; end
    end
    -- fists_of_fury,if=energy.time_to_max>3
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 41"; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 43"; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(((chi>3|cooldown.fists_of_fury.remains>6)&(chi>=5|cooldown.fists_of_fury.remains>2))|energy.time_to_max<=3)
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick) and (((Player:Chi() > 3 or S.FistsofFury:CooldownRemainsP() > 6) and (Player:Chi() >= 5 or S.FistsofFury:CooldownRemainsP() > 2)) or Player:EnergyTimeToMaxPredicted() <= 3)) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 47"; end
    end
    -- chi_burst,if=chi<=3
    if S.ChiBurst:IsCastableP() and (Player:Chi() <= 3) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 55"; end
    end
    -- fist_of_the_white_tiger,if=chi.max-chi>=3
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 3) then
      if HR.Cast(S.FistoftheWhiteTiger) then return "fist_of_the_white_tiger 57"; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=2&(!talent.hit_combo.enabled|!prev_gcd.1.tiger_palm)
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm62, EvaluateTargetIfTigerPalm73) then return "tiger_palm 75" end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 76"; end
    end
    -- flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() and (Player:BuffDownP(S.BokProcBuff)) then
      if HR.Cast(S.FlyingSerpentKick) then return "flying_serpent_kick 78"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(buff.bok_proc.up|(talent.hit_combo.enabled&prev_gcd.1.tiger_palm&chi<4))
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick85, EvaluateTargetIfBlackoutKick100) then return "blackout_kick 102" end
    end
  end
  Cd = function()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return "invoke_xuen_the_white_tiger 103"; end
    end
    -- use_item,name=lustrous_golden_plumage
    if I.LustrousGoldenPlumage:IsReady() then
      if HR.CastSuggested(I.LustrousGoldenPlumage) then return "lustrous_golden_plumage 105"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 107"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 109"; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 111"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 113"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 115"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 117"; end
    end
    -- touch_of_death,if=target.time_to_die>9
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (Target:TimeToDie() > 9) then
      if HR.Cast(S.TouchofDeath) then return "touch_of_death 119"; end
    end
    -- storm_earth_and_fire,if=cooldown.storm_earth_and_fire.charges=2|(cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15
    if S.StormEarthandFire:IsCastableP() and HR.CDsON() and (S.StormEarthandFire:ChargesP() == 2 or (S.FistsofFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.StormEarthandFire, Settings.Windwalker.OffGCDasOffGCD.StormEarthandFire) then return "storm_earth_and_fire 121"; end
    end
    -- serenity,if=cooldown.rising_sun_kick.remains<=2|target.time_to_die<=12
    if S.Serenity:IsCastableP() and HR.CDsON() and (S.RisingSunKick:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 12) then
      if HR.Cast(S.Serenity, Settings.Windwalker.OffGCDasOffGCD.Serenity) then return "serenity 129"; end
    end
  end
  Serenity = function()
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies<3|prev_gcd.1.spinning_crane_kick
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick136, EvaluateTargetIfRisingSunKick151) then return "rising_sun_kick 153" end
    end
    -- fists_of_fury,if=(buff.bloodlust.up&prev_gcd.1.rising_sun_kick)|buff.serenity.remains<1|(active_enemies>1&active_enemies<5)
    if S.FistsofFury:IsCastableP() and ((Player:HasHeroism() and Player:PrevGCDP(1, S.RisingSunKick)) or Player:BuffRemainsP(S.SerenityBuff) < 1 or (Cache.EnemiesCount[8] > 1 and Cache.EnemiesCount[8] < 5)) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 154"; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(active_enemies>=3|(active_enemies=2&prev_gcd.1.blackout_kick))
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick) and (Cache.EnemiesCount[8] >= 3 or (Cache.EnemiesCount[8] == 2 and Player:PrevGCDP(1, S.BlackoutKick)))) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 172"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick193) then return "blackout_kick 200" end
    end
  end
  St = function()
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return "whirling_dragon_punch 201"; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=chi>=5
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick206, EvaluateTargetIfRisingSunKick213) then return "rising_sun_kick 215" end
    end
    -- fists_of_fury,if=energy.time_to_max>3
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 3) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 216"; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick221) then return "rising_sun_kick 228" end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&buff.dance_of_chiji.up
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick) and Player:BuffP(S.DanceofChijiBuff)) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 229"; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&active_enemies>1
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff) and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 235"; end
    end
    -- fist_of_the_white_tiger,if=chi<=2
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:Chi() <= 2) then
      if HR.Cast(S.FistoftheWhiteTiger) then return "fist_of_the_white_tiger 247"; end
    end
    -- energizing_elixir,if=chi<=3&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (Player:Chi() <= 3 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return "energizing_elixir 249"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>3|chi>=3)&(cooldown.fists_of_fury.remains>4|chi>=4|(chi=2&prev_gcd.1.tiger_palm))&buff.swift_roundhouse.stack<2
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick254, EvaluateTargetIfBlackoutKick271) then return "blackout_kick 273" end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 274"; end
    end
    -- chi_burst,if=chi.max-chi>=1&active_enemies=1|chi.max-chi>=2
    if S.ChiBurst:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 1 and Cache.EnemiesCount[8] == 1 or Player:ChiMax() - Player:Chi() >= 2) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 276"; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm287, EvaluateTargetIfTigerPalm296) then return "tiger_palm 298" end
    end
    -- flying_serpent_kick,if=prev_gcd.1.blackout_kick&chi>3&buff.swift_roundhouse.stack<2,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() and (Player:PrevGCDP(1, S.BlackoutKick) and Player:Chi() > 3 and Player:BuffStackP(S.SwiftRoundhouseBuff) < 2) then
      if HR.Cast(S.FlyingSerpentKick) then return "flying_serpent_kick 299"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- spear_hand_strike,if=target.debuff.casting.react
    if S.SpearHandStrike:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled and (Target:IsCasting()) then
      if HR.CastAnnotated(S.SpearHandStrike, false, "Interrupt") then return "spear_hand_strike 307"; end
    end
    -- touch_of_karma,interval=90,pct_health=0.5
    if S.TouchofKarma:IsCastableP() then
      if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return "touch_of_karma 309"; end
    end
    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.SerenityBuff) or Player:BuffP(S.StormEarthandFireBuff) or (not S.Serenity:IsAvailable() and bool(trinket.proc.agility.react)) or Player:HasHeroism() or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 311"; end
    end
    -- call_action_list,name=serenity,if=buff.serenity.up
    if (Player:BuffP(S.SerenityBuff)) then
      local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
    end
    -- fist_of_the_white_tiger,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=3
    if S.FistoftheWhiteTiger:IsCastableP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiMax() - Player:Chi() >= 3) then
      if HR.Cast(S.FistoftheWhiteTiger) then return "fist_of_the_white_tiger 323"; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2&!prev_gcd.1.tiger_palm
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm332, EvaluateTargetIfTigerPalm345) then return "tiger_palm 347" end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3
    if (Cache.EnemiesCount[8] < 3) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=aoe,if=active_enemies>=3
    if (Cache.EnemiesCount[8] >= 3) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(269, APL)
