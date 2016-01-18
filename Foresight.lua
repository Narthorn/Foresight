-----------------------------------------------------------------------------------------------
-- Foresight
--- Vim Exe @ Jabbit <Codex>

Foresight = {
	name = "Foresight",
	version = {0,1,7},
	tVersions = {},
	tTelegraphColorSets = {
		ApolloColor.new(1, 44/255,  25/255, Apollo.GetConsoleVariable("spell.fillOpacityDefault_34")/100),
		ApolloColor.new(1, 129/255, 0,      Apollo.GetConsoleVariable("spell.fillOpacityDeuteranopia_34")/100),
		ApolloColor.new(1, 211/255, 0,      Apollo.GetConsoleVariable("spell.fillOpacityProtanopia_34")/100),
		ApolloColor.new(1, 0,       0,      Apollo.GetConsoleVariable("spell.fillOpacityTritanopia_34")/100),
		ApolloColor.new(
			Apollo.GetConsoleVariable("spell.custom1EnemyNPCDetrimentalTelegraphColorR")/255,
			Apollo.GetConsoleVariable("spell.custom1EnemyNPCDetrimentalTelegraphColorG")/255,
			Apollo.GetConsoleVariable("spell.custom1EnemyNPCDetrimentalTelegraphColorB")/255,
			Apollo.GetConsoleVariable("spell.fillOpacityCustom1_34")/100
		),
		ApolloColor.new(
			Apollo.GetConsoleVariable("spell.custom2EnemyNPCDetrimentalTelegraphColorR")/255,
			Apollo.GetConsoleVariable("spell.custom2EnemyNPCDetrimentalTelegraphColorG")/255,
			Apollo.GetConsoleVariable("spell.custom2EnemyNPCDetrimentalTelegraphColorB")/255,
			Apollo.GetConsoleVariable("spell.fillOpacityCustom2_34")/100
		),
	},
	nCircleSides = 20,
	tUnits = {},
}
  
function Foresight:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("Foresight.xml")
	self.wndTracker = Apollo.LoadForm(self.xmlDoc, "OnScreenTracker", "InWorldHudStratum", self)
	self.wndOverlay = Apollo.LoadForm(self.xmlDoc, "Overlay", "InWorldHudStratum", self)

	--self.channel = ICCommLib.JoinChannel(self.name, "OnICCommMessageReceived", self)
	Apollo.RegisterSlashCommand("foresight", "OnSlashCommand", self)
	Event_FireGenericEvent("OneVersion_ReportAddonInfo", self.name, unpack(self.version))
	
	self.tStyle = {
		crLineColor = self.tTelegraphColorSets[Apollo.GetConsoleVariable("spell.telegraphColorSet")+1],
		nLineWidth = 1,
	}
	
	self.tCircle = DrawLib:CalcCircleVectors(self.nCircleSides)
	
	self.tTrackedUnits = { 
		--["Air Column"] = {
		--	nMinSqDistance = 2000,
		--	nLineLength = 40,
		--	nUnitWidth = 6,
		--	fnDraw = self.DrawUnitLines,
		--},
		["Holo Cannon"] = {
			nMinSqDistance = 1000000,
			nLineLength = 100,
			nUnitWidth = 6,
			fnDraw = self.DrawUnitLines,
			crColor = "40a8312d",
			crColorInside = "red",
		},
		--[["Jacked Jabbit"] = {
			nMinSqDistance = 2500,
			nLineLength = 30,
			nUnitWidth = 1,
			fnDraw = self.DrawUnitLines,
		},--]]
		["Impenetrable Plasma Shield"] = {
			nMinSqDistance = 2500,
			nUnitWidth = 5,
			fnDraw = self.DrawUnitCircle,
		},
		["Flame Wave"] = {
			nMinSqDistance = 10000,
			nLineLength = 50,
			nUnitWidth = 7,
			fnDraw = self.DrawUnitLines,
			crColor = "40a8312d",
			crColorInside = "red",
		},
		["Phagetech Commander"] = {
			nMinSqDistance = 10000,
			nUnitWidth = 7,
			fnDraw = self.DrawUnitCircle,
		},
		["Phagetech Augmentor"] = {
			nMinSqDistance = 10000,
			nUnitWidth = 7,
			fnDraw = self.DrawUnitCircle,
		},
		["Phagetech Fabricator"] = {
			nMinSqDistance = 10000,
			nUnitWidth = 7,
			fnDraw = self.DrawUnitCircle,
		},
		["Phagetech Protector"] = {
			nMinSqDistance = 10000,
			nUnitWidth = 7,
			fnDraw = self.DrawUnitCircle,
		},
		["Life Force"] = {
			nMinSqDistance = 2500,
			nLineLength = 15,
			nUnitWidth = 3,
			fnDraw = self.DrawUnitLines,
			crColor = "40713fa2",
			crColorInside = "ff511f82",
		},
		["Visceralus"] = {
			nMinSqDistance = 10000,
			nLineLength = 32,
			nUnitWidth = 2,
			fnDraw = self.DrawSafeZoneLines,
			nLines = 5,
			tLineColors = {"FFFCD036","FF4DBCE9","FF5F3968","FF5F3968","FF4DBCE9"},
		},
		["Alphanumeric Hash"] = {
			nMinSqDistance = 10000,
			nLineLength = 50,
			fnDraw = self.DrawSingleUnitLine,
			crColor = "red",
		},	
		["Tesla Tower"] = {
			nMinSqDistance = 5000,
			nUnitWidth = 20,
			fnDraw = self.DrawUnitCircle,
			crColor = "red",
		},
		["16623 Hostile Invisible Unit for Fields (0 hit radius) (Very Fast Move Updates) - BEAX"] = {
			nMinSqDistance = 5000,
			nUnitWidth = 10,
			fnDraw = self.DrawUnitCircle,
			crColor = "red",
		},
		["Dreadphage Ohmna"] = {
			nMinSqDistance = 10000,
			nLineLength = 32,
			nUnitWidth = 10,
			fnDraw = self.DrawSafeZoneLines,
			nLines = 3,
			tLineColors = {"FFFCD036","FF00B0D8","FF00B0D8"},
		},
		["Ravenous Maw of the Dreadphage"] = {
			nMinSqDistance = 10000,
			nLineLength = 20,
			nUnitWidth = 5,
			fnDraw = self.DrawSingleUnitLine,
			crColor = "FFFCD036",
		},

	}
			
	Apollo.RegisterEventHandler("UnitCreated",   "OnUnitCreated",   self)
	Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
	Apollo.RegisterEventHandler("NextFrame",     "OnFrame",         self)
