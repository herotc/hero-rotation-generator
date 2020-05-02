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
Spell.Warrior.Protection = {
  WorldveinResonance                    = Spell(),
  MemoryofLucidDreams                   = Spell(),
  GuardianofAzeroth                     = Spell(),
  ThunderClap                           = Spell(6343),
  AvatarBuff                            = Spell(107574),
  DemoralizingShout                     = Spell(1160),
  BoomingVoice                          = Spell(202743),
  AnimaofDeath                          = Spell(),
  LastStandBuff                         = Spell(),
  DragonRoar                            = Spell(118000),
  Revenge                               = Spell(6572),
  Ravager                               = Spell(228920),
  ShieldBlock                           = Spell(2565),
  ShieldSlam                            = Spell(23922),
  ShieldBlockBuff                       = Spell(132404),
  UnstoppableForce                      = Spell(275336),
  RazorCoralDebuffDebuff                = Spell(),
  Avatar                                = Spell(107574),
  Devastate                             = Spell(20243),
  Intercept                             = Spell(198304),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell(),
  IgnorePain                            = Spell(190456),
  RippleInSpace                         = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  LastStand                             = Spell()
};
local S = Spell.Warrior.Protection;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Protection = {
  AzsharasFontofPower              = Item(),
  BattlePotionofStrength           = Item(163224),
  GrongsPrimalRage                 = Item(165574),
  AshvanesRazorCoral               = Item()
};
local I = Item.Warrior.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Protection = HR.GUISettings.APL.Warrior.Protection
};


local EnemyRanges = {5}
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


