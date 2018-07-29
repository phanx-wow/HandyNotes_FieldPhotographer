--[[--------------------------------------------------------------------
	HandyNotes: Field Photographer
	Shows where to take selfies for the achievement.
	Copyright (c) 2015-2018 Phanx <addons@phanx.net>. All rights reserved.
	https://github.com/Phanx/HandyNotes_FieldPhotographer
	https://www.curseforge.com/wow/addons/handynotes-field-photographer
	https://www.wowinterface.com/downloads/info23667-HandyNotesFieldPhotographer.html
----------------------------------------------------------------------]]

local ADDON_NAME = ...
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")

local ACHIEVEMENT_ID = 9924
local ACHIEVEMENT_NAME = select(2, GetAchievementInfo(ACHIEVEMENT_ID))
local ADDON_TITLE = GetAddOnMetadata(ADDON_NAME, "Title")
local ICON = "Interface\\AddOns\\"..ADDON_NAME.."\\Camera"

local L = setmetatable({}, { __index = function(t, k) t[k] = k return k end })
if GetLocale() == "deDE" then
	L["Anywhere in the city"] = "Irgendwo in der Stadt"
	L["Anywhere in the zone"] = "Irgendwo in der Zone"
	L["Continent Alpha"] = "Kontinentsopazität"
	L["Continent Scale"] = "Kontinentsgröße"
	L["Ctrl-Right-Click for all waypoints"] = "STRG-Rechtsklick, um alle Zielpunkte zu setzen"
	L["Inside the instance"] = "Innerhalb der Instanz"
	L["Inside the instance, must kill bosses to reach The Lich King"] = "Innerhalb der Instanz, man müsst Bosse töten, um den Lichkönig zu erreichen"
	L["Neverest Pinnacle doesn't count"] = "Gipfel des Nimmerlaya zählt nicht"
	L["On the surface is OK"] = "Auf der Erdoberfläche ist zulässig"
	L["Right-Click for this waypoint"] = "Rechtsklick, um Zielpunkt zu setzen"
	L["Show icons on continent maps"] = "Symbole auf Kontinentskarten anzeigen"
	L["The opacity of icons on continent maps"] = "Die Undurchsichtigkeit der Symbole auf Kontinentskarten"
	L["The opacity of icons on zone maps"] = "Die Undurchsichtigkeit der Symbole auf Zonekarten"
	L["The size of icons on continent maps"] = "Die Größe der Symbole auf Kontinentskarten"
	L["The size of icons on zone maps"] = "Die Größe der Symbole auf Zonekarten"
	L["Zone Alpha"] = "Symbolsopazität"
	L["Zone Scale"] = "Symbolsgröße"
elseif GetLocale():match("^es") then
	L["Anywhere in the city"] = "En cualquier parte de la ciudad"
	L["Anywhere in the zone"] = "En cualquier parte de la zona"
	L["Continent Alpha"] = "Opacidad en continente"
	L["Continent Scale"] = "Tamaño en continente"
	L["Ctrl-Right-Click for all waypoints"] = "Ctrl+clic derecho para todos waypoints"
	L["Inside the instance"] = "Dentro de la instancia"
	L["Inside the instance, must kill bosses to reach The Lich King"] = "Dentro de la instancia, matar a jefes para llegar al Rey Exánime"
	L["Neverest Pinnacle doesn't count"] = "Cumbre del Nieverest no cuenta"
	L["On the surface is OK"] = "En la superficie está bien"
	L["Right-Click for this waypoint"] = "Clic derecho para un waypoint"
	L["Show icons on continent maps"] = "Mostrar iconos en mapas de continentes"
	L["The opacity of icons on continent maps"] = "La opacidad de los iconos en mapas de continentes"
	L["The opacity of icons on zone maps"] = "La opacidad de los iconos en mapas de zonas"
	L["The size of icons on continent maps"] = "El tamaño de los iconos en mapas de continentes"
	L["The size of icons on zone maps"] = "El tamaño de los iconos en mapas de zonas"
	L["Zone Alpha"] = "Opacidad en zona"
	L["Zone Scale"] = "Tamaño en zona"
end

local names, mapToContinent, db, wasInCamera = {}, {}

