--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC =     AethysCore
local Cache =  AethysCache
local Unit =   AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet =    Unit.Pet
local Spell =  AC.Spell
local Item =   AC.Item
-- AethysRotation
local AR =     AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Rogue then Spell.Rogue = {} end
Spell.Rogue.Outlaw = {
  BladeFlurryBuff                       = Spell(),
  BladeFlurry                           = Spell(),
  GhostlyStrike                         = Spell(),
  BroadsidesBuff                        = Spell(),
  PistolShot                            = Spell(),
  QuickDraw                             = Spell(),
  OpportunityBuff                       = Spell(),
  GreenskinsWaterloggedWristcuffsBuff   = Spell(),
  BlunderbussBuff                       = Spell(),
  SaberSlash                            = Spell(),
  AdrenalineRushBuff                    = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  CannonballBarrage                     = Spell(),
  AdrenalineRush                        = Spell(),
  MarkedForDeath                        = Spell(),
  TrueBearingBuff                       = Spell(),
  Sprint                                = Spell(),
  DeathFromAbove                        = Spell(),
  Darkflight                            = Spell(),
  SprintBuff                            = Spell(),
  CurseoftheDreadblades                 = Spell(),
  BetweentheEyes                        = Spell(),
  RunThrough                            = Spell(),
  GhostlyStrikeDebuff                   = Spell(),
  JollyRogerBuff                        = Spell(),
  HiddenBladeBuff                       = Spell(),
  Ambush                                = Spell(),
  Vanish                                = Spell(),
  Shadowmeld                            = Spell(58984),
  SliceandDice                          = Spell(),
  LoadedDiceBuff                        = Spell(),
  DeeperStratagem                       = Spell(),
  Anticipation                          = Spell(),
  DeathFromAboveBuff                    = Spell(),
  SliceandDiceBuff                      = Spell(),
  RolltheBones                          = Spell(),
  RolltheBonesBuff                      = Spell(),
  KillingSpree                          = Spell(),
  Gouge                                 = Spell(),
  DirtyTricks                           = Spell()
};
local S = Spell.Rogue.Outlaw;

-- Items
if not Item.Rogue then Item.Rogue = {} end
Item.Rogue.Outlaw = {
  ShivarranSymmetry             = Item(),
  ProlongedPower                = Item(142117),
  ThraxisTricksyTreads          = Item(),
  GreenskinsWaterloggedWristcuffs= Item(),
  MantleoftheMasterAssassin     = Item()
};
local I = Item.Rogue.Outlaw;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Rogue.Commons,
  Outlaw = AR.GUISettings.APL.Rogue.Outlaw
};

