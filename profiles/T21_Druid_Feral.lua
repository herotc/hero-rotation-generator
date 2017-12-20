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
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Feral = {
  Regrowth                              = Spell(8936),
  Bloodtalons                           = Spell(155672),
  CatForm                               = Spell(768),
  Prowl                                 = Spell(5215),
  Dash                                  = Spell(1850),
  CatFormBuff                           = Spell(768),
  IncarnationBuff                       = Spell(102543),
  JungleStalkerBuff                     = Spell(252071),
  Berserk                               = Spell(106951),
  TigersFury                            = Spell(5217),
  TigersFuryBuff                        = Spell(5217),
  Berserking                            = Spell(26297),
  ElunesGuidance                        = Spell(202060),
  Incarnation                           = Spell(102543),
  BerserkBuff                           = Spell(106951),
  AshamanesFrenzy                       = Spell(210722),
  BloodtalonsBuff                       = Spell(145152),
  Shadowmeld                            = Spell(58984),
  Rake                                  = Spell(1822),
  RakeDebuff                            = Spell(155722),
  UseItems                              = Spell(),
  ProwlBuff                             = Spell(5215),
  ShadowmeldBuff                        = Spell(58984),
  FerociousBite                         = Spell(22568),
  PredatorySwiftnessBuff                = Spell(69369),
  RipDebuff                             = Spell(1079),
  ApexPredatorBuff                      = Spell(252752),
  MomentofClarity                       = Spell(),
  PoolResource                          = Spell(9999000010),
  SavageRoar                            = Spell(52610),
  SavageRoarBuff                        = Spell(52610),
  Rip                                   = Spell(1079),
  Maim                                  = Spell(22570),
  FieryRedMaimersBuff                   = Spell(236757),
  BrutalSlash                           = Spell(202028),
  ThrashCat                             = Spell(106830),
  MoonfireCat                           = Spell(155625),
  ClearcastingBuff                      = Spell(135700),
  SwipeCat                              = Spell(106785),
  Shred                                 = Spell(5221),
  LunarInspiration                      = Spell(155580),
  Sabertooth                            = Spell(202031)
};
local S = Spell.Druid.Feral;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Feral = {
  LuffaWrappings                   = Item(137056),
  OldWar                           = Item(127844),
  AiluroPouncers                   = Item(137024)
};
local I = Item.Druid.Feral;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = AR.Commons.Everyone;
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Druid.Commons,
  Feral = AR.GUISettings.APL.Druid.Feral
};

