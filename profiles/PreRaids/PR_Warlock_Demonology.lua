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
  ForbiddenKnowledge                    = Spell(),
  ForbiddenKnowledgeBuff                = Spell(),
  DemonicCoreBuff                       = Spell(264173),
  SummonDemonicTyrant                   = Spell(265187),
  SoulStrike                            = Spell(264057),
  ShadowBolt                            = Spell(686),
  Implosion                             = Spell(196277),
  WildImpsBuff                          = Spell(),
  CallDreadstalkers                     = Spell(104316),
  BilescourgeBombers                    = Spell(267211),
  HandofGuldan                          = Spell(105174),
  DemonicPowerBuff                      = Spell(265273),
  DemonicCalling                        = Spell(205145),
  GrimoireFelguard                      = Spell(111898),
  DemonicCallingBuff                    = Spell(205146),
  SummonVilefiend                       = Spell(264119),
  Doom                                  = Spell(265412),
  DoomDebuff                            = Spell(265412),
  NetherPortal                          = Spell(267217),
  NetherPortalBuff                      = Spell(267218),
  PowerSiphon                           = Spell(264130),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  DemonicStrength                       = Spell(267171),
  DreadstalkersBuff                     = Spell(),
  GrimoireFelguardBuff                  = Spell()
};
local S = Spell.Warlock.Demonology;

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Demonology = {
  ProlongedPower                   = Item(142117),
  Item132369                       = Item(132369)
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

-- Variables

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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, BuildAShard, Implosion, NetherPortal, NetherPortalActive, NetherPortalBuilding
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet) then return "summon_pet 3"; end
    end
    -- inner_demons,if=talent.inner_demons.enabled
    if S.InnerDemons:IsCastableP() and (S.InnerDemons:IsAvailable()) then
      if HR.Cast(S.InnerDemons) then return "inner_demons 5"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 10"; end
    end
    -- demonbolt
    if S.Demonbolt:IsCastableP() then
      if HR.Cast(S.Demonbolt) then return "demonbolt 12"; end
    end
  end
  BuildAShard = function()
    -- demonbolt,if=azerite.forbidden_knowledge.enabled&buff.forbidden_knowledge.react&!buff.demonic_core.react&cooldown.summon_demonic_tyrant.remains>20
    if S.Demonbolt:IsCastableP() and (S.ForbiddenKnowledge:AzeriteEnabled() and bool(Player:BuffStackP(S.ForbiddenKnowledgeBuff)) and not bool(Player:BuffStackP(S.DemonicCoreBuff)) and S.SummonDemonicTyrant:CooldownRemainsP() > 20) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 14"; end
    end
    -- soul_strike
    if S.SoulStrike:IsCastableP() then
      if HR.Cast(S.SoulStrike) then return "soul_strike 24"; end
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      if HR.Cast(S.ShadowBolt) then return "shadow_bolt 26"; end
    end
  end
  Implosion = function()
    -- implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
    if S.Implosion:IsCastableP() and ((Player:BuffStackP(S.WildImpsBuff) >= 6 and (Player:SoulShardsP() < 3 or Player:PrevGCDP(1, S.CallDreadstalkers) or Player:BuffStackP(S.WildImpsBuff) >= 9 or Player:PrevGCDP(1, S.BilescourgeBombers) or (not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan))) and not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan) and Player:BuffDownP(S.DemonicPowerBuff)) or (Target:TimeToDie() < 3 and Player:BuffStackP(S.WildImpsBuff) > 0) or (Player:PrevGCDP(2, S.CallDreadstalkers) and Player:BuffStackP(S.WildImpsBuff) > 2 and not S.DemonicCalling:IsAvailable())) then
      if HR.Cast(S.Implosion) then return "implosion 28"; end
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13 or not I.Item132369:IsEquipped()) then
      if HR.Cast(S.GrimoireFelguard) then return "grimoire_felguard 60"; end
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 66"; end
    end
    -- summon_demonic_tyrant
    if S.SummonDemonicTyrant:IsCastableP() then
      if HR.Cast(S.SummonDemonicTyrant) then return "summon_demonic_tyrant 78"; end
    end
    -- hand_of_guldan,if=soul_shard>=5
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 80"; end
    end
    -- hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and (((Player:PrevGCDP(2, S.HandofGuldan) or Player:BuffStackP(S.WildImpsBuff) >= 3) and Player:BuffStackP(S.WildImpsBuff) < 9) or S.SummonDemonicTyrant:CooldownRemainsP() <= Player:GCD() * 2 or Player:BuffRemainsP(S.DemonicPowerBuff) > Player:GCD() * 2)) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 82"; end
    end
    -- demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
    if S.Demonbolt:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) and Player:SoulShardsP() >= 1 and (Player:BuffStackP(S.WildImpsBuff) <= 3 or Player:PrevGCDP(3, S.HandofGuldan)) and Player:SoulShardsP() < 4 and Player:BuffP(S.DemonicCoreBuff)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 94"; end
    end
    -- summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() > 40 and Cache.EnemiesCount[40] <= 2) or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 104"; end
    end
    -- bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
    if S.BilescourgeBombers:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 9) then
      if HR.Cast(S.BilescourgeBombers) then return "bilescourge_bombers 110"; end
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 114"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and (Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) <= Player:GCD() * 5.7)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 118"; end
    end
    -- doom,cycle_targets=1,max_cycle_targets=7,if=refreshable
    if S.Doom:IsCastableP() then
      if HR.CastCycle(S.Doom, 40, function(TargetUnit) return TargetUnit:DebuffRefreshableCP(S.DoomDebuff) end) then return "doom 136" end
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
    -- call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>160
    if (S.NetherPortal:CooldownRemainsP() > 160) then
      local ShouldReturn = NetherPortalActive(); if ShouldReturn then return ShouldReturn; end
    end
  end
  NetherPortalActive = function()
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13 or not I.Item132369:IsEquipped()) then
      if HR.Cast(S.GrimoireFelguard) then return "grimoire_felguard 147"; end
    end
    -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 153"; end
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 159"; end
    end
    -- call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
    if (Player:SoulShardsP() == 1 and (S.CallDreadstalkers:CooldownRemainsP() < S.ShadowBolt:CastTime() or (S.BilescourgeBombers:IsAvailable() and S.BilescourgeBombers:CooldownRemainsP() < S.ShadowBolt:CastTime()))) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
    -- hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(160+action.hand_of_guldan.cast_time)
    if S.HandofGuldan:IsCastableP() and (((S.CallDreadstalkers:CooldownRemainsP() > S.Demonbolt:CastTime()) and (S.CallDreadstalkers:CooldownRemainsP() > S.ShadowBolt:CastTime())) and S.NetherPortal:CooldownRemainsP() > (160 + S.HandofGuldan:CastTime())) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 187"; end
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<10&soul_shard=0
    if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < 10 and Player:SoulShardsP() == 0) then
      if HR.Cast(S.SummonDemonicTyrant) then return "summon_demonic_tyrant 207"; end
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+5.5
    if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < S.SummonDemonicTyrant:CastTime() + 5.5) then
      if HR.Cast(S.SummonDemonicTyrant) then return "summon_demonic_tyrant 211"; end
    end
    -- demonbolt,if=buff.demonic_core.up
    if S.Demonbolt:IsCastableP() and (Player:BuffP(S.DemonicCoreBuff)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 219"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
  NetherPortalBuilding = function()
    -- nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
    if S.NetherPortal:IsCastableP() and (Player:SoulShardsP() >= 5 and (not S.PowerSiphon:IsAvailable() or Player:BuffP(S.DemonicCoreBuff))) then
      if HR.Cast(S.NetherPortal) then return "nether_portal 225"; end
    end
    -- call_dreadstalkers
    if S.CallDreadstalkers:IsCastableP() then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 231"; end
    end
    -- hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
    if S.HandofGuldan:IsCastableP() and (S.CallDreadstalkers:CooldownRemainsP() > 18 and Player:SoulShardsP() >= 3) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 233"; end
    end
    -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
    if S.PowerSiphon:IsCastableP() and (Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Player:SoulShardsP() >= 3) then
      if HR.Cast(S.PowerSiphon) then return "power_siphon 237"; end
    end
    -- hand_of_guldan,if=soul_shard>=5
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 245"; end
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
    -- potion,if=pet.demonic_tyrant.active|target.time_to_die<30
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(pet.demonic_tyrant.active) or Target:TimeToDie() < 30) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 250"; end
    end
    -- use_items,if=pet.demonic_tyrant.active|target.time_to_die<=15
    -- berserking,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.Berserking:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 253"; end
    end
    -- blood_fury,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.BloodFury:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 255"; end
    end
    -- fireblood,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.Fireblood:IsCastableP() and HR.CDsON() and (bool(pet.demonic_tyrant.active) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 257"; end
    end
    -- doom,if=!ticking&time_to_die>30&spell_targets.implosion<2
    if S.Doom:IsCastableP() and (not Target:DebuffP(S.DoomDebuff) and Target:TimeToDie() > 30 and Cache.EnemiesCount[40] < 2) then
      if HR.Cast(S.Doom) then return "doom 259"; end
    end
    -- demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
    if S.DemonicStrength:IsCastableP() and ((Player:BuffStackP(S.WildImpsBuff) < 6 or Player:BuffP(S.DemonicPowerBuff)) or Cache.EnemiesCount[40] < 2) then
      if HR.Cast(S.DemonicStrength) then return "demonic_strength 273"; end
    end
    -- call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
    if (S.NetherPortal:IsAvailable() and Cache.EnemiesCount[40] <= 2) then
      local ShouldReturn = NetherPortal(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=implosion,if=spell_targets.implosion>1
    if (Cache.EnemiesCount[40] > 1) then
      local ShouldReturn = Implosion(); if ShouldReturn then return ShouldReturn; end
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13 or not I.Item132369:IsEquipped()) then
      if HR.Cast(S.GrimoireFelguard) then return "grimoire_felguard 285"; end
    end
    -- summon_vilefiend,if=equipped.132369|cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and (I.Item132369:IsEquipped() or S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      if HR.Cast(S.SummonVilefiend) then return "summon_vilefiend 291"; end
    end
    -- call_dreadstalkers,if=equipped.132369|(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadstalkers:IsCastableP() and (I.Item132369:IsEquipped() or (S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
      if HR.Cast(S.CallDreadstalkers) then return "call_dreadstalkers 299"; end
    end
    -- summon_demonic_tyrant,if=equipped.132369|(buff.dreadstalkers.remains>cast_time&(buff.wild_imps.stack>=3|prev_gcd.1.hand_of_guldan)&(soul_shard<3|buff.dreadstalkers.remains<gcd*2.7|buff.grimoire_felguard.remains<gcd*2.7))
    if S.SummonDemonicTyrant:IsCastableP() and (I.Item132369:IsEquipped() or (Player:BuffRemainsP(S.DreadstalkersBuff) > S.SummonDemonicTyrant:CastTime() and (Player:BuffStackP(S.WildImpsBuff) >= 3 or Player:PrevGCDP(1, S.HandofGuldan)) and (Player:SoulShardsP() < 3 or Player:BuffRemainsP(S.DreadstalkersBuff) < Player:GCD() * 2.7 or Player:BuffRemainsP(S.GrimoireFelguardBuff) < Player:GCD() * 2.7))) then
      if HR.Cast(S.SummonDemonicTyrant) then return "summon_demonic_tyrant 313"; end
    end
    -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
    if S.PowerSiphon:IsCastableP() and (Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Cache.EnemiesCount[40] < 2) then
      if HR.Cast(S.PowerSiphon) then return "power_siphon 331"; end
    end
    -- doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
    if S.Doom:IsCastableP() and (S.Doom:IsAvailable() and Target:DebuffRefreshableCP(S.DoomDebuff) and Target:TimeToDie() > (Target:DebuffRemainsP(S.DoomDebuff) + 30)) then
      if HR.Cast(S.Doom) then return "doom 339"; end
    end
    -- hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
    if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5 or (Player:SoulShardsP() >= 3 and S.CallDreadstalkers:CooldownRemainsP() > 4 and (not S.SummonVilefiend:IsAvailable() or S.SummonVilefiend:CooldownRemainsP() > 3))) then
      if HR.Cast(S.HandofGuldan) then return "hand_of_guldan 357"; end
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
      if HR.Cast(S.SoulStrike) then return "soul_strike 365"; end
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<10|cooldown.summon_demonic_tyrant.remains>22)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25)
    if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 10 or S.SummonDemonicTyrant:CooldownRemainsP() > 22) or Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) < 5 or Target:TimeToDie() < 25)) then
      if HR.Cast(S.Demonbolt) then return "demonbolt 369"; end
    end
    -- call_action_list,name=build_a_shard
    if (true) then
      local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(266, APL)
