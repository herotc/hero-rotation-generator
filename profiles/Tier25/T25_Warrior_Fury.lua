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
Spell.Warrior.Fury = {
  WorldveinResonance                    = Spell(),
  MemoryofLucidDreams                   = Spell(),
  GuardianofAzeroth                     = Spell(),
  RecklessnessBuff                      = Spell(1719),
  Recklessness                          = Spell(1719),
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(280772),
  Rampage                               = Spell(184367),
  MemoryofLucidDreamsBuff               = Spell(),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
  Execute                               = Spell(5308),
  FuriousSlash                          = Spell(100130),
  FuriousSlashBuff                      = Spell(202539),
  Bladestorm                            = Spell(46924),
  Bloodthirst                           = Spell(23881),
  ColdSteelHotBlood                     = Spell(),
  DragonRoar                            = Spell(118000),
  RagingBlow                            = Spell(85288),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  GuardianofAzerothBuff                 = Spell(),
  BloodoftheEnemy                       = Spell(),
  PurifyingBlast                        = Spell(),
  SiegebreakerBuff                      = Spell(),
  RippleInSpace                         = Spell(),
  FocusedAzeriteBeam                    = Spell(),
  ReapingFlames                         = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  MeatCleaverBuff                       = Spell(280392),
  RazorCoralDebuffDebuff                = Spell(),
  ConductiveInkDebuffDebuff             = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  SiegebreakerDebuff                    = Spell(280773),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell()
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  AzsharasFontofPower              = Item(),
  BattlePotionofStrength           = Item(163224),
  AshvanesRazorCoral               = Item()
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Fury = HR.GUISettings.APL.Warrior.Fury
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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Movement, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 4"; end
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 6"; end
    end
    -- memory_of_lucid_dreams
    if S.MemoryofLucidDreams:IsCastableP() then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 8"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 10"; end
    end
    -- recklessness
    if S.Recklessness:IsCastableP() and Player:BuffDownP(S.RecklessnessBuff) and HR.CDsON() then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 12"; end
    end
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 16"; end
    end
  end
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      if HR.Cast(S.HeroicLeap) then return "heroic_leap 18"; end
    end
  end
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Siegebreaker, Settings.Fury.GCDasOffGCD.Siegebreaker) then return "siegebreaker 20"; end
    end
    -- rampage,if=(buff.recklessness.up|buff.memory_of_lucid_dreams.up)|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReadyP() and ((Player:BuffP(S.RecklessnessBuff) or Player:BuffP(S.MemoryofLucidDreamsBuff)) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      if HR.Cast(S.Rampage) then return "rampage 22"; end
    end
    -- execute
    if S.Execute:IsCastableP() then
      if HR.Cast(S.Execute) then return "execute 38"; end
    end
    -- furious_slash,if=!buff.bloodlust.up&buff.furious_slash.remains<3
    if S.FuriousSlash:IsCastableP() and (not Player:HasHeroism() and Player:BuffRemainsP(S.FuriousSlashBuff) < 3) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 40"; end
    end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      if HR.Cast(S.Bladestorm, Settings.Fury.GCDasOffGCD.Bladestorm) then return "bladestorm 44"; end
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 48"; end
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsCastableP() and HR.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.DragonRoar, Settings.Fury.GCDasOffGCD.DragonRoar) then return "dragon_roar 54"; end
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP() and (S.RagingBlow:ChargesP() == 2) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 58"; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 64"; end
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 66"; end
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable()) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 74"; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() then
      if HR.Cast(S.Whirlwind) then return "whirlwind 78"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- charge
    if S.Charge:IsCastableP() then
      if HR.Cast(S.Charge, Settings.Fury.GCDasOffGCD.Charge) then return "charge 82"; end
    end
    -- run_action_list,name=movement,if=movement.distance>5
    if (movement.distance > 5) then
      return Movement();
    end
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)
    if S.HeroicLeap:IsCastableP() and ((raid_event.movement.distance > 25 and 10000000000 > 45)) then
      if HR.Cast(S.HeroicLeap) then return "heroic_leap 86"; end
    end
    -- potion,if=buff.guardian_of_azeroth.up|(!essence.condensed_lifeforce.major&target.time_to_die=60)
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.GuardianofAzerothBuff) or (not bool(essence.condensed_lifeforce.major) and Target:TimeToDie() == 60)) then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 88"; end
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyP() and (S.Recklessness:CooldownRemainsP() < 3) then
      if HR.Cast(S.Rampage) then return "rampage 92"; end
    end
    -- blood_of_the_enemy,if=buff.recklessness.up
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 96"; end
    end
    -- purifying_blast,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.PurifyingBlast:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff)) then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 100"; end
    end
    -- ripple_in_space,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.RippleInSpace:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff)) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 106"; end
    end
    -- worldvein_resonance,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.WorldveinResonance:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff)) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 112"; end
    end
    -- focused_azerite_beam,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.FocusedAzeriteBeam:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff)) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 118"; end
    end
    -- reaping_flames,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.ReapingFlames:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff)) then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 124"; end
    end
    -- concentrated_flame,if=!buff.recklessness.up&!buff.siegebreaker.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and not Player:BuffP(S.SiegebreakerBuff) and Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff) == 0) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 130"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 138"; end
    end
    -- guardian_of_azeroth,if=!buff.recklessness.up&(target.time_to_die>195|target.health.pct<20)
    if S.GuardianofAzeroth:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff) and (Target:TimeToDie() > 195 or Target:HealthPercentage() < 20)) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 142"; end
    end
    -- memory_of_lucid_dreams,if=!buff.recklessness.up
    if S.MemoryofLucidDreams:IsCastableP() and (not Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 146"; end
    end
    -- recklessness,if=!essence.condensed_lifeforce.major&!essence.blood_of_the_enemy.major|cooldown.guardian_of_azeroth.remains>1|buff.guardian_of_azeroth.up|cooldown.blood_of_the_enemy.remains<gcd
    if S.Recklessness:IsCastableP() and HR.CDsON() and (not bool(essence.condensed_lifeforce.major) and not bool(essence.blood_of_the_enemy.major) or S.GuardianofAzeroth:CooldownRemainsP() > 1 or Player:BuffP(S.GuardianofAzerothBuff) or S.BloodoftheEnemy:CooldownRemainsP() < Player:GCD()) then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 150"; end
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff)) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 158"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=target.time_to_die<20|!debuff.razor_coral_debuff.up|(target.health.pct<30.1&debuff.conductive_ink_debuff.up)|(!debuff.conductive_ink_debuff.up&buff.memory_of_lucid_dreams.up|prev_gcd.2.guardian_of_azeroth|prev_gcd.2.recklessness&(!essence.memory_of_lucid_dreams.major&!essence.condensed_lifeforce.major))
    if I.AshvanesRazorCoral:IsReady() and (Target:TimeToDie() < 20 or not Target:DebuffP(S.RazorCoralDebuffDebuff) or (Target:HealthPercentage() < 30.1 and Target:DebuffP(S.ConductiveInkDebuffDebuff)) or (not Target:DebuffP(S.ConductiveInkDebuffDebuff) and Player:BuffP(S.MemoryofLucidDreamsBuff) or Player:PrevGCDP(2, S.GuardianofAzeroth) or Player:PrevGCDP(2, S.Recklessness) and (not bool(essence.memory_of_lucid_dreams.major) and not bool(essence.condensed_lifeforce.major)))) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 162"; end
    end
    -- blood_fury,if=buff.recklessness.up
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 176"; end
    end
    -- berserking,if=buff.recklessness.up
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 180"; end
    end
    -- lights_judgment,if=buff.recklessness.down&debuff.siegebreaker.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.RecklessnessBuff) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 184"; end
    end
    -- fireblood,if=buff.recklessness.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 190"; end
    end
    -- ancestral_call,if=buff.recklessness.up
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 194"; end
    end
    -- bag_of_tricks,if=buff.recklessness.down&debuff.siegebreaker.down&buff.enrage.up
    if S.BagofTricks:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff) and Target:DebuffDownP(S.SiegebreakerDebuff) and Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 198"; end
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

HR.SetAPL(72, APL)
