local _G = getfenv(0)
local _,playerClass = UnitClass("player")
local tinsert = table.insert
local layoutName = "oUF_Smee2"
_G[layoutName] = LibStub("AceAddon-3.0"):NewAddon(layoutName,"AceConsole-3.0")
local addon = _G[layoutName];
	addon.LSM = LibStub("LibSharedMedia-3.0")
	addon.build = {}
	addon.build.version, addon.build.build, addon.build.date, addon.build.tocversion = GetBuildInfo()


---------------
--      LDB      --
---------------
local LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(layoutName, {
	label = "|cFF006699oUF|r_|cFFFF3300Smee|r",
	type = "launcher",
	icon = "Interface\\Icons\\Spell_Nature_StormReach",
})


function LDB.OnClick(self, button)
	if button == "RightButton" then
		addon:OpenConfig()
	else
		if addon.db.profile.enabled then
			if IsAltKeyDown() then
				if IsControlKeyDown() then
					addon:ToggleDebug()
				end
			elseif IsShiftKeyDown()  then
--				addon:DoSomething()
			end
		else
			--addon:ToggleActive(true)
		end
	end
end

function addon:ToggleDebug()
	self.enabledDebugMessages=not self.enabledDebugMessages
	self:Print("Debug messages : "..(self.enabledDebugMessages and "ON" or "OFF"))
end

function LDB.OnTooltipShow(tt)
	tt:AddLine(layoutName)
	tt:AddLine("Debugging "..(addon.enabledDebugMessages and "en" or "dis").."abled.")
	tt:AddLine("--")
	tt:AddLine("Ctrl + Alt + Left Click : Toggle Debug Messages")
	tt:AddLine("Right Click : Open Config")
end

local function dummy(arg) end
local function GetClassColor(unit)
	local _,unitClass = UnitClass(unit)
	return unpack(addon.db.profile.colors.class[unitClass])
end
local function menu(self)
	local unit,cunit = self.unit:sub(1, -2), self.unit:gsub("(.)", string.upper, 1)
	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end 

----------------------
-- helper functions --
----------------------
local function round(num, idp)
  if idp and idp>0 then  return math.floor(num * mult + 0.5) / (10^idp)  end
  return math.floor(num + 0.5)
end
local function numberize(val)
	if(val >= 1e3) then return ("%.1fk"):format(val / 1e3)
	elseif (val >= 1e6) then return ("%.1fm"):format(val / 1e6)
	else return val
	end
end
function Hex(r, g, b)
	if type(r) == "table" then 
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end
local function GetDifficultyColor(level)
	if level == '??' then return  .69,.31,.31
	else
	local levelDiff = UnitLevel('target') - UnitLevel('player')
		if levelDiff >= 5 then
			return .69,.31,.31
		elseif levelDiff >= 3 then
			return .71,.43,.27
		elseif levelDiff >= -2 then
			return .84,.75,.65
		elseif -levelDiff <= GetQuestGreenRange() then
			return .33,.59,.33
		else
			return  .55,.57,.61
		end
	end
end
local function GetFormattedTime(s)
	local auraDb = addon.db.profile.auras.timers
	local DAY,HOUR,MINUTE,SHORT = auraDb.values.DAY,auraDb.values.HOUR,auraDb.values.MINUTE,auraDb.values.SHORT
	if s >= DAY then
		return format('%dd', floor(s/DAY + 0.5)), s % DAY
	elseif s >= HOUR then
		return format('%dh', floor(s/HOUR + 0.5)), s % HOUR
	elseif s >= MINUTE then
		if s <= MINUTE*3 and auraDb.UsingMMSS then
			return format('%d:%02d', floor(s/60), s % MINUTE), s - floor(s)
		end
		return format('%dm', floor(s/MINUTE + 0.5)), s % MINUTE
	elseif s > 2 then
		return floor(s + 0.5), s - floor(s)
	end
	return format("%0.1f", s), 0.1
end
local function GetFormattedFont(s)
	local auraDb = addon.db.profile.auras.timers
	local DAY,HOUR,MINUTE,SHORT = auraDb.values.DAY,auraDb.values.HOUR,auraDb.values.MINUTE,auraDb.values.SHORT
	if s > DAY then
		style = auraDb.cooldownTimerStyle.days
	elseif s > HOUR then
		style = auraDb.cooldownTimerStyle.hrs
	elseif s > MINUTE then
		style = auraDb.cooldownTimerStyle.mins
	elseif s > SHORT then
		style = auraDb.cooldownTimerStyle.secs
	else
		style = auraDb.cooldownTimerStyle.short
	end	
	return style.s, style.r, style.g, style.b
end

------------------
-- UPDATE HOOKS --
------------------
local function updateBanzai(self, unit, aggro)
	if self.unit ~= unit then return end
	if aggro == 1 then self.BanzaiIndicator:Show()
	else self.BanzaiIndicator:Hide() end
end

local function UpdateThreat(self, event, unit)
	if((not unit) or (not event)) or (UnitIsGhost(unit) or UnitIsDead(unit) or (not UnitIsConnected(unit))) then return end
	if unit == "player" or unit:gmatch("raid")() or unit:gmatch("party")() or unit:gmatch("pet")() or unit:gmatch("focus")() or unit:gmatch("target")() then
	   unitTarget = unit.."target"
	else
	   unitTarget = unit.."-target"
    end   
	local unitTarget = (unit =='player' and "target" or unit.."target")
	
	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(unit, unitTarget);
	if not(rawthreatpct == nil) then 
		self.Threat:SetText( Hex(GetThreatStatusColor(status)) .. string.format("%.0f", rawthreatpct ) .. "|r" )
	else
		self.Threat:SetText('')
	end
