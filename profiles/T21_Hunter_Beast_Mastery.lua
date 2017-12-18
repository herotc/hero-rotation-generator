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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.BeastMastery = {
  SummonPet                             = Spell(),
  CounterShot                           = Spell(147362),
  UseItems                              = Spell(),
  ArcaneTorrent                         = Spell(50613),
  Berserking                            = Spell(26297),
  BestialWrathBuff                      = Spell(19574),
  BloodFury                             = Spell(20572),
  Volley                                = Spell(194386),
  AspectoftheWildBuff                   = Spell(193530),
  AMurderofCrows                        = Spell(131894),
  BestialWrath                          = Spell(19574),
  Stampede                              = Spell(201430),
  AspectoftheWild                       = Spell(193530),
  OneWiththePack                        = Spell(199528),
  KillCommand                           = Spell(34026),
  DireFrenzy                            = Spell(217200),
  DireFrenzyBuff                        = Spell(217200),
  CobraShot                             = Spell(193455),
  DireBeast                             = Spell(120679),
  TitansThunder                         = Spell(207068),
  Barrage                               = Spell(120360),
  Multishot                             = Spell(2643),
  BeastCleaveBuff                       = Spell(118455, "pet"),
  ChimaeraShot                          = Spell(53209),
  ParselsTongueBuff                     = Spell(248084)
};
local S = Spell.Hunter.BeastMastery;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.BeastMastery = {
  ProlongedPower                   = Item(142117),
  CalloftheWild                    = Item(137101),
  ConvergenceofFates               = Item(140806),
  QaplaEredunWarOrder              = Item(137227),
  RoaroftheSevenLions              = Item(137080),
  ParselsTongue                    = Item(151805)
};
local I = Item.Hunter.BeastMastery;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Hunter.Commons,
  BeastMastery = AR.GUISettings.APL.Hunter.BeastMastery
};

