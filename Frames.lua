--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.init_frames = function(event)
    if event == "AUCTION_HOUSE_SHOW" then
        if not ProfessionMaster.frame then
            ProfessionMaster.init_auction_frames()
        end

        ProfessionMaster.tab_button:Show()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        if ProfessionMaster.tab_button then
            ProfessionMaster.tab_button:Hide()
        end

        if ProfessionMaster.frame then
            ProfessionMaster.frame:Hide()
        end
    elseif event == "LEARNED_SPELL_IN_TAB" or event == "PLAYER_ENTERING_WORLD" then
        ProfessionMaster.generate_frame()
    end
end

ProfessionMaster.init_auction_frames = function()
    if ProfessionMaster.frame then return end
    if not AuctionFrame then
        ProfessionMaster.enqueue({
            condition = function() return AuctionFrame ~= nil end,
            execute = ProfessionMaster.init_auction_frames,
            allow_skipping = true
        }, true)
        return
    end

    local tab_index = AuctionFrame.numTabs + 1

    local tab_button = CreateFrame(
        "Button",
        "AuctionFrameTab" .. tab_index,
        AuctionFrame,
        "AuctionTabTemplate"
    )

    tab_button:SetText("|cFFFF8000ProfessionMaster|r")
    tab_button:SetPoint("LEFT", _G["AuctionFrameTab" .. (tab_index - 1)], "RIGHT", -15, 0)
    tab_button:SetID(tab_index)

    ProfessionMaster.tab_button = tab_button

    local frame = CreateFrame(
        "Frame",
        "ProfessionMasterAHFrame",
        AuctionFrame
    )

    frame:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 12, -50)
    frame:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", 0, 8)
    frame:SetScript("OnEvent", function()
        ProfessionMaster.ah_source = true
        ProfessionMaster.dequeue()
    end)
    frame:Hide()

    local title = frame:CreateFontString(nil, nil, "GameFontNormal")
    title:SetText("ProfessionMaster")
    title:SetPoint("TOP", frame, "TOP")

    local scan_text = frame:CreateFontString(nil, nil, "GameFontNormal")
    scan_text:SetText("Scan best recipes for professions")
    scan_text:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -32)

    local i = 0
    
    local build = select(4, GetBuildInfo())

    for _, profession in pairs(ProfessionMaster.professions) do
        if profession.flags.crafting and (not profession.required_version or profession.required_version <= build) then
            local button = CreateFrame(
                "Button",
                "ProfessionMaster" .. profession.name .. "Button",
                frame,
                "UIPanelButtonTemplate"
            )

            button:SetText(profession.name)
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -48 - 28 * i)
            button:SetSize(128, 24)
            button:SetScript("OnClick", function()
                ProfessionMaster.fetch_recipes(profession)
            end)
            
            local fetch_button = CreateFrame(
                "Button",
                "ProfessionMaster" .. profession.name .. "Button",
                frame,
                "UIPanelButtonTemplate"
            )

            i = i + 1
        end
    end

    PanelTemplates_SetNumTabs(AuctionFrame, tab_index)
    PanelTemplates_EnableTab(AuctionFrame, tab_index)
    PanelTemplates_TabResize(tab_button, 0, nil, 36)

    hooksecurefunc(_G, "AuctionFrameTab_OnClick", function(button, ...)
        PanelTemplates_DeselectTab(tab_button)
        frame:Hide()

        if button == tab_button then
            PanelTemplates_SetTab(AuctionFrame, tab_index)
            PanelTemplates_SelectTab(tab_button)

            AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft");
            AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
            AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
            AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft");
            AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
            AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");    

            frame:Show()
        end
    end)

    ProfessionMaster.frame = frame
end

