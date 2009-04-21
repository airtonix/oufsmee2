local tableExtend = function(array,table)
	for index,data in pairs(table)do
		array[index] = data
	end
end

local config=oUF_Smee2_Config
config.options = {
--[[
    name = "oUF_Smee2", handler = config,
    type = 'group', 
    args = {
		["frames"] = {
--]]
			name = "Global", type = 'group',
			childGroups = "select",
			handler = config,
			args = {
				["enabledDebugMessages"] = {
					name = "Enable Debug Messages in ChatFrame1",desc = "Toggles on/off output of debug messages.",
					type = 'toggle',
					get = "getOptionValue", set = "setOptionValue",
				},
				["tags"] = {
					name = "Tags",	desc = "Text Status Tags ",
					type = 'group',childGroups = "select",
					args = { 
						
					},
				},	
				
				["frames"] = {
					name = "Frames",	desc = "Frame Options ",
					type = 'group', 
					args = {

						["font"] = {
							name = "Font", desc = "Global controls for fonts ",
							type = 'group',
							args = {
								["size"] = {
										name = "Font Size",desc = "Change the font size, note this is affected by your ui-scale in video settings.",
										type = "range", min = 1,max = 48.0, step = 0.1, 
										order = 103,
										get = "getOptionValue",	set = "setOptionValue",
								},
								["name"] = {
									type = "select",
									name = "Fontface",
									dialogControl = 'LSM30_Font',		 							disabled = not config.mod.SharedMediaActive,					 				desc = "Fontface to use on the bars.",
									get = 'getOptionValue', set = 'setOptionValue',
									disabled ='CheckUnitFrameOption',
			 						values = AceGUIWidgetLSMlists.font,
									order=26,
								},						
								["outline"] = {
									type = "select",
									name = "Outline", desc = "font options, typically outline types",
									get = 'getOptionValue', set = 'setOptionValue',
									disabled ='CheckUnitFrameOption',
									values = config.fontOutlineTypes,	
									order = 7,
								},
							},
						},

						["auras"] = {
							name = "Aura", desc = "Global controls for aura icons ",
							type = 'group',
							args = {
								["timers"] = {
									name = "Countdown Timers", desc = "Toggles on/off display of time remaining on each buff/debuff icon",
									type = 'toggle',
									get = "getOptionValue",	set = "setOptionValue",
								},
								["format"] = {
									name = "Short Format", desc = "Toggles between single digit or minutes : seconds time format display for timer countdown",
									type = 'toggle',
									get = "getOptionValue",	set = "setOptionValue",
								},
								["font"] = {
									name = "Font", desc = "Global controls for fonts ",
									type = 'group',guiInline=true,
									args = {
										["size"] = {
												name = "Font Size",desc = "Change the font size, note this is affected by your ui-scale in video settings.",
												type = "range", min = 1,max = 48.0, step = 0.1, 
												order = 103,arg = 'global-aura',
												get = "getOptionValue",	set = "setOptionValue",
										},
										["name"] = {
											type = "select",
											name = "Fontface",
											dialogControl = 'LSM30_Font',				 							disabled = not config.mod.SharedMediaActive,							 				desc = "Fontface to use on the bars.",
											get = 'getOptionValue', set = 'setOptionValue',
											disabled ='CheckUnitFrameOption',
					 						values = AceGUIWidgetLSMlists.font,
											order=26,arg = 'global-aura',
										},						
										["outline"] = {
											type = "select",
											name = "Outline", desc = "font options, typically outline types",
											get = 'getOptionValue', set = 'setOptionValue',
											disabled ='CheckUnitFrameOption',
											values = config.fontOutlineTypes,	
											order = 7,arg = 'global-aura',
										},
									},
								},
							},
						},
						["units"] = {
							name = "Units",	desc = "Individual frame controls ",
							type = 'group', 
							args = {
								["lock"] = {
									name = "Lock Frame Positions",desc = "Toggles on/off Frame Lock, allowing you to drag the frames around.",
									type = 'toggle', order = 1,
									get = "getOptionValue", set = "setOptionValue",
								},
								["scale"] = {
									type = "range", order = 2,
									name = "Frame Scale", desc = "Global frame scale.",
									min = 0.1,	max = 2.0, step = 0.01,
									get = "getOptionValue",	set = "setOptionValue",
								},

							 },
						},	

					},
				},	

				
			},
--		},
--    },
}
function config:CreateAuraOptions(groupName,frame)
	local optionSet={
			type = 'group',
			name = groupName,
			order=60,
			args = {
				["setup"] = {
					name = "Show Setup Background",
					desc = "Toggles on/off the displaying of the frame background to help with layout configuration",
					type = 'toggle',
					get = "GetUnitFrameOption",	set = "SetUnitFrameOption",
					arg = frame,
					order = 1,
				},
				
				["position"] = {
					type = "header",
					name = "Position",
					order = 2,
				},
				["anchorX"] = {
					type = "range",
					name = "Horizontal Position", desc = "Set the horizontal position.",
					min = -400, max = 400, step = 1,
					get = "GetUnitFrameOption", set = "SetUnitFrameOption",
					disabled ="CheckUnitFrameOption",
					arg = frame,
					order = 5,
				},
				["anchorY"] = {
					type = "range",
					name = "Vertical Position", desc = "Set the vertical position.",
					min = -400, max = 400, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					arg = frame,
					order = 5,
				},
				["anchorToPoint"] = {
					type = "select",
					name = "To edge...",
					desc = "Which edge on the "..frame.unit.." frame to attach To",
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					values=config.frameAnchorPoints,
					arg = frame,
					order=6,					
				},
				["anchorFromPoint"] = {
					type = "select",
					name = "From edge...", desc = "Which edge to attach from on the "..frame.unit.." frame.",
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					values = config.frameAnchorPoints,						
					arg = frame,
					order = 7,
				},
				["arrangement"] = {
					type = "header",
					name = "Arrangement",
					order=1,
				},
				["Colomns"] = {
					type = "range",
					name = "Colomns", desc = "Set amount of icons per row.",
					min = 1, max = 40, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled = 'CheckUnitFrameOption',
					arg = frame,
					order = 8,
				},
				["count"] = {
					type = "range",
					name = "Count", desc = "Set total amount of icons. For now this setting only takes effect after a UIReload",
					min = 1, max = 40, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled = 'CheckUnitFrameOption',
					arg = frame,
					order = 9,
				},
				["spacing"] = {
					type = "range",
					name = "Spacing", desc = "Set distance between each icon",
					min = 1, max = 40, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled = 'CheckUnitFrameOption',
					arg = frame,
					order = 10,
				},
				["growth-x"] = {
					type = "select",
					name = "horizontal growth direction",
					desc = "Aura icons grow left or right",
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					values=config.growthXDirections,
					arg = frame,
					order=11,
				},
				["growth-y"] = {
					type = "select",
					name = "vertical  growth direction",
					desc = "Aura icons grow up or down",
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					values=config.growthYDirections,
					arg = frame,
					order=12,
				},
				["size"] = {
					type = "header",
					name = "Size",
					order=13,
				},
				["size"] = {
					type = "range",
					name = "icon size", desc = "Set the size of the aura icons.",
					min = 0.1, max = 48, step = 0.1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					arg = frame,
					order = 20,
				},
				["playerSize"] = {
					type = "range",
					name = "Your Icons Scale", desc = "Set the size of auras that belong to you, compared to the normal size. expressed as a fraction",
					min = 0.1, max = 4.0, step = 0.1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					disabled ='CheckUnitFrameOption',
					arg = frame,
					order = 20,
				}
			}
		}
		return optionSet
