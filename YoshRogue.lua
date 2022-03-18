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
local roguedistance = 100
local avoidedrogue = false

_G.RogueSpellQueue = {}
Tinkr:require('scripts.cromulon.libs.Libdraw.Libs.LibStub.LibStub', wowex) --! If you are loading from disk your rotaiton. 
Tinkr:require('scripts.cromulon.libs.Libdraw.LibDraw', wowex) 
Tinkr:require('scripts.cromulon.libs.AceGUI30.AceGUI30', wowex)
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

function distanceto(object)
  local X1, Y1, Z1 = ObjectPosition('player')
  local X2, Y2, Z2 = ObjectPosition(object)
  if X1 and Y1 and X2 and Y2 and Z1 and Z2 then
    return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
  end
end

function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function UnitTargetingUnit(unit1,unit2)
  if UnitIsVisible(UnitTarget(unit1)) and UnitIsVisible(unit2) then
    if UnitGUID(UnitTarget(unit1)) == UnitGUID(unit2) then
      return true
    end
  end
end

Draw:Sync(function(draw)
  px, py, pz = ObjectPosition("player")
  tx, ty, tz = ObjectPosition("target")
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
    local fx, fy, fz = RotateVector(tx, ty, tz, (targetrotation+math.pi), 3)
    local xx, xy, xz = RotateVector(tx, ty, tz, (targetrotation+math.pi/2), 1.5)
    local vx, vy, vz = RotateVector(tx, ty, tz, (targetrotation-math.pi/2), 1.5)
    draw:SetColor(draw.colors.blue)
    draw:Line(tx, ty, tz, xx, xy, xz)
    draw:Line(tx, ty, tz, vx, vy, vz)
    draw:SetColor(draw.colors.yellow)
    draw:Line(tx, ty, tz, fx, fy, fz)
  end

  if UnitExists("target") and drawclass == "Warrior" and UnitCanAttack("player","target") and not UnitIsDeadOrGhost("target") then
    draw:Circle(tx, ty, tz, 5)
    draw:SetColor(draw.colors.red)
    draw:Circle(tx, ty, tz, 8)
  end

  for object in OM:Objects(OM.Types.Player) do
    if UnitCanAttack("player",object) then
      if UnitTargetingUnit(object,"player") then
        ObjectTargetingMe = Object(object)
        local ix, iy, iz = ObjectPosition(object)
        if UnitClass(object) == "Rogue" then
          roguedistance = distanceto(object)
        end
        if distanceto(object) <= 8 then
          draw:SetColor(0,255,0)
        end
        if distanceto(object) >= 8 and distanceto(object) <= 30 then
          draw:SetColor(199,206,0)            
        end
        if distanceto(object) >= 30 then
          draw:SetColor(255,0,0)
        end 
        draw:Line(px,py,pz,ix,iy,iz,4,55)  
      end
    end
  --end

  --for object in OM:Objects(OM.Types.Player) do
    if UnitCanAttack("player",object) then
    local tx, ty, tz = ObjectPosition(object)
    local dist = distanceto(object)
    local health = UnitHealth(object)
    local class = UnitClass(object)
    if distanceto(object) <= 8 then
      draw:SetColor(0,255,0)
    end
    if distanceto(object) >= 8 and distanceto(object) <= 30 then
      draw:SetColor(199,206,0)            
    end
    if distanceto(object) >= 30 then
      draw:SetColor(255,0,0)
    end  

    Draw:Text(round(dist).."y".." ","GameFontNormalSmall", tx, ty+2, tz+3)
    if UnitHealth(object) >= 70 then
      draw:SetColor(0,255,0)
    end
    if UnitHealth(object) >= 30 and UnitHealth(object) <= 70 then
      draw:SetColor(199,206,0)
    end
    if UnitHealth(object) <= 30 then
      draw:SetColor(255,0,0)
    end

    Draw:Text(health.."%","GameFontNormalSmall", tx, ty+2, tz+2)
      if UnitClass(object) == "Warrior" then
        Draw:SetColor(198,155,109)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Warlock" then
        Draw:SetColor(135,136,238)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Shaman" then
        Draw:SetColor(0,112,221 )
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Priest" then
        Draw:SetColor(255,255,255)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Mage" then
        Draw:SetColor(63,199,235)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Hunter" then
        Draw:SetColor(170,211,114)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Paladin" then
        Draw:SetColor(244,140,186 )
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Rogue" then
        Draw:SetColor(255,244,104)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Druid" then
        Draw:SetColor(255,124,10)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
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
f:RegisterEvent("COMBAT_LOG_EVENT")
f:SetScript("OnEvent", function(self, event)
  self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
  end)

local t = CreateFrame("Frame")
t:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local p = CreateFrame("Frame")
p:RegisterEvent("PLAYER_TARGET_CHANGED")

--[[
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
end]]

Routine:RegisterRoutine(function()
  local myComboPoints = GetComboPoints("player","target")
  local inInstance, instanceType = IsInInstance()
  local targetclass = UnitClass("target")
  local hasMainHandEnchant, _, _, mainHandEnchantID, hasOffHandEnchant, _, _, offHandEnchantID = GetWeaponEnchantInfo()
  local oldTarget
  local currentTarget

  local function isProtected(unit)
    if buff(1020,unit) or debuffduration(Gouge,unit) > 0.3 or debuffduration(Sap,unit) > 1 or debuffduration(Blind,unit) > 1 or debuff(12826,unit) or buff(45438,unit) or buff(642,unit) or buff(1022,unit) or debuff(33786,unit) then 
      return true end
    end

  local function isNova(unit)
    if debuff(122,unit) or debuff(33395,unit) or debuff(12494,unit) then
      return true end
    end

  local function IsPoisoned(unit)
    unit = unit or "player"
    for i=1,30 do
      local debuff,_,_,debufftype = UnitDebuff(unit,i)
      if not debuff then break end
        if debufftype == "Disease" or debufftype == "Curse" or debufftype == "Bleed" or debufftype == "Magic" or debufftype == "Poison" then
          return true
      end
    end
  end

  local function UnitTargetingUnit(unit1,unit2)
    if UnitIsVisible(UnitTarget(unit1)) and UnitIsVisible(unit2) then
      if UnitGUID(UnitTarget(unit1)) == UnitGUID(unit2) then
        return true
      end
    end
  end

    local function isCasting(Unit)
    local name = UnitCastingInfo(Unit);    
    if name then
      return true
    end
  end

  local function isChanneling(Unit)
    local name  = UnitChannelInfo(Unit);    
    if name then
      return true
    end
  end

  local function SpellCasting(Unit)
    local name = UnitCastingInfo(Unit);
    local nocast = "Not Casting";
    if name then
      return name
    else
     return nocast
    end
  end

  local function isElite(unit)
    local classification = UnitClassification(unit)
    if classification == "elite" or classification == "rareelite" or classification == "worldboss" then
      return true
    end
  end

  local function WoundStacks(unit)
    for i=1,20 do
    wounddebuffname, _, woundstack = UnitDebuff(unit, i)
      if wounddebuffname == "Wound Poison" then
        return woundstack
      end
    end
    return 0
  end

  local function SpellCooldown(spellid)
    start, duration, enabled = GetSpellCooldown(spellid);
    thecooldown = start + duration - GetTime()
    return thecooldown
  end

  local function IsFacing(Unit, Other)
    local SelfX, SelfY, SelfZ = ObjectPosition(Unit)
    local SelfFacing = ObjectRotation(Unit)
    local OtherX, OtherY, OtherZ = ObjectPosition(Other)
    local Angle = SelfX and SelfY and OtherX and OtherY and SelfFacing and ((SelfX - OtherX) * math.cos(-SelfFacing)) - ((SelfY - OtherY) * math.sin(-SelfFacing)) or 0
    return Angle < 0
  end

  local function IsBehind(Unit, Other)
    if not IsFacing(Unit, Other) then
      return true
    else return false
    end
  end

  _G.QueueRogueCast = function(_spell, _target)
    queueobject = Object("target")
    table.insert(_G.RogueSpellQueue, {spell=_spell, target=_target})
  end

--[[
  local function Queue()
    if UnitTargetingUnit("player",queueobject) then
      if #_G.RogueSpellQueue > 0 and cooldown(Hemorrhage) == 0 then
        current_spell = _G.RogueSpellQueue[1]
        if buff(Stealth,"player") then
          if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and not isProtected(current_spell.target) then
            print("cast when in range")
            cast(current_spell.spell, current_spell.target)
            current_spell = nil
          end
        else
          local counter = #_G.RogueSpellQueue
          for i=0, counter do 
            if _G.RogueSpellQueue[1] == _G.RogueSpellQueue[i] then
              table.remove(_G.RogueSpellQueue, i)
            end
          end
          if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and distancecheck(current_spell.target, current_spell.spell) and not isProtected(current_spell.target) then
            print("doing manual override spells")
            return cast(current_spell.spell, current_spell.target)
          else
            print("manual cast was on invalid target. skipped")
          end
        end
      end
    else
      table.remove(_G.RogueSpellQueue, 1)
    end
  end
]]

  local function Queue()
    if UnitTargetingUnit("player",queueobject) then
      if buff(Stealth,"player") and distance("player","target") <= 5 then
        if #_G.RogueSpellQueue > 0 and cooldown(Hemorrhage) == 0 then
          local current_spell = _G.RogueSpellQueue[1]
            counter = #_G.RogueSpellQueue
              for i=0, counter do 
                if _G.RogueSpellQueue[1] == _G.RogueSpellQueue[i] then
                  table.remove(_G.RogueSpellQueue, i)
                end
              end
            if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and distancecheck(current_spell.target, current_spell.spell) and not isProtected(current_spell.target) then
              print("doing manual override spells")
              return cast(current_spell.spell, current_spell.target)
            else
              print("manual cast was on invalid target. skipped")
            end
          end
      elseif buff(Stealth,"player") and distance("player","target") > 5 and distance("player","target") <= 10 then
        if #_G.RogueSpellQueue > 0 and cooldown(Hemorrhage) == 0 then
          local current_spell = _G.RogueSpellQueue[1]
          if current_spell.spell == "Sap" then
            counter = #_G.RogueSpellQueue
              for i=0, counter do 
                if _G.RogueSpellQueue[1] == _G.RogueSpellQueue[i] then
                  table.remove(_G.RogueSpellQueue, i)
                end
              end
            if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and not isProtected(current_spell.target) and IsFacing("player",current_spell.target) then
              print("doing manual override spells")
              return cast(current_spell.spell, current_spell.target)
            else
              print("manual cast was on invalid target. skipped")
            end
          end
        end
      elseif not buff(Stealth,"player") then
        if #_G.RogueSpellQueue > 0 and cooldown(Hemorrhage) == 0 then
          local current_spell = _G.RogueSpellQueue[1]
          counter = #_G.RogueSpellQueue
            for i=0, counter do 
              if _G.RogueSpellQueue[1] == _G.RogueSpellQueue[i] then
                table.remove(_G.RogueSpellQueue, i)
              end
            end
          if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and distancecheck(current_spell.target, current_spell.spell) and not isProtected(current_spell.target) then
            print("doing manual override spells")
            return cast(current_spell.spell, current_spell.target)
          else
            print("manual cast was on invalid target. skipped")
          end
        end
      end  
    else
      table.remove(_G.RogueSpellQueue, 1)
    end
  end

  --if cooldown(Hemorrhage) > latency() then return end

  if UnitIsDeadOrGhost("player") or isProtected("target") or debuff(676,"player") or (debuff(KidneyShot,"target") and isNova("target") and UnitPower("player") < 95) then
    if IsPlayerAttacking("target") and not debuff(676,"player") then
      Eval('RunMacroText("/stopattack")', 'player')
    end
    if debuff(676,"player") then 
      Eval('RunMacroText("/startattack")', 'player')
    end
    if castable(Stealth,"player") and not buff(Stealth,"player") and not buff(Vanish,"player") and not IsPoisoned("player") and not debuff(12867,"player") then
      return cast(Stealth,"player")
    end
    if not IsPlayerAttacking("target") and not debuff(676,"player") then
      return Queue()
    end
  return end

  if wowex.wowexStorage.read("alwaysface") and distance("player","target") <= 8 then
    if instanceType == "pvp" and UnitExists("target") and distance("player","target") <= 30 and cansee("player","target") then
      FaceObject("target")
    end
  end

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
  
  local function Execute()
    --*Eviscerate=Attack Power * (Number of Combo Points used * 0.03) * abitrary multiplier to account for Auto Attacks while pooling
    if UnitAffectingCombat("player") and (instanceType ~= "pvp" or instanceType ~= "arena") then
    local e1, e2, e3, e4, e5 = GetFinisherMaxDamage(26865)
    local ap = UnitAttackPower("player")
    local multiplier = wowex.wowexStorage.read("personalmultiplier")
    local evisc1calculated = ap * (1 * 0.03) + e1 * multiplier
    local evisc2calculated = ap * (2 * 0.03) + e2 * multiplier
    local evisc3calculated = ap * (3 * 0.03) + e3 * multiplier
    local evisc4calculated = ap * (4 * 0.03) + e4 * multiplier
    local evisc5calculated = ap * (5 * 0.03) + e5 * multiplier
      if not UnitIsPlayer("target") and castable(Eviscerate,"target") then
        if UnitHealth("target") <= evisc1calculated and myComboPoints == 1 then
          Debug("Calculated Execute on " .. UnitName("target"), 26865)
          return cast(Eviscerate)
        end
        if UnitHealth("target") <= evisc2calculated and myComboPoints == 2 then
          Debug("Calculated Execute on " .. UnitName("target"), 26865)
          return cast(Eviscerate)
        end
        if UnitHealth("target") <= evisc3calculated and myComboPoints == 3 then
          Debug("Calculated Execute on " .. UnitName("target"), 26865)
          return cast(Eviscerate)
        end
        if UnitHealth("target") <= evisc4calculated and myComboPoints == 4 then
          Debug("Calculated Execute on " .. UnitName("target"), 26865)
          return cast(Eviscerate)
        end
        if UnitHealth("target") <= evisc5calculated and myComboPoints == 5 then
          Debug("Calculated Execute on " .. UnitName("target"), 26865)
          return cast(Eviscerate)
        end
      end
    end
  end
  
  local function Defensives()
    if UnitAffectingCombat("player") and not mounted() and not buff(Stealth,"player") and not buff(Vanish,"player") then

--[[
      if PyschicScreamCD == nil or GetTime() >= PsychicScreamCD then
        if instanceType == "arena" or instanceType == "pvp" then
          if partyMembersAround("player", 15) >= 1 and castable(CloakOfShadows) then
            for object in OM:Objects(OM.Types.Player) do
              if UnitClass(object) == "Priest" then
                if UnitIsPlayer(object) and distance("player",object) <= 15 and enemiesAround(object, 15) >= 2 and not isCasting(object) and moving(object) then
                  Debug("Cloaking Priest Fear!",27223)
                  return cast(CloakOfShadows,"player")
                end
              end
            end
          end
        end
      end
]]

      if instanceType ~= "arena" then
        if health() <= 15 and not buff(30458, "player") then
          Eval('RunMacroText("/use 6")', 'player')
        end
      end
      
      if UnitIsPlayer("target") and health("target") <= 90 and distance("player","target") <= 10 then
        Eval('RunMacroText("/use Figurine - Nightseye Panther")', 'player')
      end
      if instanceType ~= "arena" and wowex.wowexStorage.read("thistletea") then
        if UnitIsPlayer("target") and UnitPower("player") <= 30 and debuff(KidneyShot,"target") then
          Eval('RunMacroText("/use Thistle Tea")', 'player')
        end
      end

      --[[
      if (killtime == nil or GetTime() > killtime + 1) and UnitPower("player") <= 40 then
        for object in OM:Objects(OM.CreatureTypes) do
          local totemname = ObjectName(object)
          if totemname == "Scorching Totem" or totemname == "Stoneskin Totem" or totemname == "Windfury Totem" or totemname == "Poison Cleansing Totem" or totemname == "Mana Tide Totem" or totemname == "Grounding Totem" or totemname == "Earthbind Totem" then
            if distance("player",object) <= 5 and health("target") >= 20 and not (buff(Stealth,"player") or buff(Vanish,"player")) then
              if UnitCanAttack("player",object) then
                oldertarget = Object("target")
                totemobject = Object(object)
                totemGUID = UnitGUID(totemobject)
                TargetUnit(totemobject)
                FaceObject(totemobject)
                Eval('RunMacroText("/startattack")', 'player')
                killtime = nil
              end
            end
          end
        end
      end
      ]]

      if castable(Evasion) and distance(ObjectTargetingMe,"player") <= 10 and (UnitClass(ObjectTargetingMe) == "Warrior" or UnitClass(ObjectTargetingMe) == "Rogue" or UnitClass(ObjectTargetingMe) == "Paladin" or UnitClass(ObjectTargetingMe) == "Hunter" or UnitClass(ObjectTargetingMe) == "Druid") then
        return cast(Evasion)
      end
      --if castable(Evasion,"player") and health("target") <= 40 and (targetclass == "Warrior" or targetclass == "Rogue" or targetclass == "Druid") then
      --  return cast(Evasion,"player")
      --end
    end
  end

  local function Dismounter()
    if UnitIsPlayer(ObjectTargetingMe) and distance("player",ObjectTargetingMe) <= 45 and not (buff(301089,"target") or buff(301091,"target") or buff(34976,"target")) then
      Dismount()
    end
  end

  function f:COMBAT_LOG_EVENT_UNFILTERED(...)
  --[[if UnitAffectingCombat("player") and not mounted() and not buff(Stealth,"player") and not buff(Vanish,"player") then]]

    timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

--[[
    if totemobject ~= nil then
      if UnitTargetingUnit("player",totemobject) then
        if subevent == "SWING_DAMAGE" then
          local amount = select(12, ...)
          if sourceGUID == UnitGUID("player") then
            if UnitTargetingUnit("player",totemobject) then
              if amount >= UnitHealth(totemobject) then
                --TargetLastTarget()
                TargetUnit(oldertarget)
                killtime = GetTime()
                Debug("Retargeting Shaman",27223)
              end
            end
          end
        end 
      end
    end
]]

    if subevent == "SPELL_AURA_REMOVED" or subevent == "SPELL_AURA_BROKEN" or subevent == "SPELL_AURA_BROKEN_SPELL" then
      local spellId, spellName = select(12,...)
      if spellId == 8643 and UnitIsPlayer("target") then
        KidneyTarget = destName
        KidneyDR = GetTime() + 20
        print("Kidney Gone - " .. KidneyDR)
      end
      if spellId == 1787 then
        length = #_G.RogueSpellQueue
        for i=0, length do 
          table.remove(_G.RogueSpellQueue, i)
          current_spell = nil
        end
      end
    end

    if subevent == "SPELL_MISSED" then
      local spellId, spellName = select(12,...)
      if spellId == 1833 and UnitIsPlayer("target") then
        CheapShotDR = nil
        CheapShotTarget = nil
      end
      if spellId == 8643 and UnitIsPlayer("target") then
        KidneyTarget = nil
        KidneyDR = nil
      end
    end

    --if --[[UnitClass(ObjectTargetingMe) == "Rogue" and]] distance(ObjectTargetingMe,"player") <= 25 and (distance("player","target") > 5 or not UnitExists("target")) then
    --  if subevent == "SPELL_CAST_SUCCESS" then
    --  local spellId, spellName = select(12, ...)
    --    if spellName == "Vanish" and (sourceName ~= UnitName("player")) then
    --      if --[[(instanceType == "arena" or instanceType == "pvp") and]] castable(Vanish) and not castable(Stealth) and not buff(Stealth,"player") then
    --        Debug("Vanishing to avoid Rogue opener",1856)            
    --        return cast(Vanish)
    --      end
    --    end
    --  end
    --end

    if subevent == "SPELL_CAST_SUCCESS" then
      local spellId, spellName = select(12, ...)
      for object in OM:Objects(OM.Types.Player) do
        if sourceName == ObjectName(object) and UnitTargetingUnit(object,"player") then
          if spellName == "Death Coil" then
            if castable(Vanish,"player") then
              Debug("Vanishing Death Coil!! ",27223)          
              return cast(Vanish)
            elseif not castable(Vanish,"player") and castable(CloakOfShadows,"player") then
              Debug("Cloaking Death Coil!! ",27223)
              return cast(CloakOfShadows)
            end
          end
          if spellName == "Pyroblast" then
            if castable(Vanish,"player") then
              Debug("Vanishing Pyroblast!! ",33938)          
              return cast(Vanish)
            elseif not castable(Vanish,"player") and castable(CloakOfShadows,"player") then
              Debug("Cloaking Pyroblast!! ",33938)
              return cast(CloakOfShadows)
            end
          end
          if spellName == "Wyvern Sting" then
            if castable(Vanish,"player") then
              Debug("Vanishing Wyvern!! ",19386)
              return cast(Vanish)
            end
          end
          if spellName == "Psychic Scream" then
            PsychicScreamCD = GetTime() + 30
            print("Psychic Scream used" .. PsychicScreamCD)
          end
        end
      end

--[[
      if spellName == "Blink" then
        for object in OM:Objects(OM.Types.Player) do
          if sourceName == ObjectName(object) then
            if UnitCanAttack("player",object) then
              local blinktime = GetTime()
              blinkcd = blinktime + 15
            end
          end
        end
      end
]]

      if spellName == "Vanish" and (sourceName ~= myname) and instanceType ~= "arena" and wowex.wowexStorage.read("fap") then
        for object in OM:Objects(OM.Types.Player) do
          if sourceName == ObjectName(object) then
            if distance("player",object) <= 15 and UnitCanAttack("player",object) and GetItemCooldown(5634) == 0 and UnitTargetingUnit(object,"player") and not buff(6615,"player") and not buff(Stealth,"player") and not mounted() then
              Eval('RunMacroText("/use Free Action Potion")', 'player')
            end
          end
        end
      end
      if spellName == "Summon Water Elemental" and instanceType ~= "arena" and wowex.wowexStorage.read("fap") then
        for object in OM:Objects(OM.Types.Player) do
          if sourceName == ObjectName(object) then
            if distance("player",object) <= 30 and UnitCanAttack("player",object) and GetItemCooldown(5634) == 0 and UnitTargetingUnit(object,"player") and not buff(6615,"player") and not buff(Stealth,"player") and not mounted() then
              Eval('RunMacroText("/use Free Action Potion")', 'player')
            end
          end
        end
      end
    end

    if subevent == "SPELL_CAST_START" then
      local spellId, spellName = select(12, ...)
      if spellName == "Fear" or spellName == "Polymorph" or spellName == "Regrowth" or spellName == "Cyclone" or spellName == "Greater Heal" or spellName == "Flash Heal" or spellname == "Healing Wave" or spellname == "Binding Heal" or spellName == "Mana Burn" or spellName == "Drain Mana" or spellName == "Holy Light" then
        if health("target") <= 50 then
          for object in OM:Objects(OM.Types.Player) do
            if sourceName == ObjectName(object) then
              if UnitCanAttack("player",object) then
                if castable(Shadowstep,object) and castable(Kick) and not buff(Stealth,"player") and not buff(Vanish,"player") and distance("player",object) >= 5 and not UnitTargetingUnit("player",object) and UnitPower("player") >= 35 then
                  if not isProtected(object) then
                    cast(Shadowstep,object)
                    FaceObject(object)
                    MoveForwardStop()
                    MoveBackwardStop() 
                    StrafeLeftStop()
                    StrafeRightStop()
                    Debug("Shadowstep on " .. ObjectName(object),38768)
                  end
                end
              end
            end
          end
        end
      end
      if spellName == "Entangling Roots" and destName == myname and instanceType ~= "arena" and wowex.wowexStorage.read("fap") then
        if GetItemCooldown(5634) == 0 and not buff(6615,"player") and not buff(Stealth,"player") and not mounted() then
          Eval('RunMacroText("/use Free Action Potion")', 'player')
        end
      end
      if spellName == "Polymorph" or spellName == "Fear" then
        for object in OM:Objects(OM.Types.Player) do
          if sourceName == ObjectName(object) then
            if (UnitTargetingUnit(object,"player") or (UnitInParty("player") == true and UnitTargetingUnit(object,"party1"))) and distance("player",object) <= 30 and IsFacing(object,"player") then
              if castable(CloakOfShadows) and UnitCanAttack("player",object) and (SpellCasting(object) == "Fear" or SpellCasting(object) == "Polymorph") then
                Debug("Cloaking Polymorph/Fear",31224)
                return Eval('RunMacroText("/run _G.QueueRogueCast([[Cloak Of Shadows]], [[player]])")', 'player')
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
        kickDuration = kicktime + 5
      end
    end
  end
  

  function CacheTarget()
    if (UnitExists("target")) then
      if (oldTarget == nil) then -- no cache -> set cache to current target
        oldTarget = Object("target")
      else -- I already have a an old target
        oldTarget = currentTarget
      end
    currentTarget = Object("target")
    end
  end
  
  function t:UNIT_SPELLCAST_SUCCEEDED()
  --[[if UnitAffectingCombat("player") and not mounted() and not buff(Stealth,"player") and not buff(Vanish,"player") then]]
    t:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
      trinketUsedBy = nil
      if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if arg3 == 42292 then
          if UnitCanAttack("player",arg1) and distance("player",arg1) <= 100 then
            trinketUsedBy = Object(arg1)
            Debug("Trinket used by " .. ObjectName(arg1),42292)
          end
        end
        if arg3 == 11297 and arg1 == "player" then
          SAPCD = GetTime() + 2
            print(SAPCD)
        end
        if arg3 == 1833 and arg1 == "player" then
          CheapShotDR = GetTime() + 22
          CheapShotTarget = UnitName("target")
          print("Cheap Shot - " .. CheapShotDR)
        end
        if roguedistance <= 30 and (distance("player","target") > 5 or not UnitExists("target")) then
          if arg3 == 1856 and (arg1 ~= "player") then
            if castable(Vanish) and not castable(Stealth) and not buff(Stealth,"player") then
              Debug("Vanishing to avoid Rogue opener",1856)
              roguedistance = 100
              avoidedrogue = true
              avoidedroguetime = GetTime()            
              return cast(Vanish)
            end
          end
        end
        if arg3 == 25275 then
          for object in OM:Objects(OM.Types.Player) do
            if castable(Shadowstep,object) and UnitCanAttack("player",object) and UnitTargetingUnit(object,"player") and UnitClass(object) == "Warrior" and distance("player",object) <= 25 and distance("player",object) >= 8 then
              Debug("Shadowstep Intercept",38768)
              return cast(Shadowstep,object)
            end
          end
        end
      end
    end)
  end

  function p:PLAYER_TARGET_CHANGED()
    p:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
      for hunter in OM:Objects(OM.Types.Player) do
        if distance("player",hunter) <= 15 then
          if UnitClass(hunter) == "Hunter" then
            if UnitCanAttack("player",hunter) then
              if buff(5384,hunter) then
                FaceObject(hunter)
                TargetUnit(hunter)
                Debug("Re-targeting Huntard",5384)
                break
              end
            end
          end
        end
      end
    end)
  end

  local function Interrupt()
    if UnitAffectingCombat("player") and not buff(Stealth,"player") and not buff(Vanish,"player") then
      if buff(36554,"player") then
        kickNameplate(Kick, true)
      end

    if instanceType == "pvp" or instanceType == "arena" then
      for object in OM:Objects(OM.Types.Player) do
        if UnitCanAttack("player",object) then
          local kickclass, _, _ = UnitClass(object)
          if isCasting(object) and kickclass ~= "Hunter" then
            if castable(Kick,object) and not UnitTargetingUnit("player",object) and not isProtected(object) then
              FaceObject(object)
              Debug("Kicked off-target instantly ",38768)
              return cast(Kick,object)
            elseif castable(Kick,object) and UnitTargetingUnit("player",object) and not isProtected(object) then
              local _, _, _, _, endTime = UnitCastingInfo(object);
              local finish = endTime/1000 - GetTime()
              if finish <= 1 and castable(Kick) then
                FaceObject(object)
                Debug("Kicked " .. UnitName(object) .. " at " .. finish,38768)
                return cast(Kick,object)
              end
              --if finish <= 0.5 and castable(Gouge,object) and not IsBehind("player",object) and not castable(Kick,object) then
              --  FaceObject(object)
              --  Debug("Gouged " .. UnitName(object) .. " at " .. finish,38764)
              --  return cast(Gouge,object)
              --end
            end  
          elseif castable(Kick,object) and isChanneling(object) and kickclass ~= "Hunter" then
            local _, _, _, startTimeMS = UnitChannelInfo(object);
            local startTime = startTimeMS/1000 - GetTime()
            if startTime >= 0.5 and castable(Kick) then
              FaceObject(object)
              Debug("Kicked " .. UnitName(object) .. " fast ",38768)
              return cast(Kick,object)
            end
          end
        end
      end
    elseif instanceType ~= "pvp" or instanceType ~= "arena" then
      for i, object in ipairs(Objects()) do
        if UnitCanAttack("player",object) then
          local kickclass, _, _ = UnitClass(object)
          if isCasting(object) and kickclass ~= "Hunter" then
            if castable(Kick,object) and not UnitTargetingUnit("player",object) and not isProtected(object) then
              FaceObject(object)
              Debug("Kicked off-target instantly ",38768)
              return cast(Kick,object)
            elseif (castable(Kick,object) or castable(Gouge,object)) and UnitTargetingUnit("player",object) and not isProtected(object) then
              local _, _, _, _, endTime, _, _, _ = UnitCastingInfo(object);
              local finish = endTime/1000 - GetTime()
              if finish <= 1 and castable(Kick,object) then
                FaceObject(object)
                Debug("Kicked " .. UnitName(object) .. " at " .. finish,38768)
                return cast(Kick,object)
              end
              if finish <= 1 and castable(Gouge,object) and not IsBehind("player",object) and not castable(Kick,object) then
                FaceObject(object)
                Debug("Gouged " .. UnitName(object) .. " at " .. finish,38764)
                return cast(Gouge,object)
              end
            end  
          elseif castable(Kick,object) and isChanneling(object) and kickclass ~= "Hunter" then
            FaceObject(object)
            Debug("Kicked " .. UnitName(object) .. " fast ",38768)
            return cast(Kick,object)
          end
        end
      end
    end
    end
  end 

  local function Cooldowns()
    if UnitExists("target") and UnitCanAttack("player","target") and UnitAffectingCombat("player") and not buff(Stealth,"player") and not buff(Vanish,"player") and not mounted() then

      if ((UnitPower("player") < 90 and (cooldown(Hemorrhage) > 0 or UnitPower("player") <= 45)) or ((distance("player","target") > 10) or not UnitExists("target"))) and offHandEnchantID ~= nil then
        if targetclass ~= "Mage" then
          if --[[not buff(2893,"target")]] targetclass ~= "Druid" or targetclass ~= "Shaman" or targetclass ~= "Warrior" or targetclass ~= "Paladin" then
            if (not debuff(CheapShot,"target") or debuffduration(CheapShot,"target") >= 1.5) and (not debuff(KidneyShot,"target") or debuffduration(KidneyShot,"target") >= 1.5) then
              if (debuffduration(11201,"target") >= 2.5) then
                if --[[GetInventoryItemID("player",17) ~= (wowex.wowexStorage.read('woundid') .. " 0")]] offHandEnchantID ~= 2644 then
                  return EquipItemByName(wowex.wowexStorage.read("woundid"), 17) -- wound weapon
                end
              elseif (debuffduration(11201,"target") <= 2.5) and --[[GetInventoryItemID("player",17) ~= wowex.wowexStorage.read("cripplingid")]] offHandEnchantID ~= 603 then
                return EquipItemByName(wowex.wowexStorage.read("cripplingid"), 17) -- crippling weapon
              end 
            end
          elseif (--[[buff(2893,"target")]] targetclass == "Druid" or targetclass == "Shaman" or targetclass == "Warrior" or targetclass == "Paladin") then
            if WoundStacks("target") < 5 and --[[GetInventoryItemID("player",17) ~= wowex.wowexStorage.read("woundid")]] offHandEnchantID ~= 2644 then
              return EquipItemByName(wowex.wowexStorage.read("woundid"), 17) -- wound weapon
            --elseif WoundStacks("target") == 5 and GetInventoryItemID("player",17) ~= wowex.wowexStorage.read("cripplingid") then
            --EquipItemByName(wowex.wowexStorage.read("cripplingid"), 17) -- crippling weapon
            end
          end
        elseif targetclass == "Mage" then
          if (not debuff(CheapShot,"target") or debuffduration(CheapShot,"target") >= 1.5) and (not debuff(KidneyShot,"target") or debuffduration(KidneyShot,"target") >= 1.5) then
            if (debuffduration(11201,"target") >= 2.5) and --[[GetInventoryItemID("player",17) ~= wowex.wowexStorage.read("mindnumbingid")]] offHandEnchantID ~= 643 then
              return EquipItemByName(wowex.wowexStorage.read("mindnumbingid"), 17) -- Mind-numbing weapon
            elseif debuffduration(11201,"target") <= 2.5 and --[[GetInventoryItemID("player",17) ~= wowex.wowexStorage.read("cripplingid")]] offHandEnchantID ~= 603 then
              return EquipItemByName(wowex.wowexStorage.read("cripplingid"), 17) -- crippling weapon
            end
          end
        end
      end

      --if castable(Sprint) and distance("player","target") >= 30 and UnitAffectingCombat("target") and not castable(Shadowstep) then
      --  return cast(Sprint)
      --  Debug("Sprint used on " .. UnitName("player"), 11305)
      --end

      if UnitExists("target") and health() <= 10 and instanceType ~= "arena" then
        for offtarget in OM:Objects(OM.Types.Player) do
          if distance("player",offtarget) <= 10 and UnitClass(object) ~= "Warrior" then
            if castable(Gouge,offtarget) and not isProtected(offtarget) then
              if UnitAffectingCombat(offtarget) and not UnitIsDeadOrGhost(offtarget) and UnitCanAttack("player",offtarget) and GetComboPoints("player","target") <= 2 and not (buff(Stealth,"player") or buff(Vanish,"player")) then
                if not UnitTargetingUnit("player",offtarget) and IsFacing(offtarget, "player") and IsFacing("player",offtarget) then
                  local gougetarget = Object(offtarget)
                  FaceObject(gougetarget)
                  Debug("Gouging off-target " .. UnitName(gougetarget), 11305)                  
                  return cast(Gouge,gougetarget)
                end
              end
            end
          end
        end
      end

      if trinketUsedBy ~= nil then
        if health("target") <= 90 then
          if ObjectType(trinketUsedBy) == 4 and UnitCanAttack("player",trinketUsedBy) and distance("player",trinketUsedBy) <= 20 then
            if UnitTargetingUnit(trinketUsedBy,"target") and not UnitTargetingUnit("player",trinketUsedBy) and not debuff(Garrote,trinketUsedBy) and not debuff(Rupture,trinketUsedBy) and not IsPoisoned(trinketUsedBy) then
              --FaceObject(trinketUsedBy)
              --return cast(Blind,trinketUsedBy)
              Debug("Consider blinding " .. UnitClass(trinketUsedBy) .. " - " .. UnitName(trinketUsedBy, 2094))
              trinketUsedBy = nil
            elseif UnitTargetingUnit(trinketUsedBy,"player") and not UnitTargetingUnit("player",trinketUsedBy) and not debuff(Garrote,trinketUsedBy) and not debuff(Rupture,trinketUsedBy) and not IsPoisoned(trinketUsedBy) then
              --FaceObject(trinketUsedBy)
              --return cast(Blind,trinketUsedBy)
              Debug("Consider blinding " .. UnitClass(trinketUsedBy) .. " - " .. UnitName(trinketUsedBy, 2094))
              trinketUsedBy = nil
            end
          end
        end
      end
    end  
  end  

 local function Opener()
    if UnitCanAttack("player","target") and distance("player","target") <= 7 and (avoidedrogue == false or (GetTime() > (avoidedroguetime + 2))) --[[and not debuff(KidneyShot,"target") and not debuff(CheapShot,"target")]] then
      if buff(Stealth,"player") or buff(Vanish,"player") then
        if not IsBehind("target","player") then
          if castable(CheapShot,"target") and targetclass ~= "Mage" and not buff(34471,"target") and not isElite("target") then
            if CheapShotDR ~= nil then
              if (UnitName("target") == CheapShotTarget) and UnitIsPlayer("target") then
                if (GetTime() > CheapShotDR) then
                  cast(Premeditation, "target")
                  return cast(CheapShot,"target")
                end
              else
                cast(Premeditation, "target") 
                return cast(CheapShot,"target")
              end
            else
              cast(Premeditation, "target")
              return cast(CheapShot,"target")
            end
          end
        end
        if IsBehind("target","player") then 
          if castable(Ambush,"target") and GetInventoryItemID("player",16) == 28768 then
            cast(Premeditation, "target")
            return cast(Ambush,"target")
          end
          if castable(Garrote,"target") and not buff(20594,"target") and (targetclass == "Mage" or targetclass == "Hunter" or isElite("target")) --[[and not debuff(18469, "target")]] and not UnitIsMounted("target") --[[and not debuff(26884,"target")]] then -- fix DRUID STUFF
            cast(Premeditation, "target")
            return cast(Garrote,"target")
          end
          if castable(CheapShot,"target") and not buff(34471,"target") and not isElite("target") then
            if CheapShotDR ~= nil then
              if (UnitName("target") == CheapShotTarget) and UnitIsPlayer("target") then
                if (GetTime() > CheapShotDR) then
                  cast(Premeditation, "target")
                  return cast(CheapShot,"target")
                elseif (GetTime() < CheapShotDR) and targetclass ~= "Rogue" then 
                  cast(Premeditation, "target")
                  return cast(Garrote,"target")
                end
              else
                cast(Premeditation, "target")
                return cast(CheapShot,"target")
              end
            else
              cast(Premeditation, "target")
              return cast(CheapShot,"target")
            end
          end
        end
      end
    end
  end

  local function Dps()
    if UnitAffectingCombat("player") and UnitExists("target") and UnitCanAttack("player","target") and not buff(Stealth,"player") and not buff(Vanish,"player") and (UnitIsPlayer("target") or UnitHealth("target") > 5) then
      kidneychain = 0
      if kickDuration ~= nil then
        kidneychain = kickDuration - GetTime()
      end

      if not GetInventoryItemID("player",16) ~= (wowex.wowexStorage.read("mainhandid") .. " 0") then 
        EquipItemByName(wowex.wowexStorage.read("mainhandid"),16)
      end 

      if not IsPlayerAttacking("target") then
        Eval('StartAttack()', 't')
      end

      if castable(Eviscerate, "target") and myComboPoints >= 4 and health("target") <= 15 and UnitIsPlayer("target") then
        Debug("Uncalculated Execute on " .. UnitName("target"), 26865)
        return cast(Eviscerate, "target")
      end

      if castable(SliceAndDice,"player") and myComboPoints <= 0 and (not buff(SliceAndDice,"player") or buffduration(SliceAndDice,"player") <= 5) and distance("player","target") <= 15 and UnitPower("player") >= 40 and not (isCasting("target") or isChanneling("target")) and UnitHealth("target") > 5 and (instanceType ~= "arena" or cooldown(Blind) > 0) then
        TargetLastTarget()
        if UnitExists("target") and GetComboPoints("player","target") >= 1 and GetComboPoints("player","target") <= 3 and UnitHealth("target") > 5 then
          cast(SliceAndDice)
          TargetLastTarget()
          Debug("Slice and Dice on target change", 6774)
        else TargetLastTarget() end
      end

      if debuff(CheapShot, "target") and not IsBehind("target","player") and castable(Gouge,"target") and debuffduration(1833,"target") < 0.5 then
        Debug("Gouge to chain Cheap shot on " .. UnitName("target"), 38764)
        return cast(Gouge, "target")
      elseif debuff(CheapShot, "target") and myComboPoints >= 3 and (IsBehind("target","player") or cooldown(Gouge) ~= 0) and castable(KidneyShot,"target") and debuffduration(1833, "target") < 0.3 --[[and not debuff(18469,"target")]] and not buff(38373,"target") then
        if KidneyDR ~= nil then
          if UnitName("target") == KidneyTarget then
            if (GetTime() > KidneyDR) then
              Debug("Kidney Shot to chain Cheap Shot on " .. UnitName("target"), 8643)
              return cast(KidneyShot, "target")
            end
          else
            Debug("Kidney Shot to chain Cheap Shot on " .. UnitName("target"), 8643)
            return cast(KidneyShot,"target")
          end
        else
          Debug("Kidney Shot to chain Cheap Shot on " .. UnitName("target"), 8643)
          return cast(KidneyShot,"target")
        end
      end 
      if debuff(1330, "target") and castable(KidneyShot, "target") and myComboPoints >= 3 and debuffduration(1330, "target") < 0.3 --[[and not debuff(18469,"target")]] and not buff(38373,"target") then
        if KidneyDR ~= nil then
          if UnitName("target") == KidneyTarget then
            if (GetTime() > KidneyDR) then
              Debug("Kidney Shot to chain Garrote on " .. UnitName("target"), 8643)
              return cast(KidneyShot, "target")
            end
          else
            Debug("Kidney Shot to chain Garrote on " .. UnitName("target"), 8643)
            return cast(KidneyShot,"target")
          end
        else
          Debug("Kidney Shot to chain Garrote on " .. UnitName("target"), 8643)
          return cast(KidneyShot,"target")
        end
      end 
      if debuff(Gouge,"target") and castable(KidneyShot,"target") and myComboPoints >= 3 and debuffduration(Gouge,"target") < 0.3 --[[and not debuff(18469,"target")]] and not buff(38373,"target") then
        if KidneyDR ~= nil then
          if UnitName("target") == KidneyTarget then
            if (GetTime() > KidneyDR) then
              Debug("Kidney Shot to chain Gouge on " .. UnitName("target"), 8643)
              return cast(KidneyShot, "target")
            end
          else
            Debug("Kidney Shot to chain Gouge on " .. UnitName("target"), 8643)
            return cast(KidneyShot,"target")
          end
        else
          Debug("Kidney Shot to chain Gouge on " .. UnitName("target"), 8643)
          return cast(KidneyShot,"target")
        end
      end 
      --if castable(KidneyShot, "target") and kidneychain >= 0.1 and kidneychain <= 0.4 and not debuff(1330,"target") and myComboPoints >= 4 --[[and (class == "Priest" or class == "Druid" or class == "Shaman" or class == "Warlock" or class == "Mage" or class == "Paladin")]] then
      --  return cast(KidneyShot, "target")
      --  Debug("Kidney Shot to chain Kick on " .. UnitName("target"), 38764)
      --end
      --if (debuff(18469,"target") or debuffduration(15487,"target") < 0.5) and castable(KidneyShot, "target") and (debuffduration(18469,"target") < 0.3 or debuffduration(15487,"target") < 0.3) and not debuff(CheapShot,"target") and myComboPoints >= 4 and not buff(38373,"target") then
      --  if KidneyDR ~= nil then
      --    if UnitName("target") == KidneyTarget then
      --      if (GetTime() >= KidneyDR) then
      --        return cast(KidneyShot, "target")
      --        Debug("Kidney to Chain Silence on " .. UnitName("target"), 8643)
      --      end
      --    else
      --      return cast(KidneyShot,"target")
       --     Debug("Kidney to Chain Silence on " .. UnitName("target"), 8643)
      --    end
     --   else
     --     return cast(KidneyShot,"target")
     --     Debug("Kidney to Chain Silence on " .. UnitName("target"), 8643)
     --   end
     -- end      
      if castable(26679, "target") and distance("player","target") >= 15 and myComboPoints >= 1 and not castable(Shadowstep,"target") and (isCasting("target") or isChanneling("target")) then
        if UnitCanAttack("player",object) then
          local throwclass, _, _ = UnitClass("target")
          if isCasting("target") and throwclass ~= "Hunter" then
            if castable(26679,"target") and not isProtected("target") then
              local _, _, _, _, ThrowendTime, _, _, _ = UnitCastingInfo(object);
              local throwfinish = endTime/1000 - GetTime()
              if throwfinish <= 1 and castable(26679,"target") then
                FaceObject("target")
                Debug("Deadly Throw to Interrupt on " .. UnitName("target"), 26679)
                return cast(26679,"target")
              end
            end
          end
        end
      end
      if instanceType == "arena" and UnitExists("target") and partyMembersAround("player", 100) >= 1 and UnitInParty("player") == true then
        ---
        if ((UnitClass("party1") == "Mage" or UnitClass("party1") == "Hunter" or UnitClass("party1") == "Warrior" or UnitClass("party1") == "Rogue" or UnitClass("party1") == "Warlock") and ((cansee("party1","target") and UnitTargetingUnit("party1","target") and SpellCasting("party1") ~= "Polymorph") or UnitHealth("party1") == 0 or UnitIsDeadOrGhost("party1"))) or ((UnitClass("party1") ~= "Mage" or UnitClass("party1") ~= "Hunter" or UnitClass("party1") ~= "Warrior" or UnitClass("party1") ~= "Rogue" or UnitClass("party1") ~= "Warlock") and (cansee("party1","target") or UnitHealth("party1") == 0 or UnitIsDeadOrGhost("party1"))) or (UnitIsDeadOrGhost("party1") or UnitHealth("party1") == 0) then
          if castable(KidneyShot, "target") and myComboPoints >= 4 and not debuff(KidneyShot, "target") and not debuff(1833, "target") and not debuff(1330, "target") --[[and not debuff(18469, "target")]] and not buff(34471, "target") and not buff(38373,"target") and not buff(1953,"target") and not isElite("target") and (((cooldown(Vanish) > 0 and cooldown(Preparation) > 0) or (GetTime() < CheapShotDR) or CheapShotDR == nil) or (targetclass ~= "Mage" or targetclass ~= "Hunter")) and (not buff(Evasion,"target") or IsBehind("player","target")) then
            if KidneyDR ~= nil then
              if UnitName("target") == KidneyTarget then
                if (GetTime() > KidneyDR) then
                  Debug("BIG Kidney on " .. UnitName("target"), 8643)
                  return cast(KidneyShot, "target")
                end
              else
                Debug("BIG Kidney on " .. UnitName("target"), 8643)
                return cast(KidneyShot,"target")
              end
            else
              Debug("BIG Kidney on " .. UnitName("target"), 8643) 
              return cast(KidneyShot,"target")
            end
          end
          ----
        elseif ((UnitClass("party1") == "Mage" or UnitClass("party1") == "Hunter" or UnitClass("party1") == "Warrior" or UnitClass("party1") == "Rogue" or UnitClass("party1") == "Warlock") and ((not cansee("party1","target") or not UnitTargetingUnit("party1","target") or SpellCasting("party1") == "Polymorph") and UnitHealth("party1") ~= 0 or not UnitIsDeadOrGhost("party1"))) or ((UnitClass("party1") ~= "Mage" or UnitClass("party1") ~= "Hunter" or UnitClass("party1") ~= "Warrior" or UnitClass("party1") ~= "Rogue" or UnitClass("party1") ~= "Warlock") and (not cansee("party1","target") or UnitHealth("party1") ~= 0 or not UnitIsDeadOrGhost("party1"))) or (not UnitIsDeadOrGhost("party1") or UnitHealth("party1") ~= 0) then
          if castable(KidneyShot, "target") and myComboPoints >= 4 and not debuff(KidneyShot, "target") and not debuff(1833, "target") and not debuff(1330, "target") --[[and not debuff(18469, "target")]] and not buff(34471, "target") and not buff(1953,"target") and not isElite("target") and (not buff(Evasion,"target") or IsBehind("player","target")) then
            if KidneyDR ~= nil then
              if UnitName("target") == KidneyTarget then
                if (GetTime() > KidneyDR) then
                  Debug("TRYING TO CAST KIDNEY on " .. UnitName("target"), 8643)
                end
              else
                Debug("TRYING TO CAST KIDNEY on " .. UnitName("target"), 8643)
              end
            else
              Debug("TRYING TO CAST KIDNEY on " .. UnitName("target"), 8643)
            end
          end
        end
      elseif instanceType ~= "arena" or partyMembersAround("player", 100) < 1 or UnitInParty("player") == false then
        if castable(KidneyShot, "target") and myComboPoints >= 4 and not debuff(KidneyShot, "target") and not debuff(1833, "target") and not debuff(1330, "target") --[[and not debuff(18469, "target")]] and not buff(34471, "target") and not buff(1953,"target") and not isElite("target") and (not buff(Evasion,"target") or IsBehind("player","target")) then
          if KidneyDR ~= nil then
            if UnitName("target") == KidneyTarget then
              if (GetTime() > KidneyDR) then
                Debug("BIG Kidney on " .. UnitName("target"), 8643)
                return cast(KidneyShot, "target")
              end
            else
              Debug("BIG Kidney on " .. UnitName("target"), 8643)
              return cast(KidneyShot,"target")
            end
          else
            Debug("BIG Kidney on " .. UnitName("target"), 8643)
            return cast(KidneyShot,"target")
          end
        end
        ----  
      end

      --if castable(Rupture, "target") and myComboPoints >= 5 and ((targetclass == "Rogue" or targetclass == "Warrior") and health("target") <= 60) and not debuff(26867, "target") and not debuff(CheapShot, "target") and (not debuff(KidneyShot,"target") or debuffduration(KidneyShot,"target") < 1) then
      --  return cast(Rupture, "target")
      --  Debug("Rupture early on " .. UnitName("target"), 38764)
      --end
      if health("target") >= 40 then
        if castable(ExposeArmor, "target") and health("target") >= 40 and myComboPoints >= 4 and (cooldown(KidneyShot) >= 8 or isElite("target")) and (targetclass == "Warlock" or targetclass == "Priest" or targetclass == "Mage" or targetclass == "Druid") then
          Debug("Kidney Miss - Expose Armor " .. UnitName("target"), 26866)
          return cast(ExposeArmor,"target")
        elseif castable(Rupture, "target") and health("target") >= 40 and myComboPoints >= 4 and (cooldown(KidneyShot) >= 8 or isElite("target")) then
          Debug("Kidney Miss - Rupture " .. UnitName("target"), 38764)
          return cast(Rupture,"target")
        end
      elseif health("target") < 40 then
        if castable(Eviscerate, "target") and health("target") < 40 and myComboPoints >= 4 and (cooldown(KidneyShot) >= 8 or isElite("target")) then
          Debug("Kidney Miss - Eviscerate " .. UnitName("target"), 26865)
          return cast(Eviscerate,"target")
        end
      end
      if instanceType == "raid" then
        if castable(SliceAndDice,"target") and myComboPoints <= 5 and myComboPoints >= 3 and (not buff(SliceAndDice, "player") or buffduration(SliceAndDice) <= 2) and not debuff(CheapShot, "target") and not debuff(1330, "target") and health("target") >= 20 and (cooldown(KidneyShot) > 14 or isElite("target")) then
          return cast(SliceAndDice,"target")
        end
      elseif instanceType ~= "raid" then
        if castable(SliceAndDice,"target") and myComboPoints < 3 and myComboPoints >= 2 and (not buff(SliceAndDice, "player") or buffduration(SliceAndDice) <= 2) and not debuff(CheapShot, "target") and not debuff(1330, "target") and health("target") >= 50 and (cooldown(KidneyShot) > 14 or isElite("target")) then
          return cast(SliceAndDice,"target")
        end
      end

      --for object in OM:Objects(OM.Types.Player) do
      --  if distance("player",object) <= 100 and UnitCanAttack("player",object) then
      --    if (UnitClass(object) ~= "Druid" or UnitClass(object) ~= "Priest" or UnitClass(object) ~= "Shaman" or UnitClass(object) ~= "Paladin") then

      --if castable(Rupture, "target") and myComboPoints >= 3 --[[and UnitPowerType("target") ~= 0]] and not debuff(CheapShot, "target") and not debuff(KidneyShot, "target") and (health("target") >= 40 or isElite("target")) and (cooldown(KidneyShot) > 3 or isElite("target")) then
      --   return cast(Rupture, "target")
      --end
      --if castable(SliceAndDice, 'target') and myComboPoints >= 2 and buffduration(SliceAndDice, 'player') <= 1 then
      --  return return cast(SliceAndDice, 'target')
      --end
      --if castable(Eviscerate, "target") and myComboPoints >= 4 and not castable(KidneyShot, "target") and (cooldown(KidneyShot) > 5 or isElite("target")) then
      --  return cast(Eviscerate, "target")
      --end
      if castable(26679,"target") and myComboPoints >= 3 and distance("player","target") >= 10 and health("target") <= 10 then
        Debug("Deadly Throw Execute " .. UnitName("target"), 26679)
        return cast(26679, "target")
      end
    end
  end

  local function Loot()
    for i, object in ipairs(Objects()) do
      if ObjectLootable(object) and ObjectDistance("player",object) < 5 and ObjectType(object) == 3 then
        ObjectInteract(object)
      end
    end
    for i = GetNumLootItems(), 1, -1 do
      LootSlot(i)
    end
  end

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
    if not buff(Vanish,"player") and not buff(Stealth,"player") and UnitExists("target") and UnitCanAttack("player","target") and (UnitIsPlayer("target") or UnitHealth("target") > 5) and not isNova("target") then
      --if buff(36554,"player") and not isCasting("target") and myComboPoints <= 3 and not (debuff(KidneyShot,"target") or debuff(CheapShot,"target")) --[[and (SapHemoCD == nil or GetTime() > SapHemoCD)]] then
      --  return cast(Hemorrhage,"target")
      --end
      
      if offHandEnchantID ~= nil then
        if castable(Shiv,"target") and myComboPoints <= 4 and not (debuff(CheapShot,"target") or debuff(KidneyShot,"target")) and buff(Evasion,"target") then
          Debug("Shiv into Evasion " .. UnitName("target"),5938)
          return cast(Shiv,"target")
        end
        if castable(Shiv,"target") and offHandEnchantID == 603 and not buff(2893,"target") and debuff(KidneyShot,"target") and debuffduration(KidneyShot,"target") <= 3 and not buff(1044,"target") and (not debuff(11201,"target") or debuffduration(11201,"target") <= 2) and not buff(6615,"target") and not buff(34471, "target") and not buff(31224, "target") and not buff(20594, "target") and not debuff(27072,"target") and not debuff(116,"target") and not debuff(27087,"target") and not debuff(12486,"target") and myComboPoints < 5 and not isElite("target") then
          Debug("Shiv on to finish Kidney " .. UnitName("target"),5938)
          return cast(Shiv,"target")
        end
        if castable(Shiv,"target") and offHandEnchantID == 603 and not buff(2893,"target") and not debuff(11201,"target") and not buff(6615,"target") and not buff(34471, "target") and not buff(31224, "target") and not buff(20594, "target") and not debuff(27072,"target") and not debuff(116,"target") and not debuff(27087,"target") and not debuff(12486,"target") and not debuff(CheapShot, "target") and not debuff(KidneyShot, "target") and myComboPoints < 5 and moving("target") and (debuff(26864, "target") or targetclass == "Rogue" or targetclass == "Warrior" or targetclass == "Mage") and targetclass ~= "Druid" and not isElite("target") then
          Debug("Shiv to Cripple " .. UnitName("target"),5938)
          return cast(Shiv, "target")
        end
        if castable(Shiv,"target") and offHandEnchantID == 643 and not debuff(11398,"target") and debuff(11201,"target") and targetclass == "Mage" and not buff(34471, "target") and not buff(31224, "target") and not buff(20594, "target") and not debuff(CheapShot, "target") and not debuff(KidneyShot, "target") and myComboPoints < 5 and not isElite("target") then
          Debug("Shiv for Mind Numbing on " .. UnitName("target"),5938)
          return cast(Shiv, "target")
        end

        if instanceType == "arena" or instanceType == "pvp" then
          if (targetclass == "Warrior" or targetclass == "Priest" or targetclass == "Shaman" or targetclass == "Warlock") and enemiesAround("player", 100) > 1 then
            if castable(Shiv,"target") and offHandEnchantID == 2644 and debuff(11201,"target") and not debuff(CheapShot, "target") and myComboPoints < 5 then
              if not buff(2893,"target") and WoundStacks("target") <= 4 then
                Debug("Shiv to Wound " .. UnitName("target"), 5938)
                return cast(Shiv,"target")
              elseif buff(2893,"target") and WoundStacks("target") <= 3 then
                Debug("Shiv to Wound " .. UnitName("target"), 5938)
                return cast(Shiv,"target")
              end
            end
          end
        end
      end

      if castable(GhostlyStrike, "target") and not buff(GhostlyStrike,"player") and myComboPoints < 5 --[[and UnitTargetingUnit("target","player") and UnitPowerType("target") ~= 0]] and not debuff(CheapShot,"target") --[[and debuff(26864, "target")]] and not debuff(KidneyShot,"target") and not isElite("target") then
        if UnitClass(ObjectTargetingMe) == "Warrior" or UnitClass(ObjectTargetingMe) == "Rogue" or UnitClass(ObjectTargetingMe) == "Paladin" or UnitClass(ObjectTargetingMe) == "Hunter" or UnitClass(ObjectTargetingMe) == "Druid" then
          return cast(GhostlyStrike, "target")
        elseif not UnitIsPlayer("target") then
          return cast(GhostlyStrike, "target")
        end
      end
      if castable(Hemorrhage, "target") and debuff(CheapShot,"target") and (myComboPoints < 5 or UnitPower("player") >= 90) --[[and (SapHemoCD == nil or GetTime() > SapHemoCD)]] then
        if not IsBehind("target","player") and debuffduration(CheapShot,"target") > 2 and UnitPower("player") >= 80 then 
          return cast(Hemorrhage,"target")
        elseif IsBehind("target","player") and debuffduration(CheapShot,"target") > 1.2 and UnitPower("player") >= 55 then
          return cast(Hemorrhage,"target")
        end
      elseif castable(Hemorrhage,"target") and (UnitPower("player") >= 95 or (health("target") <= 30 and not isCasting("target")) or health("player") <= 10) and not debuff(CheapShot,"target") and (myComboPoints < 5 or UnitPower("player") >= 90) then
        return cast(Hemorrhage,"target")
      end
    end
  end

  local function healthstone()
    local healthstonelist = {22103, 22104, 22105}
    if health() <= 40 and UnitAffectingCombat("player") then
      for i = 1, #healthstonelist do
        if GetItemCount(healthstonelist[i]) >= 1 and GetItemCooldown(healthstonelist[i]) == 0 then
          local healthstonename = GetItemInfo(healthstonelist[i])
          Eval('RunMacroText("/use ' .. healthstonename .. '")', 'player')
          Debug("Healthstone used!!",22103)
        end
      end
    end
  end

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

  local function countItem(item)
    local c
    for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
            if item == GetContainerItemID(bag,slot) then
                c=c+(select(2,GetContainerItemInfo(bag,slot)))
            end
        end
    end
    return c
  end

  local function pvp()
    if (instanceType == "arena" or instanceType == "pvp") and castable(Stealth,"player") and not mounted() and not IsPoisoned("player") and not (isCasting("player") or isChanneling("player")) and not (buff(301089,"player") or buff(301091,"player") or buff(34976,"player")) and not buff(Vanish,"player") and not debuff(12867,"player") then
      EquipItemByName(wowex.wowexStorage.read("cripplingid"), 17)
      return cast(Stealth)
    end

    if buff(Vanish,"player") then
      Eval('RunMacroText("/stopattack")', 'player')
    end

    --if castable(Preparation,"player") and cooldown(Vanish) > 0 and not buff(Vanish,"player") --[[and cooldown(Evasion) >= 0 and cooldown(Shadowstep) >= 0 and cooldown(Sprint) >= 0]] then -- add casts for sprint and evasion if Vanish is on CD
    --  cast(Sprint,"player")
    --  Debug("Prep used on " .. UnitName("player"), 14185)
    --  return cast(Preparation)
    --end

    if castable(Preparation,"player") and cooldown(Vanish) > 0 and not buff(Vanish,"player") --[[and cooldown(Evasion) >= 0 and cooldown(Shadowstep) >= 0 and cooldown(Sprint) >= 0]] then -- add casts for sprint and evasion if Vanish is on CD
      if castable(Sprint) then
        cast(Sprint,"player")
      end
      if not buff(Stealth,"player") and not buff(Vanish,"player") and castable(Evasion) then
        cast(Evasion,"player")
        Debug("Prep used on " .. UnitName("player"), 14185)
        return cast(Preparation)
      end
    end

    if instanceType == "pvp" and not mounted() and not buff(Vanish,"player") then
      for flag in OM:Objects(OM.Types.GameObject) do
        if ObjectID(flag) == 328418 or ObjectID(flag) == 328416 or ObjectID(flag) == 367128 then
          if distance("player",flag) <= 5 then
            InteractUnit(flag)
          end
        elseif ObjectID(flag) == 183511 then
          if GetItemCount(22103) == 0 then
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end
          end
        elseif ObjectID(flag) == 183512 then
          if GetItemCount(22104) == 0 then 
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end 
          end
        elseif ObjectID(flag) == 181621 then
          if GetItemCount(22105) == 0 then 
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end
          end
        end
      end
    end

    --for i, object in ipairs(Objects()) do
    for object in OM:Objects(OM.Types.Player) do
      if distance("player",object) <= 20 and buff(Stealth,object) and (SAPCD == nil or (GetTime() > SAPCD)) then
        if UnitCanAttack("player",object) and not UnitIsDeadOrGhost(object) then
          if buff(Stealth,"player") and not UnitAffectingCombat(object) then
            TargetUnit(object)
            FaceObject(object)
            Debug("Sap".." "..UnitName(object),11297)
            return cast(Sap,object)
          --elseif not buff(Stealth,"player") and castable(Gouge,object) then
          --  TargetUnit(object)
          --  FaceObject(object)
          --  return cast(Gouge,object)
          --  Debug("Gouge".." "..UnitName(object),11286)
          end
        end 
      end
    end
    --[[
    for object in OM:Objects(OM.Types.Player) do
      if castable(Vanish) and not IsPoisoned("player") and distance("player",object) <= 15 then 
        if UnitPower("player") >= 40 and GetUnitName("target") ~= ObjectName(object) and not debuff(Sap,object) and not debuff(CheapShot,"target") then
          if UnitCanAttack("player",object) and not UnitIsDeadOrGhost(object) and UnitAffectingCombat("player") and not UnitAffectingCombat(object) then
            if not isProtected(object) then
              sapobject = Object(object)
              FaceObject(object)
              TargetUnit(object)
              Eval('RunMacroText("/stopattack")', 'player')
              return cast(26889,"player")
              Debug("Vanish to Sap " .. UnitName(object), 26889)
            end
            while(buff(26888,"player") and castable(Sap,sapobject) and not UnitAffectingCombat(sapobject)) do
              TargetUnit(sapobject)
              FaceObject(sapobject)
              return cast(Sap,sapobject)
              if debuff(Sap,sapobject) then
                TargetLastTarget()
                break
              end
              break
            end
          end
        end   
      end
    end
    ]]
  end
  
  local function Hide()
    if castable(Stealth,"player") and (not buff(Stealth,"player") --[[or buff(Vanish,"player")]]) and not UnitAffectingCombat("player") and UnitCanAttack("player","target") and distance("player","target") > 5 and not IsPoisoned("player") and not debuff(12867,"player") and not (buff(301089,"target") or buff(301091,"target") or buff(34976,"target")) then
      if UnitExists("target") and distance("player","target") <= 35 then
        Dismount()
        EquipItemByName(wowex.wowexStorage.read("cripplingid"), 17)
        return cast(Stealth)
      end
      if wowex.wowexStorage.read('stealtheat') then
        if IsEatingOrDrinking() and castable(Stealth,"player") and not IsPoisoned("player") then
          return cast(Stealth)
        end
      end
    end
  end
  if not UnitIsDeadOrGhost("target") then
    if #_G.RogueSpellQueue > 0 then
      Queue()
    else
    if Dismounter() then return true end

    if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
    if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    if p:PLAYER_TARGET_CHANGED() then return true end

    if pvp() then return true end
    if Opener() then return true end
    if Interrupt() then return true end
    if Cooldowns() then return true end

    if Execute() then return true end
    if Dps() then return true end
    if Filler() then return true end 

    if Defensives() then return true end
    if Hide() then return true end
    if Poison() then return true end
    if healthstone() then return true end
    --if Distract() then return true end

