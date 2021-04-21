local CastBars_EZ = _G['CastBars_EZ'] or CreateFrame('frame', 'CastBars_EZ', UIParent)
local addonName, ns = ...
local nointerrupt_color = { .9, 0, 0, 1}
local default_color = { 1, .7, 0, 1}

local show_text = true
local show_timer = true

local castbars = { 
	player = true, 
	target = true, 
	focus = true, 
	pet = true, 
}

local CastingBarHideContent = function(self)
	if not self.locked then
		self:SetAlpha(1)
		self.bar.flash:Hide()
		self.bar.spark:Hide()
		self.bar.timer:Hide()
		if self.lag then self.lag:Hide() end
		self.bar:SetStatusBarColor(.2,.2,.2)
		self.icon:SetTexture('Interface\\ICONS\\Trade_engineering')
		self.resize:Show();
	else
		self:SetAlpha(0)
		self.bar.flash:Show()
		self.bar.spark:Show()
		if show_timer then self.bar.timer:Show() end
		if self.lag then self.lag:Show() end
		self.bar:SetStatusBarColor(unpack(default_color))
		self.resize:Hide()
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
			print (st)
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
			
			self.bar:SetStatusBarColor(unpack(default_color))
			self.bar.spark:Show()
			
			if self.lag then self.lag:Show() end
			
			--self.value = GetTime() - (startTime / 1000)
			self.value = 0
			self.maxValue = (endTime - startTime) / 1000
			self.bar:SetMinMaxValues(0, self.maxValue)
			local statusMin, statusMax = self.bar:GetMinMaxValues()
			print ("start ", statusMin, statusMax,self.value)
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
				self.bar:SetStatusBarColor(unpack(default_color))
			--end
			
			
			if self.showCastbar then self:Show() end
		
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		print(event, arg1,unit)	
			if not self:IsVisible() then
				self:Hide()
			print ("hide")
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
					self.bar:SetStatusBarColor(unpack(default_color))
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
			print ("interrupted hide")
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
		
		if castbars.player == true then 
			CastingBarFrame.showCastbar = false 
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame:SetScript("OnUpdate", function() end)
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