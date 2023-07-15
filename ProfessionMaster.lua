--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = { }

ProfessionMaster.acceptable_time = 5

ProfessionMaster.verbose = true -- Disable in production

ProfessionMaster.current_profession = nil
ProfessionMaster.current_vein = nil
ProfessionMaster.current_area = nil
ProfessionMaster.current_route = nil
ProfessionMaster.current_step = 0
ProfessionMaster.current_other_nodes = false

ProfessionMaster.en_route_since = nil
ProfessionMaster.starting_ores = nil

PM = PM or { }

ProfessionMaster.professions = {
    jewelcrafting = {
        list = _G["jewelcrafting"],
        name = "Jewelcrafting"
    },
    -- to do
    alchemy = {
        list = nil,
        name = "Alchemy"
    },
    blacksmithing = {
        list = nil,
        name = "Blacksmithing"
    },
    enchanting = {
        list = nil,
        name = "Enchanting"
    },
    engineering = {
        list = nil,
        name = "Engineering"
    },
    inscription = {
        list = nil,
        name = "Inscription"
    },
    leatherworking = {
        list = nil,
        name = "Leatherworking"
    },
    tailoring = {
        list = nil,
        name = "Tailoring"
    },
}

ProfessionMaster.gathering_professions = {
    mining = {
        list = _G["MINING"],
        name = "Mining"
    },
    -- to do
    herbalism = {
        list = nil,
        name = "Herbalism"
    },
    skinning = {
        list = nil,
        name = "Skinning"
    }
}

if PM.items == nil then PM.items = { } end

ProfessionMaster.queue = { }

ProfessionMaster.print = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8000Profession Master|r: " .. msg)
end

ProfessionMaster.print_verbose = function(msg)
    if ProfessionMaster.verbose then
        ProfessionMaster.print(msg)
    end
end

ProfessionMaster.format_price = function(price)
    if price == 0 then return "|cFFFF0000not available|r" end

    local copper = math.floor(price % 100)
    local silver = math.floor(price / 100) % 100
    local gold   = math.floor(price / 10000)

    if gold > 0 then
        return "|cFFFFD700" .. gold .. "g |r|cFFC0C0C0" .. silver .. "s |r|cFFB87333" .. copper .. "c|r"
    elseif silver > 0 then
        return "|cFFC0C0C0" .. silver .. "s |r|cFFB87333" .. copper .. "c|r"
    else
        return "|cFFB87333" .. copper .. "c|r"
    end
end

ProfessionMaster.color_source = function(recipe)
    if recipe.taught_by_trainer then
        return "|cFF00FF00" .. recipe.source .. "|r"
    elseif recipe.source == "Vendor" then
        return "|cFFFFFF00" .. recipe.source .. "|r"
    else
        return "|cFFFF0000" .. recipe.source .. "|r"
    end
end

ProfessionMaster.print_recipe = function(profession, recipe, msg, level)
    local link          = GetSpellLink(recipe.spell_id)
    local price         = ProfessionMaster.fetch_recipe_price(profession, recipe)
    local average_price = ProfessionMaster.fetch_recipe_price_per_skill_up(profession, recipe, level)

    local text = link .. " - Price per craft: " .. ProfessionMaster.format_price(price) .. " - Average price per skill up: " .. ProfessionMaster.format_price(average_price)

    if msg ~= nil then text = msg .. " " .. text end

    ProfessionMaster.print(text)
end

ProfessionMaster.print_material = function(profession, material)
    local item   = PM.items[material.item_id]
    local source = item.best_source

    if source == nil then
        source = "|cFFFF0000not available|r"
    elseif source ~= "vendor" and source ~= "auction house" then
        source = GetSpellLink(source.spell_id)
    end

    ProfessionMaster.print(material.amount .. "x " .. item.item.name .. " (" .. ProfessionMaster.format_price(item.price) .. " per unit, " .. ProfessionMaster.format_price(item.price * material.amount) .. " total) - Source: " .. source)
end

ProfessionMaster.get_skill_up_chance = function(recipe, skill_level)
    if recipe.levels[2] <= skill_level then
        return (recipe.levels[3] - skill_level)/(recipe.levels[3] - recipe.levels[2])
    elseif recipe.levels[3] > skill_level then
        return 1
    else
        return 0
    end
end

ProfessionMaster.auction_house_is_ready = function()
    if ProfessionMaster.ah_source and CanSendAuctionQuery() then
        ProfessionMaster.ah_source = false
        return true
    end
    return false
end

ProfessionMaster.dequeue = function(hw_input)
    if #ProfessionMaster.queue == 0 then return end

    for index, query in pairs(ProfessionMaster.queue) do
        if not query.requires_hw_input or hw_input then
            if query.condition() then
                query.execute()
                table.remove(ProfessionMaster.queue, index)
                ProfessionMaster.dequeue()
                return
            elseif query.allow_skipping ~= true then
                return
            end
        end
    end
end

ProfessionMaster.enqueue = function(query, never_auto_dequeue)
    table.insert(ProfessionMaster.queue, query)

    if #ProfessionMaster.queue == 1 and (never_auto_dequeue == nil or never_auto_dequeue == false) then
        ProfessionMaster.dequeue()
    end
end

