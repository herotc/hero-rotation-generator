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
if not Spell.Priest then Spell.Priest = {} end
Spell.Priest.Shadow = {
  FortressoftheMind                     = Spell(193195),
  Sanlayn                               = Spell(),
  ShadowyInsight                        = Spell(),
  Mindbender                            = Spell(200174),
  LashofInsanity                        = Spell(),
  TothePain                             = Spell(),
  Sanlayn                               = Spell(199855),
  TouchofDarkness                       = Spell(),
  VoidCorruption                        = Spell(),
  ReaperofSouls                         = Spell(199853),
  MassHysteria                          = Spell(),
  SurrenderToMadness                    = Spell(193223),
  Shadowform                            = Spell(),
  ShadowformBuff                        = Spell(),
  MindBlast                             = Spell(8092),
  ShadowWordDeath                       = Spell(32379),
  ZeksExterminatusBuff                  = Spell(236546),
  ShadowWordPain                        = Spell(589),
  Misery                                = Spell(238558),
  ShadowWordPainDebuff                  = Spell(589),
  VampiricTouch                         = Spell(34914),
  VampiricTouchDebuff                   = Spell(34914),
  VoidEruption                          = Spell(228260),
  ShadowCrash                           = Spell(205385),
  LegacyoftheVoid                       = Spell(193225),
  AuspiciousSpirits                     = Spell(155271),
  ShadowyInsight                        = Spell(162452),
  ShadowWordVoid                        = Spell(205351),
  MindFlay                              = Spell(15407),
  Silence                               = Spell(15487),
  BuffSephuzsSecret                     = Spell(208051),
  SephuzsSecretBuff                     = Spell(208051),
  VoidBolt                              = Spell(231688),
  InsanityDrainStacksBuff               = Spell(),
  MindBomb                              = Spell(205369),
  VoidformBuff                          = Spell(194249),
  VoidTorrent                           = Spell(205065),
  PowerInfusionBuff                     = Spell(10060),
  Berserking                            = Spell(26297),
  PowerInfusion                         = Spell(10060),
  Wait                                  = Spell(),
  Dispersion                            = Spell(47585),
  Shadowfiend                           = Spell(34433),
  SphereofInsanity                      = Spell(),
  UnleashtheShadows                     = Spell(),
  ShadowyInsightBuff                    = Spell(124430),
  SurrenderToMadnessBuff                = Spell(193223)
};
local S = Spell.Priest.Shadow;

-- Items
if not Item.Priest then Item.Priest = {} end
Item.Priest.Shadow = {
  MangazasMadness                  = Item(132864),
  ProlongedPower                   = Item(142117),
  ZeksExterminatus                 = Item(144438),
  SephuzsSecret                    = Item(132452)
};
local I = Item.Priest.Shadow;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Priest.Commons,
  Shadow = AR.GUISettings.APL.Priest.Shadow
};

