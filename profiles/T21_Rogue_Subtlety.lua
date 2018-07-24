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
  Vigor                                 = Spell(14983),
  MasterofShadows                       = Spell(),
  Stealth                               = Spell(1784),
  MarkedForDeath                        = Spell(137619),
  ShadowBlades                          = Spell(121471),
  ShurikenStorm                         = Spell(197835),
  TheDreadlordsDeceitBuff               = Spell(208692),
  Gloomblade                            = Spell(200758),
  Backstab                              = Spell(53),
  VanishBuff                            = Spell(1856),
  ShadowBladesBuff                      = Spell(121471),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  SymbolsofDeath                        = Spell(212283),
  NightbladeDebuff                      = Spell(195452),
  ShurikenTornado                       = Spell(),
  SymbolsofDeathBuff                    = Spell(212283),
  ShadowDanceBuff                       = Spell(185313),
  ShadowDance                           = Spell(185313),
  Subterfuge                            = Spell(108208),
  Nightblade                            = Spell(195452),
  DarkShadow                            = Spell(245687),
  SecretTechnique                       = Spell(),
  Nightstalker                          = Spell(14062),
  Eviscerate                            = Spell(196819),
  Vanish                                = Spell(1856),
  FindWeaknessDebuff                    = Spell(),
  PoolResource                          = Spell(9999000010),
  Shadowmeld                            = Spell(58984),
  Shadowstrike                          = Spell(185438),
  StealthBuff                           = Spell(1784),
  DeeperStratagem                       = Spell(193531),
  FindWeakness                          = Spell(),
  Alacrity                              = Spell(),
  ShadowFocus                           = Spell(108209),
  ArcaneTorrent                         = Spell(50613),
  ArcanePulse                           = Spell(),
  LightsJudgment                        = Spell(255647)
};
local S = Spell.Rogue.Subtlety;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Subtlety = {
  ProlongedPower                   = Item(142117)
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
local VarStealthThreshold = 0;
local VarShdThreshold = 0;

local EnemyRanges = {10, 15}
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
  UpdateRanges()
  local function Precombat()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
    if (true) then
      VarStealthThreshold = 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10
    end
    -- stealth
    if S.Stealth:IsCastableP() and Player:BuffDownP(S.Stealth) and (true) then
      if HR.Cast(S.Stealth) then return ""; end
    end
    -- marked_for_death,precombat_seconds=15
    if S.MarkedForDeath:IsCastableP() and (true) then
      if HR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- shadow_blades,precombat_seconds=1
    if S.ShadowBlades:IsCastableP() and Player:BuffDownP(S.ShadowBlades) and (true) then
      if HR.Cast(S.ShadowBlades) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Build()
    -- shuriken_storm,if=spell_targets.shuriken_storm>=2|buff.the_dreadlords_deceit.stack>=29
    if S.ShurikenStorm:IsCastableP() and (Cache.EnemiesCount[10] >= 2 or Player:BuffStackP(S.TheDreadlordsDeceitBuff) >= 29) then
      if HR.Cast(S.ShurikenStorm) then return ""; end
    end
    -- gloomblade
    if S.Gloomblade:IsCastableP() and (true) then
      if HR.Cast(S.Gloomblade) then return ""; end
    end
    -- backstab
    if S.Backstab:IsCastableP() and (true) then
      if HR.Cast(S.Backstab) then return ""; end
    end
  end
  local function Cds()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or (Player:BuffP(S.VanishBuff) and (Player:BuffP(S.ShadowBladesBuff) or S.ShadowBlades:CooldownRemainsP() <= 30))) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury,if=stealthed.rogue
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(stealthed.rogue)) then
      if HR.Cast(S.BloodFury, Settings.Subtlety.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking,if=stealthed.rogue
    if S.Berserking:IsCastableP() and HR.CDsON() and (bool(stealthed.rogue)) then
      if HR.Cast(S.Berserking, Settings.Subtlety.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- symbols_of_death,if=dot.nightblade.ticking
    if S.SymbolsofDeath:IsCastableP() and (Target:DebuffP(S.NightbladeDebuff)) then
      if HR.Cast(S.SymbolsofDeath) then return ""; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
    if S.MarkedForDeath:IsCastableP() and (Target:TimeToDie() < Player:ComboPointsDeficit()) then
      if HR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 30 and not bool(stealthed.all) and Player:ComboPointsDeficit() >= cp_max_spend) then
      if HR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- shadow_blades,if=combo_points.deficit>=2+stealthed.all
    if S.ShadowBlades:IsCastableP() and (Player:ComboPointsDeficit() >= 2 + stealthed.all) then
      if HR.Cast(S.ShadowBlades) then return ""; end
    end
    -- shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
    if S.ShurikenTornado:IsCastableP() and (Cache.EnemiesCount[15] >= 3 and Target:DebuffP(S.NightbladeDebuff) and Player:BuffP(S.SymbolsofDeathBuff) and Player:BuffP(S.ShadowDanceBuff)) then
      if HR.Cast(S.ShurikenTornado) then return ""; end
    end
    -- shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
    if S.ShadowDance:IsCastableP() and (not Player:BuffP(S.ShadowDanceBuff) and Target:TimeToDie() <= 5 + num(S.Subterfuge:IsAvailable())) then
      if HR.Cast(S.ShadowDance) then return ""; end
    end
  end
  local function Finish()
    -- nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
    if S.Nightblade:IsCastableP() and ((not S.DarkShadow:IsAvailable() or not Player:BuffP(S.ShadowDanceBuff)) and Target:TimeToDie() - Target:DebuffRemainsP(S.NightbladeDebuff) > 6 and Target:DebuffRemainsP(S.NightbladeDebuff) < S.NightbladeDebuff:TickTime() * 2 and (Cache.EnemiesCount[10] < 4 or not Player:BuffP(S.SymbolsofDeathBuff))) then
      if HR.Cast(S.Nightblade) then return ""; end
    end
    -- nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&(spell_targets.shuriken_storm<=5|talent.secret_technique.enabled)&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
    if S.Nightblade:IsCastableP() and (Cache.EnemiesCount[10] >= 2 and (Cache.EnemiesCount[10] <= 5 or S.SecretTechnique:IsAvailable()) and not Player:BuffP(S.ShadowDanceBuff) and Target:TimeToDie() >= (5 + (2 * Player:ComboPoints())) and Target:DebuffRefreshableCP(S.NightbladeDebuff)) then
      if HR.Cast(S.Nightblade) then return ""; end
    end
    -- nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if S.Nightblade:IsCastableP() and (Target:DebuffRemainsP(S.NightbladeDebuff) < S.SymbolsofDeath:CooldownRemainsP() + 10 and S.SymbolsofDeath:CooldownRemainsP() <= 5 and Target:TimeToDie() - Target:DebuffRemainsP(S.NightbladeDebuff) > S.SymbolsofDeath:CooldownRemainsP() + 5) then
      if HR.Cast(S.Nightblade) then return ""; end
    end
    -- secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
    if S.SecretTechnique:IsCastableP() and (Player:BuffP(S.SymbolsofDeathBuff) and (not S.DarkShadow:IsAvailable() or Cache.EnemiesCount[10] < 2 or Player:BuffP(S.ShadowDanceBuff))) then
      if HR.Cast(S.SecretTechnique) then return ""; end
    end
    -- secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
    if S.SecretTechnique:IsCastableP() and (Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable())) then
      if HR.Cast(S.SecretTechnique) then return ""; end
    end
    -- eviscerate
    if S.Eviscerate:IsCastableP() and (true) then
      if HR.Cast(S.Eviscerate) then return ""; end
    end
  end
  local function StealthCds()
    -- variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
    if (true) then
      VarShdThreshold = num(S.ShadowDance:ChargesFractional() >= 1.75)
    end
    -- vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
    if S.Vanish:IsCastableP() and (not bool(VarShdThreshold) and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1) then
      if HR.Cast(S.Vanish) then return ""; end
    end
    -- pool_resource,for_next=1,extra_amount=40
    if S.PoolResource:IsCastableP() and (true) then
      if HR.Cast(S.PoolResource) then return ""; end
    end
    -- shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
    if S.Shadowmeld:IsCastableP() and (Player:Energy() >= 40 and Player:EnergyDeficit() >= 10 and not bool(VarShdThreshold) and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1) then
      if HR.Cast(S.Shadowmeld) then return ""; end
    end
    -- shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&cooldown.symbols_of_death.remains>10)
    if S.ShadowDance:IsCastableP() and ((not S.DarkShadow:IsAvailable() or Target:DebuffRemainsP(S.NightbladeDebuff) >= 5 + num(S.Subterfuge:IsAvailable())) and (bool(VarShdThreshold) or Player:BuffRemainsP(S.SymbolsofDeathBuff) >= 1.2 or Cache.EnemiesCount[15] >= 4 and S.SymbolsofDeath:CooldownRemainsP() > 10)) then
      if HR.Cast(S.ShadowDance) then return ""; end
    end
    -- shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
    if S.ShadowDance:IsCastableP() and (Target:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP()) then
      if HR.Cast(S.ShadowDance) then return ""; end
    end
  end
  local function Stealthed()
    -- shadowstrike,if=buff.stealth.up
    if S.Shadowstrike:IsCastableP() and (Player:BuffP(S.StealthBuff)) then
      if HR.Cast(S.Shadowstrike) then return ""; end
    end
    -- call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
    if (Player:ComboPointsDeficit() <= 1 - num((S.DeeperStratagem:IsAvailable() and Player:BuffP(S.VanishBuff)))) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
    if S.Shadowstrike:IsCastableP() and (S.SecretTechnique:IsAvailable() and S.FindWeakness:IsAvailable() and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1 and Cache.EnemiesCount[10] == 2 and Target:TimeToDie() - remains > 6) then
      if HR.Cast(S.Shadowstrike) then return ""; end
    end
    -- shuriken_storm,if=spell_targets.shuriken_storm>=3
    if S.ShurikenStorm:IsCastableP() and (Cache.EnemiesCount[10] >= 3) then
      if HR.Cast(S.ShurikenStorm) then return ""; end
    end
    -- shadowstrike
    if S.Shadowstrike:IsCastableP() and (true) then
      if HR.Cast(S.Shadowstrike) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
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
  if S.Nightblade:IsCastableP() and (Target:TimeToDie() > 6 and Target:DebuffRemainsP(S.NightbladeDebuff) < Player:GCD() and Player:ComboPoints() >= 4 - num((HL.CombatTime() < 10)) * 2) then
    if HR.Cast(S.Nightblade) then return ""; end
  end
  -- call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
  if (Player:EnergyDeficit() <= VarStealthThreshold and Player:ComboPointsDeficit() >= 4) then
    local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
  if (Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable()) or Target:TimeToDie() <= 1 and Player:ComboPoints() >= 3) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
  if (Player:EnergyDeficit() <= VarStealthThreshold - 40 * num(not (S.Alacrity:IsAvailable() or S.ShadowFocus:IsAvailable() or S.MasterofShadows:IsAvailable()))) then
    local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
  end
  -- arcane_torrent,if=energy.deficit>=15+energy.regen
  if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:EnergyDeficit() >= 15 + Player:EnergyRegen()) then
    if HR.Cast(S.ArcaneTorrent, Settings.Subtlety.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- arcane_pulse
  if S.ArcanePulse:IsCastableP() and (true) then
    if HR.Cast(S.ArcanePulse) then return ""; end
  end
  -- lights_judgment
  if S.LightsJudgment:IsCastableP() and HR.CDsON() and (true) then
    if HR.Cast(S.LightsJudgment) then return ""; end
  end
end

HR.SetAPL(261, APL)