local data = {
	[93] = { -- Arathi Basin
		[39439262] = 27874, -- Thandol Span
	},
	[17] = { -- Blasted Lands
		[54605317] = 27866, -- The Dark Portal
	},
	[36] = { -- Burning Steppes
		[25022128] = 27968, -- Blackrock Mountain
	},
	[127] = { -- Crystalsong Forest
		[34003700] = 27867, -- Dalaran
	},
	[42] = { -- Deadwind Pass
		[46987490] = 27876, -- Karazhan
	},
	[207] = { -- Deepholm
		[59005900] = 27955, -- Deathwing's Fall
	},
	[115] = { -- Dragonblight
		[87005100] = 27879, -- Naxxramas
		[60005300] = 27880, -- Wyrmrest Temple
	},
	[27] = { -- Dun Morogh
		[59533303] = 27873, -- Deeprun Tram
	},
	[1] = { -- Durotar
		[62027726] = 27971, -- Echo Isles
		[45001000] = 27869, -- Orgrimmar
	},
	[47] = { -- Duskwood
		[74875097] = 27956, -- Darkshire
	},
	[70] = { -- Dustwallow
		[52407642] = 27865, -- Onyxia's Lair
	},
	[23] = { -- Eastern Plaguelands
		[78005336] = 27954, -- Light's Hope Chapel
	},
	[463] = { -- Echo Isles
		[38283533] = 27971, -- Echo Isles
	},
	[37] = { -- Elwynn Forest
		[66503505] = 27873, -- Deeprun Tram
		[33005000] = 27864, -- Stormwind City
	},
	[69] = { -- Feralas
		[48562076] = 27963, -- The Twin Colossals
	},
	[100] = { -- Hellfire Peninsula
		[64002100] = 27974, -- Throne of Kil'jaeden
	},
	[25] = { -- Hillsbrad Foothills
		[70594495] = 27970, -- Ravenholdt Manor
	},
	[117] = { -- Howling Fjord
		[61005900] = 27973, -- Daggercap Bay
	},
	[118] = { -- Icecrown
		[53008700] = 27863, -- The Frozen Throne
	},
	[87] = { -- Ironforge
		[80315213] = 27873, -- Deeprun Tram
	},--[[
	[12] = { -- Kalimdor
		[41928472] = 27969, -- The Scarab Dais
	},]]
	[418] = { -- Krasarang Wilds
		[72003100] = 27976, -- Turtle Beach
	},
	[379] = { -- Kun Lai Summit
		[43505220] = 27964, -- Mount Neverest
	},
	[48] = { -- Loch Modan
		[20897417] = 27960, -- Valley of Kings
	},
	[80] = { -- Moonglade
		[56766652] = 27965, -- Moonglade
	},
	[198] = { -- Mount Hyjal
		[63492337] = 27953, -- Nordrassil
	},
	[550] = { -- Nagrand (Draenor)
		[72992066] = 27962, -- Throne of the Elements
	},
	[107] = { -- Nagrand (Outland)
		[60112341] = 27962, -- Throne of the Elements
	},
	[109] = { -- Netherstorm
		[44503400] = 27966, -- The Stormspire
	},
	[85] = { -- Orgrimmar
		[51498109] = 27869, -- Orgrimmar
	},
	[32] = { -- Searing Gorge
		[34938343] = 27968, -- Blackrock Mountain
	},
	[539] = { -- Shadowmoon Valley (Draenor)
		[71284658] = 27871, -- Temple of Karabor
	},
	[81] = { -- Silithus
		[33718109] = 27969, -- The Scarab Dais
	},
	[84] = { -- Stormwind City
		[67193389] = 27873, -- Deeprun Tram
		[50005000] = 27864, -- Stormwind City
	},
	[224] = { -- Stranglethorn Vale
		[41445414] = 27877, -- Battle Ring, Gurubashi Arena
		[34267367] = 27868, -- Janeiro's Point
	},
	[535] = { -- Talador
		[46357388] = 27977, -- Auchindoun (Draenor)
	},
	[71] = { -- Tanaris
		[63255059] = 27967, -- Caverns of Time
	},
	[108] = { -- Terokkar Forest
		[29382255] = 27952, -- Shattrath City (Outland)
	},
	[210] = { -- The Cape of Stranglethorn
		[46252601] = 27877, -- Battle Ring, Gurubashi Arena
		[35406367] = 27868, -- Janeiro's Point
	},
	[249] = { -- Uldum
		[71775195] = 27978, -- Halls of Origination
	},
	[78] = { -- Un'goro Crater
		[81784645] = 27957, -- The Shaper's Terrace
	},
	[390] = { -- Vale of Eternal Blossoms
		[50005000] = 27870, -- Vale of Eternal Blossoms
	},
	[376] = { -- Valley of the Four Winds
		[52004800] = 27975, -- Sunsong Ranch
	},
	[203] = { -- Vashj'ir
		[72173877] = 27959, -- Vashj'ir
	},
--	[] = { -- Vashj'ir Ruins ???
--		[58001738] = 27959, -- Vashj'ir
--	},
	[22] = { -- Western Plaguelands
		[46542031] = 27875, -- Hearthglen
		[51928248] = 27972, -- Uther's Tomb
	},
	[52] = { -- Westfall
		[42567167] = 27878, -- The Deadmines
		[30538642] = 27961, -- Westfall Lighthouse
	},
	[56] = { -- Wetlands
		[51210962] = 27874, -- Thandol Span
	},
	[123] = { -- Wintergrasp
		[49861623] = 27958, -- Wintergrasp Fortress
	},
}

