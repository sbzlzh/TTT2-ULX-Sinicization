-- Terrortown settings module for ULX GUI
ULX_DYNAMIC_RCVARS = {}

hook.Run("TTTUlxDynamicRCVars", ULX_DYNAMIC_RCVARS)

-- 默认ines ttt cvar limits and ttt specific settings for the ttt gamemode.

local terrortown_settings = xlib.makepanel{parent = xgui.null}

xlib.makelabel{
	x = 5,
	y = 5,
	w = 600,
	wordwrap = true,
	label = "恐怖小镇2 ULX命令 XGUI模块 创建者:Bender180(由Alf21修改并且由随波逐流汉化)",
	parent = terrortown_settings
}

xlib.makelabel{
	x = 2,
	y = 345,
	w = 600,
	wordwrap = true,
	label = "上面的设置将保存.所以在编辑它们时要注意!",
	parent = terrortown_settings
}

xlib.makelabel{
	x = 5,
	y = 190,
	w = 160,
	wordwrap = true,
	label = "服务器所有者注意: 限制此面板允许或拒绝对 xgui_gmsettings 的权限.",
	parent = terrortown_settings
}

xlib.makelabel{
	x = 5,
	y = 250,
	w = 160,
	wordwrap = true,
	label = "列出的所有设置都在此处说明: http://ttt.badking.net/config- and-commands/convars",
	parent = terrortown_settings
}

xlib.makelabel{
	x = 5,
	y = 325,
	w = 160,
	wordwrap = true,
	label = "并非所有设置都响应聊天.",
	parent = terrortown_settings
}

terrortown_settings.panel = xlib.makepanel{
	x = 160,
	y = 25,
	w = 420,
	h = 318,
	parent = terrortown_settings
}

terrortown_settings.catList = xlib.makelistview{
	x = 5,
	y = 25,
	w = 150,
	h = 157,
	parent = terrortown_settings
}

terrortown_settings.catList:AddColumn("恐怖小镇2设置")

terrortown_settings.catList.Columns[1].DoClick = function()

end

terrortown_settings.catList.OnRowSelected = function(self, LineID, Line)
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel

	if nPanel ~= terrortown_settings.curPanel then
		nPanel:SetZPos(0)

		xlib.addToAnimQueue("pnlSlide", {
			panel = nPanel,
			startx = -435,
			starty = 0,
			endx = 0,
			endy = 0,
			setvisible = true
		})

		if terrortown_settings.curPanel then
			terrortown_settings.curPanel:SetZPos(-1)
			xlib.addToAnimQueue(terrortown_settings.curPanel.SetVisible, terrortown_settings.curPanel, false)
		end

		xlib.animQueue_start()

		terrortown_settings.curPanel = nPanel
	else
		xlib.addToAnimQueue("pnlSlide", {
			panel = nPanel,
			startx = 0,
			starty = 0,
			endx = -435,
			endy = 0,
			setvisible = false
		})
		self:ClearSelection()

		terrortown_settings.curPanel = nil

		xlib.animQueue_start()
	end

	-- If the panel has it, call a function when it's opened
	if nPanel.onOpen then
		nPanel.onOpen()
	end
end

-- Process modular settings
function terrortown_settings.processModules()
	terrortown_settings.catList:Clear()

	for i, module in ipairs(xgui.modules.submodule) do
		if module.mtype == "terrortown_settings" and (not module.access or LocalPlayer():query(module.access)) then
			local w, h = module.panel:GetSize()

			if w == h and h == 0 then
				module.panel:SetSize(275, 322)
			end

			if module.panel.scroll then --For DListLayouts
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
			end

			module.panel:SetParent(terrortown_settings.panel)

			local line = terrortown_settings.catList:AddLine(module.name, i)

			if module.panel == terrortown_settings.curPanel then
				terrortown_settings.curPanel = nil
				terrortown_settings.catList:SelectItem(line)
			else
				module.panel:SetVisible(false)
			end
		end
	end

	terrortown_settings.catList:SortByColumn(1, false)
end
terrortown_settings.processModules()

xgui.hookEvent("onProcessModules", nil, terrortown_settings.processModules)
xgui.addModule("TTT2设定", terrortown_settings, "icon16/ttt.png", "xgui_gmsettings")

-----------------------------------------------------------------
-------------------- MODULE: ROUND STRUCTURE --------------------
-----------------------------------------------------------------

local rspnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

-- SUBMODULE: Preparation and post-round
local rspapclp = vgui.Create("DCollapsibleCategory", rspnl)
rspapclp:SetSize(390, 95)
rspapclp:SetExpanded(1)
rspapclp:SetLabel("准备和赛后")

local rspaplst = vgui.Create("DPanelList", rspapclp)
rspaplst:SetPos(5, 25)
rspaplst:SetSize(390, 95)
rspaplst:SetSpacing(5)

rspaplst:AddItem(xlib.makeslider{
	label = "准备阶段时间 (默认. 30)",
	min = 1,
	max = 120,
	repconvar = "rep_ttt_preptime_seconds",
	parent = rspaplst
})

rspaplst:AddItem(xlib.makeslider{
	label = "第一轮准备阶段的时间 (默认. 60)",
	min = 1,
	max = 120,
	repconvar = "rep_ttt_firstpreptime",
	parent = rspaplst
})

rspaplst:AddItem(xlib.makeslider{
	label = "回合结束时间 (默认. 30)",
	min = 1,
	max = 120,
	repconvar = "rep_ttt_posttime_seconds",
	parent = rspaplst
})

rspaplst:AddItem(xlib.makecheckbox{
	label = "准备阶段重生 (默认. 0)",
	repconvar = "rep_ttt2_prep_respawn",
	parent = rsrllst
})

-- SUBMODULE: Round length
local rsrlclp = vgui.Create("DCollapsibleCategory", rspnl)
rsrlclp:SetSize(390, 90)
rsrlclp:SetExpanded(0)
rsrlclp:SetLabel("回合时间")

local rsrl = vgui.Create("DPanelList", rsrlclp)
rsrl:SetPos(5, 25)
rsrl:SetSize(390, 90)
rsrl:SetSpacing(5)

