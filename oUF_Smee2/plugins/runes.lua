--[[

	Elements handled:
	 .RuneBar [fontstring or table]

	FontString only:
	- space: The space between each "counter". (Default: " ")
	- symbol: The symbol used when cooldowns are over. (Default: "*")
	- interval: The time offset used for the update script. (Default: 0.5)

--]]
local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local localized, class = UnitClass('player')
local dummy = CreateFrame('Frame')
local colors = {
	[1] = {0.77, 0.12, 0.23},
	[2] = {0.3, 0.8, 0.1},
	[3] = {0, 0.4, 0.7},
	[4] = {0.8, 0.8, 0.8},
}

local OnUpdateBar, OnUpdateText
do
	local total = 0
	function OnUpdateText(self, elapsed)
		total = total + elapsed

		if(total >= (self.bars.RuneBar.interval or 0.5)) then
			self:UpdateElement('RuneBar')
			total = 0
		end
	end

	function OnUpdateBar(self, rune)
		local start, duration, ready = GetRuneCooldown(rune)

		if(ready) then
			self:SetValue(1)
			self:SetScript('OnUpdate', nil)
		else
			self:SetValue((GetTime() - start) / duration)
		end
	end
end	

local function UpdateStatusBar(self, event, rune, usable)
	if(rune and not usable and GetRuneType(rune)) then
		self.bars.RuneBar.bars[rune]:SetScript('OnUpdate', function(self) OnUpdateBar(self, rune) end)
	end
end

local function Update(self, event, rune)
	local runebar = self.bars.RuneBar
	if(#runebar.bars == 0) then
		local text = ''
		for i = 1, 6 do
			local start, duration, ready, temp = GetRuneCooldown(i)
			local r, g, b = unpack(runebar.colors[GetRuneType(i)])

			local temp = ready and (runebar.symbol or '*') or (duration - math.floor(GetTime() - start))
			text = string.format('%s|cff%02x%02x%02x%s%s|r', text, r * 255, g * 255, b * 255, temp, runebar.space or ' ')
		end

		runebar:SetText(text)
	else
		for i = 1, 6 do
			local runetype = GetRuneType(i)
			if(runetype) then
				runebar.bars[i]:SetStatusBarColor(unpack(runebar.colors[runetype]))
			end
		end
	end
end

local function Enable(self, unit)
	if not (unit == 'player' and class == 'DEATHKNIGHT') then return end
	if(self.bars and 	self.bars.RuneBar)then
		local runebar = self.bars.RuneBar

		if(not runebar.colors) then 
			runebar.colors = self.colors.runes or colors
		end

		self:RegisterEvent('RUNE_TYPE_UPDATE', Update)

		if(#runebar.bars == 0) then
			self:RegisterEvent('RUNE_POWER_UPDATE', Update)
			dummy:SetScript('OnUpdate', function(s, e) OnUpdateText(self, e) end)
		else
			self:RegisterEvent('RUNE_POWER_UPDATE', UpdateStatusBar)
		end

		RuneFrame:Hide()

		return true
	end
end

local function Disable(self)
	local runebar = self.bars.RuneBar
	if(runebar) then
		self:RegisterEvent('RUNE_TYPE_UPDATE', Update)

		if(#runebar == 0) then
			self:UnregisterEvent('RUNE_POWER_UPDATE', Update)
			dummy:SetScript('OnUpdate', nil)
		else
			self:UnregisterEvent('RUNE_POWER_UPDATE', UpdateStatusBar)
		end

		RuneFrame:Show()
	end
end

oUF:AddElement('RuneBar', Update, Enable, Disable)