end

local function PostUpdateHealth(self, event, unit, bar, min, max)
  bar:SetStatusBarColor(0.25, 0.25, 0.25)      -- Default statusbar color  
  if (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
    color = self.colors.tapped
  else
    bar:SetStatusBarColor(.25,.25,.35)      -- Default statusbar color
  end
end

local function PostUpdatePower(self, event, unit, bar, min, max)
	if (UnitIsGhost(unit) or UnitIsDead(unit) or not UnitIsConnected(unit)) then 
		bar:SetValue(0)
	end
end

local CastNotificationSent = false
local CastNotificationMsg = ""
local CastNotificationChannel = "SAY"
-- CASTBAR
local groupType = function(u)
	if(GetNumRaidMembers()>0)then
		return "RAID"
	elseif(GetNumPartyMembers()>0)then
		return "PARTY"
	end
end

local function whisperTarget(u)
	return UnitName(u)
end

local castAnnouncements = {
	["Resurrection"] = {
		msg = "<< Ressurecting %s >>",
		channel = groupType,
		target = nil,
	},
	["Redemption"] = {
		msg = "<< Ressurecting %s >>",
		channel = groupType,
		target = nil,
	},
	["Revive"] = {
		msg = "<< Ressurecting %s >>",
		channel = groupType,
		target = nil,
	},
	["Rebirth"] = {
		msg = "<< Ressurecting %s >>",
		channel = groupType,
		target = nil,
	},
	["Pain Suppression"] = {
		msg = "<< Pain Suppresion on %s >>",
		channel = groupType,
		target = nil,
	},
	["Power Infusion"] = {
		msg = "<< Power Infusion on You >>",
		channel = function() return "WHISPER" end,
		target = UnitName,
	},

}

local msg
local function CastbarPostCastStart(self, event, unit, name, rank, text, castid)
end
local function CastbarPostCastFailed(self, event, unit, spellname, spellrank, castid)
end
local function CastbarPostCastInterrupted(self, event, unit, spellname, spellrank, castid)
end
local function CastbarPostCastDelayed(self, event, unit, name, rank, text)
end
local function CastbarPostCastStop(self, event, unit, spellname, spellrank, castid)
end
local function CastbarPostChannelStart(self, event, unit, name, rank, text)
	self.bars.Castbar.isFishing = (name == "Fishing")
	self:CustomPositions(event)
end
local function CastbarPostChannelUpdate(self, event, unit, name, rank, text)
end
local function CastbarPostChannelStop(self, event, unit, spellname, spellrank)
	self.bars.Castbar.isFishing = (spellname == "Fishing")
	self:CustomPositions(event)
	self.bars.Castbar:SetStatusBarColor(unpack(self.bars.Castbar.defaultStatusBarColor))	
end

local function CastbarCustomDelayText(self, duration)
	self.Time:SetFormattedText("%.1f", duration)
end
local UNIT_SPELLCAST_SENT = function (self,event, unit, spell, spellrank,spelltarget)
	self.Castbar.target = spelltarget

	if(unit == "player")then
		msg = castAnnouncements[spell]
		if msg then 

			SendChatMessage(
				msg.target and msg.msg or msg.msg:format(UnitName(spelltarget)), 
				msg.channel(),
				"Common", 
				msg.target and msg.target(spelltarget) or nil
			);
			
		end
	end	
end
local UNIT_SPELLCAST_SUCCEEDED = function (self,event, unit, spell, spellrank)
	if(spell == "Ressurection" and unit == "player")then
		CastNotificationSent = false;
	end
end


local channelTimeString
local function CastbarCustomTimeText(self, duration)
		if self.casting then
			self.Time:SetFormattedText("%.1f", self.max - duration)
		elseif self.channeling then
			self:FishingFlasher(duration)
			self.Time:SetFormattedText("%.1f", duration)
		end
end

--[[----------------------------------------
	AURA UPDATE HOOKS
----------------------------------------]]--
local function customFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
--	print(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	icon.duration, icon.timeLeft,icon.owner = duration,timeLeft,caster
	return (icons.whitelist~=nil) and icons.whitelist[name]	or name
end

local function SetAuraPosition(self, icons, count)
	addon:Debug("Repositioning auras.")
	if(icons and count > 0) then
		local col,row = 0,0
		local spacing = icons.spacing or 0
		local size = (icons.size or 16) + spacing
		local anchor = icons.initialAnchor or "BOTTOMLEFT"
		local growthx = (icons["growth-x"] == "LEFT" and -1) or 1
		local growthy = (icons["growth-y"] == "DOWN" and -1) or 1
		local cols = icons.Colomns
--		local rows = icons.Rows  -- Right now only horizontally conditioned aura frames are supported
		local IndexOfLlargestIconInThisRow = 1
		local previousIconSize = 0
		local nextRowYPoint = 0
		
		for i = 1, count do
			local button = icons[i]
			if(button and button:IsShown()) then
				if(icons.gap and button.debuff) then
					if(col > 0) then col = col + 1 end
					icons.gap = false
				end
				previousIconSize = (icons[i]:GetHeight()>previousIconSize)and icons[i]:GetHeight() or previousIconSize
				
				if(col >= cols) then 
					col,row = 0, row + 1 ;
					if growthy > 0 then 
						nextRowYPoint = nextRowYPoint + (previousIconSize + spacing)
					else
						nextRowYPoint = nextRowYPoint - (previousIconSize + spacing)
					end
					previousIconSize = 0
				end
				
				local anchorFrom,anchorObj,anchorTo
				local vert = icons["growth-y"] == 'UP' and 'BOTTOM' or 'TOP'
				

				if growthx < 0 then -- <<<<
					anchorFrom		= vert.."RIGHT"
					anchorObj		= icons[i-1]
					anchorTo			= vert.."LEFT"
					anchorX			= -spacing
					anchorY			= 0

					if i == 1 or col == 0 then 
						anchorObj	= icons
						anchorTo		= vert.."RIGHT"
						anchorY 		= nextRowYPoint
					end
					
				else -- >>>>
					anchorFrom		= vert.."LEFT"
					anchorObj		= icons[i-1]
					anchorTo			= vert.."RIGHT"
					anchorX			= spacing
					anchorY			= 0
					
					if i == 1 or col == 0 then
						anchorObj	= icons
						anchorTo		= vert.."LEFT"
						anchorY 		= nextRowYPoint						
					end
					
				end
				
				addon:Debug("placing aura[".. i.."]"..anchorFrom..":"..tostring(anchorObj)..":"..anchorTo..":"..anchorX..":"..anchorY..".")
				button:SetWidth(icons.size)
				button:SetHeight(icons.size)
				button:ClearAllPoints()
				button:SetPoint(anchorFrom, anchorObj, anchorTo, anchorX, anchorY)
				col = col + 1
				
			end			
		end
	end
end

local function PreUpdateAura(event, unit)
end

local function PostUpdateAuraIcon(self,icons, unit, icon, index, offset, filter, isDebuff)
end

local function sizeAuraIcon(icon,size)
	icon:SetWidth(size)
	icon:SetHeight(size)
end

local function updateAuraIcon(self,event)
	local db = addon.db.profile
	local auraGroup = self:GetParent()
	local name,size,outline = (addon.LSM:Fetch('font',db.auras.font.name) or self.db.profile.fonts.default), db.auras.font.size, db.auras.font.outline
	local frameUnit = self.parent:GetParent().unit
	self.count:SetFont(name,size,outline)
	self.ownership:Hide() 
	
	if(self.duration~=nil and self.timeLeft~=nil) then 
		if(db.auras.timers.enabled)then
			self.remaining:Show()
			self.overlay:Show()
			if(self.duration > 0 or self.timeLeft > 0) then	
				self.overlay:SetParent(self.cd)
				local timeLeft = self.timeLeft - GetTime()
				if(auraGroup.setup and timeLeft <= 0)then self.timeLeft = GetTime()+math.random(1,300) end
				local multiplier, r, g, b = GetFormattedFont(timeLeft)
				self.overlay:SetVertexColor(r,g,b,1)
				self.remaining:SetText(GetFormattedTime(timeLeft)) 
				self.remaining:SetFont(name,(db.auras.timers.useEnlargedFonts and size * multiplier or size),outline)
				self.remaining:SetTextColor(r,g,b)
			end
		else
			self.remaining:Hide()
			self.overlay:Hide()
		end
	end

	if self.owner ~= 'player' then 
		self.icon:SetDesaturated(true)
	end -- sizeAuraIcon(self,auraGroup.size*auraGroup.playerSize) end
	if frameUnit and self.owner then
		local frameOwner, buffOwner = UnitGUID(frameUnit),UnitGUID(self.owner)
		if frameUnit ~='player' and buffOwner == frameOwner then
			self.ownership:Show() 
			self.overlay:Hide()
		end
	end

end

local function ShowAuraTooltip(self,motion)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	if(self.debuff)then
		GameTooltip:SetUnitDebuff(self.frame.unit,self.index,nil)
	else
		GameTooltip:SetUnitBuff(self.frame.unit,self.index,nil)
	end
	GameTooltip:AddLine("Aura Owner : "..(self.owner and UnitName(self.owner) or "Unknown Unit"), 1, 1, 1);
	GameTooltip:Show();
end

local function HideAuraTooltip(self,motion)
	GameTooltip:Hide()
end

local function PostCreateAuraIcon(self, button, icons, index, debuff)
	local db = addon.db.profile
	local fontPath = addon.LSM:Fetch('font',db.auras.font.name) or self.db.profile.fonts.default

	button.cd:SetReverse()
	button.overlay:SetTexture(self.textures.auraBorder)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end

	local ownership = button:CreateTexture(nil, "OVERLAY")
			ownership:SetTexture(self.textures.auraOwnerBorder)
			ownership:SetPoint("TOPLEFT", button,"TOPLEFT", -1,1)
			ownership:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT",1,-1)
			ownership:SetTexCoord(0, 1, 0, 1)
			ownership:Hide()
	button.ownership = ownership

	button.index = index
	button.count:SetParent(button.cd)
	button.count:SetFont(fontPath, db.frames.font.size, db.frames.font.outline)
	button.count:SetPoint("CENTER",button,"BOTTOM",0,-2)
	


	button:SetScript('OnEnter', ShowAuraTooltip)
	button:SetScript('OnLeave', HideAuraTooltip)
	
	local remaining = button.cd:CreateFontString(nil, "OVERLAY")
		remaining:SetFont(fontPath, db.auras.font.size, db.auras.font.outline)
		remaining:SetPoint("CENTER", button, 4, 4)
		remaining:SetJustifyH("CENTER")
	button.remaining = remaining
	button:SetScript('OnUpdate', updateAuraIcon)
end

------------
-- makers --
------------
function addon:makeAuraFrame(obj,auraTypes)
	for _,auraType in pairs(auraTypes)do
		local db =  obj.db[auraType]
		local auraFrame = CreateFrame("Frame", nil, obj)
			auraFrame.size = db.size * 1.1
			auraFrame.playerSize = db.playerSize
			auraFrame:SetHeight(auraFrame.size)
			auraFrame:SetWidth(auraFrame.size * db.Colomns)
			auraFrame:SetPoint(db.anchorFromPoint,obj.elements[db.anchorTo],db.anchorToPoint,db.anchorX,db.anchorY)
			auraFrame.spacing=db.spacing
			auraFrame.num = db.count
			auraFrame.Colomns = db.Colomns
			auraFrame.rows = db.rows		
			auraFrame["growth-x"] = db["growth-x"]
			auraFrame["growth-y"] = db["growth-y"]
			auraFrame.filter = db.filter
			auraFrame.onlyShowPlayer = db.onlyShowPlayer or nil
			auraFrame.setup = db.setup
			auraFrame.whitelist = db.whitelist
			auraFrame.blacklist = db.blacklist
			auraFrame.showType = true
		obj[auraType] = auraFrame;
	end
end


function makeComboPoints(self,anchorFrom,anchorTo,aX,aY)
	local db = addon.db.profile.frames.font
	local fontPath = addon.LSM:Fetch('font',db.name) or self.db.profile.fonts.default

	local cpoints = self:CreateFontString(nil, "OVERLAY")
			  cpoints:SetPoint(anchorFrom, self, anchorTo, aX,aY)
			  cpoints:SetFont(fontPath, db.size, db.outline)
			  cpoints:SetTextColor(1,1,1)
			  cpoints:SetJustifyH("CENTER")
	self.CPoints = cpoints
	
	self.FontObjects["ComboPoints"] =  { 
			name = "Combo Points",
			object = self.CPoints
		}
end

function makeCombatFeedbackText(self)
	if not IsAddOnLoaded("oUF_CombatFeedback") then return end
	local db = addon.db.profile.fonts
	local healthBar = self.bars.Health
	self.CombatFeedbackText = healthBar:CreateFontString(nil, "OVERLAY")
	self.CombatFeedbackText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
	self.CombatFeedbackText:SetFont(db['default'].name, db['default'].size, db['default'].outline)
	self.CombatFeedbackText.maxAlpha = .8

	self.FontObjects["CombatFeedbackText"] ={
		name = "Combat Feedback Text",
		object =  self.CombatFeedbackText
	}
end
local function CastbarFishingFlasher(self,duration)
	if(self.isFishing)then
		if (duration <= 18 and duration > 16) or (duration <= 14 and duration > 12) or (duration <= 8 and duration > 6) or (duration <= 4 and duration > 2)then
			self:SetStatusBarColor(0,1,0)	
		else
			self:SetStatusBarColor(unpack(self.defaultStatusBarColor))	
		end
	else
		self:SetStatusBarColor(unpack(self.defaultStatusBarColor))	
	end
end

local function CustomPositions(self,event)
	local bar = self.bars.Castbar
	if(event == "UNIT_SPELLCAST_CHANNEL_START")then
		if(bar.isFishing)then
			bar:ClearAllPoints()
			bar:SetPoint("CENTER",UIParent,"CENTER",0,0)
		end
	end
	
	if(event == "UNIT_SPELLCAST_CHANNEL_STOP")then
		bar:ClearAllPoints()
		bar:SetPoint(self.db.bars.Castbar.anchorFromPoint,self,self.db.bars.Castbar.anchorToPoint,self.db.bars.Castbar.anchorX,self.db.bars.Castbar.anchorY)
	end
end

local function makeCastBar(self)
	local db = addon.db.profile
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetBackdrop(self.db.bars.Castbar.Backdrop)
	bar:SetBackdropColor(unpack(self.db.bars.Castbar.BackdropColor))
	bar:SetStatusBarTexture(self.textures.statusbar)
	bar.defaultStatusBarColor = self.db.bars.Castbar.StatusBarColor
	bar:SetStatusBarColor(unpack(bar.defaultStatusBarColor))	
	bar.reverse = self.db.bars.Castbar.reverse
	
	bar.bg = bar:CreateTexture(nil, "BORDER")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture(unpack(self.db.bars.Castbar.bgColor))
	self.elements["Castbar"] = bar
	bar.elements={
		['parent'] = self,
		['self'] = bar,
		['Castbar'] = bar,
	}
	
	self.db.bars.Castbar.Text.anchorTo = "Castbar"
	bar.Text = addon:makeFontObject(bar,"Cast Name",self.db.bars.Castbar.Text)
	self.FontObjects['CastName']= { 
		name = "Cast Name",
		object = bar.Text
	}
	self.db.bars.Castbar.Time.anchorTo = "Castbar"
	bar.Time = addon:makeFontObject(bar,"Cast Time",self.db.bars.Castbar.Time)
	self.FontObjects["CastTime"] = { 
		name = "Cast Time",
		object = bar.Time
	}
	bar.isFishing = false

	if self.unit == "player" and self.db.bars.Castbar.SafeZone.enabled == true then 
		bar.SafeZone = bar:CreateTexture(nil,"OVERLAY")
		bar.SafeZone:SetTexture(self.textures.statusbar)
		bar.SafeZone:SetVertexColor(unpack(self.db.bars.Castbar.SafeZone.colour))
		bar.SafeZone:SetPoint("TOPRIGHT")
		bar.SafeZone:SetPoint("BOTTOMRIGHT")	
		bar.accurate=true
	end
		
	bar:ClearAllPoints()
	bar:SetPoint(self.db.bars.Castbar.anchorFromPoint,self,self.db.bars.Castbar.anchorToPoint,self.db.bars.Castbar.anchorX,self.db.bars.Castbar.anchorY)

	bar:SetHeight(self.db.bars.Castbar.height)
	bar:SetWidth(self.db.bars.Castbar.width)

	self.CustomPositions = CustomPositions
	bar.FishingFlasher = CastbarFishingFlasher
	bar.CustomDelayText = CastbarCustomDelayText
	bar.CustomTimeText = CastbarCustomTimeText

	self.bars.Castbar = bar;	
	self.Castbar = bar;
	
	if(self.unit == "player")then
		self:RegisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UNIT_SPELLCAST_SUCCEEDED)
	end
	
end


function RunePostUpdate(self,settings)
	local runeBar = self:GetParent();
	self:SetWidth(runeBar:GetWidth() / 100 *  settings.width)
	self:SetHeight(runeBar:GetHeight() / 100 *  settings.height)
end

function addon:makeRuneBar(frame)
	if frame.unitClass ~= "DEATHKNIGHT" then return end
	if not IsAddOnLoaded("oUF_SmeeRunes") then 
		self:Error("oUF_SmeeRunes not loaded")
		return
	end
	
	local db = addon.db.profile
	local settings = frame.db.bars.RuneBar

	local rune, runeBarHeight,runeBarWidth=_,(frame.db.height/100) * settings.height, (frame.db.width/100) * settings.width
	local runebar = CreateFrame('Frame', nil, frame)

	runebar:SetParent(frame)
	runebar:SetBackdrop(frame.textures.background)
	runebar:SetBackdropColor(unpack(db.colors.backdropColors))
	runebar:SetHeight(runeBarHeight)
	runebar:SetWidth(runeBarWidth)
	runebar:SetPoint(settings.anchorFromPoint,frame,settings.anchorToPoint,settings.anchorX,settings.anchorY)
	runebar.bars = {}
	runebar.runeMapping = {
		[1] = "BLOOD",
		[2] = "UNHOLY",
		[3] = "FROST",
		[4] = "DEATH",
	}
	runebar:Show()
	runebar.colors=db.colors.runes 
	runebar.OnSizeChange = function()
		for index,bar in pairs(runebar.bars) do
			bar:RunePostUpdate(settings.runes[index])
		end
	end

	runebar.SetChildOrientation = function(value)
		for index,bar in pairs(runebar.bars) do
			bar:SetOrientation(value)
		end
	end

	for i = 1, 6 do
		rune = CreateFrame('StatusBar', nil, runebar)
		local runeSetting = settings.runes[i]
		local anchor = runebar.bars[runeSetting.anchorTo] or runebar 
		rune:SetPoint(runeSetting.anchorFromPoint, anchor, runeSetting.anchorToPoint,runeSetting.x,runeSetting.y)
		rune.index=i
		rune:SetStatusBarTexture(frame.textures.statusbar)
		rune:SetStatusBarColor(unpack(db.colors.runes[GetRuneType(i)]))
		rune:SetOrientation(settings.orientation)
		rune:SetBackdrop(frame.textures.background)
		rune:SetBackdropColor(0, 0, 0,0.2)
		rune:SetMinMaxValues(0, 1)
		rune.RunePostUpdate = RunePostUpdate
		rune.bg = rune:CreateTexture(nil, 'BORDER')
		rune.bg:SetAllPoints(rune)
		rune.bg:SetTexture(0, 0, 0,0.3)
		runebar.bars[i] = rune
		rune:RunePostUpdate(runeSetting)
	end
	runebar.OnSizeChange()
	frame.bars.RuneBar = runebar
end


function UpdateTotemBar(self)
	local totembar = self.bars.TotemBar
	if self.unitClass ~= "SHAMAN" or not totembar then return end
	
	local settings = self.db.bars.TotemBar
	local db = addon.db.profile
	local fontDb = db.frames.font -- setting this to the global font option for now, till i work out a per-frame policy.
	local fontName, fontSize, fontOutline = ( addon.LSM:Fetch('font',fontDb.name) or addon.db.profile.fonts.default), fontDb.size, fontDb.outline
	
	totembar:ClearAllPoints()
	totembar:SetPoint(settings.anchorFromPoint, self.elements[settings.anchorTo], settings.anchorToPoint,settings.anchorX,settings.anchorY)
	totembar:SetParent(self)
	totembar:Show()
	totembar:SetBackdropColor(1,1,1,0)

	for index,totem in pairs(totembar.totems)do
		totem.duration:ClearAllPoints()
		totem.duration:SetFont(fontName, fontSize, fontOutline)
		totem.duration:SetPoint(settings.Timer.anchorFromPoint,totem.icon,settings.Timer.anchorToPoint,settings.Timer.anchorX,settings.Timer.anchorY)
		totem:SetScale(settings.scale)
	end
	
end


function addon:makeTotemBar(frame)
	if frame.unitClass ~= "SHAMAN" then return end
	self:Debug("<<CREATING TOTEM FRAME>>")
	local totembar = _G["TotemFrame"]
	totembar.totems={}
	for i=1,TotemFrame:GetNumChildren() do
		local totem = _G["TotemFrameTotem"..i]
		local bg = _G["TotemFrameTotem"..i.."Background"]
		local icon = _G["TotemFrameTotem"..i.."Icon"]
		local duration = _G["TotemFrameTotem"..i.."Duration"]
		local _,oldTotemOverlay = totem:GetChildren()
		bg:Hide()
		oldTotemOverlay:Hide()
		
		local totemOverlay = icon:CreateTexture(nil, "OVERLAY")
			  totemOverlay:SetTexture(frame.textures.border)
			  totemOverlay:SetAllPoints(icon)
			  totemOverlay:SetTexCoord(0, 1, 0, 1)
			  totemOverlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end

			duration:SetParent(totem)

			totem.overlay = totemOverlay
			totem.icon = icon
			totem.bg = bg
			totem.duration = duration
		totembar.totems[i] = totem
		
		frame.FontObjects["totem".. i .."Duration"] = {
			name = "Totem ".. i .." Timer Duration",
			object = totem.duration
		}
	end
	frame.bars.TotemBar = totembar
end

function RuneButton_OnEnter(self)
	if ( self.tooltipText ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltipText);
		GameTooltip:Show();
	end
end

function addon:StealBar(self,frame,settings)
	local db = addon.db.profile
	if frame:IsUserPlaced() then
		frame:SetUserPlaced(false) 
	end
	frame:ClearAllPoints()		
	frame:SetPoint(settings.anchorFromPoint, self.elements[settings.anchorTo], settings.anchorToPoint,settings.anchorX,settings.anchorY)
	frame:SetHeight(settings.height)
	frame:SetWidth(settings.width)
end

function UpDateFrameSize(self)
-- update bars dependant on frame size.
	for index,bar in pairs(self.db.bars)do
		if(bar.dependantOnFrameSize)then
			self.bars[index]:SetHeight( ((self.db.height - 3) / 100 ) * self.db.bars[index].height )
		end
	end
	oUF_PowerSpark_ReapplySettings(self)
end

function addon:makeFontObject(frame,name,data)
	local db = addon.db.profile	
	local parent = frame.elements and frame.elements[data.anchorTo] or frame
	
	-- make our font object, parenting it to the supplied anchor point.
	local fontObject = parent:CreateFontString(nil, "OVERLAY")
			  fontObject:SetJustifyH(data.justifyH)
			  fontObject:SetJustifyV(data.justifyV)
			  fontObject:SetPoint(data.anchorFromPoint, parent,data.anchorToPoint, data.anchorX, data.anchorY)

			  local fontDb = db.frames.font -- setting this to the global font option for now, till i work out a per-frame policy.
			  fontObject:SetFont((self.LSM:Fetch('font',fontDb.name) or self.db.profile.fonts.default), fontDb.size, fontDb.outline)

	-- if the parent frame is the unitframe and therefore has an UpdateTag function, use it.			
	if(frame.Tag~=nil and data.tag~=nil)then
		fontObject.tag = data.tag
		frame:Tag(fontObject, data.tag)
	end
	
	-- store the fontobject in the parent frames fontobject table.
	if(frame.FontObjects)then
		frame.FontObjects[name] = {
				name = data.desc,
				object = fontObject
		}
	end
	
	return fontObject
end

--==========================--
--							--
--		NORMAL STYLE		--
--							--
--==========================--

local layout = function(self, unit)
	local db = addon.db.profile	
	self.FontObjects = {}
	self.Indicators = {}
	self.db = db.frames.units[unit]
	self.colors = colors
	self.menu = menu
	_,self.unitClass = UnitClass(unit)
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("*type2", "menu")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self.BarFade =  self.db.barFading
	self.disallowVehicleSwap =  self.db.disallowVehicleSwap	
	self.ignoreHealComm = true
	
	self.textures = {
		background = db.textures.backgrounds[self.db.textures.background],
		statusbar = addon.LSM:Fetch('statusbar',self.db.textures.statusbar),
		border = db.textures.borders[self.db.textures.border],
		auraBorder = db.textures.borders[self.db.textures.border],
		auraOwnerBorder = db.textures.borders["slimbuff"],
	}
	self:SetBackdrop(self.textures.background)
	self:SetBackdropColor(unpack(db.colors.backdropColors))	
	self.elements={
		["parent"] = self,
		["UIParent"] = UIParent,
	}
--======--
--	BARS --
--======--
    self.bars = {}
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self,"TOPLEFT", 1,-1)
	health:SetPoint("TOPRIGHT", self,"TOPRIGHT",-1,-1)
	health:SetStatusBarTexture(self.textures.statusbar)
	health:SetHeight(((self.db.height - 3) / 100 ) * self.db.bars.Health.height)

	health.colorTapping =  self.db.bars.Health.colorTapping
	health.colorDisconnected =  self.db.bars.Health.colorDisconnected
	health.colorClass =  self.db.bars.Health.colorClass
	health.colorReaction =  self.db.bars.Health.colorReaction 	
	health.reverse = self.db.bars.Health.reverse

	health.bg = health:CreateTexture(nil, "BORDER")
	health.bg:SetAllPoints(health)
	local hpbg = self.db.bars.Health.bgColor
	health.bg:SetTexture(hpbg[1],hpbg[2],hpbg[3],hpbg[4])
	self.elements["Health"] = health
	self.bars.Health = health
	self.hcbParent = health
	self.Health = health
	
	local power = CreateFrame("StatusBar", nil, self)
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
	power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
	power:SetStatusBarTexture(self.textures.statusbar)
	power:SetHeight( ((self.db.height - 3) / 100 ) * self.db.bars.Power.height)

	power.colorTapping =  self.db.bars.Power.colorTapping
	power.colorDisconnected =  self.db.bars.Power.colorDisconnected
	power.colorClass =  self.db.bars.Power.colorClass
	power.colorReaction =  self.db.bars.Power.colorReaction 	
	power.reverse = self.db.bars.Power.reverse

	power.OnSizeChange=function(object)
		self.db.bars.Health.height = 100 - self.db.bars.Power.height
		self:OnSizeChange()
	end
	health.OnSizeChange=function(object)
		self.db.bars.Power.height = 100 - self.db.bars.Health.height
		self:OnSizeChange()
	end
	
	
	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	local ppbg = self.db.bars.Power.bgColor
	power.bg:SetTexture(ppbg[1],ppbg[2],ppbg[3],ppbg[4])
	self.elements["Power"] = power
	self.bars.Power = power
	self.Power = power
	
	for index, data in pairs(self.db.FontObjects) do
		self[index] = addon:makeFontObject(self,index,data)
	end
	
