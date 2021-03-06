local layoutName = 'oUF_Smee2'
local addon = _G[layoutName]
local configAddonName = layoutName..'_Config'
local configAddon = _G[configAddonName]
local tinsert = table.insert
local db = addon.db.profile
local oUF = Smee2_oUFEmbed

GlobalObject = {}

configAddon.growthYDirections= {
	UP = "UP",
	DOWN = "DOWN",
}
configAddon.growthXDirections= {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}
configAddon.frameAnchorPoints = {
	TOPLEFT = "TOPLEFT", TOP = "TOP", TOPRIGHT = "TOPRIGHT",
	LEFT = "LEFT", CENTER = "CENTER", RIGHT = "RIGHT",
	BOTTOMLEFT = "BOTTOMLEFT", BOTTOM = "BOTTOM", BOTTOMRIGHT = "BOTTOMRIGHT"
}
configAddon.frameLevelOptions = function()
	local frameLevels = {}
	for i=0,40 do
		frameLevels[i] = tostring(i)
	end
	return frameLevels
end
configAddon.frameStrataOptions = {
	TOOLTIP = "TOOLTIP",
	FULLSCREEN_DIALOG = "FULLSCREEN_DIALOG",
	FULLSCREEN ="FULLSCREEN",
	DIALOG = "DIALOG",
	HIGH = "HIGH",
	MEDIUM = "MEDIUM",
	LOW = "LOW",
	BACKGROUND = "BACKGROUND",
}
configAddon.textHorizontalAlignmentPoints={
	LEFT = "LEFT", CENTER = "CENTER", RIGHT ="RIGHT"
}
configAddon.textVerticalAlignmentPoints={
	TOP = "TOP", MIDDLE = "MIDDLE", BOTTOM = "BOTTOM"
}
configAddon.fontOutlineTypes={
	NONE = "None",
	OUTLINE = "OUTLINE",
	THICKOUTLINE = "THICKOUTLINE",
	THINOUTLINE = "THINOUTLINE",
	MONOCHROME = "MONOCHROME"
}

configAddon.resizeRules = {
	["Height"] = {
		['Power'] = function(obj,num)
			 return ((obj:GetParent().db.height - 3) / 100 ) * num
		end,
		['Health'] = function(obj,num)
			 return ((obj:GetParent().db.height - 3) / 100 ) * num
		end,
		['Castbar'] = function(obj,num)
			return num
		end,
		['RuneBar'] = function(obj,num)
			return ((obj:GetParent().db.height - 3) / 100 ) * num
		end,
		['TotemBar'] = function(obj,num)
			return num
		end,
	},
	["Width"] = {
		['Power'] = function(obj,num)
			return obj:GetWidth()
		end,
		['Health'] = function(obj,num)
			return obj:GetWidth()
		end,
		['Castbar'] = function(obj,num)
			return num
		end,
		['RuneBar'] = function(obj,num)
			return ((obj:GetParent().db.width - 3) / 100 ) * num
		end,
		['Totembar'] = function(obj,num)
			return num
		end,
	}
}

function configAddon:BarPowerColourRepresentTypes(groupName)
	local types = {
		colorTapping			= "... tapped by others",
		colorDisconnected	= "... unit is offline",
		colorHappiness		= "... happiness (pets)",
		colorClass				= "... class colour (player)",
		colorClassPet			= "... class colour (pets)",
		colorClassNPC			= "... class colour (npc)",
		colorReaction			= "... reaction of the unit",
		colorSmooth			= "... bar percentage",
	}

	if(groupName == "Power")then
		table.insert(types, { 	colorPower= "... the power type" })
	elseif(groupName == "Health")then
		table.insert(types, { colorHealth = "... health" })
	end
	
	return types
end

function configAddon:UpdateTextures(object,data)
	local textures = addon.db.profile.textures
	local texture = addon.LSM:Fetch('statusbar',data.statusbar)

	for bar,obj in pairs(object.bars)do 			
		obj:SetStatusBarTexture(texture)
		if(bar == 'Castbar' and obj.SafeZone)then 
			obj.SafeZone:SetTexture(texture)
		end
	end
	
