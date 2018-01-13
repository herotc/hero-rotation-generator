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
if not Spell.Monk then Spell.Monk = {} end
Spell.Monk.Brewmaster = {
  ChiBurst                              = Spell(123986),
  ChiWave                               = Spell(115098),
  DampenHarm                            = Spell(122278),
  FortifyingBrewBuff                    = Spell(115203),
  FortifyingBrew                        = Spell(115203),
  DampenHarmBuff                        = Spell(122278),
  DiffuseMagicBuff                      = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ExplodingKeg                          = Spell(214326),
  InvokeNiuzaotheBlackOx                = Spell(132578),
  PurifyingBrew                         = Spell(119582),
  Brews                                 = Spell(115308),
  IronskinBrewBuff                      = Spell(215479),
  IronskinBrew                          = Spell(115308),
  BlackoutComboBuff                     = Spell(228563),
  BlackOxBrew                           = Spell(115399),
  KegSmash                              = Spell(121253),
  ArcaneTorrent                         = Spell(50613),
  TigerPalm                             = Spell(100780),
  BlackoutStrike                        = Spell(205523),
  BreathofFire                          = Spell(115181),
  BreathofFireDotDebuff                 = Spell(123725),
  RushingJadeWind                       = Spell(116847),
  BlackoutCombo                         = Spell(196736)
};
local S = Spell.Monk.Brewmaster;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Brewmaster = {
  ProlongedPower                   = Item(142117),
  ArchimondesHatredReborn          = Item(144249)
};
local I = Item.Monk.Brewmaster;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Monk.Commons,
  Brewmaster = AR.GUISettings.APL.Monk.Brewmaster
};

-- Variables