--[[
	if IsAddOnLoaded("oUF_SmeeAFK") and (unit ~= "targettarget" or unit ~= "focustarget") then
		self.AFK = {}
		self.AFK.object = health.text
		self.AFK.Tagger=self
		self.AFK.fontFormat = "|cFFFF0000AFK |cFFFFFFFF%s:%s"	

		self.DC = {}
		self.DC.object = health.text
		self.DC.Tagger=self
		self.DC.fontFormat = "|cFFFF0000D/C |cFFFFFFFF%s:%s"	
	end
--]]

--==========--
--	ICONS	--
--==========--
--Leader Icon
	self.Leader = health:CreateTexture(nil, "OVERLAY")
	self.Leader:SetPoint("TOPLEFT", self, 0, 4)
	self.Leader:SetHeight(10)
	self.Leader:SetWidth(10)
-- Raid Icon
	self.RaidIcon = health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("TOP", self, 0, 4)
	self.RaidIcon:SetHeight(10)
	self.RaidIcon:SetWidth(10)
--Master Loot Icon
	self.MasterLooter = health:CreateTexture(nil, "OVERLAY")
	self.MasterLooter:SetPoint("TOPLEFT", self, 8, 4)
	self.MasterLooter:SetHeight(10)
	self.MasterLooter:SetWidth(10)

	self:SetAttribute("initial-height", self.db.height)		-- Size
	self:SetAttribute("initial-width", self.db.width)		-- Size		
		
