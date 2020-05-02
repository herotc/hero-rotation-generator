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
  RazorCoralDebuffDebuff                = Spell(),
  ConductiveInkDebuffDebuff             = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell(),
  InvokeNiuzaotheBlackOx                = Spell(132578),
  IronskinBrew                          = Spell(115308),
  BlackoutComboBuff                     = Spell(228563),
  ElusiveBrawlerBuff                    = Spell(),
  IronskinBrewBuff                      = Spell(215479),
  Brews                                 = Spell(115308),
  BlackOxBrew                           = Spell(115399),
  PurifyingBrew                         = Spell(119582),
  KegSmash                              = Spell(121253),
  TigerPalm                             = Spell(100780),
  RushingJadeWind                       = Spell(116847),
  RushingJadeWindBuff                   = Spell(116847),
  SpecialDelivery                       = Spell(),
  ExpelHarm                             = Spell(),
  BlackoutStrike                        = Spell(205523),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameDebuff               = Spell(),
  HeartEssence                          = Spell(),
  BreathofFire                          = Spell(115181),
  BreathofFireDotDebuff                 = Spell(123725),
  BlackoutCombo                         = Spell(196736),
  ArcaneTorrent                         = Spell(50613)
};
local S = Spell.Monk.Brewmaster;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Brewmaster = {
  ProlongedPower                   = Item(142117),
  AshvanesRazorCoral               = Item()
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
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() then
      if HR.Cast(S.ChiBurst) then return "chi_burst 6"; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 8"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- gift_of_the_ox,if=health<health.max*0.65
    -- dampen_harm,if=incoming_damage_1500ms&buff.fortifying_brew.down
    if S.DampenHarm:IsCastableP() and (bool(incoming_damage_1500ms) and Player:BuffDownP(S.FortifyingBrewBuff)) then
      if HR.Cast(S.DampenHarm) then return "dampen_harm 13"; end
    end
    -- fortifying_brew,if=incoming_damage_1500ms&(buff.dampen_harm.down|buff.diffuse_magic.down)
    if S.FortifyingBrew:IsCastableP() and (bool(incoming_damage_1500ms) and (Player:BuffDownP(S.DampenHarmBuff) or Player:BuffDownP(S.DiffuseMagicBuff))) then
      if HR.Cast(S.FortifyingBrew) then return "fortifying_brew 17"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|debuff.conductive_ink_debuff.up&target.health.pct<31|target.time_to_die<20
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuffDebuff) or Target:DebuffP(S.ConductiveInkDebuffDebuff) and Target:HealthPercentage() < 31 or Target:TimeToDie() < 20) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 23"; end
    end
    -- use_items
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 30"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 32"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 34"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 36"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 38"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 40"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 42"; end
    end
    -- invoke_niuzao_the_black_ox,if=target.time_to_die>25
    if S.InvokeNiuzaotheBlackOx:IsCastableP() and HR.CDsON() and (Target:TimeToDie() > 25) then
      if HR.Cast(S.InvokeNiuzaotheBlackOx, Settings.Brewmaster.OffGCDasOffGCD.InvokeNiuzaotheBlackOx) then return "invoke_niuzao_the_black_ox 44"; end
    end
    -- ironskin_brew,if=buff.blackout_combo.down&incoming_damage_1999ms>(health.max*0.1+stagger.last_tick_damage_4)&buff.elusive_brawler.stack<2&!buff.ironskin_brew.up
    if S.IronskinBrew:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and incoming_damage_1999ms > (health.max * 0.1 + stagger.last_tick_damage_4) and Player:BuffStackP(S.ElusiveBrawlerBuff) < 2 and not Player:BuffP(S.IronskinBrewBuff)) then
      if HR.Cast(S.IronskinBrew, Settings.Brewmaster.OffGCDasOffGCD.IronskinBrew) then return "ironskin_brew 46"; end
    end
    -- ironskin_brew,if=cooldown.brews.charges_fractional>1&cooldown.black_ox_brew.remains<3&buff.ironskin_brew.remains<15
    if S.IronskinBrew:IsCastableP() and (S.Brews:ChargesFractionalP() > 1 and S.BlackOxBrew:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.IronskinBrewBuff) < 15) then
      if HR.Cast(S.IronskinBrew, Settings.Brewmaster.OffGCDasOffGCD.IronskinBrew) then return "ironskin_brew 54"; end
    end
    -- purifying_brew,if=stagger.pct>(6*(3-(cooldown.brews.charges_fractional)))&(stagger.last_tick_damage_1>((0.02+0.001*(3-cooldown.brews.charges_fractional))*stagger.last_tick_damage_30))
    if S.PurifyingBrew:IsCastableP() and (stagger.pct > (6 * (3 - (S.Brews:ChargesFractionalP()))) and (stagger.last_tick_damage_1 > ((0.02 + 0.001 * (3 - S.Brews:ChargesFractionalP())) * stagger.last_tick_damage_30))) then
      if HR.Cast(S.PurifyingBrew, Settings.Brewmaster.OffGCDasOffGCD.PurifyingBrew) then return "purifying_brew 62"; end
    end
    -- black_ox_brew,if=cooldown.brews.charges_fractional<0.5
    if S.BlackOxBrew:IsCastableP() and (S.Brews:ChargesFractionalP() < 0.5) then
      if HR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return "black_ox_brew 68"; end
    end
    -- black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
    if S.BlackOxBrew:IsCastableP() and ((Player:EnergyPredicted() + (Player:EnergyRegen() * S.KegSmash:CooldownRemainsP())) < 40 and Player:BuffDownP(S.BlackoutComboBuff) and S.KegSmash:CooldownUpP()) then
      if HR.Cast(S.BlackOxBrew, Settings.Brewmaster.OffGCDasOffGCD.BlackOxBrew) then return "black_ox_brew 72"; end
    end
    -- keg_smash,if=spell_targets>=2
    if S.KegSmash:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.KegSmash) then return "keg_smash 80"; end
    end
    -- tiger_palm,if=talent.rushing_jade_wind.enabled&buff.blackout_combo.up&buff.rushing_jade_wind.up
    if S.TigerPalm:IsCastableP() and (S.RushingJadeWind:IsAvailable() and Player:BuffP(S.BlackoutComboBuff) and Player:BuffP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.TigerPalm) then return "tiger_palm 88"; end
    end
    -- tiger_palm,if=(talent.invoke_niuzao_the_black_ox.enabled|talent.special_delivery.enabled)&buff.blackout_combo.up
    if S.TigerPalm:IsCastableP() and ((S.InvokeNiuzaotheBlackOx:IsAvailable() or S.SpecialDelivery:IsAvailable()) and Player:BuffP(S.BlackoutComboBuff)) then
      if HR.Cast(S.TigerPalm) then return "tiger_palm 96"; end
    end
    -- expel_harm,if=buff.gift_of_the_ox.stack>4
    if S.ExpelHarm:IsCastableP() and (Player:BuffStackP(S.GiftoftheOxBuff) > 4) then
      if HR.Cast(S.ExpelHarm) then return "expel_harm 104"; end
    end
    -- blackout_strike
    if S.BlackoutStrike:IsCastableP() then
      if HR.Cast(S.BlackoutStrike) then return "blackout_strike 108"; end
    end
    -- keg_smash
    if S.KegSmash:IsCastableP() then
      if HR.Cast(S.KegSmash) then return "keg_smash 110"; end
    end
    -- concentrated_flame,if=dot.concentrated_flame.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Target:DebuffRemainsP(S.ConcentratedFlameDebuff) == 0) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 112"; end
    end
    -- heart_essence,if=!essence.the_crucible_of_flame.major
    if S.HeartEssence:IsCastableP() and (not bool(essence.the_crucible_of_flame.major)) then
      if HR.Cast(S.HeartEssence) then return "heart_essence 116"; end
    end
    -- expel_harm,if=buff.gift_of_the_ox.stack>=3
    if S.ExpelHarm:IsCastableP() and (Player:BuffStackP(S.GiftoftheOxBuff) >= 3) then
      if HR.Cast(S.ExpelHarm) then return "expel_harm 118"; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 122"; end
    end
    -- breath_of_fire,if=buff.blackout_combo.down&(buff.bloodlust.down|(buff.bloodlust.up&&dot.breath_of_fire_dot.refreshable))
    if S.BreathofFire:IsCastableP() and (Player:BuffDownP(S.BlackoutComboBuff) and (Player:HasNotHeroism() or (Player:HasHeroism() and true and Target:DebuffRefreshableCP(S.BreathofFireDotDebuff)))) then
      if HR.Cast(S.BreathofFire) then return "breath_of_fire 126"; end
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP() then
      if HR.Cast(S.ChiBurst) then return "chi_burst 132"; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return "chi_wave 134"; end
    end
    -- expel_harm,if=buff.gift_of_the_ox.stack>=2
    if S.ExpelHarm:IsCastableP() and (Player:BuffStackP(S.GiftoftheOxBuff) >= 2) then
      if HR.Cast(S.ExpelHarm) then return "expel_harm 136"; end
    end
    -- tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>gcd&(energy+(energy.regen*(cooldown.keg_smash.remains+gcd)))>=65
    if S.TigerPalm:IsCastableP() and (not S.BlackoutCombo:IsAvailable() and S.KegSmash:CooldownRemainsP() > Player:GCD() and (Player:EnergyPredicted() + (Player:EnergyRegen() * (S.KegSmash:CooldownRemainsP() + Player:GCD()))) >= 65) then
      if HR.Cast(S.TigerPalm) then return "tiger_palm 140"; end
    end
    -- arcane_torrent,if=energy<31
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:EnergyPredicted() < 31) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 148"; end
    end
    -- rushing_jade_wind
    if S.RushingJadeWind:IsCastableP() then
      if HR.Cast(S.RushingJadeWind) then return "rushing_jade_wind 150"; end
    end
  end
end

HR.SetAPL(268, APL)
