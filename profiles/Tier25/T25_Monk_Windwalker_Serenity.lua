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
  TouchofDeath                          = Spell(115080),
  SerenityBuff                          = Spell(152173),
  Serenity                              = Spell(152173),
  ChiBurst                              = Spell(123986),
  FistoftheWhiteTiger                   = Spell(261947),
  ChiWave                               = Spell(115098),
  InvokeXuentheWhiteTiger               = Spell(123904),
  GuardianofAzeroth                     = Spell(),
  WhirlingDragonPunch                   = Spell(152175),
  EnergizingElixir                      = Spell(115288),
  TigerPalm                             = Spell(100780),
  FistsofFury                           = Spell(113656),
  RisingSunKick                         = Spell(107428),
  MarkoftheCraneDebuff                  = Spell(228287),
  RushingJadeWind                       = Spell(261715),
  RushingJadeWindBuff                   = Spell(261715),
  SpinningCraneKick                     = Spell(101546),
  DanceofChijiBuff                      = Spell(),
  ReverseHarm                           = Spell(),
  HitCombo                              = Spell(196741),
  FlyingSerpentKick                     = Spell(101545),
  BokProcBuff                           = Spell(116768),
  BlackoutKick                          = Spell(100784),
  WorldveinResonance                    = Spell(),
  ArcaneTorrent                         = Spell(50613),
  CyclotronicBlast                      = Spell(),
  StormEarthandFire                     = Spell(137639),
  TouchofDeathDebuff                    = Spell(),
  WorldveinResonanceBuff                = Spell(),
  BloodoftheEnemy                       = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  StormEarthandFireBuff                 = Spell(137639),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell(),
  RazorCoralDebuffDebuff                = Spell(),
  TheUnboundForce                       = Spell(),
  PurifyingBlast                        = Spell(),
  ReapingFlames                         = Spell(),
  FocusedAzeriteBeam                    = Spell(),
  MemoryofLucidDreams                   = Spell(),
  RippleInSpace                         = Spell(),
  SpearHandStrike                       = Spell(116705),
  TouchofKarma                          = Spell(122470),
  SeethingRageBuff                      = Spell()
};
local S = Spell.Monk.Windwalker;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Windwalker = {
  ProlongedPower                   = Item(142117),
  CyclotronicBlast                 = Item(),
  LustrousGoldenPlumage            = Item(159617),
  GladiatorsBadge                  = Item(),
  GladiatorsMedallion              = Item(),
  RemoteGuidanceDevice             = Item(),
  DribblingInkpod                  = Item(),
  AshvanesRazorCoral               = Item(),
  AzsharasFontofPower              = Item()
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
local VarTodOnUseTrinket = 0;
local VarHoldTod = 0;
local VarFontofPowerPrecombatChannel = 0;

HL:RegisterForEvent(function()
  VarTodOnUseTrinket = 0
  VarHoldTod = 0
  VarFontofPowerPrecombatChannel = 0
end, "PLAYER_REGEN_ENABLED")

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


local function EvaluateTargetIfFilterRisingSunKick79(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick94(TargetUnit)
  return (S.WhirlingDragonPunch:IsAvailable() and S.RisingSunKick:BaseDuration() > S.WhirlingDragonPunch:CooldownRemainsP() + 4) and (S.FistsofFury:CooldownRemainsP() > 3 or Player:Chi() >= 5)
end

local function EvaluateTargetIfFilterFistoftheWhiteTiger116(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFistoftheWhiteTiger123(TargetUnit)
  return Player:ChiMax() - Player:Chi() >= 3
end

local function EvaluateTargetIfFilterTigerPalm129(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm138(TargetUnit)
  return Player:ChiMax() - Player:Chi() >= 2 and (not S.HitCombo:IsAvailable() or not bool(combo_break))
end

local function EvaluateTargetIfFilterBlackoutKick150(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick163(TargetUnit)
  return bool(combo_strike) and (Player:BuffP(S.BokProcBuff) or (S.HitCombo:IsAvailable() and Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() < 4))
end

local function EvaluateTargetIfFilterRisingSunKick459(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick466(TargetUnit)
  return bool(combo_strike)
end

local function EvaluateTargetIfFilterFistoftheWhiteTiger474(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFistoftheWhiteTiger481(TargetUnit)
  return Player:Chi() < 3
end

local function EvaluateTargetIfFilterBlackoutKick489(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick498(TargetUnit)
  return bool(combo_strike) or not S.HitCombo:IsAvailable()
end

local function EvaluateTargetIfFilterRisingSunKick516(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfRisingSunKick527(TargetUnit)
  return S.TouchofDeath:CooldownRemainsP() > 2 or bool(VarHoldTod)
end

local function EvaluateTargetIfFilterFistoftheWhiteTiger547(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFistoftheWhiteTiger554(TargetUnit)
  return Player:Chi() < 3
end

local function EvaluateTargetIfFilterTigerPalm570(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm581(TargetUnit)
  return bool(combo_strike) and Player:ChiMax() - Player:Chi() > 3 and not bool(TargetUnit:DebuffRemainsP(S.TouchofDeathDebuff)) and Player:BuffDownP(S.StormEarthandFireBuff)
end

local function EvaluateTargetIfFilterBlackoutKick593(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick618(TargetUnit)
  return bool(combo_strike) and ((S.TouchofDeath:CooldownRemainsP() > 2 or bool(VarHoldTod)) and (S.RisingSunKick:CooldownRemainsP() > 2 and S.FistsofFury:CooldownRemainsP() > 2 or S.RisingSunKick:CooldownRemainsP() < 3 and S.FistsofFury:CooldownRemainsP() > 3 and Player:Chi() > 2 or S.RisingSunKick:CooldownRemainsP() > 3 and S.FistsofFury:CooldownRemainsP() < 3 and Player:Chi() > 4 or Player:Chi() > 5) or Player:BuffP(S.BokProcBuff))
end

local function EvaluateTargetIfFilterTigerPalm624(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm631(TargetUnit)
  return bool(combo_strike) and Player:ChiMax() - Player:Chi() > 1
end

local function EvaluateTargetIfFilterBlackoutKick639(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfBlackoutKick650(TargetUnit)
  return (S.FistsofFury:CooldownRemainsP() < 3 and Player:Chi() == 2 or Player:EnergyTimeToMaxPredicted() < 1) and (Player:PrevGCDP(1, S.TigerPalm) or Player:ChiMax() - Player:Chi() < 2)
end

local function EvaluateTargetIfFilterFistoftheWhiteTiger690(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfFistoftheWhiteTiger713(TargetUnit)
  return Player:ChiMax() - Player:Chi() >= 3 and Player:BuffDownP(S.SerenityBuff) and Player:BuffDownP(S.SeethingRageBuff) and (Player:EnergyTimeToMaxPredicted() < 1 or S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2 or not S.Serenity:IsAvailable() and S.TouchofDeath:CooldownRemainsP() < 3 and not bool(VarHoldTod) or Player:EnergyTimeToMaxPredicted() < 4 and S.FistsofFury:CooldownRemainsP() < 1.5)
end

local function EvaluateTargetIfFilterTigerPalm719(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.MarkoftheCraneDebuff)
end

local function EvaluateTargetIfTigerPalm752(TargetUnit)
  return not bool(combo_break) and Player:ChiMax() - Player:Chi() >= 2 and (S.Serenity:IsAvailable() or not bool(TargetUnit:DebuffRemainsP(S.TouchofDeathDebuff)) or Cache.EnemiesCount[8] > 2) and Player:BuffDownP(S.SeethingRageBuff) and Player:BuffDownP(S.SerenityBuff) and (Player:EnergyTimeToMaxPredicted() < 1 or S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2 or not S.Serenity:IsAvailable() and S.TouchofDeath:CooldownRemainsP() < 3 and not bool(VarHoldTod) or Player:EnergyTimeToMaxPredicted() < 4 and S.FistsofFury:CooldownRemainsP() < 1.5)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, CdSef, CdSerenity, Serenity, St
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
    -- variable,name=tod_on_use_trinket,op=set,value=equipped.cyclotronic_blast|equipped.lustrous_golden_plumage|equipped.gladiators_badge|equipped.gladiators_medallion|equipped.remote_guidance_device
    if (true) then
      VarTodOnUseTrinket = num(I.CyclotronicBlast:IsEquipped() or I.LustrousGoldenPlumage:IsEquipped() or I.GladiatorsBadge:IsEquipped() or I.GladiatorsMedallion:IsEquipped() or I.RemoteGuidanceDevice:IsEquipped())
    end
    -- variable,name=hold_tod,op=set,value=cooldown.touch_of_death.remains+9>target.time_to_die|!talent.serenity.enabled&!variable.tod_on_use_trinket&equipped.dribbling_inkpod&target.time_to_pct_30.remains<130&target.time_to_pct_30.remains>8|target.time_to_die<130&target.time_to_die>cooldown.serenity.remains&cooldown.serenity.remains>2|buff.serenity.up&target.time_to_die>11
    if (true) then
      VarHoldTod = num(S.TouchofDeath:CooldownRemainsP() + 9 > Target:TimeToDie() or not S.Serenity:IsAvailable() and not bool(VarTodOnUseTrinket) and I.DribblingInkpod:IsEquipped() and target.time_to_pct_30.remains < 130 and target.time_to_pct_30.remains > 8 or Target:TimeToDie() < 130 and Target:TimeToDie() > S.Serenity:CooldownRemainsP() and S.Serenity:CooldownRemainsP() > 2 or Player:BuffP(S.SerenityBuff) and Target:TimeToDie() > 11)
    end
    -- variable,name=font_of_power_precombat_channel,op=set,value=19,if=!talent.serenity.enabled&(variable.tod_on_use_trinket|equipped.ashvanes_razor_coral)
    if (not S.Serenity:IsAvailable() and (bool(VarTodOnUseTrinket) or I.AshvanesRazorCoral:IsEquipped())) then
      VarFontofPowerPrecombatChannel = 19
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 50"; end
    end
    -- chi_burst,if=!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled
    if S.ChiBurst:IsCastableP() and (not S.Serenity:IsAvailable() or not S.FistoftheWhiteTiger:IsAvailable()) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 52"; end
    end
    -- chi_wave,if=talent.fist_of_the_white_tiger.enabled|essence.conflict_and_strife.major
    if S.ChiWave:IsCastableP() and (S.FistoftheWhiteTiger:IsAvailable() or bool(essence.conflict_and_strife.major)) then
      if HR.Cast(S.ChiWave) then return "chi_wave 60"; end
    end
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return "invoke_xuen_the_white_tiger 64"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 66"; end
    end
  end
  Aoe = function()
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return "whirling_dragon_punch 68"; end
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return "energizing_elixir 70"; end
    end
    -- fists_of_fury,if=energy.time_to_max>1
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 74"; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.rising_sun_kick.duration>cooldown.whirling_dragon_punch.remains+4)&(cooldown.fists_of_fury.remains>3|chi>=5)
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick79, EvaluateTargetIfRisingSunKick94) then return "rising_sun_kick 96" end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 97"; end
    end
    -- spinning_crane_kick,if=combo_strike&(((chi>3|cooldown.fists_of_fury.remains>6)&(chi>=5|cooldown.fists_of_fury.remains>2))|energy.time_to_max<=3|buff.dance_of_chiji.react)
    if S.SpinningCraneKick:IsCastableP() and (bool(combo_strike) and (((Player:Chi() > 3 or S.FistsofFury:CooldownRemainsP() > 6) and (Player:Chi() >= 5 or S.FistsofFury:CooldownRemainsP() > 2)) or Player:EnergyTimeToMaxPredicted() <= 3 or bool(Player:BuffStackP(S.DanceofChijiBuff)))) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 101"; end
    end
    -- reverse_harm,if=chi.max-chi>=2
    if S.ReverseHarm:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 2) then
      if HR.Cast(S.ReverseHarm) then return "reverse_harm 109"; end
    end
    -- chi_burst,if=chi.max-chi>=3
    if S.ChiBurst:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 3) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 111"; end
    end
    -- fist_of_the_white_tiger,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=3
    if S.FistoftheWhiteTiger:IsCastableP() then
      if HR.CastTargetIf(S.FistoftheWhiteTiger, 8, "min", EvaluateTargetIfFilterFistoftheWhiteTiger116, EvaluateTargetIfFistoftheWhiteTiger123) then return "fist_of_the_white_tiger 125" end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=2&(!talent.hit_combo.enabled|!combo_break)
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm129, EvaluateTargetIfTigerPalm138) then return "tiger_palm 140" end
    end
    -- chi_wave,if=!combo_break
    if S.ChiWave:IsCastableP() and (not bool(combo_break)) then
      if HR.Cast(S.ChiWave) then return "chi_wave 141"; end
    end
    -- flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() and (Player:BuffDownP(S.BokProcBuff)) then
      if HR.Cast(S.FlyingSerpentKick) then return "flying_serpent_kick 143"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike&(buff.bok_proc.up|(talent.hit_combo.enabled&prev_gcd.1.tiger_palm&chi<4))
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick150, EvaluateTargetIfBlackoutKick163) then return "blackout_kick 165" end
    end
  end
  CdSef = function()
    -- invoke_xuen_the_white_tiger,if=buff.serenity.down|target.time_to_die<25
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.SerenityBuff) or Target:TimeToDie() < 25) then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return "invoke_xuen_the_white_tiger 166"; end
    end
    -- guardian_of_azeroth,if=target.time_to_die>185|!variable.hold_tod&cooldown.touch_of_death.remains<=14|target.time_to_die<35
    if S.GuardianofAzeroth:IsCastableP() and (Target:TimeToDie() > 185 or not bool(VarHoldTod) and S.TouchofDeath:CooldownRemainsP() <= 14 or Target:TimeToDie() < 35) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 170"; end
    end
    -- worldvein_resonance,if=cooldown.touch_of_death.remains>58|cooldown.touch_of_death.remains<2|variable.hold_tod|target.time_to_die<20
    if S.WorldveinResonance:IsCastableP() and (S.TouchofDeath:CooldownRemainsP() > 58 or S.TouchofDeath:CooldownRemainsP() < 2 or bool(VarHoldTod) or Target:TimeToDie() < 20) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 176"; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 184"; end
    end
    -- touch_of_death,if=!variable.hold_tod&(!equipped.cyclotronic_blast|cooldown.cyclotronic_blast.remains<=1)&(chi>1|energy<40)
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (not bool(VarHoldTod) and (not I.CyclotronicBlast:IsEquipped() or S.CyclotronicBlast:CooldownRemainsP() <= 1) and (Player:Chi() > 1 or Player:EnergyPredicted() < 40)) then
      if HR.Cast(S.TouchofDeath) then return "touch_of_death 186"; end
    end
    -- storm_earth_and_fire,,if=cooldown.storm_earth_and_fire.charges=2|dot.touch_of_death.remains|target.time_to_die<20|(buff.worldvein_resonance.remains>10|cooldown.worldvein_resonance.remains>cooldown.storm_earth_and_fire.full_recharge_time|!essence.worldvein_resonance.major)&(cooldown.touch_of_death.remains>cooldown.storm_earth_and_fire.full_recharge_time|variable.hold_tod&!equipped.dribbling_inkpod)&cooldown.fists_of_fury.remains<=9&chi>=3&cooldown.whirling_dragon_punch.remains<=13
    if S.StormEarthandFire:IsCastableP() and HR.CDsON() and (S.StormEarthandFire:ChargesP() == 2 or bool(Target:DebuffRemainsP(S.TouchofDeathDebuff)) or Target:TimeToDie() < 20 or (Player:BuffRemainsP(S.WorldveinResonanceBuff) > 10 or S.WorldveinResonance:CooldownRemainsP() > S.StormEarthandFire:FullRechargeTimeP() or not bool(essence.worldvein_resonance.major)) and (S.TouchofDeath:CooldownRemainsP() > S.StormEarthandFire:FullRechargeTimeP() or bool(VarHoldTod) and not I.DribblingInkpod:IsEquipped()) and S.FistsofFury:CooldownRemainsP() <= 9 and Player:Chi() >= 3 and S.WhirlingDragonPunch:CooldownRemainsP() <= 13) then
      if HR.Cast(S.StormEarthandFire, Settings.Windwalker.OffGCDasOffGCD.StormEarthandFire) then return "storm_earth_and_fire 194"; end
    end
    -- blood_of_the_enemy,if=cooldown.touch_of_death.remains>45|variable.hold_tod&cooldown.fists_of_fury.remains<2|target.time_to_die<12|target.time_to_die>100&target.time_to_die<110&(cooldown.fists_of_fury.remains<3|cooldown.whirling_dragon_punch.remains<5|cooldown.rising_sun_kick.remains<5)
    if S.BloodoftheEnemy:IsCastableP() and (S.TouchofDeath:CooldownRemainsP() > 45 or bool(VarHoldTod) and S.FistsofFury:CooldownRemainsP() < 2 or Target:TimeToDie() < 12 or Target:TimeToDie() > 100 and Target:TimeToDie() < 110 and (S.FistsofFury:CooldownRemainsP() < 3 or S.WhirlingDragonPunch:CooldownRemainsP() < 5 or S.RisingSunKick:CooldownRemainsP() < 5)) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 218"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&((cooldown.concentrated_flame.remains<=cooldown.touch_of_death.remains+1|variable.hold_tod)&(!talent.whirling_dragon_punch.enabled|cooldown.whirling_dragon_punch.remains)&cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains&buff.storm_earth_and_fire.down|dot.touch_of_death.remains)|target.time_to_die<8
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and ((S.ConcentratedFlame:CooldownRemainsP() <= S.TouchofDeath:CooldownRemainsP() + 1 or bool(VarHoldTod)) and (not S.WhirlingDragonPunch:IsAvailable() or bool(S.WhirlingDragonPunch:CooldownRemainsP())) and bool(S.RisingSunKick:CooldownRemainsP()) and bool(S.FistsofFury:CooldownRemainsP()) and Player:BuffDownP(S.StormEarthandFireBuff) or bool(Target:DebuffRemainsP(S.TouchofDeathDebuff))) or Target:TimeToDie() < 8) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 232"; end
    end
    -- blood_fury,if=cooldown.touch_of_death.remains>30|variable.hold_tod|target.time_to_die<20
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.TouchofDeath:CooldownRemainsP() > 30 or bool(VarHoldTod) or Target:TimeToDie() < 20) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 254"; end
    end
    -- berserking,if=cooldown.touch_of_death.remains>30|variable.hold_tod|target.time_to_die<15
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.TouchofDeath:CooldownRemainsP() > 30 or bool(VarHoldTod) or Target:TimeToDie() < 15) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 260"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 266"; end
    end
    -- fireblood,if=cooldown.touch_of_death.remains>30|variable.hold_tod|target.time_to_die<10
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.TouchofDeath:CooldownRemainsP() > 30 or bool(VarHoldTod) or Target:TimeToDie() < 10) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 268"; end
    end
    -- ancestral_call,if=cooldown.touch_of_death.remains>30|variable.hold_tod|target.time_to_die<20
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.TouchofDeath:CooldownRemainsP() > 30 or bool(VarHoldTod) or Target:TimeToDie() < 20) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 274"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 280"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=variable.tod_on_use_trinket&(cooldown.touch_of_death.remains>21|variable.hold_tod)&(debuff.razor_coral_debuff.down|buff.storm_earth_and_fire.remains>13|target.time_to_die-cooldown.touch_of_death.remains<40&cooldown.touch_of_death.remains<25|target.time_to_die<25)
    if I.AshvanesRazorCoral:IsReady() and (bool(VarTodOnUseTrinket) and (S.TouchofDeath:CooldownRemainsP() > 21 or bool(VarHoldTod)) and (Target:DebuffDownP(S.RazorCoralDebuffDebuff) or Player:BuffRemainsP(S.StormEarthandFireBuff) > 13 or Target:TimeToDie() - S.TouchofDeath:CooldownRemainsP() < 40 and S.TouchofDeath:CooldownRemainsP() < 25 or Target:TimeToDie() < 25)) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 282"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=!variable.tod_on_use_trinket&(debuff.razor_coral_debuff.down|(!equipped.dribbling_inkpod|target.time_to_pct_30.remains<8)&(dot.touch_of_death.remains|cooldown.touch_of_death.remains+9>target.time_to_die)&buff.storm_earth_and_fire.up|target.time_to_die<25)
    if I.AshvanesRazorCoral:IsReady() and (not bool(VarTodOnUseTrinket) and (Target:DebuffDownP(S.RazorCoralDebuffDebuff) or (not I.DribblingInkpod:IsEquipped() or target.time_to_pct_30.remains < 8) and (bool(Target:DebuffRemainsP(S.TouchofDeathDebuff)) or S.TouchofDeath:CooldownRemainsP() + 9 > Target:TimeToDie()) and Player:BuffP(S.StormEarthandFireBuff) or Target:TimeToDie() < 25)) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 298"; end
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsCastableP() then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 312"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 314"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 316"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 318"; end
    end
    -- memory_of_lucid_dreams,if=energy<40
    if S.MemoryofLucidDreams:IsCastableP() and (Player:EnergyPredicted() < 40) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 320"; end
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 322"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 324"; end
    end
  end
  CdSerenity = function()
    -- invoke_xuen_the_white_tiger,if=buff.serenity.down|target.time_to_die<25
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.SerenityBuff) or Target:TimeToDie() < 25) then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return "invoke_xuen_the_white_tiger 326"; end
    end
    -- guardian_of_azeroth,if=buff.serenity.down&(target.time_to_die>185|cooldown.serenity.remains<=7)|target.time_to_die<35
    if S.GuardianofAzeroth:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and (Target:TimeToDie() > 185 or S.Serenity:CooldownRemainsP() <= 7) or Target:TimeToDie() < 35) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 330"; end
    end
    -- blood_fury,if=cooldown.serenity.remains>20|target.time_to_die<20
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.Serenity:CooldownRemainsP() > 20 or Target:TimeToDie() < 20) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 336"; end
    end
    -- berserking,if=cooldown.serenity.remains>20|target.time_to_die<15
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.Serenity:CooldownRemainsP() > 20 or Target:TimeToDie() < 15) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 340"; end
    end
    -- arcane_torrent,if=buff.serenity.down&chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.SerenityBuff) and Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 344"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 348"; end
    end
    -- fireblood,if=cooldown.serenity.remains>20|target.time_to_die<10
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.Serenity:CooldownRemainsP() > 20 or Target:TimeToDie() < 10) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 350"; end
    end
    -- ancestral_call,if=cooldown.serenity.remains>20|target.time_to_die<20
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.Serenity:CooldownRemainsP() > 20 or Target:TimeToDie() < 20) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 354"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 358"; end
    end
    -- touch_of_death,if=!variable.hold_tod
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (not bool(VarHoldTod)) then
      if HR.Cast(S.TouchofDeath) then return "touch_of_death 360"; end
    end
    -- blood_of_the_enemy,if=buff.serenity.down&(cooldown.serenity.remains>20|cooldown.serenity.remains<2)|target.time_to_die<15
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and (S.Serenity:CooldownRemainsP() > 20 or S.Serenity:CooldownRemainsP() < 2) or Target:TimeToDie() < 15) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 364"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|buff.serenity.remains>9|target.time_to_die<25
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuffDebuff) or Player:BuffRemainsP(S.SerenityBuff) > 9 or Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 372"; end
    end
    -- worldvein_resonance,if=buff.serenity.down&(cooldown.serenity.remains>15|cooldown.serenity.remains<2)|target.time_to_die<20
    if S.WorldveinResonance:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and (S.Serenity:CooldownRemainsP() > 15 or S.Serenity:CooldownRemainsP() < 2) or Target:TimeToDie() < 20) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 378"; end
    end
    -- concentrated_flame,if=buff.serenity.down&(cooldown.serenity.remains|cooldown.concentrated_flame.charges=2)&!dot.concentrated_flame_burn.remains&(cooldown.rising_sun_kick.remains&cooldown.fists_of_fury.remains|target.time_to_die<8)
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and (bool(S.Serenity:CooldownRemainsP()) or S.ConcentratedFlame:ChargesP() == 2) and not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and (bool(S.RisingSunKick:CooldownRemainsP()) and bool(S.FistsofFury:CooldownRemainsP()) or Target:TimeToDie() < 8)) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 386"; end
    end
    -- serenity
    if S.Serenity:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Serenity, Settings.Windwalker.OffGCDasOffGCD.Serenity) then return "serenity 400"; end
    end
    -- the_unbound_force,if=buff.serenity.down
    if S.TheUnboundForce:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 402"; end
    end
    -- purifying_blast,if=buff.serenity.down
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 406"; end
    end
    -- reaping_flames,if=buff.serenity.down
    if S.ReapingFlames:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 410"; end
    end
    -- focused_azerite_beam,if=buff.serenity.down
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 414"; end
    end
    -- memory_of_lucid_dreams,if=buff.serenity.down&energy<40
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffDownP(S.SerenityBuff) and Player:EnergyPredicted() < 40) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 418"; end
    end
    -- ripple_in_space,if=buff.serenity.down
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 422"; end
    end
    -- bag_of_tricks,if=buff.serenity.down
    if S.BagofTricks:IsCastableP() and (Player:BuffDownP(S.SerenityBuff)) then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 426"; end
    end
  end
  Serenity = function()
    -- fists_of_fury,if=buff.serenity.remains<1|active_enemies>1
    if S.FistsofFury:IsCastableP() and (Player:BuffRemainsP(S.SerenityBuff) < 1 or Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 430"; end
    end
    -- spinning_crane_kick,if=combo_strike&(active_enemies>2|active_enemies>1&!cooldown.rising_sun_kick.up)
    if S.SpinningCraneKick:IsCastableP() and (bool(combo_strike) and (Cache.EnemiesCount[8] > 2 or Cache.EnemiesCount[8] > 1 and not S.RisingSunKick:CooldownUpP())) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 440"; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick459, EvaluateTargetIfRisingSunKick466) then return "rising_sun_kick 468" end
    end
    -- fists_of_fury,interrupt_if=gcd.remains=0
    if S.FistsofFury:IsCastableP() then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 469"; end
    end
    -- fist_of_the_white_tiger,target_if=min:debuff.mark_of_the_crane.remains,if=chi<3
    if S.FistoftheWhiteTiger:IsCastableP() then
      if HR.CastTargetIf(S.FistoftheWhiteTiger, 8, "min", EvaluateTargetIfFilterFistoftheWhiteTiger474, EvaluateTargetIfFistoftheWhiteTiger481) then return "fist_of_the_white_tiger 483" end
    end
    -- reverse_harm,if=chi.max-chi>1&energy.time_to_max<1
    if S.ReverseHarm:IsCastableP() and (Player:ChiMax() - Player:Chi() > 1 and Player:EnergyTimeToMaxPredicted() < 1) then
      if HR.Cast(S.ReverseHarm) then return "reverse_harm 484"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike|!talent.hit_combo.enabled
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick489, EvaluateTargetIfBlackoutKick498) then return "blackout_kick 500" end
    end
    -- spinning_crane_kick
    if S.SpinningCraneKick:IsCastableP() then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 501"; end
    end
  end
  St = function()
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return "whirling_dragon_punch 503"; end
    end
    -- fists_of_fury,if=talent.serenity.enabled|cooldown.touch_of_death.remains>6|variable.hold_tod
    if S.FistsofFury:IsCastableP() and (S.Serenity:IsAvailable() or S.TouchofDeath:CooldownRemainsP() > 6 or bool(VarHoldTod)) then
      if HR.Cast(S.FistsofFury) then return "fists_of_fury 505"; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=cooldown.touch_of_death.remains>2|variable.hold_tod
    if S.RisingSunKick:IsCastableP() then
      if HR.CastTargetIf(S.RisingSunKick, 8, "min", EvaluateTargetIfFilterRisingSunKick516, EvaluateTargetIfRisingSunKick527) then return "rising_sun_kick 529" end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&active_enemies>1
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff) and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 530"; end
    end
    -- reverse_harm,if=chi.max-chi>1
    if S.ReverseHarm:IsCastableP() and (Player:ChiMax() - Player:Chi() > 1) then
      if HR.Cast(S.ReverseHarm) then return "reverse_harm 542"; end
    end
    -- fist_of_the_white_tiger,target_if=min:debuff.mark_of_the_crane.remains,if=chi<3
    if S.FistoftheWhiteTiger:IsCastableP() then
      if HR.CastTargetIf(S.FistoftheWhiteTiger, 8, "min", EvaluateTargetIfFilterFistoftheWhiteTiger547, EvaluateTargetIfFistoftheWhiteTiger554) then return "fist_of_the_white_tiger 556" end
    end
    -- energizing_elixir,if=chi<=3&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (Player:Chi() <= 3 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return "energizing_elixir 557"; end
    end
    -- chi_burst,if=chi.max-chi>0&active_enemies=1|chi.max-chi>1
    if S.ChiBurst:IsCastableP() and (Player:ChiMax() - Player:Chi() > 0 and Cache.EnemiesCount[8] == 1 or Player:ChiMax() - Player:Chi() > 1) then
      if HR.Cast(S.ChiBurst) then return "chi_burst 559"; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike&chi.max-chi>3&!dot.touch_of_death.remains&buff.storm_earth_and_fire.down
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm570, EvaluateTargetIfTigerPalm581) then return "tiger_palm 583" end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 584"; end
    end
    -- spinning_crane_kick,if=combo_strike&buff.dance_of_chiji.react
    if S.SpinningCraneKick:IsCastableP() and (bool(combo_strike) and bool(Player:BuffStackP(S.DanceofChijiBuff))) then
      if HR.Cast(S.SpinningCraneKick) then return "spinning_crane_kick 586"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike&((cooldown.touch_of_death.remains>2|variable.hold_tod)&(cooldown.rising_sun_kick.remains>2&cooldown.fists_of_fury.remains>2|cooldown.rising_sun_kick.remains<3&cooldown.fists_of_fury.remains>3&chi>2|cooldown.rising_sun_kick.remains>3&cooldown.fists_of_fury.remains<3&chi>4|chi>5)|buff.bok_proc.up)
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick593, EvaluateTargetIfBlackoutKick618) then return "blackout_kick 620" end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=combo_strike&chi.max-chi>1
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm624, EvaluateTargetIfTigerPalm631) then return "tiger_palm 633" end
    end
    -- flying_serpent_kick,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() then
      if HR.Cast(S.FlyingSerpentKick) then return "flying_serpent_kick 634"; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(cooldown.fists_of_fury.remains<3&chi=2|energy.time_to_max<1)&(prev_gcd.1.tiger_palm|chi.max-chi<2)
    if S.BlackoutKick:IsCastableP() then
      if HR.CastTargetIf(S.BlackoutKick, 8, "min", EvaluateTargetIfFilterBlackoutKick639, EvaluateTargetIfBlackoutKick650) then return "blackout_kick 652" end
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
      if HR.CastAnnotated(S.SpearHandStrike, false, "Interrupt") then return "spear_hand_strike 655"; end
    end
    -- touch_of_karma,interval=90,pct_health=0.5
    if S.TouchofKarma:IsCastableP() then
      if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return "touch_of_karma 657"; end
    end
    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up&dot.touch_of_death.remains|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.SerenityBuff) or Player:BuffP(S.StormEarthandFireBuff) and bool(Target:DebuffRemainsP(S.TouchofDeathDebuff)) or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 659"; end
    end
    -- reverse_harm,if=chi.max-chi>=2&(talent.serenity.enabled|!dot.touch_of_death.remains)&buff.serenity.down&(energy.time_to_max<1|talent.serenity.enabled&cooldown.serenity.remains<2|!talent.serenity.enabled&cooldown.touch_of_death.remains<3&!variable.hold_tod|energy.time_to_max<4&cooldown.fists_of_fury.remains<1.5)
    if S.ReverseHarm:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 2 and (S.Serenity:IsAvailable() or not bool(Target:DebuffRemainsP(S.TouchofDeathDebuff))) and Player:BuffDownP(S.SerenityBuff) and (Player:EnergyTimeToMaxPredicted() < 1 or S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2 or not S.Serenity:IsAvailable() and S.TouchofDeath:CooldownRemainsP() < 3 and not bool(VarHoldTod) or Player:EnergyTimeToMaxPredicted() < 4 and S.FistsofFury:CooldownRemainsP() < 1.5)) then
      if HR.Cast(S.ReverseHarm) then return "reverse_harm 667"; end
    end
    -- fist_of_the_white_tiger,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=3&buff.serenity.down&buff.seething_rage.down&(energy.time_to_max<1|talent.serenity.enabled&cooldown.serenity.remains<2|!talent.serenity.enabled&cooldown.touch_of_death.remains<3&!variable.hold_tod|energy.time_to_max<4&cooldown.fists_of_fury.remains<1.5)
    if S.FistoftheWhiteTiger:IsCastableP() then
      if HR.CastTargetIf(S.FistoftheWhiteTiger, 8, "min", EvaluateTargetIfFilterFistoftheWhiteTiger690, EvaluateTargetIfFistoftheWhiteTiger713) then return "fist_of_the_white_tiger 715" end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!combo_break&chi.max-chi>=2&(talent.serenity.enabled|!dot.touch_of_death.remains|active_enemies>2)&buff.seething_rage.down&buff.serenity.down&(energy.time_to_max<1|talent.serenity.enabled&cooldown.serenity.remains<2|!talent.serenity.enabled&cooldown.touch_of_death.remains<3&!variable.hold_tod|energy.time_to_max<4&cooldown.fists_of_fury.remains<1.5)
    if S.TigerPalm:IsCastableP() then
      if HR.CastTargetIf(S.TigerPalm, 8, "min", EvaluateTargetIfFilterTigerPalm719, EvaluateTargetIfTigerPalm752) then return "tiger_palm 754" end
    end
    -- chi_wave,if=!talent.fist_of_the_white_tiger.enabled&prev_gcd.1.tiger_palm&time<=3
    if S.ChiWave:IsCastableP() and (not S.FistoftheWhiteTiger:IsAvailable() and Player:PrevGCDP(1, S.TigerPalm) and HL.CombatTime() <= 3) then
      if HR.Cast(S.ChiWave) then return "chi_wave 755"; end
    end
    -- call_action_list,name=cd_serenity,if=talent.serenity.enabled
    if (S.Serenity:IsAvailable()) then
      local ShouldReturn = CdSerenity(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cd_sef,if=!talent.serenity.enabled
    if (not S.Serenity:IsAvailable()) then
      local ShouldReturn = CdSef(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=serenity,if=buff.serenity.up
    if (Player:BuffP(S.SerenityBuff)) then
      local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
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
