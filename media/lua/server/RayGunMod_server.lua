
--server
if isClient() then return; end

local Commands = {};
Commands.RayGunMod = {};


Commands.RayGunMod.syncBurst = function(player, args)
  local playerId = player:getOnlineID();
    sendServerCommand("RayGunMod", "syncBurst",  {id = playerId, x = args.x, y = args.y,  z = args.z, dir = args.dir})
end


Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

