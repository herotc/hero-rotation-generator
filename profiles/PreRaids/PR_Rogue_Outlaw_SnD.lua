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
Spell.Rogue.Outlaw = {
  Stealth                               = Spell(),
  MarkedForDeath                        = Spell(137619),
  RolltheBones                          = Spell(193316),
  SliceandDiceBuff                      = Spell(5171),
  SliceandDice                          = Spell(5171),
  AdrenalineRushBuff                    = Spell(13750),
  AdrenalineRush                        = Spell(13750),
  PistolShot                            = Spell(185763),
  BroadsideBuff                         = Spell(),
  QuickDraw                             = Spell(196938),
  OpportunityBuff                       = Spell(195627),
  SinisterStrike                        = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BladeFlurry                           = Spell(13877),
  BladeFlurryBuff                       = Spell(13877),
  GhostlyStrike                         = Spell(196937),
  KillingSpree                          = Spell(51690),
  BladeRush                             = Spell(),
  Vanish                                = Spell(1856),
  Shadowmeld                            = Spell(58984),
  BetweentheEyes                        = Spell(199804),
  RuthlessPrecisionBuff                 = Spell(),
  Deadshot                              = Spell(),
  AceUpYourSleeve                       = Spell(),
  RolltheBonesBuff                      = Spell(),
  Dispatch                              = Spell(),
  Ambush                                = Spell(8676),
  LoadedDiceBuff                        = Spell(240837),
  GrandMeleeBuff                        = Spell(),
  SnakeEyes                             = Spell(),
  SnakeEyesBuff                         = Spell(),
  SkullandCrossbonesBuff                = Spell(),
  ArcaneTorrent                         = Spell(50613),
  ArcanePulse                           = Spell(),
  LightsJudgment                        = Spell(255647)
};
local S = Spell.Rogue.Outlaw;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Outlaw = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Rogue.Outlaw;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Rogue.Commons,
  Outlaw = HR.GUISettings.APL.Rogue.Outlaw
};

-- Variables
local VarBladeFlurrySync = 0;
local VarAmbushCondition = 0;
local VarRtbReroll = 0;

