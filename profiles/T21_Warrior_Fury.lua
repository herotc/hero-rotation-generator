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
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Fury = {
  Bloodthirst                           = Spell(),
  EnrageBuff                            = Spell(),
  Bladestorm                            = Spell(),
  Whirlwind                             = Spell(),
  MeatCleaverBuff                       = Spell(),
  Rampage                               = Spell(),
  FrothingBerserker                     = Spell(),
  MassacreBuff                          = Spell(),
  Execute                               = Spell(),
  RagingBlow                            = Spell(),
  InnerRage                             = Spell(),
  OdynsFury                             = Spell(),
  BerserkerRage                         = Spell(),
  Outburst                              = Spell(),
  BattleCryBuff                         = Spell(),
  WreckingBallBuff                      = Spell(),
  FuriousSlash                          = Spell(),
  FujiedasFuryBuff                      = Spell(),
  Juggernaut                            = Spell(),
  JuggernautBuff                        = Spell(),
  StoneHeartBuff                        = Spell(),
  Frenzy                                = Spell(),
  FrenzyBuff                            = Spell(),
  HeroicLeap                            = Spell(),
  BattleCry                             = Spell(),
  Bloodbath                             = Spell(),
  Carnage                               = Spell(),
  Charge                                = Spell(),
  AvatarBuff                            = Spell(),
  Avatar                                = Spell(),
  DragonRoar                            = Spell(),
  BloodbathBuff                         = Spell(),
  UseItem                               = Spell(),
  RecklessAbandon                       = Spell(),
  DragonRoarBuff                        = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613)
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  OldWar                           = Item(127844),
  ConvergenceofFates               = Item(140806),
  UmbralMoonglaives                = Item(),
  KazzalaxFujiedasFury             = Item()
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Warrior.Commons,
  Fury = AR.GUISettings.APL.Warrior.Fury
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Aoe()
    -- bloodthirst,if=buff.enrage.down|rage<90
    if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff) or rage < 90) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- bladestorm,if=buff.enrage.remains>2&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
    if S.Bladestorm:IsCastableP() and (Player:BuffRemainsP(S.EnrageBuff) > 2 and (raid_event.adds.in > 90 or not bool(raid_event.adds.exists) or Cache.EnemiesCount[0] > desired_targets)) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
    -- whirlwind,if=buff.meat_cleaver.down
    if S.Whirlwind:IsCastableP() and (Player:BuffDownP(S.MeatCleaverBuff)) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- rampage,if=buff.meat_cleaver.up&(buff.enrage.down&!talent.frothing_berserker.enabled|buff.massacre.react|rage>=100)
    if S.Rampage:IsCastableP() and (Player:BuffP(S.MeatCleaverBuff) and (Player:BuffDownP(S.EnrageBuff) and not S.FrothingBerserker:IsAvailable() or bool(Player:BuffStackP(S.MassacreBuff)) or rage >= 100)) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() and (true) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
  end
  local function Cooldowns()
    -- rampage,if=buff.massacre.react&buff.enrage.remains<1
    if S.Rampage:IsCastableP() and (bool(Player:BuffStackP(S.MassacreBuff)) and Player:BuffRemainsP(S.EnrageBuff) < 1) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- bloodthirst,if=target.health.pct<20&buff.enrage.remains<1
    if S.Bloodthirst:IsCastableP() and (Target:HealthPercentage() < 20 and Player:BuffRemainsP(S.EnrageBuff) < 1) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- execute
    if S.Execute:IsCastableP() and (true) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- raging_blow,if=talent.inner_rage.enabled&buff.enrage.up
    if S.RagingBlow:IsCastableP() and (S.InnerRage:IsAvailable() and Player:BuffP(S.EnrageBuff)) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- rampage,if=(rage>=100&talent.frothing_berserker.enabled&!set_bonus.tier21_4pc)|set_bonus.tier21_4pc|!talent.frothing_berserker.enabled
    if S.Rampage:IsCastableP() and ((rage >= 100 and S.FrothingBerserker:IsAvailable() and not AC.Tier21_4Pc) or AC.Tier21_4Pc or not S.FrothingBerserker:IsAvailable()) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- odyns_fury,if=buff.enrage.up&(cooldown.raging_blow.remains>0|!talent.inner_rage.enabled)
    if S.OdynsFury:IsCastableP() and (Player:BuffP(S.EnrageBuff) and (S.RagingBlow:CooldownRemainsP() > 0 or not S.InnerRage:IsAvailable())) then
      if AR.Cast(S.OdynsFury) then return ""; end
    end
    -- berserker_rage,if=talent.outburst.enabled&buff.enrage.down&buff.battle_cry.up
    if S.BerserkerRage:IsCastableP() and (S.Outburst:IsAvailable() and Player:BuffDownP(S.EnrageBuff) and Player:BuffP(S.BattleCryBuff)) then
      if AR.Cast(S.BerserkerRage) then return ""; end
    end
    -- bloodthirst,if=(buff.enrage.remains<1&!talent.outburst.enabled)|!talent.inner_rage.enabled
    if S.Bloodthirst:IsCastableP() and ((Player:BuffRemainsP(S.EnrageBuff) < 1 and not S.Outburst:IsAvailable()) or not S.InnerRage:IsAvailable()) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- whirlwind,if=buff.wrecking_ball.react&buff.enrage.up
    if S.Whirlwind:IsCastableP() and (bool(Player:BuffStackP(S.WreckingBallBuff)) and Player:BuffP(S.EnrageBuff)) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- raging_blow
    if S.RagingBlow:IsCastableP() and (true) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- furious_slash
    if S.FuriousSlash:IsCastableP() and (true) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
  end
  local function Execute()
    -- bloodthirst,if=buff.fujiedas_fury.up&buff.fujiedas_fury.remains<2
    if S.Bloodthirst:IsCastableP() and (Player:BuffP(S.FujiedasFuryBuff) and Player:BuffRemainsP(S.FujiedasFuryBuff) < 2) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- execute,if=artifact.juggernaut.enabled&(!buff.juggernaut.up|buff.juggernaut.remains<2)|buff.stone_heart.react
    if S.Execute:IsCastableP() and (S.Juggernaut:ArtifactEnabled() and (not Player:BuffP(S.JuggernautBuff) or Player:BuffRemainsP(S.JuggernautBuff) < 2) or bool(Player:BuffStackP(S.StoneHeartBuff))) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- furious_slash,if=talent.frenzy.enabled&buff.frenzy.remains<=2
    if S.FuriousSlash:IsCastableP() and (S.Frenzy:IsAvailable() and Player:BuffRemainsP(S.FrenzyBuff) <= 2) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
    -- rampage,if=buff.massacre.react&buff.enrage.remains<1
    if S.Rampage:IsCastableP() and (bool(Player:BuffStackP(S.MassacreBuff)) and Player:BuffRemainsP(S.EnrageBuff) < 1) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- execute
    if S.Execute:IsCastableP() and (true) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- odyns_fury
    if S.OdynsFury:IsCastableP() and (true) then
      if AR.Cast(S.OdynsFury) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- furious_slash,if=set_bonus.tier19_2pc
    if S.FuriousSlash:IsCastableP() and (AC.Tier19_2Pc) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
    -- raging_blow
    if S.RagingBlow:IsCastableP() and (true) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- furious_slash
    if S.FuriousSlash:IsCastableP() and (true) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
  end
  local function Movement()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() and (true) then
      if AR.Cast(S.HeroicLeap) then return ""; end
    end
  end
  local function SingleTarget()
    -- bloodthirst,if=buff.fujiedas_fury.up&buff.fujiedas_fury.remains<2
    if S.Bloodthirst:IsCastableP() and (Player:BuffP(S.FujiedasFuryBuff) and Player:BuffRemainsP(S.FujiedasFuryBuff) < 2) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- furious_slash,if=talent.frenzy.enabled&(buff.frenzy.down|buff.frenzy.remains<=2)
    if S.FuriousSlash:IsCastableP() and (S.Frenzy:IsAvailable() and (Player:BuffDownP(S.FrenzyBuff) or Player:BuffRemainsP(S.FrenzyBuff) <= 2)) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
    -- raging_blow,if=buff.enrage.up&talent.inner_rage.enabled
    if S.RagingBlow:IsCastableP() and (Player:BuffP(S.EnrageBuff) and S.InnerRage:IsAvailable()) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- rampage,if=target.health.pct>21&(rage>=100|!talent.frothing_berserker.enabled)&(((cooldown.battle_cry.remains>5|cooldown.bloodbath.remains>5)&!talent.carnage.enabled)|((cooldown.battle_cry.remains>3|cooldown.bloodbath.remains>3)&talent.carnage.enabled))|buff.massacre.react
    if S.Rampage:IsCastableP() and (Target:HealthPercentage() > 21 and (rage >= 100 or not S.FrothingBerserker:IsAvailable()) and (((S.BattleCry:CooldownRemainsP() > 5 or S.Bloodbath:CooldownRemainsP() > 5) and not S.Carnage:IsAvailable()) or ((S.BattleCry:CooldownRemainsP() > 3 or S.Bloodbath:CooldownRemainsP() > 3) and S.Carnage:IsAvailable())) or bool(Player:BuffStackP(S.MassacreBuff))) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- execute,if=buff.stone_heart.react&((talent.inner_rage.enabled&cooldown.raging_blow.remains>1)|buff.enrage.up)
    if S.Execute:IsCastableP() and (bool(Player:BuffStackP(S.StoneHeartBuff)) and ((S.InnerRage:IsAvailable() and S.RagingBlow:CooldownRemainsP() > 1) or Player:BuffP(S.EnrageBuff))) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- furious_slash,if=set_bonus.tier19_2pc&!talent.inner_rage.enabled
    if S.FuriousSlash:IsCastableP() and (AC.Tier19_2Pc and not S.InnerRage:IsAvailable()) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
    -- whirlwind,if=buff.wrecking_ball.react&buff.enrage.up
    if S.Whirlwind:IsCastableP() and (bool(Player:BuffStackP(S.WreckingBallBuff)) and Player:BuffP(S.EnrageBuff)) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- raging_blow
    if S.RagingBlow:IsCastableP() and (true) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- furious_slash
    if S.FuriousSlash:IsCastableP() and (true) then
      if AR.Cast(S.FuriousSlash) then return ""; end
    end
  end
  local function ThreeTargets()
    -- execute,if=buff.stone_heart.react
    if S.Execute:IsCastableP() and (bool(Player:BuffStackP(S.StoneHeartBuff))) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- rampage,if=buff.meat_cleaver.up&((buff.enrage.down&!talent.frothing_berserker.enabled)|(rage>=100&talent.frothing_berserker.enabled))|buff.massacre.react
    if S.Rampage:IsCastableP() and (Player:BuffP(S.MeatCleaverBuff) and ((Player:BuffDownP(S.EnrageBuff) and not S.FrothingBerserker:IsAvailable()) or (rage >= 100 and S.FrothingBerserker:IsAvailable())) or bool(Player:BuffStackP(S.MassacreBuff))) then
      if AR.Cast(S.Rampage) then return ""; end
    end
    -- raging_blow,if=talent.inner_rage.enabled
    if S.RagingBlow:IsCastableP() and (S.InnerRage:IsAvailable()) then
      if AR.Cast(S.RagingBlow) then return ""; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() and (true) then
      if AR.Cast(S.Bloodthirst) then return ""; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() and (true) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
  end
  -- auto_attack
  -- charge
  if S.Charge:IsCastableP() and (true) then
    if AR.Cast(S.Charge) then return ""; end
  end
  -- run_action_list,name=movement,if=movement.distance>5
  if (movement.distance > 5) then
    return Movement();
  end
  -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)|!raid_event.movement.exists
  if S.HeroicLeap:IsCastableP() and ((raid_event.movement.distance > 25 and raid_event.movement.in > 45) or not bool(raid_event.movement.exists)) then
    if AR.Cast(S.HeroicLeap) then return ""; end
  end
  -- potion,name=old_war,if=buff.battle_cry.up&(buff.avatar.up|!talent.avatar.enabled)
  if I.OldWar:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.BattleCryBuff) and (Player:BuffP(S.AvatarBuff) or not S.Avatar:IsAvailable())) then
    if AR.CastSuggested(I.OldWar) then return ""; end
  end
  -- dragon_roar,if=(equipped.convergence_of_fates&cooldown.battle_cry.remains<2)|!equipped.convergence_of_fates&(!cooldown.battle_cry.remains<=10|cooldown.battle_cry.remains<2)|(talent.bloodbath.enabled&(cooldown.bloodbath.remains<1|buff.bloodbath.up))
  if S.DragonRoar:IsCastableP() and ((I.ConvergenceofFates:IsEquipped() and S.BattleCry:CooldownRemainsP() < 2) or not I.ConvergenceofFates:IsEquipped() and (num(not bool(S.BattleCry:CooldownRemainsP())) <= 10 or S.BattleCry:CooldownRemainsP() < 2) or (S.Bloodbath:IsAvailable() and (S.Bloodbath:CooldownRemainsP() < 1 or Player:BuffP(S.BloodbathBuff)))) then
    if AR.Cast(S.DragonRoar) then return ""; end
  end
  -- rampage,if=cooldown.battle_cry.remains<1&cooldown.bloodbath.remains<1&target.health.pct>20
  if S.Rampage:IsCastableP() and (S.BattleCry:CooldownRemainsP() < 1 and S.Bloodbath:CooldownRemainsP() < 1 and Target:HealthPercentage() > 20) then
    if AR.Cast(S.Rampage) then return ""; end
  end
  -- furious_slash,if=talent.frenzy.enabled&(buff.frenzy.stack<3|buff.frenzy.remains<3|(cooldown.battle_cry.remains<1&buff.frenzy.remains<9))
  if S.FuriousSlash:IsCastableP() and (S.Frenzy:IsAvailable() and (Player:BuffStackP(S.FrenzyBuff) < 3 or Player:BuffRemainsP(S.FrenzyBuff) < 3 or (S.BattleCry:CooldownRemainsP() < 1 and Player:BuffRemainsP(S.FrenzyBuff) < 9))) then
    if AR.Cast(S.FuriousSlash) then return ""; end
  end
  -- use_item,name=umbral_moonglaives,if=equipped.umbral_moonglaives&(cooldown.battle_cry.remains>gcd&cooldown.battle_cry.remains<2|cooldown.battle_cry.remains=0)
  if S.UseItem:IsCastableP() and (I.UmbralMoonglaives:IsEquipped() and (S.BattleCry:CooldownRemainsP() > Player:GCD() and S.BattleCry:CooldownRemainsP() < 2 or S.BattleCry:CooldownRemainsP() == 0)) then
    if AR.Cast(S.UseItem) then return ""; end
  end
  -- bloodthirst,if=equipped.kazzalax_fujiedas_fury&buff.fujiedas_fury.down
  if S.Bloodthirst:IsCastableP() and (I.KazzalaxFujiedasFury:IsEquipped() and Player:BuffDownP(S.FujiedasFuryBuff)) then
    if AR.Cast(S.Bloodthirst) then return ""; end
  end
  -- avatar,if=((buff.battle_cry.remains>5|cooldown.battle_cry.remains<12)&target.time_to_die>80)|((target.time_to_die<40)&(buff.battle_cry.remains>6|cooldown.battle_cry.remains<12|(target.time_to_die<20)))
  if S.Avatar:IsCastableP() and (((Player:BuffRemainsP(S.BattleCryBuff) > 5 or S.BattleCry:CooldownRemainsP() < 12) and Target:TimeToDie() > 80) or ((Target:TimeToDie() < 40) and (Player:BuffRemainsP(S.BattleCryBuff) > 6 or S.BattleCry:CooldownRemainsP() < 12 or (Target:TimeToDie() < 20)))) then
    if AR.Cast(S.Avatar) then return ""; end
  end
  -- battle_cry,if=gcd.remains=0&talent.reckless_abandon.enabled&!talent.bloodbath.enabled&(equipped.umbral_moonglaives&(prev_off_gcd.umbral_moonglaives|(trinket.cooldown.remains>3&trinket.cooldown.remains<90))|!equipped.umbral_moonglaives)
  if S.BattleCry:IsCastableP() and (Player:GCDRemains() == 0 and S.RecklessAbandon:IsAvailable() and not S.Bloodbath:IsAvailable() and (I.UmbralMoonglaives:IsEquipped() and (bool(prev_off_gcd.umbral_moonglaives) or (trinket.cooldown.remains > 3 and trinket.cooldown.remains < 90)) or not I.UmbralMoonglaives:IsEquipped())) then
    if AR.Cast(S.BattleCry) then return ""; end
  end
  -- battle_cry,if=gcd.remains=0&talent.bladestorm.enabled&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
  if S.BattleCry:IsCastableP() and (Player:GCDRemains() == 0 and S.Bladestorm:IsAvailable() and (raid_event.adds.in > 90 or not bool(raid_event.adds.exists) or Cache.EnemiesCount[0] > desired_targets)) then
    if AR.Cast(S.BattleCry) then return ""; end
  end
  -- battle_cry,if=gcd.remains=0&buff.dragon_roar.up&(cooldown.bloodthirst.remains=0|buff.enrage.remains>cooldown.bloodthirst.remains)
  if S.BattleCry:IsCastableP() and (Player:GCDRemains() == 0 and Player:BuffP(S.DragonRoarBuff) and (S.Bloodthirst:CooldownRemainsP() == 0 or Player:BuffRemainsP(S.EnrageBuff) > S.Bloodthirst:CooldownRemainsP())) then
    if AR.Cast(S.BattleCry) then return ""; end
  end
  -- battle_cry,if=(gcd.remains=0|gcd.remains<=0.4&prev_gcd.1.rampage)&(cooldown.bloodbath.remains=0|buff.bloodbath.up|!talent.bloodbath.enabled|(target.time_to_die<12))&(equipped.umbral_moonglaives&(prev_off_gcd.umbral_moonglaives|(trinket.cooldown.remains>3&trinket.cooldown.remains<90))|!equipped.umbral_moonglaives)
  if S.BattleCry:IsCastableP() and ((Player:GCDRemains() == 0 or Player:GCDRemains() <= 0.4 and Player:PrevGCDP(1, S.Rampage)) and (S.Bloodbath:CooldownRemainsP() == 0 or Player:BuffP(S.BloodbathBuff) or not S.Bloodbath:IsAvailable() or (Target:TimeToDie() < 12)) and (I.UmbralMoonglaives:IsEquipped() and (bool(prev_off_gcd.umbral_moonglaives) or (trinket.cooldown.remains > 3 and trinket.cooldown.remains < 90)) or not I.UmbralMoonglaives:IsEquipped())) then
    if AR.Cast(S.BattleCry) then return ""; end
  end
  -- bloodbath,if=buff.battle_cry.up|(target.time_to_die<14)|(cooldown.battle_cry.remains<2&prev_gcd.1.rampage)
  if S.Bloodbath:IsCastableP() and (Player:BuffP(S.BattleCryBuff) or (Target:TimeToDie() < 14) or (S.BattleCry:CooldownRemainsP() < 2 and Player:PrevGCDP(1, S.Rampage))) then
    if AR.Cast(S.Bloodbath) then return ""; end
  end
  -- blood_fury,if=buff.battle_cry.up
  if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.BattleCryBuff)) then
    if AR.Cast(S.BloodFury, Settings.Fury.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=(buff.battle_cry.up&(buff.avatar.up|!talent.avatar.enabled))|(buff.battle_cry.up&target.time_to_die<40)
  if S.Berserking:IsCastableP() and AR.CDsON() and ((Player:BuffP(S.BattleCryBuff) and (Player:BuffP(S.AvatarBuff) or not S.Avatar:IsAvailable())) or (Player:BuffP(S.BattleCryBuff) and Target:TimeToDie() < 40)) then
    if AR.Cast(S.Berserking, Settings.Fury.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent,if=rage<rage.max-40
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (rage < rage.max - 40) then
    if AR.Cast(S.ArcaneTorrent, Settings.Fury.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- run_action_list,name=cooldowns,if=buff.battle_cry.up&spell_targets.whirlwind=1
  if (Player:BuffP(S.BattleCryBuff) and Cache.EnemiesCount[0] == 1) then
    return Cooldowns();
  end
  -- run_action_list,name=three_targets,if=target.health.pct>20&(spell_targets.whirlwind=3|spell_targets.whirlwind=4)
  if (Target:HealthPercentage() > 20 and (Cache.EnemiesCount[0] == 3 or Cache.EnemiesCount[0] == 4)) then
    return ThreeTargets();
  end
  -- run_action_list,name=aoe,if=spell_targets.whirlwind>4
  if (Cache.EnemiesCount[0] > 4) then
    return Aoe();
  end
  -- run_action_list,name=execute,if=target.health.pct<20
  if (Target:HealthPercentage() < 20) then
    return Execute();
  end
  -- run_action_list,name=single_target,if=target.health.pct>20
  if (Target:HealthPercentage() > 20) then
    return SingleTarget();
  end
end