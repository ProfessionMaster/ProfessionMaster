--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.get_selected_item_id = function()
    return tonumber(GetTradeSkillItemLink(GetTradeSkillSelectionIndex()):match("item:(%d+)")) or tonumber(GetTradeSkillRecipeLink(GetTradeSkillSelectionIndex()):match("enchant:(%d+)"))
end

ProfessionMaster.init_profession_frames = function()
    if not ProfessionMaster.profession_frame and TradeSkillFrame then
        local frame = ProfessionMaster.UILib.CreateFrame("Frame", "ProfessionMasterProfessionFrame", TradeSkillFrame, "ButtonFrameTemplate", 70, 16, 16, 16)

        frame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 0, -13)
        frame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 0, 72)
        frame:SetWidth(320)

        frame.title = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.title:SetText("|cFFFFFFFFProfessionMaster")
        frame.title:SetPoint("TOP", frame, "TOP", 16, -6)

        frame.corner = CreateFrame("Frame", nil, frame)
        frame.corner:SetPoint("TOPLEFT", -6, 7)
        frame.corner:SetSize(60, 60)
        frame.corner.tex = frame.corner:CreateTexture()
        frame.corner.tex:SetAllPoints(frame.corner)

        frame.profession_title = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.profession_title:SetText("")
        frame.profession_title:SetPoint("TOP", frame, "TOP", 16, -28)

        frame.profession_level = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.profession_level:SetText("")
        frame.profession_level:SetPoint("TOP", frame, "TOP", 16, -44)

        frame.best_recipe = frame:AddText("", 1, 0)
        frame.best_recipe_price_per_craft = frame:AddText("", 1, 0)
        frame.best_recipe_crafts_per_level = frame:AddText("", 1, 0)
        frame.best_recipe_fetched_at = frame:AddText("", 1, 0)

        frame.reagents = frame:AddText("Reagents:", 4, 0, 1)
        frame.reagents_list = frame:AddFrame("Frame", nil, nil, 1, 0)

        ProfessionMaster.profession_frame = frame

        ProfessionMaster.update_profession_frames()
    end
end

ProfessionMaster.get_fetch_timestamp = function(recipe)
    if not recipe then return nil end

    local fetch_time = nil

    for _, material in ipairs(recipe.materials) do
        if not PM.items[material.item_id] or not PM.items[material.item_id].auction_fetch_at then
            return nil
        else
            if not fetch_time or PM.items[material.item_id].auction_fetch_at < fetch_time then
                fetch_time = PM.items[material.item_id].auction_fetch_at
            end
        end
    end

    return fetch_time
end

ProfessionMaster.format_timestamp = function(timestamp)
    if not timestamp then return "|cFFFF0000never" end
    
    local timediff = time() - timestamp

    if timediff < 0 then return "|cFFFF0000never" end

    if timediff < 86400 then
        local hours = math.floor(timediff / 3600)
        local minutes = math.floor((timediff - hours * 3600) / 60)

        if timediff < 60 then
            return "|cFF00FF00< 1min ago"
        end

        if timediff < 3600 then
            return "|cFF00FF00" .. minutes .. "min ago"
        end

        if timediff < 7200 then
            return "|cFF00FF001h " .. minutes .. "min ago"
        end

        if timediff < 43200 then
            return "|cFFFFFF00" .. hours .. "h " .. minutes .. "min ago"
        end

        return "|cFFFF8000" .. hours .. "h " .. minutes .. "min ago"
    end

    return "|cFFFF0000> 24h ago (AH scan reccomended!)"
end

-- todo: consider every profession learned by this character
ProfessionMaster.list_reagents = function(recipe)
    if not recipe then return { } end

    local reagents = { }

    for _, material in ipairs(recipe.materials) do
        local _, link = GetItemInfo(material.item_id)
        reagent = material.amount .. "x " .. (link or PM.items[material.item_id].name or "|cFFFF0000unknown") .. " |r|cFFFFFFFF- "

        local count = GetItemCount(material.item_id, true)
        local craftable = ProfessionMaster.get_number_of_possible_crafts(material.item_id)
        if count < material.amount then
            if count + craftable < material.amount then
                count = "|r|cFFFF0000" .. count .. "|r|cFFFFFFFF (can make: |r|cFFFF0000" .. craftable .. "|r|cFFFFFFFF)"
            else
                count = "|r|cFFFF0000" .. count .. "|r|cFFFFFFFF (can make: |r|cFF00FF00" .. craftable .. "|r|cFFFFFFFF)"
            end
        end

        reagent = reagent .. "have: |r|cFF00FF00" .. count .. "|r"

        table.insert(reagents, reagent)
    end

    return reagents
end

ProfessionMaster.update_profession_frames = function()
    ProfessionMaster.enqueue({
        condition = function() return ProfessionMaster.professions[GetTradeSkillLine():gsub('%s+', ''):lower()] ~= nil end,
        execute = ProfessionMaster.update_profession_frames,
        allow_skipping = true,
        forbid_same_tick = true
    }, true)

    if not ProfessionMaster.profession_frame or not TradeSkillFrame then return end

    local profession_name, current_level, max_level = GetTradeSkillLine()
    local profession = ProfessionMaster.professions[profession_name:gsub('%s+', ''):lower()] -- todo: localization

    if not profession then return end

    local best_recipe = ProfessionMaster.get_best_recipe(profession, current_level)

    local frame = ProfessionMaster.profession_frame

    if frame.profession ~= profession then
        SetPortraitToTexture(frame.corner.tex, profession.icon)
        frame.profession = profession
    end

    frame:Show()

    frame.profession_title:SetText(profession_name)
    frame.profession_level:SetText("|cFFFFFFFF" .. ProfessionMaster.check_for_levelups(profession))
    
    frame.best_recipe:UpdateText("|cFFFFFFFFBest recipe for this level: |r" .. (best_recipe and GetSpellLink(best_recipe.spell_id) or "|cFFFF0000unknown |cFFFFFFFF(scan auction house!)"))
    frame.best_recipe_price_per_craft:UpdateText("|cFFFFFFFFPrice per craft: " .. (best_recipe and ProfessionMaster.format_price(ProfessionMaster.fetch_recipe_price(best_recipe)) or "|cFFFF0000unknown"))
    frame.best_recipe_crafts_per_level:UpdateText("|cFFFFFFFFAverage crafts per level up: " .. (best_recipe and ProfessionMaster.get_skill_up_chance(profession, best_recipe, current_level) or "|cFFFF0000unknown"))
    frame.best_recipe_fetched_at:UpdateText("|cFFFFFFFFLast updated: " .. ProfessionMaster.format_timestamp(ProfessionMaster.get_fetch_timestamp(best_recipe)))

    frame.reagents_list:DeleteAllText()
    for _, reagent in ipairs(ProfessionMaster.list_reagents(best_recipe)) do
        frame.reagents_list:AddText(reagent, 1, 0)
    end
end

ProfessionMaster.trade_skill_frames_initializer = function()
    ProfessionMaster.enqueue({
        condition = function() return TradeSkillFrame ~= nil end,
        execute = ProfessionMaster.init_profession_frames,
        allow_skipping = true
    }, true)
end