end

function config:CreateBarOptions(groupName,frame)
	local optionGroup = {
		type = 'group',
		name = groupName,
		order = 52,
		args = {
			["enabled"] = {
				type = "toggle",
				name = "enable", desc = "Enable this bar.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=1,
			},
			["reverse"] = {
				type = "toggle",
				name = "reverse", desc = "Reverse the direction in which this statusbar grows.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=1,
			},
			["headerSize"] = {
				type = "header",
				name = "Size",
				order=10,
			},
			["height"] = {
				type = "range",
				name = "Height", desc = "Set the bar height.",
				min = 1, max = 100, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=11,
			},
			["bgColor"] = {
					type = "color",
					name = "bgColor Colour", desc = "choose the bgColor for the bar.",
					get = 'GetColourOption', set = 'SetColourOption',
					arg = frame,
					hasAlpha = true,
					order=32,
			}
		}
	}
	
	if not (groupName=="Health" or groupName=="Power") then
		tableExtend(optionGroup.args,{
			["width"] = {
				type = "range",
				name = "Width", desc = "Set the bar width.",
				min = 1, max = 400, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=12,
			},
			["height"] = {
				type = "range",
				name = "Height", desc = "Set the bar height.",
				min = 1, max = 200, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=11,
			},
			["headerPosition"] = {
				type = "header",
				name = "Position",
				order=20,
			},
			["anchorX"] = {
				type = "range",
				name = "Horizontal Position", desc = "Set the Vertical position.",
				min = -400, max = 400,
				step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=21,
			},
			["anchorY"] = {
				type = "range",
				name = "Vertical Position", desc = "Set the Horizontal position.",
				min = -400, max = 400, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=22,
			},
		})
	end
	
	if(groupName == 'Castbar') then
		tableExtend(optionGroup.args,{
		["headerColour"] = {
				type = "header",
				name = "Colours",
				order=30,
		},
		["StatusBarColor"] = {
				type = "color",
				name = "StatusBarColor Colour", desc = "choose the StatusBarColor the casting bar.",
				get = 'GetColourOption', set = 'SetColourOption',
				arg = frame,
				hasAlpha = true,
				order=31,
		},
		["BackdropColor"] = {
				type = "color",
				name = "BackdropColor Colour", desc = "choose the BackdropColor for the casting bar.",
				get = 'GetColourOption', set = 'SetColourOption',
				arg = frame,
				hasAlpha = true,
				order=33,
		},
		['Text'] = {
			type = "group",
			name = "CastName",
			order=40,
			args={
				["anchorX"] = {
					type = "range",
					name = "Horizontal Position", desc = "Set the Vertical position.",
					min = -400, max = 400, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					arg = frame,
					order=21,
				},
				["anchorY"] = {
					type = "range",
					name = "Vertical Position", desc = "Set the Horizontal position.",
					min = -400, max = 400, step = 1,
					get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
					arg = frame,
					order=22,
				},
			}
		},
		['Time'] = {
				type = "group",
				name = "CastTime",
				order=50,
				args={
					["anchorX"] = {
						type = "range",
						name = "Horizontal Position", desc = "Set the Vertical position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=21,
					},
					["anchorY"] = {
						type = "range",
						name = "Vertical Position", desc = "Set the Horizontal position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=22,
					},
				}
			}
		})

		if frame.unit == 'player' then
			tableExtend(optionGroup.args,{
			["SafeZone"] = {
				type = 'group',
				name = 'Latency SafeZone',
				order = 52,
				args = {
					["enabled"] = {
						type = "toggle",
						name = "enable", desc = "Enable latency safezone overlay.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=1,
					},
					["accurate"] = {
						type = "toggle",
						name = "accurate latency", desc = "turn on accurate latency measurement.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=1,
					},
					["colour"] = {
							type = "color",
							name = "Colour", desc = "choose the colour for the safezone.",
							get = 'GetColourOption', set = 'SetColourOption',
							arg = frame,
							hasAlpha = true,
							order=32,
					}
				}			
			}
		})
		end
	elseif groupName == "TotemBar"then
		tableExtend(optionGroup.args,{
			["scale"] = {
				type = "range",
				name = "Scale", desc = "Set scale of the totem icon.",
				min = 1, max = 4, step = .1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=22,
			},
			['Timer'] = {
				type = "group",
				name = "Timer",
				order=40,
				args={
					["anchorX"] = {
						type = "range",
						name = "Horizontal Position", desc = "Set the Vertical position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=21,
					},
					["anchorY"] = {
						type = "range",
						name = "Vertical Position", desc = "Set the Horizontal position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						arg = frame,
						order=22,
					},
					["anchorToPoint"] = {
						type = "select",
						name = "To edge...",
						desc = "Which edge on the "..frame.unit.." frame to attach To",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						disabled ='CheckUnitFrameOption',
						values=config.frameAnchorPoints,
						arg = frame,
						order=26,					
					},
					["anchorFromPoint"] = {
						type = "select",
						name = "From edge...", desc = "Which edge to attach from on the "..frame.unit.." frame.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
						disabled ='CheckUnitFrameOption',
						values = config.frameAnchorPoints,						
						arg = frame,
						order = 28,
					},
				}
			}
		})
	elseif(groupName == 'RuneBar') then
		optionGroup.args["orientation"] = {
			type = "select",
			name = "Rune Orientation", desc = "Which axis do the runes deplete?",
			get = 'GetUnitFrameOption', set = 'GetUnitFrameOption',
			arg = frame,
			values = { HORIZONTAL ="Horizontally", VERTICAL = "Vertically"},
			order=4,
		}
	end		
	return optionGroup
