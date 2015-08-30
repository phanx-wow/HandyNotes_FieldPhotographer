--[[--------------------------------------------------------------------
	HandyNotes: Field Photographer
	Shows where to take selfies for the achievement.
	Copyright (c) 2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info-HandyNotes-FieldPhotographer.html
	http://www.curse.com/addons/wow/handynotes-field-photographer
	https://github.com/Phanx/HandyNotes_FieldPhotographer
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
	["Arathi"] = {
		[39439262] = 27874, -- Thandol Span
	},
	["BlastedLands"] = {
		[54605417] = 27866, -- The Dark Portal
	},
	["BurningSteppes"] = {
		[25022128] = 27968, -- Blackrock Mountain
	},
	["CrystalsongForest"] = {
		[34003700] = 27867, -- Dalaran
	},
	["Deepholm"] = {
		[59005900] = 27955, -- Deathwing's Fall
	},
	["Dragonblight"] = {
		[87005100] = 27879, -- Naxxramas
		[60005300] = 27880, -- Wyrmrest Temple
	},
	["DunMorogh"] = {
		[59533303] = 27873, -- Deeprun Tram
	},
	["Durotar"] = {
		[62027726] = 27971, -- Echo Isles
	},
	["EchoIslesStart"] = {
		[38283533] = 27971, -- Echo Isles
	},
	["Durotar"] = {
		[45001000] = 27869, -- Orgrimmar
	},
	["Duskwood"] = {
		[74875097] = 27956, -- Darkshire
	},
	["Dustwallow"] = {
		[52407642] = 27865, -- Onyxia's Lair
	},
	["DeadwindPass"] = {
		[46987490] = 27876, -- Karazhan
	},
	["EasternPlaguelands"] = {
		[75805336] = 27954, -- Light's Hope Chapel
	},
	["Elwynn"] = {
		[66503505] = 27873, -- Deeprun Tram
		[33005000] = 27864, -- Stormwind City
	},
	["Feralas"] = {
		[48562076] = 27963, -- The Twin Colossals
	},
	["Hellfire"] = {
		[64002100] = 27974, -- Throne of Kil'jaeden
	},
	["HillsbradFoothills"] = {
		[70594495] = 27970, -- Ravenholdt Manor
	},
	["HowlingFjord"] = {
		[61005900] = 27973, -- Daggercap Bay
	},
	["IcecrownGlacier"] = {
		[53008700] = 27863, -- The Frozen Throne
	},
	["Ironforge"] = {
		[80315213] = 27873, -- Deeprun Tram
	},--[[
	["Kalimdor"] = {
		[41928472] = 27969, -- The Scarab Dais
	},]]
	["Krasarang"] = {
		[72003100] = 27976, -- Turtle Beach
	},
	["KunLaiSummit"] = {
		[43005200] = 27964, -- Mount Neverest
	},
	["LochModan"] = {
		[20897417] = 27960, -- Valley of Kings
	},
	["Moonglade"] = {
		[56766652] = 27965, -- Moonglade
	},
	["Hyjal"] = {
		[63492337] = 27953, -- Nordrassil
	},
	["Nagrand"] = {
		[60112341] = 27962, -- Throne of the Elements
	},
	["NagrandDraenor"] = {
		[72992066] = 27962, -- Throne of the Elements
	},
	["Netherstorm"] = {
		[45003500] = 27966, -- The Stormspire
	},
	["Orgrimmar"] = {
		[51495787] = 27869, -- Orgrimmar
	},
	["SearingGorge"] = {
		[34938343] = 27968, -- Blackrock Mountain
	},
	["ShadowmoonValleyDR"] = {
		[71284658] = 27871, -- Temple of Karabor
	},
	["Silithus"] = {
		[33718109] = 27969, -- The Scarab Dais
	},
	["StormwindCity"] = {
		[67193389] = 27873, -- Deeprun Tram
		[50005000] = 27864, -- Stormwind City
	},
	["StranglethornVale"] = {
		[41445414] = 27877, -- Battle Ring, Gurubashi Arena
		[34267367] = 27868, -- Janeiro's Point
	},
	["Talador"] = {
		[46357388] = 27977, -- Auchindoun (Draenor)
	},
	["Tanaris"] = {
		[63255059] = 27967, -- Caverns of Time
	},
	["TerokkarForest"] = {
		[29382255] = 27952, -- Shattrath City (Outland)
	},
	["TheCapeOfStranglethorn"] = {
		[46252601] = 27877, -- Battle Ring, Gurubashi Arena
		[35406367] = 27868, -- Janeiro's Point
	},
	["Uldum"] = {
		[71775195] = 27978, -- Halls of Origination
	},
	["UngoroCrater"] = {
		[81784645] = 27957, -- The Shaper's Terrace
	},
	["ValeofEternalBlossoms"] = {
		[50005000] = 27870, -- Vale of Eternal Blossoms
	},
	["ValleyoftheFourWinds"] = {
		[52004800] = 27975, -- Sunsong Ranch
	},
	["Vashjir"] = {
		[72173877] = 27959, -- Vashj'ir
	},
	["VashjirRuins"] = {
		[58001738] = 27959, -- Vashj'ir
	},
	["WesternPlaguelands"] = {
		[44651826] = 27875, -- Hearthglen
		[51928248] = 27972, -- Uther's Tomb
	},
	["Westfall"] = {
		[42567167] = 27878, -- The Deadmines
		[30538642] = 27961, -- Westfall Lighthouse
	},
	["Wetlands"] = {
		[51210962] = 27874, -- Thandol Span
	},
	["LakeWintergrasp"] = {
		[49861623] = 27958, -- Wintergrasp Fortress
	},
}

local factions = {
	[27869] = "Horde", -- Orgrimmar
	[27864] = "Alliance", -- Stormwind City
}

local continents = {
	["Azeroth"] = true, -- Eastern Kingdoms
	["Draenor"] = true,
	["Expansion01"] = true, -- Outland
	["Kalimdor"] = true,
	["Northrend"] = true,
	["Pandaria"] = true,
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
--	[UNKNOWN] = L["Anywhere in the city"], -- Orgrimmar
}

local cameraBuffs ={
	(GetSpellInfo(182575)),
	(GetSpellInfo(181884)),
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

function pluginHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if self:GetCenter() > UIParent:GetCenter() then
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	mapFile = gsub(mapFile, "_terrain%d+$", "")
	local criteria = data[mapFile] and data[mapFile][coord]
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

function pluginHandler:OnLeave(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	tooltip:Hide()
end

------------------------------------------------------------------------

local waypoints = {}

local function setWaypoint(mapFile, coord)
	local criteria = data[mapFile][coord]

	local waypoint = waypoints[criteria]
	if waypoint and TomTom:IsValidWaypoint(waypoint) then
		return
	end

	local title = names[criteria] or criteria
	local zone = HandyNotes:GetMapFiletoMapID(mapFile)
	local x, y = HandyNotes:getXY(coord)
	waypoints[criteria] = TomTom:AddMFWaypoint(zone, nil, x, y, {
		title = title .. "|n" .. ACHIEVEMENT_NAME,
		persistent = nil,
		minimap = true,
		world = true
	})
end

local function setAllWaypoints()
	for mapFile, coords in next, data do
		if not continents[mapFile] then
			for coord in next, coords do
				setWaypoint(mapFile, coord)
			end
		end
	end
end

function pluginHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and TomTom then
		if IsControlKeyDown() then
			setAllWaypoints()
		else
			setWaypoint(mapFile, coord)
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
				-- coord, mapFile2, iconpath, scale, alpha, level2
				-- multiply scale * 1.4 to compensate for transparent texture regions
				return coord, nil, ICON, scale * 1.4, alpha
			end
			coord, v = next(t, coord)
		end
	end
	function pluginHandler:GetNodes(mapFile, minimap, dungeonLevel)
		mapFile = gsub(mapFile, "_terrain%d+$", "")
		--print(ACHIEVEMENT_NAME, "GetNodes", mapFile)
		local isContinent = continents[mapFile]
		if isContinent and not db.showOnContinents then
			return iterator
		end
		scale = isContinent and db.continentScale or db.zoneScale
		alpha = isContinent and db.continentAlpha or db.zoneAlpha
		return iterator, data[mapFile]
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
	for mapFile, coords in next, data do
		for coord, criteria in next, coords do
			if factions[criteria] and factions[criteria] ~= faction then
				--print("Removed faction criteria:", (GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID, criteria)))
				coords[coord] = nil
				if not next(coords) then
					data[mapFile] = nil
				end
			end
		end
	end
	-- Calculate continent coordinates
	local HereBeDragons = LibStub("HereBeDragons-1.0")
	local continents = { GetMapContinents() }
	for mapFile, coords in next, data do
		if not continents[mapFile] then
			local continentMapID = continents[2 * HandyNotes:GetCZ(mapFile) - 1]
			local continentMapFile = HandyNotes:GetMapIDtoMapFile(continentMapID)
			mapToContinent[mapFile] = continentMapFile
			for coord, criteria in next, coords do
				local x, y = HandyNotes:getXY(coord)
				x, y = HereBeDragons:GetWorldCoordinatesFromZone(x, y, mapFile)
				x, y = HereBeDragons:GetZoneCoordinatesFromWorld(x, y, continentMapID)
				if x and y then
					data[continentMapFile] = data[continentMapFile] or {}
					data[continentMapFile][HandyNotes:getCoord(x, y)] = criteria
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
	for i = 1, #cameraBuffs do
		if UnitBuff("player", cameraBuffs[i]) then
			inCamera = true
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