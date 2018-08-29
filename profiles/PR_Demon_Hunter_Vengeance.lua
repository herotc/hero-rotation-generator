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
if not Spell.DemonHunter then Spell.DemonHunter = {} end
Spell.DemonHunter.Vengeance = {
  SigilofFlame                          = Spell(204596),
  FieryBrand                            = Spell(),
  InfernalStrike                        = Spell(189110),
  ImmolationAura                        = Spell(178740),
  FieryBrandDebuff                      = Spell(),
  FelDevastation                        = Spell(212084),
  DemonSpikes                           = Spell(203720),
  Metamorphosis                         = Spell(191427),
  SpiritBomb                            = Spell(),
  SoulCleave                            = Spell(228477),
  Felblade                              = Spell(232893),
  Fracture                              = Spell(),
  Shear                                 = Spell(203782),
  ThrowGlaive                           = Spell(204157),
  ConsumeMagic                          = Spell(183752),
  CharredFlesh                          = Spell()
};
local S = Spell.DemonHunter.Vengeance;

-- Items
if not Item.DemonHunter then Item.DemonHunter = {} end
Item.DemonHunter.Vengeance = {
  ProlongedPower                   = Item(142117)
};
local I = Item.DemonHunter.Vengeance;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DemonHunter.Commons,
  Vengeance = HR.GUISettings.APL.DemonHunter.Vengeance
};

-- Variables

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
  local Precombat, Brand, Defensives, Normal
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  Brand = function()
    -- sigil_of_flame,if=cooldown.fiery_brand.remains<2
    if S.SigilofFlame:IsCastableP() and (S.FieryBrand:CooldownRemainsP() < 2) then
      if HR.Cast(S.SigilofFlame) then return ""; end
    end
    -- infernal_strike,if=cooldown.fiery_brand.remains=0
    if S.InfernalStrike:IsCastableP() and (S.FieryBrand:CooldownRemainsP() == 0) then
      if HR.Cast(S.InfernalStrike) then return ""; end
    end
    -- fiery_brand
    if S.FieryBrand:IsCastableP() then
      if HR.Cast(S.FieryBrand) then return ""; end
    end
    -- immolation_aura,if=dot.fiery_brand.ticking
    if S.ImmolationAura:IsCastableP() and (Target:DebuffP(S.FieryBrandDebuff)) then
      if HR.Cast(S.ImmolationAura) then return ""; end
    end
    -- fel_devastation,if=dot.fiery_brand.ticking
    if S.FelDevastation:IsCastableP() and (Target:DebuffP(S.FieryBrandDebuff)) then
      if HR.Cast(S.FelDevastation) then return ""; end
    end
    -- infernal_strike,if=dot.fiery_brand.ticking
    if S.InfernalStrike:IsCastableP() and (Target:DebuffP(S.FieryBrandDebuff)) then
      if HR.Cast(S.InfernalStrike) then return ""; end
    end
    -- sigil_of_flame,if=dot.fiery_brand.ticking
    if S.SigilofFlame:IsCastableP() and (Target:DebuffP(S.FieryBrandDebuff)) then
      if HR.Cast(S.SigilofFlame) then return ""; end
    end
  end
  Defensives = function()
    -- demon_spikes
    if S.DemonSpikes:IsCastableP() then
      if HR.Cast(S.DemonSpikes) then return ""; end
    end
    -- metamorphosis
    if S.Metamorphosis:IsCastableP() then
      if HR.Cast(S.Metamorphosis) then return ""; end
    end
    -- fiery_brand
    if S.FieryBrand:IsCastableP() then
      if HR.Cast(S.FieryBrand) then return ""; end
    end
  end
  Normal = function()
    -- infernal_strike
    if S.InfernalStrike:IsCastableP() then
      if HR.Cast(S.InfernalStrike) then return ""; end
    end
    -- spirit_bomb,if=soul_fragments>=4
    if S.SpiritBomb:IsCastableP() and (soul_fragments >= 4) then
      if HR.Cast(S.SpiritBomb) then return ""; end
    end
    -- soul_cleave,if=!talent.spirit_bomb.enabled
    if S.SoulCleave:IsCastableP() and (not S.SpiritBomb:IsAvailable()) then
      if HR.Cast(S.SoulCleave) then return ""; end
    end
    -- soul_cleave,if=talent.spirit_bomb.enabled&soul_fragments=0
    if S.SoulCleave:IsCastableP() and (S.SpiritBomb:IsAvailable() and soul_fragments == 0) then
      if HR.Cast(S.SoulCleave) then return ""; end
    end
    -- immolation_aura,if=pain<=90
    if S.ImmolationAura:IsCastableP() and (Player:Pain() <= 90) then
      if HR.Cast(S.ImmolationAura) then return ""; end
    end
    -- felblade,if=pain<=70
    if S.Felblade:IsCastableP() and (Player:Pain() <= 70) then
      if HR.Cast(S.Felblade) then return ""; end
    end
    -- fracture,if=soul_fragments<=3
    if S.Fracture:IsCastableP() and (soul_fragments <= 3) then
      if HR.Cast(S.Fracture) then return ""; end
    end
    -- fel_devastation
    if S.FelDevastation:IsCastableP() then
      if HR.Cast(S.FelDevastation) then return ""; end
    end
    -- sigil_of_flame
    if S.SigilofFlame:IsCastableP() then
      if HR.Cast(S.SigilofFlame) then return ""; end
    end
    -- shear
    if S.Shear:IsCastableP() then
      if HR.Cast(S.Shear) then return ""; end
    end
    -- throw_glaive
    if S.ThrowGlaive:IsCastableP() then
      if HR.Cast(S.ThrowGlaive) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- consume_magic
    if S.ConsumeMagic:IsCastableP() then
      if HR.Cast(S.ConsumeMagic) then return ""; end
    end
    -- use_item,slot=trinket1
    -- use_item,slot=trinket2
    -- call_action_list,name=brand,if=talent.charred_flesh.enabled
    if (S.CharredFlesh:IsAvailable()) then
      local ShouldReturn = Brand(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=defensives
    if (true) then
      local ShouldReturn = Defensives(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=normal
    if (true) then
      local ShouldReturn = Normal(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(581, APL)
