local debugFix = CreateConVar("TTT2DebugUlibReplicatedWritableCvarStackTrace", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "如果激活,当'ULib.replicatedWritableCvar'被使用而没有一个字符串作为default_value时,会打印出调试堆栈跟踪.")

local oldreplicatedWritableCvar = ULib.replicatedWritableCvar

ULib.replicatedWritableCvar = function(sv_cvar, cl_cvar, default_value, save, notify, access)
	-- Make sure that default_value is a string
	if not isstring(default_value) then

		default_value = tostring(default_value)

		if debugFix:GetBool() then
			ErrorNoHaltWithStack("[ULIB] Failed to use arg[3] = default_value of ConVar " .. sv_cvar)
		end
	end

	oldreplicatedWritableCvar(sv_cvar, cl_cvar, default_value, save, notify, access)
end
