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
  Avatar                                = Spell(107574),
  DemoralizingShout                     = Spell(),
  Ravager                               = Spell(),
  DragonRoar                            = Spell(),
  ThunderClap                           = Spell(),
  UnstoppableForce                      = Spell(),
  AvatarBuff                            = Spell(107574),
  DemoralizingShoutDebuffDebuff         = Spell(),
  ShieldBlock                           = Spell(),
  ShieldSlam                            = Spell(),
  ShieldBlockBuff                       = Spell(),
  LastStandBuff                         = Spell(),
  LastStand                             = Spell(),
  Revenge                               = Spell(),
  Vengeance                             = Spell(),
  RevengeBuff                           = Spell(),
  VengeanceIgnorePainBuff               = Spell(),
  VengeanceRevengeBuff                  = Spell(),
  IgnorePain                            = Spell(),
  Devastate                             = Spell(),
  Intercept                             = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738)
};
local S = Spell.Warrior.Protection;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Protection = {
  BattlePotionofStrength           = Item(163224),
  RampingAmplitudeGigavoltEngine   = Item()
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


local EnemyRanges = {}
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
  local Precombat, Prot
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 4"; end
    end
  end
  Prot = function()
    -- potion,if=target.time_to_die<25
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and (Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 6"; end
    end
    -- avatar,if=(cooldown.demoralizing_shout.ready|cooldown.demoralizing_shout.remains>2)
    if S.Avatar:IsCastableP() and HR.CDsON() and ((S.DemoralizingShout:CooldownUpP() or S.DemoralizingShout:CooldownRemainsP() > 2)) then
      if HR.Cast(S.Avatar, Settings.Protection.GCDasOffGCD.Avatar) then return "avatar 8"; end
    end
    -- demoralizing_shout
    if S.DemoralizingShout:IsCastableP() then
      if HR.Cast(S.DemoralizingShout) then return "demoralizing_shout 14"; end
    end
    -- ravager
    if S.Ravager:IsCastableP() then
      if HR.Cast(S.Ravager) then return "ravager 16"; end
    end
    -- dragon_roar
    if S.DragonRoar:IsCastableP() then
      if HR.Cast(S.DragonRoar) then return "dragon_roar 18"; end
    end
    -- thunder_clap,if=(talent.unstoppable_force.enabled&buff.avatar.up&debuff.demoralizing_shout_debuff.up)
    if S.ThunderClap:IsCastableP() and ((S.UnstoppableForce:IsAvailable() and Player:BuffP(S.AvatarBuff) and Target:DebuffP(S.DemoralizingShoutDebuffDebuff))) then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 20"; end
    end
    -- shield_block,if=(cooldown.shield_slam.ready&buff.shield_block.down&buff.last_stand.down)
    if S.ShieldBlock:IsCastableP() and ((S.ShieldSlam:CooldownUpP() and Player:BuffDownP(S.ShieldBlockBuff) and Player:BuffDownP(S.LastStandBuff))) then
      if HR.Cast(S.ShieldBlock) then return "shield_block 28"; end
    end
    -- last_stand,if=buff.shield_block.down
    if S.LastStand:IsCastableP() and (Player:BuffDownP(S.ShieldBlockBuff)) then
      if HR.Cast(S.LastStand) then return "last_stand 36"; end
    end
    -- shield_slam
    if S.ShieldSlam:IsCastableP() then
      if HR.Cast(S.ShieldSlam) then return "shield_slam 40"; end
    end
    -- thunder_clap
    if S.ThunderClap:IsCastableP() then
      if HR.Cast(S.ThunderClap) then return "thunder_clap 42"; end
    end
    -- revenge,if=(!talent.vengeance.enabled)|(talent.vengeance.enabled&buff.revenge.react&!buff.vengeance_ignore_pain.up)|(buff.vengeance_revenge.up)|(talent.vengeance.enabled&!buff.vengeance_ignore_pain.up&!buff.vengeance_revenge.up&rage>=30)
    if S.Revenge:IsCastableP() and ((not S.Vengeance:IsAvailable()) or (S.Vengeance:IsAvailable() and bool(Player:BuffStackP(S.RevengeBuff)) and not Player:BuffP(S.VengeanceIgnorePainBuff)) or (Player:BuffP(S.VengeanceRevengeBuff)) or (S.Vengeance:IsAvailable() and not Player:BuffP(S.VengeanceIgnorePainBuff) and not Player:BuffP(S.VengeanceRevengeBuff) and Player:Rage() >= 30)) then
      if HR.Cast(S.Revenge) then return "revenge 44"; end
    end
    -- ignore_pain,use_off_gcd=1,if=rage>70
    if S.IgnorePain:IsCastableP() and (Player:Rage() > 70) then
      if HR.Cast(S.IgnorePain) then return "ignore_pain 62"; end
    end
    -- devastate
    if S.Devastate:IsCastableP() then
      if HR.Cast(S.Devastate) then return "devastate 64"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- intercept
    if S.Intercept:IsCastableP() then
      if HR.Cast(S.Intercept) then return "intercept 68"; end
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine
    if I.RampingAmplitudeGigavoltEngine:IsReady() then
      if HR.CastSuggested(I.RampingAmplitudeGigavoltEngine) then return "ramping_amplitude_gigavolt_engine 70"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 72"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 74"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 76"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 78"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 80"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 82"; end
    end
    -- call_action_list,name=prot
    if (true) then
      local ShouldReturn = Prot(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(73, APL)
