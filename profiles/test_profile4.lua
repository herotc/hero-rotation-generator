--- ============================ HEADER ============================
--- ======= LOCALIZE =======
- - Addon
local addonName, addonTable=...
-- AethysCore
local AC =     AethysCore
local Cache =  AethysCache
local Unit =   AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell =  AC.Spell
local Item =   AC.Item
-- AethysRotation
local AR =     AethysRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Guardian = {
  AutoAttack                    = Spell(),
  BloodFury                     = Spell(20572),
  Berserking                    = Spell(26297),
  ArcaneTorrent                 = Spell(50613),
  UseItem                       = Spell(),
  Incarnation                   = Spell(102558),
  RageoftheSleeper              = Spell(200851),
  LunarBeam                     = Spell(204066),
  FrenziedRegeneration          = Spell(22842),
  BristlingFur                  = Spell(155835),
  IronfurBuff                   = Spell(192081),
  Ironfur                       = Spell(192081),
  GoryFurBuff                   = Spell(201671),
  Moonfire                      = Spell(8921),
  IncarnationBuff               = Spell(102558),
  MoonfireDebuff                = Spell(164812),
  ThrashBear                    = Spell(77758),
  ThrashCatDebuff               = Spell(),
  ThrashBearDebuff              = Spell(192090),
  Mangle                        = Spell(33917),
  Pulverize                     = Spell(80313),
  PulverizeBuff                 = Spell(158792),
  GalacticGuardianBuff          = Spell(213708),
  SwipeCat                      = Spell(106785),
  SwipeBear                     = Spell(213771)
};
local S = Spell.Druid.Guardian;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = {
};
local I = Item.Druid.Guardian;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Druid.Commons,
  Guardian = AR.GUISettings.APL.Druid.Guardian,
};

-- Variables

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function Swipe()
  if Player:Buff(S.CatForm)
    return S.SwipeCat;
  else
    return S.SwipeBear;
  end
end

local function Thrash()
  if Player:Buff(S.CatForm)
    return S.ThrashCat;
  else
    return S.ThrashBear;
  end
end

--- ======= ACTION LISTS =======
local function Apl()

  -- auto_attack
  if S.AutoAttack:IsCastableP() and (true) then
    if AR.Cast(S.AutoAttack) then return ""; end
  end
  -- blood_fury
  if S.BloodFury:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.BloodFury, Settings.Guardian.OffGCDasOffGCD.BloodFury) then return ""; end
  end
  -- berserking
  if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.Berserking, Settings.Guardian.OffGCDasOffGCD.Berserking) then return ""; end
  end
  -- arcane_torrent
  if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (true) then
    if AR.Cast(S.ArcaneTorrent, Settings.Guardian.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
  end
  -- use_item,slot=trinket2
  if S.UseItem:IsCastableP() and (true) then
    if AR.Cast(S.UseItem) then return ""; end
  end
  -- incarnation
  if S.Incarnation:IsCastableP() and (true) then
    if AR.Cast(S.Incarnation) then return ""; end
  end
  -- rage_of_the_sleeper
  if S.RageoftheSleeper:IsCastableP() and (true) then
    if AR.Cast(S.RageoftheSleeper) then return ""; end
  end
  -- lunar_beam
  if S.LunarBeam:IsCastableP() and (true) then
    if AR.Cast(S.LunarBeam) then return ""; end
  end
  -- frenzied_regeneration,if=incoming_damage_5s%health.max>=0.5|health<=health.max*0.4
  if S.FrenziedRegeneration:IsCastableP() and (incoming_damage_5s / health.max >= 0.5 or health <= health.max * 0.4) then
    if AR.Cast(S.FrenziedRegeneration) then return ""; end
  end
  -- bristling_fur,if=buff.ironfur.stack=1|buff.ironfur.down
  if S.BristlingFur:IsCastableP() and (Player:BuffStackP(S.IronfurBuff) == 1 or Player:BuffDownP(S.IronfurBuff)) then
    if AR.Cast(S.BristlingFur) then return ""; end
  end
  -- ironfur,if=(buff.ironfur.up=0)|(buff.gory_fur.up=1)|(rage>=80)
  if S.Ironfur:IsCastableP() and ((num(Player:BuffP(S.IronfurBuff)) == 0) or (num(Player:BuffP(S.GoryFurBuff)) == 1) or (rage >= 80)) then
    if AR.Cast(S.Ironfur) then return ""; end
  end
  -- moonfire,if=buff.incarnation.up=1&dot.moonfire.remains<=4.8
  if S.Moonfire:IsCastableP() and (num(Player:BuffP(S.IncarnationBuff)) == 1 and Target:DebuffRemainsP(S.MoonfireDebuff) <= 4.8) then
    if AR.Cast(S.Moonfire) then return ""; end
  end
  -- thrash_bear,if=buff.incarnation.up=1&dot.thrash.remains<=4.5
  if S.ThrashBear:IsCastableP() and (num(Player:BuffP(S.IncarnationBuff)) == 1 and Target:DebuffRemainsP(ThrashDebuff()) <= 4.5) then
    if AR.Cast(S.ThrashBear) then return ""; end
  end
  -- mangle
  if S.Mangle:IsCastableP() and (true) then
    if AR.Cast(S.Mangle) then return ""; end
  end
  -- thrash_bear
  if S.ThrashBear:IsCastableP() and (true) then
    if AR.Cast(S.ThrashBear) then return ""; end
  end
  -- pulverize,if=buff.pulverize.up=0|buff.pulverize.remains<=6
  if S.Pulverize:IsCastableP() and (num(Player:BuffP(S.PulverizeBuff)) == 0 or Player:BuffRemainsP(S.PulverizeBuff) <= 6) then
    if AR.Cast(S.Pulverize) then return ""; end
  end
  -- moonfire,if=buff.galactic_guardian.up=1&(!ticking|dot.moonfire.remains<=4.8)
  if S.Moonfire:IsCastableP() and (num(Player:BuffP(S.GalacticGuardianBuff)) == 1 and (not bool(ticking) or Target:DebuffRemainsP(S.MoonfireDebuff) <= 4.8)) then
    if AR.Cast(S.Moonfire) then return ""; end
  end
  -- moonfire,if=buff.galactic_guardian.up=1
  if S.Moonfire:IsCastableP() and (num(Player:BuffP(S.GalacticGuardianBuff)) == 1) then
    if AR.Cast(S.Moonfire) then return ""; end
  end
  -- moonfire,if=dot.moonfire.remains<=4.8
  if S.Moonfire:IsCastableP() and (Target:DebuffRemainsP(S.MoonfireDebuff) <= 4.8) then
    if AR.Cast(S.Moonfire) then return ""; end
  end
  -- swipe
  if Swipe():IsCastableP() and (true) then
    if AR.Cast(Swipe()) then return ""; end
  end
end