end

function Foresight:OnUnitCreated(unit) 
	local tUnitData = self.tTrackedUnits[unit:GetName()]
	if tUnitData then
		self.tUnits[unit:GetId()] = {
			unit = unit,
			nMinSqDistance = tUnitData.nMinSqDistance,
			nLineLength = tUnitData.nLineLength,
			nUnitWidth = tUnitData.nUnitWidth,
			fnDraw = tUnitData.fnDraw,
			crColor = tUnitData.crColor,
			crColorInside = tUnitData.crColorInside,
			nLines = tUnitData.nLines,
			tLineColors = tUnitData.tLineColors,
			
			-- ok this is seriously dumb but I cba changing all the code in five minutes which is
			-- the time I have now before we pull again
		}
	end
end
function Foresight:OnUnitDestroyed(unit) self.tUnits[unit:GetId()] = nil end

function Foresight:OnFrame()
	self.wndOverlay:DestroyAllPixies()
	if next(self.tUnits) ~= nil then
		self.vPlayerPos = Vector3.New(GameLib.GetPlayerUnit():GetPosition())
		for id,unit in pairs(self.tUnits) do 
			unit.vPosition = Vector3.New(unit.unit:GetPosition())
			if self:GetSqDistanceFromPlayer(unit.vPosition) < unit.nMinSqDistance then
				unit.fnDraw(self,unit)
			end
		end
	end
end

function Foresight:GetSqDistanceFromPlayer(vPos)
	return (self.vPlayerPos - vPos):LengthSq()
end

function Foresight:DrawUnitLines(unit)
	local vPos = unit.vPosition	
	local vFacing = Vector3.New(unit.unit:GetFacing())

	local fLength = unit.nLineLength
	
	if unit.nLineLength < 0 then 
		vFacing = -vFacing
		fLength = -fLength
	end

	local fClosest = Vector3.Dot(self.vPlayerPos - vPos, vFacing)
	
	if -10 < fClosest and fClosest < fLength then
		local vNormal = Vector3.Cross(vFacing, Vector3.New(0,1,0))
		local fDistance = Vector3.Dot(self.vPlayerPos - vPos, vNormal)
		local tStyle = {nLength = fLength, fWidth = self.tStyle.nLineWidth, crLineColor = unit.crColor or self.tStyle.crLineColor}
		
		if math.abs(fDistance) < unit.nUnitWidth then tStyle.crLineColor = unit.crColorInside or Foresight.tTelegraphColorSets[5] end

		-- inner lines, thin
		self:DrawLine(vPos - vNormal*(unit.nUnitWidth-0.3), vFacing, tStyle, fClosest)
		self:DrawLine(vPos + vNormal*(unit.nUnitWidth-0.3), vFacing, tStyle, fClosest)

		-- outer lines, fat
		tStyle.fWidth = tStyle.fWidth + 6
		self:DrawLine(vPos - vNormal*unit.nUnitWidth, vFacing, tStyle, fClosest)
		self:DrawLine(vPos + vNormal*unit.nUnitWidth, vFacing, tStyle, fClosest)
	end
