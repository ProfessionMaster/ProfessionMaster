--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

local UILib = { }

UILib.frames = { }

UILib.CreateFrame = function(frame_type, name, parent, template, mt, mr, mb, ml)
    local frame = CreateFrame(frame_type, name, parent, template)

    frame.frame_index = #UILib.frames + 1
    frame.children = { }
    frame.rows = { }
    frame.deleted_rows = { }
    frame.mt = mt or 0
    frame.mr = mr or frame.mt
    frame.mb = mb or frame.mt
    frame.ml = ml or frame.mr

    function frame:AddText(str, mt, mr, mb, ml, justify)
        local text = nil
        
        if #self.deleted_rows > 0 then
            text = self.deleted_rows[#self.deleted_rows]
            text:Show()
            self.deleted_rows[#self.deleted_rows] = nil
        else
            text = self:CreateFontString(nil, nil, "GameFontNormal")

            function text:GetBorderBoxHeight()
                return self:GetHeight() + self.mt + self.mb
            end
    
            function text:UpdatePosition()
                local cur_mt = 0
    
                for _, c in pairs(self.parent.children) do
                    if c.index >= self.index then break end
                    cur_mt = cur_mt + c:GetBorderBoxHeight()
                end
    
                self:SetPoint("TOPLEFT",  self.parent, "TOPLEFT",   self.parent.ml + self.ml, -self.parent.mt - self.mt - cur_mt)
                self:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", -self.parent.mr - self.mr, -self.parent.mt - self.mt - cur_mt)

                if self.frame then
                    self.frame:SetPoint("TOPLEFT",     self.parent, "TOPLEFT",   self.parent.ml + self.ml, -self.parent.mt - self.mt - cur_mt)
                    self.frame:SetPoint("BOTTOMRIGHT", self.parent, "TOPRIGHT", -self.parent.mr - self.mr, -self.parent.mt - self.mt - cur_mt - self:GetHeight())
                end
            end
    
            function text:UpdateText(str)
                self:SetText(str)
                self:UpdatePosition()
    
                for _, c in pairs(self.parent.children) do
                    if c.index > self.index then
                        c:UpdatePosition()
                    end
                end
            end
    
            function text:DeleteText()
                self:Hide()
                self:SetText("")

                self.click_handler = nil
                self.tooltip_hidden = true
                
                for _, t in pairs(self.parent.children) do
                    if t.index > self.index then
                        t.index = t.index - 1
                    end
                end
    
                for i = self.index, #self.parent.children - 1 do
                    self.parent.children[i] = self.parent.children[i + 1]
                    self.parent.children[i].index = i
                end
    
                self.parent.children[#self.parent.children] = nil
                
                for i = self.row_index, #self.parent.rows - 1 do
                    self.parent.rows[i] = self.parent.rows[i + 1]
                    self.parent.rows[i].row_index = i
                end
    
                self.parent.rows[#self.parent.rows] = nil
    
                for _, t in pairs(self.parent.children) do
                    t:UpdatePosition()
                end
    
                self.index = #self.parent.deleted_rows + 1
                self.parent.deleted_rows[self.index] = self
            end

            function text:TryCreateFrame()
                if not self.frame then
                    local text_obj = self

                    self.frame = CreateFrame("Frame", nil, self.parent)
                    self.frame:SetFrameStrata("TOOLTIP")
                    self.frame:SetScript("OnMouseDown", function()
                        if text_obj.click_handler then
                            text_obj.click_handler()
                        end
                    end)
                    self.frame:SetScript("OnEnter", function()
                        if text_obj.tooltip and not text_obj.tooltip_hidden then
                            GameTooltip:SetOwner(text_obj.frame, "ANCHOR_CURSOR")
                            text_obj.tooltip()
                            GameTooltip:Show()
                        end
                    end)
                    self.frame:SetScript("OnLeave", function()
                        if text_obj.tooltip and not text_obj.tooltip_hidden then
                            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                            GameTooltip:Hide()
                        end
                    end)

                    self:UpdatePosition()
                end
            end

            function text:OnClick(func)
                self.click_handler = func
                self:TryCreateFrame()
            end

            function text:AddTooltip(func)
                self.tooltip_hidden = false
                self:TryCreateFrame()

                self.tooltip = func
            end
        end

        text.index = #self.children + 1
        text.row_index = #self.rows + 1
        text.parent = self
        text.mt = mt or 0
        text.mr = mr or text.mt
        text.mb = mb or text.mt
        text.ml = ml or text.mr
        text.justify = justify or "LEFT"

        text:SetJustifyH(text.justify)

        text:UpdateText(str)
        
        self.children[text.index] = text
        self.rows[text.row_index] = text
        
        return text
    end

    function frame:AddFrame(frame_type, name, template, mt, mr, mb, ml)
        local child = UILib.CreateFrame(frame_type, name, self, template, mt, mr, mb, ml)

        child.index = #self.children + 1
        child.parent = self

        function child:UpdatePosition()
            local cur_mt = 0

            for _, child in pairs(self.parent.children) do
                if child.index >= self.index then break end
                cur_mt = cur_mt + child:GetBorderBoxHeight()
            end

            self:SetPoint("TOPLEFT",     self.parent, "TOPLEFT",      self.parent.ml + self.ml, -self.parent.mt - self.mt - cur_mt)
            self:SetPoint("BOTTOMRIGHT", self.parent, "BOTTOMRIGHT", -self.parent.mr - self.mr,  self.parent.mb + self.mb)
        end

        child:UpdatePosition()

        self.children[child.index] = child

        return child
    end

    function frame:GetBorderBoxHeight()
        local content_height = 0

        for _, c in pairs(self.children) do
            content_height = content_height + c:GetBorderBoxHeight()
        end

        return content_height + self.mt + self.mb
    end

    function frame:DeleteAllText()
        while #self.rows > 0 do
            self.rows[1]:DeleteText()
        end
    end

    table.insert(UILib.frames, frame)

    return frame
end

ProfessionMaster = ProfessionMaster or { }
ProfessionMaster.UILib = UILib