ProfessionMaster.set_background = function(frame, rounded_tr, rounded_br, rounded_bl, rounded_tl)
    local str = function(rounded)
        if rounded then return "Rounded" end
        return ""
    end

    local media = "Interface/Addons/ProfessionMaster/media/"

    frame.frames = {
        { f = CreateFrame("Frame", nil, frame), a = "TOPRIGHT",    w = function() return                    16 end, h = function() return                     16 end, t = media .. "FrameTopRight"    .. str(rounded_tr) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOMRIGHT", w = function() return                    16 end, h = function() return                     16 end, t = media .. "FrameBottomRight" .. str(rounded_br) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOMLEFT",  w = function() return                    16 end, h = function() return                     16 end, t = media .. "FrameBottomLeft"  .. str(rounded_bl) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "TOPLEFT",     w = function() return                    16 end, h = function() return                     16 end, t = media .. "FrameTopLeft"     .. str(rounded_tl) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "TOP",         w = function() return frame:GetWidth() - 32 end, h = function() return                     16 end, t = media .. "FrameTop.blp"                                  },
        { f = CreateFrame("Frame", nil, frame), a = "RIGHT",       w = function() return                    16 end, h = function() return frame:GetHeight() - 32 end, t = media .. "FrameRight.blp"                                },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOM",      w = function() return frame:GetWidth() - 32 end, h = function() return                     16 end, t = media .. "FrameBottom.blp"                               },
        { f = CreateFrame("Frame", nil, frame), a = "LEFT",        w = function() return                    16 end, h = function() return frame:GetHeight() - 32 end, t = media .. "FrameLeft.blp"                                 },
        { f = CreateFrame("Frame", nil, frame), a = "CENTER",      w = function() return frame:GetWidth() - 32 end, h = function() return frame:GetHeight() - 32 end, t = media .. "FrameCenter.blp"                               }
    }

    for _, data in ipairs(frame.frames) do
        data.f:SetSize(data.w(), data.h())
        data.f:SetPoint(data.a)
        data.f:SetFrameStrata("LOW")
        data.tex = data.f:CreateTexture()
        data.tex:SetAllPoints(data.f)
        data.tex:SetTexture(data.t)
    end

    frame:SetScript("OnSizeChanged", function()
        for _, data in ipairs(frame.frames) do
            data.f:SetSize(data.w(), data.h())
        end
    end)
end

ProfessionMaster.reset_position = function()
    if ProfessionMaster.main_frame then
        ProfessionMaster.main_frame:ClearAllPoints()
        ProfessionMaster.main_frame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", -32, 90)
    end
    
    if ProfessionMaster.step_frame then
        ProfessionMaster.step_frame:ClearAllPoints()
        ProfessionMaster.step_frame:SetPoint("TOP", nil, "TOP", 0, -16)
    end
    
    PM.x_pos = nil
    PM.y_pos = nil
    PM.anchor = "BOTTOMRIGHT"
    PM.anchor_to = "BOTTOMRIGHT"
    PM.step_x_pos = nil
    PM.step_y_pos = nil
    PM.step_anchor = "TOP"
    PM.step_anchor_to = "TOP"
end

