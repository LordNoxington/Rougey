---@diagnostic disable: undefined-global, lowercase-global
---Ghostly STRIKE ADD CLASS CHECK -- done
--ADD Rupture on rogue as higher priority than Kidney when rogue > 70% health -- done
--Offhand swapping for poisons e.g. druid to stack wound, mindnumbing on casters?
--incoming Death coil -> Vanish using Missiles DONEEE
--add faster shiv on melee class DONE
--Add Nigh Invulnerability belt usage DONE
--Add /stop attack and stealth if warrior has crippling
--Add kicks for specific spells
--Add Blinds for objects that aren't your target, and target is <= 30% health DONEE
--Don't overlap kick with kidney shop... Track kick interrupt DONEE
local Tinkr = ...
local wowex = {}
local Routine = Tinkr.Routine
local Util = Tinkr.Util
local Draw = Tinkr.Util.Draw:New()
local Common = Tinkr.Common
local OM = Tinkr.Util.ObjectManager
local E = Tinkr:require('Routine.Modules.Exports')
local lastdebugmsg = ""
local lastdebugtime = 0
local poisondelay = 0
Tinkr:require('scripts.cromulon.libs.Libdraw.Libs.LibStub.LibStub', wowex) --! If you are loading from disk your rotaiton. 
Tinkr:require('scripts.cromulon.libs.Libdraw.LibDraw', wowex) 
Tinkr:require('scripts.cromulon.libs.AceGUI30.AceGUI30', wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-BlizOptionsGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-DropDownGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-Frame' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-InlineGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-ScrollFrame' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-SimpleGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-TabGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-TreeGroup' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIContainer-Window' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Button' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-CheckBox' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-ColorPicker' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-DropDown' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-DropDown-Items' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-EditBox' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Heading' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Icon' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-InteractiveLabel' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Keybinding' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Label' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-MultiLineEditBox' , wowex)
Tinkr:require('scripts.cromulon.libs.AceGUI30.widgets.AceGUIWidget-Slider' , wowex)
Tinkr:require('scripts.wowex.libs.AceAddon30.AceAddon30' , wowex)
Tinkr:require('scripts.wowex.libs.AceConsole30.AceConsole30' , wowex)
Tinkr:require('scripts.wowex.libs.AceDB30.AceDB30' , wowex)
Tinkr:require('scripts.cromulon.system.init' , wowex)
Tinkr:require('scripts.cromulon.system.configs' , wowex)
Tinkr:require('scripts.cromulon.system.storage' , wowex)
Tinkr:require('scripts.cromulon.libs.libCh0tFqRg.libCh0tFqRg' , wowex)
Tinkr:require('scripts.cromulon.libs.libNekSv2Ip.libNekSv2Ip' , wowex)
Tinkr:require('scripts.cromulon.libs.CallbackHandler10.CallbackHandler10' , wowex)
Tinkr:require('scripts.cromulon.libs.HereBeDragons.HereBeDragons-20' , wowex)
Tinkr:require('scripts.cromulon.libs.HereBeDragons.HereBeDragons-pins-20' , wowex)
Tinkr:require('scripts.cromulon.interface.uibuilder' , wowex)
Tinkr:require('scripts.cromulon.interface.buttons' , wowex)
Tinkr:require('scripts.cromulon.interface.panels' , wowex)
Tinkr:require('scripts.cromulon.interface.minimap' , wowex)
--[[ Tinkr.classic then
    ObjectManager.Types = {
        Object = 0,
        Item = 1,
        Container = 2,
        Unit = 3,
        Player = 4,
        ActivePlayer = 5,
        GameObject = 6,
        DynamicObject = 7,
        Corpse = 8,
        AreaTrigger = 9,
        SceneObject = 10,
        ConversationData = 11
    }
    ObjectManager.TypeNames = {
        [0] = "Object",
        [1] = "Item",
        [2] = "Container",
        [3] = "Unit",
        [4] = "Player",
        [5] = "ActivePlayer",
        [6] = "GameObject",
        [7] = "DynamicObject",
        [8] = "Corpse",
        [9] = "AreaTrigger",
        [10] = "SceneObject",
        [11] = "ConversationData"
    }
    ObjectManager.CreatureTypes = {
        Beast = 1,
        Dragonkin = 2,
        Demon = 3,
        Elemental = 4,
        Giant = 5,
        Undead = 6,
        Humanoid = 7,
        Critter = 8,
        Mechanical = 9,
        NOT_SPECIFIED = 10,
        Totem = 11,
        NON_COMBAT_PET = 12,
        GAS_CLOUD = 13
    }]]
local function UnitTargetingUnit(unit1,unit2)
  if UnitIsVisible(UnitTarget(unit1)) and UnitIsVisible(unit2) then
    if UnitGUID(UnitTarget(unit1)) == UnitGUID(unit2) then
      return true
    end
  end
end

