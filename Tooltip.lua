--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.get_item_professions = function(item_id)
    local professions = { }

    for _, profession in pairs(ProfessionMaster.professions) do
        local inserted = false

        if profession.flags.crafting then
            if profession.list ~= nil and profession.list.items ~= nil and profession.list.items[item_id] ~= nil then
                table.insert(professions, profession)
                inserted = true
            end
        end
        
        if profession.flags.gathering and not inserted then
            if profession.list ~= nil then
                for _, node in pairs(profession.list.nodes) do
                    if node.items[item_id] ~= nil then
                        table.insert(professions, profession)
                        break
                    end
                end
            end
        end
    end

    return professions
end


ProfessionMaster.setup_tooltip = function(tooltip)
    local name, link = tooltip:GetItem()
	if not name then return end
	local item_id = select(1, GetItemInfoInstant(name))

    local professions = ProfessionMaster.get_item_professions(item_id)

    if #professions > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine("ProfessionMaster")
        tooltip:AddLine(" ")

        local has_uses = false
        
        for _, profession in ipairs(professions) do
            if profession.flags.crafting then
                local recipe_count = 0

                for result_item_id, recipes in pairs(profession.list.recipes) do
                    for id, recipe in ipairs(recipes) do
                        local needed = false

                        for _, material in ipairs(recipe.materials) do
                            if material.item_id == item_id then
                                needed = true
                                break
                            end
                        end

                        if needed then
                            recipe_count = recipe_count + 1
                        end
                    end
                end

                if recipe_count > 0 then
                    if not has_uses then
                        tooltip:AddLine("|cFFFFFFFFUsed for:")
                        has_uses = true
                    end

                    tooltip:AddDoubleLine("|T" .. profession.texture .. ":13|t |cFFFFFFFF" .. profession.name, "|cFFFFFFFF" .. recipe_count .. " recipes")
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
                    -- todo: which vendor? where? nearest?
                    best_soure = "Vendor"
                else
                    if PM.items[item_id].best_profession then
                        best_source = "|T" .. PM.items[item_id].best_profession.texture .. ":13|t |cFFFFFFFF" .. PM.items[item_id].best_source.name
                    else
                        best_source = "|cFFFFFFFF" .. PM.items[item_id].best_source.name
                    end
                end
            end

            best_price = PM.items[item_id].price
        end

        tooltip:AddLine(" ")

        if best_price ~= -1 then tooltip:AddDoubleLine("|cFFFFFFFFBest price:", ProfessionMaster.format_price(best_price) .. " |cFFFFFFFF(" .. best_source .. "|cFFFFFFFF)") end

        if has_uses then
            tooltip:AddLine(" ")
            tooltip:AddLine("Ctrl + Right Click |cFFFFFFFFto see more details")
        end

        tooltip:AddLine(" ")
    end
end

ProfessionMaster.tooltip_initializer = function()
    GameTooltip:HookScript("OnTooltipSetItem", ProfessionMaster.setup_tooltip)
end