--==========--
--	PLAYER	--
--==========--
	if unit == "player" then
		self.Combat = health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(24)
		self.Combat:SetWidth(24)
		self.Combat:SetPoint("CENTER", self, "BOTTOMRIGHT", -5, 5)
		self.Combat:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.Combat:SetTexCoord(1/2, 1, 0.01, 0.5)

	-- Resting Icon
		self.Resting = health:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("TOP", self, 0, 8)
		self.Resting:SetHeight(16)
		self.Resting:SetWidth(16)
		self.Resting:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		self.Resting:SetTexCoord(0, 0.5, 0, 0.42)

		if IsAddOnLoaded("oUF_PowerSpark") then
			self.Spark = power:CreateTexture(nil, "OVERLAY")
			self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			self.Spark:SetVertexColor(1, 1, 1, 0.8)
			self.Spark:SetBlendMode("ADD")
			self.Spark:SetHeight(power:GetHeight()*4)
			self.Spark:SetWidth(power:GetHeight())
		end
		
		addon:makeRuneBar(self)
		addon:makeTotemBar(self)
		self.UpdateTotemBar = UpdateTotemBar
		self:UpdateTotemBar()		
		if IsAddOnLoaded("CoolLine") and self.db.bars.CoolLine then
			addon:StealBar(self,_G["CoolLine"],self.db.bars.CoolLine)
		end
		addon:makeAuraFrame(self,{"Buffs","Debuffs"})
	end