-- Variables

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
    -- summon_pet
    if S.SummonPet:IsCastableP() and (true) then
      if AR.Cast(S.SummonPet) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_shot
  -- counter_shot,if=target.debuff.casting.react
  if S.CounterShot:IsCastableP() and (Target:IsCasting()) then
    if AR.Cast(S.CounterShot) then return ""; end
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- arcane_torrent,if=focus.deficit>=30
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:FocusDeficit() >= 30) then
    if AR.Cast(S.ArcaneTorrent, Settings.BeastMastery.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- berserking,if=buff.bestial_wrath.remains>7&(!set_bonus.tier20_2pc|buff.bestial_wrath.remains<11)
  if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffRemainsP(S.BestialWrathBuff) > 7 and (not AC.Tier20_2Pc or Player:BuffRemainsP(S.BestialWrathBuff) < 11)) then
    if AR.Cast(S.Berserking, Settings.BeastMastery.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- blood_fury,if=buff.bestial_wrath.remains>7
  if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffRemainsP(S.BestialWrathBuff) > 7) then
    if AR.Cast(S.BloodFury, Settings.BeastMastery.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- volley,toggle=on
  if S.Volley:IsCastableP() and (true) then
    if AR.Cast(S.Volley) then return ""; end
  end
  -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.BestialWrathBuff) and Player:BuffP(S.AspectoftheWildBuff)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- a_murder_of_crows,if=cooldown.bestial_wrath.remains<3|target.time_to_die<16
  if S.AMurderofCrows:IsCastableP() and (S.BestialWrath:CooldownRemainsP() < 3 or Target:TimeToDie() < 16) then
    if AR.Cast(S.AMurderofCrows) then return ""; end
  end
  -- stampede,if=buff.bloodlust.up|buff.bestial_wrath.up|cooldown.bestial_wrath.remains<=2|target.time_to_die<=14
  if S.Stampede:IsCastableP() and (Player:HasHeroism() or Player:BuffP(S.BestialWrathBuff) or S.BestialWrath:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 14) then
    if AR.Cast(S.Stampede) then return ""; end
  end
  -- bestial_wrath,if=!buff.bestial_wrath.up
  if S.BestialWrath:IsCastableP() and (not Player:BuffP(S.BestialWrathBuff)) then
    if AR.Cast(S.BestialWrath) then return ""; end
  end
  -- aspect_of_the_wild,if=(equipped.call_of_the_wild&equipped.convergence_of_fates&talent.one_with_the_pack.enabled)|buff.bestial_wrath.remains>7|target.time_to_die<12
  if S.AspectoftheWild:IsCastableP() and ((I.CalloftheWild:IsEquipped() and I.ConvergenceofFates:IsEquipped() and S.OneWiththePack:IsAvailable()) or Player:BuffRemainsP(S.BestialWrathBuff) > 7 or Target:TimeToDie() < 12) then
    if AR.Cast(S.AspectoftheWild) then return ""; end
  end
  -- kill_command,target_if=min:bestial_ferocity.remains,if=!talent.dire_frenzy.enabled|(pet.cat.buff.dire_frenzy.remains>gcd.max*1.2|(!pet.cat.buff.dire_frenzy.up&!talent.one_with_the_pack.enabled))
  if S.KillCommand:IsCastableP() and (not S.DireFrenzy:IsAvailable() or (Pet:BuffRemainsP(S.DireFrenzyBuff) > Player:GCD() * 1.2 or (not Pet:BuffP(S.DireFrenzyBuff) and not S.OneWiththePack:IsAvailable()))) then
    if AR.Cast(S.KillCommand) then return ""; end
  end
  -- cobra_shot,if=set_bonus.tier20_2pc&spell_targets.multishot=1&!equipped.qapla_eredun_war_order&(buff.bestial_wrath.up&buff.bestial_wrath.remains<gcd.max*2)&(!talent.dire_frenzy.enabled|pet.cat.buff.dire_frenzy.remains>gcd.max*1.2)
  if S.CobraShot:IsCastableP() and (AC.Tier20_2Pc and Cache.EnemiesCount[40] == 1 and not I.QaplaEredunWarOrder:IsEquipped() and (Player:BuffP(S.BestialWrathBuff) and Player:BuffRemainsP(S.BestialWrathBuff) < Player:GCD() * 2) and (not S.DireFrenzy:IsAvailable() or Pet:BuffRemainsP(S.DireFrenzyBuff) > Player:GCD() * 1.2)) then
    if AR.Cast(S.CobraShot) then return ""; end
  end
  -- dire_beast,if=cooldown.bestial_wrath.remains>2&((!equipped.qapla_eredun_war_order|cooldown.kill_command.remains>=1)|full_recharge_time<gcd.max|cooldown.titans_thunder.up|spell_targets>1)
  if S.DireBeast:IsCastableP() and (S.BestialWrath:CooldownRemainsP() > 2 and ((not I.QaplaEredunWarOrder:IsEquipped() or S.KillCommand:CooldownRemainsP() >= 1) or S.DireBeast:FullRechargeTimeP() < Player:GCD() or S.TitansThunder:CooldownUpP() or Cache.EnemiesCount[40] > 1)) then
    if AR.Cast(S.DireBeast) then return ""; end
  end
  -- titans_thunder,if=buff.bestial_wrath.up
  if S.TitansThunder:IsCastableP() and (Player:BuffP(S.BestialWrathBuff)) then
    if AR.Cast(S.TitansThunder) then return ""; end
  end
  -- dire_frenzy,if=pet.cat.buff.dire_frenzy.remains<=gcd.max*1.2|(talent.one_with_the_pack.enabled&(cooldown.bestial_wrath.remains>3&charges_fractional>1.2))|full_recharge_time<gcd.max|target.time_to_die<9
  if S.DireFrenzy:IsCastableP() and (Pet:BuffRemainsP(S.DireFrenzyBuff) <= Player:GCD() * 1.2 or (S.OneWiththePack:IsAvailable() and (S.BestialWrath:CooldownRemainsP() > 3 and S.DireFrenzy:ChargesFractional() > 1.2)) or S.DireFrenzy:FullRechargeTimeP() < Player:GCD() or Target:TimeToDie() < 9) then
    if AR.Cast(S.DireFrenzy) then return ""; end
  end
  -- barrage,if=spell_targets.barrage>1
  if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
    if AR.Cast(S.Barrage) then return ""; end
  end
  -- multishot,if=spell_targets>4&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
  if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 4 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
    if AR.Cast(S.Multishot) then return ""; end
  end
  -- kill_command
  if S.KillCommand:IsCastableP() and (true) then
    if AR.Cast(S.KillCommand) then return ""; end
  end
  -- multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
  if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
    if AR.Cast(S.Multishot) then return ""; end
  end
  -- chimaera_shot,if=focus<90
  if S.ChimaeraShot:IsCastableP() and (Player:Focus() < 90) then
    if AR.Cast(S.ChimaeraShot) then return ""; end
  end
  -- cobra_shot,if=equipped.roar_of_the_seven_lions&spell_targets.multishot=1&(cooldown.kill_command.remains>focus.time_to_max*0.85&cooldown.bestial_wrath.remains>focus.time_to_max*0.85)
  if S.CobraShot:IsCastableP() and (I.RoaroftheSevenLions:IsEquipped() and Cache.EnemiesCount[40] == 1 and (S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted() * 0.85 and S.BestialWrath:CooldownRemainsP() > Player:FocusTimeToMaxPredicted() * 0.85)) then
    if AR.Cast(S.CobraShot) then return ""; end
  end
  -- cobra_shot,if=(cooldown.kill_command.remains>focus.time_to_max&cooldown.bestial_wrath.remains>focus.time_to_max)|(buff.bestial_wrath.up&(spell_targets.multishot=1|focus.regen*cooldown.kill_command.remains>action.kill_command.cost))|target.time_to_die<cooldown.kill_command.remains|(equipped.parsels_tongue&buff.parsels_tongue.remains<=gcd.max*2)
  if S.CobraShot:IsCastableP() and ((S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted() and S.BestialWrath:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) or (Player:BuffP(S.BestialWrathBuff) and (Cache.EnemiesCount[40] == 1 or Player:FocusRegen() * S.KillCommand:CooldownRemainsP() > S.KillCommand:Cost())) or Target:TimeToDie() < S.KillCommand:CooldownRemainsP() or (I.ParselsTongue:IsEquipped() and Player:BuffRemainsP(S.ParselsTongueBuff) <= Player:GCD() * 2)) then
    if AR.Cast(S.CobraShot) then return ""; end
  end
  -- dire_beast,if=buff.bestial_wrath.up
  if S.DireBeast:IsCastableP() and (Player:BuffP(S.BestialWrathBuff)) then
    if AR.Cast(S.DireBeast) then return ""; end
  end
end

AR.SetAPL(253, APL)
