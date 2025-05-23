

require "lua_timers"
RayGunMod = RayGunMod or {}
RayGunMod.dbg = false
function RayGunMod.clamp(val, minv, maxv)
    if val < minv then return minv end
    if val > maxv then return maxv end
    return val
end

function RayGunMod.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj);
            sq:getSpecialObjects():remove(obj);
            sq:getObjects():remove(obj);
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end

function RayGunMod.isWithinRange(pl, sq)
    local MaxRange = SandboxVars.RayGunMod.EffectsRange or 12
	local dist = pl:DistTo(sq:getX(), sq:getY())
	local bool = dist <= MaxRange
	--if not bool then getPlayer():Say(tostring("Miss")) end
    return bool
end
function RayGunMod.getPointer()
	if not isIngameState() then return nil end
	local sq = nil
	local zPos = getPlayer():getZ() or 0
	local mx, my = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), zPos)
	if mx and my then
		sq = getCell():getGridSquare(math.floor(mx), math.floor(my), zPos)
	end
	return sq or nil
end


function RayGunMod.attack(pl, wpn)
    if not (wpn and RayGunMod.isRayGun(wpn)) then return end

    local sq = RayGunMod.getPointer()
    if not sq then return end

    local modData = wpn:getModData()
    modData.ColdCell = modData.ColdCell or 0

    if wpn:getCurrentAmmoCount() <= 0 or modData.ColdCell <= 0 then return end
    if not ISReloadWeaponAction.canShoot(wpn) then return end

    --if not (sq:isCanSee(pl:getPlayerNum()) and sq:hasFloor(true)) then return end --uncomment if you dont want to reduce ammo when you cant see the square or its in midair

    if not RayGunMod.isWithinRange(pl, sq) then
        local px, py, pz = pl:getX(), pl:getY(), pl:getZ()
        local dx, dy = sq:getX() - px, sq:getY() - py
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist == 0 then return end

        local maxRange = RayGunMod.maxRange or 10
        local scale = maxRange / dist
        local tx = math.floor(px + dx * scale + 0.5)
        local ty = math.floor(py + dy * scale + 0.5)
        local tz = pz

        sq = getCell():getGridSquare(tx, ty, tz)
        if not sq then return end
    end

    if not (getDebug() and getDebugOptions():getBoolean("Cheat.Player.UnlimitedAmmo")) then
        modData.ColdCell = math.max(0, modData.ColdCell - 1)
    end
    RayGunMod:refresh(wpn)

    if not (sq:isCanSee(pl:getPlayerNum()) and sq:hasFloor(true)) then return end --comment this one if you uncommented the above

    local tx, ty, tz = sq:getX(), sq:getY(), sq:getZ()
    RayGunMod.AoE(sq, true)
    RayGunMod.doEffect(sq)

    if isClient() then
        sendClientCommand("RayGunMod", "syncBurst", { x = tx, y = ty, z = tz, dir = pl:getDir() })
    else
        RayGunMod.doBurst(tx, ty, tz, pl:getDir())
    end
end
Events.OnWeaponSwing.Add(RayGunMod.attack)




--[[
function RayGunMod.attack(pl, wpn)
    if wpn and RayGunMod.isRayGun(wpn) then
        local sq = RayGunMod.getPointer()
        local modData = wpn:getModData()
        modData.ColdCell = modData.ColdCell or 0
        local ammo = wpn:getCurrentAmmoCount()
        if sq and ammo > 0 and modData.ColdCell > 0 then



            local modData = wpn:getModData()
            if not (getDebug() and getDebugOptions():getBoolean("Cheat.Player.UnlimitedAmmo")) then
                modData.ColdCell = math.max(0, modData.ColdCell - 1)
            end
            RayGunMod:refresh(wpn)

            if RayGunMod.isWithinRange(pl, sq) then
                local tx, ty, tz = sq:getX(), sq:getY(), sq:getZ()
                RayGunMod.AoE(sq, true)



                RayGunMod.doEffect(sq)


                if isClient() then
                    sendClientCommand("RayGunMod", "syncBurst", { x = tx, y = ty, z = tz, dir = pl:getDir() })
                else
                    RayGunMod.doBurst(tx, ty, tz, pl:getDir())
                end

            end
        end
    end
end
Events.OnWeaponSwing.Remove(RayGunMod.attack)
Events.OnWeaponSwing.Add(RayGunMod.attack)

 ]]

-----------------------            ---------------------------

--[[ function RayGunMod.debris(sq)
    local sprName = "mortar_" .. tostring(ZombRand(63) - 8)
    local debris = IsoObject.new(sq, tostring(sprName), tostring(sprName), false)
    sq:AddTileObject(debris)
    if isClient() then
        debris:transmitCompleteItemToServer()
    end
end
 ]]
-- RayGunMod.burst(getPointer())
--[[
local sq = getPointer()
RayGunMod.burstObj = sq:AddTileObject(IsoObject.new(sq, "mortarburst_8",nil))

print(RayGunMod.burstObj)
RayGunMod.burstObj:getSquare():transmitRemoveItemFromSquare(RayGunMod.burstObj)
RayGunMod.burstObj:getSquare():RemoveTileObject(RayGunMod.burstObj)



local sq = getPointer()
local sprName = IsoSpriteManager.instance:getSprite("mortarburst_8")
local burstObj = IsoObject.new(sq, sprName)
sq:AddTileObject(burstObj)

RayGunMod.burstObj = burstObj
print(RayGunMod.burstObj)


if isClient() then
    RayGunMod.burstObj:transmitUpdatedSpriteToServer()
end



RayGunMod.doSledge(RayGunMod.burstObj)
 ]]
 --[[
function RayGunMod.addBurst(sprNum, sq)
    sprNum = sprNum or 0
    sq = sq or RayGunMod.getPointer()
    local sprName = "mortarburst_" .. tostring(sprNum)
    local obj = IsoObject.new(getCell(), sq, sprName, false, nil)
    sq:AddTileObject(obj)
    if isClient() then
        obj:transmitCompleteItemToServer()
    end
    timer:Simple(0.05, function()
        RayGunMod.doSledge(obj)
    end)

    ISInventoryPage.renderDirty = true
end
function RayGunMod.burst(sq)
    sq = sq or RayGunMod.getPointer()

    local sprNum = 0
    local ticks = 0
    local maxBursts = 14
    local tickRate = 10

    local function tickHandler()
        ticks = ticks + 1
        if ticks >= tickRate then
            RayGunMod.addBurst(sprNum, sq)
            sprNum = sprNum + 1
            ticks = 0

            if sprNum >= maxBursts then
                Events.OnTick.Remove(tickHandler)
            end
        end
    end

    Events.OnTick.Add(tickHandler)
end
 ]]
-----------------------            ---------------------------