Draw:Sync(function(draw)
  local px, py, pz = ObjectPosition("player")
  local tx, ty, tz = ObjectPosition("target")
  local playerHeight = ObjectHeight("player")
  local playerRadius = ObjectBoundingRadius("player")
  local targetRadius = ObjectBoundingRadius("target")
  local targetReach = ObjectCombatReach("target")
  local combatReach = ObjectCombatReach("player")      
  local drawclass = UnitClass("target")
  --draw:SetColor(draw.colors.white)
  --draw:Circle(px, py, pz, playerRadius)
  --draw:Circle(px, py, pz, combatReach)

  local rotation = ObjectRotation("player")
  --local rx, ry, rz = RotateVector(px, py, pz, rotation, playerRadius);

  --draw:Line(px, py, pz, rx, ry, rz)

  if UnitExists("target") and UnitCanAttack("player","target") and not UnitIsDeadOrGhost("target") then
    local targetrotation = ObjectRotation("target")
    local fx, fy, fz = RotateVector(tx, ty, tz, (targetrotation+math.pi), 2)
    local xx, xy, xz = RotateVector(tx, ty, tz, (targetrotation+math.pi/2), 1)
    local vx, vy, vz = RotateVector(tx, ty, tz, (targetrotation-math.pi/2), 1)
    draw:Line(tx, ty, tz, xx, xy, xz)
    draw:Line(tx, ty, tz, vx, vy, vz)
    draw:SetColor(draw.colors.yellow)
    draw:Line(tx, ty, tz, fx, fy, fz)
  end

  if UnitExists("target") and drawclass == "Warrior" and not UnitIsDeadOrGhost("target") then
    draw:Circle(tx, ty, tz, 5)
    draw:SetColor(draw.colors.red)
    draw:Circle(tx, ty, tz, 8)
  end

  for object in OM:Objects(OM.Types.Players) do
    if (ObjectType(object) == 4 or ObjectType(object) == 5) and UnitCanAttack("player",object) then
      if UnitTargetingUnit(object,"player") then
        local px, py, pz = ObjectPosition("player")
        local tx, ty, tz = ObjectPosition(object)
        draw:SetColor(draw.colors.white)
        draw:Line(px,py,pz,tx,ty,tz,4,55)  
      end
    end
  end
end)

  --[[
  for i, object in ipairs(Objects()) do
    if UnitCanAttack("player",object) and UnitTargetingUnit(object,'player') then
      for m in ObjectManager:Missiles() do
        -- inital -> hit
        draw:SetColor(255, 255, 255, 128)
        draw:Line(m.ix, m.iy, m.iz, m.hx, m.hy, m.hz)

        -- current -> hit
        draw:SetColor(3, 252, 11, 256)
        draw:Line(m.cx, m.cy, m.cz, m.hx, m.hy, m.hz)

        -- model -> hit
        if m.mx and m.my and m.mz then
            draw:SetColor(3, 252, 252, 256)
            draw:Line(m.mx, m.my, m.mz, m.hx, m.hy, m.hz)
        end

        draw:SetColor(255, 255, 255, 255)
        local cdt = Common.Distance(m.cx, m.cy, m.cz, m.hx, m.hy, m.hz)
        local spell = GetSpellInfo(m.spellId)
        draw:Text((spell or m.spellId), "NumberFont_Small", m.cx, m.cy, m.cz + 1.35)
      end
    end 
  end
  ]]

--[[
function Draw:WorldToScreen(wx, wy, wz)
function Draw:CameraPosition()
function Draw:Map(value, fromLow, fromHigh, toLow, toHigh)
function Draw:SetColor(r, g, b, a)
function Draw:SetColorRaw(r, g, b, a)
function Draw:SetAlpha(a)
function Draw:Distance(ax, ay, az, bx, by, bz)
function Draw:Distance2D(x1, y1, x2, y2)
function Draw:SetWidth(width)
function Draw:RotateX(cx, cy, cz, px, py, pz, r)
function Draw:RotateY(cx, cy, cz, px, py, pz, r)
function Draw:RotateZ(cx, cy, cz, px, py, pz, r)
function Draw:Line(x1, y1, z1, x2, y2, z2, maxD)
function Draw:LineRaw(x1, y1, z1, x2, y2, z2)
function Draw:Line2D(sx, sy, ex, ey)
function Draw:Circle(x, y, z, radius)
function Draw:Cylinder(x, y, z, radius, height)
function Draw:Array(vectors, x, y, z, rotationX, rotationY, rotationZ)
function Draw:Text(text, font, x, y, z)
function Draw:Texture(config, x, y, z, alphaA)
function Draw:ClearCanvas()
function Draw:Update()
function Draw:Helper()
function Draw:Enable()
function Draw:Disable()
function Draw:Enabled()
function Draw:Sync(callback)
function Draw:HexToRGB(hex)
function Draw:SetColorFromObject(object)
function Draw:New()
]]

local function Debug(text,spellid)
  if (lastdebugmsg ~= message or lastdebugtime < GetTime()) then
    local _, _, icon = GetSpellInfo(spellid)
    lastdebugmsg = message
    lastdebugtime = GetTime() + 2
    RaidNotice_AddMessage(RaidWarningFrame, "|T"..icon..":0|t"..text, ChatTypeInfo["RAID_WARNING"],1)
    return true
  end
  return false
end

local playerGUID = UnitGUID("player")
local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
  self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
  end)

local t = CreateFrame("Frame")
t:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local function LogEvent(self, event, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
    self:LogEvent_Original(event, CombatLogGetCurrentEventInfo())
  elseif event == "COMBAT_TEXT_UPDATE" then
    self:LogEvent_Original(event, (...), GetCurrentCombatTextEventInfo())
  else
    self:LogEvent_Original(event, ...)
  end
end

local function OnEventTraceLoaded()
  EventTrace.LogEvent_Original = EventTrace.LogEvent
  EventTrace.LogEvent = LogEvent
end

if EventTrace then
  OnEventTraceLoaded()
else
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and (...) == "Blizzard_EventTrace" then
      OnEventTraceLoaded()
      self:UnregisterAllEvents()
    end
  end)
end

