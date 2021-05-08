local addon = LibStub("AceAddon-3.0"):NewAddon("CastBars_EZ", "AceConsole-3.0")
local icon = LibStub("LibDBIcon-1.0")
local CastBarsEZLDB = LibStub("LibDataBroker-1.1", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local CastBars_EZ = _G['CastBars_EZ'] or CreateFrame('frame', 'CastBars_EZ', UIParent)
local addonName, ns = ...
local nointerrupt_color = { .9, 0, 0, 1}
local default_color_CB = { 1, .7, 0, 1}
local default_color_TB = { 1, .7, 0, 1}
local show_text = true
local show_timer = true

local castbars = { 
	-- default value 
	player = true, 
	target = true,
	pet = true, 	
	focus = true, 

}
		local options = {
		
			handler = CastBarsEZ,
			type = "group",
			args = {
			layoutmode = {
					type = "toggle",
					name = "layoutmode : move and resize castbars",
					width = "full",
					desc = "layoutmode : move and resize castbars",
					get = function()
					
					end,
					set = function(info, value)
					
					end,
					order = 5
			},
			visibility = {
					type = "group",
					name = "Visibility",
					desc = "Show/Hide the differents castbars",
					order = 10,
					args = {
						player_cb = {
							type = "toggle",
							
							name = "Player Cast Bar",
							desc = "Show/Hide Player Cast Bar",
							get = function()
								return addon.db.profile.show_player
							end,
							set = function(info, value)
								
								--call function after profil 
								if addon.db.profile.show_player ~= value then
								addon.db.profile.show_player = value
								end
							end,
						order = 11,
						},
						target_cb = {
							type = "toggle",
							
							name = "Target Cast Bar",
							desc = "Show/Hide Target Cast Bar",
							get = function()
								return addon.db.profile.show_target
							end,
							set = function(info, value)
								if addon.db.profile.show_target ~= value then
								addon.db.profile.show_target = value
								end
							end,
						 order = 12,   
						},
						focus_cb = {
							type = "toggle",
							
							name = "Focus Cast Bar",
							desc = "Show/Hide Focus Cast Bar",
							get = function()
								return addon.db.profile.show_focus
							end,
							set = function(info, value)
								if addon.db.profile.show_focus ~= value then
								addon.db.profile.show_focus = value
								end
							end,
						order = 13,    
						},
						pet_cb = {
							type = "toggle",
							
							name = "Pet Cast Bar",
							desc = "Show/Hide Pet Cast Bar",
							get = function()
								return addon.db.profile.show_pet
							end,
							set = function(info, value)
							if addon.db.profile.show_pet ~= value then
								addon.db.profile.show_pet = value
								end
							end,
						 order = 14,   
						},
					}
			},
			colors = {
					type ="group",
					name = "Castbars Colors",
					desc = "change colors of the differents castbars",
					args = {
						playerCBcolor = {
						type = "color",
						hasAlpha = true,
						name = "Player Bar Color",
						desc = "Change the color of CastBar.",
						get = function(info) 
							--return default_color[1],default_color[2],default_color[3],default_color[4]
						return addon:Getcolor_CB()
						end,
						
						set = function(info, r, g, b, a)
						--print(r, g, b, a) 
						default_color_CB = {r, g, b, a}
						addon:Setcolor_CB(default_color_CB)
						
						end,
						},
						TargetCBcolor = {
						type = "color",
						hasAlpha = true,
						name = "Target Bar Color",
						desc = "Change the color of Target CastBar.",
						get = function(info) 
							--return default_color[1],default_color[2],default_color[3],default_color[4]
						return addon:Getcolor_TB()
						end,
						
						set = function(info, r, g, b, a)
						--print(r, g, b, a) 
						default_color_TB = {r, g, b, a}
						addon:Setcolor_TB(default_color_TB)
						
						end,
						},
					}
			},
			}

			
			}
		
			
		local defaults = {
			profile = {
				minimapHide = false,		
				minimapPos = 204,
				show_player = true, 
				show_target = true, 
				show_focus = true, 
				show_pet = true, 
				colorcastbarCB = default_color_CB,
				colorcastbarTB = default_color_TB,
				frameCoord={},
			
			}
		}



local CastingBarShowContent = function(selfB)
			if not selfB.locked then
				selfB:SetAlpha(1)
				selfB.bar.flash:Hide()
				selfB.bar.spark:Hide()
				selfB.bar.timer:Hide()
				if selfB.lag then selfB.lag:Hide() end
				selfB.bar:SetStatusBarColor(.2,.2,.2)
				selfB.icon:SetTexture('Interface\\ICONS\\Trade_engineering')
				selfB.resize:Show();
			else
				selfB:SetAlpha(0)
				selfB.bar.flash:Show()
				selfB.bar.spark:Show()
				if show_timer then selfB.bar.timer:Show() end
				if selfB.lag then selfB.lag:Show() end
				selfB.bar:SetStatusBarColor(unpack(default_color_CB))
				selfB.resize:Hide()
				
				selfB:SetScript("OnDragStop", function(self)
				self.isMoving=false;
				self:StopMovingOrSizing();
						
				end)
				
			end
end

function addon:OnInitialize()
		
	addon.db = LibStub("AceDB-3.0"):New("CastBars_EZDB", defaults, true)

	local castbars = { -- load the last value savec in the profil
		player = addon.db.profile.show_player, 
		target = addon.db.profile.show_target,
		pet = addon.db.profile.show_pet, 	
		focus = addon.db.profile.show_focus,
		}
		
	default_color_CB = addon.db.profile.colorcastbarCB
	default_color_TB = addon.db.profile.colorcastbarTB
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CastBarsEZ", options, {"ECB", "ecb","EZCBB"})
		AceConfigDialog:AddToBlizOptions("CastBarsEZ") -- frame Option Addon interface

		--icon minimap
		local CastBarsEZLDB = CastBarsEZLDB:NewDataObject("CastBars_EZ", {
		type = "data source",
		text = "CastBars_EZ",
		icon = "Interface\\Icons\\Spell_nature_lightning",
		OnClick = 	function(_, button)                

					if button == "LeftButton" then 
						LibStub("AceConfigDialog-3.0"):Open("CastBarsEZ")
					end
							
					if button == "RightButton" then 
							
							for unit, enable in pairs(castbars) do
							
							--print(unit,enable)
							local castbar = _G[unit.."ezCastBar"]
							

								if enable then
								castbar.locked = not castbar.locked							
								
									if castbar then
											
											castbar:RegisterForDrag("LeftButton")
											castbar:EnableMouse(true)
											castbar.bar.text:SetText(unit)
											castbar:Show()
											CastingBarShowContent(castbar)
									end
								end
								
							end
							
								
							
						
					end
					
					end,
		OnTooltipShow = function(tt)
						tt:AddLine("CastBarsEZ version  : |cffffff00".."2".."|r")
						tt:AddLine("|cffffff00Click|right to Hide/Show and move the castbars.")
						tt:AddLine("|cffffff00Click|left to Show the panel option.")
						end,
		})


icon:Register("CastBars_EZ", CastBarsEZLDB, self.db.profile.minimap)
self:RegisterChatCommand("CastBars_EZ", "CommandTheCastBars_EZ")



end
------------------------------------------
--- Color casts bar
------------------------------------------
---Player-
function addon:Getcolor_CB()
	  
   return 
   unpack(addon.db.profile.colorcastbarCB)

end

function addon:Setcolor_CB()
  
	if addon.db.profile.colorcastbarCB ~= (default_color_CB) then
        
		addon.db.profile.colorcastbarCB = (default_color_CB)
    end
end
----Target Cast bar
function addon:Getcolor_TB()
	  
   return 
   unpack(addon.db.profile.colorcastbarTB)

end

function addon:Setcolor_TB()
  
	if addon.db.profile.colorcastbarTB ~= (default_color_TB) then
        
		addon.db.profile.colorcastbarTB = (default_color_TB)
    end
end
------------------------------------------
	



local CastingBarHideContent = function(selfB)
	if not selfB.locked then
		selfB:SetAlpha(1)
		selfB.bar.flash:Hide()
		selfB.bar.spark:Hide()
		selfB.bar.timer:Hide()
		if selfB.lag then selfB.lag:Hide() end
		selfB.bar:SetStatusBarColor(.2,.2,.2)
		selfB.icon:SetTexture('Interface\\ICONS\\Trade_engineering')
		selfB.resize:Show();
	else
		selfB:SetAlpha(0)
		selfB.bar.flash:Show()
		selfB.bar.spark:Show()
		if show_timer then selfB.bar.timer:Show() end
		if selfB.lag then selfB.lag:Show() end
		print(unpack(default_color_CB))
		selfB.bar:SetStatusBarColor(unpack(default_color_CB))
		selfB.resize:Hide()
		
		selfB:SetScript("OnDragStop", function(selfB)
		selfB.isMoving=false;
		selfB:StopMovingOrSizing();
		
		-- Save position
		local point, relativeTo, relativePoint, xOfs, yOfs = selfB:GetPoint()
		print(point, relativeTo, relativePoint, xOfs, yOfs)
		local W = selfB:GetWidth()
		local H = selfB:GetHeight()
		
		addon.db.profile.frameCoord[selfB.unit] ={}
		addon.db.profile.frameCoord[selfB.unit].Point = point
		addon.db.profile.frameCoord[selfB.unit].RelativePoint = relativePoint
		addon.db.profile.frameCoord[selfB.unit].xOfs = xOfs
		addon.db.profile.frameCoord[selfB.unit].yOfs = yOfs
		addon.db.profile.frameCoord[selfB.unit].w = W
		addon.db.profile.frameCoord[selfB.unit].h = H		
		
	
		
		
		end)
		
	end
end


local CastingBarFinishSpell = function(self, barSpark, barFlash)
	self.bar:SetStatusBarColor(0, 1, 0)
	if barSpark then self.bar.spark:Hide() end
	if barFlash then
		self.bar.flash:SetAlpha(0)
		self.bar.flash:Show()
	end
	self.flashing = 1
	self.fadeOut = 1
	self.casting = nil
	self.channeling = nil
end

local MakeCastBar = function(unit, enable)
	local frame = _G[unit.."ezCastBar"] or CreateFrame("frame", unit.."ezCastBar", UIParent, "ezCastBarTemplate")
	
	
	-- Ajouter ici 
	if unit == "player" then
		x = addon.db.profile.frameCoord[unit].xOfs	
		y = addon.db.profile.frameCoord[unit].yOfs
		rel= addon.db.profile.frameCoord[unit].RelativePoint
		H = addon.db.profile.frameCoord[unit].h
		W = addon.db.profile.frameCoord[unit].w
		C = addon.db.profile.colorcastbarCB

	frame:SetStatusBarColor(unpack(C))
	frame:SetPoint(rel,UIParent,rel,x,y)
	frame:SetHeight(H)
	frame:SetWidth(W)
	end
	
	if unit == "target" then
		x = addon.db.profile.frameCoord[unit].xOfs	
		y = addon.db.profile.frameCoord[unit].yOfs
		rel= addon.db.profile.frameCoord[unit].RelativePoint
		H = addon.db.profile.frameCoord[unit].h
		W =addon.db.profile.frameCoord[unit].w
		C = addon.db.profile.colorcastbarTB

	frame:SetStatusBarColor(unpack(C))
	frame:SetPoint(rel,UIParent,rel,x,y)
	frame:SetHeight(H)
	frame:SetWidth(W)
	end	
	
	if unit == "pet" then
		x = addon.db.profile.frameCoord[unit].xOfs	
		y = addon.db.profile.frameCoord[unit].yOfs
		rel= addon.db.profile.frameCoord[unit].RelativePoint
		H = addon.db.profile.frameCoord[unit].h
		W =addon.db.profile.frameCoord[unit].w
	frame:SetPoint(rel,UIParent,rel,x,y)
	frame:SetHeight(H)
	frame:SetWidth(W)
	end	
	
	if unit == "focus" then
		x = addon.db.profile.frameCoord[unit].xOfs	
		y = addon.db.profile.frameCoord[unit].yOfs
		rel= addon.db.profile.frameCoord[unit].RelativePoint
		H = addon.db.profile.frameCoord[unit].h
		W =addon.db.profile.frameCoord[unit].w
	frame:SetPoint(rel,UIParent,rel,x,y)
	frame:SetHeight(H)
	frame:SetWidth(W)
	end
	
	
	
	
	if unit == "player" then
		frame.lag = _G[frame:GetName().."Lag"] or frame.bar:CreateTexture(frame:GetName().."Lag", "BORDER")
		frame.lag:SetPoint("TOPRIGHT")
		frame.lag:SetPoint("BOTTOMRIGHT")
		frame.lag:SetTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill", "BACKGROUND")
		frame.lag:SetVertexColor(1, 0, 0)
		frame.lag:SetBlendMode("ADD")
	end
	
	if show_text == false then
		frame.bar.text:Hide()
	end
		
	if show_timer == false then
		frame.bar.timer:Hide()
	end
	
	frame.timerUpdate = .1
	
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("UNIT_SPELLCAST_START")
	frame:RegisterEvent("UNIT_SPELLCAST_STOP")
	frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	--frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	--frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	frame.unit = unit
	frame.casting = nil
	frame.channeling = nil
	frame.holdTime = 0
	frame.showCastbar = castbars[unit]
	frame.locked = true
	CastingBarHideContent(frame)
	frame:Hide()
	
	frame:SetScript("OnShow", function(self)
		if not self.locked then return end
		if self.casting then
			local name, text, texture, startTime, endTime, isTradeSkill, castID = UnitCastingInfo(unit)
			local _, _, _, st = UnitCastingInfo(self.unit)
			--print (st)
			if st then
				self.value = (GetTime() - (st / 1000))
				
			end
		else
			local _, _, _, _, et = UnitChannelInfo(self.unit)
			if et then
				self.value = ((et / 1000) - GetTime())
			end
		end
	end)
	
	frame:SetScript("OnEvent", function(self, event, ...)
	--print(event)
		local arg1 = ...
		if not self.locked then return end
		local unit = self.unit
			if  event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" then
				local spellChannel  = UnitChannelInfo(unit)
				local spellName  = UnitCastingInfo(unit)
				if  spellChannel then
					event = "UNIT_SPELLCAST_CHANNEL_START"
					arg1 = unit
				elseif spellName then
					event = "UNIT_SPELLCAST_START"
					arg1 = unit
				else
					CastingBarFinishSpell(self)
				end
			end
		
		if arg1 ~= unit then return end

		if event == "UNIT_SPELLCAST_START" then
		--print(event)
		--print("Start Cast:",unit)
			local name, text, texture, startTime, endTime, isTradeSkill, castID = UnitCastingInfo(unit)
			--print ("n:",name, " text:",text, " texture:",texture, " ST:",startTime, " ET:",endTime, " ITS:",isTradeSkill, " CastID:",castID)
			if not name then
				self:Hide()
				return
			end
			
			if unit == 'player' then notInterruptible = false end
			
			if unit == 'player' then 
			
			self.bar:SetStatusBarColor(unpack(default_color_CB))
			
			else
			self.bar:SetStatusBarColor(unpack(default_color_TB))
			
			end
			
			self.bar.spark:Show()
			
			if self.lag then self.lag:Show() end
			
			--self.value = GetTime() - (startTime / 1000)
			self.value = 0
			self.maxValue = (endTime - startTime) / 1000
			self.bar:SetMinMaxValues(0, self.maxValue)
			local statusMin, statusMax = self.bar:GetMinMaxValues()
			--print ("start ", statusMin, statusMax,self.value)
			self.bar:SetValue(self.value)
			self.bar.text:SetText(text)
			self.icon:SetTexture(texture)
			self:SetAlpha(1)
			self.holdTime = 0
			self.casting = 1
			self.castID = castID
			self.channeling = nil
			self.fadeOut = nil
			--if notInterruptible then -- addded in WOLTK--
				--self.bar:SetStatusBarColor(unpack(nointerrupt_color)) 
			--else 
			
			if  unit == 'player' then 
			
			self.bar:SetStatusBarColor(unpack(default_color_CB))
			
			else
			self.bar:SetStatusBarColor(unpack(default_color_TB))
			
			end
			--end
			
			
			if self.showCastbar then self:Show() end
		
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		--print(event, arg1,unit)	
			if self:IsVisible() then
		
		
				self:Hide()
			--print ("hide")
				self.flashing = 1
				self.fadeOut = 1
				self.holdTime = 0
			end
			
			if (self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") then
				if self.bar.spark then
					self.bar.spark:Hide()
				end
				self.bar.flash:SetAlpha(0)
				self.bar.flash:Show()
				self.bar:SetValue(self.maxValue)
				if event == "UNIT_SPELLCAST_STOP" then
					self.casting = nil
					self.bar:SetStatusBarColor(0, 1, 0)
				else
					self.channeling = nil
				end
				self.flashing = 1
				self.fadeOut = 1
				self.holdTime = 0
			end
		elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
			if self:IsShown() and (self.casting and select(4, ...) == self.castID) and not self.fadeOut then
				self.bar:SetValue(self.maxValue)
				self.bar:SetStatusBarColor(1, 0, 0)
				self.bar.spark:Hide()
				if event == "UNIT_SPELLCAST_FAILED" then
					self.bar.text:SetText(FAILED)
				else
					self.bar.text:SetText(INTERRUPTED)
				end
				if self.lag then self.lag:Hide() end
				self.casting = nil
				self.channeling = nil
				self.fadeOut = 1
				self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
			end
		elseif event == "UNIT_SPELLCAST_DELAYED" then
			if self:IsShown() then
				local name, text, texture, startTime, endTime, isTradeSkill, castID = UnitCastingInfo(unit)
				if not name then
					self:Hide()
					return
				end
				self.value = (GetTime() - (startTime / 1000))
				self.maxValue = (endTime - startTime) / 1000
				self.bar:SetMinMaxValues(0, self.maxValue)
				if not self.casting then
					self.bar:SetStatusBarColor(unpack(default_color_CB))
					self.bar.spark:Show()
					self.bar.flash:SetAlpha(0)
					self.bar.flash:Hide()
					self.casting = 1
					self.channeling = nil
					self.flashing = 0
					self.fadeOut = 0
				end
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			--print ("chanelstart:",unit)
		
			local name, text, texture, startTime, endTime, isTradeSkill, castID = UnitChannelInfo(unit)
			--print (name, text, texture, startTime, endTime, isTradeSkill, castID)
			if not name then
				self:Hide()
				return
			end
			
			if unit == 'player' then notInterruptible = false end
			if self.lag then self.lag:Hide() end

			self.bar:SetStatusBarColor(0, 1, 0)
			self.value = (endTime / 1000) - GetTime()
			self.maxValue = (endTime - startTime) / 1000
			self.bar:SetMinMaxValues(0, self.maxValue)
			self.bar:SetValue(self.value)
			self.bar.text:SetText(name)
			self.icon:SetTexture(texture)
			self.bar.spark:Hide()
			self:SetAlpha(1)
			self.holdTime = 0
			self.casting = nil
			self.channeling = 1
			self.fadeOut = nil
		
			self.bar:SetStatusBarColor(unpack(default_color)) 
			
			if self.showCastbar then self:Show() end
		elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		  --print ("chanel_Updatestart:",unit)
			    if self:IsShown() then
					
					local name, text, texture, startTime, endTime, isTradeSkill, castID = UnitChannelInfo(unit)
					--print (name, text, texture, startTime, endTime, isTradeSkill, castID)
					if not name then
						self:Hide()
						return
					end
					self.value = (endTime / 1000) - GetTime()
					self.maxValue = (endTime - startTime) / 1000
					self.bar:SetMinMaxValues(0, self.maxValue)
					self.bar:SetValue(self.value)
				
				--print("Gettime" , GetTime())
				--print("StartTime" , startTime)
				--print("EndTime" , endTime)
				--print("max" , self.maxValue)
				--print("min" , self.value*1000)
				end
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			--print ("interrupted hide")
			self.bar:Hide()
		
		elseif unit ~= 'player'  then 
			self.bar:SetStatusBarColor(unpack(nointerrupt_color))
		end
	end)
	
	frame:SetScript("OnUpdate", function(self, elapsed)
		
		if not self.locked then return end
		
		if not self.bar.timer then return end
		--if self.timerUpdate > elapsed  then print(elapsed-self.timerUpdate) end
		
		if self.timerUpdate and self.timerUpdate < elapsed then
				--print("update " ,self.maxValue , self.value  , elapsed)	
			if self.casting then
				self.bar.timer:SetText(format("%.1f", max(self.maxValue - (self.value), 0)))
			elseif self.channeling then
				self.bar.timer:SetText(format("%.1f", max(self.value, 0)))
			else
				self.bar.timer:SetText("")
			end
			self.timerUpdate = .1
		else
			self.timerUpdate = self.timerUpdate - elapsed
		
		end

		if self.casting then
			self.value = self.value + elapsed
			if self.value >= self.maxValue then
				self.bar:SetValue(self.maxValue)
				CastingBarFinishSpell(self, self.bar.spark, self.bar.flash)
				return
			end
			self.bar:SetValue(self.value)
			self.bar.flash:Hide()
			self.bar.spark:SetPoint("CENTER", self.bar:GetStatusBarTexture(), "RIGHT", 0, 0)
			if self.unit == "player" then -- then screen lagbar
				local down, up, lag = GetNetStats()
				local castingmin, castingmax = self.bar:GetMinMaxValues()
				local lagvalue = ( lag / 1000 ) / ( castingmax - castingmin )
				--print(lagvalue)
				if ( lagvalue < 0 ) then lagvalue = 0; elseif ( lagvalue > 1 ) then lagvalue = 1 end
				self.lag:ClearAllPoints()
				self.lag:SetPoint("RIGHT")
				self.lag:SetHeight(self.bar:GetHeight())
				self.lag:SetWidth(self.bar:GetWidth() * lagvalue)
			end
		elseif self.channeling then
			self.value = self.value - elapsed
			if self.value <= 0 then
				CastingBarFinishSpell(self, self.bar.spark, self.bar.flash)
				return
			end
			self.bar:SetValue(self.value)
			self.bar.flash:Hide()
		elseif GetTime() < self.holdTime then
			return
		elseif self.flashing then
			local alpha = 0
			alpha = self.bar.flash:GetAlpha() + CASTING_BAR_FLASH_STEP
			if alpha < 1 then
				self.bar.flash:SetAlpha(alpha)
			else
				self.bar.flash:SetAlpha(1)
				self.flashing = nil
			end
		elseif self.fadeOut then
			local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP
			if alpha > 0 then
				self:SetAlpha(alpha)
			else
				self.fadeOut = nil
				self:Hide()
			end
		end
	end)

end

--CastBars_EZ:RegisterEvent('PLAYER_TALENT_UPDATE') not present in classic
CastBars_EZ:RegisterEvent('PLAYER_ENTERING_WORLD')
CastBars_EZ:RegisterEvent('ADDON_LOADED')
CastBars_EZ:SetScript('OnEvent', function(self, event, arg1, ...)



	if (event=='ADDON_LOADED' and arg1 == addonName) or event == 'PLAYER_ENTERING_WORLD' then
	--if (event=='ADDON_LOADED' and arg1 == addonName) or event == 'PLAYER_ENTERING_WORLD' or event=='PLAYER_TALENT_UPDATE' then
		--print ("Addon loaded" , castbars.player )
		if castbars.player == true then 
			CastingBarFrame.showCastbar = false 
			CastingBarFrame:UnregisterAllEvents()
			TargetFrameSpellBar:SetScript("OnUpdate", function() end)
		
		end
		

		if castbars.target == true then 
			TargetFrameSpellBar.showCastbar = false 
			TargetFrameSpellBar:UnregisterAllEvents()
			TargetFrameSpellBar:SetScript("OnUpdate", function() end)
		end

		if castbars.focus == true then 
			FocusFrameSpellBar.showCastbar = false 
			FocusFrameSpellBar:UnregisterAllEvents()
			FocusFrameSpellBar:SetScript("OnUpdate", function() end)
		end

		if castbars.pet == true then 
			PetCastingBarFrame.showCastbar = false 
			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame:SetScript("OnUpdate", function() end)
		end

		for unit, enable in pairs(castbars) do
			if enable then
				MakeCastBar(unit, enable)
				
			end
		end
	end	
end)


-- setup slash command
SLASH_CastBars_EZ1 = "/ezcb";

SlashCmdList["CastBars_EZ"] = function(cmd)
	for unit, enable in pairs(castbars) do
		if enable then
			local castbar = _G[unit.."ezCastBar"]
			if castbar then
			--print(castbar)
				castbar.locked = not castbar.locked
				if castbar.locked then
					castbar:RegisterForDrag("")
					castbar:EnableMouse(false)
					castbar.bar.text:SetText("")
					castbar:Hide()
				else
					castbar:RegisterForDrag("LeftButton")
					castbar:EnableMouse(true)
					castbar.bar.text:SetText(unit)
					castbar:Show()
				end
				CastingBarHideContent(castbar)
				
			end
		end
	end
end