-- Variables
local AmbushCondition = 0;
local RtbReroll = 0;
local SsUseableNoreroll = 0;
local SsUseable = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Bf()
    -- cancel_buff,name=blade_flurry,if=spell_targets.blade_flurry<2&buff.blade_flurry.up
    if (spell_targets.blade_flurry < 2 and Player:BuffP(S.BladeFlurryBuff)) then
      -- if AR.Cancel(S.BladeFlurryBuff) then return ""; end
    end
    -- cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2
    if (I.ShivarranSymmetry:IsEquipped() and S.BladeFlurry:CooldownUpP() and Player:BuffP(S.BladeFlurryBuff) and spell_targets.blade_flurry >= 2) then
      -- if AR.Cancel(S.BladeFlurryBuff) then return ""; end
    end
    -- blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
    if S.BladeFlurry:IsCastableP() and (spell_targets.blade_flurry >= 2 and not Player:BuffP(S.BladeFlurryBuff)) then
      if AR.Cast(S.BladeFlurry) then return ""; end
    end
  end
  local function Build()
    -- ghostly_strike,if=combo_points.deficit>=1+buff.broadsides.up&refreshable
    if S.GhostlyStrike:IsCastableP() and (combo_points.deficit >= 1 + num(Player:BuffP(S.BroadsidesBuff)) and bool(refreshable)) then
      if AR.Cast(S.GhostlyStrike) then return ""; end
    end
    -- pistol_shot,if=combo_points.deficit>=1+buff.broadsides.up+talent.quick_draw.enabled&buff.opportunity.up&(energy.time_to_max>2-talent.quick_draw.enabled|(buff.greenskins_waterlogged_wristcuffs.up&(buff.blunderbuss.up|buff.greenskins_waterlogged_wristcuffs.remains<2)))
    if S.PistolShot:IsCastableP() and (combo_points.deficit >= 1 + num(Player:BuffP(S.BroadsidesBuff)) + num(S.QuickDraw:IsAvailable()) and Player:BuffP(S.OpportunityBuff) and (energy.time_to_max > 2 - num(S.QuickDraw:IsAvailable()) or (Player:BuffP(S.GreenskinsWaterloggedWristcuffsBuff) and (Player:BuffP(S.BlunderbussBuff) or Player:BuffRemainsP(S.GreenskinsWaterloggedWristcuffsBuff) < 2)))) then
      if AR.Cast(S.PistolShot) then return ""; end
    end
    -- saber_slash,if=variable.ss_useable
    if S.SaberSlash:IsCastableP() and (bool(SsUseable)) then
      if AR.Cast(S.SaberSlash) then return ""; end
    end
  end
  local function Cds()
    -- potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 60 or Player:BuffP(S.AdrenalineRushBuff)) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.BloodFury, Settings.Outlaw.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Outlaw.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- arcane_torrent,if=energy.deficit>40
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (energy.deficit > 40) then
      if AR.Cast(S.ArcaneTorrent, Settings.Outlaw.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- cannonball_barrage,if=spell_targets.cannonball_barrage>=1
    if S.CannonballBarrage:IsCastableP() and (spell_targets.cannonball_barrage >= 1) then
      if AR.Cast(S.CannonballBarrage) then return ""; end
    end
    -- adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
    if S.AdrenalineRush:IsCastableP() and (not Player:BuffP(S.AdrenalineRushBuff) and energy.deficit > 0) then
      if AR.Cast(S.AdrenalineRush) then return ""; end
    end
    -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
    if S.MarkedForDeath:IsCastableP() and (Target:TimeToDie() < combo_points.deficit or ((raid_event.adds.in > 40 or Player:BuffRemainsP(S.TrueBearingBuff) > 15 - num(Player:BuffP(S.AdrenalineRushBuff)) * 5) and not bool(stealthed.rogue) and combo_points.deficit >= cp_max_spend - 1)) then
      if AR.Cast(S.MarkedForDeath) then return ""; end
    end
    -- sprint,if=!talent.death_from_above.enabled&equipped.thraxis_tricksy_treads&!variable.ss_useable
    if S.Sprint:IsCastableP() and (not S.DeathFromAbove:IsAvailable() and I.ThraxisTricksyTreads:IsEquipped() and not bool(SsUseable)) then
      if AR.Cast(S.Sprint) then return ""; end
    end
    -- darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
    if S.Darkflight:IsCastableP() and (I.ThraxisTricksyTreads:IsEquipped() and not bool(SsUseable) and Player:BuffDownP(S.SprintBuff)) then
      if AR.Cast(S.Darkflight) then return ""; end
    end
    -- curse_of_the_dreadblades,if=combo_points.deficit>=4&(buff.true_bearing.up|buff.adrenaline_rush.up|time_to_die<20)
    if S.CurseoftheDreadblades:IsCastableP() and (combo_points.deficit >= 4 and (Player:BuffP(S.TrueBearingBuff) or Player:BuffP(S.AdrenalineRushBuff) or time_to_die < 20)) then
      if AR.Cast(S.CurseoftheDreadblades) then return ""; end
    end
  end
  local function Finish()
    -- between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
    if S.BetweentheEyes:IsCastableP() and (I.GreenskinsWaterloggedWristcuffs:IsEquipped() and not Player:BuffP(S.GreenskinsWaterloggedWristcuffsBuff)) then
      if AR.Cast(S.BetweentheEyes) then return ""; end
    end
    -- run_through,if=!talent.death_from_above.enabled|energy.time_to_max<cooldown.death_from_above.remains+3.5
    if S.RunThrough:IsCastableP() and (not S.DeathFromAbove:IsAvailable() or energy.time_to_max < S.DeathFromAbove:CooldownRemainsP() + 3.5) then
      if AR.Cast(S.RunThrough) then return ""; end
    end
  end
  local function Stealth()
    -- variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up
    if (true) then
      AmbushCondition = num(combo_points.deficit >= 2 + 2 * num((S.GhostlyStrike:IsAvailable() and not Target:DebuffP(S.GhostlyStrikeDebuff))) + num(Player:BuffP(S.BroadsidesBuff)) and energy > 60 and not Player:BuffP(S.JollyRogerBuff) and not Player:BuffP(S.HiddenBladeBuff))
    end
    -- ambush,if=variable.ambush_condition
    if S.Ambush:IsCastableP() and (bool(AmbushCondition)) then
      if AR.Cast(S.Ambush) then return ""; end
    end
    -- vanish,if=(variable.ambush_condition|equipped.mantle_of_the_master_assassin&!variable.rtb_reroll&!variable.ss_useable)&mantle_duration=0
    if S.Vanish:IsCastableP() and ((bool(AmbushCondition) or I.MantleoftheMasterAssassin:IsEquipped() and not bool(RtbReroll) and not bool(SsUseable)) and mantle_duration == 0) then
      if AR.Cast(S.Vanish) then return ""; end
    end
    -- shadowmeld,if=variable.ambush_condition
    if S.Shadowmeld:IsCastableP() and (bool(AmbushCondition)) then
      if AR.Cast(S.Shadowmeld) then return ""; end
    end
  end
  -- variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&buff.loaded_dice.up&(rtb_buffs<2|(rtb_buffs<4&!buff.true_bearing.up))
  if (true) then
    RtbReroll = num(not S.SliceandDice:IsAvailable() and Player:BuffP(S.LoadedDiceBuff) and (rtb_buffs < 2 or (rtb_buffs < 4 and not Player:BuffP(S.TrueBearingBuff))))
  end
  -- variable,name=ss_useable_noreroll,value=(combo_points<4+talent.deeper_stratagem.enabled)
  if (true) then
    SsUseableNoreroll = num((combo_points < 4 + num(S.DeeperStratagem:IsAvailable())))
  end
  -- variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<5)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
  if (true) then
    SsUseable = num((S.Anticipation:IsAvailable() and combo_points < 5) or (not S.Anticipation:IsAvailable() and ((bool(RtbReroll) and combo_points < 4 + num(S.DeeperStratagem:IsAvailable())) or (not bool(RtbReroll) and bool(SsUseableNoreroll)))))
  end
  -- call_action_list,name=bf
  if (true) then
    local ShouldReturn = Bf(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=cds
  if (true) then
    local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
  if (bool(stealthed.rogue) or S.Vanish:CooldownUpP() or S.Shadowmeld:CooldownUpP()) then
    local ShouldReturn = Stealth(); if ShouldReturn then return ShouldReturn; end
  end
  -- death_from_above,if=energy.time_to_max>2&!variable.ss_useable_noreroll
  if S.DeathFromAbove:IsCastableP() and (energy.time_to_max > 2 and not bool(SsUseableNoreroll)) then
    if AR.Cast(S.DeathFromAbove) then return ""; end
  end
  -- sprint,if=equipped.thraxis_tricksy_treads&buff.death_from_above.up&buff.death_from_above.remains<=0.15
  if S.Sprint:IsCastableP() and (I.ThraxisTricksyTreads:IsEquipped() and Player:BuffP(S.DeathFromAboveBuff) and Player:BuffRemainsP(S.DeathFromAboveBuff) <= 0.15) then
    if AR.Cast(S.Sprint) then return ""; end
  end
  -- adrenaline_rush,if=buff.death_from_above.up&buff.death_from_above.remains<=0.15
  if S.AdrenalineRush:IsCastableP() and (Player:BuffP(S.DeathFromAboveBuff) and Player:BuffRemainsP(S.DeathFromAboveBuff) <= 0.15) then
    if AR.Cast(S.AdrenalineRush) then return ""; end
  end
  -- slice_and_dice,if=!variable.ss_useable&buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8&!buff.slice_and_dice.improved&!buff.loaded_dice.up
  if S.SliceandDice:IsCastableP() and (not bool(SsUseable) and Player:BuffRemainsP(S.SliceandDiceBuff) < Target:TimeToDie() and Player:BuffRemainsP(S.SliceandDiceBuff) < (1 + combo_points) * 1.8 and not bool(buff.slice_and_dice.improved) and not Player:BuffP(S.LoadedDiceBuff)) then
    if AR.Cast(S.SliceandDice) then return ""; end
  end
  -- slice_and_dice,if=buff.loaded_dice.up&combo_points>=cp_max_spend&(!buff.slice_and_dice.improved|buff.slice_and_dice.remains<4)
  if S.SliceandDice:IsCastableP() and (Player:BuffP(S.LoadedDiceBuff) and combo_points >= cp_max_spend and (not bool(buff.slice_and_dice.improved) or Player:BuffRemainsP(S.SliceandDiceBuff) < 4)) then
    if AR.Cast(S.SliceandDice) then return ""; end
  end
  -- slice_and_dice,if=buff.slice_and_dice.improved&buff.slice_and_dice.remains<=2&combo_points>=2&!buff.loaded_dice.up
  if S.SliceandDice:IsCastableP() and (bool(buff.slice_and_dice.improved) and Player:BuffRemainsP(S.SliceandDiceBuff) <= 2 and combo_points >= 2 and not Player:BuffP(S.LoadedDiceBuff)) then
    if AR.Cast(S.SliceandDice) then return ""; end
  end
  -- roll_the_bones,if=!variable.ss_useable&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
  if S.RolltheBones:IsCastableP() and (not bool(SsUseable) and (Target:TimeToDie() > 20 or Player:BuffRemainsP(S.RolltheBonesBuff) < Target:TimeToDie()) and (Player:BuffRemainsP(S.RolltheBonesBuff) <= 3 or bool(RtbReroll))) then
    if AR.Cast(S.RolltheBones) then return ""; end
  end
  -- killing_spree,if=energy.time_to_max>5|energy<15
  if S.KillingSpree:IsCastableP() and (energy.time_to_max > 5 or energy < 15) then
    if AR.Cast(S.KillingSpree) then return ""; end
  end
  -- call_action_list,name=build
  if (true) then
    local ShouldReturn = Build(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=finish,if=!variable.ss_useable
  if (not bool(SsUseable)) then
    local ShouldReturn = Finish(); if ShouldReturn then return ShouldReturn; end
  end
  -- gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
  if S.Gouge:IsCastableP() and (S.DirtyTricks:IsAvailable() and combo_points.deficit >= 1) then
    if AR.Cast(S.Gouge) then return ""; end
  end
end