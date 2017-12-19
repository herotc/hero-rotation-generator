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
Spell.Rogue.Subtlety = {
  Vigor                                 = Spell(14983),
  MasterofShadows                       = Spell(),
  EnvelopingShadows                     = Spell(238104),
  Stealth                               = Spell(1784),
  MarkedForDeath                        = Spell(137619),
  ShurikenStorm                         = Spell(197835),
  TheFirstoftheDeadBuff                 = Spell(248110),
  Gloomblade                            = Spell(200758),
  Backstab                              = Spell(53),
  VanishBuff                            = Spell(1856),
  ShadowBladesBuff                      = Spell(121471),
  ShadowBlades                          = Spell(121471),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  SymbolsofDeath                        = Spell(212283),
  DeathFromAbove                        = Spell(152150),
  NightbladeDebuff                      = Spell(195452),
  GoremawsBite                          = Spell(209782),
  ShadowDance                           = Spell(185313),
  PoolResource                          = Spell(9999000010),
  Vanish                                = Spell(1856),
  ShadowFocus                           = Spell(108209),
  SymbolsofDeathBuff                    = Spell(212283),
  ShadowDanceBuff                       = Spell(185313),
  StealthBuff                           = Spell(1784),
  Subterfuge                            = Spell(108208),
  Nightblade                            = Spell(195452),
  DarkShadow                            = Spell(245687),
  FinalityNightbladeBuff                = Spell(197498),
  FinalityEviscerateBuff                = Spell(197496),
  Eviscerate                            = Spell(196819),
  FeedingFrenzyBuff                     = Spell(238140),
  Shadowmeld                            = Spell(58984),
  Shadowstrike                          = Spell(185438),
  DeeperStratagem                       = Spell(193531),
  ShadowmeldBuff                        = Spell(58984),
  TheDreadlordsDeceitBuff               = Spell(208692),
  SubterfugeBuff                        = Spell(108208),
  DeathFromAboveBuff                    = Spell(163786),
  Wait                                  = Spell(),
  Anticipation                          = Spell(114015),
  ShadowGesturesBuff                    = Spell()
};
local S = Spell.Rogue.Subtlety;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Subtlety = {
  ShadowSatyrsWalk                 = Item(137032),
  ProlongedPower                   = Item(142117),
  TheFirstoftheDead                = Item(151818),
  MantleoftheMasterAssassin        = Item(144236),
  InsigniaofRavenholdt             = Item(137049),
  DenialoftheHalfgiants            = Item(137100)
};
local I = Item.Rogue.Subtlety;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Rogue.Commons,
  Subtlety = AR.GUISettings.APL.Rogue.Subtlety
};

