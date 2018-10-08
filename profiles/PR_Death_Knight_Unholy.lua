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
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Unholy = {
  RaiseDead                             = Spell(),
  ArmyoftheDead                         = Spell(42650),
  DeathandDecay                         = Spell(43265),
  Apocalypse                            = Spell(275699),
  Defile                                = Spell(152280),
  Epidemic                              = Spell(207317),
  DeathCoil                             = Spell(47541),
  ScourgeStrike                         = Spell(55090),
  ClawingShadows                        = Spell(207311),
  FesteringStrike                       = Spell(85948),
  FesteringWoundDebuff                  = Spell(194310),
  BurstingSores                         = Spell(),
  SuddenDoomBuff                        = Spell(81340),
  UnholyFrenzyBuff                      = Spell(),
  DarkTransformation                    = Spell(63560),
  SummonGargoyle                        = Spell(49206),
  UnholyFrenzy                          = Spell(207289),
  SoulReaper                            = Spell(130736),
  UnholyBlight                          = Spell(115989),
  Pestilence                            = Spell(277234),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Outbreak                              = Spell(77575),
  VirulentPlagueDebuff                  = Spell(191587)
};
local S = Spell.DeathKnight.Unholy;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  ProlongedPower                   = Item(142117),
  BygoneBeeAlmanac                 = Item(),
  JesHowler                        = Item(),
  GalecallersBeak                  = Item()
};
local I = Item.DeathKnight.Unholy;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Unholy = HR.GUISettings.APL.DeathKnight.Unholy
};

-- Variables
local VarPoolingForGargoyle = 0;