local factions = {
	[27869] = "Horde", -- Orgrimmar
	[27864] = "Alliance", -- Stormwind City
}

local continents = {
	[572] = true, -- Draenor
	[ 13] = true, -- Eastern Kingdoms
	[ 12] = true, -- Kalimdor
	[113] = true, -- Northrend
	[101] = true, -- Outland
	[424] = true, -- Pandaria
}

local notes = {
	[27863] = L["Inside the instance, must kill bosses to reach The Lich King"], -- The Frozen Throne
	[27864] = L["Anywhere in the city"], -- Stormwind City
	[27867] = L["Anywhere in the city"], -- Dalaran
	[27870] = L["Anywhere in the zone"], -- Vale of Eternal Blossoms
	[27873] = L["Inside the instance"], -- Deeprun Tram
	[27876] = L["Inside the instance"], -- Karazhan
	[27878] = L["Inside the instance"], -- The Deadmines
	[27879] = L["Inside the instance"], -- Naxxramas
	[27959] = L["Anywhere in the zone"], -- Vashj'ir
	[27964] = L["Neverest Pinnacle doesn't count"], -- Mount Neverest
	[27967] = L["On the surface is OK"], -- Caverns of Time
	[27977] = L["Inside the instance"], -- Auchindoun (Draenor)
	[27978] = L["Inside the instance"], -- Halls of Origination
	[27869] = L["Anywhere in the city"], -- Orgrimmar
}

local cameraBuffs = {
	[(GetSpellInfo(181765)) or ""] = true,
	[(GetSpellInfo(181884)) or ""] = true,
}

local defaults = {
	profile = {
		zoneAlpha = 1,
		zoneScale = 1.5,
		continentScale = 1,
		showOnContinents = true,
	}
}

