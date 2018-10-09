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
if not Spell.Rogue then Spell.Rogue = {} end
Spell.Rogue.Subtlety = {
  StealthBuff                           = Spell(1784),
  Stealth                               = Spell(1784),
  MarkedForDeath                        = Spell(137619),
  ShadowBladesBuff                      = Spell(121471),
  ShadowBlades                          = Spell(121471),
  ShurikenToss                          = Spell(),
  Nightstalker                          = Spell(14062),
  DarkShadow                            = Spell(245687),
  SymbolsofDeath                        = Spell(212283),
  SharpenedBladesBuff                   = Spell(),
  SharpenedBlades                       = Spell(),
  ShurikenStorm                         = Spell(197835),
  TheDreadlordsDeceitBuff               = Spell(208692),
  Gloomblade                            = Spell(200758),
  Backstab                              = Spell(53),
  SymbolsofDeathBuff                    = Spell(212283),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  NightbladeDebuff                      = Spell(195452),
  ShurikenTornado                       = Spell(),
  ShadowDanceBuff                       = Spell(185313),
  ShadowDance                           = Spell(185313),
  Subterfuge                            = Spell(108208),
  Eviscerate                            = Spell(196819),
  ShadowFocus                           = Spell(108209),
  NightsVengeanceBuff                   = Spell(),
  SecretTechnique                       = Spell(),
  Nightblade                            = Spell(195452),
  NightsVengeance                       = Spell(),
  Vanish                                = Spell(1856),
  FindWeaknessDebuff                    = Spell(),
  Shadowmeld                            = Spell(58984),
  PoolResource                          = Spell(9999000010),
  Shadowstrike                          = Spell(185438),
  DeeperStratagem                       = Spell(193531),
  VanishBuff                            = Spell(1856),
  FindWeakness                          = Spell(),
  BladeIntheShadows                     = Spell(),
  Vigor                                 = Spell(14983),
  MasterofShadows                       = Spell(),
  Alacrity                              = Spell(),
  ArcaneTorrent                         = Spell(50613),
  ArcanePulse                           = Spell(),
  LightsJudgment                        = Spell(255647)
};
local S = Spell.Rogue.Subtlety;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Subtlety = {
  ProlongedPower                   = Item(142117),
  GalecallersBoon                  = Item()
};
local I = Item.Rogue.Subtlety;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Rogue.Commons,
  Subtlety = HR.GUISettings.APL.Rogue.Subtlety
};

-- Variables
local VarShdThreshold = 0;
local VarStealthThreshold = 0;

