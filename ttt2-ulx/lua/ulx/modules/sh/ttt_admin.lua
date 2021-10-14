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
local CATEGORY_NAME = "TTT 管理员"
local gamemode_error = "目前的游戏模式不是恐怖小镇的麻烦!"

-----------------------------------------------------------------------------------------------
ROLE_NONE = ROLE_NONE or 0
ROLE_INNOCENT = ROLE_INNOCENT or 1
ROLE_TRAITOR = ROLE_TRAITOR or 2
ROLE_DETECTIVE = ROLE_DETECTIVE or 3

--[Ulx Completes]------------------------------------------------------------------------------
ulx.rolesTbl = ulx.rolesTbl or {"traitor", "detective", "innocent"}

ulx.target_role = ulx.target_role or {}
function updateRoles()
	table.Empty(ulx.target_role)

	for _, v in pairs(ulx.rolesTbl) do
		if TTT2 then
			local rd = roles.GetByName(v)

			if not rd.notSelectable then
				table.insert(ulx.target_role, v)
			end
		else
			table.insert(ulx.target_role, v)
		end
	end
end
hook.Add(ULib.HOOK_UCLCHANGED, "ULXRoleNamesUpdate", updateRoles)

updateRoles()

ulx.target_class = ulx.target_class or {}

--[End]----------------------------------------------------------------------------------------

--[Global Helper Functions][Used by more than one command.]------------------------------------
--[[send_messages][Sends messages to player(s)]
@param  {[PlayerObject]} v       [The player(s) to send the message to.]
@param  {[String]}       message [The message that will be sent.]
--]]
function send_messages(v, message)
	if type(v) == "Players" then
		v:ChatPrint(message)
	elseif type(v) == "table" then
		for i = 1, #v do
			v[i]:ChatPrint(message)
		end
	end
end

--[[corpse_find][Finds the corpse of a given player.]
@param  {[PlayerObject]} v       [The player that to find the corpse for.]
--]]
function corpse_find(v)
	for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end

--[[corpse_remove][removes the corpse given.]
@param  {[Ragdoll]} corpse [The corpse to be removed.]
--]]
function corpse_remove(corpse)
	CORPSE.SetFound(corpse, false)

	if string.find(corpse:GetModel(), "zm_", 6, true) then
		player.GetByUniqueID(corpse.uqid):TTT2NETSetBool("body_found", false)

		corpse:Remove()

		SendFullStateUpdate()
	elseif corpse.player_ragdoll then
		player.GetByUniqueID(corpse.uqid):TTT2NETSetBool("body_found", false)

		corpse:Remove()

		SendFullStateUpdate()
	end
end

--[[corpse_identify][identifies the given corpse.]
@param  {[Ragdoll]} corpse [The corpse to be identified.]
--]]
function corpse_identify(corpse)
	if corpse then
		local ply = player.GetByUniqueID(corpse.uqid)

		ply:TTT2NETSetBool("body_found", true)

		CORPSE.SetFound(corpse, true)
	end
end
--[End]----------------------------------------------------------------------------------------