ProfessionMaster.fetch_recipes = function(profession)
    if profession == nil then
        ProfessionMaster.print("This profession does not exist!")
        return
    end

    if not CanSendAuctionQuery() then
        ProfessionMaster.print("You have to be at the auction house to use this function!")
        return
    end

    ProfessionMaster.queue = { }

    local skill_id, skill = -1, 0

    for index = 1, GetNumSkillLines() do
        local name, _, _, level = GetSkillLineInfo(index)
        if name == profession.name then
            skill    = level
            skill_id = index
        end
    end

    ProfessionMaster.frame:RegisterAllEvents()

    ProfessionMaster.print("Fetching all recipes for " .. profession.name .. "...")

    profession.best_recipes = { }

    local total_items = 0

    for item_id, item in pairs(profession.list.items) do
        if item.used_in_recipes then
            total_items = total_items + 1
        end
    end

    local current_item = 1

    for item_id, item in pairs(profession.list.items) do
        if item.used_in_recipes then
            ProfessionMaster.enqueue({
                condition = ProfessionMaster.auction_house_is_ready,
                execute   = function()
                    if not invalid then
                        best_material_source = item.sold_at_vendor and "vendor" or nil
                        lowest_price         = item.vendor_purchase_price

                        SortAuctionSetSort("list", "unitprice")
                        QueryAuctionItems(item.name, nil, nil, 0, nil, nil, false, true, nil)
                    end
                end
            })

            ProfessionMaster.enqueue({
                condition = ProfessionMaster.auction_house_is_ready,
                execute   = function()
                    if not invalid then
                        if GetNumAuctionItems("list") >= 1 then
                            local _,_,count,_,_,_,_,_,_,buyout_price,_,_,_,_,_,_,_,_ = GetAuctionItemInfo("list", 1)

                            local auction_price = buyout_price / count

                            if lowest_price == 0 or auction_price < lowest_price then
                                best_material_source = "auction house"
                                lowest_price = auction_price
                            end

                            PM.items[item_id] = {
                                item              = item,
                                found_best_source = false,
                                best_source       = best_material_source,
                                vendor_price      = profession.list.items[item_id].vendor_purchase_price,
                                auction_price     = auction_price,
                                price             = lowest_price
                            }
                        end

                        local _, link = GetItemInfo(item_id)

                        ProfessionMaster.print(current_item .. "/" .. total_items .. " " .. link .. " - price: " .. ProfessionMaster.format_price(lowest_price))

                        current_item = current_item + 1
                    end
                end
            })
        end
    end

    ProfessionMaster.enqueue({
        condition = function() return true end,
        execute   = function()
            ProfessionMaster.frame:UnregisterAllEvents()

            -- Compare auction house / vendor prices to crafting prices
            for item_id, v in pairs(profession.list.recipes) do
                for _, recipe in ipairs(v) do
                    if PM.items[item_id] == nil then
                        PM.items[item_id] = {
                            item              = profession.list.items[item_id],
                            found_best_source = false,
                            best_source       = best_material_source,
                            vendor_price      = profession.list.items[item_id].vendor_purchase_price,
                            auction_price     = auction_price,
                            price             = lowest_price
                        }
                    end

                    local price = ProfessionMaster.fetch_recipe_product_price(profession, recipe)

                    if price < PM.items[item_id].price then
                        PM.items[item_id].best_source = recipe
                        PM.items[item_id].price       = price
                    end
                end
            end

            profession.last_scan_date = date("%m/%d/%y %H:%M:%S")

            for item_id, item in ipairs(PM.items) do
                item.found_best_source = true
            end

            for level = 1, 450 do
                profession.best_recipes[level] = ProfessionMaster.get_best_recipe(profession, level)
            end

            if skill ~= 0 then
                ProfessionMaster.print_best_recipe(profession, skill)
            end
        end
    })
end

ProfessionMaster.print_best_recipe = function(profession, skill)
    ProfessionMaster.print("Best recipe for " .. profession.name .. " at current level (" .. skill .. "):")
    ProfessionMaster.print_recipe(profession, profession.best_recipes[skill], nil, skill)
    ProfessionMaster.print("Recipe source: " .. ProfessionMaster.color_source(profession.best_recipes[skill]))
    ProfessionMaster.print("Average amount of crafts needed per skill up: " .. (1 / ProfessionMaster.get_skill_up_chance(profession.best_recipes[skill], skill)))
    ProfessionMaster.print("Required materials per craft:")

    for _,material in ipairs(profession.best_recipes[skill].materials) do
        ProfessionMaster.print_material(profession, material)
    end
end

ProfessionMaster.fetch_recipe_price = function(profession, recipe)
    local price = 0

    for _, material in ipairs(recipe.materials) do
        if PM.items[material.item_id] == nil then
            return 0
        else
            if not PM.items[material.item_id].found_best_source then
                local current_price = PM.items[material.item_id].price
                local best_recipe   = nil

                if profession.list.recipes[material.item_id] ~= nil then
                    for _, material_recipe in ipairs(profession.list.recipes[material.item_id]) do
                        local recipe_price = ProfessionMaster.fetch_recipe_product_price(profession, material_recipe)

                        if current_price == 0 or recipe_price < current_price then
                            best_recipe   = material_recipe
                            current_price = recipe_price
                        end
                    end
                end

                PM.items[material.item_id].found_best_source = true
                
                if best_recipe ~= nil then
                    PM.items[material.item_id].best_source = best_recipe
                    PM.items[material.item_id].price       = current_price
                end
            end

            price = price + (PM.items[material.item_id].price * material.amount)
        end
    end

    return price
end

ProfessionMaster.fetch_recipe_product_price = function(profession, recipe)
    local price_per_craft  = ProfessionMaster.fetch_recipe_price(profession, recipe)
    local average_products = (recipe.min_product + recipe.max_product) / 2

    return price_per_craft / average_products
end