local EnemyRanges = {15, 10}
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
  local Precombat, Build, Cds, Finish, StealthCds, Stealthed
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- stealth
    if S.Stealth:IsCastableP() and Player:BuffDownP(S.StealthBuff) then
      if HR.Cast(S.Stealth) then return "stealth 4"; end
    end
    -- marked_for_death,precombat_seconds=15
    if S.MarkedForDeath:IsCastableP() then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 8"; end
    end
    -- shadow_blades,precombat_seconds=1
    if S.ShadowBlades:IsCastableP() and Player:BuffDownP(S.ShadowBladesBuff) then
      if HR.Cast(S.ShadowBlades) then return "shadow_blades 10"; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 14"; end
    end
  end
  Build = function()
    -- shuriken_toss,if=!talent.nightstalker.enabled&(!talent.dark_shadow.enabled|cooldown.symbols_of_death.remains>10)&buff.sharpened_blades.stack>=29&spell_targets.shuriken_storm<=(3*azerite.sharpened_blades.rank)
    if S.ShurikenToss:IsCastableP() and (not S.Nightstalker:IsAvailable() and (not S.DarkShadow:IsAvailable() or S.SymbolsofDeath:CooldownRemainsP() > 10) and Player:BuffStackP(S.SharpenedBladesBuff) >= 29 and Cache.EnemiesCount[10] <= (3 * S.SharpenedBlades:AzeriteRank())) then
      if HR.Cast(S.ShurikenToss) then return "shuriken_toss 16"; end
    end
    -- shuriken_storm,if=spell_targets>=2|buff.the_dreadlords_deceit.stack>=29
    if S.ShurikenStorm:IsCastableP() and (Cache.EnemiesCount[10] >= 2 or Player:BuffStackP(S.TheDreadlordsDeceitBuff) >= 29) then
      if HR.Cast(S.ShurikenStorm) then return "shuriken_storm 28"; end
    end
    -- gloomblade
    if S.Gloomblade:IsCastableP() then
      if HR.Cast(S.Gloomblade) then return "gloomblade 38"; end
    end
    -- backstab
    if S.Backstab:IsCastableP() then
      if HR.Cast(S.Backstab) then return "backstab 40"; end
    end
  end
  Cds = function()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.symbols_of_death.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=10)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or Player:BuffP(S.SymbolsofDeathBuff) and (Player:BuffP(S.ShadowBladesBuff) or S.ShadowBlades:CooldownRemainsP() <= 10)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 42"; end
    end
    -- use_item,name=galecallers_boon,if=buff.symbols_of_death.up|target.time_to_die<20
    if I.GalecallersBoon:IsReady() and (Player:BuffP(S.SymbolsofDeathBuff) or Target:TimeToDie() < 20) then
      if HR.CastSuggested(I.GalecallersBoon) then return "galecallers_boon 50"; end
    end
    -- blood_fury,if=buff.symbols_of_death.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SymbolsofDeathBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 54"; end
    end
    -- berserking,if=buff.symbols_of_death.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SymbolsofDeathBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 58"; end
    end
    -- fireblood,if=buff.symbols_of_death.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SymbolsofDeathBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 62"; end
    end
    -- ancestral_call,if=buff.symbols_of_death.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SymbolsofDeathBuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 66"; end
    end
    -- symbols_of_death,if=dot.nightblade.ticking
    if S.SymbolsofDeath:IsCastableP() and (Target:DebuffP(S.NightbladeDebuff)) then
      if HR.Cast(S.SymbolsofDeath) then return "symbols_of_death 70"; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit|!stealthed.all&combo_points.deficit>=cp_max_spend)
    if S.MarkedForDeath:IsCastableP() then
      if HR.CastTargetIf(S.MarkedForDeath, 15, "min", function(TargetUnit) return Target:TimeToDie() end, function(TargetUnit) return (Cache.EnemiesCount[15] > 1) and (TargetUnit:TimeToDie() < Player:ComboPointsDeficit() or not bool(stealthed.all) and Player:ComboPointsDeficit() >= cp_max_spend) end) then return "marked_for_death 80" end
    end
    -- marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&!stealthed.all&combo_points.deficit>=cp_max_spend
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 30 - raid_event.adds.duration and not bool(stealthed.all) and Player:ComboPointsDeficit() >= cp_max_spend) then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 81"; end
    end
    -- shadow_blades,if=combo_points.deficit>=2+stealthed.all
    if S.ShadowBlades:IsCastableP() and (Player:ComboPointsDeficit() >= 2 + stealthed.all) then
      if HR.Cast(S.ShadowBlades) then return "shadow_blades 83"; end
    end
    -- shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
    if S.ShurikenTornado:IsCastableP() and (Cache.EnemiesCount[15] >= 3 and TargetUnit:DebuffP(S.NightbladeDebuff) and Player:BuffP(S.SymbolsofDeathBuff) and Player:BuffP(S.ShadowDanceBuff)) then
      if HR.Cast(S.ShurikenTornado) then return "shuriken_tornado 85"; end
    end
    -- shadow_dance,if=!stealthed.all&target.time_to_die<=5+talent.subterfuge.enabled
    if S.ShadowDance:IsCastableP() and (not bool(stealthed.all) and TargetUnit:TimeToDie() <= 5 + num(S.Subterfuge:IsAvailable())) then
      if HR.Cast(S.ShadowDance) then return "shadow_dance 99"; end
    end
  end
  Finish = function()
    -- eviscerate,if=talent.shadow_focus.enabled&buff.nights_vengeance.up&spell_targets.shuriken_storm>=2+3*talent.secret_technique.enabled
    if S.Eviscerate:IsCastableP() and (S.ShadowFocus:IsAvailable() and Player:BuffP(S.NightsVengeanceBuff) and Cache.EnemiesCount[10] >= 2 + 3 * num(S.SecretTechnique:IsAvailable())) then
      if HR.Cast(S.Eviscerate) then return "eviscerate 103"; end
    end
    -- nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
    if S.Nightblade:IsCastableP() and ((not S.DarkShadow:IsAvailable() or not Player:BuffP(S.ShadowDanceBuff)) and TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.NightbladeDebuff) > 6 and TargetUnit:DebuffRemainsP(S.NightbladeDebuff) < S.NightbladeDebuff:TickTime() * 2 and (Cache.EnemiesCount[10] < 4 or not Player:BuffP(S.SymbolsofDeathBuff))) then
      if HR.Cast(S.Nightblade) then return "nightblade 111"; end
    end
    -- nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&(talent.secret_technique.enabled|azerite.nights_vengeance.enabled|spell_targets.shuriken_storm<=5)&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
    if S.Nightblade:IsCastableP() then
      if HR.CastCycle(S.Nightblade, 15, function(TargetUnit) return Cache.EnemiesCount[10] >= 2 and (S.SecretTechnique:IsAvailable() or S.NightsVengeance:AzeriteEnabled() or Cache.EnemiesCount[10] <= 5) and not Player:BuffP(S.ShadowDanceBuff) and TargetUnit:TimeToDie() >= (5 + (2 * Player:ComboPoints())) and TargetUnit:DebuffRefreshableCP(S.NightbladeDebuff) end) then return "nightblade 153" end
    end
    -- nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if S.Nightblade:IsCastableP() and (TargetUnit:DebuffRemainsP(S.NightbladeDebuff) < S.SymbolsofDeath:CooldownRemainsP() + 10 and S.SymbolsofDeath:CooldownRemainsP() <= 5 and TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.NightbladeDebuff) > S.SymbolsofDeath:CooldownRemainsP() + 5) then
      if HR.Cast(S.Nightblade) then return "nightblade 154"; end
    end
    -- secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|buff.shadow_dance.up)
    if S.SecretTechnique:IsCastableP() and (Player:BuffP(S.SymbolsofDeathBuff) and (not S.DarkShadow:IsAvailable() or Player:BuffP(S.ShadowDanceBuff))) then
      if HR.Cast(S.SecretTechnique) then return "secret_technique 174"; end
    end
    -- secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
    if S.SecretTechnique:IsCastableP() and (Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable())) then
      if HR.Cast(S.SecretTechnique) then return "secret_technique 182"; end
    end
    -- eviscerate
    if S.Eviscerate:IsCastableP() then
      if HR.Cast(S.Eviscerate) then return "eviscerate 188"; end
    end
  end
  StealthCds = function()
    -- variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
    if (true) then
      VarShdThreshold = num(S.ShadowDance:ChargesFractionalP() >= 1.75)
    end
    -- vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1&combo_points.deficit>1
    if S.Vanish:IsCastableP() and (not bool(VarShdThreshold) and TargetUnit:DebuffRemainsP(S.FindWeaknessDebuff) < 1 and Player:ComboPointsDeficit() > 1) then
      if HR.Cast(S.Vanish) then return "vanish 194"; end
    end
    -- pool_resource,for_next=1,extra_amount=40
    -- shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1&combo_points.deficit>1
    if S.Shadowmeld:IsCastableP() and HR.CDsON() and (Player:EnergyPredicted() >= 40 and Player:EnergyDeficitPredicted() >= 10 and not bool(VarShdThreshold) and TargetUnit:DebuffRemainsP(S.FindWeaknessDebuff) < 1 and Player:ComboPointsDeficit() > 1) then
      if S.Shadowmeld:IsUsablePPool(40) then
        if HR.Cast(S.Shadowmeld, Settings.Commons.OffGCDasOffGCD.Racials) then return "shadowmeld 201"; end
      else
        if HR.Cast(S.PoolResource) then return "pool_resource 202"; end
      end
    end
    -- shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets.shuriken_storm>=4&cooldown.symbols_of_death.remains>10)
    if S.ShadowDance:IsCastableP() and ((not S.DarkShadow:IsAvailable() or TargetUnit:DebuffRemainsP(S.NightbladeDebuff) >= 5 + num(S.Subterfuge:IsAvailable())) and (bool(VarShdThreshold) or Player:BuffRemainsP(S.SymbolsofDeathBuff) >= 1.2 or Cache.EnemiesCount[10] >= 4 and S.SymbolsofDeath:CooldownRemainsP() > 10)) then
      if HR.Cast(S.ShadowDance) then return "shadow_dance 208"; end
    end
    -- shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
    if S.ShadowDance:IsCastableP() and (TargetUnit:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP()) then
      if HR.Cast(S.ShadowDance) then return "shadow_dance 222"; end
    end
  end
  Stealthed = function()
    -- shadowstrike,if=buff.stealth.up
    if S.Shadowstrike:IsCastableP() and (Player:BuffP(S.StealthBuff)) then
      if HR.Cast(S.Shadowstrike) then return "shadowstrike 226"; end
    end
    -- call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
    if (Player:ComboPointsDeficit() <= 1 - num((S.DeeperStratagem:IsAvailable() and Player:BuffP(S.VanishBuff)))) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- shuriken_toss,if=buff.sharpened_blades.stack>=29&(!talent.find_weakness.enabled|debuff.find_weakness.up)
    if S.ShurikenToss:IsCastableP() and (Player:BuffStackP(S.SharpenedBladesBuff) >= 29 and (not S.FindWeakness:IsAvailable() or TargetUnit:DebuffP(S.FindWeaknessDebuff))) then
      if HR.Cast(S.ShurikenToss) then return "shuriken_toss 236"; end
    end
    -- shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
    if S.Shadowstrike:IsCastableP() then
      if HR.CastCycle(S.Shadowstrike, 15, function(TargetUnit) return S.SecretTechnique:IsAvailable() and S.FindWeakness:IsAvailable() and TargetUnit:DebuffRemainsP(S.FindWeaknessDebuff) < 1 and Cache.EnemiesCount[10] == 2 and TargetUnit:TimeToDie() - remains > 6 end) then return "shadowstrike 258" end
    end
    -- shadowstrike,if=!talent.deeper_stratagem.enabled&azerite.blade_in_the_shadows.rank=3&spell_targets.shuriken_storm=3
    if S.Shadowstrike:IsCastableP() and (not S.DeeperStratagem:IsAvailable() and S.BladeIntheShadows:AzeriteRank() == 3 and Cache.EnemiesCount[10] == 3) then
      if HR.Cast(S.Shadowstrike) then return "shadowstrike 259"; end
    end
    -- shuriken_storm,if=spell_targets>=3
    if S.ShurikenStorm:IsCastableP() and (Cache.EnemiesCount[10] >= 3) then
      if HR.Cast(S.ShurikenStorm) then return "shuriken_storm 265"; end
    end
    -- shadowstrike
    if S.Shadowstrike:IsCastableP() then
      if HR.Cast(S.Shadowstrike) then return "shadowstrike 273"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- stealth
    if S.Stealth:IsCastableP() then
      if HR.Cast(S.Stealth) then return "stealth 276"; end
    end
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=stealthed,if=stealthed.all
    if (bool(stealthed.all)) then
      return Stealthed();
    end
    -- nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
    if S.Nightblade:IsCastableP() and (TargetUnit:TimeToDie() > 6 and TargetUnit:DebuffRemainsP(S.NightbladeDebuff) < Player:GCD() and Player:ComboPoints() >= 4 - num((HL.CombatTime() < 10)) * 2) then
      if HR.Cast(S.Nightblade) then return "nightblade 282"; end
    end
    -- variable,name=stealth_threshold,value=25+talent.vigor.enabled*35+talent.master_of_shadows.enabled*25+talent.shadow_focus.enabled*20+talent.alacrity.enabled*10+15*(spell_targets.shuriken_storm>=3)
    if (true) then
      VarStealthThreshold = 25 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 25 + num(S.ShadowFocus:IsAvailable()) * 20 + num(S.Alacrity:IsAvailable()) * 10 + 15 * num((Cache.EnemiesCount[10] >= 3))
    end
    -- call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&(talent.dark_shadow.enabled&cooldown.secret_technique.up|combo_points.deficit>=4)
    if (Player:EnergyDeficitPredicted() <= VarStealthThreshold and (S.DarkShadow:IsAvailable() and S.SecretTechnique:CooldownUpP() or Player:ComboPointsDeficit() >= 4)) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=finish,if=combo_points.deficit<=1|target.time_to_die<=1&combo_points>=3
    if (Player:ComboPointsDeficit() <= 1 or TargetUnit:TimeToDie() <= 1 and Player:ComboPoints() >= 3) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=finish,if=spell_targets.shuriken_storm=4&combo_points>=4
    if (Cache.EnemiesCount[10] == 4 and Player:ComboPoints() >= 4) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
    if (Player:EnergyDeficitPredicted() <= VarStealthThreshold) then
      local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
    end
    -- arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:EnergyDeficitPredicted() >= 15 + Player:EnergyRegen()) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 316"; end
    end
    -- arcane_pulse
    if S.ArcanePulse:IsCastableP() then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 318"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 320"; end
    end
  end
end

HR.SetAPL(261, APL)
