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
if not Spell.Priest then Spell.Priest = {} end
Spell.Priest.Shadow = {
  ShadowformBuff                        = Spell(232698),
  Shadowform                            = Spell(232698),
  MindBlast                             = Spell(8092),
  ShadowWordVoid                        = Spell(205351),
  VoidEruption                          = Spell(228260),
  DarkAscension                         = Spell(280711),
  VoidformBuff                          = Spell(194249),
  VoidBolt                              = Spell(205448),
  DarkVoid                              = Spell(263346),
  ShadowWordPainDebuff                  = Spell(589),
  SurrenderToMadness                    = Spell(193223),
  Mindbender                            = Spell(200174),
  ShadowCrash                           = Spell(205385),
  MindSear                              = Spell(48045),
  ShadowWordPain                        = Spell(589),
  ShadowWordDeath                       = Spell(32379),
  Misery                                = Spell(238558),
  VampiricTouch                         = Spell(34914),
  VampiricTouchDebuff                   = Spell(34914),
  VoidTorrent                           = Spell(263165),
  MindFlay                              = Spell(15407),
  Berserking                            = Spell(26297)
};
local S = Spell.Priest.Shadow;

-- Items
if not Item.Priest then Item.Priest = {} end
Item.Priest.Shadow = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Priest.Shadow;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Priest.Commons,
  Shadow = HR.GUISettings.APL.Priest.Shadow
};

-- Variables
local VarDotsUp = 0;

HL:RegisterForEvent(function()
  VarDotsUp = 0
end, "PLAYER_REGEN_ENABLED")

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

local function InsanityThreshold ()
	return S.LegacyOfTheVoid:IsAvailable() and 60 or 90;
end
local function ExecuteRange ()
	return 20;
end

local function EvaluateCycleShadowWordDeath58(TargetUnit)
  return TargetUnit:TimeToDie() < 3 or Player:BuffDownP(S.VoidformBuff)
end

local function EvaluateCycleShadowWordPain79(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.ShadowWordPainDebuff) and TargetUnit:TimeToDie() > 4) and (not S.Misery:IsAvailable() and not S.DarkVoid:IsAvailable())
end

local function EvaluateCycleVampiricTouch96(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.VampiricTouchDebuff)) and ((TargetUnit:TimeToDie() > 6))
end

local function EvaluateCycleVampiricTouch109(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.ShadowWordPainDebuff)) and ((S.Misery:IsAvailable() and TargetUnit:TimeToDie() > 4))
end

