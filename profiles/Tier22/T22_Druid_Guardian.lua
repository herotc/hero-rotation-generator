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
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Guardian = {
  BearForm                              = Spell(5487),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Barkskin                              = Spell(22812),
  BearFormBuff                          = Spell(),
  LunarBeam                             = Spell(204066),
  BristlingFur                          = Spell(155835),
  Maul                                  = Spell(6807),
  Ironfur                               = Spell(192081),
  IronfurBuff                           = Spell(192081),
  LayeredMane                           = Spell(),
  Pulverize                             = Spell(80313),
  ThrashBearDebuff                      = Spell(192090),
  Moonfire                              = Spell(8921),
  MoonfireDebuff                        = Spell(164812),
  Incarnation                           = Spell(102558),
  ThrashCat                             = Spell(106830),
  ThrashBear                            = Spell(77758),
  IncarnationBuff                       = Spell(102558),
  SwipeCat                              = Spell(106785),
  SwipeBear                             = Spell(213771),
  Mangle                                = Spell(33917),
  GalacticGuardianBuff                  = Spell(213708),
  PoweroftheMoon                        = Spell(273367)
};
local S = Spell.Druid.Guardian;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Druid.Guardian;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Druid.Commons,
  Guardian = HR.GUISettings.APL.Druid.Guardian
};


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

local function Swipe()
  if Player:Buff(S.CatForm) then
    return S.SwipeCat;
  else
    return S.SwipeBear;
  end
end

local function Thrash()
  if Player:Buff(S.CatForm) then
    return S.ThrashCat;
  else
    return S.ThrashBear;
  end
end


local function EvaluateCyclePulverize75(TargetUnit)
  return TargetUnit:DebuffStackP(S.ThrashBearDebuff) == dot.thrash_bear.max_stacks
end

local function EvaluateCycleMoonfire86(TargetUnit)
  return TargetUnit:DebuffRefreshableCP(S.MoonfireDebuff) and Cache.EnemiesCount[40] < 2
end

local function EvaluateCycleMoonfire137(TargetUnit)
  return Player:BuffP(S.GalacticGuardianBuff) and Cache.EnemiesCount[40] < 2
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
    -- bear_form
    if S.BearForm:IsCastableP() then
      if HR.Cast(S.BearForm) then return "bear_form 3"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 6"; end
    end
  end
  Cooldowns = function()
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 8"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 10"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 12"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 14"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 16"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 18"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 20"; end
    end
    -- barkskin,if=buff.bear_form.up
    if S.Barkskin:IsCastableP() and (Player:BuffP(S.BearFormBuff)) then
      if HR.Cast(S.Barkskin) then return "barkskin 22"; end
    end
    -- lunar_beam,if=buff.bear_form.up
    if S.LunarBeam:IsCastableP() and (Player:BuffP(S.BearFormBuff)) then
      if HR.Cast(S.LunarBeam) then return "lunar_beam 26"; end
    end
    -- bristling_fur,if=buff.bear_form.up
    if S.BristlingFur:IsCastableP() and (Player:BuffP(S.BearFormBuff)) then
      if HR.Cast(S.BristlingFur) then return "bristling_fur 30"; end
    end
    -- use_items
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
    -- maul,if=rage.deficit<10&active_enemies<4
    if S.Maul:IsCastableP() and (Player:RageDeficit() < 10 and Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.Maul) then return "maul 39"; end
    end
    -- ironfur,if=cost=0|(rage>cost&azerite.layered_mane.enabled&active_enemies>2)
    if S.Ironfur:IsCastableP() and (S.Ironfur:Cost() == 0 or (Player:Rage() > S.Ironfur:Cost() and S.LayeredMane:AzeriteEnabled() and Cache.EnemiesCount[40] > 2)) then
      if HR.Cast(S.Ironfur) then return "ironfur 47"; end
    end
    -- pulverize,target_if=dot.thrash_bear.stack=dot.thrash_bear.max_stacks
    if S.Pulverize:IsCastableP() then
      if HR.CastCycle(S.Pulverize, 40, EvaluateCyclePulverize75) then return "pulverize 81" end
    end
    -- moonfire,target_if=dot.moonfire.refreshable&active_enemies<2
    if S.Moonfire:IsCastableP() then
      if HR.CastCycle(S.Moonfire, 40, EvaluateCycleMoonfire86) then return "moonfire 98" end
    end
    -- incarnation
    if S.Incarnation:IsCastableP() then
      if HR.Cast(S.Incarnation) then return "incarnation 99"; end
    end
    -- thrash,if=(buff.incarnation.down&active_enemies>1)|(buff.incarnation.up&active_enemies>4)
    if Thrash():IsCastableP() and ((Player:BuffDownP(S.IncarnationBuff) and Cache.EnemiesCount[40] > 1) or (Player:BuffP(S.IncarnationBuff) and Cache.EnemiesCount[40] > 4)) then
      if HR.Cast(Thrash()) then return "thrash 101"; end
    end
    -- swipe,if=buff.incarnation.down&active_enemies>4
    if Swipe():IsCastableP() and (Player:BuffDownP(S.IncarnationBuff) and Cache.EnemiesCount[40] > 4) then
      if HR.Cast(Swipe()) then return "swipe 119"; end
    end
    -- mangle,if=dot.thrash_bear.ticking
    if S.Mangle:IsCastableP() and (Target:DebuffP(S.ThrashBearDebuff)) then
      if HR.Cast(S.Mangle) then return "mangle 129"; end
    end
    -- moonfire,target_if=buff.galactic_guardian.up&active_enemies<2
    if S.Moonfire:IsCastableP() then
      if HR.CastCycle(S.Moonfire, 40, EvaluateCycleMoonfire137) then return "moonfire 149" end
    end
    -- thrash
    if Thrash():IsCastableP() then
      if HR.Cast(Thrash()) then return "thrash 150"; end
    end
    -- maul
    if S.Maul:IsCastableP() then
      if HR.Cast(S.Maul) then return "maul 152"; end
    end
    -- moonfire,if=azerite.power_of_the_moon.rank>1&active_enemies=1
    if S.Moonfire:IsCastableP() and (S.PoweroftheMoon:AzeriteRank() > 1 and Cache.EnemiesCount[40] == 1) then
      if HR.Cast(S.Moonfire) then return "moonfire 154"; end
    end
    -- swipe
    if Swipe():IsCastableP() then
      if HR.Cast(Swipe()) then return "swipe 166"; end
    end
  end
end

HR.SetAPL(104, APL)