--=====================================--
--	PET 
--=====================================--
	
	if unit == "pet" then
		power.colorPower = true
		power.colorHappiness = true
		addon:makeAuraFrame(self,{"Buffs"})
--		makeComboPoints(self,"RIGHT","LEFT",-9, 3,38,"RIGHT")
	end
--=====================================--
--	PET TARGET
--=====================================--
	if unit == "pettarget" then
		power.colorPower = true
		addon:makeAuraFrame(self,{"Debuffs"})
--		makeComboPoints(self,"RIGHT","LEFT",-9, 3,38,"RIGHT")
	end
--===========--
--	TARGET   --
--===========--
	if unit == "target" then
		addon:makeAuraFrame(self,{"Debuffs","Buffs"})
		makeComboPoints(self,"RIGHT","LEFT",-9, 3,38,"RIGHT")
	end

--===========--
--	 FOCUS   --
--===========--
	if unit == "focus" then
		addon:makeAuraFrame(self,{"Buffs","Debuffs"})
	end

--=================--
--	 FOCUSTARGET   --
--=================--
	if unit == "focustarget" then
	end	
	
--=================--
--	 TARGETTARGET   --
--=================--
	if unit == "targettarget" then
	end	

--==============--
--	 CASTBARS   --
--==============--
	if unit and  self.db.bars.Castbar and  self.db.bars.Castbar.enabled then
		makeCastBar(self)
	end