ProfessionMaster.fetch_recipe_price_per_skill_up = function(profession, recipe, level)
    return ProfessionMaster.fetch_recipe_price(profession, recipe) / ProfessionMaster.get_skill_up_chance(recipe, level)
end

ProfessionMaster.get_best_recipe = function(profession, level)
    if profession == nil then
        return
    end

    -- todo: check which recipes will be needed for later steps and factor that into the choice!!!
    -- todo: add options (prioritize guaranteed skill ups, no recipes from world drops, no recipes from vendors, no recipes that aren't trained yet)

    local best_recipe       = nil
    local best_recipe_price = 0

    for _, v in pairs(profession.list.recipes) do
        for _, recipe in ipairs(v) do
            if recipe.levels[1] <= level and recipe.levels[3] > level then
                local average_price = ProfessionMaster.fetch_recipe_price_per_skill_up(profession, recipe, level)

                if best_recipe == nil or best_recipe_price == 0 or average_price < best_recipe_price then
                    best_recipe       = recipe
                    best_recipe_price = average_price
                end
            end
        end
    end


    if verbose then
        if best_recipe ~= nil then
            ProfessionMaster.print_recipe(profession, best_recipe, "Best recipe for level " .. level .. ":", level)
        else
            ProfessionMaster.print("|cFFFF0000No recipe found for level " .. level .. ".|r")
        end
    end

    return best_recipe
end

ProfessionMaster.init_frames = function(event)
    if event == "AUCTION_HOUSE_SHOW" then
        ProfessionMaster.init_auction_frames()
    elseif event == "TRADE_SKILL_SHOW" then
        ProfessionMaster.init_profession_frames()
    elseif event == "LEARNED_SPELL_IN_TAB" or event == "PLAYER_ENTERING_WORLD" then
        ProfessionMaster.generate_frame()
    end
end

ProfessionMaster.init_auction_frames = function()
    if ProfessionMaster.frame ~= nil then return end
    local tab_index = AuctionFrame.numTabs + 1

    local tab_button = CreateFrame(
        "Button",
        "AuctionFrameTab" .. tab_index,
        AuctionFrame,
        "AuctionTabTemplate"
    )

    tab_button:SetText("|cFFFF8000Profession Master|r")
    tab_button:SetPoint("LEFT", _G["AuctionFrameTab" .. (tab_index - 1)], "RIGHT", -15, 0)
    tab_button:SetID(tab_index)

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
    title:SetText("Profession Master")
    title:SetPoint("TOP", frame, "TOP")

    local scan_text = frame:CreateFontString(nil, nil, "GameFontNormal")
    scan_text:SetText("Scan best recipes for professions")
    scan_text:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -32)

    local scan_text = frame:CreateFontString(nil, nil, "GameFontNormal")
    scan_text:SetText("Fetch best recipe for professions at current level")
    scan_text:SetPoint("TOPLEFT", frame, "TOP", 0, -32)

    local i = 0

    for _, profession in pairs(ProfessionMaster.professions) do
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

        fetch_button:SetText(profession.name)
        fetch_button:SetPoint("TOPLEFT", frame, "TOP", 0, -48 - 28 * i)
        fetch_button:SetSize(128, 24)
        fetch_button:SetScript("OnClick", function()
            for index = 1, GetNumSkillLines() do
                local name, _, _, level = GetSkillLineInfo(index)
                if name == profession.name then
                    ProfessionMaster.print_best_recipe(profession, level)
                    return
                end
            end

            ProfessionMaster.print("You do not have this profession!")
        end)

        i = i + 1
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

ProfessionMaster.init_profession_frames = function()
    if not ProfessionMaster.profession_frame and TradeSkillFrame then
        local frame = CreateFrame("Frame", "ProfessionMasterProfessionFrame", TradeSkillFrame)

        local title = frame:CreateFontString(nil, nil, "GameFontNormal")
        title:SetText("Profession Master")
        title:SetPoint("TOP", frame, "TOP")

        ProfessionMaster.profession_frame = frame
    end
end

ProfessionMaster.get_item_professions = function(item_id)
    local professions, gathering_professions = { }, { }

    for _, profession in pairs(ProfessionMaster.professions) do
        if profession.list ~= nil and profession.list.items[item_id] ~= nil then
            table.insert(professions, profession)
        end
    end

    for _, profession in pairs(ProfessionMaster.gathering_professions) do
        if profession.list ~= nil then
            for _, node in pairs(profession.list.nodes) do
                if node.items[item_id] ~= nil then
                    table.insert(gathering_professions, profession)
                    break
                end
            end
        end
    end

    return professions, gathering_professions
end