end

--------------------------------
-- PLAYERFRAME ANCHOR OBJECTS
-- : Builds and returns a valid ace3config table to be used in a select widget

function configAddon:PlayerFramesToAnchorTo()
	local AnchorToFrames = {}
	for frame, object in pairs(addon.units)do
		AnchorToFrames[frame] = frame
	end
	AnchorToFrames['UIParent'] = 'UIParent'
	return AnchorToFrames
end

function configAddon:UnitFrameAnchorElements(frame)
	local AnchorToFrames = {}
	for frame, object in pairs(frame.elements)do
		AnchorToFrames[frame] = frame
	end
	return AnchorToFrames
end
-------------------------------
-- Debug Exploder
-- : Explodes and joins the info table passed around in the ace3config gui

function configAddon:concatLeaves(branch)
	local picture = ""
		for index,value in pairs(branch) do
			picture = picture .. "["..index.."] - "..tostring(value).."\n"
		end
	return picture
end

function configAddon:SetupUnitOptions(table)
	for index,frame in pairs(table)do
		if frame.unit ~= nil then 
			self.options.args['frames'].args['units'].args[index] = self:AddUnitOptionSet(frame)
			self:Debug("Inserting Option Config for : "..frame.unit)
		end
	end	
end

function configAddon:SetupProfileOptions(table)
	self.options.args['profiles'].args = table
end

--	MANUPILATORS
function configAddon:ScaleObject(obj,value)
	if obj~=nil then
		obj:SetScale(db.frames.scale)
	else
		db.frames.scale = value
		for index,frame in pairs(oUF.objects)do
			if(frame.unit ~= nil) then
				self:ScaleObject(frame)
			end
		end
	end
end
function configAddon:MoveObject(object,setting)
	if(object ~= nil) then
		local anchorTo = setting.anchorTo 
		local parentElements = object:GetParent().elements
		if(anchorTo == nil or anchorTo == 'parent')then
			anchorTo = object:GetParent()
		elseif parentElements and parentElements[anchorTo] then
			anchorTo = parentElements[anchorTo]
		elseif(oUF.units[anchorTo])then
			anchorTo = oUF.units[anchorTo]
		else
			anchorTo = UIParent
		end 
		object:ClearAllPoints()
		object:SetPoint(setting.anchorFromPoint,anchorTo,setting.anchorToPoint,setting.anchorX,setting.anchorY)
		if(setting.frameStrata)then object:SetFrameStrata(setting.frameStrata or "LOW") end
		if(setting.frameLevell)then object:SetFrameLevel(setting.frameLevel or object:GetFrameLevel() or 1) end
	end	
end

function configAddon:UpdateBars(frame)
	if frame.bars then 
		for index,bar in pairs(frame.bars)do
			frame:UpdateElement(index)
		end
	end
end

function configAddon:SizeObject(object,settings,parent)	
	if(object ~= nil) then		
		local widthRule = configAddon.resizeRules["Width"][parent] and configAddon.resizeRules["Width"][parent](object,settings.width) or settings.width
		local heightRule =  configAddon.resizeRules["Height"][parent] and configAddon.resizeRules["Height"][parent](object,settings.height)  or settings.height
		object:SetWidth(widthRule)
		object:SetHeight(heightRule)
		if(object.OnSizeChange) then object:OnSizeChange(object) end
	end
end

function configAddon:SetFontType(obj)
	addon:UpdateFontObjects(obj)
end

function configAddon:SetDefaultFontType(size,name,outline)
	local fontDb = db.frames.font
	fontDb.size = size~=nil and size or fontDb.size
	fontDb.name = name~=nil and name or fontDb.name
	fontDb.outline = outline~=nil and outline or fontDb.outline
	self:SetFontType()
end

function configAddon:SetAuraTimeFormat(value)
	db.auras.timers.UsingMMSS = value
end
function configAddon:ToggleAuraTimers(value)
	db.auras.timers.enabled = value
end