local function EvaluateCycleAshvanesRazorCoral84(TargetUnit)
  return TargetUnit:DebuffStackP(S.RazorCoralDebuffDebuff) == 0
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, St
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
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 12"; end
    end
  end
  Aoe = function()
    -- thunder_clap
    if S.ThunderClap:IsCastableP() then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 14"; end
    end
    -- memory_of_lucid_dreams,if=buff.avatar.down
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffDownP(S.AvatarBuff)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 16"; end
    end
    -- demoralizing_shout,if=talent.booming_voice.enabled
    if S.DemoralizingShout:IsCastableP() and (S.BoomingVoice:IsAvailable()) then
      if HR.Cast(S.DemoralizingShout, Settings.Protection.GCDasOffGCD.DemoralizingShout) then return "demoralizing_shout 20"; end
    end
    -- anima_of_death,if=buff.last_stand.up
    if S.AnimaofDeath:IsCastableP() and (Player:BuffP(S.LastStandBuff)) then
      if HR.Cast(S.AnimaofDeath) then return "anima_of_death 24"; end
    end
    -- dragon_roar
    if S.DragonRoar:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.DragonRoar, Settings.Protection.GCDasOffGCD.DragonRoar) then return "dragon_roar 28"; end
    end
    -- revenge
    if S.Revenge:IsReadyP() then
      if HR.Cast(S.Revenge) then return "revenge 30"; end
    end
    -- use_item,name=grongs_primal_rage,if=buff.avatar.down|cooldown.thunder_clap.remains>=4
    if I.GrongsPrimalRage:IsReady() and (Player:BuffDownP(S.AvatarBuff) or S.ThunderClap:CooldownRemainsP() >= 4) then
      if HR.CastSuggested(I.GrongsPrimalRage) then return "grongs_primal_rage 32"; end
    end
    -- ravager
    if S.Ravager:IsCastableP() then
      if HR.Cast(S.Ravager) then return "ravager 38"; end
    end
    -- shield_block,if=cooldown.shield_slam.ready&buff.shield_block.down
    if S.ShieldBlock:IsReadyP() and (S.ShieldSlam:CooldownUpP() and Player:BuffDownP(S.ShieldBlockBuff)) then
      if HR.Cast(S.ShieldBlock, Settings.Protection.OffGCDasOffGCD.ShieldBlock) then return "shield_block 40"; end
    end
    -- shield_slam
    if S.ShieldSlam:IsCastableP() then
      if HR.Cast(S.ShieldSlam) then return "shield_slam 46"; end
    end
  end
  St = function()
    -- thunder_clap,if=spell_targets.thunder_clap=2&talent.unstoppable_force.enabled&buff.avatar.up
    if S.ThunderClap:IsCastableP() and (Cache.EnemiesCount[5] == 2 and S.UnstoppableForce:IsAvailable() and Player:BuffP(S.AvatarBuff)) then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 48"; end
    end
    -- shield_block,if=cooldown.shield_slam.ready&buff.shield_block.down
    if S.ShieldBlock:IsReadyP() and (S.ShieldSlam:CooldownUpP() and Player:BuffDownP(S.ShieldBlockBuff)) then
      if HR.Cast(S.ShieldBlock, Settings.Protection.OffGCDasOffGCD.ShieldBlock) then return "shield_block 54"; end
    end
    -- shield_slam,if=buff.shield_block.up
    if S.ShieldSlam:IsCastableP() and (Player:BuffP(S.ShieldBlockBuff)) then
      if HR.Cast(S.ShieldSlam) then return "shield_slam 60"; end
    end
    -- thunder_clap,if=(talent.unstoppable_force.enabled&buff.avatar.up)
    if S.ThunderClap:IsCastableP() and ((S.UnstoppableForce:IsAvailable() and Player:BuffP(S.AvatarBuff))) then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 64"; end
    end
    -- demoralizing_shout,if=talent.booming_voice.enabled
    if S.DemoralizingShout:IsCastableP() and (S.BoomingVoice:IsAvailable()) then
      if HR.Cast(S.DemoralizingShout, Settings.Protection.GCDasOffGCD.DemoralizingShout) then return "demoralizing_shout 70"; end
    end
    -- anima_of_death,if=buff.last_stand.up
    if S.AnimaofDeath:IsCastableP() and (Player:BuffP(S.LastStandBuff)) then
      if HR.Cast(S.AnimaofDeath) then return "anima_of_death 74"; end
    end
    -- shield_slam
    if S.ShieldSlam:IsCastableP() then
      if HR.Cast(S.ShieldSlam) then return "shield_slam 78"; end
    end
    -- use_item,name=ashvanes_razor_coral,target_if=debuff.razor_coral_debuff.stack=0
    if I.AshvanesRazorCoral:IsReady() then
      if HR.CastCycle(I.AshvanesRazorCoral, 5, EvaluateCycleAshvanesRazorCoral84) then return "ashvanes_razor_coral 88" end
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.stack>7&(cooldown.avatar.remains<5|buff.avatar.up)
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffStackP(S.RazorCoralDebuffDebuff) > 7 and (S.Avatar:CooldownRemainsP() < 5 or Player:BuffP(S.AvatarBuff))) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 89"; end
    end
    -- dragon_roar
    if S.DragonRoar:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.DragonRoar, Settings.Protection.GCDasOffGCD.DragonRoar) then return "dragon_roar 97"; end
    end
    -- thunder_clap
    if S.ThunderClap:IsCastableP() then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 99"; end
    end
    -- revenge
    if S.Revenge:IsReadyP() then
      if HR.Cast(S.Revenge) then return "revenge 101"; end
    end
    -- use_item,name=grongs_primal_rage,if=buff.avatar.down|cooldown.shield_slam.remains>=4
    if I.GrongsPrimalRage:IsReady() and (Player:BuffDownP(S.AvatarBuff) or S.ShieldSlam:CooldownRemainsP() >= 4) then
      if HR.CastSuggested(I.GrongsPrimalRage) then return "grongs_primal_rage 103"; end
    end
    -- ravager
    if S.Ravager:IsCastableP() then
      if HR.Cast(S.Ravager) then return "ravager 109"; end
    end
    -- devastate
    if S.Devastate:IsCastableP() then
      if HR.Cast(S.Devastate) then return "devastate 111"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- intercept,if=time=0
    if S.Intercept:IsCastableP() and (HL.CombatTime() == 0) then
      if HR.Cast(S.Intercept) then return "intercept 115"; end
    end
    -- use_items,if=cooldown.avatar.remains<=gcd|buff.avatar.up
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 118"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 120"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 122"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 124"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 126"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 128"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 130"; end
    end
    -- potion,if=buff.avatar.up|target.time_to_die<25
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvatarBuff) or Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 132"; end
    end
    -- ignore_pain,if=rage.deficit<25+20*talent.booming_voice.enabled*cooldown.demoralizing_shout.ready
    if S.IgnorePain:IsReadyP() and (Player:RageDeficit() < 25 + 20 * num(S.BoomingVoice:IsAvailable()) * num(S.DemoralizingShout:CooldownUpP())) then
      if HR.Cast(S.IgnorePain, Settings.Protection.OffGCDasOffGCD.IgnorePain) then return "ignore_pain 136"; end
    end
    -- worldvein_resonance,if=cooldown.avatar.remains<=2
    if S.WorldveinResonance:IsCastableP() and (S.Avatar:CooldownRemainsP() <= 2) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 142"; end
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 146"; end
    end
    -- memory_of_lucid_dreams
    if S.MemoryofLucidDreams:IsCastableP() then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 148"; end
    end
    -- concentrated_flame,if=buff.avatar.down&!dot.concentrated_flame_burn.remains>0|essence.the_crucible_of_flame.rank<3
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.AvatarBuff) and num(not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff))) > 0 or essence.the_crucible_of_flame.rank < 3) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 150"; end
    end
    -- last_stand,if=cooldown.anima_of_death.remains<=2
    if S.LastStand:IsCastableP() and (S.AnimaofDeath:CooldownRemainsP() <= 2) then
      if HR.Cast(S.LastStand) then return "last_stand 156"; end
    end
    -- avatar
    if S.Avatar:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Avatar, Settings.Protection.GCDasOffGCD.Avatar) then return "avatar 160"; end
    end
    -- run_action_list,name=aoe,if=spell_targets.thunder_clap>=3
    if (Cache.EnemiesCount[5] >= 3) then
      return Aoe();
    end
    -- call_action_list,name=st
    if (true) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(73, APL)
