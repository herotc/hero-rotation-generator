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
if not Spell.Warlock then Spell.Warlock = {} end
Spell.Warlock.Demonology = {
  SummonPet                             = Spell(30146),
  InnerDemons                           = Spell(267216),
  Demonbolt                             = Spell(264178),
  MemoryofLucidDreams                   = Spell(),
  SoulStrike                            = Spell(264057),
  DemonicConsumption                    = Spell(267215),
  HandofGuldan                          = Spell(105174),
  ShadowBolt                            = Spell(686),
  Implosion                             = Spell(196277),
  WildImpsBuff                          = Spell(),
  CallDreadstalkers                     = Spell(104316),
  BilescourgeBombers                    = Spell(267211),
  DemonicPowerBuff                      = Spell(265273),
  DemonicCalling                        = Spell(205145),
  GrimoireFelguard                      = Spell(111898),
  SummonDemonicTyrant                   = Spell(265187),
  DemonicCallingBuff                    = Spell(205146),
  DemonicCoreBuff                       = Spell(264173),
  SummonVilefiend                       = Spell(264119),
  FocusedAzeriteBeam                    = Spell(),
  PurifyingBlast                        = Spell(),
  BloodoftheEnemy                       = Spell(),
  ConcentratedFlame                     = Spell(),
  ConcentratedFlameBurnDebuff           = Spell(),
  Doom                                  = Spell(265412),
  DoomDebuff                            = Spell(265412),
  NetherPortal                          = Spell(267217),
  NetherPortalBuff                      = Spell(267218),
  GuardianofAzeroth                     = Spell(),
  PowerSiphon                           = Spell(264130),
  ExplosivePotential                    = Spell(275395),
  ExplosivePotentialBuff                = Spell(275398),
  DemonicStrength                       = Spell(267171),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  WorldveinResonance                    = Spell(),
  RippleInSpace                         = Spell(),
  DreadstalkersBuff                     = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  BalefulInvocation                     = Spell(287059),
  ShadowsBite                           = Spell(272944),
  ShadowsBiteBuff                       = Spell(272945),
  ReapingFlames                         = Spell()
};
local S = Spell.Warlock.Demonology;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Demonology = {
  BattlePotionofIntellect          = Item(163222),
  Item132369                       = Item(132369),
  AzsharasFontofPower              = Item(),
  PocketsizedComputationDevice     = Item(),
  RotcrustedVoodooDoll             = Item(),
  ShiverVenomRelic                 = Item(),
  AquipotentNautilus               = Item(),
  TidestormCodex                   = Item(165576),
  VialofStorms                     = Item()
};
local I = Item.Warlock.Demonology;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warlock.Commons,
  Demonology = HR.GUISettings.APL.Warlock.Demonology
};


local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.ConcentratedFlame:RegisterInFlight()
S.HandofGuldan:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function FutureShard ()
  local Shard = Player:SoulShards()
  if not Player:IsCasting() then
    return Shard
  else
    if Player:IsCasting(S.UnstableAffliction) 
        or Player:IsCasting(S.SeedOfCorruption) then
      return Shard - 1
    elseif Player:IsCasting(S.SummonDoomGuard) 
        or Player:IsCasting(S.SummonDoomGuardSuppremacy) 
        or Player:IsCasting(S.SummonInfernal) 
        or Player:IsCasting(S.SummonInfernalSuppremacy) 
        or Player:IsCasting(S.GrimoireFelhunter) 
        or Player:IsCasting(S.SummonFelhunter) then
      return Shard - 1
    else
      return Shard
    end
  end
end


