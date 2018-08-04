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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.Survival = {
  SummonPet                             = Spell(),
  SteelTrapDebuff                       = Spell(162487),
  SteelTrap                             = Spell(162488),
  Harpoon                               = Spell(190925),
  Muzzle                                = Spell(187707),
  BuffSephuzsSecret                     = Spell(),
  SephuzsSecretBuff                     = Spell(208052),
  Berserking                            = Spell(26297),
  CoordinatedAssault                    = Spell(),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  CoordinatedAssaultBuff                = Spell(),
  BerserkingBuff                        = Spell(26297),
  BloodFuryBuff                         = Spell(20572),
  MongooseBite                          = Spell(190928),
  MongooseFuryBuff                      = Spell(190931),
  AMurderofCrows                        = Spell(206505),
  Chakrams                              = Spell(),
  KillCommand                           = Spell(),
  TipoftheSpearBuff                     = Spell(),
  WildfireBomb                          = Spell(),
  WildfireBombDebuff                    = Spell(),
  Butchery                              = Spell(212436),
  WildfireInfusion                      = Spell(),
  ShrapnelBombDebuff                    = Spell(),
  InternalBleedingDebuff                = Spell(),
  SerpentSting                          = Spell(87935),
  SerpentStingDebuff                    = Spell(118253),
  VipersVenom                           = Spell(),
  VipersVenomBuff                       = Spell(),
  Carve                                 = Spell(187708),
  TermsofEngagement                     = Spell(),
  FlankingStrike                        = Spell(202800),
  AspectoftheEagle                      = Spell(186289),
  MongooseBiteEagle                     = Spell(),
  RaptorStrikeEagle                     = Spell(),
  RaptorStrike                          = Spell(186270)
};
local S = Spell.Hunter.Survival;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Survival = {
  ProlongedPower                   = Item(142117),
  SephuzsSecret                    = Item(132452)
};
local I = Item.Hunter.Survival;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  Survival = HR.GUISettings.APL.Hunter.Survival
};

-- Variables
local VarCanGcd = 0;

