local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local damage_format = "-%d"
local heal_format = "+%d"
local maxAlpha = 0.6
local updateFrame
local feedback = {}
local originalHeight = {}
local function createUpdateFrame()
	if updateFrame then return end
	updateFrame = CreateFrame("Frame")
	updateFrame:Hide()
	updateFrame:SetScript("OnUpdate", function()
		if next(feedback) == nil then
			updateFrame:Hide()
			return
		end
		for object, startTime in pairs(feedback) do
			local maxalpha = object.CombatFeedbackText.maxAlpha
			local elapsedTime = GetTime() - startTime
			if ( elapsedTime < COMBATFEEDBACK_FADEINTIME ) then
				local alpha = maxalpha*(elapsedTime / COMBATFEEDBACK_FADEINTIME)
				object.CombatFeedbackText:SetAlpha(alpha)
			elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME) ) then
				object.CombatFeedbackText:SetAlpha(maxalpha)
			elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME + COMBATFEEDBACK_FADEOUTTIME) ) then
				local alpha = maxalpha - maxalpha*((elapsedTime - COMBATFEEDBACK_HOLDTIME - COMBATFEEDBACK_FADEINTIME) / COMBATFEEDBACK_FADEOUTTIME)
				object.CombatFeedbackText:SetAlpha(alpha)
			else
				object.CombatFeedbackText:Hide()
				feedback[object] = nil
			end
		end		
	end)
end

local function combat(self, event, unit, eventType, flags, amount, dtype)
	if unit ~= self.unit then return end
	local FeedbackText = self.CombatFeedbackText
	local font, fontHeight, fontFlags = FeedbackText:GetFont()
	fontHeight = FeedbackText.origHeight -- always start at original height
	local text, arg
	local r,g,b = 1,1,1
	if eventType == "IMMUNE" and not FeedbackText.ignoreImmune then
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[eventType]
	elseif eventType == "WOUND" and not FeedbackText.ignoreDamage then
		if amount ~= 0 then
			if flags == "CRITICAL" or flags == "CRUSHING" then
				fontHeight = fontHeight * 1.5
			elseif flags == "GLANCING" then
				fontHeight = fontHeight * 0.75
			end
			r = 1.0
			g = 0.0
			b = 0.0
			text = damage_format
			arg = amount
		elseif flags == "ABSORB" then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["ABSORB"]
		elseif flags == "BLOCK" then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["BLOCK"]
		elseif flags == "RESIST" then
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["RESIST"]
		else
			text = CombatFeedbackText["MISS"]
		end
	elseif eventType == "BLOCK" and not FeedbackText.ignoreDamage then
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[eventType]
	elseif eventType == "HEAL" and not FeedbackText.ignoreHeal then
		text = heal_format
		arg = amount
		r = 0.0
		g = 1.0
		b = 0.0
		if flags == "CRITICAL" then
			fontHeight = fontHeight * 1.3
		end
	elseif event == "ENERGIZE" and not FeedbackText.ignoreEnergize then
		text = amount
		r = 0.41
		g = 0.8
		b = 0.94
		if flags == "CRITICAL" then
			fontHeight = fontHeight * 1.3
		end
	elseif not FeedbackText.ignoreOther then
		text = CombatFeedbackText[eventType]
	end

	if text then
		FeedbackText:SetFont(font,fontHeight,fontFlags)
		FeedbackText:SetFormattedText(text, arg)
		FeedbackText:SetTextColor(r, g, b)
		FeedbackText:SetAlpha(0)
		FeedbackText:Show()
		feedback[self] = GetTime()
		updateFrame:Show() -- start our onupdate
	end
end
oUF.UNIT_COMBAT = combat

local function addCombat(object)
	if not object.CombatFeedbackText then return end
	-- store the original starting height
	local font, fontHeight, fontFlags = object.CombatFeedbackText:GetFont()
	object.CombatFeedbackText.origHeight = fontHeight
	object.CombatFeedbackText.maxAlpha = object.CombatFeedbackText.maxAlpha or maxAlpha
	createUpdateFrame()
	object:RegisterEvent("UNIT_COMBAT")
end

for k, object in ipairs(oUF.objects) do addCombat(object) end
oUF:RegisterInitCallback(addCombat)