local EnemyRanges = {35, 8}
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
  local Precombat, Build, Cds, Finish, Stealth
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- stealth
    if S.Stealth:IsCastableP() then
      if HR.Cast(S.Stealth) then return "stealth 6908"; end
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 6910"; end
    end
    -- marked_for_death,precombat_seconds=5,if=raid_event.adds.in>40
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 40) then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 6912"; end
    end
    -- roll_the_bones,precombat_seconds=2
    if S.RolltheBones:IsCastableP() then
      if HR.Cast(S.RolltheBones) then return "roll_the_bones 6914"; end
    end
    -- slice_and_dice,precombat_seconds=2
    if S.SliceandDice:IsCastableP() and Player:BuffDownP(S.SliceandDiceBuff) then
      if HR.Cast(S.SliceandDice) then return "slice_and_dice 6916"; end
    end
    -- adrenaline_rush,precombat_seconds=1
    if S.AdrenalineRush:IsCastableP() and Player:BuffDownP(S.AdrenalineRushBuff) then
      if HR.Cast(S.AdrenalineRush) then return "adrenaline_rush 6920"; end
    end
  end
  Build = function()
    -- pistol_shot,if=combo_points.deficit>=1+buff.broadside.up+talent.quick_draw.enabled&buff.opportunity.up
    if S.PistolShot:IsCastableP() and (Player:ComboPointsDeficit() >= 1 + num(Player:BuffP(S.BroadsideBuff)) + num(S.QuickDraw:IsAvailable()) and Player:BuffP(S.OpportunityBuff)) then
      if HR.Cast(S.PistolShot) then return "pistol_shot 6924"; end
    end
    -- sinister_strike
    if S.SinisterStrike:IsCastableP() then
      if HR.Cast(S.SinisterStrike) then return "sinister_strike 6932"; end
    end
  end
  Cds = function()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or Player:BuffP(S.AdrenalineRushBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 6934"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 6938"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 6940"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 6942"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 6944"; end
    end
    -- adrenaline_rush,if=!buff.adrenaline_rush.up&energy.time_to_max>1
    if S.AdrenalineRush:IsCastableP() and (not Player:BuffP(S.AdrenalineRushBuff) and Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.AdrenalineRush) then return "adrenaline_rush 6946"; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit|!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
    if S.MarkedForDeath:IsCastableP() and (bool(min:target.time_to_die)) and ((Cache.EnemiesCount[35] > 1) and (Target:TimeToDie() < Player:ComboPointsDeficit() or not bool(stealthed.rogue) and Player:ComboPointsDeficit() >= cp_max_spend - 1)) then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 6950"; end
    end
    -- marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1
    if S.MarkedForDeath:IsCastableP() and (10000000000 > 30 - raid_event.adds.duration and not bool(stealthed.rogue) and Player:ComboPointsDeficit() >= cp_max_spend - 1) then
      if HR.Cast(S.MarkedForDeath) then return "marked_for_death 6954"; end
    end
    -- blade_flurry,if=spell_targets>=2&!buff.blade_flurry.up&(!raid_event.adds.exists|raid_event.adds.remains>8|raid_event.adds.in>(2-cooldown.blade_flurry.charges_fractional)*25)
    if S.BladeFlurry:IsCastableP() and (Cache.EnemiesCount[8] >= 2 and not Player:BuffP(S.BladeFlurryBuff) and (not (Cache.EnemiesCount[8] > 1) or 0 > 8 or 10000000000 > (2 - S.BladeFlurry:ChargesFractionalP()) * 25)) then
      if HR.Cast(S.BladeFlurry) then return "blade_flurry 6956"; end
    end
    -- ghostly_strike,if=variable.blade_flurry_sync&combo_points.deficit>=1+buff.broadside.up
    if S.GhostlyStrike:IsCastableP() and (bool(VarBladeFlurrySync) and Player:ComboPointsDeficit() >= 1 + num(Player:BuffP(S.BroadsideBuff))) then
      if HR.Cast(S.GhostlyStrike) then return "ghostly_strike 6972"; end
    end
    -- killing_spree,if=variable.blade_flurry_sync&(energy.time_to_max>5|energy<15)
    if S.KillingSpree:IsCastableP() and (bool(VarBladeFlurrySync) and (Player:EnergyTimeToMaxPredicted() > 5 or Player:EnergyPredicted() < 15)) then
      if HR.Cast(S.KillingSpree) then return "killing_spree 6978"; end
    end
    -- blade_rush,if=variable.blade_flurry_sync&energy.time_to_max>1
    if S.BladeRush:IsCastableP() and (bool(VarBladeFlurrySync) and Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.BladeRush) then return "blade_rush 6982"; end
    end
    -- vanish,if=!stealthed.all&variable.ambush_condition
    if S.Vanish:IsCastableP() and (not bool(stealthed.all) and bool(VarAmbushCondition)) then
      if HR.Cast(S.Vanish) then return "vanish 6986"; end
    end
    -- shadowmeld,if=!stealthed.all&variable.ambush_condition
    if S.Shadowmeld:IsCastableP() and HR.CDsON() and (not bool(stealthed.all) and bool(VarAmbushCondition)) then
      if HR.Cast(S.Shadowmeld, Settings.Commons.OffGCDasOffGCD.Racials) then return "shadowmeld 6990"; end
    end
  end
  Finish = function()
    -- between_the_eyes,if=buff.ruthless_precision.up|(azerite.deadshot.enabled|azerite.ace_up_your_sleeve.enabled)&buff.roll_the_bones.up
    if S.BetweentheEyes:IsCastableP() and (Player:BuffP(S.RuthlessPrecisionBuff) or (S.Deadshot:AzeriteEnabled() or S.AceUpYourSleeve:AzeriteEnabled()) and Player:BuffP(S.RolltheBonesBuff)) then
      if HR.Cast(S.BetweentheEyes) then return "between_the_eyes 6994"; end
    end
    -- slice_and_dice,if=buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8
    if S.SliceandDice:IsCastableP() and (Player:BuffRemainsP(S.SliceandDiceBuff) < Target:TimeToDie() and Player:BuffRemainsP(S.SliceandDiceBuff) < (1 + Player:ComboPoints()) * 1.8) then
      if HR.Cast(S.SliceandDice) then return "slice_and_dice 7004"; end
    end
    -- roll_the_bones,if=(buff.roll_the_bones.remains<=3|variable.rtb_reroll)&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)
    if S.RolltheBones:IsCastableP() and ((Player:BuffRemainsP(S.RolltheBonesBuff) <= 3 or bool(VarRtbReroll)) and (Target:TimeToDie() > 20 or Player:BuffRemainsP(S.RolltheBonesBuff) < Target:TimeToDie())) then
      if HR.Cast(S.RolltheBones) then return "roll_the_bones 7010"; end
    end
    -- between_the_eyes,if=azerite.ace_up_your_sleeve.enabled|azerite.deadshot.enabled
    if S.BetweentheEyes:IsCastableP() and (S.AceUpYourSleeve:AzeriteEnabled() or S.Deadshot:AzeriteEnabled()) then
      if HR.Cast(S.BetweentheEyes) then return "between_the_eyes 7018"; end
    end
    -- dispatch
    if S.Dispatch:IsCastableP() then
      if HR.Cast(S.Dispatch) then return "dispatch 7024"; end
    end
  end
  Stealth = function()
    -- ambush
    if S.Ambush:IsCastableP() then
      if HR.Cast(S.Ambush) then return "ambush 7026"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- stealth
    if S.Stealth:IsCastableP() then
      if HR.Cast(S.Stealth) then return "stealth 7029"; end
    end
    -- variable,name=rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
    if (true) then
      VarRtbReroll = num(rtb_buffs < 2 and (Player:BuffP(S.LoadedDiceBuff) or not Player:BuffP(S.GrandMeleeBuff) and not Player:BuffP(S.RuthlessPrecisionBuff)))
    end
    -- variable,name=rtb_reroll,op=set,if=azerite.deadshot.enabled|azerite.ace_up_your_sleeve.enabled,value=rtb_buffs<2&(buff.loaded_dice.up|buff.ruthless_precision.remains<=cooldown.between_the_eyes.remains)
    if (S.Deadshot:AzeriteEnabled() or S.AceUpYourSleeve:AzeriteEnabled()) then
      VarRtbReroll = num(rtb_buffs < 2 and (Player:BuffP(S.LoadedDiceBuff) or Player:BuffRemainsP(S.RuthlessPrecisionBuff) <= S.BetweentheEyes:CooldownRemainsP()))
    end
    -- variable,name=rtb_reroll,op=set,if=azerite.snake_eyes.enabled,value=rtb_buffs<2|(azerite.snake_eyes.rank=3&rtb_buffs<5)
    if (S.SnakeEyes:AzeriteEnabled()) then
      VarRtbReroll = num(rtb_buffs < 2 or (S.SnakeEyes:AzeriteRank() == 3 and rtb_buffs < 5))
    end
    -- variable,name=rtb_reroll,op=reset,if=azerite.snake_eyes.rank>=2&buff.snake_eyes.stack>=2-buff.broadside.up
    if (S.SnakeEyes:AzeriteRank() >= 2 and Player:BuffStackP(S.SnakeEyesBuff) >= 2 - num(Player:BuffP(S.BroadsideBuff))) then
      VarRtbReroll = 0
    end
    -- variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
    if (true) then
      VarAmbushCondition = num(Player:ComboPointsDeficit() >= 2 + 2 * num((S.GhostlyStrike:IsAvailable() and S.GhostlyStrike:CooldownRemainsP() < 1)) + num(Player:BuffP(S.BroadsideBuff)) and Player:EnergyPredicted() > 60 and not Player:BuffP(S.SkullandCrossbonesBuff))
    end
    -- variable,name=blade_flurry_sync,value=spell_targets.blade_flurry<2&raid_event.adds.in>20|buff.blade_flurry.up
    if (true) then
      VarBladeFlurrySync = num(Cache.EnemiesCount[8] < 2 and 10000000000 > 20 or Player:BuffP(S.BladeFlurryBuff))
    end
    -- call_action_list,name=stealth,if=stealthed.all
    if (bool(stealthed.all)) then
      local ShouldReturn = Stealth(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))
    if (Player:ComboPoints() >= cp_max_spend - (num(Player:BuffP(S.BroadsideBuff)) + num(Player:BuffP(S.OpportunityBuff))) * num((S.QuickDraw:IsAvailable() and (not S.MarkedForDeath:IsAvailable() or S.MarkedForDeath:CooldownRemainsP() > 1)))) then
      local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=build
    if (true) then
      local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
    end
    -- arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:EnergyDeficitPredicted() >= 15 + Player:EnergyRegen()) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 7098"; end
    end
    -- arcane_pulse
    if S.ArcanePulse:IsCastableP() then
      if HR.Cast(S.ArcanePulse) then return "arcane_pulse 7100"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 7102"; end
    end
  end
end

HR.SetAPL(260, APL)
