--[[--------------------------------------------------------------------------------------------
║                              Trouble in Terrorist Town Commands                              ║
║                               By: Skillz, Bender180 and Alf21                                ║
║                              ╔═════════╗╔═════════╗╔═════════╗                               ║
║                              ║ ╔═╗ ╔═╗ ║║ ╔═╗ ╔═╗ ║║ ╔═╗ ╔═╗ ║                               ║
║                              ╚═╝ ║ ║ ╚═╝╚═╝ ║ ║ ╚═╝╚═╝ ║ ║ ╚═╝                               ║
║──────────────────────────────────║ ║────────║ ║────────║ ║───────────────────────────────────║
║──────────────────────────────────║ ║────────║ ║────────║ ║───────────────────────────────────║
║──────────────────────────────────╚═╝────────╚═╝────────╚═╝───────────────────────────────────║
║                  All code included is completely original or extracted                       ║
║            from the base ttt files that are provided with the ttt gamemode.                  ║
║                                                                                              ║
----------------------------------------------------------------------------------------------]]
local CATEGORY_NAME = "TTT 乐趣"
local gamemode_error = "当前的游戏模式在最恐怖的城镇中并不麻烦"

function GamemodeCheck(calling_ply)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)

		return true
	else
		return false
	end
end

--[Helper Functions]---------------------------------------------------------------------------
--[End]----------------------------------------------------------------------------------------

--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces < target(s) > to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.credits(calling_ply, target_plys, amount, should_silent)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
			target_plys[i]:AddCredits(amount)
		end

		ulx.fancyLogAdmin(calling_ply, true, "#A 给了 #T #i 学分", target_plys, amount)
	end
end

local credits = ulx.command(CATEGORY_NAME, "ulx credits", ulx.credits, "!credits")
credits:addParam{type = ULib.cmds.PlayersArg}
credits:addParam{type = ULib.cmds.NumArg, hint = "学分", ULib.cmds.round}
credits:defaultAccess(ULib.ACCESS_SUPERADMIN)
credits:setOpposite("ulx silent credits", {nil, nil, nil, true}, "!scredits", true)
credits:help("给予目标学分.")
--[End]----------------------------------------------------------------------------------------