local function EvaluateCycleMindSear124(TargetUnit)
  return Cache.EnemiesCount[40] > 2
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cleave, Single
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
    -- shadowform,if=!buff.shadowform.up
    if S.Shadowform:IsCastableP() and Player:BuffDownP(S.ShadowformBuff) and (not Player:BuffP(S.ShadowformBuff)) then
      if HR.Cast(S.Shadowform) then return "shadowform 6"; end
    end
    -- mind_blast
    if S.MindBlast:IsReadyP() and Everyone.TargetIsValid() then
      if HR.Cast(S.MindBlast) then return "mind_blast 12"; end
    end
    -- shadow_word_void
    if S.ShadowWordVoid:IsReadyP() and Everyone.TargetIsValid() then
      if HR.Cast(S.ShadowWordVoid) then return "shadow_word_void 14"; end
    end
  end
  Aoe = function()
    -- void_eruption
    if S.VoidEruption:IsReadyP() then
      if HR.Cast(S.VoidEruption) then return "void_eruption 16"; end
    end
    -- dark_ascension,if=buff.voidform.down
    if S.DarkAscension:IsReadyP() and (Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.DarkAscension) then return "dark_ascension 18"; end
    end
    -- void_bolt,if=talent.dark_void.enabled&dot.shadow_word_pain.remains>travel_time
    if S.VoidBolt:IsReadyP() and (S.DarkVoid:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) > S.VoidBolt:TravelTime()) then
      if HR.Cast(S.VoidBolt) then return "void_bolt 22"; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
    if S.SurrenderToMadness:IsReadyP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness) then return "surrender_to_madness 32"; end
    end
    -- dark_void,if=raid_event.adds.in>10
    if S.DarkVoid:IsReadyP() and (10000000000 > 10) then
      if HR.Cast(S.DarkVoid) then return "dark_void 36"; end
    end
    -- mindbender
    if S.Mindbender:IsReadyP() then
      if HR.Cast(S.Mindbender) then return "mindbender 38"; end
    end
    -- shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if S.ShadowCrash:IsReadyP() and (10000000000 > 5 and raid_event.adds.duration < 20) then
      if HR.Cast(S.ShadowCrash) then return "shadow_crash 40"; end
    end
    -- mind_sear,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindSear:IsCastableP() then
      if HR.Cast(S.MindSear) then return "mind_sear 42"; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 44"; end
    end
  end
  Cleave = function()
    -- void_eruption
    if S.VoidEruption:IsReadyP() then
      if HR.Cast(S.VoidEruption) then return "void_eruption 46"; end
    end
    -- dark_ascension,if=buff.voidform.down
    if S.DarkAscension:IsReadyP() and (Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.DarkAscension) then return "dark_ascension 48"; end
    end
    -- void_bolt
    if S.VoidBolt:IsReadyP() then
      if HR.Cast(S.VoidBolt) then return "void_bolt 52"; end
    end
    -- shadow_word_death,target_if=target.time_to_die<3|buff.voidform.down
    if S.ShadowWordDeath:IsReadyP() then
      if HR.CastCycle(S.ShadowWordDeath, 40, EvaluateCycleShadowWordDeath58) then return "shadow_word_death 62" end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
    if S.SurrenderToMadness:IsReadyP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness) then return "surrender_to_madness 63"; end
    end
    -- dark_void,if=raid_event.adds.in>10
    if S.DarkVoid:IsReadyP() and (10000000000 > 10) then
      if HR.Cast(S.DarkVoid) then return "dark_void 67"; end
    end
    -- mindbender
    if S.Mindbender:IsReadyP() then
      if HR.Cast(S.Mindbender) then return "mindbender 69"; end
    end
    -- mind_blast
    if S.MindBlast:IsReadyP() then
      if HR.Cast(S.MindBlast) then return "mind_blast 71"; end
    end
    -- shadow_crash,if=(raid_event.adds.in>5&raid_event.adds.duration<2)|raid_event.adds.duration>2
    if S.ShadowCrash:IsReadyP() and ((10000000000 > 5 and raid_event.adds.duration < 2) or raid_event.adds.duration > 2) then
      if HR.Cast(S.ShadowCrash) then return "shadow_crash 73"; end
    end
    -- shadow_word_pain,target_if=refreshable&target.time_to_die>4,if=!talent.misery.enabled&!talent.dark_void.enabled
    if S.ShadowWordPain:IsCastableP() then
      if HR.CastCycle(S.ShadowWordPain, 40, EvaluateCycleShadowWordPain79) then return "shadow_word_pain 91" end
    end
    -- vampiric_touch,target_if=refreshable,if=(target.time_to_die>6)
    if S.VampiricTouch:IsCastableP() then
      if HR.CastCycle(S.VampiricTouch, 40, EvaluateCycleVampiricTouch96) then return "vampiric_touch 104" end
    end
    -- vampiric_touch,target_if=dot.shadow_word_pain.refreshable,if=(talent.misery.enabled&target.time_to_die>4)
    if S.VampiricTouch:IsCastableP() then
      if HR.CastCycle(S.VampiricTouch, 40, EvaluateCycleVampiricTouch109) then return "vampiric_touch 115" end
    end
    -- void_torrent,if=buff.voidform.up
    if S.VoidTorrent:IsReadyP() and (Player:BuffP(S.VoidformBuff)) then
      if HR.Cast(S.VoidTorrent) then return "void_torrent 116"; end
    end
    -- mind_sear,target_if=spell_targets.mind_sear>2,chain=1,interrupt=1
    if S.MindSear:IsCastableP() then
      if HR.CastCycle(S.MindSear, 40, EvaluateCycleMindSear124) then return "mind_sear 126" end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return "mind_flay 127"; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 129"; end
    end
  end
  Single = function()
    -- void_eruption
    if S.VoidEruption:IsReadyP() then
      if HR.Cast(S.VoidEruption) then return "void_eruption 131"; end
    end
    -- dark_ascension,if=buff.voidform.down
    if S.DarkAscension:IsReadyP() and (Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.DarkAscension) then return "dark_ascension 133"; end
    end
    -- void_bolt
    if S.VoidBolt:IsReadyP() then
      if HR.Cast(S.VoidBolt) then return "void_bolt 137"; end
    end
    -- shadow_word_death,if=target.time_to_die<3|cooldown.shadow_word_death.charges=2|(cooldown.shadow_word_death.charges=1&cooldown.shadow_word_death.remains<gcd.max)
    if S.ShadowWordDeath:IsReadyP() and (Target:TimeToDie() < 3 or S.ShadowWordDeath:ChargesP() == 2 or (S.ShadowWordDeath:ChargesP() == 1 and S.ShadowWordDeath:CooldownRemainsP() < Player:GCD())) then
      if HR.Cast(S.ShadowWordDeath) then return "shadow_word_death 139"; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)&target.time_to_die>200|target.time_to_die<75
    if S.SurrenderToMadness:IsReadyP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism())) and Target:TimeToDie() > 200 or Target:TimeToDie() < 75) then
      if HR.Cast(S.SurrenderToMadness) then return "surrender_to_madness 147"; end
    end
    -- dark_void,if=raid_event.adds.in>10
    if S.DarkVoid:IsReadyP() and (10000000000 > 10) then
      if HR.Cast(S.DarkVoid) then return "dark_void 151"; end
    end
    -- mindbender
    if S.Mindbender:IsReadyP() then
      if HR.Cast(S.Mindbender) then return "mindbender 153"; end
    end
    -- shadow_word_death,if=!buff.voidform.up|(cooldown.shadow_word_death.charges=2&buff.voidform.stack<15)
    if S.ShadowWordDeath:IsReadyP() and (not Player:BuffP(S.VoidformBuff) or (S.ShadowWordDeath:ChargesP() == 2 and Player:BuffStackP(S.VoidformBuff) < 15)) then
      if HR.Cast(S.ShadowWordDeath) then return "shadow_word_death 155"; end
    end
    -- shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if S.ShadowCrash:IsReadyP() and (10000000000 > 5 and raid_event.adds.duration < 20) then
      if HR.Cast(S.ShadowCrash) then return "shadow_crash 163"; end
    end
    -- mind_blast,if=variable.dots_up
    if S.MindBlast:IsReadyP() and (bool(VarDotsUp)) then
      if HR.Cast(S.MindBlast) then return "mind_blast 165"; end
    end
    -- void_torrent,if=dot.shadow_word_pain.remains>4&dot.vampiric_touch.remains>4&buff.voidform.up
    if S.VoidTorrent:IsReadyP() and (Target:DebuffRemainsP(S.ShadowWordPainDebuff) > 4 and Target:DebuffRemainsP(S.VampiricTouchDebuff) > 4 and Player:BuffP(S.VoidformBuff)) then
      if HR.Cast(S.VoidTorrent) then return "void_torrent 169"; end
    end
    -- shadow_word_pain,if=refreshable&target.time_to_die>4&!talent.misery.enabled&!talent.dark_void.enabled
    if S.ShadowWordPain:IsCastableP() and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff) and Target:TimeToDie() > 4 and not S.Misery:IsAvailable() and not S.DarkVoid:IsAvailable()) then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 177"; end
    end
    -- vampiric_touch,if=refreshable&target.time_to_die>6|(talent.misery.enabled&dot.shadow_word_pain.refreshable)
    if S.VampiricTouch:IsCastableP() and (Target:DebuffRefreshableCP(S.VampiricTouchDebuff) and Target:TimeToDie() > 6 or (S.Misery:IsAvailable() and Target:DebuffRefreshableCP(S.ShadowWordPainDebuff))) then
      if HR.Cast(S.VampiricTouch) then return "vampiric_touch 189"; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return "mind_flay 201"; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 203"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- use_item,slot=trinket2
    -- potion,if=buff.bloodlust.react|target.time_to_die<=80|target.health.pct<35
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 80 or Target:HealthPercentage() < 35) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 206"; end
    end
    -- variable,name=dots_up,op=set,value=dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking
    if (true) then
      VarDotsUp = num(Target:DebuffP(S.ShadowWordPainDebuff) and Target:DebuffP(S.VampiricTouchDebuff))
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 214"; end
    end
    -- run_action_list,name=aoe,if=spell_targets.mind_sear>(5+1*talent.misery.enabled)
    if (Cache.EnemiesCount[40] > (5 + 1 * num(S.Misery:IsAvailable()))) then
      return Aoe();
    end
    -- run_action_list,name=cleave,if=active_enemies>1
    if (Cache.EnemiesCount[40] > 1) then
      return Cleave();
    end
    -- run_action_list,name=single,if=active_enemies=1
    if (Cache.EnemiesCount[40] == 1) then
      return Single();
    end
  end
end

HR.SetAPL(258, APL)
