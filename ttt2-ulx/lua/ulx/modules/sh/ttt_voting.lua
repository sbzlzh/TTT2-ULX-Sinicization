--[[--------------------------------------------------------------------------------------------
�                              Trouble in Terrorist Town Commands                              �
�                               By: Skillz, Bender180 and Alf21                                �
�                              +---------++---------++---------+                               �
�                              � +-+ +-+ �� +-+ +-+ �� +-+ +-+ �                               �
�                              +-+ � � +-++-+ � � +-++-+ � � +-+                               �
�----------------------------------� �--------� �--------� �-----------------------------------�
�----------------------------------� �--------� �--------� �-----------------------------------�
�----------------------------------+-+--------+-+--------+-+-----------------------------------�
�                  All code included is completely original or extracted                       �
�            from the base ttt files that are provided with the ttt gamemode.                  �
�                                                                                              �
----------------------------------------------------------------------------------------------]]
local CATEGORY_NAME = "TTT 投票"
local gamemode_error = "The current gamemode is not trouble in terrorest town"


---[Next Round Slay Voting]----------------------------------------------------------------------------

local function voteslaynrDone2(t, target, time, ply, reason)
	local shouldslaynr = false

	if t.results[1] and t.results[1] > 0 then
		shouldslaynr = true

		if reason then
			ulx.fancyLogAdmin(ply, "#A 将允许 #T 在下一轮被杀死 (#s)", target, reason)
		else
			ulx.fancyLogAdmin(ply, "#A 将允许 #T 在下一轮被杀死", target)
		end
	else
		ulx.fancyLogAdmin(ply, "#A 将不允许在下一轮杀死 #T", target)
	end

	if shouldslaynr then
		if GetConVar("gamemode"):GetString() ~= "terrortown" then
			ULib.tsayError(ply, gamemode_error, true)
		else
			--local target_ply = target:Nick()
			--ULib.consoleCommand("ulx slaynr " ..target:Nick().. "\n") --has issue with players with spaces in name
			--going to write to pdata directly for more streamlined look

			local eslays = target:GetPData("slaynr_slays", 0) --get existing slays or 0
			local nslays

			nslays = eslays + 1 --add the vote slay to the existing slays

			target:SetPData("slaynr_slays", nslays) --add the new slays
			--heavy lifting will be done by existing slaynr command

			target:ChatPrint("Based on a vote, you will be slain next round")
		end
	end
end

local function voteslaynrDone(t, target, time, ply, reason)
	local results = t.results
	local winner
	local winnernum = 0

	for id, numvotes in pairs(results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVar("ulx_voteslaynrSuccessratio"):GetInt()
	local minVotes = GetConVar("ulx_voteslaynrMinvotes"):GetInt()
	local str

	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "投票结果:用户将在下一轮存活. (" .. (results[1] or "0") .. "/" .. t.voters .. ")"
	else
		str = "投票结果:用户将在下一轮被杀死,等待批准. (" .. winnernum .. "/" .. t.voters .. ")"

		ulx.doVote("接受结果并杀死 " .. target:Nick() .. "?", {"是", "否"}, voteslaynrDone2, 30000, {ply}, true, target, time, ply, reason)
	end

	ULib.tsay(_, str) -- TODO, color?
	ulx.logString(str)

	if game.IsDedicated() then
		Msg(str .. "\n")
	end
end

function ulx.voteslaynr(calling_ply, target_ply, reason)
	if voteInProgress then
		ULib.tsayError(calling_ply, "已经有投票正在进行中.请等待当前的结束.", true)

		return
	end

	local msg = "杀死 " .. target_ply:Nick() .. " 下一回合?"

	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote(msg, {"是", "否"}, voteslaynrDone, nil, nil, nil, target_ply, nil, calling_ply, reason)
	ulx.fancyLogAdmin(calling_ply, "#A 想在下一轮杀死 #T", target_ply)
end

local voteslaynr = ulx.command(CATEGORY_NAME, "ulx votesnr", ulx.voteslaynr, "!votesnr")
voteslaynr:addParam{type = ULib.cmds.PlayerArg}
voteslaynr:addParam{type = ULib.cmds.StringArg, hint = "原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
voteslaynr:defaultAccess(ULib.ACCESS_ADMIN)
voteslaynr:help("开始投票以在下一轮杀死目标.")

if SERVER then
	ulx.convar("voteslaynrSuccessratio", "0.6", nil, ULib.ACCESS_ADMIN) -- The ratio needed for a voteslaynr to succeed
end

if SERVER then
	ulx.convar("voteslaynrMinvotes", "1", nil, ULib.ACCESS_ADMIN) -- Minimum votes needed for voteslaynr
end

---[Spectator Voting]----------------------------------------------------------------------------
local function votefsDone2(t, target, time, ply, reason)
	local shouldfs = false

	if t.results[1] and t.results[1] > 0 then
		shouldfs = true

		ulx.fancyLogAdmin(ply, "#A 将允许 #T 被迫旁观.", target)
	else
		ulx.fancyLogAdmin(ply, "#A 不允许 #T 被迫旁观.", target)
	end

	if shouldfs then
		if GetConVar("gamemode"):GetString() ~= "terrortown" then
			ULib.tsayError(ply, gamemode_error, true)
		else
			target:ConCommand("ttt_spectator_mode 1")
			target:ConCommand("ttt_cl_idlepopup")
		end
	end
end

local function votefsDone(t, target, time, ply, reason)
	local results = t.results
	local winner
	local winnernum = 0

	for id, numvotes in pairs(results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVar("ulx_votefsSuccessratio"):GetInt()
	local minVotes = GetConVar("ulx_votefsMinvotes"):GetInt()
	local str

	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "投票结果:用户将被发送到观众. (" .. (results[1] or "0") .. "/" .. t.voters .. ")"
	else
		str = "投票结果:用户将被发送给旁观者,等待批准. (" .. winnernum .. "/" .. t.voters .. ")"

		ulx.doVote("接受结果并发送 " .. target:Nick() .. " 对观众?", {"是", "否"}, votefsDone2, 30000, {ply}, true, target, time, ply, reason)
	end

	ULib.tsay(nil, str) -- TODO, color?
	ulx.logString(str)

	if game.IsDedicated() then
		Msg(str .. "\n")
	end
end

function ulx.votefs(calling_ply, target_ply, reason)
	if voteInProgress then
		ULib.tsayError(calling_ply, "已经有投票正在进行中.请等待当前的结束.", true)

		return
	end

	local msg = "强迫 " .. target_ply:Nick() .. " 到旁观者?"

	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote(msg, {"是", "否"}, votefsDone, nil, nil, nil, target_ply, time, calling_ply, reason)
	ulx.fancyLogAdmin(calling_ply, "#A 想让 #T 成为旁观者.", target_ply)
end

local votefs = ulx.command(CATEGORY_NAME, "ulx votefs", ulx.votefs, "!votefs")
votefs:addParam{type = ULib.cmds.PlayerArg}
votefs:addParam{type = ULib.cmds.StringArg, hint = "原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
votefs:defaultAccess(ULib.ACCESS_ADMIN)
votefs:help("开始投票让目标强制进入旁观者模式.")

if SERVER then
	ulx.convar("votefsSuccessratio", "0.6", nil, ULib.ACCESS_ADMIN) -- The ratio needed for a votefs to succeed
end

if SERVER then
	ulx.convar("votefsMinvotes", "1", nil, ULib.ACCESS_ADMIN) -- Minimum votes needed for votefs
end