Routine:RegisterRoutine(function()
  local GetComboPoints = GetComboPoints("player","target")
  --local mainHandLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
  --local _, _, _, _, _, _, itemType5 = GetItemInfo(mainHandLink)
  if gcd() > latency() then return end
  if wowex.keystate() then return end
  if UnitIsDeadOrGhost("player") or debuffduration(Gouge,"target") > 0.3 or debuffduration(Sap,"target") > 0.3 or debuff(Cyclone,"target") or debuffduration(Blind,"target") > 0.3 or debuff(12826,"target") or buff(45438, "target") then return end
  -- or buff(Vanish,"player")
  local function InventorySlots()
    local slotsfree = 0
    for i = 0, 4 do
      freeslots, _ = GetContainerNumFreeSlots(i)
      slotsfree = slotsfree + freeslots
    end
    return slotsfree
  end
  local function GetFinisherMaxDamage(ID)
    local function GetStringSpace(x, y)
      for i = 1, 7 do
        if string.sub(x, y + i, y + i) then
          if string.sub(x, y + i, y + i) == " " then
            return i
          end
        end
      end
    end
    local f = GetSpellDescription(ID)
    local _, a, b, c, d, e = strsplit("\n", f)
    local aa, bb, cc, dd, ee = string.find(a, "%-"), string.find(b, "%-"), string.find(c, "%-"), string.find(d, "%-"), string.find(e, "%-")
    return tonumber(string.sub(a, aa + 1, aa + GetStringSpace(a, aa))), tonumber(string.sub(b, bb + 1, bb + GetStringSpace(b, bb))), tonumber(string.sub(c, cc + 1, cc + GetStringSpace(c, cc))), tonumber(string.sub(d, dd + 1, dd + GetStringSpace(d, dd))), tonumber(string.sub(e, ee + 1, ee + GetStringSpace(e, ee)))
  end
  local function GetAggroRange(unit)
    local range = 0
    local playerlvl = UnitLevel("player")
    local targetlvl = UnitLevel(unit)
    range = 20 - (playerlvl - targetlvl) * 1
    if range <= 5 then
      range = 10
    elseif range >= 45 then
      range = 45
    elseif UnitReaction("player", unit) >= 4 then
      range = 10
    end
    return range +2
  end

  local function IsFacing(Unit, Other)
    local SelfX, SelfY, SelfZ = ObjectPosition(Unit)
    local SelfFacing = ObjectRotation(Unit)
    local OtherX, OtherY, OtherZ = ObjectPosition(Other)
    local Angle = SelfX and SelfY and OtherX and OtherY and SelfFacing and ((SelfX - OtherX) * math.cos(-SelfFacing)) - ((SelfY - OtherY) * math.sin(-SelfFacing)) or 0
    return Angle < 0
  end
  local function IsBehind()
    if not IsFacing("target", "player") then
      return true
    end
  end
  local function isCasting(Unit)
    local name--[[, text, texture, startTime, endTime, isTradeSkill, castID, spellID]] = UnitCastingInfo(Unit);    
    if name then
      return true
    end
  end
  local function isChanneling(Unit)
    local name--[[, text, texture, startTime, endTime, isTradeSkill, castID, spellID]] = UnitChannelInfo(Unit);    
    if name then
      return true
    end
  end
  function IsPoisoned(unit)
    unit = unit or "player"
    for i=1,30 do
      local debuff,_,_,debufftype = UnitDebuff(unit,i)
      if not debuff then break end
      if debufftype == "Disease" or debufftype == "Curse" or debufftype == "Bleed" then
        return debuff
      end
    end
  end
  
  local function Execute()
    --*Eviscerate=Attack Power * (Number of Combo Points used * 0.03) * abitrary multiplier to account for Auto Attacks while pooling
    local e1, e2, e3, e4, e5 = GetFinisherMaxDamage(26865)
    local ap = UnitAttackPower("player")
    local multiplier = wowex.wowexStorage.read("personalmultiplier")
    local evisc1calculated = ap * (1 * 0.03) + e1 * multiplier
    local evisc2calculated = ap * (2 * 0.03) + e2 * multiplier
    local evisc3calculated = ap * (3 * 0.03) + e3 * multiplier
    local evisc4calculated = ap * (4 * 0.03) + e4 * multiplier
    local evisc5calculated = ap * (5 * 0.03) + e5 * multiplier

    if not UnitIsPlayer("target") and castable(Eviscerate) then
      if UnitHealth("target") <= evisc1calculated and GetComboPoints == 1 then
        cast(Eviscerate)
        Debug("Calculated Execute on " .. UnitName("target"), 26865)
      end
      if UnitHealth("target") <= evisc2calculated and GetComboPoints == 2 then
        cast(Eviscerate)
        Debug("Calculated Execute on " .. UnitName("target"), 26865)
      end
      if UnitHealth("target") <= evisc3calculated and GetComboPoints == 3 then
        cast(Eviscerate)
        Debug("Calculated Execute on " .. UnitName("target"), 26865)
      end
      if UnitHealth("target") <= evisc4calculated and GetComboPoints == 4 then
        cast(Eviscerate)
        Debug("Calculated Execute on " .. UnitName("target"), 26865)
      end
      if UnitHealth("target") <= evisc5calculated and GetComboPoints == 5 then
        cast(Eviscerate)
        Debug("Calculated Execute on " .. UnitName("target"), 26865)
      end
    end
  end
  
  local function Defensives()
    if UnitAffectingCombat("player") and not mounted() then
      --local defclass, _, _ = UnitClass("target")
      --if mounted() then
      --  Dismount()
      --end
      --if castable(Sprint) and (debuff(18223,"player") or debuff(25365,"player") or debuff(27088,"player") or debuff(122,"player") or debuff(12494,"player")) and health() <= 95 then
      --  cast(Sprint)
      --end
      if health() <= 30 and not buff(30458, "player") then
        Eval('RunMacroText("/use 6")', 'player')
      end
      --if castable(Evasion) and health() <= 95 and UnitTargetingUnit("target","player") and (defclass == "Warrior" or defclass == "Rogue") then
      --  cast(Evasion,"player")
      --end
      --[[
      for i, object in ipairs(Objects()) do
        if UnitCanAttack("player",object) and UnitTargetingUnit(object,'player') then
          for m in ObjectManager:Missiles() do
          local scaryspell = GetSpellInfo(m.spellId)
            if (scaryspell == "Pyroblast" or scaryspell == "Death Coil") then
              return cast(Vanish)
            end 
          end
        end
      end
      ]]
    end
  end

  function f:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = ...
    local spellId, spellName, spellSchool
    --local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

    if subevent == "SPELL_CAST_SUCCESS" then
      local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
      local myname = UnitName("player")
      if destName == myname and spellName == "Scatter Shot" and castable(Vanish) then
        cast(Vanish)
        Debug("Vanishing Scatter Shot!! ",19503)
      end
      if destName == myname and spellName == "Hammer of Justice" and castable(Vanish) then
        cast(Vanish)
        Debug("Vanishing Hammer of Justice!! ",853)
      end
      if destName == myname and spellName == "Death Coil" then
        if castable(Vanish) then
          cast(Vanish)
          Debug("Vanishing Death Coil!! ",27223)
        elseif castable(CloakOfShadows) then
          cast(CloakOfShadows)
          Debug("Cloaking Death Coil!! ",27223)
        end
      end
      if destName == myname and spellName == "Pyroblast" then
        if castable(Vanish) then
          cast(Vanish)
          Debug("Vanishing Pyroblast!! ",33938)
        elseif castable(CloakOfShadows) then
          cast(CloakOfShadows)
          Debug("Cloaking Pyroblast!! ",33938)
        end
      end
      if spellName == "Feign Death" then
        TargetNearestEnemy()
      end
    end
      if subevent == "SPELL_CAST_START" then
        local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
        if spellName == "Fear" or spellName == "Polymorph" or spellName == "Regrowth" or spellId == 25235 or spellName == "Cyclone" then
          --for i, object in ipairs(Objects()) do
          for object in OM:Objects(OM.Types.Players) do
            if sourceName == ObjectName(object) then
              if (ObjectType(object) == 4 or ObjectType(object) == 5) and UnitCanAttack("player",object) then
                if castable(Shadowstep,object) and cansee("player",object) and not buff(Stealth,"player") and UnitPower("player") >= 25 and (distance("player",object) >= 15 or not UnitTargetingUnit("player",object)) then
                  cast(Shadowstep,object)
                  FaceObject(object)
                  MoveForwardStop()
                  Debug("Shadowstep on " .. ObjectName(object),38768)
                  kickNameplate(Kick, true)
                end
                if buff(36554,"player") then
                  kickNameplate(Kick, true)
                end 
              end
            end
          end
        end
      end
      if subevent == "SPELL_INTERRUPT" then
        local kicktime = GetTime()
        local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
        if spellName == "Kick" and sourceName == UnitName("player") and destName == UnitName("target") then
          kickInterrupt = kicktime + 5
        end
      end
    end
  
  function t:UNIT_SPELLCAST_SUCCEEDED()
    t:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
      trinketUsedBy = nil
      if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if arg3 == 42292 then
          if UnitCanAttack("player",arg1) then
            trinketUsedBy = Object(arg1)
            Debug("Trinket used by " .. ObjectName(trinketUsedBy),42292)
          end
        end
      end
    end) 

      --local blindtarget = Object(targetUnit)
      --if castable(Blind, blindtarget) and not buff(Stealth,"player") and UnitCanAttack("player",blindtarget) then
      --  FaceObject(blindtarget)
      --  cast(Blind, blindtarget)
       -- Debug("Blinding Trinket on " .. UnitName(blindtarget),42292)
      --end
  end
  

  local function Interrupt()
    if UnitAffectingCombat("player") and not buff(Stealth,"player") then
      if buff(36554,"player") then
        kickNameplate(Kick, true)
      end 
      --for i, object in ipairs(Objects()) do
      for object in OM:Objects(OM.Types.Units) do
        if (ObjectType(object) == 3 or ObjectType(object) == 4 or ObjectType(object) == 5) and UnitCanAttack("player",object) and UnitAffectingCombat("player")  then
          if isCasting(object) then
            local _, _, _, _, endTime, _, _, _ = UnitCastingInfo(object);
            local finish = endTime/1000 - GetTime()
            if finish <= 1 and castable(Kick,object) and melee() then
              FaceObject(object)
              cast(Kick,object)
              Debug("Kicked " .. UnitName(object) .. " at " .. finish,38768)
            end
            if finish <= 1 and castable(Gouge,object) and not IsBehind(object) and not castable(Kick,object) then
              FaceObject(object)
              cast(Gouge,object)
              Debug("Gouged " .. UnitName(object) .. " at " .. finish,38764)
            end 
          end 
          if isChanneling(object) then
            local _, _, _, startTime = UnitChannelInfo(object);
            local startTime = startTime/1000 - GetTime()
            if startTime <= 1 and castable(Kick,object) and melee() then
              cast(Kick,object)
              Debug("Kicked " .. UnitName(object) .. " at " .. startTime,38768)
            end
            if startTime <= 1 and castable(Gouge,object) and not IsBehind(object) and not castable(Kick,object) then
              cast(Gouge,object)
              Debug("Gouged " .. UnitName(object) .. " at " .. startTime,38764)
            end 
          end
        end
      end
    end
  end 

  local function Cooldowns()
    if UnitExists("target") and UnitCanAttack("player","target") and UnitAffectingCombat("player") and not buff(Stealth,"player") and not mounted() then
      if buff(36554,"player") then
        kickNameplate(Kick, true)
      end 
      if castable(Preparation) and not castable(Vanish) and not castable(Evasion) then
        cast(Preparation)
        Debug("Prep used on " .. UnitName("player"), 14185)
      end
      --if castable(Shadowstep) and distance("player","target") >= 20 then
      --  cast(Shadowstep, "target")
      --end
      if castable(Sprint) and distance("player","target") >= 30 then
        --not castable(Shadowstep) and
        cast(Sprint)
        Debug("Sprint used on " .. UnitName("player"), 11305)
      end
    end
    --Blind on
    if trinketUsedBy ~= nil then
      if castable(Blind) and health("target") <= 70 and not buff(Stealth,"player") then
        if (ObjectType(trinketUsedBy) == 4 or ObjectType(trinketUsedBy) == 5) and UnitCanAttack("player",trinketUsedBy) and distance("player",trinketUsedBy) <= 15 then
          if UnitTargetingUnit(trinketUsedBy,"target") and not UnitTargetingUnit("player",trinketUsedBy) and not IsPoisoned(trinketUsedBy) then
            cast(Blind,trinketUsedBy)
            trinketUsedBy = nil
          elseif UnitTargetingUnit(trinketUsedBy,"player") and not UnitTargetingUnit("player",trinketUsedBy) and not IsPoisoned(trinketUsedBy) then
            cast(Blind,trinketUsedBy)
            trinketUsedBy = nil
          end
        --elseif (ObjectType(object) == 4 or ObjectType(object) == 5) and UnitCanAttack("player",object) and distance("player",object) >= 15 then
        --  if UnitTargetingUnit(object,"target") and not UnitTargetingUnit("player",object) and not IsPoisoned(object) then
        --    cast(Shadowstep,object)
        --    cast(Blind,object)
        --  elseif UnitTargetingUnit(object,"player") and not UnitTargetingUnit("player",object) and not IsPoisoned(object) then
        --    cast(Shadowstep,object)
        --    cast(Blind,object)
        --  end
        end
      end
    end
  end
