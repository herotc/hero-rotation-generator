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
Spell.Warrior.Arms = {
  Warbreaker                            = Spell(),
  Bladestorm                            = Spell(),
  BattleCry                             = Spell(),
  BattleCryBuff                         = Spell(),
  Ravager                               = Spell(),
  ColossusSmashDebuff                   = Spell(),
  ColossusSmash                         = Spell(),
  InFortheKillBuff                      = Spell(),
  InFortheKill                          = Spell(),
  Cleave                                = Spell(),
  Whirlwind                             = Spell(),
  CleaveBuff                            = Spell(),
  ShatteredDefensesBuff                 = Spell(),
  Execute                               = Spell(),
  StoneHeartBuff                        = Spell(),
  MortalStrike                          = Spell(),
  ExecutionersPrecisionBuff             = Spell(),
  Rend                                  = Spell(),
  FocusedRage                           = Spell(),
  FocusedRageBuff                       = Spell(),
  FervorofBattle                        = Spell(),
  WeightedBladeBuff                     = Spell(),
  Overpower                             = Spell(),
  Dauntless                             = Spell(),
  BattleCryDeadlyCalmBuff               = Spell(),
  AngerManagement                       = Spell(),
  Slam                                  = Spell(),
  Charge                                = Spell(),
  Avatar                                = Spell(),
  AvatarBuff                            = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  RendDebuff                            = Spell(),
  UseItems                              = Spell()
};
local S = Spell.Warrior.Arms;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Arms = {
  TheGreatStormsEye             = Item(),
  ArchavonsHeavyHand            = Item(),
  ProlongedPower                = Item(142117)
};
local I = Item.Warrior.Arms;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Warrior.Commons,
  Arms = AR.GUISettings.APL.Warrior.Arms
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
    -- warbreaker,if=(cooldown.bladestorm.up|cooldown.bladestorm.remains<=gcd)&(cooldown.battle_cry.up|cooldown.battle_cry.remains<=gcd)
    if S.Warbreaker:IsCastableP() and ((S.Bladestorm:CooldownUpP() or S.Bladestorm:CooldownRemainsP() <= Player:GCD()) and (S.BattleCry:CooldownUpP() or S.BattleCry:CooldownRemainsP() <= Player:GCD())) then
      if AR.Cast(S.Warbreaker) then return ""; end
    end
    -- bladestorm,if=buff.battle_cry.up&!talent.ravager.enabled
    if S.Bladestorm:IsCastableP() and (Player:BuffP(S.BattleCryBuff) and not S.Ravager:IsAvailable()) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
    -- ravager,if=talent.ravager.enabled&cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
    if S.Ravager:IsCastableP() and (S.Ravager:IsAvailable() and S.BattleCry:CooldownRemainsP() <= Player:GCD() and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 6) then
      if AR.Cast(S.Ravager) then return ""; end
    end
    -- colossus_smash,if=buff.in_for_the_kill.down&talent.in_for_the_kill.enabled
    if S.ColossusSmash:IsCastableP() and (Player:BuffDownP(S.InFortheKillBuff) and S.InFortheKill:IsAvailable()) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- colossus_smash,cycle_targets=1,if=debuff.colossus_smash.down&spell_targets.whirlwind<=10
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff) and Cache.EnemiesCount[0] <= 10) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- cleave,if=spell_targets.whirlwind>=5
    if S.Cleave:IsCastableP() and (Cache.EnemiesCount[0] >= 5) then
      if AR.Cast(S.Cleave) then return ""; end
    end
    -- whirlwind,if=spell_targets.whirlwind>=5&buff.cleave.up
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[0] >= 5 and Player:BuffP(S.CleaveBuff)) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- whirlwind,if=spell_targets.whirlwind>=7
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[0] >= 7) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- colossus_smash,if=buff.shattered_defenses.down
    if S.ColossusSmash:IsCastableP() and (Player:BuffDownP(S.ShatteredDefensesBuff)) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- execute,if=buff.stone_heart.react
    if S.Execute:IsCastableP() and (bool(Player:BuffStackP(S.StoneHeartBuff))) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- mortal_strike,if=buff.shattered_defenses.up|buff.executioners_precision.down
    if S.MortalStrike:IsCastableP() and (Player:BuffP(S.ShatteredDefensesBuff) or Player:BuffDownP(S.ExecutionersPrecisionBuff)) then
      if AR.Cast(S.MortalStrike) then return ""; end
    end
    -- rend,cycle_targets=1,if=remains<=duration*0.3&spell_targets.whirlwind<=3
    if S.Rend:IsCastableP() and (Player:BuffRemainsP(S.Rend) <= S.Rend:BaseDuration() * 0.3 and Cache.EnemiesCount[0] <= 3) then
      if AR.Cast(S.Rend) then return ""; end
    end
    -- cleave
    if S.Cleave:IsCastableP() and (true) then
      if AR.Cast(S.Cleave) then return ""; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() and (true) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
  end
  local function Cleave()
    -- bladestorm,if=buff.battle_cry.up&!talent.ravager.enabled
    if S.Bladestorm:IsCastableP() and (Player:BuffP(S.BattleCryBuff) and not S.Ravager:IsAvailable()) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
    -- ravager,if=talent.ravager.enabled&cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
    if S.Ravager:IsCastableP() and (S.Ravager:IsAvailable() and S.BattleCry:CooldownRemainsP() <= Player:GCD() and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 6) then
      if AR.Cast(S.Ravager) then return ""; end
    end
    -- colossus_smash,cycle_targets=1,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- warbreaker,if=raid_event.adds.in>90&buff.shattered_defenses.down
    if S.Warbreaker:IsCastableP() and (raid_event.adds.in > 90 and Player:BuffDownP(S.ShatteredDefensesBuff)) then
      if AR.Cast(S.Warbreaker) then return ""; end
    end
    -- focused_rage,if=rage.deficit<35&buff.focused_rage.stack<3
    if S.FocusedRage:IsCastableP() and (rage.deficit < 35 and Player:BuffStackP(S.FocusedRageBuff) < 3) then
      if AR.Cast(S.FocusedRage) then return ""; end
    end
    -- rend,cycle_targets=1,if=remains<=duration*0.3
    if S.Rend:IsCastableP() and (Player:BuffRemainsP(S.Rend) <= S.Rend:BaseDuration() * 0.3) then
      if AR.Cast(S.Rend) then return ""; end
    end
    -- mortal_strike
    if S.MortalStrike:IsCastableP() and (true) then
      if AR.Cast(S.MortalStrike) then return ""; end
    end
    -- execute
    if S.Execute:IsCastableP() and (true) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- cleave
    if S.Cleave:IsCastableP() and (true) then
      if AR.Cast(S.Cleave) then return ""; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() and (true) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
  end
  local function Execute()
    -- bladestorm,if=buff.battle_cry.up&(set_bonus.tier20_4pc|equipped.the_great_storms_eye)
    if S.Bladestorm:IsCastableP() and (Player:BuffP(S.BattleCryBuff) and (AC.Tier20_4Pc or I.TheGreatStormsEye:IsEquipped())) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
    -- colossus_smash,if=buff.shattered_defenses.down&(buff.battle_cry.down|(buff.executioners_precision.stack=2&(cooldown.battle_cry.remains<1|buff.battle_cry.up)))
    if S.ColossusSmash:IsCastableP() and (Player:BuffDownP(S.ShatteredDefensesBuff) and (Player:BuffDownP(S.BattleCryBuff) or (Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2 and (S.BattleCry:CooldownRemainsP() < 1 or Player:BuffP(S.BattleCryBuff))))) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- warbreaker,if=(raid_event.adds.in>90|!raid_event.adds.exists)&cooldown.mortal_strike.remains<=gcd.remains&buff.shattered_defenses.down&buff.executioners_precision.stack=2
    if S.Warbreaker:IsCastableP() and ((raid_event.adds.in > 90 or not bool(raid_event.adds.exists)) and S.MortalStrike:CooldownRemainsP() <= Player:GCDRemains() and Player:BuffDownP(S.ShatteredDefensesBuff) and Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2) then
      if AR.Cast(S.Warbreaker) then return ""; end
    end
    -- focused_rage,if=rage.deficit<35&buff.focused_rage.stack<3
    if S.FocusedRage:IsCastableP() and (rage.deficit < 35 and Player:BuffStackP(S.FocusedRageBuff) < 3) then
      if AR.Cast(S.FocusedRage) then return ""; end
    end
    -- rend,if=remains<5&cooldown.battle_cry.remains<2&(cooldown.bladestorm.remains<2|!set_bonus.tier20_4pc)
    if S.Rend:IsCastableP() and (Player:BuffRemainsP(S.Rend) < 5 and S.BattleCry:CooldownRemainsP() < 2 and (S.Bladestorm:CooldownRemainsP() < 2 or not AC.Tier20_4Pc)) then
      if AR.Cast(S.Rend) then return ""; end
    end
    -- ravager,if=cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
    if S.Ravager:IsCastableP() and (S.BattleCry:CooldownRemainsP() <= Player:GCD() and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 6) then
      if AR.Cast(S.Ravager) then return ""; end
    end
    -- mortal_strike,if=buff.executioners_precision.stack=2&buff.shattered_defenses.up
    if S.MortalStrike:IsCastableP() and (Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2 and Player:BuffP(S.ShatteredDefensesBuff)) then
      if AR.Cast(S.MortalStrike) then return ""; end
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled&buff.weighted_blade.stack=3&debuff.colossus_smash.up&buff.battle_cry.down
    if S.Whirlwind:IsCastableP() and (S.FervorofBattle:IsAvailable() and Player:BuffStackP(S.WeightedBladeBuff) == 3 and Target:DebuffP(S.ColossusSmashDebuff) and Player:BuffDownP(S.BattleCryBuff)) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- overpower,if=rage<40
    if S.Overpower:IsCastableP() and (rage < 40) then
      if AR.Cast(S.Overpower) then return ""; end
    end
    -- execute,if=buff.shattered_defenses.down|rage>=40|talent.dauntless.enabled&rage>=36
    if S.Execute:IsCastableP() and (Player:BuffDownP(S.ShatteredDefensesBuff) or rage >= 40 or S.Dauntless:IsAvailable() and rage >= 36) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- bladestorm,interrupt=1,if=(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)&!set_bonus.tier20_4pc
    if S.Bladestorm:IsCastableP() and ((raid_event.adds.in > 90 or not bool(raid_event.adds.exists) or Cache.EnemiesCount[0] > desired_targets) and not AC.Tier20_4Pc) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
  end
  local function Single()
    -- bladestorm,if=buff.battle_cry.up&(set_bonus.tier20_4pc|equipped.the_great_storms_eye)
    if S.Bladestorm:IsCastableP() and (Player:BuffP(S.BattleCryBuff) and (AC.Tier20_4Pc or I.TheGreatStormsEye:IsEquipped())) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
    -- colossus_smash,if=buff.shattered_defenses.down
    if S.ColossusSmash:IsCastableP() and (Player:BuffDownP(S.ShatteredDefensesBuff)) then
      if AR.Cast(S.ColossusSmash) then return ""; end
    end
    -- warbreaker,if=(raid_event.adds.in>90|!raid_event.adds.exists)&((talent.fervor_of_battle.enabled&debuff.colossus_smash.remains<gcd)|!talent.fervor_of_battle.enabled&((buff.stone_heart.up|cooldown.mortal_strike.remains<=gcd.remains)&buff.shattered_defenses.down))
    if S.Warbreaker:IsCastableP() and ((raid_event.adds.in > 90 or not bool(raid_event.adds.exists)) and ((S.FervorofBattle:IsAvailable() and Target:DebuffRemainsP(S.ColossusSmashDebuff) < Player:GCD()) or not S.FervorofBattle:IsAvailable() and ((Player:BuffP(S.StoneHeartBuff) or S.MortalStrike:CooldownRemainsP() <= Player:GCDRemains()) and Player:BuffDownP(S.ShatteredDefensesBuff)))) then
      if AR.Cast(S.Warbreaker) then return ""; end
    end
    -- focused_rage,if=!buff.battle_cry_deadly_calm.up&buff.focused_rage.stack<3&!cooldown.colossus_smash.up&(rage>=130|debuff.colossus_smash.down|talent.anger_management.enabled&cooldown.battle_cry.remains<=8)
    if S.FocusedRage:IsCastableP() and (not Player:BuffP(S.BattleCryDeadlyCalmBuff) and Player:BuffStackP(S.FocusedRageBuff) < 3 and not S.ColossusSmash:CooldownUpP() and (rage >= 130 or Target:DebuffDownP(S.ColossusSmashDebuff) or S.AngerManagement:IsAvailable() and S.BattleCry:CooldownRemainsP() <= 8)) then
      if AR.Cast(S.FocusedRage) then return ""; end
    end
    -- rend,if=remains<=gcd.max|remains<5&cooldown.battle_cry.remains<2&(cooldown.bladestorm.remains<2|!set_bonus.tier20_4pc)
    if S.Rend:IsCastableP() and (Player:BuffRemainsP(S.Rend) <= Player:GCD() or Player:BuffRemainsP(S.Rend) < 5 and S.BattleCry:CooldownRemainsP() < 2 and (S.Bladestorm:CooldownRemainsP() < 2 or not AC.Tier20_4Pc)) then
      if AR.Cast(S.Rend) then return ""; end
    end
    -- ravager,if=cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
    if S.Ravager:IsCastableP() and (S.BattleCry:CooldownRemainsP() <= Player:GCD() and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 6) then
      if AR.Cast(S.Ravager) then return ""; end
    end
    -- execute,if=buff.stone_heart.react
    if S.Execute:IsCastableP() and (bool(Player:BuffStackP(S.StoneHeartBuff))) then
      if AR.Cast(S.Execute) then return ""; end
    end
    -- overpower,if=buff.battle_cry.down
    if S.Overpower:IsCastableP() and (Player:BuffDownP(S.BattleCryBuff)) then
      if AR.Cast(S.Overpower) then return ""; end
    end
    -- mortal_strike,if=buff.shattered_defenses.up|buff.executioners_precision.down
    if S.MortalStrike:IsCastableP() and (Player:BuffP(S.ShatteredDefensesBuff) or Player:BuffDownP(S.ExecutionersPrecisionBuff)) then
      if AR.Cast(S.MortalStrike) then return ""; end
    end
    -- rend,if=remains<=duration*0.3
    if S.Rend:IsCastableP() and (Player:BuffRemainsP(S.Rend) <= S.Rend:BaseDuration() * 0.3) then
      if AR.Cast(S.Rend) then return ""; end
    end
    -- cleave,if=talent.fervor_of_battle.enabled&buff.cleave.down&!equipped.archavons_heavy_hand
    if S.Cleave:IsCastableP() and (S.FervorofBattle:IsAvailable() and Player:BuffDownP(S.CleaveBuff) and not I.ArchavonsHeavyHand:IsEquipped()) then
      if AR.Cast(S.Cleave) then return ""; end
    end
    -- whirlwind,if=spell_targets.whirlwind>1|talent.fervor_of_battle.enabled
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[0] > 1 or S.FervorofBattle:IsAvailable()) then
      if AR.Cast(S.Whirlwind) then return ""; end
    end
    -- slam,if=spell_targets.whirlwind=1&!talent.fervor_of_battle.enabled&(rage>=52|!talent.rend.enabled|!talent.ravager.enabled)
    if S.Slam:IsCastableP() and (Cache.EnemiesCount[0] == 1 and not S.FervorofBattle:IsAvailable() and (rage >= 52 or not S.Rend:IsAvailable() or not S.Ravager:IsAvailable())) then
      if AR.Cast(S.Slam) then return ""; end
    end
    -- overpower
    if S.Overpower:IsCastableP() and (true) then
      if AR.Cast(S.Overpower) then return ""; end
    end
    -- bladestorm,if=(raid_event.adds.in>90|!raid_event.adds.exists)&!set_bonus.tier20_4pc
    if S.Bladestorm:IsCastableP() and ((raid_event.adds.in > 90 or not bool(raid_event.adds.exists)) and not AC.Tier20_4Pc) then
      if AR.Cast(S.Bladestorm) then return ""; end
    end
  end
  -- charge
  if S.Charge:IsCastableP() and (true) then
    if AR.Cast(S.Charge) then return ""; end
  end
  -- auto_attack
  -- potion,name=old_war,if=(!talent.avatar.enabled|buff.avatar.up)&buff.battle_cry.up&debuff.colossus_smash.up|target.time_to_die<=26
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and ((not S.Avatar:IsAvailable() or Player:BuffP(S.AvatarBuff)) and Player:BuffP(S.BattleCryBuff) and Target:DebuffP(S.ColossusSmashDebuff) or Target:TimeToDie() <= 26) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- blood_fury,if=buff.battle_cry.up|target.time_to_die<=16
  if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.BattleCryBuff) or Target:TimeToDie() <= 16) then
    if AR.Cast(S.BloodFury, Settings.Arms.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking,if=buff.battle_cry.up|target.time_to_die<=11
  if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.BattleCryBuff) or Target:TimeToDie() <= 11) then
    if AR.Cast(S.Berserking, Settings.Arms.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent,if=buff.battle_cry_deadly_calm.down&rage.deficit>40&cooldown.battle_cry.remains
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:BuffDownP(S.BattleCryDeadlyCalmBuff) and rage.deficit > 40 and bool(S.BattleCry:CooldownRemainsP())) then
    if AR.Cast(S.ArcaneTorrent, Settings.Arms.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- avatar,if=gcd.remains<0.25&(buff.battle_cry.up|cooldown.battle_cry.remains<15)|target.time_to_die<=20
  if S.Avatar:IsCastableP() and (Player:GCDRemains() < 0.25 and (Player:BuffP(S.BattleCryBuff) or S.BattleCry:CooldownRemainsP() < 15) or Target:TimeToDie() <= 20) then
    if AR.Cast(S.Avatar) then return ""; end
  end
  -- battle_cry,if=((target.time_to_die>=70|set_bonus.tier20_4pc)&((gcd.remains<=0.5&prev_gcd.1.ravager)|!talent.ravager.enabled&!gcd.remains&target.debuff.colossus_smash.remains>=5&(!cooldown.bladestorm.remains|!set_bonus.tier20_4pc)&(!talent.rend.enabled|dot.rend.remains>4)))|buff.executioners_precision.stack=2&buff.shattered_defenses.up&!gcd.remains&!set_bonus.tier20_4pc
  if S.BattleCry:IsCastableP() and (((Target:TimeToDie() >= 70 or AC.Tier20_4Pc) and ((Player:GCDRemains() <= 0.5 and Player:PrevGCDP(1, S.Ravager)) or not S.Ravager:IsAvailable() and not bool(Player:GCDRemains()) and target.debuff.colossus_smash.remains >= 5 and (not bool(S.Bladestorm:CooldownRemainsP()) or not AC.Tier20_4Pc) and (not S.Rend:IsAvailable() or Target:DebuffRemainsP(S.RendDebuff) > 4))) or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2 and Player:BuffP(S.ShatteredDefensesBuff) and not bool(Player:GCDRemains()) and not AC.Tier20_4Pc) then
    if AR.Cast(S.BattleCry) then return ""; end
  end
  -- use_items,if=buff.battle_cry.up&debuff.colossus_smash.up
  if S.UseItems:IsCastableP() and (Player:BuffP(S.BattleCryBuff) and Target:DebuffP(S.ColossusSmashDebuff)) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- run_action_list,name=execute,target_if=target.health.pct<=20&spell_targets.whirlwind<5
  if (true) then
    return Execute();
  end
  -- run_action_list,name=aoe,if=spell_targets.whirlwind>=4
  if (Cache.EnemiesCount[0] >= 4) then
    return Aoe();
  end
  -- run_action_list,name=cleave,if=spell_targets.whirlwind>=2
  if (Cache.EnemiesCount[0] >= 2) then
    return Cleave();
  end
  -- run_action_list,name=single,if=target.health.pct>20
  if (Target:HealthPercentage() > 20) then
    return Single();
  end
end