end

function Foresight:DrawSingleUnitLine(unit)
	local vPos = unit.vPosition
	local vFacing = Vector3.New(unit.unit:GetFacing())
	local fLength = unit.nLineLength
	
	if unit.nLineLength < 0 then 
		vFacing = -vFacing
		fLength = -fLength
	end
	
	local fClosest = Vector3.Dot(self.vPlayerPos - vPos, vFacing)
	
	if -10 < fClosest and fClosest < fLength then
		local vNormal = Vector3.Cross(vFacing, Vector3.New(0,1,0))
		local fDistance = Vector3.Dot(self.vPlayerPos - vPos, vNormal)
		local tStyle = {nLength = fLength, fWidth = self.tStyle.nLineWidth+6, crLineColor = unit.crColor or self.tStyle.crLineColor, bOutline = true}
		
		self:DrawLine(vPos, vFacing, tStyle, fClosest)
	end
end

function Foresight:DrawUnitCircle(unit)
	DrawLib:DrawUnitCircle(unit.unit, unit.nUnitWidth, self.nCircleSides,
		{nLineWidth = self.tStyle.nLineWidth+3, crLineColor = unit.crColor or self.tStyle.crLineColor, bOutline = true}) 
end

function Foresight:DrawSafeZoneLines(unit)
	local vPos = unit.vPosition
	local fHeading = unit.unit:GetHeading()
	local tVectors = DrawLib:CalcCircleVectors(unit.nLines, fHeading)

	local fLength = unit.nLineLength
	local tStyle  = {nLength = fLength, fWidth = self.tStyle.nLineWidth+7}
	local tStyleO = {nLength = fLength+0.02, fWidth = self.tStyle.nLineWidth+9, crLineColor = "black"}
	
	for i=1,unit.nLines do
		tStyle.crLineColor = unit.tLineColors[i]
		self:DrawLine(vPos, tVectors[i], tStyleO, nil, unit.nUnitWidth)
		self:DrawLine(vPos, tVectors[i], tStyle, nil, unit.nUnitWidth)
	end
end

function Foresight:DrawLine(vPos, vFacing, tStyle, fClosest, fOffset)
	local vA = vPos 
	local vB = vPos + vFacing*(fClosest and math.min(fClosest+20, tStyle.nLength) or tStyle.nLength)
	
	if fOffset then vA = vA + vFacing*fOffset end
	
	tStyle.nLineWidth = tStyle.fWidth

	local pA = GameLib.WorldLocToScreenPoint(vA)
	local pB = GameLib.WorldLocToScreenPoint(vB)
	DrawLib:DrawLine(pA,pB,tStyle)
end

--

function Foresight:OnICCommMessageReceived(channel, message, sender)
	if message.ping then
		self.channel:SendMessage({version = self.version})
	elseif message.version then
		if not self.tVersions[message.version] then self.tVersions[message.version] = {} end
		local tUsers = self.tVersions[message.version]
		tUsers[#tUsers+1] = sender
	end
end

function Foresight:OnSlashCommand(strCmd, strParam)
	if strParam == "version" then
		self.tMembers = {} 
		for i=1, GroupLib.GetMemberCount() do
			groupmember = GroupLib.GetGroupMember(i)
			if groupmember.strCharacterName ~= GameLib.GetPlayerUnit():GetName() then
				self.tMembers[groupmember.strCharacterName] = false
			end
		end
		self.tVersions = {}
		self.channel:SendMessage({ping = true})
		self.tmrVersionCheck = ApolloTimer.Create(2, false, "OnVersionCheckTimer", self)
		
	end
end

function Foresight:OnVersionCheckTimer()
	Print(self.name .. " version: " .. self.version)
	for version, tUsers in pairs(self.tVersions) do
		for i=1,#tUsers do self.tMembers[tUsers[i]] = nil end
		if version ~= self.version then
			Print("Users with v"..version..": "..table.concat(tUsers,","))
		end
	end
	if GroupLib.InGroup() then
		Print("--")
		local tMissingUsers = {}
		for user,_ in pairs(self.tMembers) do tMissingUsers[#tMissingUsers+1] = user end
		if #tMissingUsers then
			Print("Users without "..self.name..": "..table.concat(tMissingUsers,","))
		end
	end
end

Apollo.RegisterAddon(Foresight, false, "", {"DrawLib"})