local EnemyRanges = {8}
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
    -- chi_burst
    if S.ChiBurst:IsCastableP() and (true) then
      if AR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() and (true) then
      if AR.Cast(S.ChiWave) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- greater_gift_of_the_ox
  -- gift_of_the_ox
  -- dampen_harm,if=incoming_damage_1500ms&buff.fortifying_brew.down
  if S.DampenHarm:IsCastableP() and (bool(incoming_damage_1500ms) and Player:BuffDownP(S.FortifyingBrewBuff)) then
    if AR.Cast(S.DampenHarm) then return ""; end
  end
  -- fortifying_brew,if=incoming_damage_1500ms&(buff.dampen_harm.down|buff.diffuse_magic.down)
  if S.FortifyingBrew:IsCastableP() and (bool(incoming_damage_1500ms) and (Player:BuffDownP(S.DampenHarmBuff) or Player:BuffDownP(S.DiffuseMagicBuff))) then
    if AR.Cast(S.FortifyingBrew) then return ""; end
  end
  -- use_item,name=archimondes_hatred_reborn
  if I.ArchimondesHatredReborn:IsReady() and (true) then
    if AR.CastSuggested(I.ArchimondesHatredReborn) then return ""; end
  end
  -- potion
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
    if AR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Brewmaster.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.Berserking, Settings.Brewmaster.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- exploding_keg
  if S.ExplodingKeg:IsCastableP() and (true) then
    if AR.Cast(S.ExplodingKeg) then return ""; end
  end
  -- invoke_niuzao_the_black_ox,if=target.time_to_die>45
  if S.InvokeNiuzaotheBlackOx:IsCastableP() and AR.CDsON() and (Target:TimeToDie() > 45) then
    if AR.Cast(S.InvokeNiuzaotheBlackOx, Settings.Brewmaster.OffGCDasOffGCD.InvokeNiuzaotheBlackOx) then return ""; end
  end
  -- purifying_brew,if=stagger.heavy|(stagger.moderate&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.5&buff.ironskin_brew.remains>=buff.ironskin_brew.duration*2.5)
  if S.PurifyingBrew:IsCastableP() and (bool(stagger.heavy) or (bool(stagger.moderate) and S.Brews:ChargesFractional() >= cooldown.brews.max_charges - 0.5 and Player:BuffRemainsP(S.IronskinBrewBuff) >= S.IronskinBrewBuff:BaseDuration() * 2.5)) then
    if AR.Cast(S.PurifyingBrew, Settings.Brewmaster.OffGCDasOffGCD.PurifyingBrew) then return ""; end
  end
  -- ironskin_brew,if=buff.blackout_combo.down&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.1-(1+buff.ironskin_brew.remains<=buff.ironskin_brew.duration*0.5)&buff.ironskin_brew.remains<=buff.ironskin_brew.duration*2
  if S.IronskinBrew:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and S.Brews:ChargesFractional() >= cooldown.brews.max_charges - 0.1 - num((1 + Player:BuffRemainsP(S.IronskinBrewBuff) <= S.IronskinBrewBuff:BaseDuration() * 0.5)) and Player:BuffRemainsP(S.IronskinBrewBuff) <= S.IronskinBrewBuff:BaseDuration() * 2) then
    if AR.Cast(S.IronskinBrew, Settings.Brewmaster.OffGCDasOffGCD.IronskinBrew) then return ""; end
  end
  -- black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
  if S.BlackOxBrew:IsCastableP() and (bool(incoming_damage_1500ms) and bool(stagger.heavy) and S.Brews:ChargesFractional() <= 0.75) then
    if AR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return ""; end
  end
  -- black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
  if S.BlackOxBrew:IsCastableP() and ((Player:Energy() + (Player:EnergyRegen() * S.KegSmash:CooldownRemainsP())) < 40 and Player:BuffDownP(S.BlackoutComboBuff) and S.KegSmash:CooldownUpP()) then
    if AR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return ""; end
  end
  -- arcane_torrent,if=energy<31
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (Player:Energy() < 31) then
    if AR.Cast(S.ArcaneTorrent, Settings.Brewmaster.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- keg_smash,if=spell_targets>=3
  if S.KegSmash:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
    if AR.Cast(S.KegSmash) then return ""; end
  end
  -- tiger_palm,if=buff.blackout_combo.up
  if S.TigerPalm:IsCastableP() and (Player:BuffP(S.BlackoutComboBuff)) then
    if AR.Cast(S.TigerPalm) then return ""; end
  end
  -- keg_smash
  if S.KegSmash:IsCastableP() and (true) then
    if AR.Cast(S.KegSmash) then return ""; end
  end
  -- blackout_strike
  if S.BlackoutStrike:IsCastableP() and (true) then
    if AR.Cast(S.BlackoutStrike) then return ""; end
  end
  -- breath_of_fire,if=buff.blackout_combo.down&(buff.bloodlust.down|(buff.bloodlust.up&&dot.breath_of_fire_dot.refreshable))
  if S.BreathofFire:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and (Player:HasNotHeroism() or (Player:HasHeroism() and true and Target:DebuffRefreshableCP(S.BreathofFireDotDebuff)))) then
    if AR.Cast(S.BreathofFire) then return ""; end
  end
  -- rushing_jade_wind
  if S.RushingJadeWind:IsCastableP() and (true) then
    if AR.Cast(S.RushingJadeWind) then return ""; end
  end
  -- chi_burst
  if S.ChiBurst:IsCastableP() and (true) then
    if AR.Cast(S.ChiBurst) then return ""; end
  end
  -- chi_wave
  if S.ChiWave:IsCastableP() and (true) then
    if AR.Cast(S.ChiWave) then return ""; end
  end
  -- tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>gcd&(energy+(energy.regen*(cooldown.keg_smash.remains+gcd)))>=55
  if S.TigerPalm:IsCastableP() and (not S.BlackoutCombo:IsAvailable() and S.KegSmash:CooldownRemainsP() > Player:GCD() and (Player:Energy() + (Player:EnergyRegen() * (S.KegSmash:CooldownRemainsP() + Player:GCD()))) >= 55) then
    if AR.Cast(S.TigerPalm) then return ""; end
  end
end

AR.SetAPL(268, APL)
