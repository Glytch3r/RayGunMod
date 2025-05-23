RayGunMod = RayGunMod or {}

--for some reason the refresh after shooting or reloading doesnt automatically update unless player walks
--to fix that bug we do refresh every min in game. this is a fix for a weird pz bug that lead me to hours of frustration so yeah lets do it this way we have no choice

function RayGunMod.refresher(ticks)
    RayGunMod.refresh(getPlayer():getPrimaryHandItem())
end
Events.EveryOneMinute.Add(RayGunMod.refresher)


-----------------------            ---------------------------

function RayGunMod.isRayGun(wpn)
    if not wpn then return false end
    if not wpn.isAimedFirearm or not wpn.getScriptItem then return false end
    if wpn:isAimedFirearm() and wpn:getScriptItem():isRanged() then
        local modData = wpn:getModData()
        return modData and modData.isRayGun
    end
    return false
end

function RayGunMod.updateGunTooltip(pl)
    if not pl then return end
    local inv = pl:getInventory()
    if not inv then return end
    local items = inv:getItems()
    if not items then return end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and RayGunMod.isRayGun(item) then
            local modData = item:getModData()
            modData.ColdCell = modData.ColdCell or 0
            item:setTooltip("Charge: " .. modData.ColdCell)
        end
    end
end
function RayGunMod.clearAnim(pl)
    pl = pl or getPlayer()
	pl:clearVariable("isLoading")
	pl:clearVariable("isRacking")
	pl:clearVariable("isUnloading")
	pl:clearVariable("WeaponReloadType")
	pl:clearVariable("RackAiming")
end
function RayGunMod.refresh(wpn)
    if not wpn or not RayGunMod.isRayGun(wpn) then return end
    local pl = getPlayer()

    local modData = wpn:getModData()
    local charge = modData.ColdCell
    local ammoCount = 0

    if charge >= 11 then
        ammoCount = 2
    elseif charge >= 1 then
        ammoCount = 1
    end
    --RayGunMod.clearAnim(pl)
    wpn:setCurrentAmmoCount(math.max(0, math.min(2, ammoCount)))

    wpn:setTooltip("Charge: " .. charge)
    ISInventoryPage.dirtyUI()
end


function RayGunMod.equip(pl, wpn)
    if wpn and RayGunMod.isRayGun(wpn) then
        RayGunMod.refresh(wpn)
    end
end
Events.OnEquipPrimary.Add(RayGunMod.equip)

-----------------------            ---------------------------

Events.OnCreatePlayer.Add(function()
    local pl = getPlayer()
    triggerEvent("OnEquipPrimary", pl , pl:getPrimaryHandItem())
end)
-----------------------            ---------------------------
function RayGunMod.updateCharge(item)
    if item:getFullType() == "Base.ColdCellBattery" then
        local modData = item:getModData()
        modData.ColdCell = modData.ColdCell or 10
        item:setTooltip("Charge: " .. modData.ColdCell)
    end
end

function RayGunMod.updateBatteryTooltips(pl, batt)
    local inv = pl:getInventory()
    local items = inv:getItems()

    if batt then
        RayGunMod.updateCharge(batt)
        return
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        RayGunMod.updateCharge(item)
    end
end
function RayGunMod.refreshAllChargeTooltips()
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player and not player:isDead() then
            RayGunMod.updateBatteryTooltips(player)
            RayGunMod.updateGunTooltip(player)
        end
    end
end

Events.OnRefreshInventoryWindowContainers.Remove(RayGunMod.refreshAllChargeTooltips)
Events.OnRefreshInventoryWindowContainers.Add(RayGunMod.refreshAllChargeTooltips)
-----------------------            ---------------------------
