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
  FrozenTempest                         = Spell(),
  RimeBuff                              = Spell(),
  GlacialAdvance                        = Spell(194913),
  Frostscythe                           = Spell(207230),
  FrostStrike                           = Spell(49143),
  RazoriceDebuff                        = Spell(51714),
  HowlingBlast                          = Spell(49184),
  KillingMachineBuff                    = Spell(51124),
  RunicAttenuation                      = Spell(207104),
  Obliterate                            = Spell(49020),
  HornofWinter                          = Spell(57330),
  ArcaneTorrent                         = Spell(50613),
  PillarofFrost                         = Spell(51271),
  ChainsofIce                           = Spell(45524),
  ColdHeartBuff                         = Spell(),
  PillarofFrostBuff                     = Spell(),
  FrostwyrmsFury                        = Spell(279302),
  UnholyStrengthBuff                    = Spell(53365),
  BreathofSindragosaDebuff              = Spell(),
  EmpowerRuneWeaponBuff                 = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  EmpowerRuneWeapon                     = Spell(47568),
  BreathofSindragosa                    = Spell(152279),
  ColdHeart                             = Spell(),
  FrozenPulseBuff                       = Spell(),
  FrozenPulse                           = Spell(194909),
  FrostFeverDebuff                      = Spell(),
  IcyTalonsBuff                         = Spell(194879),
  Obliteration                          = Spell(281238)
};
local S = Spell.DeathKnight.Frost;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  ProlongedPower                   = Item(142117),
  RazdunksBigRedButton             = Item(),
  MerekthasFang                    = Item()
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


