

RayGunMod = RayGunMod or {}

RayGunReloadAction = ISBaseTimedAction:derive("RayGunReloadAction")

function RayGunReloadAction:isValid()
    return self.gun and RayGunMod.isRayGun(self.gun)
end

function RayGunReloadAction:start()
    self:setActionAnim("reload")
    self:setOverrideHandModels(self.gun, nil)
end

function RayGunReloadAction:update()
end
function RayGunReloadAction:perform()
    local inv = self.character:getInventory()
    local modData = self.gun:getModData()
    modData.ColdCell = modData.ColdCell or 0

    local maxCharge = 20
    local needed = maxCharge - modData.ColdCell
    if needed <= 0 then
        ISBaseTimedAction.perform(self)
        return
    end

    local items = inv:getItems()
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        if item:getFullType() == "Base.ColdCellBattery" then
            local battData = item:getModData()
            battData.ColdCell = battData.ColdCell or 10
            local charge = battData.ColdCell

            if charge > 0 then
                local transfer = math.min(charge, needed)
                modData.ColdCell = modData.ColdCell + transfer
                needed = needed - transfer

                charge = charge - transfer

                if charge > 0 then
                    battData.ColdCell = charge
                else
                    inv:Remove(item)
                end

                if needed <= 0 then
                    break
                end
            else
                inv:Remove(item)
            end
        end
    end

    RayGunMod.refresh(self.gun)
    ISBaseTimedAction.perform(self)
end

function RayGunReloadAction:new(character, gun, time)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.gun = gun
    o.maxTime = time or 60
    o.stopOnWalk = true
    o.stopOnRun = true
    return o
end

function RayGunMod.doReload(pl, wpn)
    if RayGunMod.isRayGun(wpn) then
        ISTimedActionQueue.add(RayGunReloadAction:new(pl, wpn))
    end
end
--Events.OnPressReloadButton.Add(RayGunMod.doReload)




function RayGunMod.recharge(pl, wpn)
	if not (wpn and RayGunMod.isRayGun(wpn)) then return end

	local inv = pl:getInventory()
	local batt = inv:FindAndReturn("Base.ColdCellBattery")
	if not batt then return end

	local battData = batt:getModData()
	battData.ColdCell = battData.ColdCell or 10

	local modData = wpn:getModData()
	modData.ColdCell = modData.ColdCell or 0

	local needed = 20 - modData.ColdCell
	if needed <= 0 then return end

	local transfer = math.min(needed, battData.ColdCell)
	modData.ColdCell = modData.ColdCell + transfer
	battData.ColdCell = battData.ColdCell - transfer

	if battData.ColdCell <= 0 then
		inv:Remove(batt)
	end

	RayGunMod.refresh(wpn)
end

--Events.OnPressReloadButton.Remove(RayGunMod.recharge)
--Events.OnPressReloadButton.Add(RayGunMod.recharge)

-----------------------            ---------------------------
