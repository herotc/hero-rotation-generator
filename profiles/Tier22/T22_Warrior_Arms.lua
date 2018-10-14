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
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Arms = {
  Skullsplitter                         = Spell(260643),
  DeadlyCalm                            = Spell(262228),
  DeadlyCalmBuff                        = Spell(262228),
  Bladestorm                            = Spell(227847),
  ColossusSmash                         = Spell(167105),
  Warbreaker                            = Spell(262161),
  Ravager                               = Spell(152277),
  ColossusSmashDebuff                   = Spell(208086),
  Cleave                                = Spell(845),
  Slam                                  = Spell(1464),
  CrushingAssaultBuff                   = Spell(278826),
  MortalStrike                          = Spell(12294),
  OverpowerBuff                         = Spell(7384),
  Dreadnaught                           = Spell(262150),
  ExecutionersPrecisionBuff             = Spell(242188),
  Overpower                             = Spell(7384),
  Execute                               = Spell(163201),
  SweepingStrikesBuff                   = Spell(260708),
  TestofMight                           = Spell(275529),
  TestofMightBuff                       = Spell(275540),
  DeepWoundsDebuff                      = Spell(262115),
  SuddenDeathBuff                       = Spell(52437),
  StoneHeartBuff                        = Spell(225947),
  SweepingStrikes                       = Spell(260708),
  Whirlwind                             = Spell(1680),
  FervorofBattle                        = Spell(202316),
  Rend                                  = Spell(772),
  RendDebuff                            = Spell(772),
  AngerManagement                       = Spell(152278),
  SeismicWave                           = Spell(277639),
  Charge                                = Spell(100),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Avatar                                = Spell(107574),
  Massacre                              = Spell(281001)
};
local S = Spell.Warrior.Arms;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Arms = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Warrior.Arms;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Arms = HR.GUISettings.APL.Warrior.Arms
};


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

S.ExecuteDefault    = Spell(163201)
S.ExecuteMassacre   = Spell(281000)