ProfessionMaster.setup_tooltip = function(tooltip)
    local name, link = tooltip:GetItem()
	if not name then return end
	local item_id = select(1, GetItemInfoInstant(name))

    local professions, gathering_professions = ProfessionMaster.get_item_professions(item_id)

    if #professions > 0 or #gathering_professions > 0 then
        local str = ""

        for _, profession in ipairs(professions) do
            str = str .. profession.name .. ", "
        end

        for _, profession in ipairs(gathering_professions) do
            str = str .. profession.name .. ", "
        end

        str = str:sub(1, #str - 2)

        tooltip:AddDoubleLine("Profession Master:", str)
        tooltip:AddLine(" ")
        tooltip:AddLine("|cFFFFFFFFSources:")
        
        for _, profession in ipairs(professions) do
            -- todo
        end
        
        for _, profession in ipairs(gathering_professions) do
            for _, node in pairs(profession.list.nodes) do
                if node.items[item_id] ~= nil then
                    tooltip:AddLine("|cFFFFFFFF" .. node.name)
                end
            end
        end

        local best_source = "|cFFFF0000Unknown"
        local best_price = -1

        if PM.items[item_id] then
            if PM.items[item_id].found_best_source then
                if PM.items[item_id].best_source == "auction house" then
                    best_source = "Auction house"
                elseif PM.items[item_id].best_source == "vendor" then
                    best_soure = "Vendor"
                else
                    best_source = "|cFFFFFFFF" .. PM.items[item_id].best_source.name
                end
            end

            best_price = PM.items[item_id].price
        end

        tooltip:AddLine(" ")

        if best_price ~= -1 then tooltip:AddDoubleLine("|cFFFFFFFFBest price:", ProfessionMaster.format_price(best_price)) end
        tooltip:AddDoubleLine("|cFFFFFFFFBest source:", best_source)

        tooltip:AddLine(" ")
    end
end

ProfessionMaster.slash_command = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
end

ProfessionMaster.join_channel = function()
    JoinChannelByName("PMGatheringRoutesData")
    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.print("Failed to join gathering routes data channel")
    end
end

ProfessionMaster.set_background = function(frame, rounded_tr, rounded_br, rounded_bl, rounded_tl)
    local str = function(rounded)
        if rounded then return "Rounded" end
        return ""
    end

    frame.frames = {
        { f = CreateFrame("Frame", nil, frame), a = "TOPRIGHT",    w = function() return                     8 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameTopRight"    .. str(rounded_tr) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOMRIGHT", w = function() return                     8 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameBottomRight" .. str(rounded_br) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOMLEFT",  w = function() return                     8 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameBottomLeft"  .. str(rounded_bl) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "TOPLEFT",     w = function() return                     8 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameTopLeft"     .. str(rounded_tl) .. ".blp" },
        { f = CreateFrame("Frame", nil, frame), a = "TOP",         w = function() return frame:GetWidth() - 16 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameTop.blp"                                  },
        { f = CreateFrame("Frame", nil, frame), a = "RIGHT",       w = function() return                     8 end, h = function() return frame:GetHeight() - 16 end, t = "Interface/Addons/ProfessionMaster/media/FrameRight.blp"                                },
        { f = CreateFrame("Frame", nil, frame), a = "BOTTOM",      w = function() return frame:GetWidth() - 16 end, h = function() return                      8 end, t = "Interface/Addons/ProfessionMaster/media/FrameBottom.blp"                               },
        { f = CreateFrame("Frame", nil, frame), a = "LEFT",        w = function() return                     8 end, h = function() return frame:GetHeight() - 16 end, t = "Interface/Addons/ProfessionMaster/media/FrameLeft.blp"                                 },
        { f = CreateFrame("Frame", nil, frame), a = "CENTER",      w = function() return frame:GetWidth() - 16 end, h = function() return frame:GetHeight() - 16 end, t = "Interface/Addons/ProfessionMaster/media/FrameCenter.blp"                               }
    }

    for _, data in ipairs(frame.frames) do
        data.f:SetSize(data.w(), data.h())
        data.f:SetPoint(data.a)
        data.f:SetDepth(0)
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

ProfessionMaster.generate_frame = function()
    local frame = ProfessionMaster.main_frame or (function()
        local f = CreateFrame("Frame", "PMFrame", UIParent)
        ProfessionMaster.set_background(f, false, true, true, false)
        return f
    end)()

    frame:SetWidth(280)
    frame:SetHeight(72)
    frame:RegisterForDrag("LeftButton")
    frame:SetPoint("BOTTOMRIGHT", -16, 90)
    frame:SetClampedToScreen(true)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
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
    title:SetText("Profession Master")
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

    for index = 1, GetNumSkillLines() do
        local name, _, _, level = GetSkillLineInfo(index)
        if ProfessionMaster.professions[name:gsub("%s+", ""):lower()] ~= nil or ProfessionMaster.gathering_professions[name:gsub("%s+", ""):lower()] ~= nil then
            local profession = ProfessionMaster.professions[name:gsub("%s+", ""):lower()] or ProfessionMaster.gathering_professions[name:gsub("%s+", ""):lower()]

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
                    profession_frame:SetHeight(24)

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

                    if not profession.list then
                        profession_frame:SetHeight(44)

                        -- todo: Free content

                        profession_frame.title = profession_frame:CreateFontString(nil, nil, "GameFontNormal")
                        profession_frame.title:SetJustifyH("CENTER")
                        profession_frame.title:SetText("|cFFFF0000You do not own a guide for this profession!")
                        profession_frame.title:SetPoint("BOTTOM", 0, 8)
                    else
                        if profession.name == "Mining" then -- temporary, should be all gathering later
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

                            profession_frame.ore_selector = CreateFrame("Frame", nil, profession_frame, "UIDropDownMenuTemplate")
                            profession_frame.ore_selector:SetPoint("TOPLEFT", -8, -22)
                            UIDropDownMenu_SetWidth(profession_frame.ore_selector, 112)
                            UIDropDownMenu_Initialize(profession_frame.ore_selector, function(self, level, menu_list)
                                local info = UIDropDownMenu_CreateInfo()

                                for vein_id, node in pairs(profession.list.nodes) do
                                    info.text, info.arg1, info.arg2, info.func, info.checked = node.name, vein_id, node.name, self.set_value, vein_id == profession_frame.selected_vein
                                    UIDropDownMenu_AddButton(info)
                                end
                            end)

                            function profession_frame.ore_selector:set_value(vein_id, name)
                                profession_frame.selected_vein = vein_id
                                profession_frame.selected_area = 0

                                UIDropDownMenu_SetText(profession_frame.ore_selector, name)
                                CloseDropDownMenus()
                                
                                profession_frame:SetHeight(64 + profession_frame.sub_frame:GetHeight())
                                profession_frame.area_selector:Show()
                                profession_frame.sub_frame:Show()

                                UIDropDownMenu_Initialize(profession_frame.area_selector, function(self, level, menu_list)
                                    local info = UIDropDownMenu_CreateInfo()
    
                                    info.text, info.arg1, info.arg2, info.func, info.checked = "Any zone", 0, "Any zone", self.set_value, 0 == profession_frame.selected_area
                                    UIDropDownMenu_AddButton(info)

                                    -- todo: sort by level
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

                                        for route_id, _ in ipairs(routes[menu_list]) do
                                            info.text, info.arg1, info.arg2, info.func, info.checked = route_id, route_id, menu_list, self.set_value, ProfessionMaster.current_area == menu_list and ProfessionMaster.current_route == route_id
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
                                profession_frame:SetHeight(56)

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
                    end

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

            alignment = "TOPRIGHT"
            xoff = -8

            buttons[index] = button
        end
    end

    frame.buttons = buttons
    
    frame:Show()

    ProfessionMaster.main_frame = frame

    local step_frame = ProfessionMaster.step_frame or CreateFrame("Frame", "PMStepFrame", UIParent)

    step_frame:SetWidth(48)
    step_frame:SetHeight(48)
    step_frame:RegisterForDrag("LeftButton")
    step_frame:SetPoint("TOP", 0, -16)
    step_frame:SetClampedToScreen(true)

    step_frame:SetMovable(true)
    step_frame:EnableMouse(true)
    step_frame:RegisterForDrag("LeftButton")

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
        text = "Profession Master",
        icon = "Interface/Addons/ProfessionMaster/media/ProfessionMaster.blp",
        OnClick = function(self, btn)
            ProfessionMaster.toggle()
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("Toggle Profession Master frame")
        end,
    })

    local icon = LibStub("LibDBIcon-1.0", true)
    icon:Register("ProfessionMaster", minimap_button, PM)
end

ProfessionMaster.init = function()
    local helper = CreateFrame("Frame", nil, UIParent)
    helper:SetScript("OnEvent", ProfessionMaster.init_frames)
    helper:RegisterEvent("AUCTION_HOUSE_SHOW")
    helper:RegisterEvent("TRADE_SKILL_SHOW")
    helper:RegisterEvent("LEARNED_SPELL_IN_TAB")
    helper:RegisterEvent("PLAYER_ENTERING_WORLD")

    local queuehelper = CreateFrame("Frame", "QueueHelper", UIParent)
    queuehelper:SetScript("OnUpdate", function()
        if not ProfessionMaster.main_frame then
            ProfessionMaster.generate_frame()
        end

        ProfessionMaster.ah_source = false
        ProfessionMaster.dequeue()

        ProfessionMaster.update_step_frame()
    end)
    queuehelper:SetScript("OnKeyDown", function()
        ProfessionMaster.ah_source = false
        ProfessionMaster.dequeue(true)
    end)
    queuehelper:SetPropagateKeyboardInput(true)
    
    GameTooltip:HookScript("OnTooltipSetItem", ProfessionMaster.setup_tooltip)

    SLASH_PROFESSIONMASTER1, SLASH_PROFESSIONMASTER2 = "/pm", "/professionmaster"
    SlashCmdList["PROFESSIONMASTER"] = ProfessionMaster.slash_command

    local chat_helper = CreateFrame("Frame", nil, UIParent)
    chat_helper:SetScript("OnEvent", ProfessionMaster.chat_handler)
    chat_helper:RegisterEvent("CHAT_MSG_CHANNEL")
end

local hex_digits = {
    [0x0] = '0', [0x1] = '1', [0x2] = '2', [0x3] = '3',
    [0x4] = '4', [0x5] = '5', [0x6] = '6', [0x7] = '7',
    [0x8] = '8', [0x9] = '9', [0xa] = 'a', [0xb] = 'b',
    [0xc] = 'c', [0xd] = 'd', [0xe] = 'e', [0xf] = 'f'
}

function from_hex(hex)
    for num, val in pairs(hex_digits) do
        if val == hex then
            return num
        end
    end

    return nil
end

ProfessionMaster.encode = function(op, args)
    if op == nil or op.id == nil or op.size == nil then
        ProfessionMaster.print_verbose("|cFFFF0000Encoding error: invalid operation")
        return ""
    end

    if #op.size ~= #args then
        ProfessionMaster.print_verbose("|cFFFF0000Encoding error: invalid argument count for operation " .. op.id)
        return ""
    end

    local buffer = { bit.band(op.id, 0x0F), bit.band(bit.rshift(op.id, 4), 0x0F) }

    for i, arg in ipairs(args) do
        for j = 0, (op.size[i] * 2) - 1 do
            table.insert(buffer, bit.band(bit.rshift(arg, j * 4), 0x0F))
        end
    end

    local str = ""

    for i, val in ipairs(buffer) do
        str = str .. hex_digits[val]
    end

    return str
end

ProfessionMaster.decode = function(str)
    if #str < 2 then
        ProfessionMaster.print_verbose("|cFFFF0000Decoding error: invalid operation")
        return nil, nil
    end

    local op = ProfessionMaster.operation_lookup(bit.bor(from_hex(str:sub(1, 1)), bit.lshift(from_hex(str:sub(2, 2)), 0x0F)))
    
    if op == nil then
        ProfessionMaster.print_verbose("|cFFFF0000Decoding error: invalid operation")
        return nil, nil
    end
    
    local reqsize = 0
    for _, size in ipairs(op.size) do
        reqsize = reqsize + size
    end

    if (str:len() - 2) / 2 ~= reqsize then
        ProfessionMaster.print_verbose("|cFFFF0000Decoding error: invalid size for operation " .. op.id)
        return nil, nil
    end

    local pos = 3
    local args = {}

    for _, size in ipairs(op.size) do
        local arg = 0

        for i = pos, pos + (size * 2) - 1 do
            arg = bit.bor(arg, bit.lshift(from_hex(str:sub(i, i)), ((i - pos) * 4)))
        end

        pos = pos + (size * 2)

        table.insert(args, arg)
    end

    return op, args
end

ProfessionMaster.operation_lookup = function(id)
    for _, data in pairs(ProfessionMaster.operations) do
        if data.id == id then
            return data
        end
    end

    return nil
end

ProfessionMaster.request_route_usage = function(vein_id, zone_id)
    if not zone_id then zone_id = 0 end

    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.join_channel()
    end

    ProfessionMaster.print("Requesting best farming route... Please press any keyboard button to send the request.")

    ProfessionMaster.enqueue({
        condition = function() return true end,
        execute = function()
            ProfessionMaster.print("Request sent! Please wait a few seconds while we fetch all the latest data.")

            ProfessionMaster.requested_routes_time = GetServerTime()
            ProfessionMaster.requested_vein_id = vein_id
            ProfessionMaster.requested_zone_id = zone_id
            ProfessionMaster.best_route = nil
            ProfessionMaster.best_area = nil
            ProfessionMaster.requested_routes = { }

            for _, profession in pairs(ProfessionMaster.gathering_professions) do
                if profession.list and profession.list.nodes[vein_id] then
                    if zone_id == 0 then
                        for cur_zone_id, _ in pairs(profession.list.nodes[vein_id].routes) do
                            if ProfessionMaster.requested_routes[cur_zone_id] == nil then
                                ProfessionMaster.requested_routes[cur_zone_id] = { }
                            end

                            for cur_route_id, _ in ipairs(profession.list.nodes[vein_id].routes[cur_zone_id]) do
                                if ProfessionMaster.requested_routes[cur_zone_id][cur_route_id] == nil then
                                    ProfessionMaster.requested_routes[cur_zone_id][cur_route_id] = { users = 0, ores = 0 }
                                end
                            end
                        end
                    elseif profession.list.nodes[vein_id].routes[zone_id] then
                        if ProfessionMaster.requested_routes[zone_id] == nil then
                            ProfessionMaster.requested_routes[zone_id] = { }
                        end

                        for cur_route_id, _ in ipairs(profession.list.nodes[vein_id].routes[zone_id]) do
                            if ProfessionMaster.requested_routes[zone_id][cur_route_id] == nil then
                                ProfessionMaster.requested_routes[zone_id][cur_route_id] = { users = 0, ores = 0 }
                            end
                        end
                    end
                end
            end

            SendChatMessage(
                ProfessionMaster.encode(ProfessionMaster.operations["request"], { vein_id, zone_id, GetServerTime() }),
                "CHANNEL",
                nil,
                GetChannelName("PMGatheringRoutesData")
            )

            ProfessionMaster.enqueue({
                condition = function()
                    local server_time = GetServerTime()

                    return not ProfessionMaster.acceptable_time_difference(
                        ProfessionMaster.requested_routes_time,
                        server_time
                    )
                end,
                execute = function()
                    local best_area = nil
                    local best_route = -1
                    local best_users = -1
                    local route_ores = -1

                    for zone, data in pairs(ProfessionMaster.requested_routes) do
                        for route, route_data in pairs(data) do
                            if route_ores == -1 or ((route_data.users == 0 or route_ores < route_data.ores / route_data.users) and best_users > 0) then
                                best_area = zone
                                best_route = route
                                best_users = route_data.users
                                route_ores = route_data.ores / route_data.users
                            end
                        end
                    end

                    if route_users == -1 then route_users = 0 end

                    if best_route == -1 then
                        ProfessionMaster.print_verbose("No routes currently used! Pick any of the available routes")
                        return
                    end

                    if best_users == 0 then
                        ProfessionMaster.print_verbose("Best route: " .. C_Map.GetMapInfo(best_area).name .. " (" .. best_route .. "): currently empty!")
                    else
                        ProfessionMaster.print_verbose("Best route: " .. C_Map.GetMapInfo(best_area).name .. " (" .. best_route .. "): average ores: " .. route_ores .. "/5 mins - players: " .. best_users)
                    end

                    for key, profession in pairs(ProfessionMaster.gathering_professions) do
                        if profession.list and profession.list.nodes[vein_id] then
                            if ProfessionMaster.main_frame.profession_frames[profession.name].sub_frame.optimal_route then
                                ProfessionMaster.main_frame.profession_frames[profession.name].sub_frame.optimal_route:Enable()
                            end
                        end
                    end

                    ProfessionMaster.best_route = best_route
                    ProfessionMaster.best_area = best_area

                    ProfessionMaster.requested_routes_time = nil
                end,
                allow_skipping = true
            })
        end,
        requires_hw_input = true
    })
end

ProfessionMaster.process_route_request = function(args)
    if ProfessionMaster.current_step == 0 then return end
    if args[2] ~= 0 and args[2] ~= ProfessionMaster.current_area then return end

    local server_time = GetServerTime()

    if ProfessionMaster.current_vein == args[1] and ProfessionMaster.acceptable_time_difference(
        server_time,
        args[3]
    ) then
        ProfessionMaster.enqueue({
            condition = function() return true end,
            execute = function()
                SendChatMessage(
                    ProfessionMaster.encode(ProfessionMaster.operations["route"], {
                        args[1],
                        C_Map.GetBestMapForUnit("Player"),
                        ProfessionMaster.current_route,
                        GetServerTime(),
                        (GetItemCount(ProfessionMaster.current_profession.list.nodes[ProfessionMaster.current_vein].main_item) - ProfessionMaster.starting_ores) * 300 / (GetServerTime() - ProfessionMaster.en_route_since)
                    }),
                    "CHANNEL",
                    nil,
                    GetChannelName("PMGatheringRoutesData")
                )
            end,
            requires_hw_input = true
        }, true)
    end
end

ProfessionMaster.process_route_reply = function(args)
    if ProfessionMaster.requested_routes_time == nil then return end
    
    if ProfessionMaster.current_vein == args[1] and ProfessionMaster.acceptable_time_difference(
        args[4],
        ProfessionMaster.requested_routes_time
    ) then
        if ProfessionMaster.requested_routes[args[2]] == nil then
            ProfessionMaster.requested_routes[args[2]] = { }
        end

        if ProfessionMaster.requested_routes[args[2]][args[3]] == nil then
            ProfessionMaster.requested_routes[args[2]][args[3]] = { users = 1, ores = args[5] }
        else
            ProfessionMaster.requested_routes[args[2]][args[3]].users = ProfessionMaster.requested_routes[args[2]][args[3]].users + 1
            ProfessionMaster.requested_routes[args[2]][args[3]].ores = ProfessionMaster.requested_routes[args[2]][args[3]].ores + args[5]
        end
    end
end

ProfessionMaster.acceptable_time_difference = function(t1, t2)
    local diff = t2 - t1
    return diff > -ProfessionMaster.acceptable_time and diff < ProfessionMaster.acceptable_time
end

ProfessionMaster.process_ah_price = function(args)
    if PM.items[args[1]] == nil then
        PM.items[args[1]] = {
            item              = nil, -- todo
            found_best_source = true, -- for now
            best_source       = "auction house",
            vendor_price      = args[3],
            auction_price     = args[2],
            price             = args[2]
        }
    else
        PM.items[args[1]].auction_price = args[2]
        PM.items[args[1]].price = args[2] -- todo: hmmmm will be wrong often, so reset the best source!
        PM.items[args[1]].best_source = "auction house"
        PM.items[args[1]].found_best_source = true -- for now
    end
end

ProfessionMaster.operations = {
    request  = { id = 0, handler = ProfessionMaster.process_route_request, size = { 4, 4, 4       } },
    route    = { id = 1, handler = ProfessionMaster.process_route_reply,   size = { 4, 4, 1, 4, 4 } },
    ah_price = { id = 2, handler = ProfessionMaster.process_ah_price,      size = { 4, 4, 4       } },
    source   = { id = 3, handler = function() return end,                  size = {               } }  -- todo
}

ProfessionMaster.chat_handler = function(...)
    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.join_channel()
        return
    end

    local _args = { ... }
    local _, channel_name = string.split(" ", _args[6])
    
    if channel_name ~= "PMGatheringRoutesData" --[[ or _args[4]:gsub("-.+", "") == UnitName("Player") ]] then return end

    local op, args = ProfessionMaster.decode(_args[3])

    if op == nil or args == nil then
        return
    end

    op.handler(args)
end

ProfessionMaster.gathering_step = function()
    if ProfessionMaster.current_profession == nil then
        return "No route selected"
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local x, y = C_Map.GetPlayerMapPosition(zone_id, "player"):GetXY()

    x = floor(x * 1000) / 10
    y = floor(y * 1000) / 10

    if zone_id ~= ProfessionMaster.current_area then
        ProfessionMaster.en_route_since = GetServerTime()

        local player_instance = C_Map.GetWorldPosFromMapPos(zone_id, { x = x, y = y })
        local target_instance = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = 50, y = 50 })
    
        if player_instance ~= target_instance then
            return "Travel to " .. GetRealZoneText(target_instance)
        end

        return "Travel to " .. C_Map.GetMapInfo(ProfessionMaster.current_area).name
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    if ProfessionMaster.current_step < 1 then
        local best_step = 0
        local best_distance = 0

        for id, values in ipairs(route.route) do
            ProfessionMaster.current_step = id
            local distance = ProfessionMaster.get_step_distance_number()

            if best_step == 0 or distance < best_distance then
                best_step = id
                best_distance = distance
            end
        end

        ProfessionMaster.current_step = best_step
    end

    if ProfessionMaster.current_step > #route.route then
        ProfessionMaster.current_step = 1
    end

    local materials = "materials"

    if ProfessionMaster.current_profession.name == ProfessionMaster.gathering_professions.mining.name then
        materials = "ores"
    elseif ProfessionMaster.current_profession.name == ProfessionMaster.gathering_professions.herbalism.name then
        materials = "herbs"
    end

    local distance = ProfessionMaster.get_step_distance_number()

    local step = route.route[ProfessionMaster.current_step]

    local cur_level = 1

    for index = 1, GetNumSkillLines() do
        local name, _, _, level = GetSkillLineInfo(index)
        if name == profession.name then
            cur_level = level
            break
        end
    end

    -- todo: skip walking steps if last step was for wrong vein_id anyway
    if (distance and distance < 10) or (step.vein_id ~= ProfessionMaster.current_vein and not ProfessionMaster.current_other_nodes) or step.min_level > cur_level then
        ProfessionMaster.current_step = ProfessionMaster.current_step + 1

        if ProfessionMaster.current_step > #route.route then
            ProfessionMaster.current_step = 1
        end
    end
    
    local is_cave = route.route[ProfessionMaster.current_step].cave
    local is_node = route.route[ProfessionMaster.current_step].node

    local msg = "Travel here"

    if is_node then
        msg = "Check for " .. materials
    end
    
    if is_cave then
        msg = "Explore cave for " .. materials
    end

    if route.route[ProfessionMaster.current_step].msg then
        msg = route.route[ProfessionMaster.current_step].msg
    end

    return "Step " .. ProfessionMaster.current_step .. ": " .. msg
