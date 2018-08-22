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
  LightsJudgment                        = Spell(255647),
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
  RushingJadeWindBuff                   = Spell(116847),
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
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Monk.Commons,
  Brewmaster = HR.GUISettings.APL.Monk.Brewmaster
};

-- Variables

local EnemyRanges = {8}
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
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- auto_attack
  -- gift_of_the_ox
  -- dampen_harm,if=incoming_damage_1500ms&buff.fortifying_brew.down
  if S.DampenHarm:IsCastableP() and (bool(incoming_damage_1500ms) and Player:BuffDownP(S.FortifyingBrewBuff)) then
    if HR.Cast(S.DampenHarm) then return ""; end
  end
  -- fortifying_brew,if=incoming_damage_1500ms&(buff.dampen_harm.down|buff.diffuse_magic.down)
  if S.FortifyingBrew:IsCastableP() and (bool(incoming_damage_1500ms) and (Player:BuffDownP(S.DampenHarmBuff) or Player:BuffDownP(S.DiffuseMagicBuff))) then
    if HR.Cast(S.FortifyingBrew) then return ""; end
  end
  -- use_item,name=archimondes_hatred_reborn
  if I.ArchimondesHatredReborn:IsReady() then
    if HR.CastSuggested(I.ArchimondesHatredReborn) then return ""; end
  end
  -- potion
  if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
    if HR.CastSuggested(I.ProlongedPower) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and HR.CDsON() then
    if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and HR.CDsON() then
    if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- lights_judgment
  if S.LightsJudgment:IsCastableP() and HR.CDsON() then
    if HR.Cast(S.LightsJudgment) then return ""; end
  end
  -- invoke_niuzao_the_black_ox,if=target.time_to_die>45
  if S.InvokeNiuzaotheBlackOx:IsCastableP() and HR.CDsON() and (Target:TimeToDie() > 45) then
    if HR.Cast(S.InvokeNiuzaotheBlackOx, Settings.Brewmaster.OffGCDasOffGCD.InvokeNiuzaotheBlackOx) then return ""; end
  end
  -- purifying_brew,if=stagger.heavy|(stagger.moderate&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.5&buff.ironskin_brew.remains>=buff.ironskin_brew.duration*2.5)
  if S.PurifyingBrew:IsCastableP() and (bool(stagger.heavy) or (bool(stagger.moderate) and S.Brews:ChargesFractional() >= cooldown.brews.max_charges - 0.5 and Player:BuffRemainsP(S.IronskinBrewBuff) >= S.IronskinBrewBuff:BaseDuration() * 2.5)) then
    if HR.Cast(S.PurifyingBrew, Settings.Brewmaster.OffGCDasOffGCD.PurifyingBrew) then return ""; end
  end
  -- ironskin_brew,if=buff.blackout_combo.down&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-1.0-(1+buff.ironskin_brew.remains<=buff.ironskin_brew.duration*0.5)&buff.ironskin_brew.remains<=buff.ironskin_brew.duration*2
  if S.IronskinBrew:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and S.Brews:ChargesFractional() >= cooldown.brews.max_charges - 1.0 - num((1 + Player:BuffRemainsP(S.IronskinBrewBuff) <= S.IronskinBrewBuff:BaseDuration() * 0.5)) and Player:BuffRemainsP(S.IronskinBrewBuff) <= S.IronskinBrewBuff:BaseDuration() * 2) then
    if HR.Cast(S.IronskinBrew, Settings.Brewmaster.OffGCDasOffGCD.IronskinBrew) then return ""; end
  end
  -- black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
  if S.BlackOxBrew:IsCastableP() and (bool(incoming_damage_1500ms) and bool(stagger.heavy) and S.Brews:ChargesFractional() <= 0.75) then
    if HR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return ""; end
  end
  -- black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
  if S.BlackOxBrew:IsCastableP() and ((Player:Energy() + (Player:EnergyRegen() * S.KegSmash:CooldownRemainsP())) < 40 and Player:BuffDownP(S.BlackoutComboBuff) and S.KegSmash:CooldownUpP()) then
    if HR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return ""; end
  end
  -- arcane_torrent,if=energy<31
  if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:Energy() < 31) then
    if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
  end
  -- keg_smash,if=spell_targets>=3
  if S.KegSmash:IsCastableP() and (Cache.EnemiesCount[8] >= 3) then
    if HR.Cast(S.KegSmash) then return ""; end
  end
  -- tiger_palm,if=buff.blackout_combo.up
  if S.TigerPalm:IsCastableP() and (Player:BuffP(S.BlackoutComboBuff)) then
    if HR.Cast(S.TigerPalm) then return ""; end
  end
  -- keg_smash
  if S.KegSmash:IsCastableP() then
    if HR.Cast(S.KegSmash) then return ""; end
  end
  -- blackout_strike
  if S.BlackoutStrike:IsCastableP() then
    if HR.Cast(S.BlackoutStrike) then return ""; end
  end
  -- breath_of_fire,if=buff.blackout_combo.down&(buff.bloodlust.down|(buff.bloodlust.up&&dot.breath_of_fire_dot.refreshable))
  if S.BreathofFire:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and (Player:HasNotHeroism() or (Player:HasHeroism() and true and Target:DebuffRefreshableCP(S.BreathofFireDotDebuff)))) then
    if HR.Cast(S.BreathofFire) then return ""; end
  end
  -- rushing_jade_wind,if=buff.rushing_jade_wind.down
  if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff)) then
    if HR.Cast(S.RushingJadeWind) then return ""; end
  end
  -- chi_burst
  if S.ChiBurst:IsCastableP() then
    if HR.Cast(S.ChiBurst) then return ""; end
  end
  -- chi_wave
  if S.ChiWave:IsCastableP() then
    if HR.Cast(S.ChiWave) then return ""; end
  end
  -- tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>gcd&(energy+(energy.regen*(cooldown.keg_smash.remains+gcd)))>=55
  if S.TigerPalm:IsCastableP() and (not S.BlackoutCombo:IsAvailable() and S.KegSmash:CooldownRemainsP() > Player:GCD() and (Player:Energy() + (Player:EnergyRegen() * (S.KegSmash:CooldownRemainsP() + Player:GCD()))) >= 55) then
    if HR.Cast(S.TigerPalm) then return ""; end
  end
end

HR.SetAPL(268, APL)
