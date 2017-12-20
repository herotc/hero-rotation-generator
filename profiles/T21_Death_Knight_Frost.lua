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
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Frost = {
  RemorselessWinter                     = Spell(196770),
  GatheringStorm                        = Spell(194912),
  HowlingBlast                          = Spell(49184),
  RimeBuff                              = Spell(59052),
  Obliterate                            = Spell(49020),
  BreathofSindragosa                    = Spell(152279),
  FrostStrike                           = Spell(49143),
  ShatteringStrikes                     = Spell(207057),
  RazoriceDebuff                        = Spell(51714),
  RemorselessWinterBuff                 = Spell(196770),
  SindragosasFury                       = Spell(190778),
  PillarofFrostBuff                     = Spell(51271),
  UnholyStrengthBuff                    = Spell(53365),
  Frostscythe                           = Spell(207230),
  KillingMachineBuff                    = Spell(51124),
  GlacialAdvance                        = Spell(194913),
  GatheringStormBuff                    = Spell(211805),
  EmpowerRuneWeapon                     = Spell(47568),
  HornofWinter                          = Spell(57330),
  ChainsofIce                           = Spell(45524),
  ColdHeartBuff                         = Spell(235599),
  PillarofFrost                         = Spell(51271),
  ArcaneTorrent                         = Spell(50613),
  BreathofSindragosaDebuff              = Spell(155166),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  UseItems                              = Spell(),
  TemptationBuff                        = Spell(234143),
  Obliteration                          = Spell(207256),
  ObliterationBuff                      = Spell(207256),
  HungeringRuneWeapon                   = Spell(207127),
  Icecap                                = Spell(207126),
  FrozenPulse                           = Spell(194909),
  HungeringRuneWeaponBuff               = Spell(207127),
  FreezingFog                           = Spell(207060),
  IcyTalons                             = Spell(194878),
  IcyTalonsBuff                         = Spell(194879),
  MindFreeze                            = Spell(47528)
};
local S = Spell.DeathKnight.Frost;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  ProlongedPower                   = Item(142117),
  PerseveranceoftheEbonMartyr      = Item(132459),
  ConsortsColdCore                 = Item(144293),
  KoltirasNewfoundWill             = Item(132366),
  RingofCollapsingFutures          = Item(142173),
  HornofValor                      = Item(133642),
  DraughtofSouls                   = Item(140808),
  FeloiledInfernalMachine          = Item(144482),
  ColdHeart                        = Item(151796)
};
local I = Item.DeathKnight.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.DeathKnight.Commons,
  Frost = AR.GUISettings.APL.DeathKnight.Frost
};

-- Variables

