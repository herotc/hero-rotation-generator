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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.Survival = {
  ArcaneTorrent                         = Spell(50613),
  Berserking                            = Spell(26297),
  AspectoftheEagleBuff                  = Spell(186289),
  BloodFury                             = Spell(20572),
  BerserkingBuff                        = Spell(26297),
  BloodFuryBuff                         = Spell(20572),
  SnakeHunter                           = Spell(201078),
  MongooseBite                          = Spell(190928),
  MongooseFuryBuff                      = Spell(190931),
  AspectoftheEagle                      = Spell(186289),
  Butchery                              = Spell(212436),
  Caltrops                              = Spell(187698),
  ExplosiveTrap                         = Spell(191433),
  Carve                                 = Spell(187708),
  SerpentSting                          = Spell(87935),
  SerpentStingDebuff                    = Spell(118253),
  FlankingStrike                        = Spell(202800),
  FuryoftheEagle                        = Spell(203415),
  MoknathalTacticsBuff                  = Spell(201081),
  Lacerate                              = Spell(185855),
  LacerateDebuff                        = Spell(185855),
  RaptorStrike                          = Spell(186270),
  T212PExposedFlankBuff                 = Spell(251751),
  SpittingCobra                         = Spell(194407),
  DragonsfireGrenade                    = Spell(194855),
  SteelTrap                             = Spell(162488),
  AMurderofCrows                        = Spell(206505),
  WayoftheMoknathal                     = Spell(201082),
  UseItems                              = Spell(),
  Muzzle                                = Spell(187707)
};
local S = Spell.Hunter.Survival;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Survival = {
  ProlongedPower                   = Item(142117),
  Item137043                       = Item(137043)
};
local I = Item.Hunter.Survival;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Hunter.Commons,
  Survival = AR.GUISettings.APL.Hunter.Survival
};

