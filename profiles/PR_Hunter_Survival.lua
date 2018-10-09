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
  BloodFury                             = Spell(20572),
  CoordinatedAssault                    = Spell(),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  Berserking                            = Spell(26297),
  BerserkingBuff                        = Spell(26297),
  CoordinatedAssaultBuff                = Spell(),
  BloodFuryBuff                         = Spell(20572),
  AspectoftheEagle                      = Spell(186289),
  AMurderofCrows                        = Spell(206505),
  Carve                                 = Spell(187708),
  ShrapnelBombDebuff                    = Spell(),
  WildfireBomb                          = Spell(),
  GuerrillaTactics                      = Spell(),
  MongooseBite                          = Spell(190928),
  LatentPoisonDebuff                    = Spell(),
  Chakrams                              = Spell(),
  KillCommand                           = Spell(),
  Butchery                              = Spell(212436),
  WildfireInfusion                      = Spell(),
  InternalBleedingDebuff                = Spell(),
  FlankingStrike                        = Spell(202800),
  WildfireBombDebuff                    = Spell(),
  SerpentSting                          = Spell(87935),
  SerpentStingDebuff                    = Spell(118253),
  VipersVenomBuff                       = Spell(),
  TermsofEngagement                     = Spell(),
  TipoftheSpearBuff                     = Spell(),
  RaptorStrike                          = Spell(186270),
  MongooseFuryBuff                      = Spell(190931),
  VipersVenom                           = Spell(),
  LatentPoison                          = Spell(),
  VenomousFangs                         = Spell(),
  AlphaPredator                         = Spell(),
  BirdsofPrey                           = Spell(),
  BlurofTalonsBuff                      = Spell(),
  UpCloseandPersonal                    = Spell(),
  WildernessSurvival                    = Spell(),
  ArcaneTorrent                         = Spell(50613)
};
local S = Spell.Hunter.Survival;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Survival = {
  ProlongedPower                   = Item(142117)
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
local VarCarveCdr = 0;

local EnemyRanges = {40}
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
  local Precombat, Cds, Cleave, MbApWfiSt, St, WfiSt
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet) then return "summon_pet 3"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 6"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() and Player:DebuffDownP(S.SteelTrapDebuff) then
      if HR.Cast(S.SteelTrap) then return "steel_trap 8"; end
    end
    -- harpoon
    if S.Harpoon:IsCastableP() then
      if HR.Cast(S.Harpoon) then return "harpoon 12"; end
    end
  end
  Cds = function()
    -- blood_fury,if=cooldown.coordinated_assault.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 14"; end
    end
    -- ancestral_call,if=cooldown.coordinated_assault.remains>30
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 18"; end
    end
    -- fireblood,if=cooldown.coordinated_assault.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 22"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 26"; end
    end
    -- berserking,if=cooldown.coordinated_assault.remains>60|time_to_die<11
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 60 or Target:TimeToDie() < 11) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 28"; end
    end
    -- potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)|time_to_die<26
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll") and not Player:IsRace("Orc")) or Target:TimeToDie() < 26) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 38"; end
    end
    -- aspect_of_the_eagle,if=target.distance>=6
    if S.AspectoftheEagle:IsCastableP() and (target.distance >= 6) then
      if HR.Cast(S.AspectoftheEagle) then return "aspect_of_the_eagle 50"; end
    end
  end
  Cleave = function()
    -- variable,name=carve_cdr,op=setif,value=active_enemies,value_else=5,condition=active_enemies<5
    if  then
      if HR.CastCycle(VarCarveCdr, 40, function(TargetUnit) return (Cache.EnemiesCount[40] < 5) and (Cache.EnemiesCount[40] < 5) end) then return "carve_cdr 74" end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 75"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() then
      if HR.Cast(S.CoordinatedAssault) then return "coordinated_assault 77"; end
    end
    -- carve,if=dot.shrapnel_bomb.ticking
    if S.Carve:IsCastableP() and (TargetUnit:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.Carve) then return "carve 79"; end
    end
    -- wildfire_bomb,if=!talent.guerrilla_tactics.enabled|full_recharge_time<gcd
    if S.WildfireBomb:IsCastableP() and (not S.GuerrillaTactics:IsAvailable() or S.WildfireBomb:FullRechargeTimeP() < Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 83"; end
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack,if=debuff.latent_poison.stack=10
    if S.MongooseBite:IsCastableP() then
      if HR.CastTargetIf(S.MongooseBite, 40, "max", function(TargetUnit) return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) end, function(TargetUnit) return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) == 10 end) then return "mongoose_bite 99" end
    end
    -- chakrams
    if S.Chakrams:IsCastableP() then
      if HR.Cast(S.Chakrams) then return "chakrams 100"; end
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() then
      if HR.CastTargetIf(S.KillCommand, 40, "min", function(TargetUnit) return min:bloodseeker.remains end, function(TargetUnit) return Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() end) then return "kill_command 112" end
    end
    -- butchery,if=full_recharge_time<gcd|!talent.wildfire_infusion.enabled|dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3
    if S.Butchery:IsCastableP() and (S.Butchery:FullRechargeTimeP() < Player:GCD() or not S.WildfireInfusion:IsAvailable() or TargetUnit:DebuffP(S.ShrapnelBombDebuff) and TargetUnit:DebuffStackP(S.InternalBleedingDebuff) < 3) then
      if HR.Cast(S.Butchery) then return "butchery 113"; end
    end
    -- carve,if=talent.guerrilla_tactics.enabled
    if S.Carve:IsCastableP() and (S.GuerrillaTactics:IsAvailable()) then
      if HR.Cast(S.Carve) then return "carve 125"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 129"; end
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable|talent.wildfire_infusion.enabled
    if S.WildfireBomb:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.WildfireBombDebuff) or S.WildfireInfusion:IsAvailable()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 137"; end
    end
    -- serpent_sting,target_if=min:remains,if=buff.vipers_venom.up
    if S.SerpentSting:IsCastableP() then
      if HR.CastTargetIf(S.SerpentSting, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff) end, function(TargetUnit) return Player:BuffP(S.VipersVenomBuff) end) then return "serpent_sting 155" end
    end
    -- carve,if=cooldown.wildfire_bomb.remains>variable.carve_cdr%2
    if S.Carve:IsCastableP() and (S.WildfireBomb:CooldownRemainsP() > VarCarveCdr / 2) then
      if HR.Cast(S.Carve) then return "carve 156"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 162"; end
    end
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
      if HR.Cast(S.Harpoon) then return "harpoon 164"; end
    end
    -- serpent_sting,target_if=min:remains,if=refreshable&buff.tip_of_the_spear.stack<3
    if S.SerpentSting:IsCastableP() then
      if HR.CastTargetIf(S.SerpentSting, 40, "min", function(TargetUnit) return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff) end, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffStackP(S.TipoftheSpearBuff) < 3 end) then return "serpent_sting 186" end
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack
    if S.MongooseBite:IsCastableP() then
      if HR.CastTargetIf(S.MongooseBite, 40, "max", function(TargetUnit) return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) end) then return "mongoose_bite 193" end
    end
    -- raptor_strike,target_if=max:debuff.latent_poison.stack
    if S.RaptorStrike:IsCastableP() then
      if HR.CastTargetIf(S.RaptorStrike, 40, "max", function(TargetUnit) return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) end) then return "raptor_strike 200" end
    end
  end
  MbApWfiSt = function()
    -- serpent_sting,if=!dot.serpent_sting.ticking
    if S.SerpentSting:IsCastableP() and (not TargetUnit:DebuffP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 201"; end
    end
    -- wildfire_bomb,if=full_recharge_time<gcd|(focus+cast_regen<focus.max)&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() or (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax()) and (bool(next_wi_bomb.volatile) and TargetUnit:DebuffP(S.SerpentStingDebuff) and TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) or bool(next_wi_bomb.pheromone) and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 205"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() then
      if HR.Cast(S.CoordinatedAssault) then return "coordinated_assault 235"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 237"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 239"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.remains&next_wi_bomb.pheromone
    if S.MongooseBite:IsCastableP() and (bool(Player:BuffRemainsP(S.MongooseFuryBuff)) and bool(next_wi_bomb.pheromone)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 241"; end
    end
    -- kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and (Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())) then
      if HR.Cast(S.KillCommand) then return "kill_command 245"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&focus>60&dot.serpent_sting.remains>3*gcd
    if S.WildfireBomb:IsCastableP() and (bool(next_wi_bomb.shrapnel) and Player:Focus() > 60 and TargetUnit:DebuffRemainsP(S.SerpentStingDebuff) > 3 * Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 259"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|!talent.vipers_venom.enabled|next_wi_bomb.volatile&!dot.shrapnel_bomb.ticking|azerite.latent_poison.enabled|azerite.venomous_fangs.enabled)
    if S.SerpentSting:IsCastableP() and (Player:BuffP(S.VipersVenomBuff) or TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and (not S.MongooseBite:IsAvailable() or not S.VipersVenom:IsAvailable() or bool(next_wi_bomb.volatile) and not TargetUnit:DebuffP(S.ShrapnelBombDebuff) or S.LatentPoison:AzeriteEnabled() or S.VenomousFangs:AzeriteEnabled())) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 263"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60 or TargetUnit:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 283"; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 289"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
    if S.WildfireBomb:IsCastableP() and (bool(next_wi_bomb.volatile) and TargetUnit:DebuffP(S.SerpentStingDebuff) or bool(next_wi_bomb.pheromone) or bool(next_wi_bomb.shrapnel) and Player:Focus() > 50) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 297"; end
    end
  end
  St = function()
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 301"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() then
      if HR.Cast(S.CoordinatedAssault) then return "coordinated_assault 303"; end
    end
    -- wildfire_bomb,if=full_recharge_time<gcd&talent.alpha_predator.enabled
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() and S.AlphaPredator:IsAvailable()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 305"; end
    end
    -- serpent_sting,if=refreshable&buff.mongoose_fury.stack=5&talent.alpha_predator.enabled
    if S.SerpentSting:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffStackP(S.MongooseFuryBuff) == 5 and S.AlphaPredator:IsAvailable()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 313"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.stack=5&talent.alpha_predator.enabled
    if S.MongooseBite:IsCastableP() and (Player:BuffStackP(S.MongooseFuryBuff) == 5 and S.AlphaPredator:IsAvailable()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 325"; end
    end
    -- raptor_strike,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&(buff.coordinated_assault.remains<gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd)
    if S.RaptorStrike:IsCastableP() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD())) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 331"; end
    end
    -- mongoose_bite,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&(buff.coordinated_assault.remains<gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd)
    if S.MongooseBite:IsCastableP() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD())) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 343"; end
    end
    -- kill_command,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
      if HR.Cast(S.KillCommand) then return "kill_command 355"; end
    end
    -- chakrams
    if S.Chakrams:IsCastableP() then
      if HR.Cast(S.Chakrams) then return "chakrams 365"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 367"; end
    end
    -- wildfire_bomb,if=focus+cast_regen<focus.max&(full_recharge_time<gcd|dot.wildfire_bomb.refreshable&buff.mongoose_fury.down)
    if S.WildfireBomb:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() or TargetUnit:DebuffRefreshableCP(S.WildfireBombDebuff) and Player:BuffDownP(S.MongooseFuryBuff))) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 369"; end
    end
    -- harpoon,if=talent.terms_of_engagement.enabled|azerite.up_close_and_personal.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable() or S.UpCloseandPersonal:AzeriteEnabled()) then
      if HR.Cast(S.Harpoon) then return "harpoon 385"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 391"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|!talent.vipers_venom.enabled|azerite.latent_poison.enabled|azerite.venomous_fangs.enabled)
    if S.SerpentSting:IsCastableP() and (Player:BuffP(S.VipersVenomBuff) or TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and (not S.MongooseBite:IsAvailable() or not S.VipersVenom:IsAvailable() or S.LatentPoison:AzeriteEnabled() or S.VenomousFangs:AzeriteEnabled())) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 399"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus>60
    if S.MongooseBite:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 417"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsCastableP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 421"; end
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable
    if S.WildfireBomb:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.WildfireBombDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 423"; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 427"; end
    end
  end
  WfiSt = function()
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 435"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() then
      if HR.Cast(S.CoordinatedAssault) then return "coordinated_assault 437"; end
    end
    -- mongoose_bite,if=azerite.wilderness_survival.enabled&next_wi_bomb.volatile&dot.serpent_sting.remains>2.1*gcd&dot.serpent_sting.remains<3.5*gcd&cooldown.wildfire_bomb.remains>2.5*gcd
    if S.MongooseBite:IsCastableP() and (S.WildernessSurvival:AzeriteEnabled() and bool(next_wi_bomb.volatile) and TargetUnit:DebuffRemainsP(S.SerpentStingDebuff) > 2.1 * Player:GCD() and TargetUnit:DebuffRemainsP(S.SerpentStingDebuff) < 3.5 * Player:GCD() and S.WildfireBomb:CooldownRemainsP() > 2.5 * Player:GCD()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 439"; end
    end
    -- wildfire_bomb,if=full_recharge_time<gcd|(focus+cast_regen<focus.max)&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() or (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax()) and (bool(next_wi_bomb.volatile) and TargetUnit:DebuffP(S.SerpentStingDebuff) and TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) or bool(next_wi_bomb.pheromone) and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 449"; end
    end
    -- kill_command,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3&(!talent.alpha_predator.enabled|buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3 and (not S.AlphaPredator:IsAvailable() or Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())) then
      if HR.Cast(S.KillCommand) then return "kill_command 479"; end
    end
    -- raptor_strike,if=dot.internal_bleeding.stack<3&dot.shrapnel_bomb.ticking&!talent.mongoose_bite.enabled
    if S.RaptorStrike:IsCastableP() and (TargetUnit:DebuffStackP(S.InternalBleedingDebuff) < 3 and TargetUnit:DebuffP(S.ShrapnelBombDebuff) and not S.MongooseBite:IsAvailable()) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 497"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&buff.mongoose_fury.down&(cooldown.kill_command.remains>gcd|focus>60)&!dot.serpent_sting.refreshable
    if S.WildfireBomb:IsCastableP() and (bool(next_wi_bomb.shrapnel) and Player:BuffDownP(S.MongooseFuryBuff) and (S.KillCommand:CooldownRemainsP() > Player:GCD() or Player:Focus() > 60) and not TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 505"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 513"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 515"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|!talent.vipers_venom.enabled|next_wi_bomb.volatile&!dot.shrapnel_bomb.ticking|azerite.latent_poison.enabled|azerite.venomous_fangs.enabled|buff.mongoose_fury.stack=5)
    if S.SerpentSting:IsCastableP() and (Player:BuffP(S.VipersVenomBuff) or TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and (not S.MongooseBite:IsAvailable() or not S.VipersVenom:IsAvailable() or bool(next_wi_bomb.volatile) and not TargetUnit:DebuffP(S.ShrapnelBombDebuff) or S.LatentPoison:AzeriteEnabled() or S.VenomousFangs:AzeriteEnabled() or Player:BuffStackP(S.MongooseFuryBuff) == 5)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 523"; end
    end
    -- harpoon,if=talent.terms_of_engagement.enabled|azerite.up_close_and_personal.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable() or S.UpCloseandPersonal:AzeriteEnabled()) then
      if HR.Cast(S.Harpoon) then return "harpoon 545"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60 or TargetUnit:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 551"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsCastableP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 557"; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsCastableP() and (TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 559"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
    if S.WildfireBomb:IsCastableP() and (bool(next_wi_bomb.volatile) and TargetUnit:DebuffP(S.SerpentStingDebuff) or bool(next_wi_bomb.pheromone) or bool(next_wi_bomb.shrapnel) and Player:Focus() > 50) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 567"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- use_items
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=mb_ap_wfi_st,if=active_enemies<2&talent.wildfire_infusion.enabled&talent.alpha_predator.enabled&talent.mongoose_bite.enabled
    if (Cache.EnemiesCount[40] < 2 and S.WildfireInfusion:IsAvailable() and S.AlphaPredator:IsAvailable() and S.MongooseBite:IsAvailable()) then
      return MbApWfiSt();
    end
    -- run_action_list,name=wfi_st,if=active_enemies<2&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[40] < 2 and S.WildfireInfusion:IsAvailable()) then
      return WfiSt();
    end
    -- run_action_list,name=st,if=active_enemies<2
    if (Cache.EnemiesCount[40] < 2) then
      return St();
    end
    -- run_action_list,name=cleave
    if (true) then
      return Cleave();
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 610"; end
    end
  end
end

HR.SetAPL(255, APL)