rsrl:AddItem(xlib.makecheckbox{
	label = "急速模式",
	repconvar = "rep_ttt_haste",
	parent = rsrl
})

rsrl:AddItem(xlib.makeslider{
	label = "急速模式设置时间 (默认. 5)",
	min = 1,
	max = 60,
	repconvar = "rep_ttt_haste_starting_minutes",
	parent = rsrl
})

rsrl:AddItem(xlib.makeslider{
	label = "每次死亡的回合设置时间 (默认. 0.5)",
	min = 0.1,
	max = 9,
	decimal = 1,
	repconvar = "rep_ttt_haste_minutes_per_death",
	parent = rsrl
})

rsrl:AddItem(xlib.makeslider{
	label = "每轮的时间限制 (默认. 10)",
	min = 1,
	max = 60,
	repconvar = "rep_ttt_roundtime_minutes",
	parent = rsrl
})

-- SUBMODULE: Map switching and voting
local msavclp = vgui.Create("DCollapsibleCategory", rspnl)
msavclp:SetSize(390, 95)
msavclp:SetExpanded(0)
msavclp:SetLabel("地图切换和投票")

local msavlst = vgui.Create("DPanelList", msavclp)
msavlst:SetPos(5, 25)
msavlst:SetSize(390, 95)
msavlst:SetSpacing(5)

msavlst:AddItem(xlib.makeslider{
	label = "切换地图前的最大回合数 (默认. 6)",
	min = 1,
	max = 100,
	repconvar = "rep_ttt_round_limit",
	parent = msavlst
})

msavlst:AddItem(xlib.makeslider{
	label = "地图切换前的最大分钟数 (默认. 75)",
	min = 1,
	max = 150,
	repconvar = "rep_ttt_time_limit_minutes",
	parent = msavlst
})

msavlst:AddItem(xlib.makecheckbox{
	label = "地图投票系统 (默认. 0)",
	repconvar = "rep_ttt_always_use_mapcycle",
	parent = msavlst
})

msavlst:AddItem(xlib.makelabel{
	wordwrap = true,
	label = "这什么都不做,但因为它包含在TTT中,所以它在这里.",
	parent = msavlst
})

xgui.hookEvent("onProcessModules", nil, rspnl.processModules)
xgui.addSubModule("回合结构", rspnl, nil, "terrortown_settings")

-------------------------------------------------------
-------------------- MODULE: ROLES --------------------
-------------------------------------------------------

local rolepnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local b = true

for _, v in pairs(GetSortedRoles()) do
	if v == INNOCENT then
		local size = 45

		local gptdcclp = vgui.Create("DCollapsibleCategory", rolepnl)
		gptdcclp:SetSize(390, size)
		gptdcclp:SetExpanded(b and 1 or 0)
		gptdcclp:SetLabel("" .. v.name)

		b = false

		local gptdlst = vgui.Create("DPanelList", gptdcclp)
		gptdlst:SetPos(5, 25)
		gptdlst:SetSize(390, size)
		gptdlst:SetSpacing(5)

		gptdlst:AddItem(xlib.makeslider{
			label = "将成为平民的玩家总数的百分比",
			min = 0.01,
			max = 1,
			decimal = 2,
			repconvar = "rep_ttt_min_inno_pct",
			parent = gptdlst
		})

		gptdlst:AddItem(xlib.makecheckbox{
			label = "是否启用平民成为叛徒一队",
			repconvar = "rep_ttt_" .. v.name .. "_traitor_button",
			parent = gptdlst
		})
	else
		local tmp = 0

		if ULX_DYNAMIC_RCVARS[v.index] then
			for _, cvar in pairs(ULX_DYNAMIC_RCVARS[v.index]) do
				if cvar.slider then
					tmp = tmp + 25
				end

				if cvar.checkbox then
					tmp = tmp + 20
				end

				if cvar.combobox then
					tmp = tmp + 30

					if cvar.desc then
						tmp = tmp + 13
					end
				end

				if cvar.label then
					tmp = tmp + 13
				end
			end
		end

		if not v.notSelectable or tmp > 0 then
			local size = not v.notSelectable and 70 or 0

			if not v.notSelectable and v ~= TRAITOR then
				size = size + 50

				if v ~= TRAITOR then
					size = size + 25
				end
			end

			size = size + tmp

			local gptdcclp = vgui.Create("DCollapsibleCategory", rolepnl)
			gptdcclp:SetSize(390, size)
			gptdcclp:SetExpanded(b and 1 or 0)
			gptdcclp:SetLabel("" .. v.name)

			b = false

			local gptdlst = vgui.Create("DPanelList", gptdcclp)
			gptdlst:SetPos(5, 25)
			gptdlst:SetSize(390, size)
			gptdlst:SetSpacing(5)

			if not v.notSelectable then
				gptdlst:AddItem(xlib.makeslider{
					label = "成为" .. v.name .. "的玩家总数的百分比",
					min = 0.01,
					max = 1,
					decimal = 2,
					repconvar = "rep_ttt_" .. v.name .. "_pct",
					parent = gptdlst
				})

				gptdlst:AddItem(xlib.makeslider{
					label = "成为" .. v.name .. "的最大数量",
					min = 1,
					max = 64,
					repconvar = "rep_ttt_" .. v.name .. "_max",
					parent = gptdlst
				})

				if v ~= TRAITOR then
					gptdlst:AddItem(xlib.makeslider{
						label = "成为" .. v.name .. "的概率",
						min = 1,
						max = 100,
						repconvar = "rep_ttt_" .. v.name .. "_random",
						parent = gptdlst
					})

					gptdlst:AddItem(xlib.makeslider{
						label = "成为" .. v.name .. "的最少玩家人数",
						min = 1,
						max = 64,
						repconvar = "rep_ttt_" .. v.name .. "_min_players",
						parent = gptdlst
					})

					if ConVarExists("rep_ttt_" .. v.name .. "_karma_min") then
						gptdlst:AddItem(xlib.makeslider{
							label = "成为" .. v.name .. "的最低人品",
							min = 1,
							max = 1000,
							repconvar = "rep_ttt_" .. v.name .. "_karma_min",
							parent = gptdlst
						})
					end

					gptdlst:AddItem(xlib.makecheckbox{
						label = "是否启用" .. v.name .. "角色 (默认. 1)",
						repconvar = "rep_ttt_" .. v.name .. "_enabled",
						parent = gptdlst
					})
				end

				gptdlst:AddItem(xlib.makecheckbox{
					label = "是否启用成为叛徒一队",
					repconvar = "rep_ttt_" .. v.name .. "_traitor_button",
					parent = gptdlst
				})
			end

			if tmp > 0 then
				for _, cvar in pairs(ULX_DYNAMIC_RCVARS[v.index]) do
					if cvar.checkbox then
						gptdlst:AddItem(xlib.makecheckbox{
							label = v.name .. ": " .. cvar.desc,
							repconvar = "rep_" .. cvar.cvar,
							parent = gptdlst
						})
					elseif cvar.slider then
						gptdlst:AddItem(xlib.makeslider{
							label = v.name .. ": " .. (cvar.desc or cvar.cvar),
							min = cvar.min or 1,
							max = cvar.max or 1000,
							decimal = cvar.decimal or 0,
							repconvar = "rep_" .. cvar.cvar,
							parent = gptdlst
						})
					elseif cvar.combobox then
						if cvar.desc then
							gptdlst:AddItem(xlib.makelabel{
								label = v.name .. ": " .. (cvar.desc or cvar.cvar),
								parent = gptdlst
							})
						end

						gptdlst:AddItem(xlib.makecombobox{
							enableinput = cvar.enableinput or false,
							choices = cvar.choices,
							isNumberConvar = true,
							repconvar = "rep_" .. cvar.cvar,
							numOffset = (-1) * (cvar.numStart or 0) + 1,
							parent = gptdlst
						})
					elseif cvar.label then
						gptdlst:AddItem(xlib.makelabel{
							label = cvar.desc,
							parent = gptdlst
						})
					end
				end
			end
		end
	end