-- Variables
local VarHasteEval = 0;
local VarEruptEval = 0;
local VarCdTime = 0;
local VarDotSwpDpgcd = 0;
local VarDotVtDpgcd = 0;
local VarSearDpgcd = 0;
local VarS2MsetupTime = 0;
local VarActorsFightTimeMod = 0;
local VarS2Mcheck = 0;

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    AC.GetEnemies(i);
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
  UpdateRanges()
  local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- variable,name=haste_eval,op=set,value=(raw_haste_pct-0.3)*(10+10*equipped.mangazas_madness+5*talent.fortress_of_the_mind.enabled)
    if (true) then
      VarHasteEval = (raw_haste_pct - 0.3) * (10 + 10 * num(I.MangazasMadness:IsEquipped()) + 5 * num(S.FortressoftheMind:IsAvailable()))
    end
    -- variable,name=haste_eval,op=max,value=0
    if (true) then
      VarHasteEval = math.max(VarHasteEval, 0)
    end
    -- variable,name=erupt_eval,op=set,value=26+1*talent.fortress_of_the_mind.enabled-4*talent.Sanlayn.enabled-3*talent.Shadowy_insight.enabled+variable.haste_eval*1.5
    if (true) then
      VarEruptEval = 26 + 1 * num(S.FortressoftheMind:IsAvailable()) - 4 * num(S.Sanlayn:IsAvailable()) - 3 * num(S.ShadowyInsight:IsAvailable()) + VarHasteEval * 1.5
    end
    -- variable,name=cd_time,op=set,value=(12+(2-2*talent.mindbender.enabled*set_bonus.tier20_4pc)*set_bonus.tier19_2pc+(1-3*talent.mindbender.enabled*set_bonus.tier20_4pc)*equipped.mangazas_madness+(6+5*talent.mindbender.enabled)*set_bonus.tier20_4pc+2*artifact.lash_of_insanity.rank)
    if (true) then
      VarCdTime = (12 + (2 - 2 * num(S.Mindbender:IsAvailable()) * num(AC.Tier20_4Pc)) * num(AC.Tier19_2Pc) + (1 - 3 * num(S.Mindbender:IsAvailable()) * num(AC.Tier20_4Pc)) * num(I.MangazasMadness:IsEquipped()) + (6 + 5 * num(S.Mindbender:IsAvailable())) * num(AC.Tier20_4Pc) + 2 * S.LashofInsanity:ArtifactRank())
    end
    -- variable,name=dot_swp_dpgcd,op=set,value=36.5*1.2*(1+0.06*artifact.to_the_pain.rank)*(1+0.2+stat.mastery_rating%16000)*0.75
    if (true) then
      VarDotSwpDpgcd = 36.5 * 1.2 * (1 + 0.06 * S.TothePain:ArtifactRank()) * (1 + 0.2 + stat.mastery_rating / 16000) * 0.75
    end
    -- variable,name=dot_vt_dpgcd,op=set,value=68*1.2*(1+0.2*talent.sanlayn.enabled)*(1+0.05*artifact.touch_of_darkness.rank)*(1+0.2+stat.mastery_rating%16000)*0.5
    if (true) then
      VarDotVtDpgcd = 68 * 1.2 * (1 + 0.2 * num(S.Sanlayn:IsAvailable())) * (1 + 0.05 * S.TouchofDarkness:ArtifactRank()) * (1 + 0.2 + stat.mastery_rating / 16000) * 0.5
    end
    -- variable,name=sear_dpgcd,op=set,value=120*1.2*(1+0.05*artifact.void_corruption.rank)
    if (true) then
      VarSearDpgcd = 120 * 1.2 * (1 + 0.05 * S.VoidCorruption:ArtifactRank())
    end
    -- variable,name=s2msetup_time,op=set,value=(0.8*(83+(20+20*talent.fortress_of_the_mind.enabled)*set_bonus.tier20_4pc-(5*talent.sanlayn.enabled)+((33-13*set_bonus.tier20_4pc)*talent.reaper_of_souls.enabled)+set_bonus.tier19_2pc*4+8*equipped.mangazas_madness+(raw_haste_pct*10*(1+0.7*set_bonus.tier20_4pc))*(2+(0.8*set_bonus.tier19_2pc)+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank)-(1*talent.sanlayn.enabled)))),if=talent.surrender_to_madness.enabled
    if (S.SurrenderToMadness:IsAvailable()) then
      VarS2MsetupTime = (0.8 * (83 + (20 + 20 * num(S.FortressoftheMind:IsAvailable())) * num(AC.Tier20_4Pc) - (5 * num(S.Sanlayn:IsAvailable())) + ((33 - 13 * num(AC.Tier20_4Pc)) * num(S.ReaperofSouls:IsAvailable())) + num(AC.Tier19_2Pc) * 4 + 8 * num(I.MangazasMadness:IsEquipped()) + (raw_haste_pct * 10 * (1 + 0.7 * num(AC.Tier20_4Pc))) * (2 + (0.8 * num(AC.Tier19_2Pc)) + (1 * num(S.ReaperofSouls:IsAvailable())) + (2 * S.MassHysteria:ArtifactRank()) - (1 * num(S.Sanlayn:IsAvailable())))))
    end
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- shadowform,if=!buff.shadowform.up
    if S.Shadowform:IsCastableP() and (not Player:BuffP(S.ShadowformBuff)) then
      if AR.Cast(S.Shadowform) then return ""; end
    end
    -- mind_blast
    if S.MindBlast:IsCastableP() and (true) then
      if AR.Cast(S.MindBlast) then return ""; end
    end
  end
  local function Check()
    -- variable,op=set,name=actors_fight_time_mod,value=0
    if (true) then
      VarActorsFightTimeMod = 0
    end
    -- variable,op=set,name=actors_fight_time_mod,value=-((-(450)+(time+target.time_to_die))%10),if=time+target.time_to_die>450&time+target.time_to_die<600
    if (AC.CombatTime() + Target:TimeToDie() > 450 and AC.CombatTime() + Target:TimeToDie() < 600) then
      VarActorsFightTimeMod = num(true) - ((num(true) - (450) + (AC.CombatTime() + Target:TimeToDie())) / 10)
    end
    -- variable,op=set,name=actors_fight_time_mod,value=((450-(time+target.time_to_die))%5),if=time+target.time_to_die<=450
    if (AC.CombatTime() + Target:TimeToDie() <= 450) then
      VarActorsFightTimeMod = ((450 - (AC.CombatTime() + Target:TimeToDie())) / 5)
    end
    -- variable,op=set,name=s2mcheck,value=variable.s2msetup_time-(variable.actors_fight_time_mod*nonexecute_actors_pct)
    if (true) then
      VarS2Mcheck = VarS2MsetupTime - (VarActorsFightTimeMod * nonexecute_actors_pct)
    end
    -- variable,op=min,name=s2mcheck,value=180
    if (true) then
      VarS2Mcheck = math.min(VarS2Mcheck, 180)
    end
  end
  local function Main()
    -- surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
    if S.SurrenderToMadness:IsCastableP() and (S.SurrenderToMadness:IsAvailable() and Target:TimeToDie() <= VarS2Mcheck) then
      if AR.Cast(S.SurrenderToMadness) then return ""; end
    end
    -- shadow_word_death,if=equipped.zeks_exterminatus&equipped.mangazas_madness&buff.zeks_exterminatus.react
    if S.ShadowWordDeath:IsCastableP() and (I.ZeksExterminatus:IsEquipped() and I.MangazasMadness:IsEquipped() and bool(Player:BuffStackP(S.ZeksExterminatusBuff))) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd.max,moving=1,cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (S.Misery:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) < Player:GCD()) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (S.Misery:IsAvailable() and (Target:DebuffRemainsP(S.VampiricTouchDebuff) < 3 * Player:GCD() or Target:DebuffRemainsP(S.ShadowWordPainDebuff) < 3 * Player:GCD())) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&dot.shadow_word_pain.remains<(3+(4%3))*gcd
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) < (3 + (4 / 3)) * Player:GCD()) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=!talent.misery.enabled&dot.vampiric_touch.remains<(4+(4%3))*gcd
    if S.VampiricTouch:IsCastableP() and (not S.Misery:IsAvailable() and Target:DebuffRemainsP(S.VampiricTouchDebuff) < (4 + (4 / 3)) * Player:GCD()) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- void_eruption,if=(talent.mindbender.enabled&cooldown.mindbender.remains<(variable.erupt_eval+gcd.max*4%3))|!talent.mindbender.enabled|set_bonus.tier20_4pc
    if S.VoidEruption:IsCastableP() and ((S.Mindbender:IsAvailable() and S.Mindbender:CooldownRemainsP() < (VarEruptEval + Player:GCD() * 4 / 3)) or not S.Mindbender:IsAvailable() or AC.Tier20_4Pc) then
      if AR.Cast(S.VoidEruption) then return ""; end
    end
    -- shadow_crash,if=talent.shadow_crash.enabled
    if S.ShadowCrash:IsCastableP() and (S.ShadowCrash:IsAvailable()) then
      if AR.Cast(S.ShadowCrash) then return ""; end
    end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2&insanity<=(85-15*talent.reaper_of_souls.enabled)|(equipped.zeks_exterminatus&buff.zeks_exterminatus.react)
    if S.ShadowWordDeath:IsCastableP() and ((Cache.EnemiesCount[40] <= 4 or (S.ReaperofSouls:IsAvailable() and Cache.EnemiesCount[40] <= 2)) and S.ShadowWordDeath:ChargesP() == 2 and Player:Insanity() <= (85 - 15 * num(S.ReaperofSouls:IsAvailable())) or (I.ZeksExterminatus:IsEquipped() and bool(Player:BuffStackP(S.ZeksExterminatusBuff)))) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- mind_blast,if=active_enemies<=4&talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
    if S.MindBlast:IsCastableP() and (Cache.EnemiesCount[40] <= 4 and S.LegacyoftheVoid:IsAvailable() and (Player:Insanity() <= 81 or (Player:Insanity() <= 75.2 and S.FortressoftheMind:IsAvailable()))) then
      if AR.Cast(S.MindBlast) then return ""; end
    end
    -- mind_blast,if=active_enemies<=4&!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
    if S.MindBlast:IsCastableP() and (Cache.EnemiesCount[40] <= 4 and not S.LegacyoftheVoid:IsAvailable() or (Player:Insanity() <= 96 or (Player:Insanity() <= 95.2 and S.FortressoftheMind:IsAvailable()))) then
      if AR.Cast(S.MindBlast) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and Target:TimeToDie() > 10 and (Cache.EnemiesCount[40] < 5 and (S.AuspiciousSpirits:IsAvailable() or S.ShadowyInsight:IsAvailable()))) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=active_enemies>1&!talent.misery.enabled&!ticking&(variable.dot_vt_dpgcd*target.time_to_die%(gcd.max*(156+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not S.Misery:IsAvailable() and not Target:DebuffP(S.VampiricTouch) and (VarDotVtDpgcd * Target:TimeToDie() / (Player:GCD() * (156 + VarSearDpgcd * (Cache.EnemiesCount[40] - 1)))) > 1) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=active_enemies>1&!talent.misery.enabled&!ticking&(variable.dot_swp_dpgcd*target.time_to_die%(gcd.max*(118+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and (VarDotSwpDpgcd * Target:TimeToDie() / (Player:GCD() * (118 + VarSearDpgcd * (Cache.EnemiesCount[40] - 1)))) > 1) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity<=75-10*talent.legacy_of_the_void.enabled)
    if S.ShadowWordVoid:IsCastableP() and (S.ShadowWordVoid:IsAvailable() and (Player:Insanity() <= 75 - 10 * num(S.LegacyoftheVoid:IsAvailable()))) then
      if AR.Cast(S.ShadowWordVoid) then return ""; end
    end
    -- mind_flay,interrupt=1,chain=1
    if S.MindFlay:IsCastableP() and (true) then
      if AR.Cast(S.MindFlay) then return ""; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() and (true) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
  end
  local function S2M()
    -- silence,if=equipped.sephuzs_secret&(target.is_add|target.debuff.casting.react)&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up,cycle_targets=1
    if S.Silence:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (I.SephuzsSecret:IsEquipped() and (bool(target.is_add) or Target:IsCasting()) and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
      if AR.CastAnnotated(S.Silence, false, "Interrupt") then return ""; end
    end
    -- void_bolt,if=buff.insanity_drain_stacks.value<6&set_bonus.tier19_4pc
    if S.VoidBolt:IsCastableP() and (buff.insanity_drain_stacks.value < 6 and AC.Tier19_4Pc) then
      if AR.Cast(S.VoidBolt) then return ""; end
    end
    -- mind_bomb,if=equipped.sephuzs_secret&target.is_add&cooldown.buff_sephuzs_secret.remains<1&!buff.sephuzs_secret.up,cycle_targets=1
    if S.MindBomb:IsCastableP() and (I.SephuzsSecret:IsEquipped() and bool(target.is_add) and S.BuffSephuzsSecret:CooldownRemainsP() < 1 and not Player:BuffP(S.SephuzsSecretBuff)) then
      if AR.Cast(S.MindBomb) then return ""; end
    end
    -- shadow_crash,if=talent.shadow_crash.enabled
    if S.ShadowCrash:IsCastableP() and (S.ShadowCrash:IsAvailable()) then
      if AR.Cast(S.ShadowCrash) then return ""; end
    end
    -- mindbender,if=cooldown.shadow_word_death.charges=0&buff.voidform.stack>(45+25*set_bonus.tier20_4pc)
    if S.Mindbender:IsCastableP() and (S.ShadowWordDeath:ChargesP() == 0 and Player:BuffStackP(S.VoidformBuff) > (45 + 25 * num(AC.Tier20_4Pc))) then
      if AR.Cast(S.Mindbender) then return ""; end
    end
    -- void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&!buff.power_infusion.up|buff.voidform.stack<5
    if S.VoidTorrent:IsCastableP() and (Target:DebuffRemainsP(S.ShadowWordPainDebuff) > 5.5 and Target:DebuffRemainsP(S.VampiricTouchDebuff) > 5.5 and not Player:BuffP(S.PowerInfusionBuff) or Player:BuffStackP(S.VoidformBuff) < 5) then
      if AR.Cast(S.VoidTorrent) then return ""; end
    end
    -- berserking,if=buff.voidform.stack>=65
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffStackP(S.VoidformBuff) >= 65) then
      if AR.Cast(S.Berserking, Settings.Shadow.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- shadow_word_death,if=current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(30+30*talent.reaper_of_souls.enabled)<100)
    if S.ShadowWordDeath:IsCastableP() and (current_insanity_drain * Player:GCD() > Player:Insanity() and (Player:Insanity() - (current_insanity_drain * Player:GCD()) + (30 + 30 * num(S.ReaperofSouls:IsAvailable())) < 100)) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- power_infusion,if=cooldown.shadow_word_death.charges=0&buff.voidform.stack>(45+25*set_bonus.tier20_4pc)|target.time_to_die<=30
    if S.PowerInfusion:IsCastableP() and (S.ShadowWordDeath:ChargesP() == 0 and Player:BuffStackP(S.VoidformBuff) > (45 + 25 * num(AC.Tier20_4Pc)) or Target:TimeToDie() <= 30) then
      if AR.Cast(S.PowerInfusion) then return ""; end
    end
    -- void_bolt
    if S.VoidBolt:IsCastableP() and (true) then
      if AR.Cast(S.VoidBolt) then return ""; end
    end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(30+30*talent.reaper_of_souls.enabled))<100
    if S.ShadowWordDeath:IsCastableP() and ((Cache.EnemiesCount[40] <= 4 or (S.ReaperofSouls:IsAvailable() and Cache.EnemiesCount[40] <= 2)) and current_insanity_drain * Player:GCD() > Player:Insanity() and (Player:Insanity() - (current_insanity_drain * Player:GCD()) + (30 + 30 * num(S.ReaperofSouls:IsAvailable()))) < 100) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
    if S.Wait:IsCastableP() and (S.VoidBolt:UsableInP() < Player:GCD() * 0.28) then
      if AR.Cast(S.Wait) then return ""; end
    end
    -- dispersion,if=current_insanity_drain*gcd.max>insanity&!buff.power_infusion.up|(buff.voidform.stack>76&cooldown.shadow_word_death.charges=0&current_insanity_drain*gcd.max>insanity)
    if S.Dispersion:IsCastableP() and (current_insanity_drain * Player:GCD() > Player:Insanity() and not Player:BuffP(S.PowerInfusionBuff) or (Player:BuffStackP(S.VoidformBuff) > 76 and S.ShadowWordDeath:ChargesP() == 0 and current_insanity_drain * Player:GCD() > Player:Insanity())) then
      if AR.Cast(S.Dispersion) then return ""; end
    end
    -- mind_blast,if=active_enemies<=5
    if S.MindBlast:IsCastableP() and (Cache.EnemiesCount[40] <= 5) then
      if AR.Cast(S.MindBlast) then return ""; end
    end
    -- wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=5
    if S.Wait:IsCastableP() and (S.MindBlast:UsableInP() < Player:GCD() * 0.28 and Cache.EnemiesCount[40] <= 5) then
      if AR.Cast(S.Wait) then return ""; end
    end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2
    if S.ShadowWordDeath:IsCastableP() and ((Cache.EnemiesCount[40] <= 4 or (S.ReaperofSouls:IsAvailable() and Cache.EnemiesCount[40] <= 2)) and S.ShadowWordDeath:ChargesP() == 2) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&buff.voidform.stack>15
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and Player:BuffStackP(S.VoidformBuff) > 15) then
      if AR.Cast(S.Shadowfiend) then return ""; end
    end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+50)<100
    if S.ShadowWordVoid:IsCastableP() and (S.ShadowWordVoid:IsAvailable() and (Player:Insanity() - (current_insanity_drain * Player:GCD()) + 50) < 100) then
      if AR.Cast(S.ShadowWordVoid) then return ""; end
    end
    -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (S.Misery:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) < Player:GCD()) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (S.Misery:IsAvailable() and (Target:DebuffRemainsP(S.VampiricTouchDebuff) < 3 * Player:GCD() or Target:DebuffRemainsP(S.ShadowWordPainDebuff) < 3 * Player:GCD())) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and (Cache.EnemiesCount[40] < 5 or S.AuspiciousSpirits:IsAvailable() or S.ShadowyInsight:IsAvailable() or bool(S.SphereofInsanity:ArtifactRank()))) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
    if S.VampiricTouch:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.VampiricTouch) and (Cache.EnemiesCount[40] < 4 or S.Sanlayn:IsAvailable() or (S.AuspiciousSpirits:IsAvailable() and bool(S.UnleashtheShadows:ArtifactRank())))) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and Target:TimeToDie() > 10 and (Cache.EnemiesCount[40] < 5 and (S.AuspiciousSpirits:IsAvailable() or S.ShadowyInsight:IsAvailable()))) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.VampiricTouch) and Target:TimeToDie() > 10 and (Cache.EnemiesCount[40] < 4 or S.Sanlayn:IsAvailable() or (S.AuspiciousSpirits:IsAvailable() and bool(S.UnleashtheShadows:ArtifactRank())))) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and Target:TimeToDie() > 10 and (Cache.EnemiesCount[40] < 5 and bool(S.SphereofInsanity:ArtifactRank()))) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+60)<100&cooldown.shadow_word_death.charges>=1))
    if S.MindFlay:IsCastableP() and (true) then
      if AR.Cast(S.MindFlay) then return ""; end
    end
  end
  local function Vf()
    -- surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=variable.s2mcheck-(buff.insanity_drain_stacks.value)
    if S.SurrenderToMadness:IsCastableP() and (S.SurrenderToMadness:IsAvailable() and Player:Insanity() >= 25 and (S.VoidBolt:CooldownUpP() or S.VoidTorrent:CooldownUpP() or S.ShadowWordDeath:CooldownUpP() or Player:BuffP(S.ShadowyInsightBuff)) and Target:TimeToDie() <= VarS2Mcheck - (buff.insanity_drain_stacks.value)) then
      if AR.Cast(S.SurrenderToMadness) then return ""; end
    end
    -- silence,if=equipped.sephuzs_secret&(target.is_add|target.debuff.casting.react)&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up&buff.insanity_drain_stacks.value>10,cycle_targets=1
    if S.Silence:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (I.SephuzsSecret:IsEquipped() and (bool(target.is_add) or Target:IsCasting()) and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff) and buff.insanity_drain_stacks.value > 10) then
      if AR.CastAnnotated(S.Silence, false, "Interrupt") then return ""; end
    end
    -- void_bolt
    if S.VoidBolt:IsCastableP() and (true) then
      if AR.Cast(S.VoidBolt) then return ""; end
    end
    -- shadow_word_death,if=equipped.zeks_exterminatus&equipped.mangazas_madness&buff.zeks_exterminatus.react
    if S.ShadowWordDeath:IsCastableP() and (I.ZeksExterminatus:IsEquipped() and I.MangazasMadness:IsEquipped() and bool(Player:BuffStackP(S.ZeksExterminatusBuff))) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- mind_bomb,if=equipped.sephuzs_secret&target.is_add&cooldown.buff_sephuzs_secret.remains<1&!buff.sephuzs_secret.up&buff.insanity_drain_stacks.value>10,cycle_targets=1
    if S.MindBomb:IsCastableP() and (I.SephuzsSecret:IsEquipped() and bool(target.is_add) and S.BuffSephuzsSecret:CooldownRemainsP() < 1 and not Player:BuffP(S.SephuzsSecretBuff) and buff.insanity_drain_stacks.value > 10) then
      if AR.Cast(S.MindBomb) then return ""; end
    end
    -- shadow_crash,if=talent.shadow_crash.enabled
    if S.ShadowCrash:IsCastableP() and (S.ShadowCrash:IsAvailable()) then
      if AR.Cast(S.ShadowCrash) then return ""; end
    end
    -- void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+60))
    if S.VoidTorrent:IsCastableP() and (Target:DebuffRemainsP(S.ShadowWordPainDebuff) > 5.5 and Target:DebuffRemainsP(S.VampiricTouchDebuff) > 5.5 and (not S.SurrenderToMadness:IsAvailable() or (S.SurrenderToMadness:IsAvailable() and Target:TimeToDie() > VarS2Mcheck - (buff.insanity_drain_stacks.value) + 60))) then
      if AR.Cast(S.VoidTorrent) then return ""; end
    end
    -- mindbender,if=buff.insanity_drain_stacks.value>=(variable.cd_time+(variable.haste_eval*!set_bonus.tier20_4pc)-(3*set_bonus.tier20_4pc*(raid_event.movement.in<15)*((active_enemies-(raid_event.adds.count*(raid_event.adds.remains>0)))=1))+(5-3*set_bonus.tier20_4pc)*buff.bloodlust.up+2*talent.fortress_of_the_mind.enabled*set_bonus.tier20_4pc)&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-buff.insanity_drain_stacks.value))
    if S.Mindbender:IsCastableP() and (buff.insanity_drain_stacks.value >= (VarCdTime + (VarHasteEval * num(not AC.Tier20_4Pc)) - (3 * num(AC.Tier20_4Pc) * num((10000000000 < 15)) * num(((Cache.EnemiesCount[40] - (0 * num((0 > 0)))) == 1))) + (5 - 3 * num(AC.Tier20_4Pc)) * num(Player:HasHeroism()) + 2 * num(S.FortressoftheMind:IsAvailable()) * num(AC.Tier20_4Pc)) and (not S.SurrenderToMadness:IsAvailable() or (S.SurrenderToMadness:IsAvailable() and Target:TimeToDie() > VarS2Mcheck - buff.insanity_drain_stacks.value))) then
      if AR.Cast(S.Mindbender) then return ""; end
    end
    -- power_infusion,if=buff.insanity_drain_stacks.value>=(variable.cd_time+5*buff.bloodlust.up*(1+1*set_bonus.tier20_4pc))&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+61))
    if S.PowerInfusion:IsCastableP() and (buff.insanity_drain_stacks.value >= (VarCdTime + 5 * num(Player:HasHeroism()) * (1 + 1 * num(AC.Tier20_4Pc))) and (not S.SurrenderToMadness:IsAvailable() or (S.SurrenderToMadness:IsAvailable() and Target:TimeToDie() > VarS2Mcheck - (buff.insanity_drain_stacks.value) + 61))) then
      if AR.Cast(S.PowerInfusion) then return ""; end
    end
    -- berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.value<=20&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+60))
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffStackP(S.VoidformBuff) >= 10 and buff.insanity_drain_stacks.value <= 20 and (not S.SurrenderToMadness:IsAvailable() or (S.SurrenderToMadness:IsAvailable() and Target:TimeToDie() > VarS2Mcheck - (buff.insanity_drain_stacks.value) + 60))) then
      if AR.Cast(S.Berserking, Settings.Shadow.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(15+15*talent.reaper_of_souls.enabled))<100
    if S.ShadowWordDeath:IsCastableP() and ((Cache.EnemiesCount[40] <= 4 or (S.ReaperofSouls:IsAvailable() and Cache.EnemiesCount[40] <= 2)) and current_insanity_drain * Player:GCD() > Player:Insanity() and (Player:Insanity() - (current_insanity_drain * Player:GCD()) + (15 + 15 * num(S.ReaperofSouls:IsAvailable()))) < 100) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
    if S.Wait:IsCastableP() and (S.VoidBolt:UsableInP() < Player:GCD() * 0.28) then
      if AR.Cast(S.Wait) then return ""; end
    end
    -- mind_blast,if=active_enemies<=4
    if S.MindBlast:IsCastableP() and (Cache.EnemiesCount[40] <= 4) then
      if AR.Cast(S.MindBlast) then return ""; end
    end
    -- wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=4
    if S.Wait:IsCastableP() and (S.MindBlast:UsableInP() < Player:GCD() * 0.28 and Cache.EnemiesCount[40] <= 4) then
      if AR.Cast(S.Wait) then return ""; end
    end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2|(equipped.zeks_exterminatus&buff.zeks_exterminatus.react)
    if S.ShadowWordDeath:IsCastableP() and ((Cache.EnemiesCount[40] <= 4 or (S.ReaperofSouls:IsAvailable() and Cache.EnemiesCount[40] <= 2)) and S.ShadowWordDeath:ChargesP() == 2 or (I.ZeksExterminatus:IsEquipped() and bool(Player:BuffStackP(S.ZeksExterminatusBuff)))) then
      if AR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&buff.voidform.stack>15
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and Player:BuffStackP(S.VoidformBuff) > 15) then
      if AR.Cast(S.Shadowfiend) then return ""; end
    end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+25)<100
    if S.ShadowWordVoid:IsCastableP() and (S.ShadowWordVoid:IsAvailable() and (Player:Insanity() - (current_insanity_drain * Player:GCD()) + 25) < 100) then
      if AR.Cast(S.ShadowWordVoid) then return ""; end
    end
    -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (S.Misery:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) < Player:GCD()) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max)&target.time_to_die>5*gcd.max,cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (S.Misery:IsAvailable() and (Target:DebuffRemainsP(S.VampiricTouchDebuff) < 3 * Player:GCD() or Target:DebuffRemainsP(S.ShadowWordPainDebuff) < 3 * Player:GCD()) and Target:TimeToDie() > 5 * Player:GCD()) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
    if S.ShadowWordPain:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and (Cache.EnemiesCount[40] < 5 or S.AuspiciousSpirits:IsAvailable() or S.ShadowyInsight:IsAvailable() or bool(S.SphereofInsanity:ArtifactRank()))) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
    if S.VampiricTouch:IsCastableP() and (not S.Misery:IsAvailable() and not Target:DebuffP(S.VampiricTouch) and (Cache.EnemiesCount[40] < 4 or S.Sanlayn:IsAvailable() or (S.AuspiciousSpirits:IsAvailable() and bool(S.UnleashtheShadows:ArtifactRank())))) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- vampiric_touch,if=active_enemies>1&!talent.misery.enabled&!ticking&((1+0.02*buff.voidform.stack)*variable.dot_vt_dpgcd*target.time_to_die%(gcd.max*(156+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
    if S.VampiricTouch:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not S.Misery:IsAvailable() and not Target:DebuffP(S.VampiricTouch) and ((1 + 0.02 * Player:BuffStackP(S.VoidformBuff)) * VarDotVtDpgcd * Target:TimeToDie() / (Player:GCD() * (156 + VarSearDpgcd * (Cache.EnemiesCount[40] - 1)))) > 1) then
      if AR.Cast(S.VampiricTouch) then return ""; end
    end
    -- shadow_word_pain,if=active_enemies>1&!talent.misery.enabled&!ticking&((1+0.02*buff.voidform.stack)*variable.dot_swp_dpgcd*target.time_to_die%(gcd.max*(118+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
    if S.ShadowWordPain:IsCastableP() and (Cache.EnemiesCount[40] > 1 and not S.Misery:IsAvailable() and not Target:DebuffP(S.ShadowWordPain) and ((1 + 0.02 * Player:BuffStackP(S.VoidformBuff)) * VarDotSwpDpgcd * Target:TimeToDie() / (Player:GCD() * (118 + VarSearDpgcd * (Cache.EnemiesCount[40] - 1)))) > 1) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100&cooldown.shadow_word_death.charges>=1))
    if S.MindFlay:IsCastableP() and (true) then
      if AR.Cast(S.MindFlay) then return ""; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() and (true) then
      if AR.Cast(S.ShadowWordPain) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- potion,if=buff.bloodlust.react|target.time_to_die<=80|(target.health.pct<35&cooldown.power_infusion.remains<30)
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 80 or (Target:HealthPercentage() < 35 and S.PowerInfusion:CooldownRemainsP() < 30)) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- call_action_list,name=check,if=talent.surrender_to_madness.enabled&!buff.surrender_to_madness.up
  if (S.SurrenderToMadness:IsAvailable() and not Player:BuffP(S.SurrenderToMadnessBuff)) then
    local ShouldReturn = Check(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=s2m,if=buff.voidform.up&buff.surrender_to_madness.up
  if (Player:BuffP(S.VoidformBuff) and Player:BuffP(S.SurrenderToMadnessBuff)) then
    return S2M();
  end
  -- run_action_list,name=vf,if=buff.voidform.up
  if (Player:BuffP(S.VoidformBuff)) then
    return Vf();
  end
  -- run_action_list,name=main
  if (true) then
    return Main();
  end
end

AR.SetAPL(258, APL)