local function EvaluateCycleDoom140(TargetUnit)
  return TargetUnit:DebuffRefreshableCP(S.DoomDebuff)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, BuildAShard, Implosion, NetherPortal, NetherPortalActive, NetherPortalBuilding, Opener
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsReadyP() then
      if HR.Cast(S.SummonPet, Settings.Demonology.GCDasOffGCD.SummonPet) then return "summon_pet 3"; end
    end
    -- inner_demons,if=talent.inner_demons.enabled
    if S.InnerDemons:IsCastableP() and (S.InnerDemons:IsAvailable()) then
      if HR.Cast(S.InnerDemons) then return "inner_demons 5"; end
    end
    -- snapshot_stats
    -- potion
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 10"; end
    end
    -- demonbolt
    if S.Demonbolt:IsCastableP() then
      if HR.Cast(S.Demonbolt) then return "demonbolt 12"; end
    end
  end
  BuildAShard = function()
    -- memory_of_lucid_dreams,if=soul_shard<2
    if S.MemoryofLucidDreams:IsCastableP() and (Player:SoulShardsP() < 2) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 14"; end
    end
    -- soul_strike,if=!talent.demonic_consumption.enabled|time>15|prev_gcd.1.hand_of_guldan&!buff.bloodlust.remains
    if S.SoulStrike:IsCastableP() and (not S.DemonicConsumption:IsAvailable() or HL.CombatTime() > 15 or Player:PrevGCDP(1, S.HandofGuldan) and not Player:HasHeroism()) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 16"; end
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 22"; end
    end
  end
  Implosion = function()
    -- implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
    if S.Implosion:IsCastableP() and ((Player:BuffStackP(S.WildImpsBuff) >= 6 and (Player:SoulShardsP() < 3 or Player:PrevGCDP(1, S.CallDreadstalkers) or Player:BuffStackP(S.WildImpsBuff) >= 9 or Player:PrevGCDP(1, S.BilescourgeBombers) or (not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan))) and not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan) and Player:BuffDownP(S.DemonicPowerBuff)) or (Target:TimeToDie() < 3 and Player:BuffStackP(S.WildImpsBuff) > 0) or (Player:PrevGCDP(2, S.CallDreadstalkers) and Player:BuffStackP(S.WildImpsBuff) > 2 and not S.DemonicCalling:IsAvailable())) then
      if HR.Cast(S.Implosion) then return "implosion 24"; end
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13 or not I.Item132369:IsEquipped()) then
      if HR.Cast(S.GrimoireFelguard, Settings.Demonology.GCDasOffGCD.GrimoireFelguard) then return "grimoire_felguard 56"; end
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 62"; end
    end
    -- summon_demonic_tyrant
    if S.SummonDemonicTyrant:IsCastableP() then
      if HR.Cast(S.SummonDemonicTyrant, Settings.Demonology.GCDasOffGCD.SummonDemonicTyrant) then return "summon_demonic_tyrant 74"; end
    end
    -- hand_of_guldan,if=soul_shard>=5
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 76"; end
    end
    -- hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and (((Player:PrevGCDP(2, S.HandofGuldan) or Player:BuffStackP(S.WildImpsBuff) >= 3) and Player:BuffStackP(S.WildImpsBuff) < 9) or S.SummonDemonicTyrant:CooldownRemainsP() <= Player:GCD() * 2 or Player:BuffRemainsP(S.DemonicPowerBuff) > Player:GCD() * 2)) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 78"; end
    end
    -- demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
    if S.Demonbolt:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) and Player:SoulShardsP() >= 1 and (Player:BuffStackP(S.WildImpsBuff) <= 3 or Player:PrevGCDP(3, S.HandofGuldan)) and Player:SoulShardsP() < 4 and Player:BuffP(S.DemonicCoreBuff)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 90"; end
    end
    -- summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() > 40 and Cache.EnemiesCount[40] <= 2) or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 100"; end
    end
    -- bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
    if S.BilescourgeBombers:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 9) then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 106"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 110"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 112"; end
    end
    -- blood_of_the_enemy
    if S.BloodoftheEnemy:IsCastableP() then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 114"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight&spell_targets.implosion<5
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight() and Cache.EnemiesCount[40] < 5) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 116"; end
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 124"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and (Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) <= Player:GCD() * 5.7)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 128"; end
    end
    -- doom,cycle_targets=1,max_cycle_targets=7,if=refreshable
    if S.Doom:IsCastableP() then
      if HR.CastCycle(S.Doom, 40, EvaluateCycleDoom140) then return "doom 148" end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
  NetherPortal = function()
    -- call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
    if (S.NetherPortal:CooldownRemainsP() < 20) then
      local ShouldReturn = NetherPortalBuilding(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
    if (S.NetherPortal:CooldownRemainsP() > 165) then
      local ShouldReturn = NetherPortalActive(); if ShouldReturn then return ShouldReturn; end
    end
  end
  NetherPortalActive = function()
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsReadyP() then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 159"; end
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13 or not I.Item132369:IsEquipped()) then
      if HR.Cast(S.GrimoireFelguard, Settings.Demonology.GCDasOffGCD.GrimoireFelguard) then return "grimoire_felguard 161"; end
    end
    -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 167"; end
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 173"; end
    end
    -- call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
    if (Player:SoulShardsP() == 1 and (S.CallDreadstalkers:CooldownRemainsP() < S.ShadowBolt:CastTime() or (S.BilescourgeBombers:IsAvailable() and S.BilescourgeBombers:CooldownRemainsP() < S.ShadowBolt:CastTime()))) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
    -- hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(165+action.hand_of_guldan.cast_time)
    if S.HandofGuldan:IsCastableP() and (((S.CallDreadstalkers:CooldownRemainsP() > S.Demonbolt:CastTime()) and (S.CallDreadstalkers:CooldownRemainsP() > S.ShadowBolt:CastTime())) and S.NetherPortal:CooldownRemainsP() > (165 + S.HandofGuldan:CastTime())) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 201"; end
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<5&soul_shard=0
    if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < 5 and Player:SoulShardsP() == 0) then
      if HR.Cast(S.SummonDemonicTyrant, Settings.Demonology.GCDasOffGCD.SummonDemonicTyrant) then return "summon_demonic_tyrant 221"; end
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+0.5
    if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < S.SummonDemonicTyrant:CastTime() + 0.5) then
      if HR.Cast(S.SummonDemonicTyrant, Settings.Demonology.GCDasOffGCD.SummonDemonicTyrant) then return "summon_demonic_tyrant 225"; end
    end
    -- demonbolt,if=buff.demonic_core.up&soul_shard<=3
    if S.Demonbolt:IsCastableP() and (Player:BuffP(S.DemonicCoreBuff) and Player:SoulShardsP() <= 3) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 233"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
  NetherPortalBuilding = function()
    -- use_item,name=azsharas_font_of_power,if=cooldown.nether_portal.remains<=5*spell_haste
    if I.AzsharasFontofPower:IsReady() and (S.NetherPortal:CooldownRemainsP() <= 5 * Player:SpellHaste()) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 239"; end
    end
    -- guardian_of_azeroth,if=!cooldown.nether_portal.remains&soul_shard>=5
    if S.GuardianofAzeroth:IsCastableP() and (not bool(S.NetherPortal:CooldownRemainsP()) and Player:SoulShardsP() >= 5) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 243"; end
    end
    -- nether_portal,if=soul_shard>=5
    if S.NetherPortal:IsReadyP() and (Player:SoulShardsP() >= 5) then
      if HR.Cast(S.NetherPortal) then return "nether_portal 247"; end
    end
    -- call_dreadstalkers,if=time>=30
    if S.CallDreadstalkers:IsReadyP() and (HL.CombatTime() >= 30) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 249"; end
    end
    -- hand_of_guldan,if=time>=30&cooldown.call_dreadstalkers.remains>18&soul_shard>=3
    if S.HandofGuldan:IsCastableP() and (HL.CombatTime() >= 30 and S.CallDreadstalkers:CooldownRemainsP() > 18 and Player:SoulShardsP() >= 3) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 251"; end
    end
    -- power_siphon,if=time>=30&buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
    if S.PowerSiphon:IsCastableP() and (HL.CombatTime() >= 30 and Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Player:SoulShardsP() >= 3) then
      if HR.Cast(S.PowerSiphon) then return "power_siphon 255"; end
    end
    -- hand_of_guldan,if=time>=30&soul_shard>=5
    if S.HandofGuldan:IsCastableP() and (HL.CombatTime() >= 30 and Player:SoulShardsP() >= 5) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 263"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
  Opener = function()
    -- hand_of_guldan,line_cd=30,if=azerite.explosive_potential.enabled
    if S.HandofGuldan:IsCastableP() and (S.ExplosivePotential:AzeriteEnabled()) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 267"; end
    end
    -- implosion,if=azerite.explosive_potential.enabled&buff.wild_imps.stack>2&buff.explosive_potential.down
    if S.Implosion:IsCastableP() and (S.ExplosivePotential:AzeriteEnabled() and Player:BuffStackP(S.WildImpsBuff) > 2 and Player:BuffDownP(S.ExplosivePotentialBuff)) then
      if HR.Cast(S.Implosion) then return "implosion 271"; end
    end
    -- doom,line_cd=30
    if S.Doom:IsCastableP() then
      if HR.Cast(S.Doom) then return "doom 279"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 281"; end
    end
    -- hand_of_guldan,if=prev_gcd.1.hand_of_guldan&soul_shard>0&prev_gcd.2.soul_strike
    if S.HandofGuldan:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) and Player:SoulShardsP() > 0 and Player:PrevGCDP(2, S.SoulStrike)) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 283"; end
    end
    -- demonic_strength,if=prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&(buff.wild_imps.stack>1&action.hand_of_guldan.in_flight)
    if S.DemonicStrength:IsReadyP() and (Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan) and (Player:BuffStackP(S.WildImpsBuff) > 1 and S.HandofGuldan:InFlight())) then
      if HR.Cast(S.DemonicStrength, Settings.Demonology.GCDasOffGCD.DemonicStrength) then return "demonic_strength 289"; end
    end
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsReadyP() then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 301"; end
    end
    -- soul_strike,line_cd=30,if=!buff.bloodlust.remains|time>5&prev_gcd.1.hand_of_guldan
    if S.SoulStrike:IsCastableP() and (not Player:HasHeroism() or HL.CombatTime() > 5 and Player:PrevGCDP(1, S.HandofGuldan)) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 303"; end
    end
    -- summon_vilefiend,if=soul_shard=5
    if S.SummonVilefiend:IsReadyP() and (Player:SoulShardsP() == 5) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 307"; end
    end
    -- grimoire_felguard,if=soul_shard=5
    if S.GrimoireFelguard:IsReadyP() and (Player:SoulShardsP() == 5) then
      if HR.Cast(S.GrimoireFelguard, Settings.Demonology.GCDasOffGCD.GrimoireFelguard) then return "grimoire_felguard 309"; end
    end
    -- call_dreadstalkers,if=soul_shard=5
    if S.CallDreadstalkers:IsReadyP() and (Player:SoulShardsP() == 5) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 311"; end
    end
    -- hand_of_guldan,if=soul_shard=5
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() == 5) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 313"; end
    end
    -- hand_of_guldan,if=soul_shard>=3&prev_gcd.2.hand_of_guldan&time>5&(prev_gcd.1.soul_strike|!talent.soul_strike.enabled&prev_gcd.1.shadow_bolt)
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and Player:PrevGCDP(2, S.HandofGuldan) and HL.CombatTime() > 5 and (Player:PrevGCDP(1, S.SoulStrike) or not S.SoulStrike:IsAvailable() and Player:PrevGCDP(1, S.ShadowBolt))) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 315"; end
    end
    -- summon_demonic_tyrant,if=prev_gcd.1.demonic_strength|prev_gcd.1.hand_of_guldan&prev_gcd.2.hand_of_guldan|!talent.demonic_strength.enabled&buff.wild_imps.stack+imps_spawned_during.2000%spell_haste>=6
    if S.SummonDemonicTyrant:IsCastableP() and (Player:PrevGCDP(1, S.DemonicStrength) or Player:PrevGCDP(1, S.HandofGuldan) and Player:PrevGCDP(2, S.HandofGuldan) or not S.DemonicStrength:IsAvailable() and Player:BuffStackP(S.WildImpsBuff) + imps_spawned_during.2000 / Player:SpellHaste() >= 6) then
      if HR.Cast(S.SummonDemonicTyrant, Settings.Demonology.GCDasOffGCD.SummonDemonicTyrant) then return "summon_demonic_tyrant 325"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.remains
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and bool(Player:BuffRemainsP(S.DemonicCoreBuff))) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 337"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- potion,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)&(!talent.nether_portal.enabled|cooldown.nether_portal.remains>160)|target.time_to_die<30
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions and (bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) and (not S.NetherPortal:IsAvailable() or S.NetherPortal:CooldownRemainsP() > 160) or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 344"; end
    end
    -- use_item,name=azsharas_font_of_power,if=cooldown.summon_demonic_tyrant.remains<=20&!talent.nether_portal.enabled
    if I.AzsharasFontofPower:IsReady() and (S.SummonDemonicTyrant:CooldownRemainsP() <= 20 and not S.NetherPortal:IsAvailable()) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 356"; end
    end
    -- use_items,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15
    -- berserking,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15
    if S.Berserking:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 363"; end
    end
    -- blood_fury,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 371"; end
    end
    -- fireblood,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15
    if S.Fireblood:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 379"; end
    end
    -- blood_of_the_enemy,if=pet.demonic_tyrant.active&pet.demonic_tyrant.remains<=15-gcd*3&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)
    if S.BloodoftheEnemy:IsCastableP() and (bool(pet.demonic_tyrant.active) and pet.demonic_tyrant.remains <= 15 - Player:GCD() * 3 and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5)) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 387"; end
    end
    -- worldvein_resonance,if=(pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15)
    if S.WorldveinResonance:IsCastableP() and ((bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) or Target:TimeToDie() <= 15)) then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 399"; end
    end
    -- ripple_in_space,if=pet.demonic_tyrant.active&(!essence.vision_of_perfection.major|!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>=cooldown.summon_demonic_tyrant.duration-5)|target.time_to_die<=15
    if S.RippleInSpace:IsCastableP() and (bool(pet.demonic_tyrant.active) and (not bool(essence.vision_of_perfection.major) or not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() >= S.SummonDemonicTyrant:BaseDuration() - 5) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 407"; end
    end
    -- use_item,name=pocketsized_computation_device,if=cooldown.summon_demonic_tyrant.remains>=20&cooldown.summon_demonic_tyrant.remains<=cooldown.summon_demonic_tyrant.duration-15|target.time_to_die<=30
    if I.PocketsizedComputationDevice:IsReady() and (S.SummonDemonicTyrant:CooldownRemainsP() >= 20 and S.SummonDemonicTyrant:CooldownRemainsP() <= S.SummonDemonicTyrant:BaseDuration() - 15 or Target:TimeToDie() <= 30) then
      if HR.CastSuggested(I.PocketsizedComputationDevice) then return "pocketsized_computation_device 415"; end
    end
    -- use_item,name=rotcrusted_voodoo_doll,if=(cooldown.summon_demonic_tyrant.remains>=25|target.time_to_die<=30)
    if I.RotcrustedVoodooDoll:IsReady() and ((S.SummonDemonicTyrant:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30)) then
      if HR.CastSuggested(I.RotcrustedVoodooDoll) then return "rotcrusted_voodoo_doll 423"; end
    end
    -- use_item,name=shiver_venom_relic,if=(cooldown.summon_demonic_tyrant.remains>=25|target.time_to_die<=30)
    if I.ShiverVenomRelic:IsReady() and ((S.SummonDemonicTyrant:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30)) then
      if HR.CastSuggested(I.ShiverVenomRelic) then return "shiver_venom_relic 427"; end
    end
    -- use_item,name=aquipotent_nautilus,if=(cooldown.summon_demonic_tyrant.remains>=25|target.time_to_die<=30)
    if I.AquipotentNautilus:IsReady() and ((S.SummonDemonicTyrant:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30)) then
      if HR.CastSuggested(I.AquipotentNautilus) then return "aquipotent_nautilus 431"; end
    end
    -- use_item,name=tidestorm_codex,if=(cooldown.summon_demonic_tyrant.remains>=25|target.time_to_die<=30)
    if I.TidestormCodex:IsReady() and ((S.SummonDemonicTyrant:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30)) then
      if HR.CastSuggested(I.TidestormCodex) then return "tidestorm_codex 435"; end
    end
    -- use_item,name=vial_of_storms,if=(cooldown.summon_demonic_tyrant.remains>=25|target.time_to_die<=30)
    if I.VialofStorms:IsReady() and ((S.SummonDemonicTyrant:CooldownRemainsP() >= 25 or Target:TimeToDie() <= 30)) then
      if HR.CastSuggested(I.VialofStorms) then return "vial_of_storms 439"; end
    end
    -- call_action_list,name=opener,if=!talent.nether_portal.enabled&time<30&!cooldown.summon_demonic_tyrant.remains
    if (not S.NetherPortal:IsAvailable() and HL.CombatTime() < 30 and not bool(S.SummonDemonicTyrant:CooldownRemainsP())) then
      local ShouldReturn = Opener(); if ShouldReturn then return ShouldReturn; end
    end
    -- use_item,name=azsharas_font_of_power,if=(time>30|!talent.nether_portal.enabled)&talent.grimoire_felguard.enabled&(target.time_to_die>120|target.time_to_die<cooldown.summon_demonic_tyrant.remains+15)|target.time_to_die<=35
    if I.AzsharasFontofPower:IsReady() and ((HL.CombatTime() > 30 or not S.NetherPortal:IsAvailable()) and S.GrimoireFelguard:IsAvailable() and (Target:TimeToDie() > 120 or Target:TimeToDie() < S.SummonDemonicTyrant:CooldownRemainsP() + 15) or Target:TimeToDie() <= 35) then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 449"; end
    end
    -- hand_of_guldan,if=azerite.explosive_potential.rank&time<5&soul_shard>2&buff.explosive_potential.down&buff.wild_imps.stack<3&!prev_gcd.1.hand_of_guldan&&!prev_gcd.2.hand_of_guldan
    if S.HandofGuldan:IsCastableP() and (bool(S.ExplosivePotential:AzeriteRank()) and HL.CombatTime() < 5 and Player:SoulShardsP() > 2 and Player:BuffDownP(S.ExplosivePotentialBuff) and Player:BuffStackP(S.WildImpsBuff) < 3 and not Player:PrevGCDP(1, S.HandofGuldan) and true and not Player:PrevGCDP(2, S.HandofGuldan)) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 457"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&buff.demonic_core.stack=4
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and Player:BuffStackP(S.DemonicCoreBuff) == 4) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 469"; end
    end
    -- implosion,if=azerite.explosive_potential.rank&buff.wild_imps.stack>2&buff.explosive_potential.remains<action.shadow_bolt.execute_time&(!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>12)
    if S.Implosion:IsCastableP() and (bool(S.ExplosivePotential:AzeriteRank()) and Player:BuffStackP(S.WildImpsBuff) > 2 and Player:BuffRemainsP(S.ExplosivePotentialBuff) < S.ShadowBolt:ExecuteTime() and (not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() > 12)) then
      if HR.Cast(S.Implosion) then return "implosion 475"; end
    end
    -- doom,if=!ticking&time_to_die>30&spell_targets.implosion<2&!buff.nether_portal.remains
    if S.Doom:IsCastableP() and (not Target:DebuffP(S.DoomDebuff) and Target:TimeToDie() > 30 and Cache.EnemiesCount[40] < 2 and not bool(Player:BuffRemainsP(S.NetherPortalBuff))) then
      if HR.Cast(S.Doom) then return "doom 491"; end
    end
    -- bilescourge_bombers,if=azerite.explosive_potential.rank>0&time<10&spell_targets.implosion<2&buff.dreadstalkers.remains&talent.nether_portal.enabled
    if S.BilescourgeBombers:IsReadyP() and (S.ExplosivePotential:AzeriteRank() > 0 and HL.CombatTime() < 10 and Cache.EnemiesCount[40] < 2 and bool(Player:BuffRemainsP(S.DreadstalkersBuff)) and S.NetherPortal:IsAvailable()) then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 507"; end
    end
    -- demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
    if S.DemonicStrength:IsReadyP() and ((Player:BuffStackP(S.WildImpsBuff) < 6 or Player:BuffP(S.DemonicPowerBuff)) or Cache.EnemiesCount[40] < 2) then
      if HR.Cast(S.DemonicStrength, Settings.Demonology.GCDasOffGCD.DemonicStrength) then return "demonic_strength 515"; end
    end
    -- call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
    if (S.NetherPortal:IsAvailable() and Cache.EnemiesCount[40] <= 2) then
      local ShouldReturn = NetherPortal(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=implosion,if=spell_targets.implosion>1
    if (Cache.EnemiesCount[40] > 1) then
      local ShouldReturn = Implosion(); if ShouldReturn then return ShouldReturn; end
    end
    -- guardian_of_azeroth,if=cooldown.summon_demonic_tyrant.remains<=15|target.time_to_die<=30
    if S.GuardianofAzeroth:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() <= 15 or Target:TimeToDie() <= 30) then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 527"; end
    end
    -- grimoire_felguard,if=(target.time_to_die>120|target.time_to_die<cooldown.summon_demonic_tyrant.remains+15|cooldown.summon_demonic_tyrant.remains<13)
    if S.GrimoireFelguard:IsReadyP() and ((Target:TimeToDie() > 120 or Target:TimeToDie() < S.SummonDemonicTyrant:CooldownRemainsP() + 15 or S.SummonDemonicTyrant:CooldownRemainsP() < 13)) then
      if HR.Cast(S.GrimoireFelguard, Settings.Demonology.GCDasOffGCD.GrimoireFelguard) then return "grimoire_felguard 531"; end
    end
    -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 537"; end
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 543"; end
    end
    -- the_unbound_force,if=buff.reckless_force.react
    if S.TheUnboundForce:IsCastableP() and (bool(Player:BuffStackP(S.RecklessForceBuff))) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 555"; end
    end
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsReadyP() then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 559"; end
    end
    -- hand_of_guldan,if=(azerite.baleful_invocation.enabled|talent.demonic_consumption.enabled)&prev_gcd.1.hand_of_guldan&cooldown.summon_demonic_tyrant.remains<2
    if S.HandofGuldan:IsCastableP() and ((S.BalefulInvocation:AzeriteEnabled() or S.DemonicConsumption:IsAvailable()) and Player:PrevGCDP(1, S.HandofGuldan) and S.SummonDemonicTyrant:CooldownRemainsP() < 2) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 561"; end
    end
    -- summon_demonic_tyrant,if=soul_shard<3&(!talent.demonic_consumption.enabled|buff.wild_imps.stack+imps_spawned_during.2000%spell_haste>=6&time_to_imps.all.remains<cast_time)|target.time_to_die<20
    if S.SummonDemonicTyrant:IsCastableP() and (Player:SoulShardsP() < 3 and (not S.DemonicConsumption:IsAvailable() or Player:BuffStackP(S.WildImpsBuff) + imps_spawned_during.2000 / Player:SpellHaste() >= 6 and time_to_imps.all.remains < S.SummonDemonicTyrant:CastTime()) or Target:TimeToDie() < 20) then
      if HR.Cast(S.SummonDemonicTyrant, Settings.Demonology.GCDasOffGCD.SummonDemonicTyrant) then return "summon_demonic_tyrant 571"; end
    end
    -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
    if S.PowerSiphon:IsCastableP() and (Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Cache.EnemiesCount[40] < 2) then
      if HR.Cast(S.PowerSiphon) then return "power_siphon 581"; end
    end
    -- doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
    if S.Doom:IsCastableP() and (S.Doom:IsAvailable() and Target:DebuffRefreshableCP(S.DoomDebuff) and Target:TimeToDie() > (Target:DebuffRemainsP(S.DoomDebuff) + 30)) then
      if HR.Cast(S.Doom) then return "doom 589"; end
    end
    -- hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(cooldown.summon_demonic_tyrant.remains>20|(cooldown.summon_demonic_tyrant.remains<gcd*2&talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains<gcd*4&!talent.demonic_consumption.enabled))&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5 or (Player:SoulShardsP() >= 3 and S.CallDreadstalkers:CooldownRemainsP() > 4 and (S.SummonDemonicTyrant:CooldownRemainsP() > 20 or (S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 2 and S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 4 and not S.DemonicConsumption:IsAvailable())) and (not S.SummonVilefiend:IsAvailable() or S.SummonVilefiend:CooldownRemainsP() > 3))) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 607"; end
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 625"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<6|cooldown.summon_demonic_tyrant.remains>22&!azerite.shadows_bite.enabled)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25|buff.shadows_bite.remains)
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 6 or S.SummonDemonicTyrant:CooldownRemainsP() > 22 and not S.ShadowsBite:AzeriteEnabled()) or Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) < 5 or Target:TimeToDie() < 25 or bool(Player:BuffRemainsP(S.ShadowsBiteBuff)))) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 629"; end
    end
    -- focused_azerite_beam,if=!pet.demonic_tyrant.active
    if S.FocusedAzeriteBeam:IsCastableP() and (not bool(pet.demonic_tyrant.active)) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 649"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 651"; end
    end
    -- blood_of_the_enemy
    if S.BloodoftheEnemy:IsCastableP() then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 653"; end
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight&!pet.demonic_tyrant.active
    if S.ConcentratedFlame:IsCastableP() and (not bool(Target:DebuffRemainsP(S.ConcentratedFlameBurnDebuff)) and not S.ConcentratedFlame:InFlight() and not bool(pet.demonic_tyrant.active)) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 655"; end
    end
    -- reaping_flames,if=!pet.demonic_tyrant.active
    if S.ReapingFlames:IsCastableP() and (not bool(pet.demonic_tyrant.active)) then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 663"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(266, APL)