end

hook.Run("TTTUlxModifyGameplaySettings", rolepnl)

xgui.hookEvent("onProcessModules", nil, rolepnl.processModules)
xgui.addSubModule("角色", rolepnl, nil, "terrortown_settings")

----------------------------------------------------------
-------------------- MODULE: GAMEPLAY --------------------
----------------------------------------------------------

local gppnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

-- SUBMODULE: DNA
local gpdnaclp = vgui.Create("DCollapsibleCategory", gppnl)
gpdnaclp:SetSize(390, 120)
gpdnaclp:SetExpanded(1)
gpdnaclp:SetLabel("DNA")

local gpdnalst = vgui.Create("DPanelList", gpdnaclp)
gpdnalst:SetPos(5, 25)
gpdnalst:SetSize(390, 120)
gpdnalst:SetSpacing(5)

gpdnalst:AddItem(xlib.makeslider{
	label = "杀手的DNA最大范围 (默认. 550)",
	min = 100,
	max = 1000,
	repconvar = "rep_ttt_killer_dna_range",
	parent = gpdnalst
})

gpdnalst:AddItem(xlib.makeslider{
	label = "杀手的DNA样本时间 (默认. 100)",
	min = 10,
	max = 200,
	repconvar = "rep_ttt_killer_dna_basetime",
	parent = gpdnalst
})

gpdnalst:AddItem(xlib.makecheckbox{
	label = "DNA雷达 (默认. 0)",
	repconvar = "rep_ttt2_dna_radar",
	parent = gpdnalst
})

gpdnalst:AddItem(xlib.makeslider{
	label = "DNA雷达冷却 (默认. 5.0)",
	min = 0,
	max = 60,
	decimal = 1,
	repconvar = "rep_ttt2_dna_radar_cooldown",
	parent = gpdnalst
})

gpdnalst:AddItem(xlib.makeslider{
	label = "DNA插槽 (默认. 4)",
	min = 1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_dna_scanner_slots",
	parent = gpdnalst
})

-- SUBMODULE: Radar
local gpradarclp = vgui.Create("DCollapsibleCategory", gppnl)
gpradarclp:SetSize(390, 25)
gpradarclp:SetExpanded(0)
gpradarclp:SetLabel("雷达")

local gpradarlst = vgui.Create("DPanelList", gpradarclp)
gpradarlst:SetPos(5, 25)
gpradarlst:SetSize(390, 25)
gpradarlst:SetSpacing(5)

gpradarlst:AddItem(xlib.makeslider{
	label = "雷达冷却时间 (默认. 30)",
	min = 1,
	max = 60,
	decimal = 0,
	repconvar = "rep_ttt2_radar_charge_time",
	parent = gpradarlst
})

-- SUBMODULE: Voicechat battery
local gpvcbclp = vgui.Create("DCollapsibleCategory", gppnl)
gpvcbclp:SetSize(390, 90)
gpvcbclp:SetExpanded(0)
gpvcbclp:SetLabel("语音聊天电池")

local gpvcblst = vgui.Create("DPanelList", gpvcbclp)
gpvcblst:SetPos(5, 25)
gpvcblst:SetSize(390, 90)
gpvcblst:SetSpacing(5)

gpvcblst:AddItem(xlib.makecheckbox{
	label = "是否启用语音聊天电池功能 (默认. 0)",
	repconvar = "rep_ttt_voice_drain",
	parent = gpvcblst
})

gpvcblst:AddItem(xlib.makeslider{
	label = "消耗电池电量 (默认. 0.2)",
	min = 0.1,
	max = 1,
	decimal = 1,
	repconvar = "rep_ttt_voice_drain_normal",
	parent = gpvcblst
})

gpvcblst:AddItem(xlib.makeslider{
	label = "管理员和侦探的语音聊天电量 (默认. 0.05)",
	min = 0.01,
	max = 1,
	decimal = 2,
	repconvar = "rep_ttt_voice_drain_admin",
	parent = gpvcblst
})