ProfessionMaster.generate_frame = function()
    local frame = ProfessionMaster.main_frame or (function()
        local f = CreateFrame("Frame", "PMFrame", UIParent)
        ProfessionMaster.set_background(f, false, true, true, false)
        return f
    end)()

    frame:SetWidth(280)
    frame:SetHeight(72)
    frame:RegisterForDrag("LeftButton")
    frame:SetPoint(PM.anchor or "BOTTOMRIGHT", PM.x_pos or -16, PM.y_pos or 90)
    frame:SetClampedToScreen(true)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        PM.anchor, _, PM.anchor_to, PM.x_pos, PM.y_pos = self:GetPoint()
    end)

    frame.close = frame.close or CreateFrame("Button", "PMFrameClose", frame, "UIPanelButtonTemplate")
    frame.close:SetPoint("TOPRIGHT", -4, -4)
    frame.close:SetWidth(20)
    frame.close:SetHeight(20)
    frame.close:SetScript("OnClick", function()
        ProfessionMaster.hide()
    end)

    frame.close.inner = frame.close.inner or CreateFrame("Button", "PMFrameCloseInner", frame.close)
    frame.close.inner:SetNormalTexture("Interface/Buttons/UI-StopButton")
    frame.close.inner:SetPoint("CENTER")
    frame.close.inner:SetWidth(12)
    frame.close.inner:SetHeight(12)
    frame.close.inner:EnableMouse(false)

    --[[local br = CreateFrame("Button", nil, frame)
    br:EnableMouse("true")
    br:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    br:SetSize(12, 12)
    br:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")

    br:SetScript("OnMouseDown", function(self)
        self:GetParent():StartSizing("BOTTOMRIGHT") 
    end)
    br:SetScript("OnMouseUp", function(self)
        self:GetParent():StopMovingOrSizing("BOTTOMRIGHT")
    end)]]
    
    local title = frame.title or frame:CreateFontString(nil, nil, "GameFontNormal")
    title:SetText("ProfessionMaster")
    title:SetPoint("TOP", frame, "TOP", 0, -4)
    title:SetTextColor(1, 1, 1)

    frame.title = title

    local your_professions = frame.your_professions or frame:CreateFontString(nil, nil, "GameFontNormal")
    your_professions:SetText("Your professions:")
    your_professions:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -24)
    your_professions:SetTextColor(1, 1, 1)

    frame.your_professions = your_professions

    local alignment = "TOPLEFT"
    local xoff = 8

    local buttons = frame.buttons or { }
    frame.profession_frames = frame.profession_frames or { }

    -- todo: Secondary professions!!!
    -- todo: Update when training new profession!!!
    for index = 1, GetNumSkillLines() do
        local name, _, _, level = GetSkillLineInfo(index)
        if ProfessionMaster.professions[name:gsub("%s+", ""):lower()] ~= nil then
            local profession = ProfessionMaster.professions[name:gsub("%s+", ""):lower()]

            if profession.flags.primary then

                local button = buttons[index] or CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
                button:SetPoint(alignment, frame, alignment, xoff, -40)
                button:SetText(name)
                button:SetSize(128, 24)

                button:SetScript("OnClick", function()
                    local profession_frame = frame.profession_frames[name]
                    
                    if not profession_frame then
                        profession_frame = CreateFrame("Frame", nil, frame)
                        profession_frame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 4)
                        profession_frame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 4)
                        profession_frame:SetHeight(44)

                        ProfessionMaster.set_background(profession_frame, true, false, false, true);

                        if frame.visible_frame then
                            frame.visible_frame:Hide()
                        end

                        frame.visible_frame = profession_frame

                        profession_frame.title = profession_frame:CreateFontString(nil, nil, "GameFontNormal")
                        profession_frame.title:SetJustifyH("CENTER")
                        profession_frame.title:SetText(name)
                        profession_frame.title:SetPoint("TOP", 0, -8)
                        profession_frame.title:SetTextColor(1, 1, 1)

                        profession_frame.level = profession_frame:CreateFontString(nil, nil, "GameFontNormal")
                        profession_frame.level:SetJustifyH("CENTER")
                        profession_frame.level:SetText(ProfessionMaster.check_for_levelups(profession))
                        profession_frame.level:SetPoint("BOTTOM", 0, 8)

                        --[[if not profession.list then
                            profession_frame:SetHeight(44)

                            -- todo: Free content

                            profession_frame.text = profession_frame:CreateFontString(nil, nil, "GameFontNormal")
                            profession_frame.text:SetJustifyH("CENTER")
                            profession_frame.text:SetText("|cFFFF0000You do not own a guide for this profession!")
                            profession_frame.text:SetPoint("BOTTOM", 0, 8)
                        else]]
                            if profession.flags.gathering then
                                profession_frame.sub_frame = CreateFrame("Frame", nil, profession_frame)
                                profession_frame.sub_frame:Hide()

                                profession_frame.sub_frame:SetPoint("TOPLEFT", 0, -60)
                                profession_frame.sub_frame:SetPoint("TOPRIGHT", 0, -60)

                                profession_frame.sub_frame:SetHeight(96)

                                profession_frame.sub_frame.query_button = CreateFrame("Button", nil, profession_frame.sub_frame, "UIPanelButtonTemplate")
                                profession_frame.sub_frame.query_button:SetText("Find best route")
                                profession_frame.sub_frame.query_button:SetPoint("TOPLEFT", 8, -4)
                                profession_frame.sub_frame.query_button:SetWidth(264)
                                profession_frame.sub_frame.query_button:SetScript("OnClick", function()
                                    if profession_frame.selected_vein == nil then return end

                                    ProfessionMaster.request_route_usage(profession_frame.selected_vein, profession_frame.selected_area)
                                end)

                                profession_frame.sub_frame.optimal_route = CreateFrame("Button", nil, profession_frame.sub_frame, "UIPanelButtonTemplate")
                                profession_frame.sub_frame.optimal_route:SetText("Use best route")
                                profession_frame.sub_frame.optimal_route:SetPoint("LEFT", 8, 0)
                                profession_frame.sub_frame.optimal_route:SetWidth(128)
                                profession_frame.sub_frame.optimal_route:SetScript("OnClick", function()
                                    if profession_frame.selected_vein == nil or ProfessionMaster.best_area == nil or ProfessionMaster.best_route == nil then return end

                                    ProfessionMaster.start_route("mining", profession_frame.selected_vein, ProfessionMaster.best_area, ProfessionMaster.best_route, profession_frame.current_other_nodes)

                                    UIDropDownMenu_SetText(profession_frame.sub_frame.manual_route, C_Map.GetMapInfo(ProfessionMaster.best_area).name .. " (" .. ProfessionMaster.best_route .. ")")

                                    profession_frame.sub_frame.stop_button:Enable()
                                end)
                                
                                profession_frame.sub_frame.manual_route = CreateFrame("Frame", nil, profession_frame.sub_frame, "UIDropDownMenuTemplate")
                                profession_frame.sub_frame.manual_route:SetPoint("RIGHT", 8, -2)
                                UIDropDownMenu_SetWidth(profession_frame.sub_frame.manual_route, 112)

                                profession_frame.sub_frame.stop_button = CreateFrame("Button", nil, profession_frame.sub_frame, "UIPanelButtonTemplate")
                                profession_frame.sub_frame.stop_button:SetText("Stop route")
                                profession_frame.sub_frame.stop_button:SetPoint("BOTTOMLEFT", 8, 4)
                                profession_frame.sub_frame.stop_button:SetWidth(264)
                                profession_frame.sub_frame.stop_button:SetScript("OnClick", function()
                                    ProfessionMaster.stop_route()
                                    profession_frame.sub_frame.stop_button:Disable()
                                    UIDropDownMenu_SetText(profession_frame.sub_frame.manual_route, "Choose a route")
                                end)

                                function pre_sort(list)
                                    local output = { }

                                    for level = 1, 450 do
                                        for id, entry in pairs(list) do
                                            if entry.min_level == level then
                                                table.insert(output, {
                                                    id = id,
                                                    entry = entry
                                                })
                                            end
                                        end
                                    end

                                    return output
                                end

                                profession_frame.nodes_list = profession_frame.nodes_list or pre_sort(profession.list.nodes)

                                profession_frame.ore_selector = CreateFrame("Frame", nil, profession_frame, "UIDropDownMenuTemplate")
                                profession_frame.ore_selector:SetPoint("TOPLEFT", -8, -22)
                                UIDropDownMenu_SetWidth(profession_frame.ore_selector, 112)
                                UIDropDownMenu_Initialize(profession_frame.ore_selector, function(self, level, menu_list)
                                    local info = UIDropDownMenu_CreateInfo()

                                    for _, node in ipairs(profession_frame.nodes_list) do
                                        info.text, info.arg1, info.arg2, info.func, info.checked = node.entry.name, node.id, node.entry.name, self.set_value, node.id == profession_frame.selected_vein
                                        UIDropDownMenu_AddButton(info)
                                    end
                                end)

                                function profession_frame.ore_selector:set_value(vein_id, name)
                                    profession_frame.selected_vein = vein_id
                                    profession_frame.selected_area = 0

                                    UIDropDownMenu_SetText(profession_frame.ore_selector, name)
                                    CloseDropDownMenus()
                                    
                                    profession_frame:SetHeight(84 + profession_frame.sub_frame:GetHeight())
                                    profession_frame.area_selector:Show()
                                    profession_frame.sub_frame:Show()

                                    UIDropDownMenu_Initialize(profession_frame.area_selector, function(self, level, menu_list)
                                        local info = UIDropDownMenu_CreateInfo()
        
                                        info.text, info.arg1, info.arg2, info.func, info.checked = "Any zone", 0, "Any zone", self.set_value, 0 == profession_frame.selected_area
                                        UIDropDownMenu_AddButton(info)

                                        for zone_id, routes in pairs(profession.list.nodes[profession_frame.selected_vein].routes) do
                                            if #routes > 0 then
                                                info.text, info.arg1, info.arg2, info.func, info.checked = C_Map.GetMapInfo(zone_id).name, zone_id, C_Map.GetMapInfo(zone_id).name, self.set_value, zone_id == profession_frame.selected_area
                                                UIDropDownMenu_AddButton(info)
                                            end
                                        end
                                    end)

                                    UIDropDownMenu_Initialize(profession_frame.sub_frame.manual_route, function(self, level, menu_list)
                                        local routes = profession.list.nodes[profession_frame.selected_vein].routes
                                        if not level or level == 1 then
                                            local info = UIDropDownMenu_CreateInfo()

                                            for zone_id, _ in pairs(routes) do
                                                if #routes[zone_id] > 0 then
                                                    info.text, info.hasArrow, info.menuList, info.checked = C_Map.GetMapInfo(zone_id).name, true, zone_id, ProfessionMaster.current_area == zone_id
                                                    UIDropDownMenu_AddButton(info)
                                                end
                                            end
                                        elseif menu_list then
                                            local info = UIDropDownMenu_CreateInfo()

                                            for route_id, route in ipairs(routes[menu_list]) do
                                                info.arg1, info.arg2, info.func, info.checked = route_id, menu_list, self.set_value, ProfessionMaster.current_area == menu_list and ProfessionMaster.current_route == route_id
                                                
                                                if route.name then
                                                    info.text = "(" .. route_id .. ") " .. route.name
                                                else
                                                    info.text = route_id
                                                end

                                                UIDropDownMenu_AddButton(info, level)
                                            end
                                        end
                                    end)
                                end

                                function profession_frame.sub_frame.manual_route:set_value(route_id, zone_id)
                                    ProfessionMaster.start_route("mining", profession_frame.selected_vein, zone_id, route_id, profession_frame.current_other_nodes)

                                    UIDropDownMenu_SetText(profession_frame.sub_frame.manual_route, C_Map.GetMapInfo(zone_id).name .. " (" .. route_id .. ")")

                                    profession_frame.sub_frame.stop_button:Enable()
                                    CloseDropDownMenus()
                                end

                                profession_frame.area_selector = CreateFrame("Frame", nil, profession_frame, "UIDropDownMenuTemplate")
                                profession_frame.area_selector:SetPoint("TOPRIGHT", 8, -22)
                                UIDropDownMenu_SetWidth(profession_frame.area_selector, 112)

                                function profession_frame.area_selector:set_value(zone_id, name)
                                    profession_frame.selected_area = zone_id
                                    UIDropDownMenu_SetText(profession_frame.area_selector, name)
                                    CloseDropDownMenus()
                                end

                                profession_frame.reset = function()
                                    profession_frame:SetHeight(76)

                                    UIDropDownMenu_SetText(profession_frame.ore_selector, "Select a node")
                                    UIDropDownMenu_SetText(profession_frame.area_selector, "Any zone")
                                    UIDropDownMenu_SetText(profession_frame.sub_frame.manual_route, "Choose a route")

                                    profession_frame.selected_vein = nil
                                    profession_frame.selected_area = 0
                                    profession_frame.area_selector:Hide()
                                    profession_frame.sub_frame:Hide()
                                    profession_frame.sub_frame.optimal_route:Disable()

                                    ProfessionMaster.best_route = nil
                                    ProfessionMaster.best_area = nil 
                                    
                                    if not ProfessionMaster.current_profession then
                                        profession_frame.sub_frame.stop_button:Disable()
                                    else
                                        profession_frame.sub_frame.stop_button:Enable()
                                    end
                                end
                            end
                        --end

                        if profession_frame.reset then
                            profession_frame.reset()
                        end

                        frame.profession_frames[name] = profession_frame
                    else
                        if profession_frame:IsVisible() then
                            profession_frame:Hide()

                            frame.visible_frame = nil
                        else
                            if frame.visible_frame then
                                frame.visible_frame:Hide()
                            end

                            if profession_frame.reset then
                                profession_frame.reset()
                            end

                            profession_frame:Show()

                            frame.visible_frame = profession_frame
                        end
                    end
                end)

                for name, profession_frame in pairs(frame.profession_frames) do
                    if profession_farme.level then
                        profession_frame.level:SetText(ProfessionMaster.check_for_levelups(profession))
                    end
                end

                alignment = "TOPRIGHT"
                xoff = -8

                buttons[index] = button
            end
        end
    end

    frame.buttons = buttons
    
    frame:Show()

    ProfessionMaster.main_frame = frame

    local step_frame = ProfessionMaster.step_frame or CreateFrame("Frame", "PMStepFrame", UIParent)

    step_frame:SetWidth(48)
    step_frame:SetHeight(48)
    step_frame:RegisterForDrag("LeftButton")
    step_frame:SetPoint(PM.step_anchor or "TOP", PM.step_x_pos or 0, PM.step_y_pos or -16)
    step_frame:SetClampedToScreen(true)

    step_frame:SetMovable(true)
    step_frame:EnableMouse(true)
    step_frame:RegisterForDrag("LeftButton")
    
    step_frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    step_frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        PM.step_anchor, _, PM.step_anchor_to, PM.step_x_pos, PM.step_y_pos = self:GetPoint()
    end)

    step_frame.text = step_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    step_frame.text:SetJustifyH("CENTER")
    step_frame.text:SetText("")
    step_frame.text:SetPoint("TOP", step_frame, "BOTTOM", 0, -8)


    step_frame.tex = step_frame:CreateTexture()
    step_frame.tex:SetAllPoints(step_frame)
    step_frame.tex:SetColorTexture(0.04, 0.08, 0.13, 0.75)

    step_frame.mask = step_frame:CreateMaskTexture()
    step_frame.mask:SetAllPoints(step_frame.tex)
    step_frame.mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    step_frame.tex:AddMaskTexture(step_frame.mask)

    step_frame:Hide()

    step_frame.inner_frame = step_frame.inner_frame or CreateFrame("Frame", nil, step_frame)
    
    step_frame.inner_frame:SetWidth(8)
    step_frame.inner_frame:SetHeight(8)
    step_frame.inner_frame:SetMovable(false)
    step_frame.inner_frame:SetPoint("CENTER", 0, 0)

    step_frame.inner_frame.tex = step_frame.inner_frame:CreateTexture()
    step_frame.inner_frame.tex:SetAllPoints(step_frame.inner_frame)
    step_frame.inner_frame.tex:SetColorTexture(0.31, 0.61, 0.85, 1.00)

    step_frame.inner_frame.mask = step_frame:CreateMaskTexture()
    step_frame.inner_frame.mask:SetAllPoints(step_frame.inner_frame.tex)
    step_frame.inner_frame.mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    step_frame.inner_frame.tex:AddMaskTexture(step_frame.inner_frame.mask)

    ProfessionMaster.step_frame = step_frame

    -- minimap button

    local minimap_button = LibStub("LibDataBroker-1.1"):NewDataObject("ProfessionMaster", {
        type = "data source",
        text = "ProfessionMaster",
        icon = "Interface/Addons/ProfessionMaster/media/ProfessionMaster.blp",
        OnClick = function(self, btn)
            if btn == "LeftButton" then
                ProfessionMaster.toggle()
            elseif btn == "RightButton" then
                ProfessionMaster.reset_position()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("ProfessionMaster")
            tooltip:AddLine("Left click: |cFFFFFFFFToggle frame")
            tooltip:AddLine("Right click: |cFFFFFFFFReset frame position")
        end,
    })

    local icon = LibStub("LibDBIcon-1.0", true)
    icon:Register("ProfessionMaster", minimap_button, PM)
end

ProfessionMaster.hide = function()
    ProfessionMaster.main_frame:Hide()
end

ProfessionMaster.show = function()
    ProfessionMaster.main_frame:Show()
end

ProfessionMaster.toggle = function()
    if ProfessionMaster.main_frame:IsVisible() then
        ProfessionMaster.hide()
    else
        ProfessionMaster.show()
    end
end

ProfessionMaster.frame_initializer = function()
    local helper = CreateFrame("Frame", nil, UIParent)
    helper:RegisterEvent("AUCTION_HOUSE_SHOW")
    helper:RegisterEvent("AUCTION_HOUSE_CLOSED")
    helper:RegisterEvent("LEARNED_SPELL_IN_TAB")
    helper:RegisterEvent("PLAYER_ENTERING_WORLD")
    helper:SetScript("OnEvent", ProfessionMaster.init_frames)

    ProfessionMaster.enqueue({
        condition = function() return AuctionFrame ~= nil end,
        execute = ProfessionMaster.init_auction_frames,
        allow_skipping = true
    }, true)
end