end

function config:SetupTagOptions(tags)
	local tagOptions = self.options.args['tags'].args
	for tag,logic in pairs(tags)do
		tagOptions[tag] = self:AddTagOptionSet(tag,logic)
	end
end

function config:AddTagOptionSet(tag,logic)
	local tagOption = {
		type = 'group',childGroups = 'tab',
		name = tag,
		args = {
			["inputTagString"] = {
				type = "input",
				get = 'GetTagOption', set = 'SetTagOption',
				name = "tag string / moniker", width = 'full',
				desc = "The tag that you can use as a placeholder for this logic",
				arg = tag,
				order=12,
			},
			["inputTagFunc"] = {
				type = "input",multiline=true,
				get = 'GetTagOption', set = 'SetTagOption',
				name = "tag logic / function", arg = tag,	width = 'full',
				desc = "The logic that this tags uses to produce the resulting text",
				order=32,
			},
			["inputTagEvents"] = {
				type = "input",multiline=true,
				get = 'GetTagOption', set = 'SetTagOption',
				name = 'tag events', arg = tag, width = 'full',
				desc = "A space delimited set of event names that will cause this tag to execute and update a fontstring using it. specifiying no events means that it only updates when the frame spawns.",
				order=42,
			},
		},
	}
	return tagOption