gpvcblst:AddItem(xlib.makeslider{
	label = "不语音聊天时每滴答的电池充电率 (默认. 0.05)",
	min = 0.01,
	max = 1,
	decimal = 2,
	repconvar = "rep_ttt_voice_drain_recharge",
	parent = gpvcblst
})


-- SUBMODULE: Dead Player Settings
local gpdpsclp = vgui.Create("DCollapsibleCategory", gppnl)
gpdpsclp:SetSize(390, 160)
gpdpsclp:SetExpanded(0)
gpdpsclp:SetLabel("死亡玩家设置")

local gpdpslst = vgui.Create("DPanelList", gpdpsclp)
gpdpslst:SetPos(5, 25)
gpdpslst:SetSize(390, 160)
gpdpslst:SetSpacing(5)

gpdpslst:AddItem(xlib.makecheckbox{
	label = "布娃娃定住 (默认. 1)",
	repconvar = "rep_ttt_ragdoll_pinning",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "布娃娃固定无辜者 (默认. 0)",
	repconvar = "rep_ttt_ragdoll_pinning_innocents",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "身份验证 (默认. 1)",
	repconvar = "rep_ttt_identify_body_woconfirm",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "宣布发现尸体 (默认. 1)",
	repconvar = "rep_ttt_announce_body_found",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "限制观众聊天 (默认. 1)",
	repconvar = "rep_ttt_limit_spectator_chat",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "最后的话聊天打印 (默认. 0)",
	repconvar = "rep_ttt_lastwords_chatprint",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "仅确认侦探 (默认. 0)",
	repconvar = "rep_ttt2_confirm_detective_only",
	parent = gpdpslst
})

gpdpslst:AddItem(xlib.makecheckbox{
	label = "仅探长检测 (默认. 0)",
	repconvar = "rep_ttt2_inspect_detective_only",
	parent = gpdpslst
})

-- SUBMODULE: Other Gameplay Settings
local gpogsclp = vgui.Create("DCollapsibleCategory", gppnl)
gpogsclp:SetSize(390, 290)
gpogsclp:SetExpanded(0)
gpogsclp:SetLabel("其他游戏设置")

local gpogslst = vgui.Create("DPanelList", gpogsclp)
gpogslst:SetPos(5, 25)
gpogslst:SetSize(390, 290)
gpogslst:SetSpacing(5)