--[[
  local function Opener()
    if UnitCanAttack("player","target") and melee() then
      if buff(Stealth,"player") then
        cast(Premeditation, "target")
        if not IsBehind("target") then
          if wowex.wowexStorage.read("openerfrontal") == "Cheap Shot" and castable(CheapShot) then
            cast(CheapShot,"target")
            --EquipItemByName(29124, 16)
          end
        end
        if IsBehind("target") then
          local itemID = GetInventoryItemID("player", 16)
          local localizedClass, englishClass, classIndex = UnitClass("target")
            if (itemID ~= 31331) and (UnitHealth("target") >= 95 or UnitHealth("target") <= 20) and (classIndex == "8" or classIndex == "9" or classIndex == "5" or classIndex == "3") then
              Eval('RunMacroText("/equipslot 16 The Night Blade")', 'player')
              --return cast(Ambush, "target")
            end
            if IsBehind("target") and UnitExists("target") and UnitCanAttack("player","target") and UnitHealth("target") >= 80 or UnitHealth("target") <= 20 and (classIndex == "8" or classIndex == "9" or classIndex == "5" or classIndex == "3") then
              cast(Ambush, "target")
            --  Eval('RunMacroText("/cast Ambush")', 'target')
            end
            if castable(Garrote) and UnitPowerType("target") == 0 then
              --EquipItemByName(29124, 16)
              cast(Garrote, "target")
              --EquipItemByName(29124, 16)
            end 
            if castable(CheapShot) then
            --  EquipItemByName(29124, 16)
              cast(CheapShot,"target")
            --  EquipItemByName(29124, 16)
            end 
        end
      end
    end
  end
  ]]

  local function Opener()
    if UnitCanAttack("player","target") then
      if buff(Stealth,"player") or buff(Vanish,"player")then
        if not IsBehind("target") then
          if wowex.wowexStorage.read("openerfrontal") == "Cheap Shot" and castable(CheapShot) then
            cast(Premeditation, "target")
            cast(CheapShot,"target")
          end
        end
        if IsBehind("target") then
          if wowex.wowexStorage.read("openerbehind") == "Garrote" and castable(Garrote) and UnitPowerType("target") == 0 and not debuff(18469, "target") then
            cast(Premeditation, "target")
            cast(Garrote,"target")
          end
          if wowex.wowexStorage.read("openerbehind") == "Garrote" and castable(CheapShot) and not buff(34471, "target") and not mounted("target") then
            cast(Premeditation, "target")
            cast(CheapShot,"target")
          end
          if wowex.wowexStorage.read("openerbehind") == "Ambush" and castable(Ambush) then
            cast(Ambush,"target")
          end
        end
      end
    end
  end
  local function Dps()
    if UnitAffectingCombat("player") and UnitExists("target") and UnitCanAttack("player","target") and not buff(Stealth,"player") then
      if buff(36554,"player") then
        kickNameplate(Kick, true)
      end 
      local class, _, _ = UnitClass("target")
      local kidneydelay = 0
      if kickInterrupt ~= nil then
        kidneydelay = kickInterrupt - GetTime()
      end
      --if mounted() then
      --  Dismount()
      --end
      --kickNameplate(Kick, true)
      --if itemID ~= 29124 then
      --  EquipItemByName(29124, 16)
      --end 
      --if castable(Gouge, "target") and not castable(Kick) and not IsBehind("target") and (isCasting("target") or isChanneling("target")) then
      --  FaceObject("target")
      --  kickNameplate(Gouge, true)
      --  Debug("Gouge interrupt on " .. UnitName("target"), 38764)
      --end
      if not IsPlayerAttacking("target") then
        --Dismount()
        Eval('StartAttack()', 't')
      end
      if castable(SliceAndDice) and GetComboPoints <= 0 and not buff(SliceAndDice,"player") and distance("player","target") <= 20 and UnitPower("player") >= 40 and not (isCasting("target") or isChanneling("target")) then
        TargetLastTarget()
        --if not UnitIsDeadOrGhost("target") and GetComboPoints >= 1 then
          cast(SliceAndDice)
          Debug("Slice and Dice on target change", 6774)
          TargetLastTarget()
        --end
      end
      if debuff(CheapShot, "target") and not IsBehind("target") and castable(Gouge, "target") and debuffduration(1833, "target") < 0.3 then
        --for i=1,40 do
        --local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("target", i);
        --    if name == "Cheap Shot" and expirationTime ~= nil then
        --      local debuffend = expirationTime - GetTime()
        --    if castable(Gouge, "target") and debuffend <= 0.2 then
              cast(Gouge, "target")
              Debug("Gouge chain on " .. UnitName("target"), 38764)
        --    end 
        --  end 
       -- end
      elseif debuff(CheapShot, "target") and IsBehind("target") and castable(KidneyShot, "target") and debuffduration(1833, "target") < 0.3 then
        --for i=1,40 do
        --local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("target", i);
        --    if name == "Cheap Shot" and expirationTime ~= nil then
        --      local debuffend = expirationTime - GetTime()
        --      if castable(KidneyShot, "target") and debuffend <= 0.2 then
                cast(KidneyShot, "target")
                Debug("Kidney Shot to chain Cheap Shot on " .. UnitName("target"), 8643)
              --end 
            --end 
        --end
        --[[
        elseif debuff(Gouge, "target") then
          for i=1,40 do
          local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("target", i);
              if name == "Gouge" and expirationTime ~= nil then
                local debuffend = expirationTime - GetTime()
              if debuffend <= 0.1 then
                cast(KidneyShot, "target")
                Debug("Kidney chain on " .. UnitName("target"), 8643)
              end 
            end 
          end
          ]]
      end 
      if debuff(1330, "target") and castable(KidneyShot, "target") and debuffduration(1330, "target") < 0.2 then
        --for i=1,40 do
        --local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("target", i);
        --    if name == "Garrote - Silence" and expirationTime ~= nil then
        --      local debuffendG = expirationTime - GetTime()
        --    if debuffendG <= 0.2 and castable(KidneyShot, "target") then
              cast(KidneyShot, "target")
              Debug("Kidney Shot to chain Garrote on " .. UnitName("target"), 38764)
        --    end 
        --  end 
      --  end
      end
      if castable(KidneyShot, "target") and kidneydelay >= 0.1 and kidneydelay <= 0.4 --[[and (class == "Priest" or class == "Druid" or class == "Shaman" or class == "Warlock" or class == "Mage" or class == "Paladin")]] then
        cast(KidneyShot, "target")
        Debug("Kidney Shot to chain Kick on " .. UnitName("target"), 38764)
      end
      if debuff(18469,"target") and castable(KidneyShot, "target") and debuffduration(18469,"target") < 0.2 then
        cast(KidneyShot, "target")
        Debug("Kidney to Chain Silence on " .. UnitName("target"), 8643)
      end
      if castable(Eviscerate, "target") and GetComboPoints >= 3 and UnitHealth("target") <= 15 and UnitIsPlayer("target") then
        cast(Eviscerate, "target")
        Debug("Uncalculated Execute on " .. UnitName("target"), 26865)
      end
      --if castable(KidneyShot, "target") and not castable(Kick,"target") and GetComboPoints >= 1 and not debuff(1833, "target") and not debuff(1330, "target") and not debuff(18469, "target") and not buff(34471, "target") and isCasting("target") and UnitHealth("target") <= 15 then
      --  cast(KidneyShot, "target")
      --  Debug("Kidney to Interrupt on " .. UnitName("target"), 8643)
      --end
      if castable(26679, "target") and distance("player","target") >= 30 and GetComboPoints >= 1 and not castable(Shadowstep, "target") and (isCasting("target") or isChanneling("target")) then
        cast(26679, "target")
        Debug("Deadly Throw to Interrupt on " .. UnitName("target"), 26679)
      end
      --Test until replacement copied from cutegirl
      if castable(KidneyShot, "target") and GetComboPoints >= 4 and not debuff(KidneyShot, "target") and not debuff(1833, "target") and not debuff(1330, "target") and not debuff(18469, "target") and not buff(34471, "target") and kidneydelay <= 0.4 then
        cast(KidneyShot, "target")
        Debug("BIG Kidney on " .. UnitName("target"), 8643)
      end
      if castable(Rupture, "target") and GetComboPoints >= 4 and health("target") >= 60 and class == "Rogue" and not debuff(26867, "target") then
        cast(Rupture, "target")
        Debug("Rupture early on " .. UnitName("target"), 38764)
      end
      if castable(SliceAndDice,"target") and GetComboPoints <= 4 and GetComboPoints >= 1 and not buff(SliceAndDice, "player") and not debuff(CheapShot, "target") and not debuff(1330, "target") and cooldown(KidneyShot) > 3 then
        cast(SliceAndDice,"target")
      end
      if castable(Rupture, "target") and GetComboPoints >= 3 and UnitPowerType("target") ~= 0 and not debuff(CheapShot, "target") and not debuff(KidneyShot, "target") and health("target") >= 40 and cooldown(KidneyShot) > 3 then
         cast(Rupture, "target")
      end
      --if castable(SliceAndDice, 'target') and GetComboPoints >= 2 and buffduration(SliceAndDice, 'player') <= 1 then
      --  return cast(SliceAndDice, 'target')
      --end
      if castable(Eviscerate, "target") and GetComboPoints >= 4 and not castable(KidneyShot, "target") and cooldown(KidneyShot) > 2 then
        cast(Eviscerate, "target")
      end
    end
  end
  --
  --local function Loot()
  --  for i, object in ipairs(Objects()) do
  --    if ObjectLootable(object) and ObjectDistance("player",object) < 5 and ObjectType(object) == 3 then
   --     ObjectInteract(object)
  --    end
  --  end
  --  for i = GetNumLootItems(), 1, -1 do
  --    LootSlot(i)
  --  end
  --end
  local function Project(X, Y, Z, Direction, Distance)
    return X + math.cos(Direction) * Distance, Y + math.sin(Direction) * Distance, Z
  end
  local function Distract()
    --*Throw Distract behind the enemy if its facing us to let us open with a behind opener
    if buff(Stealth,"player") and UnitCanAttack("player","target") and UnitExists("target") and not UnitAffectingCombat("target") and IsFacing("target", "player") and not UnitIsPlayer("target") and distance("player","target") <= 15 then
      local X, Y, Z = ObjectPosition("target")
      local SelfFacing = ObjectRotation("player")
      local ProjX, ProjY, ProjZ = Project(X, Y, Z, SelfFacing, 7)
      if ProjX and IsSpellKnown(1725) then
        cast("Distract",'none'):click(ProjX,ProjY,ProjZ)
        cast(Premeditation, "target")
      end
    end
  end
  local function Filler()
    if melee() and not debuff(Sap,"target") and not debuff(Gouge,"target") and not debuff(Blind,"target") and not buff(Vanish,"player") and not buff(Stealth,"player") and UnitExists("target") and UnitCanAttack("player","target") and not buff(Shadowstep, 'player') then
      local fillerclass, _, _ = UnitClass("target")
      if mounted() then
        Dismount()
      end
      if buff(36554,"player") then
        kickNameplate(Kick, true)
      end 
      --if itemID ~= 29124 then
      --  EquipItemByName(29124, 16)
      --end 
      --Backstab/SS if Hemorrhage is not learned on Daggers
      --if itemType5 == "Daggers" and not IsSpellKnown(26864) then
      --  if IsBehind() and castable(Backstab) then
      --    cast(Backstab,"target")
      --  end
      --  if not IsBehind() and castable(SinisterStrike) then
      --    cast(SinisterStrike,"target")
      --  end
      --end
      --Cast Hemorrhage if its known
      --if IsSpellKnown(26864) then 
        if castable(Shiv, "target") and melee() and not debuff(11201,"target") and not buff(34471, "target") and not buff(31224, "target") and not buff(20594, "target") and not debuff(27187, "target") and not debuff(CheapShot, "target") and not debuff(KidneyShot, "taret") and GetComboPoints < 5 and moving("target") and (debuff(26864, "target") or fillerclass == "Rogue" or fillerclass == "Warrior" or fillerclass == "Shaman") --[[and debuff(26864 hemo, "target")]] then
          --and UnitPower("player") >= 60
          Dismount()
          cast(Shiv, "target")
          --EquipItemByName(29124, 16)

        end     
        if castable(GhostlyStrike, "target") and melee() and not buff(GhostlyStrike,"player") and health() <= 90 and GetComboPoints < 5 and UnitTargetingUnit("target", "player") and UnitPowerType("target") ~= 0 then
          Dismount()
          cast(GhostlyStrike, "target")
          --EquipItemByName(29124, 16)

        end
        if castable(Hemorrhage, "target") and melee() and (UnitPower("player") >= 70 or health("target") <= 40 or debuff(KidneyShot, "target")) then
          -- and GetComboPoints < 5
          cast(Hemorrhage,"target")
          --EquipItemByName(29124, 16)

      --  end
      end
      --SS Spam on everything else
      --if not IsSpellKnown(26864) and itemType5 ~= "Daggers" then
      --  if castable(SinisterStrike) then
      --    cast(SinisterStrike,"target")
      --  end
      --end
    end
  end
  --Poisons thanks rex
  function checkweaponenchants(hand)
    if not hand then return end
    local mainhandbuff, _, _, _, offhandbuff, _, _, _ = GetWeaponEnchantInfo()
    if mainhandbuff == true and hand == 'mainhand' then
      return true
    elseif offhandbuff == true and hand == 'offhand' then
      return true
    end
    return false
  end
  local function Poison()
    local deadlypoisonlist = {22054, 22053, 20844, 8985, 8984, 2893, 2892}
    local instantpoisonlist = {21927, 8928, 8927, 8926, 6950, 6949, 6947}
    local cripplingpoisonlist = {3776, 3775}
    local mindnumbingpoisonlist = {9186, 6951, 5237}
    local woundpoisonlist = {22055, 10922, 10921, 10920, 10918}
    if not UnitAffectingCombat("player") and GetUnitSpeed("player") == 0 then
      if not checkweaponenchants('mainhand') then
        if wowex.wowexStorage.read("mainhandpoison") == "Instant" then
          for i = 1, #instantpoisonlist do
            if GetItemCount(instantpoisonlist[i]) >= 1 and (GetItemCooldown(instantpoisonlist[i])) == 0 and poisondelay < GetTime() then
              local instantpoisonname = GetItemInfo(instantpoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. instantpoisonname .. '")', 'player')
              Eval('RunMacroText("/use 16")', 'player')
              Debug(instantpoisonname,2842)
            end
          end
        elseif wowex.wowexStorage.read("mainhandpoison") == "Wound" then
          for i = 1, #woundpoisonlist do
            if GetItemCount(woundpoisonlist[i]) >= 1 and (GetItemCooldown(woundpoisonlist[i])) == 0 and poisondelay < GetTime() then
              local woundpoisonname = GetItemInfo(woundpoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. woundpoisonname .. '")', 'player')
              Eval('RunMacroText("/use 16")', 'player')
              Debug(woundpoisonname,2842)
            end
          end
        elseif wowex.wowexStorage.read("mainhandpoison") == "Crippling" then
          for i = 1, #cripplingpoisonlist do
            if GetItemCount(cripplingpoisonlist[i]) >= 1 and (GetItemCooldown(cripplingpoisonlist[i])) == 0 and poisondelay < GetTime() then
              local cripplingname = GetItemInfo(cripplingpoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. cripplingname .. '")', 'player')
              Eval('RunMacroText("/use 16")', 'player')
              Debug(cripplingname,2842)
            end
          end
        end
      end
      if not checkweaponenchants('offhand') then
        if wowex.wowexStorage.read("offhandpoison") == "Deadly" then
          for i = 1, #deadlypoisonlist do
            if GetItemCount(deadlypoisonlist[i]) >= 1 and (GetItemCooldown(deadlypoisonlist[i])) == 0 and poisondelay < GetTime() then
              local instantpoisonname = GetItemInfo(deadlypoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. instantpoisonname .. '")', 'player')
              Eval('RunMacroText("/use 17")', 'player')
              Debug(instantpoisonname,2842)
            end
          end
        elseif wowex.wowexStorage.read("offhandpoison") == "MindNumbing" then
          for i = 1, #mindnumbingpoisonlist do
            if GetItemCount(mindnumbingpoisonlist[i]) >= 1 and (GetItemCooldown(mindnumbingpoisonlist[i])) == 0 and poisondelay < GetTime() then
              local mindnumbingname = GetItemInfo(mindnumbingpoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. mindnumbingname .. '")', 'player')
              Eval('RunMacroText("/use 17")', 'player')
              Debug(mindnumbingname,2842)     
            end
          end
        elseif wowex.wowexStorage.read("offhandpoison") == "Crippling" then
          for i = 1, #cripplingpoisonlist do
            if GetItemCount(cripplingpoisonlist[i]) >= 1 and (GetItemCooldown(cripplingpoisonlist[i])) == 0 and poisondelay < GetTime() then
              local cripplingname = GetItemInfo(cripplingpoisonlist[i])
              poisondelay = GetTime() + 4
              Eval('RunMacroText("/use ' .. cripplingname .. '")', 'player')
              Eval('RunMacroText("/use 17")', 'player')
              Debug(cripplingname,2842)
            end
          end
        end
      end
    end
  end
  local function pvp()
    local inInstance, instanceType = IsInInstance()
    if (instanceType == "arena" or instanceType == "pvp") and castable(Stealth) and not mounted() and not IsPoisoned("player") then
      cast(Stealth)
    end
    --for i, object in ipairs(Objects()) do
    for object in OM:Objects(OM.Types.Players) do
      if (ObjectType(object) == 4 or ObjectType(object) == 5) and UnitCanAttack("player",object) then
        if buff(Stealth,object) then
          if buff(Stealth,"player") and distance("player",object) <= 20 then
            TargetUnit(object)
            FaceObject(object)
            cast(Sap,object)
            Debug("Sap".." "..UnitName(object),11297)
          elseif castable(Gouge,object) then
            TargetUnit(object)
            FaceObject(object)
            cast(Gouge,object)
            Debug("Gouge".." "..UnitName(object),11286)   
          end
        end 
      end
    end
    --[[
    if UnitAffectingCombat("player") then

      for i, object in ipairs(Objects()) do
        if UnitCreatureType(object) == 11 then
          local totemname = ObjectName(object)
          if totemname == "Stoneskin Totem" or totemname == "Windfury Totem" or totemname == "Magma Totem" or totemname == "Poison Cleansing Totem" or totemname == "Mana Tide Totem" then
            if UnitCanAttack("player",object) and not buff(Stealth,"player") then
              TargetUnit(object)
              Eval('StartAttack()', 't')
            end
          end
        end
      end
    end
    ]]
  end

  local function Hide()
    if wowex.wowexStorage.read("useStealth") and not (buff(Stealth,"player") or buff(Vanish,"player")) and not UnitAffectingCombat("player") and UnitCanAttack("player","target") and not melee() and not IsPoisoned("player") then
      if wowex.wowexStorage.read("stealthmode") == "DynTarget" then
        if UnitExists("target") and distance("player","target") <= 35 and not UnitAffectingCombat("player") then
          Dismount()
          cast(Stealth)
          cast(Premeditation,"target")
        end
      end
      --if wowex.wowexStorage.read("stealthmode") == "DynOM" then
      --  for i, object in ipairs(Objects()) do
      --    if ObjectType(object) == 3 and UnitCanAttack("player",object) and UnitCreatureType(object) ~= "Critter" and distance("player",object) <= GetAggroRange(object) and not UnitIsDeadOrGhost(object) and not UnitAffectingCombat(object) then
      --    Dismount()
      --    cast(Stealth)
      --    cast(Premeditation,"target")
      --    cast(Sprint)
      --    end
      --  end
      --end
      if wowex.wowexStorage.read('stealtheat') then
        if IsEatingOrDrinking() and castable(Stealth,"player") then
          cast(Stealth)
        end
      end
    end
  end
  if not UnitIsDeadOrGhost("target") then
    if Defensives() then return true end
    if Interrupt() then return true end
    if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
    if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    if Cooldowns() then return true end
    if Execute() then return true end
    if pvp() then return true end
    if Opener() then return true end
    if Dps() then return true end
    if Filler() then return true end 
    if Hide() then return true end
    --if Distract() then return true end
    if Poison() then return true end
  end
  --if wowex.wowexStorage.read('autoloot') and not UnitAffectingCombat("player") and (not buff(Stealth,"player") or not buff(Vanish,"player")) and InventorySlots() > 2 then
  --  Loot()
  --  return true 
  --end