end

ProfessionMaster.correct_instance = function()
    if ProfessionMaster.current_profession == nil then
        return
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")

    local player_instance = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))
    local target_instance = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = 50, y = 50 })

    if player_instance ~= target_instance then
        return
    end

    return true
end

ProfessionMaster.get_step_distance_number = function()
    if ProfessionMaster.current_profession == nil then
        return nil
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    local step = ProfessionMaster.current_step

    if ProfessionMaster.current_step < 1 or ProfessionMaster.current_step > #route.route then
        step = 1
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local instance_id, pos = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))

    local step_x, step_y = route.route[step].x, route.route[step].y

    local step_instance_id, step_pos = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = step_x / 100, y = step_y / 100 })

    local dx = pos.x - step_pos.x
    local dy = pos.y - step_pos.y

    local distance = floor(sqrt(dy * dy + dx * dx))
    
    return distance
end

ProfessionMaster.get_step_distance = function()
    return ProfessionMaster.get_step_distance_number() .. " yards"
end

ProfessionMaster.get_step_direction = function()
    if ProfessionMaster.current_profession == nil then
        return nil
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    local step = ProfessionMaster.current_step

    if ProfessionMaster.current_step < 1 or ProfessionMaster.current_step > #route.route then
        step = 1
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local instance_id, pos = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))

    local step_x, step_y = route.route[step].x, route.route[step].y

    local step_instance_id, step_pos = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = step_x / 100, y = step_y / 100 })

    local dx = step_pos.x - pos.x
    local dy = step_pos.y - pos.y

    if dx == 0 then return 0 end

    local angle = GetPlayerFacing() - atan(dy / dx) * math.pi / 180

    if dx < 0 then return angle - math.pi end

    return angle