gpogslst:AddItem(xlib.makecheckbox{
	label = "新角色是否启用 (默认. 1)",
	repconvar = "rep_ttt_newroles_enabled",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "最大角色 (默认. 0)",
	min = 0,
	max = 64,
	repconvar = "rep_ttt_max_roles",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "最大角色百分比 (默认. 0)",
	min = 0,
	max = 1,
	decimal = 2,
	repconvar = "rep_ttt_max_roles_pct",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "最大基本角色 (默认. 0)",
	min = 0,
	max = 64,
	repconvar = "rep_ttt_max_baseroles",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "最大基本角色百分比 (默认. 0)",
	min = 0,
	max = 1,
	decimal = 2,
	repconvar = "rep_ttt_max_baseroles_pct",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "玩家人数 (默认. 2)",
	min = 1,
	max = 64,
	repconvar = "rep_ttt_minimum_players",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "结束后伤害 (默认. 0)",
	repconvar = "rep_ttt_postround_dm",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "垂死挣扎 (默认. 0)",
	repconvar = "rep_ttt_dyingshot",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "准备阶段投掷手榴弹 (默认. 0)",
	repconvar = "rep_ttt_no_nade_throw_during_prep",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "使用磁棒携带武器 (默认. 1)",
	repconvar = "rep_ttt_weapon_carrying",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makeslider{
	label = "携带磁棒的范围 (默认. 50)",
	min = 10,
	max = 100,
	repconvar = "rep_ttt_weapon_carrying_range",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "杀死站在传送目的地的玩家 (默认. 0)",
	repconvar = "rep_ttt_teleport_telefrags",
	parent = gpogslst
})

gpogslst:AddItem(xlib.makecheckbox{
	label = "闲置状态警告 (默认. 1)",
	repconvar = "rep_ttt_idle",
	parent = gpogslst
})

xgui.hookEvent("onProcessModules", nil, gppnl.processModules)
xgui.addSubModule("游戏玩法", gppnl, nil, "terrortown_settings")


-------------------------------------------------------------------
-------------------- MODULE: TTT2 HUD SETTINGS --------------------
-------------------------------------------------------------------

if hudelements then
	local clspnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

	for _, elem in ipairs(hudelements.GetList()) do
		if elem.togglable then
			local clsclp2 = vgui.Create("DCollapsibleCategory", clspnl)
			clsclp2:SetSize(390, 25)
			clsclp2:SetExpanded(0)
			clsclp2:SetLabel(elem.id)

			local clslst2 = vgui.Create("DPanelList", clsclp2)
			clslst2:SetPos(5, 25)
			clslst2:SetSize(390, 25)
			clslst2:SetSpacing(5)

			clslst2:AddItem(xlib.makecheckbox{
				label = "切换 '" .. elem.id .. "'?",
				repconvar = "rep_ttt2_elem_toggled_" .. elem.id,
				parent = clslst2
			})
		end
	end

	xgui.hookEvent("onProcessModules", nil, clspnl.processModules)
	xgui.addSubModule("恐怖小镇2 HUD设置", clspnl, nil, "terrortown_settings")
end

-------------------------------------------------------
-------------------- MODULE: KARMA --------------------
-------------------------------------------------------

local krmpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local krmclp = vgui.Create("DCollapsibleCategory", krmpnl)
krmclp:SetSize(390, 400)
krmclp:SetExpanded(1)
krmclp:SetLabel("业力")

local krmlst = vgui.Create("DPanelList", krmclp)
krmlst:SetPos(5, 25)
krmlst:SetSize(390, 400)
krmlst:SetSpacing(5)

krmlst:AddItem(xlib.makecheckbox{
	label = "业力系统",
	repconvar = "rep_ttt_karma",
	parent = krmlst
})

krmlst:AddItem(xlib.makecheckbox{
	label = "伤害惩罚系统",
	repconvar = "rep_ttt_karma_strict",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "业力值初始值 (默认. 1000)",
	min = 500,
	max = 2000,
	repconvar = "rep_ttt_karma_starting",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "最大业力值 (默认. 1000)",
	min = 500,
	max = 2000,
	repconvar = "rep_ttt_karma_max",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "业力值损害比率设置 (默认. 0.001)",
	min = 0.001,
	max = 0.009,
	decimal = 3,
	repconvar = "rep_ttt_karma_ratio",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "杀戮惩罚 (默认. 15)",
	min = 1,
	max = 30,
	repconvar = "rep_ttt_karma_kill_penalty",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "每轮结束基础数量 (默认. 5)",
	min = 1,
	max = 30,
	repconvar = "rep_ttt_karma_round_increment",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "额外治愈 (默认. 30)",
	min = 10,
	max = 100,
	repconvar = "rep_ttt_karma_clean_bonus",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "伤害叛徒的业力奖励 (默认. 0.0003)",
	min = 0.0001,
	max = 0.001,
	decimal = 4,
	repconvar = "rep_ttt_karma_traitordmg_ratio",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "杀死叛徒的额外业力 (默认. 40)",
	min = 10,
	max = 100,
	repconvar = "rep_ttt_karma_traitorkill_bonus",
	parent = krmlst
})

krmlst:AddItem(xlib.makecheckbox{
	label = "回合结束时自动踢出低业力等级的玩家 (默认. 1)",
	repconvar = "rep_ttt_karma_low_autokick",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "玩家被踢的业力阈值 (默认. 450)",
	min = 100,
	max = 1000,
	repconvar = "rep_ttt_karma_low_amount",
	parent = krmlst
})

krmlst:AddItem(xlib.makecheckbox{
	label = "低业力值封禁 (默认. 1)",
	repconvar = "rep_ttt_karma_low_ban",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "封禁业力值最低的玩家时间 (默认. 60)",
	min = 10,
	max = 100,
	repconvar = "rep_ttt_karma_low_ban_minutes",
	parent = krmlst
})

krmlst:AddItem(xlib.makecheckbox{
	label = "业力值持久存储 (默认. 0)",
	repconvar = "rep_ttt_karma_persist",
	parent = krmlst
})

krmlst:AddItem(xlib.makecheckbox{
	label = "调试业力变化到控制台 (默认. 0)",
	repconvar = "rep_ttt_karma_debugspam",
	parent = krmlst
})

krmlst:AddItem(xlib.makeslider{
	label = "业力起始水平 (默认. 0.25)",
	min = 0.01,
	max = 0.9,
	decimal = 2,
	repconvar = "rep_ttt_karma_clean_half",
	parent = krmlst
})

xgui.hookEvent("onProcessModules", nil, krmpnl.processModules)
xgui.addSubModule("业力", krmpnl, nil, "terrortown_settings")

-------------------------------------------------------------
-------------------- MODULE: MAP RELATED --------------------
-------------------------------------------------------------

local mprpnl = xlib.makepanel{w = 415, h = 318, parent = xgui.null}

local mapclp = vgui.Create("DCollapsibleCategory", mprpnl)
mapclp:SetSize(390, 400)
mapclp:SetExpanded(1)
mapclp:SetLabel("地图相关")

local maplst = vgui.Create("DPanelList", mapclp)
maplst:SetPos(5, 25)
maplst:SetSize(390, 400)
maplst:SetSpacing(5)

maplst:AddItem(xlib.makecheckbox{
	label = "切换是否使用武器脚本 (默认. 1)",
	repconvar = "rep_ttt_use_weapon_spawn_scripts",
	parent = maplst
})

maplst:AddItem(xlib.makeslider{
	label = "武器生成数 (默认. 0)",
	min = 0,
	max = 100,
	decimal = 0,
	repconvar = "rep_ttt_weapon_spawn_count",
	parent = maplst
})

xgui.hookEvent("onProcessModules", nil, mprpnl.processModules)
xgui.addSubModule("地图相关", mprpnl, nil, "terrortown_settings")

--------------------Equipment credits Module--------------------
local ecpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local b2 = true

for _, v in pairs(GetSortedRoles()) do
	if v ~= INNOCENT and IsShoppingRole(v.index) then
		-- ROLES credits
		if v == TRAITOR then
			local ectcclp = vgui.Create("DCollapsibleCategory", ecpnl)
			ectcclp:SetSize(390, 125)
			ectcclp:SetExpanded(b2 and 1 or 0)
			ectcclp:SetLabel(v.name .. " 学分")

			b2 = false

			local ectclst = vgui.Create("DPanelList", ectcclp)
			ectclst:SetPos(5, 25)
			ectclst:SetSize(390, 125)
			ectclst:SetSpacing(5)

			ectclst:AddItem(xlib.makeslider{
				label = "初始学分数量 (默认. 2)",
				min = 0,
				max = 10,
				repconvar = "rep_ttt_credits_starting",
				parent = ectclst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "百分比的无辜玩家死亡获得学分 (默认. 0.35)",
				min = 0.01,
				max = 0.9,
				decimal = 2,
				repconvar = "rep_ttt_credits_award_pct",
				parent = krmlst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "授予的学分数量 (默认. 1)",
				min = 0,
				max = 5,
				repconvar = "rep_ttt_credits_award_size",
				parent = ectclst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "发放学分奖励数量  (默认. 1)",
				min = 0,
				max = 5,
				repconvar = "rep_ttt_credits_award_repeat",
				parent = ectclst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "叛徒杀死侦探玩家时获得的学分点数 (默认. 1)",
				min = 0,
				max = 5,
				repconvar = "rep_ttt_credits_detectivekill",
				parent = ectclst
			})
		else
			local ectcclp = vgui.Create("DCollapsibleCategory", ecpnl)
			ectcclp:SetSize(390, 75)
			ectcclp:SetExpanded(b2 and 1 or 0)
			ectcclp:SetLabel(v.name .. " 学分")

			b2 = false

			local ectclst = vgui.Create("DPanelList", ectcclp)
			ectclst:SetPos(5, 25)
			ectclst:SetSize(390, 75)
			ectclst:SetSpacing(5)

			ectclst:AddItem(xlib.makeslider{
				label = "探长初始学分",
				min = 0,
				max = 10,
				repconvar = "rep_ttt_" .. v.abbr .. "_credits_starting",
				parent = ectclst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "探长杀死叛徒学分",
				min = 0,
				max = 10,
				repconvar = "rep_ttt_" .. v.abbr .. "_credits_traitorkill",
				parent = ectclst
			})

			ectclst:AddItem(xlib.makeslider{
				label = "叛徒死亡给予学分",
				min = 0,
				max = 10,
				repconvar = "rep_ttt_" .. v.abbr .. "_credits_traitordead",
				parent = ectclst
			})
		end
	end
end

xgui.hookEvent("onProcessModules", nil, ecpnl.processModules)
xgui.addSubModule("设备学分", ecpnl, nil, "terrortown_settings")

--------------------Prop possession Module--------------------
local pppnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local ppclp = vgui.Create("DCollapsibleCategory", pppnl)
ppclp:SetSize(390, 120)
ppclp:SetExpanded(1)
ppclp:SetLabel("道具占有")

local pplst = vgui.Create("DPanelList", ppclp)
pplst:SetPos(5, 25)
pplst:SetSize(390, 120)
pplst:SetSpacing(5)

local ppspc = xlib.makecheckbox{label = "切换观众是否可以拥有道具  (默认. 1)", repconvar = "rep_ttt_spec_prop_control", parent = pplst}
pplst:AddItem(ppspc)

local ppspb = xlib.makeslider{label = "道具拳数 (默认. 8)", min = 0, max = 50, repconvar = "rep_ttt_spec_prop_base", parent = pplst}
pplst:AddItem(ppspb)

local ppspmp = xlib.makeslider{label = "负分的冲头限制的最大减少 (默认. -6)", min = -50, max = 0, repconvar = "rep_ttt_spec_prop_maxpenalty", parent = pplst}
pplst:AddItem(ppspmp)

local ppspmb = xlib.makeslider{label = "正分的打孔计限制的最大增加 (默认. 16)", min = 0, max = 50, repconvar = "rep_ttt_spec_prop_maxbonus", parent = pplst}
pplst:AddItem(ppspmb)

local ppspf = xlib.makeslider{label = "每次冲头移动道具的力的大小 (默认. 110)", min = 50, max = 300, repconvar = "rep_ttt_spec_prop_force", parent = pplst}
pplst:AddItem(ppspf)

local ppprt = xlib.makeslider{label = "打孔计中一个点充电的秒数 (默认. 1)", min = 0, max = 10, repconvar = "rep_ttt_spec_prop_rechargetime", parent = pplst}
pplst:AddItem(ppprt)

xgui.hookEvent("onProcessModules", nil, pppnl.processModules)
xgui.addSubModule("道具占有", pppnl, nil, "terrortown_settings")

-------------------------------------------------------------
-------------------- MODULE: MAP RELATED --------------------
-------------------------------------------------------------

local arpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local arclp = vgui.Create("DCollapsibleCategory", arpnl)
arclp:SetSize(390, 150)
arclp:SetExpanded(1)
arclp:SetLabel("管理员相关")

local arlst = vgui.Create("DPanelList", arclp)
arlst:SetPos(5, 25)
arlst:SetSize(390, 150)
arlst:SetSpacing(5)

arlst:AddItem(xlib.makeslider{
	label = "空闲的时间(以秒为单位) (默认. 180)",
	min = 50,
	max = 300,
	repconvar = "rep_ttt_idle_limit",
	parent = arlst
})

arlst:AddItem(xlib.makeslider{
	label = "禁止更改姓名的玩家的时间 (默认. 10)",
	min = 0,
	max = 60,
	repconvar = "rep_ttt_namechange_bantime",
	parent = arlst
})

arlst:AddItem(xlib.makecheckbox{
	label = "是否自动踢出更改名称的玩家 (默认. 1)",
	repconvar = "rep_ttt_namechange_kick",
	parent = arlst
})

arlst:AddItem(xlib.makecheckbox{
	label = "控制台的伤害日志 (默认. 1)",
	repconvar = "rep_ttt_log_damage_for_console",
	parent = arlst
})

arlst:AddItem(xlib.makecheckbox{
	label = "损坏日志保存 (默认. 0)",
	repconvar = "rep_ttt_damagelog_save",
	parent = arlst
})

arlst:AddItem(xlib.makecheckbox{
	label = "布娃娃碰撞 (默认. 0)",
	repconvar = "rep_ttt_ragdoll_collide",
	parent = arlst
})

arlst:AddItem(xlib.makecheckbox{
	label = "按钮管理显示 (默认. 0)",
	repconvar = "rep_ttt2_tbutton_admin_show",
	parent = arlst
})

xgui.hookEvent("onProcessModules", nil, arpnl.processModules)
xgui.addSubModule("管理员相关", arpnl, nil, "terrortown_settings")

--------------------------------------------------------
-------------------- MODULE: Sprint --------------------
--------------------------------------------------------

local spnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local sclp = vgui.Create("DCollapsibleCategory", spnl)
sclp:SetSize(390, 125)
sclp:SetExpanded(1)
sclp:SetLabel("TTT2冲刺")

local slst = vgui.Create("DPanelList", sclp)
slst:SetPos(5, 25)
slst:SetSize(390, 125)
slst:SetSpacing(5)

slst:AddItem(xlib.makecheckbox{
	label = "是否启用冲刺  (默认. 1)",
	repconvar = "rep_ttt2_sprint_enabled",
	parent = slst
})

slst:AddItem(xlib.makeslider{
	label = "最大冲刺 (默认. 0.5)",
	min = 0,
	max = 2,
	decimal = 2,
	repconvar = "rep_ttt2_sprint_max",
	parent = slst
})

slst:AddItem(xlib.makeslider{
	label = "冲刺耐力消耗 (默认. 0.6)",
	min = 0,
	max = 2,
	decimal = 2,
	repconvar = "rep_ttt2_sprint_stamina_consumption",
	parent = slst
})

slst:AddItem(xlib.makeslider{
	label = "冲刺耐力再生 (默认. 0.3)",
	min = 0,
	max = 2,
	decimal = 2,
	repconvar = "rep_ttt2_sprint_stamina_regeneration",
	parent = slst
})

slst:AddItem(xlib.makecheckbox{
	label = "冲刺十字准线 (默认. 1)",
	repconvar = "rep_ttt2_sprint_crosshair",
	parent = slst
})

xgui.hookEvent("onProcessModules", nil, spnl.processModules)
xgui.addSubModule("恐怖小镇2冲刺", spnl, nil, "terrortown_settings")

--------------------------------------------------------
-------------------- MODULE: Doors ---------------------
--------------------------------------------------------

local dpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local dclp = vgui.Create("DCollapsibleCategory", dpnl)
dclp:SetSize(390, 20)
dclp:SetExpanded(1)
dclp:SetLabel("常规设置")

local dlst = vgui.Create("DPanelList", dclp)
dlst:SetPos(5, 25)
dlst:SetSize(390, 20)
dlst:SetSpacing(5)

dlst:AddItem(xlib.makecheckbox{
	label = "是否启用门力对 (默认. 1)",
	repconvar = "rep_ttt2_doors_force_pairs",
	parent = dlst
})

local dclp2 = vgui.Create("DCollapsibleCategory", dpnl)
dclp2:SetSize(390, 90)
dclp2:SetExpanded(1)
dclp2:SetLabel("可破坏的门")

local dlst2 = vgui.Create("DPanelList", dclp2)
dlst2:SetPos(5, 25)
dlst2:SetSize(390, 90)
dlst2:SetSpacing(5)

dlst2:AddItem(xlib.makecheckbox{
	label = "是否启用门可破坏 (默认. 0)",
	repconvar = "rep_ttt2_doors_destructible",
	parent = dlst2
})

dlst2:AddItem(xlib.makecheckbox{
	label = "是否启用门锁着坚不可摧 (默认. 1)",
	repconvar = "rep_ttt2_doors_locked_indestructible",
	parent = dlst2
})

dlst2:AddItem(xlib.makeslider{
	label = "门生命值 (默认. 100)",
	min = 0,
	max = 500,
	decimal = 0,
	repconvar = "rep_ttt2_doors_health",
	parent = dlst2
})

dlst2:AddItem(xlib.makeslider{
	label = "门道具健康 (默认. 50)",
	min = 0,
	max = 500,
	decimal = 0,
	repconvar = "rep_ttt2_doors_prop_health",
	parent = dlst2
})


xgui.hookEvent("onProcessModules", nil, spnl.processModules)
xgui.addSubModule("恐怖小镇2的门", dpnl, nil, "terrortown_settings")

-----------------------------------------------------------
-------------------- MODULE: Inventory --------------------
-----------------------------------------------------------

local ipnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

-- SUBMODULE: Inventory
local iclp1 = vgui.Create("DCollapsibleCategory", ipnl)
iclp1:SetSize(390, 240)
iclp1:SetExpanded(1)
iclp1:SetLabel("存货")

local ilst1 = vgui.Create("DPanelList", iclp1)
ilst1:SetPos(5, 25)
ilst1:SetSize(390, 240)
ilst1:SetSpacing(5)

ilst1:AddItem(xlib.makelabel{
	x = 0,
	y = 0,
	w = 390,
	h = 30,
	wordwrap = true,
	label = "每个插槽上的最大可能武器数量.设置 -1 为无限",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大撬棍插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_melee_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大副插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_secondary_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大主插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_primary_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大制作插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_nade_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大携带插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_carry_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大非武装插槽 (默认. 1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_unarmed_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大特殊插槽 (默认. 2)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_special_slots",
	parent = ilst
})

ilst1:AddItem(xlib.makeslider{
	label = "最大额外插槽 (默认. -1)",
	min = -1,
	max = 10,
	decimal = 0,
	repconvar = "rep_ttt2_max_extra_slots",
	parent = ilst
})

-- SUBMODULE: Inventory
local iclp2 = vgui.Create("DCollapsibleCategory", ipnl)
iclp2:SetSize(390, 240)
iclp2:SetExpanded(1)
iclp2:SetLabel("武器切换")

local ilst2 = vgui.Create("DPanelList", iclp2)
ilst2:SetPos(5, 25)
ilst2:SetSize(390, 240)
ilst2:SetSpacing(5)

ilst2:AddItem(xlib.makecheckbox{
	label = "武器自动拾取 (默认. 1)",
	repconvar = "rep_ttt_weapon_autopickup",
	parent = slst
})

xgui.hookEvent("onProcessModules", nil, ipnl.processModules)
xgui.addSubModule("恐怖小镇2存货", ipnl, nil, "terrortown_settings")

------------------------------------------------------------
-------------------- MODULE: SCOREBOARD --------------------
------------------------------------------------------------

local sbpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local sbclp = vgui.Create("DCollapsibleCategory", sbpnl)
sbclp:SetSize(390, 100)
sbclp:SetExpanded(1)
sbclp:SetLabel("突出显示组")

local sblst = vgui.Create("DPanelList", sbclp)
sblst:SetPos(5, 25)
sblst:SetSize(390, 100)
sblst:SetSpacing(5)

sblst:AddItem(xlib.makecheckbox{
	label = "记分板上显示管理员颜色 (默认. 1)",
	repconvar = "rep_ttt_highlight_admins",
	parent = sblst
})

sblst:AddItem(xlib.makecheckbox{
	label = "记分板上显示探长颜色 (默认. 1)",
	repconvar = "rep_ttt_highlight_dev",
	parent = sblst
})

sblst:AddItem(xlib.makecheckbox{
	label = "记分板上显示VIP (默认. 1)",
	repconvar = "rep_ttt_highlight_vip",
	parent = sblst
})

sblst:AddItem(xlib.makecheckbox{
	label = "记分板上显示插件开发 (默认. 1)",
	repconvar = "rep_ttt_highlight_addondev",
	parent = sblst
})

sblst:AddItem(xlib.makecheckbox{
	label = "记分板上显示支持者 (默认. 1)",
	repconvar = "rep_ttt_highlight_supporter",
	parent = sblst
})

xgui.hookEvent("onProcessModules", nil, sbpnl.processModules)
xgui.addSubModule("恐怖小镇2记分牌", sbpnl, nil, "terrortown_settings")

-------------------------------------------------------
-------------------- MODULE: ARMOR --------------------
-------------------------------------------------------

local apnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

-- SUBMODULE: Armor Features
local aclp1 = vgui.Create("DCollapsibleCategory", apnl)
aclp1:SetSize(390, 50)
aclp1:SetExpanded(1)
aclp1:SetLabel("装甲特点")

local alst1 = vgui.Create("DPanelList", aclp1)
alst1:SetPos(5, 25)
alst1:SetSize(390, 50)
alst1:SetSpacing(5)

alst1:AddItem(xlib.makecheckbox{
	label = "盔甲经典 (默认. 0)",
	repconvar = "rep_ttt_armor_classic",
	parent = alst1
})

alst1:AddItem(xlib.makecheckbox{
	label = "装甲增强 (默认. 1)",
	repconvar = "rep_ttt_armor_enable_reinforced",
	parent = alst1
})

-- SUBMODULE: Armor Item Settings
local aclp2 = vgui.Create("DCollapsibleCategory", apnl)
aclp2:SetSize(390, 65)
aclp2:SetExpanded(1)
aclp2:SetLabel("盔甲物品设置")

local alst2 = vgui.Create("DPanelList", aclp2)
alst2:SetPos(5, 25)
alst2:SetSize(390, 65)
alst2:SetSpacing(5)

alst2:AddItem(xlib.makeslider{
	label = "物品护甲值 (默认. 30)",
	repconvar = "rep_ttt_item_armor_value",
	min = 0,
	max = 100,
	decimal = 0,
	parent = alst2
})

alst2:AddItem(xlib.makecheckbox{
	label = "物品装甲块爆头 (默认. 0)",
	repconvar = "rep_ttt_item_armor_block_headshots",
	parent = alst2
})

alst2:AddItem(xlib.makecheckbox{
	label = "物品装甲块爆炸伤害 (默认. 0)",
	repconvar = "rep_ttt_item_armor_block_blastdmg",
	parent = alst2
})

-- SUBMODULE: Armor Balancing
local aclp3 = vgui.Create("DCollapsibleCategory", apnl)
aclp3:SetSize(390, 100)
aclp3:SetExpanded(1)
aclp3:SetLabel("装甲平衡")

local alst3 = vgui.Create("DPanelList", aclp3)
alst3:SetPos(5, 25)
alst3:SetSize(390, 100)
alst3:SetSpacing(5)

alst3:AddItem(xlib.makeslider{
	label = "重生时的盔甲 (默认. 0)",
	min = 0,
	max = 100,
	decimal = 0,
	repconvar = "rep_ttt_armor_on_spawn",
	parent = alst3
})

alst3:AddItem(xlib.makeslider{
	label = "强化装甲阈值 (默认. 50)",
	min = 0,
	max = 100,
	decimal = 0,
	repconvar = "rep_ttt_armor_threshold_for_reinforced",
	parent = alst3
})

alst3:AddItem(xlib.makeslider{
	label = "装甲损坏块百分比 (默认. 0.2)",
	min = 0,
	max = 1,
	decimal = 2,
	repconvar = "rep_ttt_armor_damage_block_pct",
	parent = alst3
})

alst3:AddItem(xlib.makeslider{
	label = "盔甲伤害生命值 百分比 (默认. 0.7)",
	repconvar = "rep_ttt_armor_damage_health_pct",
	min = 0,
	max = 1,
	decimal = 2,
	parent = alst3
})

xgui.hookEvent("onProcessModules", nil, apnl.processModules)
xgui.addSubModule("恐怖小镇2护甲", apnl, nil, "terrortown_settings")

---------------------------------------------------------------
-------------------- MODULE: MISCELLANEOUS --------------------
---------------------------------------------------------------

local miscpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

local miscclp = vgui.Create("DCollapsibleCategory", miscpnl)
miscclp:SetSize(390, 215)
miscclp:SetExpanded(1)
miscclp:SetLabel("各种各样的")

local misclst = vgui.Create("DPanelList", miscclp)
misclst:SetPos(5, 25)
misclst:SetSize(390, 215)
misclst:SetSpacing(5)

misclst:AddItem(xlib.makeslider{
	label = "撬棍推延迟 (默认. 1.0)",
	min = 0,
	max = 10,
	decimal = 1,
	repconvar = "rep_ttt2_crowbar_shove_delay",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "侦探帽 (默认. 0)",
	repconvar = "rep_ttt_detective_hats",
	parent = misclst
})

misclst:AddItem(xlib.makeslider{
	label = "播放器颜色模式 (默认. 1)",
	min = 0,
	max = 3,
	repconvar = "rep_ttt_playercolor_mode",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "布娃娃碰撞 (默认. 0)",
	repconvar = "rep_ttt_ragdoll_collide",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "是否启用机器人是旁观者 (默认. 0)",
	repconvar = "rep_ttt_bots_are_spectators",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "防止回合结束 (默认. 0)",
	repconvar = "rep_ttt_debug_preventwin",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "位置语音 (默认. 0)",
	repconvar = "rep_ttt_locational_voice",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "允许不跳 (默认. 0)",
	repconvar = "rep_ttt_allow_discomb_jump",
	parent = misclst
})

misclst:AddItem(xlib.makecheckbox{
	label = "强制执行玩家模型 (默认. 1)",
	repconvar = "rep_ttt_enforce_playermodel",
	parent = misclst
})

misclst:AddItem(xlib.makeslider{
	label = "生成波间隔 (默认. 0)",
	min = 0,
	max = 30,
	repconvar = "rep_ttt_spawn_wave_interval",
	parent = misclst
})

xgui.hookEvent("onProcessModules", nil, miscpnl.processModules)
xgui.addSubModule("各种各样的", miscpnl, nil, "terrortown_settings")

hook.Run("TTTUlxModifySettings", "terrortown_settings")