--===============--
--	 RANGEFADING   --
--===============--
	self.outsideRangeAlpha = self.db.range.outside
	self.inRangeAlpha = self.db.range.inside
	self.SpellRange = self.db.range.enabled
	
--===================--
--	 AGRRO INDICATOR   --
--===================--
	if IsAddOnLoaded("oUF_Banzai") then
	  self.Banzai = updateBanzai
	  self.BanzaiIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	  self.BanzaiIndicator:SetPoint("TOPRIGHT", self, 0, 0)
	  self.BanzaiIndicator:SetHeight(4)
	  self.BanzaiIndicator:SetWidth(4)
	  self.BanzaiIndicator:SetTexture(1, .25, .25)
	  self.BanzaiIndicator:Hide()
	end
--==============--
--	 SMOOTH BARS   --
--==============--
	if IsAddOnLoaded("oUF_Smooth") then
		health.Smooth = true
		power.Smooth = true
	end
--=======================--
--	 DEBUFF HIGHLIGHTING   --
--=======================--
	if IsAddOnLoaded("oUF_DebuffHighlight") then 
		self.DebuffHighlightBackdrop = self.db.DebuffHighlightBackdrop
	end
	
--=======================--
-- 
--
	
--===============--
--	 EVENT HOOKS   --
--===============--
	self.OnSizeChange = UpDateFrameSize
	self.SetAuraPosition = SetAuraPosition
	self.PostCreateAuraIcon = PostCreateAuraIcon
	self.PostUpdateAuraIcon = PostUpdateAuraIcon
	self.PostUpdateHealth = PostUpdateHealth
	self.PostUpdatePower = PostUpdatePower
	self.CustomAuraFilter = customFilter
	
	self.PostCastStart = CastbarPostCastStart
	self.PostCastFailed = CastbarPostCastFailed
	self.PostCastInterrupted = CastbarPostCastInterrupted
	self.PostCastDelayed = CastbarPostCastDelayed
	self.PostCastStop = CastbarPostCastStop

	self.PostChannelStart = CastbarPostChannelStart
	self.PostChannelUpdate = CastbarPostChannelUpdate
	self.PostChannelStop = CastbarPostChannelStop

	self:SetAttribute("initial-scale", db.frames.scale)
	return self