local function UpdateExecuteID()
    S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Execute, FiveTarget, Hac, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  UpdateExecuteID()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
  end
  Execute = function()
    -- skullsplitter,if=rage<60&((cooldown.deadly_calm.remains>3&!buff.deadly_calm.up)|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and ((S.DeadlyCalm:CooldownRemainsP() > 3 and not Player:BuffP(S.DeadlyCalmBuff)) or not S.DeadlyCalm:IsAvailable())) then
      if HR.Cast(S.Skullsplitter) then return "skullsplitter 6"; end
    end
    -- deadly_calm,if=cooldown.bladestorm.remains>6&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.DeadlyCalm:IsCastableP() and (S.Bladestorm:CooldownRemainsP() > 6 and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.DeadlyCalm) then return "deadly_calm 14"; end
    end
    -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.Ravager) then return "ravager 24"; end
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.ColossusSmash) then return "colossus_smash 34"; end
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Warbreaker) then return "warbreaker 38"; end
    end
    -- bladestorm,if=rage<30&!buff.deadly_calm.up
    if S.Bladestorm:IsCastableP() and (Player:Rage() < 30 and not Player:BuffP(S.DeadlyCalmBuff)) then
      if HR.Cast(S.Bladestorm) then return "bladestorm 42"; end
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      if HR.Cast(S.Cleave) then return "cleave 46"; end
    end
    -- slam,if=buff.crushing_assault.up
    if S.Slam:IsReadyP() and (Player:BuffP(S.CrushingAssaultBuff)) then
      if HR.Cast(S.Slam) then return "slam 48"; end
    end
    -- mortal_strike,if=debuff.colossus_smash.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|buff.executioners_precision.stack=2)
    if S.MortalStrike:IsReadyP() and (Target:DebuffP(S.ColossusSmashDebuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2)) then
      if HR.Cast(S.MortalStrike) then return "mortal_strike 52"; end
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      if HR.Cast(S.Overpower) then return "overpower 62"; end
    end
    -- execute
    if S.Execute:IsCastableP() then
      if HR.Cast(S.Execute) then return "execute 64"; end
    end
  end
  FiveTarget = function()
    -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
      if HR.Cast(S.Skullsplitter) then return "skullsplitter 66"; end
    end
    -- deadly_calm,if=cooldown.bladestorm.remains>6&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.DeadlyCalm:IsCastableP() and (S.Bladestorm:CooldownRemainsP() > 6 and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.DeadlyCalm) then return "deadly_calm 72"; end
    end
    -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.Ravager) then return "ravager 82"; end
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.ColossusSmash) then return "colossus_smash 92"; end
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Warbreaker) then return "warbreaker 96"; end
    end
    -- bladestorm,if=buff.sweeping_strikes.down&!buff.deadly_calm.up&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
    if S.Bladestorm:IsCastableP() and (Player:BuffDownP(S.SweepingStrikesBuff) and not Player:BuffP(S.DeadlyCalmBuff) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
      if HR.Cast(S.Bladestorm) then return "bladestorm 100"; end
    end
    -- cleave
    if S.Cleave:IsReadyP() then
      if HR.Cast(S.Cleave) then return "cleave 112"; end
    end
    -- execute,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|(buff.sudden_death.react|buff.stone_heart.react)&(buff.sweeping_strikes.up|cooldown.sweeping_strikes.remains>8)
    if S.Execute:IsCastableP() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or (bool(Player:BuffStackP(S.SuddenDeathBuff)) or bool(Player:BuffStackP(S.StoneHeartBuff))) and (Player:BuffP(S.SweepingStrikesBuff) or S.SweepingStrikes:CooldownRemainsP() > 8)) then
      if HR.Cast(S.Execute) then return "execute 114"; end
    end
    -- mortal_strike,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sweeping_strikes.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|buff.executioners_precision.stack=2)
    if S.MortalStrike:IsReadyP() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or Player:BuffP(S.SweepingStrikesBuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2)) then
      if HR.Cast(S.MortalStrike) then return "mortal_strike 128"; end
    end
    -- whirlwind,if=debuff.colossus_smash.up|(buff.crushing_assault.up&talent.fervor_of_battle.enabled)
    if S.Whirlwind:IsReadyP() and (Target:DebuffP(S.ColossusSmashDebuff) or (Player:BuffP(S.CrushingAssaultBuff) and S.FervorofBattle:IsAvailable())) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 142"; end
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      if HR.Cast(S.Overpower) then return "overpower 150"; end
    end
    -- whirlwind
    if S.Whirlwind:IsReadyP() then
      if HR.Cast(S.Whirlwind) then return "whirlwind 152"; end
    end
  end
  Hac = function()
    -- rend,if=remains<=duration*0.3&(!raid_event.adds.up|buff.sweeping_strikes.up)
    if S.Rend:IsReadyP() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and (not (Cache.EnemiesCount[8] > 1) or Player:BuffP(S.SweepingStrikesBuff))) then
      if HR.Cast(S.Rend) then return "rend 154"; end
    end
    -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
      if HR.Cast(S.Skullsplitter) then return "skullsplitter 172"; end
    end
    -- deadly_calm,if=(cooldown.bladestorm.remains>6|talent.ravager.enabled&cooldown.ravager.remains>6)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.DeadlyCalm:IsCastableP() and ((S.Bladestorm:CooldownRemainsP() > 6 or S.Ravager:IsAvailable() and S.Ravager:CooldownRemainsP() > 6) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.DeadlyCalm) then return "deadly_calm 178"; end
    end
    -- ravager,if=(raid_event.adds.up|raid_event.adds.in>target.time_to_die)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and (((Cache.EnemiesCount[8] > 1) or 10000000000 > Target:TimeToDie()) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.Ravager) then return "ravager 192"; end
    end
    -- colossus_smash,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
    if S.ColossusSmash:IsCastableP() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
      if HR.Cast(S.ColossusSmash) then return "colossus_smash 202"; end
    end
    -- warbreaker,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
    if S.Warbreaker:IsCastableP() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
      if HR.Cast(S.Warbreaker) then return "warbreaker 208"; end
    end
    -- bladestorm,if=(debuff.colossus_smash.up&raid_event.adds.in>target.time_to_die)|raid_event.adds.up&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
    if S.Bladestorm:IsCastableP() and ((Target:DebuffP(S.ColossusSmashDebuff) and 10000000000 > Target:TimeToDie()) or (Cache.EnemiesCount[8] > 1) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
      if HR.Cast(S.Bladestorm) then return "bladestorm 214"; end
    end
    -- overpower,if=!raid_event.adds.up|(raid_event.adds.up&azerite.seismic_wave.enabled)
    if S.Overpower:IsCastableP() and (not (Cache.EnemiesCount[8] > 1) or ((Cache.EnemiesCount[8] > 1) and S.SeismicWave:AzeriteEnabled())) then
      if HR.Cast(S.Overpower) then return "overpower 226"; end
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      if HR.Cast(S.Cleave) then return "cleave 234"; end
    end
    -- execute,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sudden_death.react
    if S.Execute:IsCastableP() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or bool(Player:BuffStackP(S.SuddenDeathBuff))) then
      if HR.Cast(S.Execute) then return "execute 236"; end
    end
    -- mortal_strike,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)
    if S.MortalStrike:IsReadyP() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2)) then
      if HR.Cast(S.MortalStrike) then return "mortal_strike 246"; end
    end
    -- whirlwind,if=raid_event.adds.up
    if S.Whirlwind:IsReadyP() and ((Cache.EnemiesCount[8] > 1)) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 254"; end
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      if HR.Cast(S.Overpower) then return "overpower 258"; end
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled
    if S.Whirlwind:IsReadyP() and (S.FervorofBattle:IsAvailable()) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 260"; end
    end
    -- slam,if=!talent.fervor_of_battle.enabled&!raid_event.adds.up
    if S.Slam:IsReadyP() and (not S.FervorofBattle:IsAvailable() and not (Cache.EnemiesCount[8] > 1)) then
      if HR.Cast(S.Slam) then return "slam 264"; end
    end
  end
  SingleTarget = function()
    -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
    if S.Rend:IsReadyP() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Rend) then return "rend 270"; end
    end
    -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
      if HR.Cast(S.Skullsplitter) then return "skullsplitter 286"; end
    end
    -- deadly_calm,if=(cooldown.bladestorm.remains>6|talent.ravager.enabled&cooldown.ravager.remains>6)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.DeadlyCalm:IsCastableP() and ((S.Bladestorm:CooldownRemainsP() > 6 or S.Ravager:IsAvailable() and S.Ravager:CooldownRemainsP() > 6) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.DeadlyCalm) then return "deadly_calm 292"; end
    end
    -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      if HR.Cast(S.Ravager) then return "ravager 306"; end
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.ColossusSmash) then return "colossus_smash 316"; end
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Warbreaker) then return "warbreaker 320"; end
    end
    -- execute,if=buff.sudden_death.react
    if S.Execute:IsCastableP() and (bool(Player:BuffStackP(S.SuddenDeathBuff))) then
      if HR.Cast(S.Execute) then return "execute 324"; end
    end
    -- bladestorm,if=cooldown.mortal_strike.remains&((debuff.colossus_smash.up&!azerite.test_of_might.enabled)|buff.test_of_might.up)
    if S.Bladestorm:IsCastableP() and (bool(S.MortalStrike:CooldownRemainsP()) and ((Target:DebuffP(S.ColossusSmashDebuff) and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
      if HR.Cast(S.Bladestorm) then return "bladestorm 328"; end
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      if HR.Cast(S.Cleave) then return "cleave 338"; end
    end
    -- overpower,if=azerite.seismic_wave.rank=3
    if S.Overpower:IsCastableP() and (S.SeismicWave:AzeriteRank() == 3) then
      if HR.Cast(S.Overpower) then return "overpower 340"; end
    end
    -- mortal_strike
    if S.MortalStrike:IsReadyP() then
      if HR.Cast(S.MortalStrike) then return "mortal_strike 344"; end
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      if HR.Cast(S.Overpower) then return "overpower 346"; end
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled&(!azerite.test_of_might.enabled|(rage>=60|debuff.colossus_smash.up|buff.deadly_calm.up))
    if S.Whirlwind:IsReadyP() and (S.FervorofBattle:IsAvailable() and (not S.TestofMight:AzeriteEnabled() or (Player:Rage() >= 60 or Target:DebuffP(S.ColossusSmashDebuff) or Player:BuffP(S.DeadlyCalmBuff)))) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 348"; end
    end
    -- slam,if=!talent.fervor_of_battle.enabled&(!azerite.test_of_might.enabled|(rage>=60|debuff.colossus_smash.up|buff.deadly_calm.up))
    if S.Slam:IsReadyP() and (not S.FervorofBattle:IsAvailable() and (not S.TestofMight:AzeriteEnabled() or (Player:Rage() >= 60 or Target:DebuffP(S.ColossusSmashDebuff) or Player:BuffP(S.DeadlyCalmBuff)))) then
      if HR.Cast(S.Slam) then return "slam 358"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- charge
    if S.Charge:IsCastableP() then
      if HR.Cast(S.Charge, Settings.Arms.GCDasOffGCD.Charge) then return "charge 369"; end
    end
    -- auto_attack
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 372"; end
    end
    -- blood_fury,if=debuff.colossus_smash.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 374"; end
    end
    -- berserking,if=debuff.colossus_smash.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 378"; end
    end
    -- arcane_torrent,if=debuff.colossus_smash.down&cooldown.mortal_strike.remains>1.5&rage<50
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff) and S.MortalStrike:CooldownRemainsP() > 1.5 and Player:Rage() < 50) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 382"; end
    end
    -- lights_judgment,if=debuff.colossus_smash.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 388"; end
    end
    -- fireblood,if=debuff.colossus_smash.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 392"; end
    end
    -- ancestral_call,if=debuff.colossus_smash.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 396"; end
    end
    -- avatar,if=cooldown.colossus_smash.remains<8|(talent.warbreaker.enabled&cooldown.warbreaker.remains<8)
    if S.Avatar:IsCastableP() and HR.CDsON() and (S.ColossusSmash:CooldownRemainsP() < 8 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 8)) then
      if HR.Cast(S.Avatar, Settings.Arms.GCDasOffGCD.Avatar) then return "avatar 400"; end
    end
    -- sweeping_strikes,if=spell_targets.whirlwind>1&(cooldown.bladestorm.remains>10|cooldown.colossus_smash.remains>8|azerite.test_of_might.enabled)
    if S.SweepingStrikes:IsCastableP() and (Cache.EnemiesCount[8] > 1 and (S.Bladestorm:CooldownRemainsP() > 10 or S.ColossusSmash:CooldownRemainsP() > 8 or S.TestofMight:AzeriteEnabled())) then
      if HR.Cast(S.SweepingStrikes) then return "sweeping_strikes 408"; end
    end
    -- run_action_list,name=hac,if=raid_event.adds.exists
    if ((Cache.EnemiesCount[8] > 1)) then
      return Hac();
    end
    -- run_action_list,name=five_target,if=spell_targets.whirlwind>4
    if (Cache.EnemiesCount[8] > 4) then
      return FiveTarget();
    end
    -- run_action_list,name=execute,if=(talent.massacre.enabled&target.health.pct<35)|target.health.pct<20
    if ((S.Massacre:IsAvailable() and Target:HealthPercentage() < 35) or Target:HealthPercentage() < 20) then
      return Execute();
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

HR.SetAPL(71, APL)
