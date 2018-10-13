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
Spell.Rogue.Assassination = {
  ApplyPoison                           = Spell(),
  Stealth                               = Spell(),
  MarkedForDeath                        = Spell(137619),
  VendettaDebuff                        = Spell(79140),
  Vanish                                = Spell(1856),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Vendetta                              = Spell(79140),
  RuptureDebuff                         = Spell(1943),
  Exsanguinate                          = Spell(200806),
  Nightstalker                          = Spell(14062),
  Subterfuge                            = Spell(108208),
  Garrote                               = Spell(703),
  GarroteDebuff                         = Spell(703),
  MasterAssassin                        = Spell(),
  ToxicBlade                            = Spell(245388),
  Envenom                               = Spell(32645),
  DeeperStratagem                       = Spell(193531),
  ToxicBladeDebuff                      = Spell(245389),
  PoisonedKnife                         = Spell(),
  SharpenedBladesBuff                   = Spell(),
  FanofKnives                           = Spell(51723),
  HiddenBladesBuff                      = Spell(),
  TheDreadlordsDeceitBuff               = Spell(208692),
  Blindside                             = Spell(),
  BlindsideBuff                         = Spell(),
  VenomRush                             = Spell(152152),
  Mutilate                              = Spell(1329),
  Rupture                               = Spell(1943),
  PoolResource                          = Spell(9999000010),
  CrimsonTempest                        = Spell(121411),
  CrimsonTempestBuff                    = Spell(121411),
  ArcaneTorrent                         = Spell(50613),
  ArcanePulse                           = Spell(),
  LightsJudgment                        = Spell(255647)
};
local S = Spell.Rogue.Assassination;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Assassination = {
  ProlongedPower                   = Item(142117),
  GalecallersBoon                  = Item(),
  LustrousGoldenPlumage            = Item()
};
local I = Item.Rogue.Assassination;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Rogue.Commons,
  Assassination = HR.GUISettings.APL.Rogue.Assassination
};