local EnemyRanges = {8, 30}
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
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  local function BosPooling()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- howling_blast,if=buff.rime.up&rune.time_to_4<(gcd*2)
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and Player:RuneTimeToX(4) < (Player:GCD() * 2)) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=rune.time_to_6<gcd&!talent.gathering_storm.enabled
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(6) < Player:GCD() and not S.GatheringStorm:IsAvailable()) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- obliterate,if=rune.time_to_4<gcd&(cooldown.breath_of_sindragosa.remains|runic_power.deficit>=30)
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(4) < Player:GCD() and (bool(S.BreathofSindragosa:CooldownRemainsP()) or Player:RunicPowerDeficit() >= 30)) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<5&set_bonus.tier19_4pc&cooldown.breath_of_sindragosa.remains&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsCastableP() and (Player:RunicPowerDeficit() < 5 and AC.Tier19_4Pc and bool(S.BreathofSindragosa:CooldownRemainsP()) and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStackP(S.RazoriceDebuff) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6)) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- remorseless_winter,if=buff.rime.up&equipped.perseverance_of_the_ebon_martyr
    if S.RemorselessWinter:IsCastableP() and (Player:BuffP(S.RimeBuff) and I.PerseveranceoftheEbonMartyr:IsEquipped()) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- howling_blast,if=buff.rime.up&(buff.remorseless_winter.up|cooldown.remorseless_winter.remains>gcd|(!equipped.perseverance_of_the_ebon_martyr&!talent.gathering_storm.enabled))
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and (Player:BuffP(S.RemorselessWinterBuff) or S.RemorselessWinter:CooldownRemainsP() > Player:GCD() or (not I.PerseveranceoftheEbonMartyr:IsEquipped() and not S.GatheringStorm:IsAvailable()))) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=!buff.rime.up&!(talent.gathering_storm.enabled&!(cooldown.remorseless_winter.remains>(gcd*2)|rune>4))&rune>3
    if S.Obliterate:IsCastableP() and (not Player:BuffP(S.RimeBuff) and not (S.GatheringStorm:IsAvailable() and not (S.RemorselessWinter:CooldownRemainsP() > (Player:GCD() * 2) or Player:Rune() > 4)) and Player:Rune() > 3) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.react&debuff.razorice.stack=5
    if S.SindragosasFury:IsCastableP() and ((I.ConsortsColdCore:IsEquipped() or Player:BuffP(S.PillarofFrostBuff)) and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Target:DebuffStackP(S.RazoriceDebuff) == 5) then
      if AR.Cast(S.SindragosasFury) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<30&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>rune.time_to_4)
    if S.FrostStrike:IsCastableP() and (Player:RunicPowerDeficit() < 30 and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStackP(S.RazoriceDebuff) < 5 or S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4))) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.react&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
    if S.Frostscythe:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) and (not I.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2)) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- glacial_advance,if=spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (Cache.EnemiesCount[30] >= 2) then
      if AR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=3
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- frost_strike,if=(cooldown.remorseless_winter.remains<(gcd*2)|buff.gathering_storm.stack=10)&cooldown.breath_of_sindragosa.remains>rune.time_to_4&talent.gathering_storm.enabled&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsCastableP() and ((S.RemorselessWinter:CooldownRemainsP() < (Player:GCD() * 2) or Player:BuffStackP(S.GatheringStormBuff) == 10) and S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4) and S.GatheringStorm:IsAvailable() and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStackP(S.RazoriceDebuff) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6)) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- obliterate,if=!buff.rime.up&(!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>gcd)
    if S.Obliterate:IsCastableP() and (not Player:BuffP(S.RimeBuff) and (not S.GatheringStorm:IsAvailable() or S.RemorselessWinter:CooldownRemainsP() > Player:GCD())) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike,if=cooldown.breath_of_sindragosa.remains>rune.time_to_4&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsCastableP() and (S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4) and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStackP(S.RazoriceDebuff) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6)) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
  end
  local function BosTicking()
    -- frost_strike,if=talent.shattering_strikes.enabled&runic_power<40&rune.time_to_2>2&cooldown.empower_rune_weapon.remains&debuff.razorice.stack=5&(cooldown.horn_of_winter.remains|!talent.horn_of_winter.enabled)
    if S.FrostStrike:IsCastableP() and (S.ShatteringStrikes:IsAvailable() and Player:RunicPower() < 40 and Player:RuneTimeToX(2) > 2 and bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and Target:DebuffStackP(S.RazoriceDebuff) == 5 and (bool(S.HornofWinter:CooldownRemainsP()) or not S.HornofWinter:IsAvailable())) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- remorseless_winter,if=runic_power>=30&((buff.rime.up&equipped.perseverance_of_the_ebon_martyr)|(talent.gathering_storm.enabled&(buff.remorseless_winter.remains<=gcd|!buff.remorseless_winter.remains)))
    if S.RemorselessWinter:IsCastableP() and (Player:RunicPower() >= 30 and ((Player:BuffP(S.RimeBuff) and I.PerseveranceoftheEbonMartyr:IsEquipped()) or (S.GatheringStorm:IsAvailable() and (Player:BuffRemainsP(S.RemorselessWinterBuff) <= Player:GCD() or not bool(Player:BuffRemainsP(S.RemorselessWinterBuff)))))) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- howling_blast,if=((runic_power>=20&set_bonus.tier19_4pc)|runic_power>=30)&buff.rime.up
    if S.HowlingBlast:IsCastableP() and (((Player:RunicPower() >= 20 and AC.Tier19_4Pc) or Player:RunicPower() >= 30) and Player:BuffP(S.RimeBuff)) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- frost_strike,if=set_bonus.tier20_2pc&runic_power.deficit<=15&rune<=3&buff.pillar_of_frost.up&!talent.shattering_strikes.enabled
    if S.FrostStrike:IsCastableP() and (AC.Tier20_2Pc and Player:RunicPowerDeficit() <= 15 and Player:Rune() <= 3 and Player:BuffP(S.PillarofFrostBuff) and not S.ShatteringStrikes:IsAvailable()) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- obliterate,if=runic_power<=45|rune.time_to_5<gcd
    if S.Obliterate:IsCastableP() and (Player:RunicPower() <= 45 or Player:RuneTimeToX(5) < Player:GCD()) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.react&debuff.razorice.stack=5
    if S.SindragosasFury:IsCastableP() and ((I.ConsortsColdCore:IsEquipped() or Player:BuffP(S.PillarofFrostBuff)) and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Target:DebuffStackP(S.RazoriceDebuff) == 5) then
      if AR.Cast(S.SindragosasFury) then return ""; end
    end
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
      if AR.Cast(S.HornofWinter) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.react&(!equipped.koltiras_newfound_will|talent.gathering_storm.enabled|spell_targets.frostscythe>=2)
    if S.Frostscythe:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) and (not I.KoltirasNewfoundWill:IsEquipped() or S.GatheringStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2)) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- glacial_advance,if=spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (Cache.EnemiesCount[30] >= 2) then
      if AR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- empower_rune_weapon,if=runic_power<30&rune.time_to_2>gcd
    if S.EmpowerRuneWeapon:IsCastableP() and (Player:RunicPower() < 30 and Player:RuneTimeToX(2) > Player:GCD()) then
      if AR.Cast(S.EmpowerRuneWeapon) then return ""; end
    end
  end
  local function ColdHeart()
    -- chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react&cooldown.pillar_of_frost.remains>6
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) == 20 and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and S.PillarofFrost:CooldownRemainsP() > 6) then
      if AR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.up&buff.pillar_of_frost.remains<gcd&(buff.cold_heart.stack>=11|(buff.cold_heart.stack>=10&set_bonus.tier20_4pc))
    if S.ChainsofIce:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffRemainsP(S.PillarofFrostBuff) < Player:GCD() and (Player:BuffStackP(S.ColdHeartBuff) >= 11 or (Player:BuffStackP(S.ColdHeartBuff) >= 10 and AC.Tier20_4Pc))) then
      if AR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.cold_heart.stack>16&buff.unholy_strength.react&buff.unholy_strength.remains<gcd&cooldown.pillar_of_frost.remains>6
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 16 and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() and S.PillarofFrost:CooldownRemainsP() > 6) then
      if AR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.cold_heart.stack>12&buff.unholy_strength.react&talent.shattering_strikes.enabled
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 12 and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and S.ShatteringStrikes:IsAvailable()) then
      if AR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=buff.cold_heart.stack>=4&target.time_to_die<=gcd
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) >= 4 and Target:TimeToDie() <= Player:GCD()) then
      if AR.Cast(S.ChainsofIce) then return ""; end
    end
  end
  local function Cooldowns()
    -- arcane_torrent,if=runic_power.deficit>=20&!talent.breath_of_sindragosa.enabled
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:RunicPowerDeficit() >= 20 and not S.BreathofSindragosa:IsAvailable()) then
      if AR.Cast(S.ArcaneTorrent, Settings.Frost.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- arcane_torrent,if=dot.breath_of_sindragosa.ticking&runic_power.deficit>=50&rune<2
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Target:DebuffP(S.BreathofSindragosaDebuff) and Player:RunicPowerDeficit() >= 50 and Player:Rune() < 2) then
      if AR.Cast(S.ArcaneTorrent, Settings.Frost.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- blood_fury,if=buff.pillar_of_frost.up
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.PillarofFrostBuff)) then
      if AR.Cast(S.BloodFury, Settings.Frost.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.PillarofFrostBuff)) then
      if AR.Cast(S.Berserking, Settings.Frost.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- use_items
    if S.UseItems:IsCastableP() and (true) then
      if AR.Cast(S.UseItems) then return ""; end
    end
    -- use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    if I.RingofCollapsingFutures:IsReady() and ((Player:BuffStackP(S.TemptationBuff) == 0 and Target:TimeToDie() > 60) or Target:TimeToDie() < 60) then
      if AR.CastSuggested(I.RingofCollapsingFutures) then return ""; end
    end
    -- use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
    if I.HornofValor:IsReady() and (Player:BuffP(S.PillarofFrostBuff) and (not S.BreathofSindragosa:IsAvailable() or not bool(S.BreathofSindragosa:CooldownRemainsP()))) then
      if AR.CastSuggested(I.HornofValor) then return ""; end
    end
    -- use_item,name=draught_of_souls,if=rune.time_to_5<3&(!dot.breath_of_sindragosa.ticking|runic_power>60)
    if I.DraughtofSouls:IsReady() and (Player:RuneTimeToX(5) < 3 and (not Target:DebuffP(S.BreathofSindragosaDebuff) or Player:RunicPower() > 60)) then
      if AR.CastSuggested(I.DraughtofSouls) then return ""; end
    end
    -- use_item,name=feloiled_infernal_machine,if=!talent.obliteration.enabled|buff.obliteration.up
    if I.FeloiledInfernalMachine:IsReady() and (not S.Obliteration:IsAvailable() or Player:BuffP(S.ObliterationBuff)) then
      if AR.CastSuggested(I.FeloiledInfernalMachine) then return ""; end
    end
    -- potion,if=buff.pillar_of_frost.up&(dot.breath_of_sindragosa.ticking|buff.obliteration.up|talent.hungering_rune_weapon.enabled)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.PillarofFrostBuff) and (Target:DebuffP(S.BreathofSindragosaDebuff) or Player:BuffP(S.ObliterationBuff) or S.HungeringRuneWeapon:IsAvailable())) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- pillar_of_frost,if=talent.obliteration.enabled&(cooldown.obliteration.remains>20|cooldown.obliteration.remains<10|!talent.icecap.enabled)
    if S.PillarofFrost:IsCastableP() and (S.Obliteration:IsAvailable() and (S.Obliteration:CooldownRemainsP() > 20 or S.Obliteration:CooldownRemainsP() < 10 or not S.Icecap:IsAvailable())) then
      if AR.Cast(S.PillarofFrost) then return ""; end
    end
    -- pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.ready&runic_power>50
    if S.PillarofFrost:IsCastableP() and (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownUpP() and Player:RunicPower() > 50) then
      if AR.Cast(S.PillarofFrost) then return ""; end
    end
    -- pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>40
    if S.PillarofFrost:IsCastableP() and (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemainsP() > 40) then
      if AR.Cast(S.PillarofFrost) then return ""; end
    end
    -- pillar_of_frost,if=talent.hungering_rune_weapon.enabled
    if S.PillarofFrost:IsCastableP() and (S.HungeringRuneWeapon:IsAvailable()) then
      if AR.Cast(S.PillarofFrost) then return ""; end
    end
    -- breath_of_sindragosa,if=buff.pillar_of_frost.up
    if S.BreathofSindragosa:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      if AR.Cast(S.BreathofSindragosa) then return ""; end
    end
    -- call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if (I.ColdHeart:IsEquipped() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and not Player:BuffP(S.ObliterationBuff) and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- obliteration,if=rune>=1&runic_power>=20&(!talent.frozen_pulse.enabled|rune<2|buff.pillar_of_frost.remains<=12)&(!talent.gathering_storm.enabled|!cooldown.remorseless_winter.ready)&(buff.pillar_of_frost.up|!talent.icecap.enabled)
    if S.Obliteration:IsCastableP() and (Player:Rune() >= 1 and Player:RunicPower() >= 20 and (not S.FrozenPulse:IsAvailable() or Player:Rune() < 2 or Player:BuffRemainsP(S.PillarofFrostBuff) <= 12) and (not S.GatheringStorm:IsAvailable() or not S.RemorselessWinter:CooldownUpP()) and (Player:BuffP(S.PillarofFrostBuff) or not S.Icecap:IsAvailable())) then
      if AR.Cast(S.Obliteration) then return ""; end
    end
    -- hungering_rune_weapon,if=!buff.hungering_rune_weapon.up&rune.time_to_2>gcd&runic_power<40
    if S.HungeringRuneWeapon:IsCastableP() and (not Player:BuffP(S.HungeringRuneWeaponBuff) and Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 40) then
      if AR.Cast(S.HungeringRuneWeapon) then return ""; end
    end
  end
  local function Obliteration()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- frostscythe,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))&spell_targets.frostscythe>1
    if S.Frostscythe:IsCastableP() and ((Player:BuffP(S.KillingMachineBuff) and (bool(Player:BuffStackP(S.KillingMachineBuff)) or Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast))) and Cache.EnemiesCount[8] > 1) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))|(spell_targets.howling_blast>=3&!buff.rime.up)
    if S.Obliterate:IsCastableP() and ((Player:BuffP(S.KillingMachineBuff) and (bool(Player:BuffStackP(S.KillingMachineBuff)) or Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast))) or (Cache.EnemiesCount[30] >= 3 and not Player:BuffP(S.RimeBuff))) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>1
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] > 1) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- howling_blast,if=!buff.rime.up&spell_targets.howling_blast>2&rune>3&talent.freezing_fog.enabled&talent.gathering_storm.enabled
    if S.HowlingBlast:IsCastableP() and (not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] > 2 and Player:Rune() > 3 and S.FreezingFog:IsAvailable() and S.GatheringStorm:IsAvailable()) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- frost_strike,if=!buff.rime.up|rune.time_to_1>=gcd|runic_power.deficit<20
    if S.FrostStrike:IsCastableP() and (not Player:BuffP(S.RimeBuff) or Player:RuneTimeToX(1) >= Player:GCD() or Player:RunicPowerDeficit() < 20) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate
    if S.Obliterate:IsCastableP() and (true) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
  end
  local function Standard()
    -- frost_strike,if=talent.icy_talons.enabled&buff.icy_talons.remains<=gcd
    if S.FrostStrike:IsCastableP() and (S.IcyTalons:IsAvailable() and Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD()) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- frost_strike,if=talent.shattering_strikes.enabled&debuff.razorice.stack=5&buff.gathering_storm.stack<2&!buff.rime.up
    if S.FrostStrike:IsCastableP() and (S.ShatteringStrikes:IsAvailable() and Target:DebuffStackP(S.RazoriceDebuff) == 5 and Player:BuffStackP(S.GatheringStormBuff) < 2 and not Player:BuffP(S.RimeBuff)) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- remorseless_winter,if=(buff.rime.up&equipped.perseverance_of_the_ebon_martyr)|talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and ((Player:BuffP(S.RimeBuff) and I.PerseveranceoftheEbonMartyr:IsEquipped()) or S.GatheringStorm:IsAvailable()) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_4<gcd&buff.hungering_rune_weapon.up
    if S.Obliterate:IsCastableP() and ((I.KoltirasNewfoundWill:IsEquipped() and S.FrozenPulse:IsAvailable() and num(AC.Tier19_2Pc) == 1) or Player:RuneTimeToX(4) < Player:GCD() and Player:BuffP(S.HungeringRuneWeaponBuff)) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike,if=(!talent.shattering_strikes.enabled|debuff.razorice.stack<5)&runic_power.deficit<10
    if S.FrostStrike:IsCastableP() and ((not S.ShatteringStrikes:IsAvailable() or Target:DebuffStackP(S.RazoriceDebuff) < 5) and Player:RunicPowerDeficit() < 10) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if AR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_5<gcd
    if S.Obliterate:IsCastableP() and ((I.KoltirasNewfoundWill:IsEquipped() and S.FrozenPulse:IsAvailable() and num(AC.Tier19_2Pc) == 1) or Player:RuneTimeToX(5) < Player:GCD()) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.react&debuff.razorice.stack=5
    if S.SindragosasFury:IsCastableP() and ((I.ConsortsColdCore:IsEquipped() or Player:BuffP(S.PillarofFrostBuff)) and bool(Player:BuffStackP(S.UnholyStrengthBuff)) and Target:DebuffStackP(S.RazoriceDebuff) == 5) then
      if AR.Cast(S.SindragosasFury) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<10&!buff.hungering_rune_weapon.up
    if S.FrostStrike:IsCastableP() and (Player:RunicPowerDeficit() < 10 and not Player:BuffP(S.HungeringRuneWeaponBuff)) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.react&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
    if S.Frostscythe:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) and (not I.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2)) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=buff.killing_machine.react
    if S.Obliterate:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff))) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<20
    if S.FrostStrike:IsCastableP() and (Player:RunicPowerDeficit() < 20) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if AR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- glacial_advance,if=spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (Cache.EnemiesCount[30] >= 2) then
      if AR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=3
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
      if AR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>(gcd*2)
    if S.Obliterate:IsCastableP() and (not S.GatheringStorm:IsAvailable() or S.RemorselessWinter:CooldownRemainsP() > (Player:GCD() * 2)) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- horn_of_winter,if=!buff.hungering_rune_weapon.up&(rune.time_to_2>gcd|!talent.frozen_pulse.enabled)
    if S.HornofWinter:IsCastableP() and (not Player:BuffP(S.HungeringRuneWeaponBuff) and (Player:RuneTimeToX(2) > Player:GCD() or not S.FrozenPulse:IsAvailable())) then
      if AR.Cast(S.HornofWinter) then return ""; end
    end
    -- frost_strike,if=!(runic_power<50&talent.obliteration.enabled&cooldown.obliteration.remains<=gcd)
    if S.FrostStrike:IsCastableP() and (not (Player:RunicPower() < 50 and S.Obliteration:IsAvailable() and S.Obliteration:CooldownRemainsP() <= Player:GCD())) then
      if AR.Cast(S.FrostStrike) then return ""; end
    end
    -- obliterate,if=!talent.gathering_storm.enabled|talent.icy_talons.enabled
    if S.Obliterate:IsCastableP() and (not S.GatheringStorm:IsAvailable() or S.IcyTalons:IsAvailable()) then
      if AR.Cast(S.Obliterate) then return ""; end
    end
    -- empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled|target.time_to_die<cooldown.breath_of_sindragosa.remains
    if S.EmpowerRuneWeapon:IsCastableP() and (not S.BreathofSindragosa:IsAvailable() or Target:TimeToDie() < S.BreathofSindragosa:CooldownRemainsP()) then
      if AR.Cast(S.EmpowerRuneWeapon) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- mind_freeze
  if S.MindFreeze:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if AR.CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<15
  if (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemainsP() < 15) then
    return BosPooling();
  end
  -- run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
  if (Target:DebuffP(S.BreathofSindragosaDebuff)) then
    return BosTicking();
  end
  -- run_action_list,name=obliteration,if=buff.obliteration.up
  if (Player:BuffP(S.ObliterationBuff)) then
    return Obliteration();
  end
  -- call_action_list,name=standard
  if (true) then
    local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
  end
end

AR.SetAPL(251, APL)