end, Routine.Classes.Rogue, Routine.Specs.Rogue)
Routine:LoadRoutine(Routine.Specs.Rogue)
print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t [Yosh] whispers: Hello, " .. UnitName("player") .. ". We have detected an \"UNAUTHORIZED THIRD PARTY PROGRAM\" running on your computer. Have fun with it.:)")

local example = {
  key = "tinkr_configs",
  title = "Made by Yosh",
  width = 840,
  height = 360,
  resize = true,
  show = false,
  table = {
    {key = "heading", type = "heading", text = "YoshRogue"},
    { key = "StealthMode", width = 130, label = "StealthMode", type = "dropdown", options = { "DynOM", "DynTarget", "Always", } },
    {
      key = "Stealtheat",
      type = "checkbox",
      text = "Stealth",
      desc = "Stealth on Food"
    },
    {
      key = "AutoLoot",
      type = "checkbox",
      text = "Auto Loot",
      desc = "Auto Loot"
    },
    {key = "heading", type = "heading", text = "Defensives"}, {
      key = "Evasion",
      type = "slider",
      text = "Evasion",
      label = "% Evasion",
      min = 0,
      max = 100,
      step = 5
    },
    {
      key = "Vanish",
      type = "slider",
      text = "Vanish",
      label = "% Vanish",
      min = 0,
      max = 100,
      step = 5
    },
    {
      key = "Gouge",
      type = "slider",
      text = "Gouge",
      label = "% Gouge",
      min = 0,
      max = 100,
      step = 5
    },
  }
}
--wowex.build_rotation_gui(example)
local button_example = {
  {
    key = "useStealth",
    buttonname = "useStealth",
    texture = "ability_stealth",
    tooltip = "Stealth",
    text = "Stealth",
    setx = "TOP",
    parent = "settings",
    sety = "TOPRIGHT"
  },
  {
    key = "useExpose",
    buttonname = "useExpose",
    texture = "ability_warrior_riposte",
    tooltip = "Expose Armor",
    text = "Expose Armor",
    setx = "TOP",
    parent = "useStealth",
    sety = "TOPRIGHT"
  }
  
}
wowex.button_factory(button_example)
Draw:Enable()

