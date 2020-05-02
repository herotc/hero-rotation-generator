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
if not Spell.Paladin then Spell.Paladin = {} end
Spell.Paladin.Protection = {
  ConsecrationBuff                      = Spell(188370),
  Consecration                          = Spell(26573),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AvengingWrathBuff                     = Spell(31884),
  Seraphim                              = Spell(152262),
  RazorCoralDebuffDebuff                = Spell(),
  ShieldoftheRighteous                  = Spell(53600),
  AvengingWrath                         = Spell(31884),
  SeraphimBuff                          = Spell(152262),
  MemoryofLucidDreams                   = Spell(),
  BastionofLight                        = Spell(204035),
  Judgment                              = Spell(20271),
  AvengersShield                        = Spell(31935),
  WorldveinResonance                    = Spell(),
  LifebloodBuff                         = Spell(),
  AvengersValorBuff                     = Spell(),
  CrusadersJudgment                     = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  AnimaofDeath                          = Spell(),
  BlessedHammer                         = Spell(204019),
  HammeroftheRighteous                  = Spell(53595),
  HeartEssence                          = Spell()
};
local S = Spell.Paladin.Protection;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Protection = {
  BattlePotionofStamina            = Item(),
  AzsharasFontofPower              = Item(),
  AshvanesRazorCoral               = Item(),
  GrongsPrimalRage                 = Item(165574),
  PocketsizedComputationDevice     = Item(),
  MerekthasFang                    = Item(),
  RazdunksBigRedButton             = Item()
};
local I = Item.Paladin.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Paladin.Commons,
  Protection = HR.GUISettings.APL.Paladin.Protection
};