--[Force role]---------------------------------------------------------------------------------
--[[ulx.force][Forces < target(s) > to become a specified role.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_role   [The role that target player(s) will have there role set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.slaynr(calling_ply, target_ply, num_slay, should_slaynr)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local current_slay
		local new_slay

		if ulx.getExclusive(target_ply, calling_ply) then
			ULib.tsayError(calling_ply, ulx.getExclusive(target_ply, calling_ply), true)
		elseif num_slay < 0 then
			ULib.tsayError(calling_ply, "无效整数:\"" .. num_slay .. "\" 指定的.", true)
		else
			current_slay = tonumber(target_ply:GetPData("slaynr_slays")) or 0

			if not should_slaynr then
				new_slay = current_slay + num_slay
			else
				new_slay = current_slay - num_slay
			end

			--local slay_reason = reason
			--if slay_reason == "reason" then
			--	slay_reason = false
			--end

			if new_slay > 0 then
				target_ply:SetPData("slaynr_slays", new_slay)
				--target_ply:SetPData("slaynr_reason", slay_reason)
			else
				target_ply:RemovePData("slaynr_slays")
				--target_ply:RemovePData("slaynr_reason")
			end

			local slays_left = tonumber(target_ply:GetPData("slaynr_slays")) or 0
			local slays_removed = (current_slay - slays_left) or 0
			local chat_message = ""

			if slays_removed == 0 then
				chat_message = "#T 下一轮不会被杀死."
			elseif slays_removed > 0 then
				chat_message = "#A 移除 " .. slays_removed .. " 一轮杀戮 #T."
			elseif slays_left == 1 then
				chat_message = "#A 将在下一轮杀死 #T."
			elseif slays_left > 1 then
				chat_message = "#A 将在下一个杀死 #T " .. tostring(slays_left) .. " 回合."
			end

			ulx.fancyLogAdmin(calling_ply, chat_message, target_ply, reason)
		end
	end
end

local slaynr = ulx.command(CATEGORY_NAME, "ulx slaynr", ulx.slaynr, "!slaynr")
slaynr:addParam{type = ULib.cmds.PlayerArg}
slaynr:addParam{type = ULib.cmds.NumArg, max = 100, default = 1, hint = "rounds", ULib.cmds.optional, ULib.cmds.round}
--slaynr:addParam{type = ULib.cmds.StringArg, hint = "reason",  ULib.cmds.optional}
slaynr:addParam{type = ULib.cmds.BoolArg, invisible = true}
slaynr:defaultAccess(ULib.ACCESS_ADMIN)
slaynr:help("在数回合内杀死目标")
slaynr:setOpposite("ulx rslaynr", {nil, nil, nil, true}, "!rslaynr")

--[Helper Functions]---------------------------------------------------------------------------
hook.Add("TTTBeginRound", "SlayPlayersNextRound", function()
	local affected_plys = {}

	for _, v in pairs(player.GetAll()) do
		local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0

		if v:Alive() and slays_left > 0 then
			local slays_left2 = slays_left - 1

			if slays_left2 == 0 then
				v:RemovePData("slaynr_slays")
				v:RemovePData("slaynr_reason")
			else
				v:SetPData("slaynr_slays", slays_left2)
			end

			v:StripWeapons()

			table.insert(affected_plys, v)

			timer.Create("check" .. v:SteamID64(), 0.1, 0, function() --workaround for issue with tommys damage log
				v:Kill()

				GAMEMODE:PlayerSilentDeath(v)

				local corpse = corpse_find(v)
				if corpse then
					v:TTT2NETSetBool("body_found", true)

					SendFullStateUpdate()

					if string.find(corpse:GetModel(), "zm_", 6, true) then
						corpse:Remove()
					elseif corpse.player_ragdoll then
						corpse:Remove()
					end
				end

				v:SetTeam(TEAM_SPEC)

				if v:IsSpec() then
					timer.Remove("check" .. v:SteamID64())

					return
				end
			end)

			timer.Create("traitorcheck" .. v:SteamID64(), 1, 0, function() -- have to wait for gamemode before doing this
				if not TTT2 and v:IsRole(ROLE_TRAITOR) or TTT2 and v:HasTeam(TEAM_TRAITOR) then
					if TTT2 then
						SendConfirmedTeam(TEAM_TRAITOR)

						local corpse = corpse_find(v)
						
						if corpse then
							events.Trigger(EVENT_BODYFOUND, v, corpse)
						end
					else
						SendConfirmedTraitors()
						SCORE:HandleBodyFound(v, v)
					end
				end
			end)
		end
	end

	local slay_message

	for i = 1, #affected_plys do
		local v = affected_plys[i]
		local string_inbetween

		if i > 1 and #affected_plys == i then
			string_inbetween = " and "
		elseif i > 1 then
			string_inbetween = ", "
		end

		string_inbetween = string_inbetween or ""
		slay_message = (slay_message or "") .. string_inbetween
		slay_message = (slay_message or "") .. v:Nick()
	end

	local slay_message_context

	if #affected_plys == 1 then
		slay_message_context = "was" else slay_message_context = "were"
	end

	if #affected_plys ~= 0 then
		ULib.tsay(nil, slay_message .. " " .. slay_message_context .. " slain.")
	end
end)

hook.Add("PlayerSpawn", "Inform", function(ply)
	local slays_left = tonumber(ply:GetPData("slaynr_slays")) or 0
	local slay_reason = false

	if ply:Alive() and slays_left > 0 then
		local chat_message = ""

		if slays_left > 0 then
			chat_message = chat_message .. "你会在这一轮被杀"
		end

		if slays_left > 1 then
			chat_message = chat_message .. " 和 " .. (slays_left - 1) .. " 当前回合之后的回合"
		end

		if slay_reason then
			chat_message = chat_message .. " 给予 \"" .. slays_reason .. "\"."
		else
			chat_message = chat_message .. "."
		end

		ply:ChatPrint(chat_message)
	end
end)
--[End]----------------------------------------------------------------------------------------


--[Force role]---------------------------------------------------------------------------------
--[[ulx.force][Forces < target(s) > to become a specified role.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_role   [The role that target player(s) will have there role set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.force(calling_ply, target_plys, target_role, should_silent)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local role, role_grammar, role_string, role_credits
		local affected_plys = {}

		if not TTT2 then
			if target_role == "traitor" or target_role == "t" then
				role, role_grammar, role_string, role_credits = ROLE_TRAITOR, "a ", "traitor", GetConVar("ttt_credits_starting"):GetInt()
			end

			if target_role == "detective" or target_role == "d" then
				role, role_grammar, role_string, role_credits = ROLE_DETECTIVE, "a ", "detective", GetConVar("ttt_credits_starting"):GetInt()
			end

			if target_role == "innocent" or target_role == "i" then
				role, role_grammar, role_string, role_credits = ROLE_INNOCENT, "an ", "innocent", 0
			end
		else
			for _, v in pairs(GetSortedRoles()) do
				if target_role == v.name or target_role == v.abbr then
					if v.notSelectable then
						role = "invalid_role_not_selectable"

						break
					end

					local gr = "a"
					local i = 1
					local sh = string.sub(v.name, i, i)
					while sh == "h" do
						i = i + 1
						sh = string.sub(v.name, i, i)
					end

					if sh == "a" or sh == "e" or sh == "i" or sh == "o" or sh == "u" then
						gr = gr .. "n"
					end

					role, role_grammar, role_string, role_credits = v.index, gr, v.name, GetStartingCredits(v.abbr)

					break
				end
			end
		end

		for i = 1, #target_plys do
			local v = target_plys[i]
			local current_role = TTT2 and v:GetSubRole() or not TTT2 and v:GetRole()

			if ulx.getExclusive(v, calling_ply) then
				ULib.tsayError(calling_ply, ulx.getExclusive(v, calling_ply), true)
			elseif GetRoundState() == 1 or GetRoundState() == 2 then
				ULib.tsayError(calling_ply, "回合还未开始!", true)
			elseif not role then
				ULib.tsayError(calling_ply, "无效角色 :\"" .. target_role .. "\" 指定的", true)
			elseif role == "invalid_role_not_selectable" then
				ULib.tsayError(calling_ply, "无法选择所选角色!", true)
			elseif not v:Alive() then
				ULib.tsayError(calling_ply, v:Nick() .. " 死了!", true)
			elseif current_role == role then
				ULib.tsayError(calling_ply, v:Nick() .. " 已经 " .. role_string, true)
			else
				v:SetRole(role)
				v:SetCredits(role_credits)

				table.insert(affected_plys, v)
			end
		end

		if role_grammar then -- if not set, no message!
			ulx.fancyLogAdmin(calling_ply, should_silent, "#A 强迫 #T 成为角色 " .. role_grammar .. " #s.", affected_plys, role_string)

			send_messages(affected_plys, "您的角色已设置为 " .. role_string .. ".")
		end

		SendFullStateUpdate()
	end
end

local force = ulx.command(CATEGORY_NAME, "ulx force", ulx.force, "!force")
force:addParam{type = ULib.cmds.PlayersArg}
force:addParam{type = ULib.cmds.StringArg, completes = ulx.target_role, hint = "- 选择角色 -", ULib.cmds.restrictToCompletes}
force:addParam{type = ULib.cmds.BoolArg, invisible = true}
force:defaultAccess(ULib.ACCESS_SUPERADMIN)
force:setOpposite("ulx sforce", {nil, nil, nil, true}, "!sforce", true)
force:help("强制 <target(s)> 成为指定角色.")

--[Force class]---------------------------------------------------------------------------------
--[[ulx.forceclass][Forces < target(s) > to become a specified class.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_class   [The class that target player(s) will have there class set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.forceclass(calling_ply, target_plys, target_class, should_silent)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		if TTT2 and TTTC then
			local class, class_grammar, class_string
			local affected_plys = {}

			for _, v in pairs(CLASS.CLASSES) do
				if target_class == v.name then
					local gr = "a"
					local i = 1
					local sh = string.sub(v.name, i, i)

					while sh == "h" do
						i = i + 1
						sh = string.sub(v.name, i, i)
					end

					if sh == "a" or sh == "e" or sh == "i" or sh == "o" or sh == "u" then
						gr = gr .. "n"
					end

					class, class_grammar, class_string = v.index, gr, v.name

					break
				end
			end

			for i = 1, #target_plys do
				local v = target_plys[i]
				local current_class = v:GetCustomClass()

				if ulx.getExclusive(v, calling_ply) then
					ULib.tsayError(calling_ply, ulx.getExclusive(v, calling_ply), true)
				elseif GetRoundState() == 1 or GetRoundState() == 2 then
					ULib.tsayError(calling_ply, "回合还未开始!", true)
				elseif not class then
					ULib.tsayError(calling_ply, "无效类 :\"" .. target_class .. "\" 指定的", true)
				elseif class == "invalid_class_not_selectable" then
					ULib.tsayError(calling_ply, "无法选择所选class!", true)
				elseif not v:Alive() then
					ULib.tsayError(calling_ply, v:Nick() .. " 死了!", true)
				elseif current_class and current_class == class then
					ULib.tsayError(calling_ply, v:Nick() .. " 已经有这class!", true)
				else
					v:UpdateClass(class)

					table.insert(affected_plys, v)
				end
			end

			if class_grammar then -- if not set, no message!
				ulx.fancyLogAdmin(calling_ply, should_silent, "#A 强迫 #T 成为 " .. class_grammar .. " #s.", affected_plys, class_string)

				send_messages(affected_plys, "您的class已设置为 " .. class_string .. ".")
			end
		end
	end
end

local forceclass = ulx.command(CATEGORY_NAME, "ulx forceclass", ulx.forceclass, "!forceclass")
forceclass:addParam{type = ULib.cmds.PlayersArg}
forceclass:addParam{type = ULib.cmds.StringArg, completes = ulx.target_class, hint = "- 选择class -", ULib.cmds.restrictToCompletes}
forceclass:addParam{type = ULib.cmds.BoolArg, invisible = true}
forceclass:defaultAccess(ULib.ACCESS_SUPERADMIN)
forceclass:setOpposite("ulx sforceclass", {nil, nil, nil, true}, "!sforceclass", true)
forceclass:help("强制class <target(s)> 成为指定的类.")

local function initClassClasses()
	if TTTC then
		table.Empty(ulx.target_class)

		for _, v in SortedPairs(CLASS.CLASSES) do
			table.insert(ulx.target_class, v.name)
		end
	end
end

hook.Add("TTT2FinishedLoading", "TTT2UlxInitClassesComplete", initClassClasses)
hook.Add(ULib.HOOK_UCLCHANGED, "ULXClassNamesUpdate", initClassClasses)

--[Respawn]------------------------------------------------------------------------------------
--[[ulx.respawn][Respawns < target(s) > ]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawn(calling_ply, target_plys, should_silent)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local affected_plys = {}

		for i = 1, #target_plys do
			local v = target_plys[i]

			if ulx.getExclusive(v, calling_ply) then
				ULib.tsayError(calling_ply, ulx.getExclusive(v, calling_ply), true)
			elseif GetRoundState() == 1 then
				ULib.tsayError(calling_ply, "等待玩家!", true)
			elseif v:Alive() and v:IsSpec() then -- players arent really dead when they are spectating, we need to handle that correctly
				timer.Remove("traitorcheck" .. v:SteamID64())

				v:ConCommand("ttt_spectator_mode 0") -- just incase they are in spectator mode take them out of it

				timer.Create("respawndelay", 0.1, 0, function() --seems to be a slight delay from when you leave spec and when you can spawn this should get us around that
					local corpse = corpse_find(v) -- run the normal respawn code now

					if corpse then
						corpse_remove(corpse)
					end

					v:SpawnForRound(true)

					if not TTT2 then
						v:SetCredits(((v:GetRole() == ROLE_INNOCENT) and 0) or GetConVar("ttt_credits_starting"):GetInt())
					else
						v:SetCredits(GetStartingCredits(v:GetSubRoleData().abbr))
					end

					table.insert(affected_plys, v)

					ulx.fancyLogAdmin(calling_ply, should_silent, "#A 重生 #T!", affected_plys)
					send_messages(affected_plys, "你重生了.")

					if v:Alive() then
						timer.Remove("respawndelay")

						return
					end
				end)

			elseif v:Alive() then
				ULib.tsayError(calling_ply, v:Nick() .. " 已经活着!", true)
			else
				timer.Remove("traitorcheck" .. v:SteamID64())

				local corpse = corpse_find(v)

				if corpse then
					corpse_remove(corpse)
				end

				v:SpawnForRound(true)

				if not TTT2 then
					v:SetCredits(((v:GetRole() == ROLE_INNOCENT) and 0) or GetConVar("ttt_credits_starting"):GetInt())
				else
					v:SetCredits(GetStartingCredits(v:GetSubRoleData().abbr))
				end

				table.insert(affected_plys, v)
			end
		end

		ulx.fancyLogAdmin(calling_ply, should_silent, "#A 重生 #T!", affected_plys)
		send_messages(affected_plys, "你重生了.")
	end
end

local respawn = ulx.command(CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn")
respawn:addParam{type = ULib.cmds.PlayersArg}
respawn:addParam{type = ULib.cmds.BoolArg, invisible = true}
respawn:defaultAccess(ULib.ACCESS_SUPERADMIN)
respawn:setOpposite("ulx srespawn", {nil, nil, true}, "!srespawn", true)
respawn:help("重生 <target(s)>.")
--[End]----------------------------------------------------------------------------------------



--[Respawn teleport]---------------------------------------------------------------------------
--[[ulx.respawntp][Respawns < target(s) > ]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_ply    [The player who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawntp(calling_ply, target_ply, should_silent)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local affected_ply = {}

		if not calling_ply:IsValid() then
			Msg("你是控制台,你不能传送或传送别人,因为你看不到世界!\n")

			return
		elseif ulx.getExclusive(target_ply, calling_ply) then
			ULib.tsayError(calling_ply, ulx.getExclusive(target_ply, calling_ply), true)
		elseif GetRoundState() == 1 then
			ULib.tsayError(calling_ply, "等待玩家!", true)
		elseif target_ply:Alive() and target_ply:IsSpec() then
			timer.Remove("traitorcheck" .. target_ply:SteamID64())

			target_ply:ConCommand("ttt_spectator_mode 0")

			timer.Create("respawntpdelay", 0.1, 0, function() --have to wait for gamemode before doing this
				local t = {}
				t.start = calling_ply:GetPos() + Vector(0, 0, 32) -- Move them up a bit so they can travel across the ground
				t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
				t.filter = target_ply

				if target_ply ~= calling_ply then
					t.filter = {target_ply, calling_ply}
				end

				local tr = util.TraceEntity(t, target_ply)
				local pos = tr.HitPos

				local corpse = corpse_find(target_ply)
				if corpse then
					corpse_remove(corpse)
				end

				target_ply:SpawnForRound(true)

				if not TTT2 then
					target_ply:SetCredits(((target_ply:GetRole() == ROLE_INNOCENT) and 0) or GetConVar("ttt_credits_starting"):GetInt())
				else
					target_ply:SetCredits(GetStartingCredits(target_ply:GetSubRoleData().abbr))
				end

				target_ply:SetPos(pos)

				table.insert(affected_ply, target_ply)

				ulx.fancyLogAdmin(calling_ply, should_silent, "#A 重生和传送 #T!", affected_ply)
				send_messages(target_ply, "你被重生和传送.")

				if target_ply:Alive() then
					timer.Remove("respawntpdelay")

					return
				end
			end)
		elseif target_ply:Alive() then
			ULib.tsayError(calling_ply, target_ply:Nick() .. " 已经活着!", true)
		else
			timer.Remove("traitorcheck" .. target_ply:SteamID64())

			local t = {}
			t.start = calling_ply:GetPos() + Vector(0, 0, 32) -- Move them up a bit so they can travel across the ground
			t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
			t.filter = target_ply

			if target_ply ~= calling_ply then
				t.filter = {target_ply, calling_ply}
			end

			local tr = util.TraceEntity(t, target_ply)
			local pos = tr.HitPos

			local corpse = corpse_find(target_ply)
			if corpse then
				corpse_remove(corpse)
			end

			target_ply:SpawnForRound(true)

			if not TTT2 then
				target_ply:SetCredits(((target_ply:GetRole() == ROLE_INNOCENT) and 0) or GetConVar("ttt_credits_starting"):GetInt())
			else
				target_ply:SetCredits(GetStartingCredits(target_ply:GetSubRoleData().abbr))
			end

			target_ply:SetPos(pos)

			table.insert(affected_ply, target_ply)
		end

		ulx.fancyLogAdmin(calling_ply, should_silent, "#A 重生和传送 #T!", affected_ply)
		send_messages(affected_ply, "你被重生和传送.")
	end
end

local respawntp = ulx.command(CATEGORY_NAME, "ulx respawntp", ulx.respawntp, "!respawntp")
respawntp:addParam{type = ULib.cmds.PlayerArg}
respawntp:addParam{type = ULib.cmds.BoolArg, invisible = true}
respawntp:defaultAccess(ULib.ACCESS_SUPERADMIN)
respawntp:setOpposite("ulx srespawntp", {nil, nil, true}, "!srespawntp", true)
respawntp:help("将 <target> 重生到特定位置.")
--[End]----------------------------------------------------------------------------------------



--[Karma]--------------------------------------------------------------------------------------
--[[ulx.karma][Sets the < target(s) > karma to a given amount.]
@param  {[PlayerObject]} calling_ply [The player who used the command.]
@param  {[PlayerObject]} target_plys [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       amount      [The number the target's karma will be set to.]
--]]
function ulx.karma(calling_ply, target_plys, amount)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
			target_plys[i]:SetBaseKarma(amount)
			target_plys[i]:SetLiveKarma(amount)
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A 将 #T 的业力值设置为 #i", target_plys, amount)
end

local karma = ulx.command(CATEGORY_NAME, "ulx karma", ulx.karma, "!karma")
karma:addParam{type = ULib.cmds.PlayersArg}
karma:addParam{type = ULib.cmds.NumArg, min = 0, max = 10000, default = 1000, hint = "Karma", ULib.cmds.optional, ULib.cmds.round}
karma:defaultAccess(ULib.ACCESS_ADMIN)
karma:help("改变 <target(s)> 业力值.")
--[End]----------------------------------------------------------------------------------------



--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces < target(s) > to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.tttspec(calling_ply, target_plys, should_unspec)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		for i = 1, #target_plys do
			local v = target_plys[i]

			if should_unspec then
				v:ConCommand("ttt_spectator_mode 0")
			else
				v:Kill()
				v:SetForceSpec(true)
				v:SetTeam(TEAM_SPEC)
				v:ConCommand("ttt_spectator_mode 1")
				v:ConCommand("ttt_cl_idlepopup")
			end
		end

		if should_unspec then
			ulx.fancyLogAdmin(calling_ply, "#A 已经迫使 #T 加入下一轮的活人世界.", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 迫使 #T 旁观.", target_plys)
		end
	end
end

local tttspec = ulx.command(CATEGORY_NAME, "ulx fspec", ulx.tttspec, "!fspec")
tttspec:addParam{type = ULib.cmds.PlayersArg}
tttspec:addParam{type = ULib.cmds.BoolArg, invisible = true}
tttspec:defaultAccess(ULib.ACCESS_ADMIN)
tttspec:setOpposite("ulx unspec", {nil, nil, true}, "!unspec")
tttspec:help("强制 <target(s)> 进入/离开旁观者.")
--[End]----------------------------------------------------------------------------------------

------------------------------ Next Round  ------------------------------
ulx.next_round = {}

local function updateNextround()
	table.Empty(ulx.next_round) -- Don't reassign so we don't lose our refs

	for _, v in pairs(ulx.rolesTbl) do
		if v ~= "innocent" then
			table.insert(ulx.next_round, v) -- Add special roles to the table.
		end
	end

	table.insert(ulx.next_round, "unmark") -- Add "unmark" to the table.
end

hook.Add(ULib.HOOK_UCLCHANGED, "ULXNextRoundUpdate", updateNextround)

updateNextround() -- Init

hook.Add("Initialize", "InitializeSetupForTTTMod", function()
	if not TTT2 then
		_G["PlysMarkedForRole"] = {}
		PlysMarkedForRole[ROLE_TRAITOR] = {}
		PlysMarkedForRole[ROLE_DETECTIVE] = {}

		hook.Add("TTTBeginRound", "Admin_Round_Traitor", function()
			if not PlysMarkedForRole[ROLE_TRAITOR] then return end

			for k, v in pairs(PlysMarkedForRole[ROLE_TRAITOR]) do
				if v then
					local ply = player.GetByUniqueID(k)
					ply:SetRole(ROLE_TRAITOR)
					ply:AddCredits(GetConVar("ttt_credits_starting"):GetInt())
					ply:ChatPrint("You have been made a traitor by an admin this round.")

					PlysMarkedForRole[ROLE_TRAITOR][k] = false
				end
			end
		end)

		hook.Add("TTTBeginRound", "Admin_Round_Detective", function()
			if not PlysMarkedForRole[ROLE_DETECTIVE] then return end

			for k, v in pairs(PlysMarkedForRole[ROLE_DETECTIVE]) do
				if v then
					local ply = player.GetByUniqueID(k)
					ply:SetRole(ROLE_DETECTIVE)
					ply:AddCredits(GetConVar("ttt_credits_starting"):GetInt())
					ply:Give("weapon_ttt_wtester")
					ply:ChatPrint("You have been made a detective by an admin this round.")

					PlysMarkedForRole[ROLE_DETECTIVE][k] = false
				end
			end
		end)
	else
		function ulx.hardnextround(calling_ply, target_plys, next_round)
			if GetConVar("gamemode"):GetString() ~= "terrortown" then
				ULib.tsayError(calling_ply, gamemode_error, true)
			else
				local affected_plys = {}

				for i = 1, #target_plys do
					local v = target_plys[i]

					if not roleselection.finalRoles then return end

					if next_round ~= "unmark" then
						local rd = roles.GetByName(next_round)

						if next_round == rd.name and not rd.notSelectable then
							roleselection.finalRoles[v] = rd.index

							table.insert(affected_plys, v)
						end
					else
						if roleselection.finalRoles[v] then
							roleselection.finalRoles[v] = nil

							table.insert(affected_plys, v)
						end
					end
				end

				if next_round == "unmark" then
					ulx.fancyLogAdmin(calling_ply, true, "#A 有硬未标记 #T.", affected_plys)
				else
					ulx.fancyLogAdmin(calling_ply, true, "#A 硬标记 #T 将成为下一轮 #s.", affected_plys, next_round)
				end
			end
		end

		local hnxtr = ulx.command(CATEGORY_NAME, "ulx hardforcenr", ulx.hardnextround, "!hnr")
		hnxtr:addParam{type = ULib.cmds.PlayersArg}
		hnxtr:addParam{type = ULib.cmds.StringArg, completes = ulx.next_round, hint = "下一回合", error = "指定的角色 \"%s\" 无效", ULib.cmds.restrictToCompletes}
		hnxtr:defaultAccess(ULib.ACCESS_SUPERADMIN)
		hnxtr:help("硬强制目标在下一轮成为特殊角色.")
	end
end)

function ulx.nextround(calling_ply, target_plys, next_round)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local affected_plys = {}

		for i = 1, #target_plys do
			local v = target_plys[i]

			if not TTT2 then
				local ID = v:UniqueID()

				PlysMarkedForRole[ROLE_TRAITOR] = PlysMarkedForRole[ROLE_TRAITOR] or {}
				PlysMarkedForRole[ROLE_DETECTIVE] = PlysMarkedForRole[ROLE_DETECTIVE] or {}

				if next_round == "traitor" then
					if PlysMarkedForRole[ROLE_TRAITOR][ID] or PlysMarkedForRole[ROLE_DETECTIVE][ID] then
						ULib.tsayError(calling_ply, "该玩家已被标记为下一轮", true)
					else
						PlysMarkedForRole[ROLE_TRAITOR][ID] = true

						table.insert(affected_plys, v)
					end
				end

				if next_round == "detective" then
					if PlysMarkedForRole[ROLE_TRAITOR][ID] or PlysMarkedForRole[ROLE_DETECTIVE][ID] then
						ULib.tsayError(calling_ply, "该玩家已被标记为下一轮!", true)
					else
						PlysMarkedForRole[ROLE_DETECTIVE][ID] = true

						table.insert(affected_plys, v)
					end
				end

				if next_round == "unmark" then
					if PlysMarkedForRole[ROLE_TRAITOR][ID] then
						PlysMarkedForRole[ROLE_TRAITOR][ID] = false

						table.insert(affected_plys, v)
					end

					if PlysMarkedForRole[ROLE_DETECTIVE][ID] then
						PlysMarkedForRole[ROLE_DETECTIVE][ID] = false

						table.insert(affected_plys, v)
					end
				end
			else
				if not roleselection.forcedRoles then return end

				local sid64 = tostring(v:SteamID64())

				if next_round ~= "unmark" then
					local rd = roles.GetByName(next_round)

					if next_round == rd.name and not rd.notSelectable then
						roleselection.forcedRoles[sid64] = rd.index

						table.insert(affected_plys, v)
					end
				else
					if roleselection.forcedRoles[sid64] then
						roleselection.forcedRoles[sid64] = nil

						table.insert(affected_plys, v)
					end
				end
			end
		end

		if next_round == "unmark" then
			ulx.fancyLogAdmin(calling_ply, true, "#A 没有标记 #T ", affected_plys)
		else
			ulx.fancyLogAdmin(calling_ply, true, "#A 标记为 #T 将成为下一轮 #s.", affected_plys, next_round)
		end
	end
end

local nxtr = ulx.command(CATEGORY_NAME, "ulx forcenr", ulx.nextround, "!nr")
nxtr:addParam{type = ULib.cmds.PlayersArg}
nxtr:addParam{type = ULib.cmds.StringArg, completes = ulx.next_round, hint = "- 设置角色 -", error = "指定的角色 \"%s\" 无效", ULib.cmds.restrictToCompletes}
nxtr:defaultAccess(ULib.ACCESS_SUPERADMIN)
nxtr:help("强制目标在下一轮中成为特殊角色.如果角色是可选的(启用和足够多的玩家),就会发生这种情况.")

---[Identify Corpse Thanks Neku]----------------------------------------------------------------------------
function ulx.identify(calling_ply, target_ply, unidentify)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		body = corpse_find(target_ply)

		if not body then
			ULib.tsayError(calling_ply, "该玩家的尸体不存在!", true)

			return
		end

		if not unidentify then
			ulx.fancyLogAdmin(calling_ply, "#A 识别出 #T 的身体!", target_ply)
			CORPSE.SetFound(body, true)

			target_ply:ConfirmPlayer(true)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 未识别出 #T 的身体!", target_ply)
			CORPSE.SetFound(body, false)

			target_ply:ResetConfirmPlayer()
			target_ply:TTT2NETSetBool("body_found", false)

			SendFullStateUpdate()
		end
	end
end

local identify = ulx.command(CATEGORY_NAME, "ulx identify", ulx.identify, "!identify")
identify:addParam{type = ULib.cmds.PlayerArg}
identify:addParam{type = ULib.cmds.BoolArg, invisible = true}
identify:defaultAccess(ULib.ACCESS_SUPERADMIN)
identify:setOpposite("ulx unidentify", {nil, nil, true}, "!unidentify", true)
identify:help("识别目标的身体.")

---[Remove Corpse Thanks Neku]----------------------------------------------------------------------------
function ulx.removebody(calling_ply, target_ply)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		body = corpse_find(target_ply)

		if not body then
			ULib.tsayError(calling_ply, "该玩家的尸体不存在!", true)

			return
		end

		ulx.fancyLogAdmin(calling_ply, "#A 移除 #T 的身体!", target_ply)

		if string.find(body:GetModel(), "zm_", 6, true) then
			body:Remove()
		elseif body.player_ragdoll then
			body:Remove()
		end
	end
end

local removebody = ulx.command(CATEGORY_NAME, "ulx removebody", ulx.removebody, "!removebody")
removebody:addParam{type = ULib.cmds.PlayerArg}
removebody:defaultAccess(ULib.ACCESS_SUPERADMIN)
removebody:help("移除目标的身体.")

---[Impair Next Round - Concpet and some code from Decicus next round slap]----------------------------------------------------------------------------
function ulx.inr(calling_ply, target_ply, amount)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		local ImpairBy = target_ply:GetPData("ImpairNR", 0)
		local chat_message = ""

		if amount == 0 then
			target_ply:RemovePData("ImpairNR")

			chat_message = "#A 不会损害 #T 下一轮的生命值."
		else
			if amount == ImpairBy then
				ULib.tsayError(calling_ply, calling_ply:Nick() .. " 将已经因该数量的生命值而受损.")
			else
				target_ply:SetPData("ImpairNR", amount)

				chat_message = "#A 将使 #T 受到以下因素的影响 " .. amount .. " 生命值下一轮."
			end
		end

		ulx.fancyLogAdmin(calling_ply, chat_message, target_ply)
	end
end

local impair = ulx.command(CATEGORY_NAME, "ulx impairnr", ulx.inr, "!impairnr")
impair:addParam{type = ULib.cmds.PlayerArg}
impair:addParam{type = ULib.cmds.NumArg, min = 0, max = 99, default = 5, hint = "要移除的生命值.", ULib.cmds.optional, ULib.cmds.round}
impair:defaultAccess(ULib.ACCESS_ADMIN)
impair:help("在下一轮削弱目标的生命值.设置为 0 以消除损伤")

---[impair Next Round Helper Functions]----------------------------------------------------------------------------

hook.Add("PlayerSpawn", "InformImpair", function(ply)
	local ImpairDamage = tonumber(ply:GetPData("ImpairNR")) or 0

	if ply:Alive() and ImpairDamage > 0 then
		local chat_message = ""

		if ImpairDamage > 0 then
			chat_message = (chat_message .. "你会受到损害 " .. ImpairDamage .. " 本轮生命值")
		end

		ply:ChatPrint(chat_message)
	end
end)

function ImpairPlayers()
	for _, ply in ipairs(player.GetAll()) do
		local impairDamage = tonumber(ply:GetPData("ImpairNR")) or 0

		if ply:Alive() and impairDamage > 0 then
			local name = ply:Nick()

			ply:TakeDamage(impairDamage)
			ply:EmitSound("player/pl_pain5.wav")
			ply:ChatPrint("You have been impaird by " .. impairDamage .. " health this round")
			ply:RemovePData("ImpairNR")

			ULib.tsay(nil, name .. " 受到损害 " .. impairDamage .. " 本轮生命值.", false)
		end
	end
end
hook.Add("TTTBeginRound", "ImpairPlayers", ImpairPlayers)

---[Round Restart]-------------------------------------------------------------------------
function ulx.roundrestart(calling_ply)
	if GetConVar("gamemode"):GetString() ~= "terrortown" then
		ULib.tsayError(calling_ply, gamemode_error, true)
	else
		ULib.consoleCommand("ttt_roundrestart" .. "\n")
		ulx.fancyLogAdmin(calling_ply, "#A 重新开始了这一轮.")
	end
end

local restartround = ulx.command(CATEGORY_NAME, "ulx roundrestart", ulx.roundrestart)
restartround:defaultAccess(ULib.ACCESS_SUPERADMIN)
restartround:help("重新开始回合.")
---[End]----------------------------------------------------------------------------------------

-- update roles table
hook.Add("TTT2RolesLoaded", "TTT2UlxSync", function()
	if TTT2 then
		table.Empty(ulx.rolesTbl)

		for _, v in pairs(GetSortedRoles()) do
			if not v.notSelectable then
				table.insert(ulx.rolesTbl, v.name)
			end
		end

		updateRoles()
		updateNextround()
	end
end)
