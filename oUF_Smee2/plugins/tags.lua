local oUF = Smee2_oUFEmbed
assert(oUF, 'oUF not loaded')

oUF.TagEvents["[status]"] = "UNIT_HEALTH PLAYER_UPDATE_RESTING PLAYER_FLAGS_CHANGED"
oUF.TagEvents["[afk]"] = "UNIT_HEALTH PLAYER_UPDATE_RESTING PLAYER_FLAGS_CHANGED"
oUF.TagEvents["[shortName]"] = "UNIT_NAME_UPDATE"

-- TODO: 
--  oUF.TagsLogicStrings = {
--  	[tag] = {
--			[name]		= [[function(u) end]],
--			[event]	= ""
-- 	}
-- }

oUF.TagsLogicStrings = {
	["[class]"]       			= [[function(u) return UnitClass(u) end]],
	["[creature]"]    		= [[function(u) return UnitCreatureFamily(u) or UnitCreatureType(u) end]],
	["[curhp]"]       		= [[UnitHealth]],
	["[curpp]"]       		= [[UnitPower]],
	["[dead]"]        		= [[function(u) 
 return UnitIsDead(u) and "Dead" or UnitIsGhost(u) and "Ghost"
end]],
	["[difficulty]"]  		= [[function(u)
 if UnitCanAttack("player", u) then 
  local l = UnitLevel(u);
  return Hex(GetDifficultyColor((l > 0) and l or 99))
 end
end]],
	["[faction]"]     		= [[function(u) return UnitFactionGroup(u) end]],
	["[leader]"]      		= [[function(u) return UnitIsPartyLeader(u) and "(L)" end]],
	["[leaderlong]"]  	= [[function(u) return UnitIsPartyLeader(u) and "(Leader)" end]],
	["[level]"]       			= [[function(u) 
 local l = UnitLevel(u);
 return (l > 0) and l or "??"
end]],
	["[maxhp]"]       		= [[UnitHealthMax]],
	["[maxpp]"]       		= [[UnitPowerMax]],
	["[missinghp]"]   	= [[function(u) m=UnitHealthMax(u) - UnitHealth(u); return m>0 and m.. " | " or "" end]],
	["[missingpp]"]   	= [[function(u) m=UnitPowerMax(u) - UnitPower(u); return m>0 and m.. " | " or "" end]],
	["[name]"]        		= [[function(u, r) return UnitName(r or u) end]],
	["[shortname]"]		= [[function(u) return string.sub(UnitName(u),1,4) or '' end]],
	["[offline]"]     		= [[function(u) return  (not UnitIsConnected(u) and "Offline") end]],
	["[perhp]"]       		= [[function(u) local m = UnitHealthMax(u); return m == 0 and 0 or math.floor(UnitHealth(u)/m*100+0.5) end]],
	["[perpp]"]       		= [[function(u) local m = UnitPowerMax(u); return m == 0 and 0 or math.floor(UnitPower(u)/m*100+0.5) end]],
	["[plus]"]        			= [[function(u) return UnitIsPlusMob(u) and "+" end]],
	["[pvp]"]         			= [[function(u) return UnitIsPVP(u) and "PvP" end]],
	["[race]"]        		= [[function(u) return UnitRace(u) end]],
	["[raidcolor]"]   		= [[function(u)
 local _, x = UnitClass(u);
 return x and Hex(RAID_CLASS_COLORS[x])
end]],
	["[rare]"]        		= [[function(u)
 local c = UnitClassification(u);
 return (c == "rare" or c == "rareelite") and "Rare"
end]],
	["[resting]"]     		= [[function(u) return u == "player" and IsResting() and "zzz" end]],
	["[afk]"]					= [[function(u) return UnitIsAFK(u) and "AFK" end]],
	["[sex]"]         			= [[function(u) local s = UnitSex(u) return s == 2 and "Male" or s == 3 and "Female" end]],
	["[smartclass]"]  	= [[function(u) return UnitIsPlayer(u) and Smee2_oUFEmbed.Tags["[class]"](u) or Smee2_oUFEmbed.Tags["[creature]"](u) end]],
	["[status]"]      		= [[function(u) return UnitIsDead(u) and "Dead" or UnitIsGhost(u) and "Ghost" or not UnitIsConnected(u) and "Offline" or Smee2_oUFEmbed.Tags["[resting]"](u) end]],
	["[threat]"]      		= [[function(u) local s = UnitThreatSituation(u); return s == 1 and "++" or s == 2 and "--" or s == 3 and "Aggro" end]],
	["[threatplus]"]		= [[function(u) 
		local unitTarget = u.."target"
		if(UnitExists(unitTarget))then
			local_,_, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(u, uTarget)
			return rawthreatpct
		else
			return ''
		end		
	end]],
	["[threatcolor]"] 	= [[function(u) return Hex(GetThreatStatusColor(UnitThreatSituation(u))) end]],
	["[cpoints]"]     		= [[function(u) local cp = GetComboPoints(u, 'target') return (cp > 0) and cp end]],
	['[smartlevel]'] 		= [[function(u) 
 local c = UnitClassification(u) 
 if(c == "worldboss") then
  return "Boss"
 else
  local plus = Smee2_oUFEmbed.Tags["[plus]"](u)
  local level = Smee2_oUFEmbed.Tags["[level]"](u)
  if(plus) then
   return level .. plus
  else
   return level
  end
 end
end]],
	["[classification]"] = [[function(u)
 local c = UnitClassification(u)
 return c == "rare" and "Rare" or c == "eliterare" and "Rare Elite" or c == "elite" and "Elite" or c == "worldboss" and "Boss"
end]],
	["[shortclassification]"] = [[function(u)
 local c = UnitClassification(u)
 return c == "rare" and "R" or c == "eliterare" and "R+" or c == "elite" and "+" or c == "worldboss" and "B"
end]],
	["[abbreviatedname]"] = [[function(u)
 local name = UnitName(u)
 return (string.len(name) > 10) and string.gsub(name, "%s?(.)%S+%s", "%1. ") or name
end
	]]
}
function oUF:ReWriteTag(tag,events,logic)
	if logic then 
		builder = assert(loadstring("return " .. logic))
		self.Tags[tag] = builder()
	end
	if events then
		oUF.TagEvents[tag] = events
	end
end

function oUF:CompileTagStringLogic()
	for tag,logic in pairs(self.TagsLogicStrings)do
		oUF:ReWriteTag(tag,oUF.TagEvents[tag],logic)
	end
end