local EnemyRanges = {}
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
  local Precombat, Cooldowns
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStamina:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStamina) then return "battle_potion_of_stamina 4"; end
    end
    -- consecration
    if S.Consecration:IsCastableP() and Player:BuffDownP(S.ConsecrationBuff) then
      if HR.Cast(S.Consecration) then return "consecration 6"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 10"; end
    end
  end
  Cooldowns = function()
    -- fireblood,if=buff.avenging_wrath.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 12"; end
    end
    -- use_item,name=azsharas_font_of_power,if=cooldown.seraphim.remains<=10|!talent.seraphim.enabled
    if I.AzsharasFontofPower:IsReady() and (S.Seraphim:CooldownRemainsP() <= 10 or not S.Seraphim:IsAvailable()) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 16"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=(debuff.razor_coral_debuff.stack>7&buff.avenging_wrath.up)|debuff.razor_coral_debuff.stack=0
    if I.AshvanesRazorCoral:IsReady() and ((Target:DebuffStackP(S.RazorCoralDebuffDebuff) > 7 and Player:BuffP(S.AvengingWrathBuff)) or Target:DebuffStackP(S.RazorCoralDebuffDebuff) == 0) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 22"; end
    end
    -- seraphim,if=cooldown.shield_of_the_righteous.charges_fractional>=2
    if S.Seraphim:IsCastableP() and (S.ShieldoftheRighteous:ChargesFractionalP() >= 2) then
      if HR.Cast(S.Seraphim) then return "seraphim 30"; end
    end
    -- avenging_wrath,if=buff.seraphim.up|cooldown.seraphim.remains<2|!talent.seraphim.enabled
    if S.AvengingWrath:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SeraphimBuff) or S.Seraphim:CooldownRemainsP() < 2 or not S.Seraphim:IsAvailable()) then
      if HR.Cast(S.AvengingWrath, Settings.Protection.GCDasOffGCD.AvengingWrath) then return "avenging_wrath 34"; end
    end
    -- memory_of_lucid_dreams,if=!talent.seraphim.enabled|cooldown.seraphim.remains<=gcd|buff.seraphim.up
    if S.MemoryofLucidDreams:IsCastableP() and (not S.Seraphim:IsAvailable() or S.Seraphim:CooldownRemainsP() <= Player:GCD() or Player:BuffP(S.SeraphimBuff)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 42"; end
    end
    -- bastion_of_light,if=cooldown.shield_of_the_righteous.charges_fractional<=0.5
    if S.BastionofLight:IsCastableP() and (S.ShieldoftheRighteous:ChargesFractionalP() <= 0.5) then
      if HR.Cast(S.BastionofLight) then return "bastion_of_light 50"; end
    end
    -- potion,if=buff.avenging_wrath.up
    if I.BattlePotionofStamina:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.CastSuggested(I.BattlePotionofStamina) then return "battle_potion_of_stamina 54"; end
    end
    -- use_items,if=buff.seraphim.up|!talent.seraphim.enabled
    -- use_item,name=grongs_primal_rage,if=cooldown.judgment.full_recharge_time>4&cooldown.avengers_shield.remains>4&(buff.seraphim.up|cooldown.seraphim.remains+4+gcd>expected_combat_length-time)&consecration.up
    if I.GrongsPrimalRage:IsReady() and (S.Judgment:FullRechargeTimeP() > 4 and S.AvengersShield:CooldownRemainsP() > 4 and (Player:BuffP(S.SeraphimBuff) or S.Seraphim:CooldownRemainsP() + 4 + Player:GCD() > expected_combat_length - HL.CombatTime()) and bool(consecration.up)) then
      if HR.CastSuggested(I.GrongsPrimalRage) then return "grongs_primal_rage 59"; end
    end
    -- use_item,name=pocketsized_computation_device,if=cooldown.judgment.full_recharge_time>4*spell_haste&cooldown.avengers_shield.remains>4*spell_haste&(!equipped.grongs_primal_rage|!trinket.grongs_primal_rage.cooldown.up)&consecration.up
    if I.PocketsizedComputationDevice:IsReady() and (S.Judgment:FullRechargeTimeP() > 4 * Player:SpellHaste() and S.AvengersShield:CooldownRemainsP() > 4 * Player:SpellHaste() and (not I.GrongsPrimalRage:IsEquipped() or not bool(trinket.grongs_primal_rage.cooldown.up)) and bool(consecration.up)) then
      if HR.CastSuggested(I.PocketsizedComputationDevice) then return "pocketsized_computation_device 69"; end
    end
    -- use_item,name=merekthas_fang,if=!buff.avenging_wrath.up&(buff.seraphim.up|!talent.seraphim.enabled)
    if I.MerekthasFang:IsReady() and (not Player:BuffP(S.AvengingWrathBuff) and (Player:BuffP(S.SeraphimBuff) or not S.Seraphim:IsAvailable())) then
      if HR.CastSuggested(I.MerekthasFang) then return "merekthas_fang 77"; end
    end
    -- use_item,name=razdunks_big_red_button
    if I.RazdunksBigRedButton:IsReady() then
      if HR.CastSuggested(I.RazdunksBigRedButton) then return "razdunks_big_red_button 85"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- worldvein_resonance,if=buff.lifeblood.stack<3
    if S.WorldveinResonance:IsCastableP() and (Player:BuffStackP(S.LifebloodBuff) < 3) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 91"; end
    end
    -- shield_of_the_righteous,if=(buff.avengers_valor.up&cooldown.shield_of_the_righteous.charges_fractional>=2.5)&(cooldown.seraphim.remains>gcd|!talent.seraphim.enabled)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengersValorBuff) and S.ShieldoftheRighteous:ChargesFractionalP() >= 2.5) and (S.Seraphim:CooldownRemainsP() > Player:GCD() or not S.Seraphim:IsAvailable())) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 95"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&!talent.seraphim.enabled)|buff.seraphim.up&buff.avengers_valor.up
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and not S.Seraphim:IsAvailable()) or Player:BuffP(S.SeraphimBuff) and Player:BuffP(S.AvengersValorBuff)) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 105"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&buff.avenging_wrath.remains<4&!talent.seraphim.enabled)|(buff.seraphim.remains<4&buff.seraphim.up)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and Player:BuffRemainsP(S.AvengingWrathBuff) < 4 and not S.Seraphim:IsAvailable()) or (Player:BuffRemainsP(S.SeraphimBuff) < 4 and Player:BuffP(S.SeraphimBuff))) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 115"; end
    end
    -- lights_judgment,if=buff.seraphim.up&buff.seraphim.remains<3
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SeraphimBuff) and Player:BuffRemainsP(S.SeraphimBuff) < 3) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 127"; end
    end
    -- consecration,if=!consecration.up
    if S.Consecration:IsCastableP() and (not bool(consecration.up)) then
      if HR.Cast(S.Consecration) then return "consecration 133"; end
    end
    -- judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and ((S.Judgment:CooldownRemainsP() < Player:GCD() and S.Judgment:ChargesFractionalP() > 1 and S.Judgment:CooldownUpP()) or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 135"; end
    end
    -- avengers_shield,if=cooldown_react
    if S.AvengersShield:IsCastableP() and (S.AvengersShield:CooldownUpP()) then
      if HR.Cast(S.AvengersShield) then return "avengers_shield 147"; end
    end
    -- judgment,if=cooldown_react|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and (S.Judgment:CooldownUpP() or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 153"; end
    end
    -- concentrated_flame,if=(!talent.seraphim.enabled|buff.seraphim.up)&!dot.concentrated_flame_burn.remains>0|essence.the_crucible_of_flame.rank<3
    if S.ConcentratedFlame:IsCastableP() and ((not S.Seraphim:IsAvailable() or Player:BuffP(S.SeraphimBuff)) and num(not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff))) > 0 or essence.the_crucible_of_flame.rank < 3) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 161"; end
    end
    -- lights_judgment,if=!talent.seraphim.enabled|buff.seraphim.up
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (not S.Seraphim:IsAvailable() or Player:BuffP(S.SeraphimBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 169"; end
    end
    -- anima_of_death
    if S.AnimaofDeath:IsCastableP() then
      if HR.Cast(S.AnimaofDeath) then return "anima_of_death 175"; end
    end
    -- blessed_hammer,strikes=3
    if S.BlessedHammer:IsCastableP() then
      if HR.Cast(S.BlessedHammer) then return "blessed_hammer 177"; end
    end
    -- hammer_of_the_righteous
    if S.HammeroftheRighteous:IsCastableP() then
      if HR.Cast(S.HammeroftheRighteous) then return "hammer_of_the_righteous 179"; end
    end
    -- consecration
    if S.Consecration:IsCastableP() then
      if HR.Cast(S.Consecration) then return "consecration 181"; end
    end
    -- heart_essence,if=!(essence.the_crucible_of_flame.major|essence.worldvein_resonance.major|essence.anima_of_life_and_death.major|essence.memory_of_lucid_dreams.major)
    if S.HeartEssence:IsCastableP() and (not (bool(essence.the_crucible_of_flame.major) or bool(essence.worldvein_resonance.major) or bool(essence.anima_of_life_and_death.major) or bool(essence.memory_of_lucid_dreams.major))) then
      if HR.Cast(S.HeartEssence) then return "heart_essence 183"; end
    end
  end
end

HR.SetAPL(66, APL)