local EnemyRanges = {8, 40}
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
  local Precombat
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() and (true) then
      if HR.Cast(S.SummonPet) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() and Player:DebuffDownP(S.SteelTrapDebuff) and (true) then
      if HR.Cast(S.SteelTrap) then return ""; end
    end
    -- harpoon
    if S.Harpoon:IsCastableP() and (true) then
      if HR.Cast(S.Harpoon) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- muzzle,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
  if S.Muzzle:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (I.SephuzsSecret:IsEquipped() and Target:IsCasting() and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
    if HR.CastAnnotated(S.Muzzle, false, "Interrupt") then return ""; end
  end
  -- use_items
  -- berserking,if=cooldown.coordinated_assault.remains>30
  if S.Berserking:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
    if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- blood_fury,if=cooldown.coordinated_assault.remains>30
  if S.BloodFury:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
    if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- ancestral_call,if=cooldown.coordinated_assault.remains>30
  if S.AncestralCall:IsCastableP() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
    if HR.Cast(S.AncestralCall) then return ""; end
  end
  -- fireblood,if=cooldown.coordinated_assault.remains>30
  if S.Fireblood:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
    if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- lights_judgment
  if S.LightsJudgment:IsCastableP() and HR.CDsON() and (true) then
    if HR.Cast(S.LightsJudgment) then return ""; end
  end
  -- potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll") and not Player:IsRace("Orc"))) then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- variable,name=can_gcd,value=!talent.mongoose_bite.enabled|buff.mongoose_fury.down|(buff.mongoose_fury.remains-(((buff.mongoose_fury.remains*focus.regen+focus)%action.mongoose_bite.cost)*gcd.max)>gcd.max)
  if (true) then
    VarCanGcd = num(not S.MongooseBite:IsAvailable() or Player:BuffDownP(S.MongooseFuryBuff) or (Player:BuffRemainsP(S.MongooseFuryBuff) - (((Player:BuffRemainsP(S.MongooseFuryBuff) * Player:FocusRegen() + Player:Focus()) / S.MongooseBite:Cost()) * Player:GCD()) > Player:GCD()))
  end
  -- steel_trap
  if S.SteelTrap:IsCastableP() and (true) then
    if HR.Cast(S.SteelTrap) then return ""; end
  end
  -- a_murder_of_crows
  if S.AMurderofCrows:IsCastableP() and (true) then
    if HR.Cast(S.AMurderofCrows) then return ""; end
  end
  -- coordinated_assault
  if S.CoordinatedAssault:IsCastableP() and (true) then
    if HR.Cast(S.CoordinatedAssault) then return ""; end
  end
  -- chakrams,if=active_enemies>1
  if S.Chakrams:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
    if HR.Cast(S.Chakrams) then return ""; end
  end
  -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3&active_enemies<2
  if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3 and Cache.EnemiesCount[40] < 2) then
    if HR.Cast(S.KillCommand) then return ""; end
  end
  -- wildfire_bomb,if=(focus+cast_regen<focus.max|active_enemies>1)&(dot.wildfire_bomb.refreshable&buff.mongoose_fury.down|full_recharge_time<gcd)
  if S.WildfireBomb:IsCastableP() and ((Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() or Cache.EnemiesCount[40] > 1) and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) and Player:BuffDownP(S.MongooseFuryBuff) or S.WildfireBomb:FullRechargeTimeP() < Player:GCD())) then
    if HR.Cast(S.WildfireBomb) then return ""; end
  end
  -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
  if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
    if HR.Cast(S.KillCommand) then return ""; end
  end
  -- butchery,if=(!talent.wildfire_infusion.enabled|full_recharge_time<gcd)&active_enemies>3|(dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3)
  if S.Butchery:IsCastableP() and ((not S.WildfireInfusion:IsAvailable() or S.Butchery:FullRechargeTimeP() < Player:GCD()) and Cache.EnemiesCount[40] > 3 or (Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleedingDebuff) < 3)) then
    if HR.Cast(S.Butchery) then return ""; end
  end
  -- serpent_sting,if=(active_enemies<2&refreshable&(buff.mongoose_fury.down|(variable.can_gcd&!talent.vipers_venom.enabled)))|buff.vipers_venom.up
  if S.SerpentSting:IsCastableP() and ((Cache.EnemiesCount[40] < 2 and Target:DebuffRefreshableCP(S.SerpentStingDebuff) and (Player:BuffDownP(S.MongooseFuryBuff) or (bool(VarCanGcd) and not S.VipersVenom:IsAvailable()))) or Player:BuffP(S.VipersVenomBuff)) then
    if HR.Cast(S.SerpentSting) then return ""; end
  end
  -- carve,if=active_enemies>2&(active_enemies<6&active_enemies+gcd<cooldown.wildfire_bomb.remains|5+gcd<cooldown.wildfire_bomb.remains)
  if S.Carve:IsCastableP() and (Cache.EnemiesCount[8] > 2 and (Cache.EnemiesCount[8] < 6 and Cache.EnemiesCount[8] + Player:GCD() < S.WildfireBomb:CooldownRemainsP() or 5 + Player:GCD() < S.WildfireBomb:CooldownRemainsP())) then
    if HR.Cast(S.Carve) then return ""; end
  end
  -- harpoon,if=talent.terms_of_engagement.enabled
  if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
    if HR.Cast(S.Harpoon) then return ""; end
  end
  -- flanking_strike
  if S.FlankingStrike:IsCastableP() and (true) then
    if HR.Cast(S.FlankingStrike) then return ""; end
  end
  -- chakrams
  if S.Chakrams:IsCastableP() and (true) then
    if HR.Cast(S.Chakrams) then return ""; end
  end
  -- serpent_sting,target_if=min:remains,if=refreshable&buff.mongoose_fury.down|buff.vipers_venom.up
  if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffDownP(S.MongooseFuryBuff) or Player:BuffP(S.VipersVenomBuff)) then
    if HR.Cast(S.SerpentSting) then return ""; end
  end
  -- aspect_of_the_eagle,if=target.distance>=6
  if S.AspectoftheEagle:IsCastableP() and (target.distance >= 6) then
    if HR.Cast(S.AspectoftheEagle) then return ""; end
  end
  -- mongoose_bite_eagle,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
  if S.MongooseBiteEagle:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
    if HR.Cast(S.MongooseBiteEagle) then return ""; end
  end
  -- mongoose_bite,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
  if S.MongooseBite:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
    if HR.Cast(S.MongooseBite) then return ""; end
  end
  -- butchery
  if S.Butchery:IsCastableP() and (true) then
    if HR.Cast(S.Butchery) then return ""; end
  end
  -- raptor_strike_eagle,target_if=min:dot.internal_bleeding.stack
  if S.RaptorStrikeEagle:IsCastableP() and (true) then
    if HR.Cast(S.RaptorStrikeEagle) then return ""; end
  end
  -- raptor_strike,target_if=min:dot.internal_bleeding.stack
  if S.RaptorStrike:IsCastableP() and (true) then
    if HR.Cast(S.RaptorStrike) then return ""; end
  end
end

HR.SetAPL(255, APL)