end

function addon:Debug(msg)
	if not self.db.profile.enabledDebugMessages then return end
	self:Print("|cFFFFFF00Debug : |r"..msg)
end

function addon:Error(msg)
	self:Print("|cFFFF0000Error : |r"..msg)
end

function addon:HideBlizzard()
	local hide = self.db.profile.hideBlizzard
	if(hide.TemporaryEnchantFrame) then 
		TemporaryEnchantFrame:Hide()
		TemporaryEnchantFrame:UnregisterAllEvents()
	end
	if(hide.BuffFrame) then 
		BuffFrame:Hide()
		BuffFrame:UnregisterAllEvents()
	end
end

function addon:UpdateFontObject()
end

function addon:UpdateFontObjects(obj,size,name,outline)
	local db = self.db.profile
	
	if obj~=nil and obj.FontObjects then	
		for index,font in pairs(obj.FontObjects)do
			if(font.object:GetObjectType() == "FontString")then
				font.object:SetFont(addon.LSM:Fetch(addon.LSM.MediaType.FONT, db.frames.font.name),db.frames.font.size,db.frames.font.outline) 
			end
		end

	else

		if size~= nil then db.frames.font.size = size end
		if name~= nil then db.frames.font.name = name end
		if outline~= nil then db.frames.font.outline = outline end
		
		for index,frame in pairs(addon.units)do
			if frame.unit ~= nil then 
				self:UpdateFontObjects(frame)
			end
		end
	end
	