end

function config:AddUnitOptionSet(frame)
	local screenHeight = GetScreenHeight()
	local screenWidth = GetScreenWidth()

	--[[-----------------------------------------
	 Unitframe
	   frame.unit = 'player'
	   frame = oUF_Player
	--------------------------------------------]]
	local optionSet = {
		type = 'group',
		name = frame.unit,
		args = {
			["headerSize"] = {
				type = "header",
				name = "Size",
				order=10,
			},
			["height"] = {
				type = "range",
				name = "Height", desc = "Set the height.",
				min = 1, max = 200, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				arg = frame,
				order=11,
			},
			["width"] = {
				type = "range",
				name = "Width", desc = "Set the width.",
				min = 1, max = 600, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				arg = frame,
				order=11,
			},
			["headerPosition"] = {
				type = "header",
				name = "Position",
				order=20,
			},
			["anchorY"] = {
				type = "range",
				name = "Vertical Position", desc = "Set the Vertical position.",
				min = -config:round(screenHeight/2,0), max = config:round(screenHeight/2,0), step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=21,
			},
			["anchorX"] = {
				type = "range",
				name = "Horizontal Position", desc = "Set the Horizontal position.",
				min = -config:round(screenWidth/2,0), max = config:round(screenWidth/2,0), step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=22,
			},
			["anchorToPoint"] = {
				type = "select",
				name = "To edge...",
				desc = "Which edge on the "..frame.unit.." frame to attach To",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				values=config.frameAnchorPoints,
				arg = frame,
				order=26,					
			},
			["anchorTo"] = {
				type = "select",
				name = "Anchor To Frame...",
				desc = "On which frame to anchor "..frame.unit.." to.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				values=config.PlayerFramesToAnchorTo,
				arg = frame,
				order=27,					
			},
			["anchorFromPoint"] = {
				type = "select",
				name = "From edge...", desc = "Which edge to attach from on the "..frame.unit.." frame.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				values = config.frameAnchorPoints,						
				arg = frame,
				order = 28,
			},
			["headerRangeFading"] = {
				type = "header",
				name = "RangeFading",
				order=30,
			},
			["Range"] = {
				type = "toggle",
				name = "Enabled", desc = "Fading this frame based on your proximity to the unit.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				arg = frame,
				order=31,
			},
			["inRangeAlpha"] = {
				type = "range",
				name = "In range opacity", desc = "Set the opacity level of the frame for when this unit is within your range.",
				min = 0, max = 1,
				step = 0.05,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				arg = frame,
				order=32,
			},
			["outsideRangeAlpha"] = {
				type = "range",
				name = "Out of range opacity", desc = "Set the opacity level of the frame for when this unit is out of your range.",
				min = 0, max = 1, step = 0.05,
				get = 'GetUnitFrameOption',	set = 'SetUnitFrameOption',
				arg = frame,
				order=33,
			},
		},
	}

	--[[-----------------------------------------
	 Textures
	--------------------------------------------]]

	optionSet.args["textures"] = {
		type = 'group',
		name = "Textures",
		order = 30,
		args = {
			["statusbar"] = {
				type = "select",
				name = "Statusbar",
				dialogControl = 'LSM30_Statusbar',				disabled = not self.mod.SharedMediaActive, 				desc = "Texture to use on the bars.",
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				values = AceGUIWidgetLSMlists.statusbar,
				arg = frame,
				order=26,
			},
		},
	}
	--[[-----------------------------------------
	 FontObjects
	--------------------------------------------]]

	optionSet.args["FontObjects"] = {
		type = 'group',
		name = "Texts",
		order = 30,
		args = {
			
		},
	}
	for index,data in pairs(frame.db.FontObjects)do
		local key = tostring(index)
		if(key) then 
			optionSet.args["FontObjects"].args[key] = {
				type = 'group',
				name = data.desc, order = 30,
				args = {
					["header"] = {
						type = "header",
						name = data.desc,
						order=1,
					},
					["anchorToPoint"] = {
						type = "select",
						name = "To edge...",
						desc = "Which edge on the "..frame.unit.." frame to attach To",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						disabled ='CheckUnitFrameOption',
						values=config.frameAnchorPoints,
						arg = frame,
						order=6,					
					},
					["anchorFromPoint"] = {
						type = "select",
						name = "From edge...", desc = "Which edge to attach from on the "..frame.unit.." frame.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						disabled ='CheckUnitFrameOption',
						values = config.frameAnchorPoints,						
						arg = frame,
						order = 7,
					},
					["justifyH"] = {
						type = "select",
						name = "Horizontal Alignment", desc = "text alignment.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						disabled ='CheckUnitFrameOption',
						values = config.textHorizontalAlignmentPoints,
						arg = frame,
						order = 7,
					},
					["justifyV"] = {
						type = "select",
						name = "Vertical Alignment", desc = "text alignment.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						disabled ='CheckUnitFrameOption',
						values = config.textVerticalAlignmentPoints,
						arg = frame,
						order = 7,
					},
					["anchorX"] = {
						type = "range",
						name = "Horizontal Position", desc = "Set the Vertical position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						arg = frame,
						order=21,
					},
					["anchorY"] = {
						type = "range",
						name = "Vertical Position", desc = "Set the Horizontal position.",
						min = -400, max = 400, step = 1,
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						arg = frame,
						order=22,
					},
					["tag"] = {
						type = "input",
						name = "oUF Tag", desc = "Tag representing logic to display.",
						get = 'GetUnitFrameOption', set = 'SetUnitFrameFontObjectOption',
						usage = "[tagname] [tagname]",
						arg = frame,
						order=32,
					},
				}
			}
		else
			optionSet.args["FontObjects"].args[key] = {
				type = 'group',
				name = 'Error', order = 30,
				args = {
					["header"] = {
						type = "header",
						name = 'Error',
						order=1,
					},
					['reason'] = {
						type = 'description',
						name = 'FontObject : '..key,
						order = 2,						
					}
				},
			}
		end
	end

	--[[-----------------------------------------
	 Bars
	--------------------------------------------]]
	optionSet.args["bars"] = {
		type = 'group',
		name = "Bars",
		order = 30,
		args = {
			
		},
	}	
	for index,data in pairs(frame.db.bars)do
		local key = tostring(index)
		if(key) then 
			if(data.classFilter)then 
				if data.classFilter == frame.unitClass then -- bars like totembar and runebar should only apply to a particular class
					optionSet.args["bars"].args[key] = self:CreateBarOptions(key,frame)
				end
			else
				optionSet.args["bars"].args[key] = self:CreateBarOptions(key,frame)
			end
		end
	end	

	--[[-----------------------------------------
	 Auras
	--------------------------------------------]]
	optionSet.args.Buffs = self:CreateAuraOptions("Buffs",frame)
	optionSet.args.Debuffs = self:CreateAuraOptions("Debuffs",frame)
	
	return optionSet
end

function config:debug(info,value)
	local object = info['arg']
	local profile = object.db
	local setting = info[#info]
   if setting == "height" then
    return object:GetHeight()
   end
 GlobalObject[#GlobalObject] = info
 self:Debug("\nGetUnitFrameOption : "..self:concatLeaves(info))
 return info[#info]
end

function config:CreateStatusBarOptions(frame,bar,barName,insertOrder,settings)
	local options = {
		type = 'group',
		name = barName,
		order = insertOrder,
		args = {
			["height"] = {
				type = "range",
				name = "Height", desc = "Set the height, as a percentage of the unit frame.",
				min = 1, max = 100, step = 1,
				get = 'GetUnitFrameOption', set = 'SetUnitFrameOption',
				disabled ='CheckUnitFrameOption',
				arg = bar,
				order=11,
			},
		
		},
	}
 return options
end