local mytable = {
  key = "cromulon_config",
  name = "Yosh Rogue Tbc",
  height = 650,
  width = 400,
  panels = 
  {
    { 
      name = "Offensive",
      items = 
      {
        { key = "heading", type = "text", color = 'FFF468', text = "Multiplier = Eviscerate=Attack Power * (Number of Combo Points used * 0.03) * abitrary multiplier to account for Auto Attacks while pooling Recommendation : <= 60 == 1.6 >= 60 == 1.4" },
        
        { key = "heading", type = "heading", color = 'FFF468', text = "Execute" },
        { key = "personalmultiplier", type = "slider", text = "Execute Multiplier", label = "Execute Multiplier", min = 1, max = 3, step = 0.1 },
        --{ key = "heading", type = "heading", color = 'FFF468', text = "Opener" },
        --{ key = "openerfrontal", width = 175, label = "Frontal", text = wowex.wowexStorage.read("openerfrontal"), type = "dropdown",
        --options = {"Cheap Shot", "None",} },
        --{ key = "openerbehind", width = 175, label = "Behind", text = wowex.wowexStorage.read("openerbehind"), type = "dropdown",
        --options = {"Ambush", "Cheap Shot", "Garrote","None"} },
        --{ key = "pershealwavepercent", type = "slider", text = "Healing Wave", label = "Healing Wave at", min = 1, max = 100, step = 1 },
        
      },
    },
    { 
      name = "Defensives",
      items = 
      {
        { key = "heading", type = "heading", color = 'FFF468', text = "Evasion" },
        { key = "evasionhp", type = "slider", text = "", label = "Evasion at", min = 1, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FFF468', text = "Vanish" },
        { key = "vanishhp", type = "slider", text = "", label = "Vanish at", min = 0, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FFF468', text = "Gouge" },
        { key = "gougehp", type = "slider", text = "", label = "Gouge at", min = 0, max = 100, step = 1 },
        
      }
    },
    { 
      name = "General",
      items = 
      {
        { key = "heading", type = "heading", color = 'FFF468', text = "Poison" },
        { key = "mainhandpoison", width = 175, label = "Mainhand", text = wowex.wowexStorage.read("mainhandpoison"), type = "dropdown",
        options = {"Instant", "Wound","Crippling", "None"} },
        { key = "offhandpoison", width = 175, label = "Offhand", text = wowex.wowexStorage.read("offhandpoison"), type = "dropdown",
        options = {"Deadly", "MindNumbing","Crippling","None"} },
        { key = "heading", type = "heading", color = 'FFF468', text = "Stealth" },
        {type = "text", text = "DynOM = Scans the area around you for NPC aggro ranges and puts you into stealth when you get close to them.", color = 'FFF468'},
        {type = "text", text = "DynTarget = Stealthes you when you're near your TARGET's aggro range.", color = 'FFF468'},       
        { key = "stealthmode", width = 175, label = "Stealth Mode", text = wowex.wowexStorage.read("stealthmode"), type = "dropdown",
        options = {"DynOM", "DynTarget",} },
        { key = "stealtheat",  type = "checkbox", text = "Stealth while eating", desc = "" },
        
        { key = "heading", type = "heading", color = 'FFF468', text = "Other" },
        { key = "autoloot",  type = "checkbox", text = "Auto Loot", desc = "" },
        
      }
    },
    { 
      name = "Draw",
      items = 
      { 
        { key = "bladeflurrydraw",  type = "checkbox", text = "BladeFlurry Range", desc = "" },
        { key = "targetingusdraw",  type = "checkbox", text = "Players targeting us", desc = "" },
        {type = "text", text = "Red: >= 30y yellow: <= 30y green: <= 8y", color = 'FFF468'},
        
      }
    },
  },
  
  tabgroup = 
  {
    {text = "Offensive", value = "one"},
    {text = "Defensives", value = "two"},
    {text = "General", value = "three"},
    {text = "Draw", value = "four"}
    
  }
}
wowex.createpanels(mytable)