end

ProfessionMaster.update_step_frame = function()
    if ProfessionMaster.current_profession == nil then
        ProfessionMaster.step_frame:Hide()
        return
    end

    local msg = ProfessionMaster.gathering_step()
    local angle = ProfessionMaster.get_step_direction() * 180 / math.pi

    ProfessionMaster.step_frame:Show()

    if ProfessionMaster.correct_instance() then
        ProfessionMaster.step_frame.inner_frame:Show()
        ProfessionMaster.step_frame.inner_frame:SetPoint("CENTER", sin(angle) * 14, cos(angle) * 14)
        ProfessionMaster.step_frame.text:SetText("|cFFFFFFFF" .. msg .. "\n" .. ProfessionMaster.get_step_distance())
    else
        ProfessionMaster.step_frame.inner_frame:Hide()
        ProfessionMaster.step_frame.text:SetText("|cFFFFFFFF" .. msg)
    end
end

ProfessionMaster.start_route = function(profession_name, vein, zone, route, current_other_nodes)
    ProfessionMaster.current_profession = ProfessionMaster.gathering_professions[profession_name]
    ProfessionMaster.current_vein = vein
    ProfessionMaster.current_area = zone
    ProfessionMaster.current_route = route
    ProfessionMaster.current_step = 0
    ProfessionMaster.current_other_nodes = current_other_nodes
    ProfessionMaster.en_route_since = GetServerTime()
    ProfessionMaster.starting_ores = GetItemCount(ProfessionMaster.current_profession.list.nodes[ProfessionMaster.current_vein].main_item)
