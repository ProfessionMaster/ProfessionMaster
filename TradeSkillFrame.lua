--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.get_selected_item_id = function()
    return tonumber(GetTradeSkillItemLink(GetTradeSkillSelectionIndex()):match("item:(%d+)")) or tonumber(GetTradeSkillRecipeLink(GetTradeSkillSelectionIndex()):match("enchant:(%d+)"))
end

ProfessionMaster.init_profession_frames = function()
    if not ProfessionMaster.profession_frame and TradeSkillFrame then
        local frame = CreateFrame("Frame", "ProfessionMasterProfessionFrame", TradeSkillFrame, "ButtonFrameTemplate")

        frame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 0, -13)
        frame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 0, 72)
        frame:SetWidth(320)

        frame.title = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.title:SetText("|cFFFFFFFFProfession Master")
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

        frame.best_recipe = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.best_recipe:SetText("")
        frame.best_recipe:SetJustifyH("LEFT")
        frame.best_recipe:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -70)

        frame.best_recipe_price_per_craft = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.best_recipe_price_per_craft:SetText("")
        frame.best_recipe_price_per_craft:SetJustifyH("LEFT")
        frame.best_recipe_price_per_craft:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -84)

        frame.best_recipe_price_per_skill_up = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.best_recipe_price_per_skill_up:SetText("")
        frame.best_recipe_price_per_skill_up:SetJustifyH("LEFT")
        frame.best_recipe_price_per_skill_up:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -98)

        frame.best_recipe_fetched_at = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.best_recipe_fetched_at:SetText("")
        frame.best_recipe_fetched_at:SetJustifyH("LEFT")
        frame.best_recipe_fetched_at:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -112)

        frame.reagents = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.reagents:SetText("Best reagent sources:")
        frame.reagents:SetPoint("TOP", frame, "TOP", 0, -128)

        frame.reagents_list = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.reagents_list:SetText("")
        frame.reagents_list:SetJustifyH("LEFT")
        frame.reagents_list:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -142)

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
    if not recipe then return "" end

    local reagents = ""

    for _, material in ipairs(recipe.materials) do
        local _, link = GetItemInfo(material.item_id)
        reagents = reagents .. material.amount .. "x " .. link .. ": "
        if not PM.items[material.item_id] or not PM.items[material.item_id].found_best_source then
            reagents = reagents .. "|cFFFF0000unknown|r\n"
        else
            local source = ""
            
            if type(PM.items[material.item_id].best_source) == "string" then
                source = "|cFF00FF00" .. PM.items[material.item_id].best_source .. "|r"
            else
                source = "|cFFFFFF00" .. PM.items[material.item_id].best_source.name .. "|r"
            end

            reagents = reagents .. source .. "\n"
        end
    end

    return reagents
end

ProfessionMaster.update_profession_frames = function()
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
    
    frame.best_recipe:SetText("|cFFFFFFFFBest recipe for this level: |r" .. (best_recipe and GetSpellLink(best_recipe.spell_id) or "|cFFFF0000unknown |cFFFFFFFF(scan auction house!)"))
    frame.best_recipe_price_per_craft:SetText("|cFFFFFFFFPrice: " .. (best_recipe and ProfessionMaster.format_price(ProfessionMaster.fetch_recipe_price(profession, best_recipe)) or "|cFFFF0000unknown"))
    frame.best_recipe_price_per_skill_up:SetText("|cFFFFFFFFAverage price per skill up: " .. (best_recipe and ProfessionMaster.format_price(ProfessionMaster.fetch_recipe_price_per_skill_up(profession, best_recipe, current_level)) or "|cFFFF0000unknown"))
    frame.best_recipe_fetched_at:SetText("|cFFFFFFFFRecipe last fetched: " .. ProfessionMaster.format_timestamp(ProfessionMaster.get_fetch_timestamp(best_recipe)))

    frame.reagents_list:SetText(ProfessionMaster.list_reagents(best_recipe))

    ProfessionMaster.enqueue({
        condition = function() return ProfessionMaster.professions[GetTradeSkillLine():gsub('%s+', ''):lower()] ~= nil end,
        execute = ProfessionMaster.update_profession_frames,
        allow_skipping = true,
        forbid_same_tick = true
    }, true)
end

ProfessionMaster.trade_skill_frames_initializer = function()
    ProfessionMaster.enqueue({
        condition = function() return TradeSkillFrame ~= nil end,
        execute = ProfessionMaster.init_profession_frames,
        allow_skipping = true
    }, true)
end