-- Variables
local VarUseThrash = 0;

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
    -- regrowth,if=talent.bloodtalons.enabled
    if S.Regrowth:IsCastableP() and (S.Bloodtalons:IsAvailable()) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- variable,name=use_thrash,value=0
    if (true) then
      VarUseThrash = 0
    end
    -- variable,name=use_thrash,value=1,if=equipped.luffa_wrappings
    if (I.LuffaWrappings:IsEquipped()) then
      VarUseThrash = 1
    end
    -- cat_form
    if S.CatForm:IsCastableP() and (true) then
      if AR.Cast(S.CatForm) then return ""; end
    end
    -- prowl
    if S.Prowl:IsCastableP() and (true) then
      if AR.Cast(S.Prowl) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and (true) then
      if AR.CastSuggested(I.OldWar) then return ""; end
    end
  end
  local function Cooldowns()
    -- dash,if=!buff.cat_form.up
    if S.Dash:IsCastableP() and (not Player:BuffP(S.CatFormBuff)) then
      if AR.Cast(S.Dash) then return ""; end
    end
    -- prowl,if=buff.incarnation.remains<0.5&buff.jungle_stalker.up
    if S.Prowl:IsCastableP() and (Player:BuffRemainsP(S.IncarnationBuff) < 0.5 and Player:BuffP(S.JungleStalkerBuff)) then
      if AR.Cast(S.Prowl) then return ""; end
    end
    -- berserk,if=energy>=30&(cooldown.tigers_fury.remains>5|buff.tigers_fury.up)
    if S.Berserk:IsCastableP() and (Player:Energy() >= 30 and (S.TigersFury:CooldownRemainsP() > 5 or Player:BuffP(S.TigersFuryBuff))) then
      if AR.Cast(S.Berserk) then return ""; end
    end
    -- tigers_fury,if=energy.deficit>=60
    if S.TigersFury:IsCastableP() and (Player:EnergyDeficit() >= 60) then
      if AR.Cast(S.TigersFury) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and AR.CDsON() and (true) then
      if AR.Cast(S.Berserking, Settings.Feral.OffGCDasOffGCD.Berserking) then return ""; end
    end
    -- elunes_guidance,if=combo_points=0&energy>=50
    if S.ElunesGuidance:IsCastableP() and (Player:ComboPoints() == 0 and Player:Energy() >= 50) then
      if AR.Cast(S.ElunesGuidance) then return ""; end
    end
    -- incarnation,if=energy>=30&(cooldown.tigers_fury.remains>15|buff.tigers_fury.up)
    if S.Incarnation:IsCastableP() and (Player:Energy() >= 30 and (S.TigersFury:CooldownRemainsP() > 15 or Player:BuffP(S.TigersFuryBuff))) then
      if AR.Cast(S.Incarnation) then return ""; end
    end
    -- potion,name=prolonged_power,if=target.time_to_die<65|(time_to_die<180&(buff.berserk.up|buff.incarnation.up))
    if I.OldWar:IsReady() and Settings.Commons.UsePotions and (Target:TimeToDie() < 65 or (Target:TimeToDie() < 180 and (Player:BuffP(S.BerserkBuff) or Player:BuffP(S.IncarnationBuff)))) then
      if AR.CastSuggested(I.OldWar) then return ""; end
    end
    -- ashamanes_frenzy,if=combo_points>=2&(!talent.bloodtalons.enabled|buff.bloodtalons.up)
    if S.AshamanesFrenzy:IsCastableP() and (Player:ComboPoints() >= 2 and (not S.Bloodtalons:IsAvailable() or Player:BuffP(S.BloodtalonsBuff))) then
      if AR.Cast(S.AshamanesFrenzy) then return ""; end
    end
    -- shadowmeld,if=combo_points<5&energy>=action.rake.cost&dot.rake.pmultiplier<2.1&buff.tigers_fury.up&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(!talent.incarnation.enabled|cooldown.incarnation.remains>18)&!buff.incarnation.up
    if S.Shadowmeld:IsCastableP() and (Player:ComboPoints() < 5 and Player:Energy() >= S.Rake:Cost() and dot.rake.pmultiplier < 2.1 and Player:BuffP(S.TigersFuryBuff) and (Player:BuffP(S.BloodtalonsBuff) or not S.Bloodtalons:IsAvailable()) and (not S.Incarnation:IsAvailable() or S.Incarnation:CooldownRemainsP() > 18) and not Player:BuffP(S.IncarnationBuff)) then
      if AR.Cast(S.Shadowmeld) then return ""; end
    end
    -- use_items
    if S.UseItems:IsCastableP() and (true) then
      if AR.Cast(S.UseItems) then return ""; end
    end
  end
  local function SingleTarget()
    -- cat_form,if=!buff.cat_form.up
    if S.CatForm:IsCastableP() and (not Player:BuffP(S.CatFormBuff)) then
      if AR.Cast(S.CatForm) then return ""; end
    end
    -- rake,if=buff.prowl.up|buff.shadowmeld.up
    if S.Rake:IsCastableP() and (Player:BuffP(S.ProwlBuff) or Player:BuffP(S.ShadowmeldBuff)) then
      if AR.Cast(S.Rake) then return ""; end
    end
    -- auto_attack
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- ferocious_bite,target_if=dot.rip.ticking&dot.rip.remains<3&target.time_to_die>10&(target.health.pct<25|talent.sabertooth.enabled)
    if S.FerociousBite:IsCastableP() and (true) then
      if AR.Cast(S.FerociousBite) then return ""; end
    end
    -- regrowth,if=combo_points=5&buff.predatory_swiftness.up&talent.bloodtalons.enabled&buff.bloodtalons.down&(!buff.incarnation.up|dot.rip.remains<8)
    if S.Regrowth:IsCastableP() and (Player:ComboPoints() == 5 and Player:BuffP(S.PredatorySwiftnessBuff) and S.Bloodtalons:IsAvailable() and Player:BuffDownP(S.BloodtalonsBuff) and (not Player:BuffP(S.IncarnationBuff) or Target:DebuffRemainsP(S.RipDebuff) < 8)) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- regrowth,if=combo_points>3&talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.apex_predator.up&buff.incarnation.down
    if S.Regrowth:IsCastableP() and (Player:ComboPoints() > 3 and S.Bloodtalons:IsAvailable() and Player:BuffP(S.PredatorySwiftnessBuff) and Player:BuffP(S.ApexPredatorBuff) and Player:BuffDownP(S.IncarnationBuff)) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- ferocious_bite,if=buff.apex_predator.up&((combo_points>4&(buff.incarnation.up|talent.moment_of_clarity.enabled))|(talent.bloodtalons.enabled&buff.bloodtalons.up&combo_points>3))
    if S.FerociousBite:IsCastableP() and (Player:BuffP(S.ApexPredatorBuff) and ((Player:ComboPoints() > 4 and (Player:BuffP(S.IncarnationBuff) or S.MomentofClarity:IsAvailable())) or (S.Bloodtalons:IsAvailable() and Player:BuffP(S.BloodtalonsBuff) and Player:ComboPoints() > 3))) then
      if AR.Cast(S.FerociousBite) then return ""; end
    end
    -- run_action_list,name=st_finishers,if=combo_points>4
    if (Player:ComboPoints() > 4) then
      return StFinishers();
    end
    -- run_action_list,name=st_generators
    if (true) then
      return StGenerators();
    end
  end
  local function StFinishers()
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- savage_roar,if=buff.savage_roar.down
    if S.SavageRoar:IsCastableP() and (Player:BuffDownP(S.SavageRoarBuff)) then
      if AR.Cast(S.SavageRoar) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- rip,target_if=!ticking|(remains<=duration*0.3)&(target.health.pct>25&!talent.sabertooth.enabled)|(remains<=duration*0.8&persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die>8
    if S.Rip:IsCastableP() and (true) then
      if AR.Cast(S.Rip) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- savage_roar,if=buff.savage_roar.remains<12
    if S.SavageRoar:IsCastableP() and (Player:BuffRemainsP(S.SavageRoarBuff) < 12) then
      if AR.Cast(S.SavageRoar) then return ""; end
    end
    -- maim,if=buff.fiery_red_maimers.up
    if S.Maim:IsCastableP() and (Player:BuffP(S.FieryRedMaimersBuff)) then
      if AR.Cast(S.Maim) then return ""; end
    end
    -- ferocious_bite,max_energy=1
    if S.FerociousBite:IsCastableP() and (true) then
      if AR.Cast(S.FerociousBite) then return ""; end
    end
  end
  local function StGenerators()
    -- regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points>=2&cooldown.ashamanes_frenzy.remains<gcd
    if S.Regrowth:IsCastableP() and (S.Bloodtalons:IsAvailable() and Player:BuffP(S.PredatorySwiftnessBuff) and Player:BuffDownP(S.BloodtalonsBuff) and Player:ComboPoints() >= 2 and S.AshamanesFrenzy:CooldownRemainsP() < Player:GCD()) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points=4&dot.rake.remains<4
    if S.Regrowth:IsCastableP() and (S.Bloodtalons:IsAvailable() and Player:BuffP(S.PredatorySwiftnessBuff) and Player:BuffDownP(S.BloodtalonsBuff) and Player:ComboPoints() == 4 and Target:DebuffRemainsP(S.RakeDebuff) < 4) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- regrowth,if=equipped.ailuro_pouncers&talent.bloodtalons.enabled&(buff.predatory_swiftness.stack>2|(buff.predatory_swiftness.stack>1&dot.rake.remains<3))&buff.bloodtalons.down
    if S.Regrowth:IsCastableP() and (I.AiluroPouncers:IsEquipped() and S.Bloodtalons:IsAvailable() and (Player:BuffStackP(S.PredatorySwiftnessBuff) > 2 or (Player:BuffStackP(S.PredatorySwiftnessBuff) > 1 and Target:DebuffRemainsP(S.RakeDebuff) < 3)) and Player:BuffDownP(S.BloodtalonsBuff)) then
      if AR.Cast(S.Regrowth) then return ""; end
    end
    -- brutal_slash,if=spell_targets.brutal_slash>desired_targets
    if S.BrutalSlash:IsCastableP() and (Cache.EnemiesCount[8] > desired_targets) then
      if AR.Cast(S.BrutalSlash) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- thrash_cat,if=refreshable&(spell_targets.thrash_cat>2)
    if S.ThrashCat:IsCastableP() and (Target:DebuffRefreshableCP(S.ThrashCat) and (Cache.EnemiesCount[8] > 2)) then
      if AR.Cast(S.ThrashCat) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- thrash_cat,if=spell_targets.thrash_cat>3&equipped.luffa_wrappings&talent.brutal_slash.enabled
    if S.ThrashCat:IsCastableP() and (Cache.EnemiesCount[8] > 3 and I.LuffaWrappings:IsEquipped() and S.BrutalSlash:IsAvailable()) then
      if AR.Cast(S.ThrashCat) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- rake,target_if=!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)&target.time_to_die>4
    if S.Rake:IsCastableP() and (true) then
      if AR.Cast(S.Rake) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- rake,target_if=talent.bloodtalons.enabled&buff.bloodtalons.up&((remains<=7)&persistent_multiplier>dot.rake.pmultiplier*0.85)&target.time_to_die>4
    if S.Rake:IsCastableP() and (true) then
      if AR.Cast(S.Rake) then return ""; end
    end
    -- brutal_slash,if=(buff.tigers_fury.up&(raid_event.adds.in>(1+max_charges-charges_fractional)*recharge_time))
    if S.BrutalSlash:IsCastableP() and ((Player:BuffP(S.TigersFuryBuff) and (10000000000 > (1 + S.BrutalSlash:MaxCharges() - S.BrutalSlash:ChargesFractional()) * S.BrutalSlash:RechargeP()))) then
      if AR.Cast(S.BrutalSlash) then return ""; end
    end
    -- moonfire_cat,target_if=refreshable
    if S.MoonfireCat:IsCastableP() and (true) then
      if AR.Cast(S.MoonfireCat) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- thrash_cat,if=refreshable&(variable.use_thrash=2|spell_targets.thrash_cat>1)
    if S.ThrashCat:IsCastableP() and (Target:DebuffRefreshableCP(S.ThrashCat) and (VarUseThrash == 2 or Cache.EnemiesCount[8] > 1)) then
      if AR.Cast(S.ThrashCat) then return ""; end
    end
    -- thrash_cat,if=refreshable&variable.use_thrash=1&buff.clearcasting.react
    if S.ThrashCat:IsCastableP() and (Target:DebuffRefreshableCP(S.ThrashCat) and VarUseThrash == 1 and bool(Player:BuffStackP(S.ClearcastingBuff))) then
      if AR.Cast(S.ThrashCat) then return ""; end
    end
    -- pool_resource,for_next=1
    if S.PoolResource:IsCastableP() and (true) then
      if AR.Cast(S.PoolResource) then return ""; end
    end
    -- swipe_cat,if=spell_targets.swipe_cat>1
    if S.SwipeCat:IsCastableP() and (Cache.EnemiesCount[8] > 1) then
      if AR.Cast(S.SwipeCat) then return ""; end
    end
    -- shred,if=dot.rake.remains>(action.shred.cost+action.rake.cost-energy)%energy.regen|buff.clearcasting.react
    if S.Shred:IsCastableP() and (Target:DebuffRemainsP(S.RakeDebuff) > (S.Shred:Cost() + S.Rake:Cost() - Player:Energy()) / Player:EnergyRegen() or bool(Player:BuffStackP(S.ClearcastingBuff))) then
      if AR.Cast(S.Shred) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- run_action_list,name=single_target,if=dot.rip.ticking|time>15
  if (Target:DebuffP(S.RipDebuff) or AC.CombatTime() > 15) then
    return SingleTarget();
  end
  -- rake,if=!ticking|buff.prowl.up
  if S.Rake:IsCastableP() and (not Target:DebuffP(S.Rake) or Player:BuffP(S.ProwlBuff)) then
    if AR.Cast(S.Rake) then return ""; end
  end
  -- dash,if=!buff.cat_form.up
  if S.Dash:IsCastableP() and (not Player:BuffP(S.CatFormBuff)) then
    if AR.Cast(S.Dash) then return ""; end
  end
  -- auto_attack
  -- moonfire_cat,if=talent.lunar_inspiration.enabled&!ticking
  if S.MoonfireCat:IsCastableP() and (S.LunarInspiration:IsAvailable() and not Target:DebuffP(S.MoonfireCat)) then
    if AR.Cast(S.MoonfireCat) then return ""; end
  end
  -- savage_roar,if=!buff.savage_roar.up
  if S.SavageRoar:IsCastableP() and (not Player:BuffP(S.SavageRoarBuff)) then
    if AR.Cast(S.SavageRoar) then return ""; end
  end
  -- berserk
  if S.Berserk:IsCastableP() and (true) then
    if AR.Cast(S.Berserk) then return ""; end
  end
  -- incarnation
  if S.Incarnation:IsCastableP() and (true) then
    if AR.Cast(S.Incarnation) then return ""; end
  end
  -- tigers_fury
  if S.TigersFury:IsCastableP() and (true) then
    if AR.Cast(S.TigersFury) then return ""; end
  end
  -- ashamanes_frenzy
  if S.AshamanesFrenzy:IsCastableP() and (true) then
    if AR.Cast(S.AshamanesFrenzy) then return ""; end
  end
  -- regrowth,if=(talent.sabertooth.enabled|buff.predatory_swiftness.up)&talent.bloodtalons.enabled&buff.bloodtalons.down&combo_points=5
  if S.Regrowth:IsCastableP() and ((S.Sabertooth:IsAvailable() or Player:BuffP(S.PredatorySwiftnessBuff)) and S.Bloodtalons:IsAvailable() and Player:BuffDownP(S.BloodtalonsBuff) and Player:ComboPoints() == 5) then
    if AR.Cast(S.Regrowth) then return ""; end
  end
  -- rip,if=combo_points=5
  if S.Rip:IsCastableP() and (Player:ComboPoints() == 5) then
    if AR.Cast(S.Rip) then return ""; end
  end
  -- thrash_cat,if=!ticking&variable.use_thrash>0
  if S.ThrashCat:IsCastableP() and (not Target:DebuffP(S.ThrashCat) and VarUseThrash > 0) then
    if AR.Cast(S.ThrashCat) then return ""; end
  end
  -- shred
  if S.Shred:IsCastableP() and (true) then
    if AR.Cast(S.Shred) then return ""; end
  end
end

AR.SetAPL(103, APL)