local options = {
	type = "group",
	name = ACHIEVEMENT_NAME,
	get = function(info)
		return db[info[#info]]
	end,
	set = function(info, v)
		db[info[#info]] = v
		HandyNotes:SendMessage("HandyNotes_NotifyUpdate", ACHIEVEMENT_NAME)
	end,
	args = {
		zoneAlpha = {
			order = 2,
			name = L["Zone Alpha"],
			desc = L["The opacity of icons on zone maps"],
			type = "range",
			min = 0, max = 1, step = 0.05, isPercent = true,
		},
		zoneScale = {
			order = 4,
			name = L["Zone Scale"],
			desc = L["The size of icons on zone maps"],
			type = "range",
			min = 0.25, max = 2, step = 0.05, isPercent = true,
		},
		spacer = {
			order = 5,
			name = " ",
			type = "description",
		},
		showOnContinents = {
			order = 6,
			name = L["Show icons on continent maps"],
			type = "toggle",
			width = "full",
		},
		continentAlpha = {
			order = 8,
			name = L["Continent Alpha"],
			desc = L["The opacity of icons on continent maps"],
			type = "range",
			min = 0, max = 1, step = 0.05, isPercent = true,
			disabled = function() return not db.showOnContinents end,
		},
		continentScale = {
			order = 10,
			name = L["Continent Scale"],
			desc = L["The size of icons on continent maps"],
			type = "range",
			min = 0.25, max = 2, step = 0.05, isPercent = true,
			disabled = function() return not db.showOnContinents end,
		},
	}
}

------------------------------------------------------------------------

local pluginHandler = {}

function pluginHandler:OnEnter(mapID, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if self:GetCenter() > UIParent:GetCenter() then
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	local criteria = data[mapID] and data[mapID][coord]
	if criteria then
		tooltip:AddLine(names[criteria])
		tooltip:AddLine(ACHIEVEMENT_NAME, 1, 1, 1)
		if notes[criteria] then
			tooltip:AddLine(notes[criteria], 1, 1, 1)
		end
		if TomTom then
			tooltip:AddLine(L["Right-Click for this waypoint"])
			tooltip:AddLine(L["Ctrl-Right-Click for all waypoints"])
		end
		tooltip:Show()
	end
end

function pluginHandler:OnLeave(mapID, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	tooltip:Hide()
end

------------------------------------------------------------------------

local waypoints = {}

local function setWaypoint(mapID, coord)
	local criteria = data[mapID][coord]

	local waypoint = waypoints[criteria]
	if waypoint and TomTom:IsValidWaypoint(waypoint) then
		return
	end

	local title = names[criteria] or criteria
	local x, y = HandyNotes:getXY(coord)
	waypoints[criteria] = TomTom:AddWaypoint(mapID, x, y, {
		title = title .. "|n" .. ACHIEVEMENT_NAME,
		persistent = nil,
		minimap = true,
		world = true
	})
end

local function setAllWaypoints()
	for mapID, coords in next, data do
		if not continents[mapID] then
			for coord in next, coords do
				setWaypoint(mapID, coord)
			end
		end
	end
end

function pluginHandler:OnClick(button, down, mapID, coord)
	if button == "RightButton" and TomTom then
		if IsControlKeyDown() then
			setAllWaypoints()
		else
			setWaypoint(mapID, coord)
		end
	end
end

------------------------------------------------------------------------

do
	local scale, alpha
	local function iterator(t, prev)
		if not t then return end
		local coord, v = next(t, prev)
		while coord do
			if v then
				-- coord, mapID, iconpath, scale, alpha
				-- multiply scale * 1.4 to compensate for transparent texture regions
				return coord, nil, ICON, scale * 1.4, alpha
			end
			coord, v = next(t, coord)
		end
	end

	function pluginHandler:GetNodes2(mapID, minimap)
		--print(ACHIEVEMENT_NAME, "GetNodes", mapID)
		local isContinent = continents[mapID]
		if isContinent and not db.showOnContinents then
			return iterator
		end
		scale = isContinent and db.continentScale or db.zoneScale
		alpha = isContinent and db.continentAlpha or db.zoneAlpha
		return iterator, data[mapID]
	end
end

------------------------------------------------------------------------

local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function Addon:PLAYER_LOGIN()
	--print("PLAYER_LOGIN")
	HandyNotes:RegisterPluginDB(ACHIEVEMENT_NAME, pluginHandler, options)
	self.db = LibStub("AceDB-3.0"):New("HNFieldPhotographerDB", defaults, true)
	db = self.db.profile
	-- Remove opposite faction only criteria
	local faction = UnitFactionGroup("player") 
	for mapID, coords in next, data do
		for coord, criteria in next, coords do
			if factions[criteria] and factions[criteria] ~= faction then
				--print("Removed faction criteria:", (GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID, criteria)))
				coords[coord] = nil
				if not next(coords) then
					data[mapID] = nil
				end
			end
		end
	end

	-- Calculate continent coordinates
	local HereBeDragons = LibStub("HereBeDragons-2.0")
	for continentMapID in next, continents do
		local children = C_Map.GetMapChildrenInfo(continentMapID)
		for _, map in next, children do
			local coords = data[map.mapID]
			if coords then
				for coord, criteria in next, coords do
					local mx, my = HandyNotes:getXY(coord)
					local cx, cy = HereBeDragons:TranslateZoneCoordinates(mx, my, map.mapID, continentMapID)
					if cx and cy then
						data[continentMapID] = data[continentMapID] or {}
						data[continentMapID][HandyNotes:getCoord(cx, cy)] = criteria
					end
				end
			end
		end
	end

	-- Go
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:CRITERIA_UPDATE()
end

function Addon:UPDATE_OVERRIDE_ACTIONBAR()
	local inCamera = false
	for i = 1, 40 do
		local name = UnitBuff("player", i)
		if not name or cameraBuffs[name] then
			inCamera = name and cameraBuffs[name]
			break
		end
	end
	--print(ACHIEVEMENT_NAME, "UPDATE_OVERRIDE_ACTIONBAR", inCamera)
	if wasInCamera == inCamera then
		-- no change
		return
	end
	wasInCamera = inCamera
	if inCamera then
		self:RegisterEvent("CRITERIA_UPDATE")
	else
		self:UnregisterEvent("CRITERIA_UPDATE")
	end
end

function Addon:CRITERIA_UPDATE()
	--print(ACHIEVEMENT_NAME, "CRITERIA_UPDATE")
	local changed
	for mapFile, coords in pairs(data) do
		for coord, criteria in pairs(coords) do
			local name, _, complete = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID, criteria)
			if complete then
				--print(ACHIEVEMENT_NAME, "completed", name)
				local waypoint = waypoints[criteria]
				if waypoint and TomTom:IsValidWaypoint(waypoint) then
					waypoints[criteria] = TomTom:RemoveWaypoint(waypoint)
				end
				coords[coord] = nil
				if not next(coords) then
					data[mapFile] = nil
				end
				changed = true
			else
				names[criteria] = name
			end
		end
	end
	if changed then
		--print(ACHIEVEMENT_NAME, "NotifyUpdate")
		HandyNotes:SendMessage("HandyNotes_NotifyUpdate", ACHIEVEMENT_NAME)
	end
end
