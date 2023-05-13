--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = { }

if PM == nil then PM = { } end

PM.professions = {
    jewelcrafting = {
        list = _G["JC"],
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

if PM.items == nil then PM.items = { } end

ProfessionMaster.queue = { }

ProfessionMaster.print = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8000Profession Master|r: " .. msg)
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
    return CanSendAuctionQuery()
end

ProfessionMaster.dequeue = function()
    if #ProfessionMaster.queue == 0 then return end

    local index, query = pairs(ProfessionMaster.queue)(ProfessionMaster.queue)

    if query.condition() then
        query.execute()
        table.remove(ProfessionMaster.queue, index)
        ProfessionMaster.dequeue()
    end
end

ProfessionMaster.enqueue = function(query)
    table.insert(ProfessionMaster.queue, query)

    if #ProfessionMaster.queue == 1 then
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
    -- todo: add options (prioritize guaranteed skill ups, no recipes from world drops, no recipes from vendors)

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

    -- debug
    if best_recipe ~= nil then
        ProfessionMaster.print_recipe(profession, best_recipe, "Best recipe for level " .. level .. ":", level)
    else
        ProfessionMaster.print("|cFFFF0000No recipe found for level " .. level .. ".|r")
    end

    return best_recipe
end

ProfessionMaster.init_frames = function()
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
    frame:SetScript("OnEvent", ProfessionMaster.dequeue)
    frame:Hide()

    local title = frame:CreateFontString(nil, nil, "GameFontNormal")
    title:SetText("Profession Master")
    title:SetPoint("TOP", frame, "TOP")

    local scan_text = frame:CreateFontString(nil, nil, "GameFontNormal")
    scan_text:SetText("Scan best recipes for professions")
    scan_text:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -32)

    local i = 0

    for _, profession in pairs(PM.professions) do
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

ProfessionMaster.setup_tooltip = function(tooltip)
    local name, link = tooltip:GetItem()
	if not name then return end
	local item_id = select(1, GetItemInfoInstant(name))

    -- tooltip:AddLine("Test")
end

ProfessionMaster.slash_command = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
end

SLASH_PROFESSIONMASTER1, SLASH_PROFESSIONMASTER2 = "/pm", "/professionmaster"

SlashCmdList["PROFESSIONMASTER"] = ProfessionMaster.slash_command;

local helper = CreateFrame("Frame", nil, UIParent)
helper:SetScript("OnEvent", ProfessionMaster.init_frames)
helper:RegisterEvent("AUCTION_HOUSE_SHOW")

GameTooltip:HookScript("OnTooltipSetItem", ProfessionMaster.setup_tooltip)
