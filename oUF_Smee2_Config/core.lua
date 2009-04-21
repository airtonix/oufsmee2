local layoutName = 'oUF_Smee2'
local mod = _G[layoutName]
local configModName = layoutName..'_Config'
_G[configModName] = LibStub("AceAddon-3.0"):NewAddon(configModName, "AceConsole-3.0")
local configMod = _G[configModName]
configMod.mod = mod



--======================--
--==<<	ACE3 SETUP	>>==--
--======================--
function configMod:round(num, idp)
  if idp and idp>0 then  return math.floor(num * mult + 0.5) / (10^idp)  end
  return math.floor(num + 0.5)
end
function configMod:numberize(val)
	if(val >= 1e3) then
		return ("%.1fk"):format(val / 1e3)
	elseif (val >= 1e6) then 
		return ("%.1fm"):format(val / 1e6)
	else
		return val
	end
end

function configMod:Debug(msg)
	if not mod.db.profile.enabledDebugMessages then return end
	self:Print("|cFFFFFF00Debug : |r"..tostring(msg))
end

function configMod:OnInitialize()
end

function configMod:OnEnable()
	self:Debug("Enabling")
	self:SetupUnitOptions(mod.units)
	self:SetupTagOptions(oUF.TagsLogicStrings)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(configModName, self.options,layoutName)
	-- RegisterOptions("Profiles", LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db))
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(configModName, layoutName)
	self:Debug("Enabled")
end

function configMod:OnDisable()
 	self:Debug("Disabling")
   -- Called when the addon is disabled
	db = self.db.profile
	if db.enabled then
		db.enabled = false
		return
	end
    self:Debug("Disabled")
end