--[[
    if Opener() then return true end
    if Execute() then return true end
    if Dps() then return true end
    if Defensives() then return true end
    if Interrupt() then return true end
    if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
    if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    if p:PLAYER_TARGET_CHANGED() then return true end
    if Opener() then return true end
    if Cooldowns() then return true end
    if Execute() then return true end
    if pvp() then return true end
    if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
    if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    if p:PLAYER_TARGET_CHANGED() then return true end
    if Opener() then return true end
    if Dps() then return true end
    if Filler() then return true end 
    if Hide() then return true end
    if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
    if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    if p:PLAYER_TARGET_CHANGED() then return true end
    --if Distract() then return true end
    if Poison() then return true end
    if healthstone() then return true end
    if Dismounter() then return true end
    ]]

    end
  end
  if wowex.wowexStorage.read('autoloot') and not UnitAffectingCombat("player") and (not buff(Stealth,"player") or not buff(Vanish,"player")) and InventorySlots() > 2 then
    Loot()
    return true 
  end
end, Routine.Classes.Rogue, Routine.Specs.Rogue)
Routine:LoadRoutine(Routine.Specs.Rogue)
print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t [Yosh] whispers: Hello, " .. UnitName("player") .. " welcome to my routine :)")

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
  --[[
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
  ]]
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
        { key = "heading", type = "heading", color = 'FFF468', text = "Execute" },
        { key = "heading", type = "text", color = 'FFF468', text = "Multiplier = Eviscerate=Attack Power * (Number of Combo Points used * 0.03) * abitrary multiplier to account for Auto Attacks while pooling Recommendation : <= 60 == 1.6 >= 60 == 1.4" },
        { key = "personalmultiplier", type = "slider", text = "Execute Multiplier", label = "Execute Multiplier", min = 1, max = 3, step = 0.1 },
        { key = "heading", type = "heading", color = 'FFF468', text = "Poison" },
        { key = "mainhandpoison", width = 175, label = "Auto Poison Mainhand", text = wowex.wowexStorage.read("mainhandpoison"), type = "dropdown",
        options = {"Instant", "Wound","Crippling", "None"} },
        { key = "offhandpoison", width = 175, label = "Auto Poison Offhand", text = wowex.wowexStorage.read("offhandpoison"), type = "dropdown",
        options = {"Deadly", "MindNumbing","Crippling","None"} },
        { key = "mainhandid", type = "editbox", label = "Main Hand Weapon ID", max = "150" },
        { key = "cripplingid", type = "editbox", label = "Crippling Poison OffHand Weapon ID", max = "150" },
        { key = "woundid", type = "editbox", label = "Wound Poison OffHand Weapon ID", max = "150" },
        { key = "mindnumbingid", type = "editbox", label = "Mind Numbing Poison OffHand Weapon ID", max = "150" },
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
        { key = "heading", type = "heading", color = 'FFF468', text = "Stealth" },
        {type = "text", text = "DynOM = Scans the area around you for NPC aggro ranges and puts you into stealth when you get close to them.", color = 'FFF468'},
        {type = "text", text = "DynTarget = Stealthes you when you're near your TARGET's aggro range.", color = 'FFF468'},       
        { key = "stealthmode", width = 175, label = "Stealth Mode", text = wowex.wowexStorage.read("stealthmode"), type = "dropdown",
        options = {"DynOM", "DynTarget",} },
        { key = "stealtheat",  type = "checkbox", text = "Stealth while eating", desc = "" },
        { key = "heading", type = "heading", color = 'FFF468', text = "Other" },
        { key = "alwaysface",  type = "checkbox", text = "Always Face Target Players?", desc = "Always face target players in BGs (For AFK)" },
        { key = "autoloot",  type = "checkbox", text = "Auto Loot", desc = "" },
        { key = "thistletea",  type = "checkbox", text = "Use Thistle Tea?" , desc = "Will use on targets during Kidney Shot" },
        { key = "fap",  type = "checkbox", text = "Use Free Action Potion?" , desc = "Uses FAPs at certain times" },
        
      }
    },
    { 
      name = "Draw",
      items = 
      { 
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