function configAddon:GetAuraRows(obj)
	local extra = mod(obj.num,obj.Colomns) > 0 and 1 or 0
	local rows = math.floor(obj.num/obj.Colomns)
	return rows + extra
end

function configAddon:SetAuraFontOptions(obj,size,name,outline)
	local fontDb = addon.db.profile.auras.font
	self:Debug(size,name,outline)
	 fontDb.size = size or fontDb.size
	 fontDb.name = name or fontDb.name
	 fontDb.outline = outline or fontDb.outline
	 
--	 for index,unit in pairs(addon.units)do
--	 	if unit.Buffs then end
--	 end
end

-- We don't really need to validate much here as the filter should prevent us
-- from doing something we shouldn't.
local OnClick = function(self)
	CancelUnitBuff(self.frame.unit, self:GetID(), self.filter)
end

local createAuraIcon = function(self, icons, index, debuff)
	local button = CreateFrame("Button", nil, icons)
	button:EnableMouse(true)
	button:RegisterForClicks'RightButtonUp'

	button:SetWidth(icons.size or 16)
	button:SetHeight(icons.size or 16)

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
	overlay:SetAllPoints(button)
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	button.overlay = overlay

	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)

	if(self.unit == 'player') then
		button:SetScript('OnClick', OnClick)
	end

	table.insert(icons, button)

	button.parent = icons
	button.frame = self
	button.debuff = debuff

	button.icon = icon
	button.count = count
	button.cd = cd

	if(self.PostCreateAuraIcon) then self:PostCreateAuraIcon(button, icons, index, debuff) end

	return button
end