end

ProfessionMaster.stop_route = function()
    ProfessionMaster.current_profession = nil
    ProfessionMaster.current_vein = nil
    ProfessionMaster.current_area = nil
    ProfessionMaster.current_route = nil
    ProfessionMaster.current_step = 0
    ProfessionMaster.current_other_nodes = false
    ProfessionMaster.en_route_since = nil
    ProfessionMaster.starting_ores = nil
end

PMCustomRoutes = PMCustomRoutes or { }

ProfessionMaster.new_route = nil

ProfessionMaster.start_creating_route = function(profession_name, vein, zone, route_id)
    ProfessionMaster.new_route = {
        profession = profession_name,
        vein = vein,
        zone = zone,
        id = route_id,
        steps = { },
        nodes = 0
    }
end

ProfessionMaster.add_step = function(node, cave, msg)
    if ProfessionMaster.new_route then
        local zone_id = C_Map.GetBestMapForUnit("Player")
        local pos = C_Map.GetPlayerMapPosition(zone_id, "player")
    
        table.insert(ProfessionMaster.new_route.steps, {
            x = pos.x,
            y = pos.y,
            node = node,
            cave = cave,
            msg = msg
        })
    end
end

ProfessionMaster.stop_creating_route = function()
    if ProfessionMaster.new_route then
        table.insert(PMCustomRoutes, ProfessionMaster.new_route)
        ProfessionMaster.new_route = nil
    end
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

ProfessionMaster.init()