-- Variables
local Frizzosequipped = 0;
local Moktalented = 0;

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function Apl()
  local function Cds()
    -- arcane_torrent,if=focus<=30
    if S.ArcaneTorrent:IsCastableP() and AR.CDsON() and (focus <= 30) then
      if AR.Cast(S.ArcaneTorrent, Settings.Survival.OffGCDasOffGCD.ArcaneTorrent) then return ""; end
    end
    -- berserking,if=buff.aspect_of_the_eagle.up
    if S.Berserking:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AspectoftheEagleBuff)) then
      if AR.Cast(S.Berserking, Settings.Survival.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- blood_fury,if=buff.aspect_of_the_eagle.up
    if S.BloodFury:IsCastableP() and AR.CDsON() and (Player:BuffP(S.AspectoftheEagleBuff)) then
      if AR.Cast(S.BloodFury, Settings.Survival.OffGCDasOffGCD.BloodFury) then return ""; end
    end
    -- potion,if=buff.aspect_of_the_eagle.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AspectoftheEagleBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll") and not Player:IsRace("Orc"))) then
      if AR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&(cooldown.aspect_of_the_eagle.remains>5&!buff.aspect_of_the_eagle.up)
    if S.SnakeHunter:IsCastableP() and (S.MongooseBite:ChargesP() == 0 and Player:BuffRemainsP(S.MongooseFuryBuff) > 3 * Player:GCD() and (S.AspectoftheEagle:CooldownRemainsP() > 5 and not Player:BuffP(S.AspectoftheEagleBuff))) then
      if AR.Cast(S.SnakeHunter) then return ""; end
    end
    -- aspect_of_the_eagle,if=buff.mongoose_fury.up&(cooldown.mongoose_bite.charges=0|buff.mongoose_fury.remains<11)
    if S.AspectoftheEagle:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff) and (S.MongooseBite:ChargesP() == 0 or Player:BuffRemainsP(S.MongooseFuryBuff) < 11)) then
      if AR.Cast(S.AspectoftheEagle) then return ""; end
    end
  end
  local function Aoe()
    -- butchery
    if S.Butchery:IsCastableP() and (true) then
      if AR.Cast(S.Butchery) then return ""; end
    end
    -- caltrops,if=!ticking
    if S.Caltrops:IsCastableP() and (not bool(ticking)) then
      if AR.Cast(S.Caltrops) then return ""; end
    end
    -- explosive_trap
    if S.ExplosiveTrap:IsCastableP() and (true) then
      if AR.Cast(S.ExplosiveTrap) then return ""; end
    end
    -- carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)
    if S.Carve:IsCastableP() and ((S.SerpentSting:IsAvailable() and bool(dot.serpent_sting.refreshable)) or (active_enemies > 5)) then
      if AR.Cast(S.Carve) then return ""; end
    end
  end
  local function Bitephase()
    -- mongoose_bite,if=cooldown.mongoose_bite.charges=3
    if S.MongooseBite:IsCastableP() and (S.MongooseBite:ChargesP() == 3) then
      if AR.Cast(S.MongooseBite) then return ""; end
    end
    -- flanking_strike,if=buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+1))
    if S.FlankingStrike:IsCastableP() and (Player:BuffRemainsP(S.MongooseFuryBuff) > (Player:GCD() * (S.MongooseBite:ChargesP() + 1))) then
      if AR.Cast(S.FlankingStrike) then return ""; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up
    if S.MongooseBite:IsCastableP() and (Player:BuffP(S.MongooseFuryBuff)) then
      if AR.Cast(S.MongooseBite) then return ""; end
    end
    -- fury_of_the_eagle,if=(!variable.mokTalented|(buff.moknathal_tactics.remains>(gcd*(8%3))))&!buff.aspect_of_the_eagle.up,interrupt_immediate=1,interrupt_if=cooldown.mongoose_bite.charges=3|(ticks_remain<=1&buff.moknathal_tactics.remains<0.7)
    if S.FuryoftheEagle:IsCastableP() and ((not bool(Moktalented) or (Player:BuffRemainsP(S.MoknathalTacticsBuff) > (Player:GCD() * (8 / 3)))) and not Player:BuffP(S.AspectoftheEagleBuff)) then
      if AR.Cast(S.FuryoftheEagle) then return ""; end
    end
    -- lacerate,if=dot.lacerate.refreshable&(focus>((50+35)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Lacerate:IsCastableP() and (bool(dot.lacerate.refreshable) and (focus > ((50 + 35) - ((S.FlankingStrike:CooldownRemainsP() / Player:GCD()) * (focus.regen * Player:GCD()))))) then
      if AR.Cast(S.Lacerate) then return ""; end
    end
    -- raptor_strike,if=buff.t21_2p_exposed_flank.up
    if S.RaptorStrike:IsCastableP() and (Player:BuffP(S.T212PExposedFlankBuff)) then
      if AR.Cast(S.RaptorStrike) then return ""; end
    end
    -- spitting_cobra
    if S.SpittingCobra:IsCastableP() and (true) then
      if AR.Cast(S.SpittingCobra) then return ""; end
    end
    -- dragonsfire_grenade
    if S.DragonsfireGrenade:IsCastableP() and (true) then
      if AR.Cast(S.DragonsfireGrenade) then return ""; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() and (true) then
      if AR.Cast(S.SteelTrap) then return ""; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() and (true) then
      if AR.Cast(S.AMurderofCrows) then return ""; end
    end
    -- caltrops,if=!ticking
    if S.Caltrops:IsCastableP() and (not bool(ticking)) then
      if AR.Cast(S.Caltrops) then return ""; end
    end
    -- explosive_trap
    if S.ExplosiveTrap:IsCastableP() and (true) then
      if AR.Cast(S.ExplosiveTrap) then return ""; end
    end
  end
  local function Bitetrigger()
    -- lacerate,if=remains<14&set_bonus.tier20_4pc&cooldown.mongoose_bite.remains<gcd*3
    if S.Lacerate:IsCastableP() and (Target:DebuffRemainsP(S.Lacerate) < 14 and AC.Tier20_4Pc and S.MongooseBite:CooldownRemainsP() < Player:GCD() * 3) then
      if AR.Cast(S.Lacerate) then return ""; end
    end
    -- mongoose_bite,if=charges>=2
    if S.MongooseBite:IsCastableP() and (S.MongooseBite:ChargesP() >= 2) then
      if AR.Cast(S.MongooseBite) then return ""; end
    end
  end
  local function Fillers()
    -- flanking_strike,if=cooldown.mongoose_bite.charges<3
    if S.FlankingStrike:IsCastableP() and (S.MongooseBite:ChargesP() < 3) then
      if AR.Cast(S.FlankingStrike) then return ""; end
    end
    -- spitting_cobra
    if S.SpittingCobra:IsCastableP() and (true) then
      if AR.Cast(S.SpittingCobra) then return ""; end
    end
    -- dragonsfire_grenade
    if S.DragonsfireGrenade:IsCastableP() and (true) then
      if AR.Cast(S.DragonsfireGrenade) then return ""; end
    end
    -- lacerate,if=refreshable|!ticking
    if S.Lacerate:IsCastableP() and (bool(refreshable) or not bool(ticking)) then
      if AR.Cast(S.Lacerate) then return ""; end
    end
    -- raptor_strike,if=buff.t21_2p_exposed_flank.up&!variable.mokTalented
    if S.RaptorStrike:IsCastableP() and (Player:BuffP(S.T212PExposedFlankBuff) and not bool(Moktalented)) then
      if AR.Cast(S.RaptorStrike) then return ""; end
    end
    -- raptor_strike,if=(talent.serpent_sting.enabled&!dot.serpent_sting.ticking)
    if S.RaptorStrike:IsCastableP() and ((S.SerpentSting:IsAvailable() and not Target:DebuffP(S.SerpentStingDebuff))) then
      if AR.Cast(S.RaptorStrike) then return ""; end
    end
    -- steel_trap,if=refreshable|!ticking
    if S.SteelTrap:IsCastableP() and (bool(refreshable) or not bool(ticking)) then
      if AR.Cast(S.SteelTrap) then return ""; end
    end
    -- caltrops,if=refreshable|!ticking
    if S.Caltrops:IsCastableP() and (bool(refreshable) or not bool(ticking)) then
      if AR.Cast(S.Caltrops) then return ""; end
    end
    -- explosive_trap
    if S.ExplosiveTrap:IsCastableP() and (true) then
      if AR.Cast(S.ExplosiveTrap) then return ""; end
    end
    -- butchery,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Butchery:IsCastableP() and (bool(Frizzosequipped) and bool(dot.lacerate.refreshable) and (focus > ((50 + 40) - ((S.FlankingStrike:CooldownRemainsP() / Player:GCD()) * (focus.regen * Player:GCD()))))) then
      if AR.Cast(S.Butchery) then return ""; end
    end
    -- carve,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Carve:IsCastableP() and (bool(Frizzosequipped) and bool(dot.lacerate.refreshable) and (focus > ((50 + 40) - ((S.FlankingStrike:CooldownRemainsP() / Player:GCD()) * (focus.regen * Player:GCD()))))) then
      if AR.Cast(S.Carve) then return ""; end
    end
    -- flanking_strike
    if S.FlankingStrike:IsCastableP() and (true) then
      if AR.Cast(S.FlankingStrike) then return ""; end
    end
    -- raptor_strike,if=(variable.mokTalented&buff.moknathal_tactics.remains<gcd*4)|(focus>((75-focus.regen*gcd)))
    if S.RaptorStrike:IsCastableP() and ((bool(Moktalented) and Player:BuffRemainsP(S.MoknathalTacticsBuff) < Player:GCD() * 4) or (focus > ((75 - focus.regen * Player:GCD())))) then
      if AR.Cast(S.RaptorStrike) then return ""; end
    end
  end
  local function Mokmaintain()
    -- raptor_strike,if=(buff.moknathal_tactics.remains<(gcd)|(buff.moknathal_tactics.stack<3))
    if S.RaptorStrike:IsCastableP() and ((Player:BuffRemainsP(S.MoknathalTacticsBuff) < (Player:GCD()) or (Player:BuffStackP(S.MoknathalTacticsBuff) < 3))) then
      if AR.Cast(S.RaptorStrike) then return ""; end
    end
  end
  -- variable,name=frizzosEquipped,value=(equipped.137043)
  if (true) then
    Frizzosequipped = num((I.Item137043:IsEquipped()))
  end
  -- variable,name=mokTalented,value=(talent.way_of_the_moknathal.enabled)
  if (true) then
    Moktalented = num((S.WayoftheMoknathal:IsAvailable()))
  end
  -- use_items
  if S.UseItems:IsCastableP() and (true) then
    if AR.Cast(S.UseItems) then return ""; end
  end
  -- muzzle,if=target.debuff.casting.react
  if S.Muzzle:IsCastableP() and Settings.General.InterruptEnabled and Target:IsInterruptible() and (bool(target.debuff.casting.react)) then
    if AR.CastAnnotated(S.Muzzle, false, "Interrupt") then return ""; end
  end
  -- auto_attack
  -- call_action_list,name=mokMaintain,if=variable.mokTalented
  if (bool(Moktalented)) then
    local ShouldReturn = Mokmaintain(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=CDs
  if (true) then
    local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=aoe,if=active_enemies>=3
  if (active_enemies >= 3) then
    local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=fillers,if=!buff.mongoose_fury.up
  if (not Player:BuffP(S.MongooseFuryBuff)) then
    local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
  if (not Player:BuffP(S.MongooseFuryBuff)) then
    local ShouldReturn = Bitetrigger(); if ShouldReturn then return ShouldReturn; end
  end
  -- call_action_list,name=bitePhase,if=buff.mongoose_fury.up
  if (Player:BuffP(S.MongooseFuryBuff)) then
    local ShouldReturn = Bitephase(); if ShouldReturn then return ShouldReturn; end
  end
end