function configAddon:ToggleAuraConfigMode(object,value)
	local num = object.visibleAuras or object.visibleBuffs or object.visibleDebuffs or 0
	local icon, name, rank, texture, count, dtype, duration, timeLeft
	if value then
		for i=1,40 do
			duration = math.random(60,800)
			timeLeft = math.random(1,duration)
	
			if(object[i]==nil)then
				icon = createAuraIcon(object.parent, object, i, false)
				icon:SetID(i)
				object[i] = icon
			end
			object[i].duration = duration
			object[i].timeleft = timeleft
			object[i].cd:SetCooldown(timeLeft, duration)
			--icon.filter = nil
			object[i].debuff = false
			object[i].icon:SetTexture("Interface\\Icons\\"..self.FakeIcons[math.random(1,#configAddon.FakeIcons-1)])
			object[i].owner = math.random(1,2)==1 and "player" or "raid3"
			object[i]:Show()				
		end
	else
		for i=1,40 do
			if i > num and object[i] then
				object[i]:Hide()
			end
		end
	end

	object.setup = value
	object:GetParent():UpdateElement('Aura')	
end

function configAddon:adjustAuraFrame(object,setting,value)
	self:Debug("adjustAuraFrame("..tostring(object)..","..setting..","..value..")")
	object[setting]=value

	if(setting == "count") then 
		if(object.num ~= value) then
			for index,obj in pairs({object:GetChildren()})do
				obj:Hide()
			end
		end
		object.num = value
	elseif(setting == "growth-x" or setting == "growth-y")then		
--
	end

	--background helper sizing.
	object:SetHeight(object.size * self:GetAuraRows(object))
	object:SetWidth(object.size * object.Colomns)
	object:GetParent():UpdateElement('Aura')
end

function configAddon:Orientation(obj,value)
		if(obj.SetChildOrientation) then 
			obj:SetChildOrientation(value)
		else
			obj:SetOrientation(value)
		end
end

function configAddon:EnableObject(obj,value)
	if value == true then 
		obj:Show()
		if obj.SetupEnabled then obj.SetupEnabled(obj) end
	else
		obj:Hide()
		if obj.SetupDisabled then obj.SetupDisabled(obj) end
	end
end


function configAddon:PositionFontObject(object,settings)
	object:ClearAllPoints()
	object:SetJustifyH(settings.justifyH)
	object:SetJustifyV(settings.justifyV)
--	local font,size,outline = object:GetFontObject()
--	object:SetFont(settings.fonts.name, settings.fonts.size, settings.fonts.outline)
	object:SetPoint(settings.anchorFromPoint, object.parent.elements[settings.anchorTo], settings.anchorToPoint, settings.anchorX, settings.anchorY)
	self:Debug(' tag : '..settings.tag)
	object.parent:Tag(object, settings.tag)	
	object:UpdateTag()
end

function configAddon:UpdateTagEvents(object,tagstr)
	-- Forcefully strip away any parentheses and the characters in them.
	self:Print("Attempting : "..tagstr)
	local tagEvents = oUF.TagEvents
	tagstr = tagstr:gsub('%b()', '')
	for tag in tagstr:gmatch'[%[]%w+[%]]' do
		local tagevents = tagEvents[tag]
		if(tagevents) then
			for event in tagevents:gmatch'%S+' do
				self:Print(event)
				oUF.RegisterTagEvent(object, event)
			end
		end
	end
end

-- GETTERS & SETTERS
function configAddon:getOptionValue(info)
	
	local value = ''
	local key = info[#info]
	local parentKey = info[#info-1]
	local section = 'default'

	self:Debug(parentKey,key,info['arg'])

	value = db[key]

	if( key == "minimapicon" )then
		value = not db.minimapicon.hide
	elseif key == "enabledDebugMessages" then
		value = db.enabledDebugMessages
	end
	
	if(parentKey == "font")then
		if(info['arg']=='global-aura')then 
			value = db.auras.font[key]
		else
			value = db.frames.font[key]
		end
	elseif(parentKey == "units")then
		if(key == "lock")then
			value = db.frames.locked
		elseif(key == "scale") then
			value = db.frames.scale
		end
	elseif(parentKey == "auras")then
		if(key == "timers")then
			value = db.auras.timers.enabled
		elseif(key == "format")then
			value = db.auras.timers.UsingMMSS
		end
	end
	
	self:Debug("get : "..self:concatLeaves(info) .. " : "..tostring(args))

	return value
end

function configAddon:setOptionValue(info,value)
	local key = info[#info]
	local parentKey = info[#info-1]
	self:Debug("\nset : " .. self:concatLeaves(info) )
	
	if(key == "enabledDebugMessages")then
		db.enabledDebugMessages = value
	elseif key == "minimapicon" then
		db.minimapicon.hide = not value
		if(db.minimapicon.hide)then
			self.addon.MinimapIcon:Hide(layoutName)
		else
			self.addon.MinimapIcon:Show(layoutName)
		end
	end

	if(parentKey)then
		if(parentKey == "font")then
			-- (obj,size,name,outline)
			if(key == "size")then
				--change fontsize
				if(info['arg']=='global-aura')then 
					self:SetAuraFontOptions(nil,value,nil,nil)
				else
					self:SetDefaultFontType(value,nil,nil)
				end
			elseif(key == "name")then
				--change fonttype
				if(info['arg']=='global-aura')
					then self:SetAuraFontOptions(nil,nil,value,nil)
				else
					self:SetDefaultFontType(nil,value,nil)
				end
			elseif(key == "outline")then
				--change fontoutline
				if(info['arg']=='global-aura')then
					self:SetAuraFontOptions(nil,nil,nil,value) 
				else
					self:SetDefaultFontType(nil,nil,value)
				end
			end			
		elseif(parentKey == "units")then
			if(key == "lock") then
				addon:ToggleFrameLock(nil,value)
			elseif(key == "scale") then
				self:ScaleObject(nil,value)
			end
		elseif(parentKey == "auras")then
			if(key == "timers")then
				self:ToggleAuraTimers(value)
			elseif(key == "format")then
				self:SetAuraTimeFormat(value)
			end
		end		
	else
		--
	end	
end

-- Handling of the frames.units[unitName]
-- GET--
function configAddon:GetUnitFrameOption(info)
	local object = info['arg']
	local profile = addon.db.profile
	local setting = info[#info]
	local output = profile

	for i=1,#info-1 do
		if(info[i]~=nil and output ~=nil)then
			output = output[info[i]];
		end
	end
	
	self:Debug("\nGetUnitFrameOption : "..self:concatLeaves(info))
	return output[setting]
end

function configAddon:CheckDebuffHighlighting(info)
	self:Debug("\nCheckDebuffHighlighting : "..self:concatLeaves(info))
	return not info['arg'].db.DebuffHighlight.enabled
end

function configAddon:ToggleDebuffHighlighting(frame,setting,value)
	local unitDb = db.frames.units[frame.unit]

	if(not unitDb.DebuffHighlight.enabled)	then
		frame:SetBackdropColor(unpack(db.colors.backdropColors))	
		frame:SetBackdropBorderColor(unpack(db.colors.backdropColors))	
		
--		frame.DebuffHighlight:Hide() 
		frame.DebuffHighlightBackdrop = false
--		frame.DebuffHighlightUseTexture = false
	else
		frame.DebuffHighlightBackdrop = unitDb.DebuffHighlight.Backdrop
--		frame.DebuffHighlightUseTexture = unitDb.DebuffHighlight.Icon
	end
	
end

-- SET--
function configAddon:SetUnitFrameOption(info,value)
	local frame = info['arg']
	local profile = frame.db
	local setting = info[#info]
	local output,object = nil,frame
	self:Debug("\nSetUnitFrameOption : "..self:concatLeaves(info))
	local parent = info[#info-1]	
	
	if(#info >= 4)then output = profile; end
	if(#info >= 5)then output = output[info[4]];object = frame[info[4]]; end	
	if(#info >= 6)then output = output[info[5]];object = object[info[5]]; end
	if(#info >= 7)then output = output[info[6]];object = object[info[6]]; end
	if(#info >= 8)then output = output[info[7]];object = object[info[7]]; end

	output[setting] = value

	if(setting == "height" or setting == "width" )then
		self:SizeObject(object,output,parent)
	elseif(setting == "scale" or setting == "anchorX" or setting == "anchorY" or setting == "anchorFromPoint" or setting == "anchorToPoint" or setting == "frameLevel" or setting == "frameStrata" )then
		if setting == "scale" or parent == "Timer" then
			frame:UpdateTotemBar()
		else	
			self:MoveObject(object,output)
		end	
	elseif info[#info-1]=="DebuffHighlight" then
	
		if setting == "Backdrop" then
			output.Icon = not value
		elseif setting == "Icon" then
			output.Backdrop = not value
		end

		self:ToggleDebuffHighlighting(frame,setting,value)
	elseif(setting == "growth-x" or setting == "growth-y") or (setting=="Colomns" or setting =="Rows" or setting =="size" or setting =="playerSize" or setting=="spacing")then
		self:adjustAuraFrame(object,setting,value)
	elseif(setting == "orientation")then
		self:Orientation(value)
	elseif(setting == "count")then 
		self:adjustAuraFrame(object,setting,value)
	elseif setting == "enabled" then
		self:EnableObject(object,value)
	elseif setting == "inRangeAlpha" or setting == "outsideRangeAlpha" then
		object.setting = value
	elseif setting == "reverse" then
		self:UpdateBars(frame)
	elseif setting == "accurate" then
		frame.bars.Castbar.SafeZone.accurate = value
		self:UpdateBars(frame)
	elseif setting == "setup" then
		self:ToggleAuraConfigMode(object,value)
	elseif parent =="textures" then
		self:UpdateTextures(frame,output)
	end
	
end

function configAddon:GetUnitFrameFontObjectOption(info)

end

function configAddon:SetUnitFrameFontObjectOption(info,value)
	local object = addon
	local profile = addon.db.profile
	local setting = info[#info]
	local output = profile
	local leafNumbers = #info-1
	
	for i=1,leafNumbers do
		if(info[i]~=nil and output ~=nil)then
			output = output[info[i]];
			if(i < leafNumbers) then 
				object = object[ info[i+1] ] 
			end
		end
	end
	output[setting] = value

	self:PositionFontObject(object.object, output)
	self:SetFontType(object.object)

	self:Debug("\nSetUnitFrameFontObjectOption :\n "..self:concatLeaves(info))
end

-- Handling of the frames.units[unitName]
-- GET--
function configAddon:GetColourOption(info)
	local object = info['arg']
	local profile = object.db
	local setting = info[#info]
	local output
	
	if(#info >= 4)then output = profile end
	if(#info >= 5)then output = output[info[4]] end	
	if(#info >= 6)then output = output[info[5]] end
	if(#info >= 7)then output = output[info[6]] end
	if(#info >= 8)then output = output[info[7]] end

	local r, g, b,a = unpack( output[setting] )
	self:Debug("\nGetColourOption  : "..self:concatLeaves(info) .. " : " ..tostring(r, g, b,a))
	return r,g,b,a
end
-- SET--
function configAddon:SetColourOption(info,r,g,b,a)
	local object = info['arg']
	local profile = object.db
	local setting = info[#info]
	local parent =  info[#info-1]
	local output

	if(#info >= 4)then output = profile; end
	if(#info >= 5)then output = output[info[4]];object = object[info[4]]; end	
	if(#info >= 6)then output = output[info[5]];object = object[info[5]]; end
	if(#info >= 7)then output = output[info[6]];object = object[info[6]]; end
	if(#info >= 8)then output = output[info[7]];object = object[info[7]]; end

	output[setting]={r,g,b,a}
	if setting == 'bgColor' then
		object.bg:SetTexture(r,g,b,a)
	elseif setting == 'StatusBarColor' then
		object:SetStatusBarColor(r,g,b,a)
	elseif setting == 'colour' and parent=='SafeZone'  then
		object:SetVertexColor(r,g,b,a)
	end

	self:Debug("\nsetColourOption  : "..self:concatLeaves(info) ..tostring(r, g, b,a))
end

--FontTags--
--GET--
function configAddon:GetFontObjectTag(info)
	local object = info['arg']
	local setting = info[#info]

	self:Debug("\nGetFontObjectTag  :\n "..self:concatLeaves(info))

	return "text"
end
--SET--
function configAddon:SetFontObjectTag(info,value)
	local object = info['arg']
	local profile = object.db
	local setting = info[#info]
	local output 

	if(#info >= 4)then output = profile; end
	if(#info >= 5)then output = output[info[4]];object = object[info[4]]; end	
	if(#info >= 6)then output = output[info[5]];object = object[info[5]]; end
	if(#info >= 7)then output = output[info[6]];object = object[info[6]]; end
	if(#info >= 8)then output = output[info[7]];object = object[info[7]]; end

	self:Debug("\nSetFontObjectTag  :\n "..self:concatLeaves(info))

	output[setting] = value
end

--SET--
function configAddon:GetTagOption(info)
	self:Debug("\nGetTagOption  :\n "..self:concatLeaves(info))
	local arg,setting, hash = info['arg'],info[#info],{
		['inputTagString'] = function(tag) return tag end,
		['inputTagFunc'] = function(tag) return oUF.TagsLogicStrings[tag] end,
		['inputTagEvents'] = function(tag) return oUF.TagEvents[tag] end,
	}
	return hash[setting](arg)
end
--SET--
function configAddon:SetTagOption(info,value)
	self:Debug("\nSetTagOption  :\n "..self:concatLeaves(info))
	local tag,setting, hash =info[#info-1],info[#info],{
		['inputTagString'] = function(tag,value) 
			self:Debug(" tag moniker : "..tag.." = ".. value .." \"this is supposed to rename the tagstring or create a new one\" ")
		end,
		['inputTagFunc'] = function(tag,value)
			oUF.TagsLogicStrings[tag] = value
			oUF:ReWriteTag(tag,nil,value)
		end,
		['inputTagEvents'] = function(tag,value)
			 oUF.TagEvents[tag] = value
			 oUF:ReWriteTag(tag,value,nil)
		end,
	}
	hash[setting](tag,value)
end

-- VALIDATE--
function configAddon:CheckUnitFrameOption(info)
	return false
end

--==========================
-- GET PROFILE UI