-- Variables
local VarEnergyRegenCombined = 0;
local VarUseFiller = 0;

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
  local Precombat, Cds, Direct, Dot, Stealthed
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- apply_poison
    if S.ApplyPoison:IsCastableP() then
      if HR.Cast(S.ApplyPoison) then return "apply_poison 4"; end
    end
    -- stealth
    if S.Stealth:IsCastableP() then
      if HR.Cast(S.Stealth) then return "stealth 6"; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 8"; end
    end
    -- marked_for_death,precombat_seconds=5,if=raid_event.adds.in>40
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 40) then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 10"; end
    end
  end
  Cds = function()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or Target:DebuffP(S.VendettaDebuff) and S.Vanish:CooldownRemainsP() < 5) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 12"; end
    end
    -- use_item,name=galecallers_boon
    if I.GalecallersBoon:IsReady() then
      if HR.CastSuggested(I.GalecallersBoon) then return "galecallers_boon 18"; end
    end
    -- use_item,name=lustrous_golden_plumage
    if I.LustrousGoldenPlumage:IsReady() then
      if HR.CastSuggested(I.LustrousGoldenPlumage) then return "lustrous_golden_plumage 20"; end
    end
    -- blood_fury,if=debuff.vendetta.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 22"; end
    end
    -- berserking,if=debuff.vendetta.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 26"; end
    end
    -- fireblood,if=debuff.vendetta.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 30"; end
    end
    -- ancestral_call,if=debuff.vendetta.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.VendettaDebuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 34"; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
    if S.MarkedForDeath:IsCastableP() then
      if HR.CastTargetIf(S.MarkedForDeath, 15, "min", function(TargetUnit) return TargetUnit:TimeToDie() end, function(TargetUnit) return TargetUnit:TimeToDie() < Player:ComboPointsDeficit() * 1.5 or (10000000000 > 40 and Player:ComboPointsDeficit() >= cp_max_spend) end) then return "marked_for_death 42" end
    end
    -- vendetta,if=dot.rupture.ticking
    if S.Vendetta:IsCastableP() and (Target:DebuffP(S.RuptureDebuff)) then
      if HR.Cast(S.Vendetta) then return "vendetta 43"; end
    end
    -- vanish,if=talent.exsanguinate.enabled&(talent.nightstalker.enabled|talent.subterfuge.enabled&spell_targets.fan_of_knives<2)&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1
    if S.Vanish:IsCastableP() and (S.Exsanguinate:IsAvailable() and (S.Nightstalker:IsAvailable() or S.Subterfuge:IsAvailable() and Cache.EnemiesCount[10] < 2) and Player:ComboPoints() >= cp_max_spend and S.Exsanguinate:CooldownRemainsP() < 1) then
      if HR.Cast(S.Vanish) then return "vanish 47"; end
    end
    -- vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&debuff.vendetta.up
    if S.Vanish:IsCastableP() and (S.Nightstalker:IsAvailable() and not S.Exsanguinate:IsAvailable() and Player:ComboPoints() >= cp_max_spend and Target:DebuffP(S.VendettaDebuff)) then
      if HR.Cast(S.Vanish) then return "vanish 57"; end
    end
    -- vanish,if=talent.subterfuge.enabled&(!talent.exsanguinate.enabled|spell_targets.fan_of_knives>=2)&!stealthed.rogue&cooldown.garrote.up&dot.garrote.refreshable&(spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives|spell_targets.fan_of_knives>=4&combo_points.deficit>=4)
    if S.Vanish:IsCastableP() and (S.Subterfuge:IsAvailable() and (not S.Exsanguinate:IsAvailable() or Cache.EnemiesCount[10] >= 2) and not bool(stealthed.rogue) and S.Garrote:CooldownUpP() and Target:DebuffRefreshableCP(S.GarroteDebuff) and (Cache.EnemiesCount[10] <= 3 and Player:ComboPointsDeficit() >= 1 + Cache.EnemiesCount[10] or Cache.EnemiesCount[10] >= 4 and Player:ComboPointsDeficit() >= 4)) then
      if HR.Cast(S.Vanish) then return "vanish 65"; end
    end
    -- vanish,if=talent.master_assassin.enabled&!stealthed.all&master_assassin_remains<=0&!dot.rupture.refreshable
    if S.Vanish:IsCastableP() and (S.MasterAssassin:IsAvailable() and not bool(stealthed.all) and master_assassin_remains <= 0 and not Target:DebuffRefreshableCP(S.RuptureDebuff)) then
      if HR.Cast(S.Vanish) then return "vanish 75"; end
    end
    -- exsanguinate,if=dot.rupture.remains>4+4*cp_max_spend&!dot.garrote.refreshable
    if S.Exsanguinate:IsCastableP() and (Target:DebuffRemainsP(S.RuptureDebuff) > 4 + 4 * cp_max_spend and not Target:DebuffRefreshableCP(S.GarroteDebuff)) then
      if HR.Cast(S.Exsanguinate) then return "exsanguinate 81"; end
    end
    -- toxic_blade,if=dot.rupture.ticking
    if S.ToxicBlade:IsCastableP() and (Target:DebuffP(S.RuptureDebuff)) then
      if HR.Cast(S.ToxicBlade) then return "toxic_blade 87"; end
    end
  end
  Direct = function()
    -- envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
    if S.Envenom:IsCastableP() and (Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable()) and (Target:DebuffP(S.VendettaDebuff) or Target:DebuffP(S.ToxicBladeDebuff) or Player:EnergyDeficitPredicted() <= 25 + VarEnergyRegenCombined or Cache.EnemiesCount[10] >= 2) and (not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemainsP() > 2)) then
      if HR.Cast(S.Envenom) then return "envenom 91"; end
    end
    -- variable,name=use_filler,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2
    if (true) then
      VarUseFiller = num(Player:ComboPointsDeficit() > 1 or Player:EnergyDeficitPredicted() <= 25 + VarEnergyRegenCombined or Cache.EnemiesCount[10] >= 2)
    end
    -- poisoned_knife,if=variable.use_filler&buff.sharpened_blades.stack>=29
    if S.PoisonedKnife:IsCastableP() and (bool(VarUseFiller) and Player:BuffStackP(S.SharpenedBladesBuff) >= 29) then
      if HR.Cast(S.PoisonedKnife) then return "poisoned_knife 109"; end
    end
    -- fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|spell_targets.fan_of_knives>=2+stealthed.rogue|buff.the_dreadlords_deceit.stack>=29)
    if S.FanofKnives:IsCastableP() and (bool(VarUseFiller) and (Player:BuffStackP(S.HiddenBladesBuff) >= 19 or Cache.EnemiesCount[10] >= 2 + stealthed.rogue or Player:BuffStackP(S.TheDreadlordsDeceitBuff) >= 29)) then
      if HR.Cast(S.FanofKnives) then return "fan_of_knives 115"; end
    end
    -- blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled)
    if S.Blindside:IsCastableP() and (bool(VarUseFiller) and (Player:BuffP(S.BlindsideBuff) or not S.VenomRush:IsAvailable())) then
      if HR.Cast(S.Blindside) then return "blindside 123"; end
    end
    -- mutilate,if=variable.use_filler
    if S.Mutilate:IsCastableP() and (bool(VarUseFiller)) then
      if HR.Cast(S.Mutilate) then return "mutilate 131"; end
    end
  end
  Dot = function()
    -- rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2)))
    if S.Rupture:IsCastableP() and (S.Exsanguinate:IsAvailable() and ((Player:ComboPoints() >= cp_max_spend and S.Exsanguinate:CooldownRemainsP() < 1) or (not Target:DebuffP(S.RuptureDebuff) and (HL.CombatTime() > 10 or Player:ComboPoints() >= 2)))) then
      if HR.Cast(S.Rupture) then return "rupture 135"; end
    end
    -- pool_resource,for_next=1
    -- garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&(target.time_to_die-remains>4&spell_targets.fan_of_knives<=1|target.time_to_die-remains>12)
    if S.Garrote:IsCastableP() then
      if HR.CastCycle(S.Garrote, 15, function(TargetUnit) return (not S.Subterfuge:IsAvailable() or not (S.Vanish:CooldownUpP() and S.Vendetta:CooldownRemainsP() <= 4)) and Player:ComboPointsDeficit() >= 1 and TargetUnit:DebuffRefreshableCP(S.GarroteDebuff) and (pmultiplier <= 1 or TargetUnit:DebuffRemainsP(S.GarroteDebuff) <= S.GarroteDebuff:TickTime()) and (not bool(exsanguinated) or TargetUnit:DebuffRemainsP(S.GarroteDebuff) <= S.GarroteDebuff:TickTime() * 2) and (TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.GarroteDebuff) > 4 and Cache.EnemiesCount[10] <= 1 or TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.GarroteDebuff) > 12) end) then return "garrote 201" end
    end
    -- crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
    if S.CrimsonTempest:IsCastableP() and (Cache.EnemiesCount[15] >= 2 and Player:BuffRemainsP(S.CrimsonTempestBuff) < 2 + num((Cache.EnemiesCount[15] >= 5)) and Player:ComboPoints() >= 4) then
      if HR.Cast(S.CrimsonTempest) then return "crimson_tempest 202"; end
    end
    -- rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
    if S.Rupture:IsCastableP() then
      if HR.CastCycle(S.Rupture, 5, function(TargetUnit) return Player:ComboPoints() >= 4 and TargetUnit:DebuffRefreshableCP(S.RuptureDebuff) and (pmultiplier <= 1 or TargetUnit:DebuffRemainsP(S.RuptureDebuff) <= S.RuptureDebuff:TickTime()) and (not bool(exsanguinated) or TargetUnit:DebuffRemainsP(S.RuptureDebuff) <= S.RuptureDebuff:TickTime() * 2) and TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.RuptureDebuff) > 4 end) then return "rupture 266" end
    end
  end
  Stealthed = function()
    -- rupture,if=combo_points>=4&(talent.nightstalker.enabled|talent.subterfuge.enabled&talent.exsanguinate.enabled&spell_targets.fan_of_knives<2|!ticking)&target.time_to_die-remains>6
    if S.Rupture:IsCastableP() and (Player:ComboPoints() >= 4 and (S.Nightstalker:IsAvailable() or S.Subterfuge:IsAvailable() and S.Exsanguinate:IsAvailable() and Cache.EnemiesCount[10] < 2 or not Target:DebuffP(S.RuptureDebuff)) and Target:TimeToDie() - Target:DebuffRemainsP(S.RuptureDebuff) > 6) then
      if HR.Cast(S.Rupture) then return "rupture 267"; end
    end
    -- envenom,if=combo_points>=cp_max_spend
    if S.Envenom:IsCastableP() and (Player:ComboPoints() >= cp_max_spend) then
      if HR.Cast(S.Envenom) then return "envenom 287"; end
    end
    -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
    if S.Garrote:IsCastableP() then
      if HR.CastCycle(S.Garrote, 15, function(TargetUnit) return S.Subterfuge:IsAvailable() and TargetUnit:DebuffRefreshableCP(S.GarroteDebuff) and (not bool(exsanguinated) or TargetUnit:DebuffRemainsP(S.GarroteDebuff) <= S.GarroteDebuff:TickTime() * 2) and TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.GarroteDebuff) > 2 end) then return "garrote 319" end
    end
    -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
    if S.Garrote:IsCastableP() then
      if HR.CastCycle(S.Garrote, 15, function(TargetUnit) return S.Subterfuge:IsAvailable() and TargetUnit:DebuffRemainsP(S.GarroteDebuff) <= 10 and pmultiplier <= 1 and not bool(exsanguinated) and TargetUnit:TimeToDie() - TargetUnit:DebuffRemainsP(S.GarroteDebuff) > 2 end) then return "garrote 338" end
    end
    -- pool_resource,for_next=1
    -- garrote,if=talent.subterfuge.enabled&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&prev_gcd.1.rupture&dot.rupture.remains>5+4*cp_max_spend
    if S.Garrote:IsCastableP() and (S.Subterfuge:IsAvailable() and S.Exsanguinate:IsAvailable() and S.Exsanguinate:CooldownRemainsP() < 1 and Player:PrevGCDP(1, S.Rupture) and Target:DebuffRemainsP(S.RuptureDebuff) > 5 + 4 * cp_max_spend) then
      if S.Garrote:IsUsablePPool() then
        if HR.Cast(S.Garrote) then return "garrote 340"; end
      else
        if HR.Cast(S.PoolResource) then return "pool_resource 341"; end
      end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
    if (true) then
      VarEnergyRegenCombined = Player:EnergyRegen() + poisoned_bleeds * 7 / (2 * Player:SpellHaste())
    end
    -- call_action_list,name=stealthed,if=stealthed.rogue
    if (bool(stealthed.rogue)) then
      local ShouldReturn = Stealthed(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=dot
    if (true) then
      local ShouldReturn = Dot(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=direct
    if (true) then
      local ShouldReturn = Direct(); if ShouldReturn then return ShouldReturn; end
    end
    -- arcane_torrent,if=energy.deficit>=15+variable.energy_regen_combined
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:EnergyDeficitPredicted() >= 15 + VarEnergyRegenCombined) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 364"; end
    end
    -- arcane_pulse
    if S.ArcanePulse:IsCastableP() then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 368"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 370"; end
    end
  end
end

HR.SetAPL(259, APL)