local EnemyRanges = {30, 10, 8}
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
  end
  Aoe = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled|(azerite.frozen_tempest.rank&spell_targets.remorseless_winter>=3&!buff.rime.up)
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable() or (bool(S.FrozenTempest:AzeriteRank()) and Cache.EnemiesCount[8] >= 3 and not Player:BuffP(S.RimeBuff))) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 6"; end
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if S.GlacialAdvance:IsCastableP() and (S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 14"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable() end) then return "frost_strike 32" end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 33"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 39"; end
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff)) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 43"; end
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 47"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable() end) then return "frost_strike 63" end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 64"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 68"; end
    end
    -- frostscythe
    if S.Frostscythe:IsCastableP() then
      if HR.Cast(S.Frostscythe) then return "frostscythe 70"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>(25+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable() end) then return "obliterate 84" end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 85"; end
    end
    -- glacial_advance
    if S.GlacialAdvance:IsCastableP() then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 89"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() end) then return "frost_strike 101" end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() then
      if HR.Cast(S.FrostStrike) then return "frost_strike 102"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 104"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return "arcane_torrent 106"; end
    end
  end
  BosPooling = function()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 108"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_4<gcd&runic_power.deficit>=25&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable() end) then return "obliterate 122" end
    end
    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25) then
      if HR.Cast(S.Obliterate) then return "obliterate 123"; end
    end
    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 125"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and not S.Frostscythe:IsAvailable() end) then return "frost_strike 141" end
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 142"; end
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 146"; end
    end
    -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 152"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable() end) then return "obliterate 168" end
    end
    -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 169"; end
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 173"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable() end) then return "frost_strike 189" end
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsUsableP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 190"; end
    end
  end
  BosTicking = function()
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=30&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 30 and not S.Frostscythe:IsAvailable() end) then return "obliterate 204" end
    end
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsCastableP() and (Player:RunicPower() <= 30) then
      if HR.Cast(S.Obliterate) then return "obliterate 205"; end
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 207"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 211"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_5<gcd|runic_power<=45&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45 and not S.Frostscythe:IsAvailable() end) then return "obliterate 225" end
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsCastableP() and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
      if HR.Cast(S.Obliterate) then return "obliterate 226"; end
    end
    -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 228"; end
    end
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 232"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 234"; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 236"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > 25 or Player:Rune() > 3 and not S.Frostscythe:IsAvailable() end) then return "obliterate 248" end
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 249"; end
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 20) then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return "arcane_torrent 251"; end
    end
  end
  ColdHeart = function()
    -- chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 5 and Target:TimeToDie() < Player:GCD()) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 253"; end
    end
    -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 257"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.pillar_of_frost.up
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and bool(Player:BuffRemainsP(S.UnholyStrengthBuff)) and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.ChainsofIce) then return "chains_of_ice 267"; end
    end
  end
  Cooldowns = function()
    -- use_items,if=(cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
    -- use_item,name=razdunks_big_red_button
    if I.RazdunksBigRedButton:IsReady() then
      if HR.CastSuggested(I.RazdunksBigRedButton) then return "razdunks_big_red_button 280"; end
    end
    -- use_item,name=merekthas_fang,if=!dot.breath_of_sindragosa.ticking&!buff.pillar_of_frost.up
    if I.MerekthasFang:IsReady() and (not Target:DebuffP(S.BreathofSindragosaDebuff) and not Player:BuffP(S.PillarofFrostBuff)) then
      if HR.CastSuggested(I.MerekthasFang) then return "merekthas_fang 282"; end
    end
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 288"; end
    end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.BloodFury:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 294"; end
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 300"; end
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
    if S.PillarofFrost:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP())) then
      if HR.Cast(S.PillarofFrost, Settings.Frost.GCDasOffGCD.PillarofFrost) then return "pillar_of_frost 304"; end
    end
    -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if S.BreathofSindragosa:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
      if HR.Cast(S.BreathofSindragosa, Settings.Frost.GCDasOffGCD.BreathofSindragosa) then return "breath_of_sindragosa 308"; end
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10|target.time_to_die<20
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10 or Target:TimeToDie() < 20) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 314"; end
    end
    -- empower_rune_weapon,if=(cooldown.pillar_of_frost.ready|target.time_to_die<20)&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
    if S.EmpowerRuneWeapon:IsCastableP() and ((S.PillarofFrost:CooldownUpP() or Target:TimeToDie() < 20) and S.BreathofSindragosa:IsAvailable() and Player:Rune() >= 3 and Player:RunicPower() > 60) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 320"; end
    end
    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd|(buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))&buff.pillar_of_frost.up
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() or (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.FrostwyrmsFury) then return "frostwyrms_fury 334"; end
    end
    -- frostwyrms_fury,if=target.time_to_die<gcd|(target.time_to_die<cooldown.pillar_of_frost.remains&buff.unholy_strength.up)
    if S.FrostwyrmsFury:IsCastableP() and (Target:TimeToDie() < Player:GCD() or (Target:TimeToDie() < S.PillarofFrost:CooldownRemainsP() and Player:BuffP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.FrostwyrmsFury) then return "frostwyrms_fury 346"; end
    end
  end
  Obliteration = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 352"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3 end) then return "obliterate 368" end
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP() and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 369"; end
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 375"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance))) end) then return "obliterate 405" end
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP() and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      if HR.Cast(S.Obliterate) then return "obliterate 406"; end
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsCastableP() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 418"; end
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 2) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 422"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
    if S.FrostStrike:IsUsableP() then
      if HR.CastCycle(S.FrostStrike, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable() end) then return "frost_strike 438" end
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsUsableP() and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 439"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 443"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP() then
      if HR.CastCycle(S.Obliterate, 10, function(TargetUnit) return (TargetUnit:DebuffStackP(S.RazoriceDebuff) < 5 or TargetUnit:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() end) then return "obliterate 457" end
    end
    -- obliterate
    if S.Obliterate:IsCastableP() then
      if HR.Cast(S.Obliterate) then return "obliterate 458"; end
    end
  end
  Standard = function()
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter) then return "remorseless_winter 460"; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsUsableP() and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 462"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP() and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 468"; end
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsCastableP() and (not Player:BuffP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 472"; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 478"; end
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.Frostscythe) then return "frostscythe 482"; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 486"; end
    end
    -- frost_strike
    if S.FrostStrike:IsUsableP() then
      if HR.Cast(S.FrostStrike) then return "frost_strike 490"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter) then return "horn_of_winter 492"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() then
      if HR.Cast(S.ArcaneTorrent, Settings.Frost.GCDasOffGCD.ArcaneTorrent) then return "arcane_torrent 494"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsCastableP() and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 498"; end
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsCastableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.GlacialAdvance) then return "glacial_advance 506"; end
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsUsableP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 516"; end
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&(cooldown.breath_of_sindragosa.remains<5|(cooldown.breath_of_sindragosa.remains<20&target.time_to_die<35))
    if (S.BreathofSindragosa:IsAvailable() and (S.BreathofSindragosa:CooldownRemainsP() < 5 or (S.BreathofSindragosa:CooldownRemainsP() < 20 and Target:TimeToDie() < 35))) then
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
end

HR.SetAPL(251, APL)
