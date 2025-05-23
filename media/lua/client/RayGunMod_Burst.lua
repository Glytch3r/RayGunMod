--lua code below is a modified version of ExplosionEffect.lua originally made by zz16
--Workshop ID: 3474836069
--Mod ID: ZZ_ExplosionSword

--permission to use the code was given to my client XiaZia
--i was specifically asked to use this
--i did the sprites that are used for this effects tho -Glytch3r
-----------------------            ---------------------------
require "ISUI/ISUIElement"
RayGunMod = RayGunMod or {}
BurstAnim = ISUIElement:derive("BurstAnim")

function BurstAnim:new(x, y, worldX, worldY, worldZ)
    local o = ISUIElement:new(x, y, 256, 256)
    setmetatable(o, self)
    self.__index = self
    o.frames = {}
    for i = 0, 15 do
        local texName = string.format("media/textures/burst/frame_%d.png", i)
        local tex = getTexture(texName)
        table.insert(o.frames, tex)
    end
    o.frameIndex = 1
    o.frameTime = 33
    o.lastUpdate = getTimestampMs()


    o.worldX = worldX
    o.worldY = worldY
    o.worldZ = worldZ

    return o
end

function BurstAnim:update()
    local screenX, screenY = ISCoordConversion.ToScreen(self.worldX, self.worldY, self.worldZ)
    local player = getPlayer()
    local zoom = getCore():getZoom(player:getPlayerNum()) or 1.0
    if zoom == 0 then zoom = 1.0 end

    local adjustedX = screenX / zoom - 128
    local adjustedY = screenY / zoom - 128

    if self.x ~= adjustedX or self.y ~= adjustedY then
        self:setX(adjustedX)
        self:setY(adjustedY)
    end
end



function BurstAnim:render()
    local now = getTimestampMs()
    if now - self.lastUpdate > self.frameTime then
        self.frameIndex = self.frameIndex + 1
        self.lastUpdate = now
        if self.frameIndex > #self.frames then
            self:removeFromUIManager()
            return
        end
    end

    local tex = self.frames[self.frameIndex]
    if tex then
        local player = getPlayer()
        local zoom = getCore():getZoom(player:getPlayerNum())
        if not zoom or zoom == 0 then zoom = 1.0 end

        local scale = 1 / zoom
        local drawW = self.width * scale
        local drawH = self.height * scale
        local offsetX = (self.width - drawW) / 2
        local offsetY = (self.height - drawH) / 2

        self:drawTextureScaled(tex, offsetX, offsetY, drawW, drawH, 1, 1, 1, 1)
    end
end

function RayGunMod.doBurst(wx, wy, wz, dirStr)
    local player = getPlayer()
    if not player then return end

    local offsetX, offsetY = 0.0, 0.0
    local dir = "N"

    if dirStr and type(dirStr) == "userdata" and dirStr.name then
        dir = dirStr:name():upper()
    elseif type(dirStr) == "string" then
        dir = dirStr:upper()
    end

    local dirOffsets8 = {
        N  = {x = -0.9, y = -1.5},
        NE = {x = -0.3, y = -1.3},
        E  = {x =  0.4, y = -0.4},
        SE = {x =  0.0, y = -0.3},
        S  = {x = -0.4, y = -0.6},
        SW = {x = -0.3, y = -0.9},
        W  = {x = -0.4, y = -0.8},
        NW = {x = -0.9, y = -1.2},
    }

    local offsets = dirOffsets8[dir]
    if offsets then
        offsetX = offsets.x
        offsetY = offsets.y
    end

    local fx = wx + offsetX
    local fy = wy + offsetY

    local screenX, screenY = ISCoordConversion.ToScreen(fx, fy, wz)
    local zoom = getCore():getZoom(player:getPlayerNum()) or 1.0
    local adjustedX = screenX / zoom
    local adjustedY = screenY / zoom

    --[[
        local emitter = getWorld():getFreeEmitter()
        emitter:setPos(fx, fy, wz)
        emitter:playSound("AerosolBombExplode")
    ]]

    local effect = BurstAnim:new(adjustedX - 128, adjustedY - 128, fx, fy, wz)
    effect:initialise()
    effect:addToUIManager()
end

