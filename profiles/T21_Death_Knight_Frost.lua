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
Spell.DeathKnight.Frost = {
  RemorselessWinter                     = Spell(196770),
  GatheringStorm                        = Spell(194912),
  GlacialAdvance                        = Spell(194913),
  Frostscythe                           = Spell(207230),
  FrostStrike                           = Spell(49143),
  HowlingBlast                          = Spell(49184),
  RimeBuff                              = Spell(),
  KillingMachineBuff                    = Spell(51124),
  RunicAttenuation                      = Spell(207104),
  Obliterate                            = Spell(49020),
  HornofWinter                          = Spell(57330),
  ArcaneTorrent                         = Spell(50613),
  PillarofFrost                         = Spell(51271),
  ChainsofIce                           = Spell(45524),
  ColdHeartItemBuff                     = Spell(235599),
  ColdHeartTalentBuff                   = Spell(281209),
  PillarofFrostBuff                     = Spell(),
  FrostwyrmsFury                        = Spell(279302),
  BreathofSindragosa                    = Spell(152279),
  EmpowerRuneWeaponBuff                 = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  EmpowerRuneWeapon                     = Spell(47568),
  ColdHeart                             = Spell(),
  RazoriceDebuff                        = Spell(51714),
  FrozenPulseBuff                       = Spell(),
  FrozenPulse                           = Spell(194909),
  MindFreeze                            = Spell(47528),
  FrostFeverDebuff                      = Spell(),
  IcyTalonsBuff                         = Spell(194879),
  BreathofSindragosaDebuff              = Spell(),
  Obliteration                          = Spell(281238)
};
local S = Spell.DeathKnight.Frost;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  ProlongedPower                   = Item(142117),
  HornofValor                      = Item(133642),
  ColdHeart                        = Item(151796)
};
local I = Item.DeathKnight.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Frost = HR.GUISettings.APL.DeathKnight.Frost
};

-- Variables

local EnemyRanges = {8, 10, 30}
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
  local Precombat, Aoe, BosPooling, BosTicking, ColdHeart, Cooldowns, Obliteration, Standard
  UpdateRanges()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  Aoe = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if S.GlacialAdvance:IsCastableP() and (S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff)) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() and (true) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- frostscythe
    if S.Frostscythe:IsCastableP() and (true) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- glacial_advance
    if S.GlacialAdvance:IsCastableP() and (true) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() and (true) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() and (true) then
      if HR.Cast(S.HornofWinter) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and (true) then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  BosPooling = function()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=runic_power.deficit>=(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() >= (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsUsableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
  end
  BosTicking = function()
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsCastableP() and (Player:RunicPower() <= 30) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff)) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
      if HR.Cast(S.HornofWinter) then return ""; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() and (true) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 20) then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  ColdHeart = function()
    -- chains_of_ice,if=(buff.cold_heart_item.stack>5|buff.cold_heart_talent.stack>5)&target.time_to_die<gcd
    if S.ChainsofIce:IsCastableP() and ((Player:BuffStackP(S.ColdHeartItemBuff) > 5 or Player:BuffStackP(S.ColdHeartTalentBuff) > 5) and Target:TimeToDie() < Player:GCD()) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
    -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.ChainsofIce) then return ""; end
    end
  end
  Cooldowns = function()
    -- use_items
    -- use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
    if I.HornofValor:IsReady() and (Player:BuffP(S.PillarofFrostBuff) and (not S.BreathofSindragosa:IsAvailable() or not bool(S.BreathofSindragosa:CooldownRemainsP()))) then
      if HR.CastSuggested(I.HornofValor) then return ""; end
    end
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.BloodFury:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.BloodFury, Settings.Frost.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.Berserking, Settings.Frost.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
    if S.PillarofFrost:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP())) then
      if HR.Cast(S.PillarofFrost, Settings.Frost.GCDasOffGCD.PillarofFrost) then return ""; end
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return ""; end
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and S.BreathofSindragosa:IsAvailable() and Player:Rune() >= 3 and Player:RunicPower() > 60) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return ""; end
    end
    -- call_action_list,name=cold_heart,if=(equipped.cold_heart|talent.cold_heart.enabled)&(((buff.cold_heart_item.stack>=10|buff.cold_heart_talent.stack>=10)&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if ((I.ColdHeart:IsEquipped() or S.ColdHeart:IsAvailable()) and (((Player:BuffStackP(S.ColdHeartItemBuff) >= 10 or Player:BuffStackP(S.ColdHeartTalentBuff) >= 10) and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up)
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() and Player:BuffP(S.PillarofFrostBuff))) then
      if HR.Cast(S.FrostwyrmsFury) then return ""; end
    end
  end
  Obliteration = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP() and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&(rune.time_to_4>gcd|spell_targets.frostscythe>=2)
    if S.Frostscythe:IsCastableP() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and (Player:RuneTimeToX(4) > Player:GCD() or Cache.EnemiesCount[8] >= 2)) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return ""; end
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsUsableP() and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate
    if S.Obliterate:IsCastableP() and (true) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
  end
  Standard = function()
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() and (true) then
      if HR.Cast(S.RemorselessWinter) then return ""; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return ""; end
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsCastableP() and (not Player:BuffP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.Frostscythe) then return ""; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return ""; end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() and (true) then
      if HR.Cast(S.FrostStrike) then return ""; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() and (true) then
      if HR.Cast(S.HornofWinter) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and (true) then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- mind_freeze
  if S.MindFreeze:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (true) then
    if HR.CastAnnotated(S.MindFreeze, false, "Interrupt") then return ""; end
  end
  -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  if S.HowlingBlast:IsCastableP() and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    if HR.Cast(S.HowlingBlast) then return ""; end
  end
  -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  if S.GlacialAdvance:IsCastableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    if HR.Cast(S.GlacialAdvance) then return ""; end
  end
  -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  if S.FrostStrike:IsUsableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    if HR.Cast(S.FrostStrike) then return ""; end
  end
  -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
  if S.BreathofSindragosa:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
    if HR.Cast(S.BreathofSindragosa, Settings.Frost.GCDasOffGCD.BreathofSindragosa) then return ""; end
  end
  -- call_action_list,name=cooldowns
  if (true) then
    local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
  if (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemainsP() < 5) then
    return BosPooling();
  end
  -- run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
  if (Target:DebuffP(S.BreathofSindragosaDebuff)) then
    return BosTicking();
  end
  -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
  if (Player:BuffP(S.PillarofFrostBuff) and S.Obliteration:IsAvailable()) then
    return Obliteration();
  end
  -- run_action_list,name=aoe,if=active_enemies>=2
  if (Cache.EnemiesCount[10] >= 2) then
    return Aoe();
  end
  -- call_action_list,name=standard
  if (true) then
    local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
  end
end

HR.SetAPL(251, APL)