-- Variables
local VarSswRefund = 0;
local VarStealthThreshold = 0;
local VarShdFractional = 0;
local VarDshDfa = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local function Precombat()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- variable,name=ssw_refund,value=equipped.shadow_satyrs_walk*(6+ssw_refund_offset)
    if (true) then
      VarSswRefund = num(I.ShadowSatyrsWalk:IsEquipped()) * (6 + ssw_refund_offset)
    end
    -- variable,name=stealth_threshold,value=(65+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10+variable.ssw_refund)
    if (true) then
      VarStealthThreshold = (65 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10 + VarSswRefund)
    end
    -- variable,name=shd_fractional,value=1.725+0.725*talent.enveloping_shadows.enabled
    if (true) then
      VarShdFractional = 1.725 + 0.725 * num(S.EnvelopingShadows:IsAvailable())
    end
    -- stealth
    if S.Stealth:IsCastableP() and (true) then
      if AR.Cast(S.Stealth) then return ""; end
    end
    -- marked_for_death,precombat=1
    if S.MarkedForDeath:IsCastableP() and (true) then
      if AR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function Build()
    -- shuriken_storm,if=spell_targets.shuriken_storm>=2+buff.the_first_of_the_dead.up
    if S.ShurikenStorm:IsCastableP() and (Cache.EnemiesCount[10] >= 2 + num(Player:BuffP(S.TheFirstoftheDeadBuff))) then
      if AR.Cast(S.ShurikenStorm) then return ""; end
    end
    -- gloomblade
    if S.Gloomblade:IsCastableP() and (true) then
      if AR.Cast(S.Gloomblade) then return ""; end
    end
    -- backstab
    if S.Backstab:IsCastableP() and (true) then
      if AR.Cast(S.Backstab) then return ""; end
    end
  end
  local function Cds()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or (Player:BuffP(S.VanishBuff) and (Player:BuffP(S.ShadowBladesBuff) or S.ShadowBlades:CooldownRemainsP() <= 30))) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury,if=stealthed.rogue
    if S.BloodFury:IsCastableP() and AR.CDsON() and (bool(stealthed.rogue)) then
      if AR.Cast(S.BloodFury, Settings.Subtlety.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking,if=stealthed.rogue
    if S.Berserking:IsCastableP() and AR.CDsON() and (bool(stealthed.rogue)) then
      if AR.Cast(S.Berserking, Settings.Subtlety.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=stealthed.rogue&energy.deficit>70
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (bool(stealthed.rogue) and Player:EnergyDeficit() > 70) then
      if AR.Cast(S.ArcaneTorrent, Settings.Subtlety.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- symbols_of_death,if=!talent.death_from_above.enabled
    if S.SymbolsofDeath:IsCastableP() and (not S.DeathFromAbove:IsAvailable()) then
      if AR.Cast(S.SymbolsofDeath) then return ""; end
    end
    -- symbols_of_death,if=(talent.death_from_above.enabled&cooldown.death_from_above.remains<=1&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)&(time>=3|set_bonus.tier20_4pc|equipped.the_first_of_the_dead))|target.time_to_die-remains<=10
    if S.SymbolsofDeath:IsCastableP() and ((S.DeathFromAbove:IsAvailable() and S.DeathFromAbove:CooldownRemainsP() <= 1 and (Target:DebuffRemainsP(S.NightbladeDebuff) >= S.DeathFromAbove:CooldownRemainsP() + 3 or Target:TimeToDie() - Target:DebuffRemainsP(S.NightbladeDebuff) <= 6) and (AC.CombatTime() >= 3 or AC.Tier20_4Pc or I.TheFirstoftheDead:IsEquipped())) or Target:TimeToDie() - Player:BuffRemainsP(S.SymbolsofDeath) <= 10) then
      if AR.Cast(S.SymbolsofDeath) then return ""; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
    if S.MarkedForDeath:IsCastableP() and (Target:TimeToDie() < Player:ComboPointsDeficit()) then
      if AR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- marked_for_death,if=raid_event.adds.in>40&!stealthed.all&combo_points.deficit>=cp_max_spend
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 40 and not bool(stealthed.all) and Player:ComboPointsDeficit() >= cp_max_spend) then
      if AR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- shadow_blades,if=(time>10&combo_points.deficit>=2+stealthed.all-equipped.mantle_of_the_master_assassin)|(time<10&(!talent.marked_for_death.enabled|combo_points.deficit>=3|dot.nightblade.ticking))
    if S.ShadowBlades:IsCastableP() and ((AC.CombatTime() > 10 and Player:ComboPointsDeficit() >= 2 + stealthed.all - num(I.MantleoftheMasterAssassin:IsEquipped())) or (AC.CombatTime() < 10 and (not S.MarkedForDeath:IsAvailable() or Player:ComboPointsDeficit() >= 3 or Target:DebuffP(S.NightbladeDebuff)))) then
      if AR.Cast(S.ShadowBlades) then return ""; end
    end
    -- goremaws_bite,if=!stealthed.all&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&((combo_points.deficit>=4-(time<10)*2&energy.deficit>50+talent.vigor.enabled*25-(time>=10)*15)|(combo_points.deficit>=1&target.time_to_die<8))
    if S.GoremawsBite:IsCastableP() and (not bool(stealthed.all) and S.ShadowDance:ChargesFractional() <= VarShdFractional and ((Player:ComboPointsDeficit() >= 4 - num((AC.CombatTime() < 10)) * 2 and Player:EnergyDeficit() > 50 + num(S.Vigor:IsAvailable()) * 25 - num((AC.CombatTime() >= 10)) * 15) or (Player:ComboPointsDeficit() >= 1 and Target:TimeToDie() < 8))) then
      if AR.Cast(S.GoremawsBite) then return ""; end
    end
    -- pool_resource,for_next=1,extra_amount=55-talent.shadow_focus.enabled*10
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- vanish,if=energy>=55-talent.shadow_focus.enabled*10&variable.dsh_dfa&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&!buff.shadow_dance.up&!buff.stealth.up&mantle_duration=0&(dot.nightblade.remains>=cooldown.death_from_above.remains+6&!(buff.the_first_of_the_dead.remains>1&combo_points>=5)|target.time_to_die-dot.nightblade.remains<=6)&cooldown.death_from_above.remains<=1|target.time_to_die<=7
    if S.Vanish:IsCastableP() and (Player:Energy() >= 55 - num(S.ShadowFocus:IsAvailable()) * 10 and bool(VarDshDfa) and (not I.MantleoftheMasterAssassin:IsEquipped() or Player:BuffP(S.SymbolsofDeathBuff)) and S.ShadowDance:ChargesFractional() <= VarShdFractional and not Player:BuffP(S.ShadowDanceBuff) and not Player:BuffP(S.StealthBuff) and mantle_duration == 0 and (Target:DebuffRemainsP(S.NightbladeDebuff) >= S.DeathFromAbove:CooldownRemainsP() + 6 and not (Player:BuffRemainsP(S.TheFirstoftheDeadBuff) > 1 and Player:ComboPoints() >= 5) or Target:TimeToDie() - Target:DebuffRemainsP(S.NightbladeDebuff) <= 6) and S.DeathFromAbove:CooldownRemainsP() <= 1 or Target:TimeToDie() <= 7) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=4+talent.subterfuge.enabled
    if S.ShadowDance:IsCastableP() and (not Player:BuffP(S.ShadowDanceBuff) and Target:TimeToDie() <= 4 + num(S.Subterfuge:IsAvailable())) then
      if AR.Cast(S.ShadowDance) then return ""; end
    end
  end
  local function Finish()
    -- nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&(mantle_duration=0|remains<=mantle_duration)&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if S.Nightblade:IsCastableP() and ((not S.DarkShadow:IsAvailable() or not Player:BuffP(S.ShadowDanceBuff)) and Target:TimeToDie() - Target:DebuffRemainsP(S.Nightblade) > 6 and (mantle_duration == 0 or Target:DebuffRemainsP(S.Nightblade) <= mantle_duration) and ((Target:DebuffRefreshableCP(S.Nightblade) and (not bool(finality) or Player:BuffP(S.FinalityNightbladeBuff) or bool(VarDshDfa))) or Target:DebuffRemainsP(S.Nightblade) < S.Nightblade:TickTime() * 2) and (Cache.EnemiesCount[10] < 4 and not bool(VarDshDfa) or not Player:BuffP(S.SymbolsofDeathBuff))) then
      if AR.Cast(S.Nightblade) then return ""; end
    end
    -- nightblade,cycle_targets=1,if=(!talent.death_from_above.enabled|set_bonus.tier19_2pc)&(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>12&mantle_duration=0&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if S.Nightblade:IsCastableP() and ((not S.DeathFromAbove:IsAvailable() or AC.Tier19_2Pc) and (not S.DarkShadow:IsAvailable() or not Player:BuffP(S.ShadowDanceBuff)) and Target:TimeToDie() - Target:DebuffRemainsP(S.Nightblade) > 12 and mantle_duration == 0 and ((Target:DebuffRefreshableCP(S.Nightblade) and (not bool(finality) or Player:BuffP(S.FinalityNightbladeBuff) or bool(VarDshDfa))) or Target:DebuffRemainsP(S.Nightblade) < S.Nightblade:TickTime() * 2) and (Cache.EnemiesCount[10] < 4 and not bool(VarDshDfa) or not Player:BuffP(S.SymbolsofDeathBuff))) then
      if AR.Cast(S.Nightblade) then return ""; end
    end
    -- nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5+(combo_points=6)&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if S.Nightblade:IsCastableP() and (Target:DebuffRemainsP(S.Nightblade) < S.SymbolsofDeath:CooldownRemainsP() + 10 and S.SymbolsofDeath:CooldownRemainsP() <= 5 + num((Player:ComboPoints() == 6)) and Target:TimeToDie() - Target:DebuffRemainsP(S.Nightblade) > S.SymbolsofDeath:CooldownRemainsP() + 5) then
      if AR.Cast(S.Nightblade) then return ""; end
    end
    -- death_from_above,if=!talent.dark_shadow.enabled|(!buff.shadow_dance.up|spell_targets>=4)&(buff.symbols_of_death.up|cooldown.symbols_of_death.remains>=10+set_bonus.tier20_4pc*5)&buff.the_first_of_the_dead.remains<1&(buff.finality_eviscerate.up|spell_targets.shuriken_storm<4)
    if S.DeathFromAbove:IsCastableP() and (not S.DarkShadow:IsAvailable() or (not Player:BuffP(S.ShadowDanceBuff) or Cache.EnemiesCount[15] >= 4) and (Player:BuffP(S.SymbolsofDeathBuff) or S.SymbolsofDeath:CooldownRemainsP() >= 10 + num(AC.Tier20_4Pc) * 5) and Player:BuffRemainsP(S.TheFirstoftheDeadBuff) < 1 and (Player:BuffP(S.FinalityEviscerateBuff) or Cache.EnemiesCount[10] < 4)) then
      if AR.Cast(S.DeathFromAbove) then return ""; end
    end
    -- eviscerate
    if S.Eviscerate:IsCastableP() and (true) then
      if AR.Cast(S.Eviscerate) then return ""; end
    end
  end
  local function StealthAls()
    -- call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
    if (Player:EnergyDeficit() <= VarStealthThreshold - 25 * num((not S.GoremawsBite:CooldownUpP() and not Player:BuffP(S.FeedingFrenzyBuff))) and (not I.ShadowSatyrsWalk:IsEquipped() or S.ShadowDance:ChargesFractional() >= VarShdFractional or Player:EnergyDeficit() >= 10)) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=stealth_cds,if=mantle_duration>2.3
    if (mantle_duration > 2.3) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
    if (Cache.EnemiesCount[10] >= 4) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
    if ((S.Shadowmeld:CooldownUpP() and not S.Vanish:CooldownUpP() and S.ShadowDance:ChargesP() <= 1)) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
    if (Target:TimeToDie() < 12 * S.ShadowDance:ChargesFractional() * (1 + num(I.ShadowSatyrsWalk:IsEquipped()) * 0.5)) then
      local ShouldReturn = StealthCds(); if ShouldReturn then return ShouldReturn; end
    end
  end
  local function StealthCds()
    -- vanish,if=!variable.dsh_dfa&mantle_duration=0&cooldown.shadow_dance.charges_fractional<variable.shd_fractional+(equipped.mantle_of_the_master_assassin&time<30)*0.3&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)
    if S.Vanish:IsCastableP() and (not bool(VarDshDfa) and mantle_duration == 0 and S.ShadowDance:ChargesFractional() < VarShdFractional + num((I.MantleoftheMasterAssassin:IsEquipped() and AC.CombatTime() < 30)) * 0.3 and (not I.MantleoftheMasterAssassin:IsEquipped() or Player:BuffP(S.SymbolsofDeathBuff))) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- shadow_dance,if=charges_fractional>=variable.shd_fractional|target.time_to_die<cooldown.symbols_of_death.remains
    if S.ShadowDance:IsCastableP() and (S.ShadowDance:ChargesFractional() >= VarShdFractional or Target:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP()) then
      if AR.Cast(S.ShadowDance) then return ""; end
    end
    -- pool_resource,for_next=1,extra_amount=40
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
    if S.Shadowmeld:IsCastableP() and (Player:Energy() >= 40 and Player:EnergyDeficit() >= 10 + VarSswRefund) then
      if AR.Cast(S.Shadowmeld) then return ""; end
    end
    -- shadow_dance,if=!variable.dsh_dfa&combo_points.deficit>=2+talent.subterfuge.enabled*2&(buff.symbols_of_death.remains>=1.2|cooldown.symbols_of_death.remains>=12+(talent.dark_shadow.enabled&set_bonus.tier20_4pc)*3-(!talent.dark_shadow.enabled&set_bonus.tier20_4pc)*4|mantle_duration>0)&(spell_targets.shuriken_storm>=4|!buff.the_first_of_the_dead.up)
    if S.ShadowDance:IsCastableP() and (not bool(VarDshDfa) and Player:ComboPointsDeficit() >= 2 + num(S.Subterfuge:IsAvailable()) * 2 and (Player:BuffRemainsP(S.SymbolsofDeathBuff) >= 1.2 or S.SymbolsofDeath:CooldownRemainsP() >= 12 + num((S.DarkShadow:IsAvailable() and AC.Tier20_4Pc)) * 3 - num((not S.DarkShadow:IsAvailable() and AC.Tier20_4Pc)) * 4 or mantle_duration > 0) and (Cache.EnemiesCount[10] >= 4 or not Player:BuffP(S.TheFirstoftheDeadBuff))) then
      if AR.Cast(S.ShadowDance) then return ""; end
    end
  end
  local function Stealthed()
    -- shadowstrike,if=buff.stealth.up
    if S.Shadowstrike:IsCastableP() and (Player:BuffP(S.StealthBuff)) then
      if AR.Cast(S.Shadowstrike) then return ""; end
    end
    -- call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration>=0.3))
    if (Player:ComboPoints() >= 5 + num((S.DeeperStratagem:IsAvailable() and Player:BuffP(S.VanishBuff))) and (Cache.EnemiesCount[10] >= 3 + num(I.ShadowSatyrsWalk:IsEquipped()) or (mantle_duration <= 1.3 and mantle_duration >= 0.3))) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- shuriken_storm,if=buff.shadowmeld.down&((combo_points.deficit>=2+equipped.insignia_of_ravenholdt&spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk)|(combo_points.deficit>=1&buff.the_dreadlords_deceit.stack>=29))
    if S.ShurikenStorm:IsCastableP() and (Player:BuffDownP(S.ShadowmeldBuff) and ((Player:ComboPointsDeficit() >= 2 + num(I.InsigniaofRavenholdt:IsEquipped()) and Cache.EnemiesCount[10] >= 3 + num(I.ShadowSatyrsWalk:IsEquipped())) or (Player:ComboPointsDeficit() >= 1 and Player:BuffStackP(S.TheDreadlordsDeceitBuff) >= 29))) then
      if AR.Cast(S.ShurikenStorm) then return ""; end
    end
    -- call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
    if (Player:ComboPoints() >= 5 + num((S.DeeperStratagem:IsAvailable() and Player:BuffP(S.VanishBuff))) and Player:ComboPointsDeficit() < 3 + num(Player:BuffP(S.ShadowBladesBuff)) - num(I.MantleoftheMasterAssassin:IsEquipped())) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- shadowstrike
    if S.Shadowstrike:IsCastableP() and (true) then
      if AR.Cast(S.Shadowstrike) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled&spell_targets.death_from_above<4
  if (true) then
    VarDshDfa = num(S.DeathFromAbove:IsAvailable() and S.DarkShadow:IsAvailable() and Cache.EnemiesCount[15] < 4)
  end
  -- shadow_dance,if=talent.dark_shadow.enabled&(!stealthed.all|buff.subterfuge.up)&buff.death_from_above.up&buff.death_from_above.remains<=0.15
  if S.ShadowDance:IsCastableP() and (S.DarkShadow:IsAvailable() and (not bool(stealthed.all) or Player:BuffP(S.SubterfugeBuff)) and Player:BuffP(S.DeathFromAboveBuff) and Player:BuffRemainsP(S.DeathFromAboveBuff) <= 0.15) then
    if AR.Cast(S.ShadowDance) then return ""; end
  end
  -- wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
  if S.Wait:IsCastableP() and (Player:BuffP(S.ShadowDanceBuff) and Player:GCDRemains() > 0) then
    if AR.Cast(S.Wait) then return ""; end
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
  if S.Nightblade:IsCastableP() and (Target:TimeToDie() > 6 and Target:DebuffRemainsP(S.Nightblade) < Player:GCD() and Player:ComboPoints() >= 4 - num((AC.CombatTime() < 10)) * 2) then
    if AR.Cast(S.Nightblade) then return ""; end
  end
  -- call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
  if (S.DarkShadow:IsAvailable() and Player:ComboPointsDeficit() >= 2 + num(Player:BuffP(S.ShadowBladesBuff)) and (Target:DebuffRemainsP(S.NightbladeDebuff) > 4 + num(S.Subterfuge:IsAvailable()) or S.ShadowDance:ChargesFractional() >= 1.9 and (not I.DenialoftheHalfgiants:IsEquipped() or AC.CombatTime() > 10))) then
    local ShouldReturn = StealthAls(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
  if (not S.DarkShadow:IsAvailable() and (Player:ComboPointsDeficit() >= 2 + num(Player:BuffP(S.ShadowBladesBuff)) or S.ShadowDance:ChargesFractional() >= 1.9 + num(S.EnvelopingShadows:IsAvailable()))) then
    local ShouldReturn = StealthAls(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=combo_points>=5+3*(buff.the_first_of_the_dead.up&talent.anticipation.enabled)+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
  if (Player:ComboPoints() >= 5 + 3 * num((Player:BuffP(S.TheFirstoftheDeadBuff) and S.Anticipation:IsAvailable())) + num((S.DeeperStratagem:IsAvailable() and not Player:BuffP(S.ShadowBladesBuff) and (mantle_duration == 0 or AC.Tier20_4Pc) and (not Player:BuffP(S.TheFirstoftheDeadBuff) or bool(VarDshDfa)))) or (Player:ComboPoints() >= 4 and Player:ComboPointsDeficit() <= 2 and Cache.EnemiesCount[10] >= 3 and Cache.EnemiesCount[10] <= 4) or (Target:TimeToDie() <= 1 and Player:ComboPoints() >= 3)) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=buff.the_first_of_the_dead.remains>1&combo_points>=3&spell_targets.shuriken_storm<2&!buff.shadow_gestures.up
  if (Player:BuffRemainsP(S.TheFirstoftheDeadBuff) > 1 and Player:ComboPoints() >= 3 and Cache.EnemiesCount[10] < 2 and not Player:BuffP(S.ShadowGesturesBuff)) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=variable.dsh_dfa&equipped.the_first_of_the_dead&dot.nightblade.remains<=(cooldown.symbols_of_death.remains+10)&cooldown.symbols_of_death.remains<=2&combo_points>=2
  if (bool(VarDshDfa) and I.TheFirstoftheDead:IsEquipped() and Target:DebuffRemainsP(S.NightbladeDebuff) <= (S.SymbolsofDeath:CooldownRemainsP() + 10) and S.SymbolsofDeath:CooldownRemainsP() <= 2 and Player:ComboPoints() >= 2) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- wait,sec=time_to_sht.5,if=combo_points=5&time_to_sht.5<=1&energy.deficit>=30&!buff.shadow_blades.up
  if S.Wait:IsCastableP() and (Player:ComboPoints() == 5 and time_to_sht.5 <= 1 and Player:EnergyDeficit() >= 30 and not Player:BuffP(S.ShadowBladesBuff)) then
    if AR.Cast(S.Wait) then return ""; end
  end
  -- call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
  if (Player:EnergyDeficit() <= VarStealthThreshold) then
    local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(261, APL)