end


function addon:ImportSharedMedia()
	for name,path in pairs(self.db.profile.textures.statusbars)do
		self.LSM:Register(self.LSM.MediaType.STATUSBAR, name, path)
	end
	
	for name,path in pairs(self.db.profile.textures.borders)do
		self.LSM:Register(self.LSM.MediaType.BORDER, name, path)
	end
	
	for name,data in pairs(self.db.profile.fonts)do
		self.LSM:Register(self.LSM.MediaType.FONT, name, data.name)
	end
end

function addon:OpenConfig(input)
	if(not IsAddOnLoaded(layoutName..'_Config')) then
		LoadAddOn(layoutName..'_Config')
	end
	InterfaceOptionsFrame:Hide()
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(layoutName.."_Config", 700, 650)
	LibStub("AceConfigDialog-3.0"):Open(layoutName.."_Config")

end

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(layoutName.."DB",oUF_Smee_Settings)
	self.enabledDebugMessages = self.db.profile.enabledDebugMessages
	self.units = {}
	self.Layout = layout
	self:HideBlizzard()
	self:ImportSharedMedia()
	self:RegisterChatCommand("oufsmee", "OpenConfig")
end

function addon:OnEnable()
	
    -- Called when the addon is enabled
	local db = self.db.profile
	if not db.enabled then
		self:Debug("Disabling")
		self:Disable()
		return
	end

	self.AuraWhiteList={}
	self.AuraBlackList={}
	
	oUF:CompileTagStringLogic()
	self.enabledDebugMessages = false
	
	oUF:RegisterStyle("normal", self.Layout)
	oUF:SetActiveStyle("normal")

	for unit,data in pairs(db.frames.units)do
		self.units[unit] = oUF:Spawn(unit)
		self.units[unit]:SetPoint( data.anchorFromPoint, self.units[data.anchorTo] or UIParent, data.anchorToPoint, data.anchorX, data.anchorY)		
	end

end

function addon:OnDisable()
    -- Called when the addon is disabled
	db = self.db.profile
	if db.enabled then
		db.enabled = false
		return
	end
    self:Debug("Disabled")
end