local EnemyRanges = {30, 5}
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
  local Precombat, Aoe, Cooldowns, Generic
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
    -- raise_dead
    if S.RaiseDead:IsCastableP() then
      if HR.Cast(S.RaiseDead) then return "raise_dead 6"; end
    end
    -- army_of_the_dead,delay=2
    if S.ArmyoftheDead:IsCastableP() then
      if HR.Cast(S.ArmyoftheDead, Settings.Unholy.GCDasOffGCD.ArmyoftheDead) then return "army_of_the_dead 8"; end
    end
  end
  Aoe = function()
    -- death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.DeathandDecay) then return "death_and_decay 10"; end
    end
    -- defile
    if S.Defile:IsCastableP() then
      if HR.Cast(S.Defile) then return "defile 14"; end
    end
    -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.Epidemic:IsUsableP() and (bool(death_and_decay.ticking) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return "epidemic 16"; end
    end
    -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (bool(death_and_decay.ticking) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 20"; end
    end
    -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 24"; end
    end
    -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsCastableP() and (bool(death_and_decay.ticking) and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.ClawingShadows) then return "clawing_shadows 28"; end
    end
    -- epidemic,if=!variable.pooling_for_gargoyle
    if S.Epidemic:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.Epidemic) then return "epidemic 32"; end
    end
    -- festering_strike,target_if=debuff.festering_wound.stack<=1&cooldown.death_and_decay.remains
    if S.FesteringStrike:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) <= 1 and bool(S.DeathandDecay:CooldownRemainsP())) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 36"; end
    end
    -- festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
    if S.FesteringStrike:IsCastableP() and (S.BurstingSores:IsAvailable() and Cache.EnemiesCount[5] >= 2 and Target:DebuffStackP(S.FesteringWoundDebuff) <= 1) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 42"; end
    end
    -- death_coil,if=buff.sudden_doom.react&rune.deficit>=4
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:RuneDeficit() >= 4) then
      if HR.Cast(S.DeathCoil) then return "death_coil 48"; end
    end
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(pet.gargoyle.active)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 52"; end
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 58"; end
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 66"; end
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ClawingShadows) then return "clawing_shadows 76"; end
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 86"; end
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsCastableP() and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 90"; end
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 104"; end
    end
  end
  Cooldowns = function()
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() then
      if HR.Cast(S.ArmyoftheDead, Settings.Unholy.GCDasOffGCD.ArmyoftheDead) then return "army_of_the_dead 108"; end
    end
    -- apocalypse,if=debuff.festering_wound.stack>=4
    if S.Apocalypse:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 4) then
      if HR.Cast(S.Apocalypse) then return "apocalypse 110"; end
    end
    -- dark_transformation
    if S.DarkTransformation:IsCastableP() then
      if HR.Cast(S.DarkTransformation) then return "dark_transformation 114"; end
    end
    -- summon_gargoyle,if=runic_power.deficit<14
    if S.SummonGargoyle:IsCastableP() and (Player:RunicPowerDeficit() < 14) then
      if HR.Cast(S.SummonGargoyle) then return "summon_gargoyle 116"; end
    end
    -- unholy_frenzy,if=debuff.festering_wound.stack<4
    if S.UnholyFrenzy:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 4) then
      if HR.Cast(S.UnholyFrenzy) then return "unholy_frenzy 118"; end
    end
    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if S.UnholyFrenzy:IsCastableP() and (Cache.EnemiesCount[30] >= 2 and ((S.DeathandDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
      if HR.Cast(S.UnholyFrenzy) then return "unholy_frenzy 122"; end
    end
    -- soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
    if S.SoulReaper:IsCastableP() and ((Target:TimeToDie() < 8 or Player:Rune() <= 2) and not Player:BuffP(S.UnholyFrenzyBuff)) then
      if HR.Cast(S.SoulReaper) then return "soul_reaper 138"; end
    end
    -- unholy_blight
    if S.UnholyBlight:IsCastableP() then
      if HR.Cast(S.UnholyBlight) then return "unholy_blight 142"; end
    end
  end
  Generic = function()
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(pet.gargoyle.active)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 144"; end
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 150"; end
    end
    -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (S.Pestilence:IsAvailable() and bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.DeathandDecay) then return "death_and_decay 158"; end
    end
    -- defile,if=cooldown.apocalypse.remains
    if S.Defile:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      if HR.Cast(S.Defile) then return "defile 164"; end
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ScourgeStrike) then return "scourge_strike 168"; end
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsCastableP() and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.ClawingShadows) then return "clawing_shadows 178"; end
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 188"; end
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsCastableP() and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
      if HR.Cast(S.FesteringStrike) then return "festering_strike 192"; end
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      if HR.Cast(S.DeathCoil) then return "death_coil 206"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- variable,name=pooling_for_gargoyle,value=cooldown.summon_gargoyle.remains<5&talent.summon_gargoyle.enabled
    if (true) then
      VarPoolingForGargoyle = num(S.SummonGargoyle:CooldownRemainsP() < 5 and S.SummonGargoyle:IsAvailable())
    end
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 65 and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) and Player:RuneDeficit() >= 5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Unholy.GCDasOffGCD.ArcaneTorrent) then return "arcane_torrent 218"; end
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsCastableP() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 222"; end
    end
    -- berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.Berserking:IsCastableP() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 226"; end
    end
    -- use_items
    -- use_item,name=bygone_bee_almanac,if=cooldown.summon_gargoyle.remains>60|!talent.summon_gargoyle.enabled
    if I.BygoneBeeAlmanac:IsReady() and (S.SummonGargoyle:CooldownRemainsP() > 60 or not S.SummonGargoyle:IsAvailable()) then
      if HR.CastSuggested(I.BygoneBeeAlmanac) then return "bygone_bee_almanac 231"; end
    end
    -- use_item,name=jes_howler,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if I.JesHowler:IsReady() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
      if HR.CastSuggested(I.JesHowler) then return "jes_howler 237"; end
    end
    -- use_item,name=galecallers_beak,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if I.GalecallersBeak:IsReady() and (bool(pet.gargoyle.active) or not S.SummonGargoyle:IsAvailable()) then
      if HR.CastSuggested(I.GalecallersBeak) then return "galecallers_beak 241"; end
    end
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.ArmyoftheDead:CooldownUpP() or bool(pet.gargoyle.active) or Player:BuffP(S.UnholyFrenzyBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 245"; end
    end
    -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsCastableP() and ((dot.virulent_plague.tick_time_remains + tick_time <= Target:DebuffRemainsP(S.VirulentPlagueDebuff)) and Target:DebuffRemainsP(S.VirulentPlagueDebuff) <= Player:GCD()) then
      if HR.Cast(S.Outbreak) then return "outbreak 251"; end
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
      return Aoe();
    end
    -- call_action_list,name=generic
    if (true) then
      local ShouldReturn = Generic(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(252, APL)
