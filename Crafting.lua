--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

-- todo: scan all known professions at once
-- todo: factor in materials you already own

ProfessionMaster = ProfessionMaster or { }
PM = PM or { }
PM.items = PM.items or { }

ProfessionMaster.color_source = function(recipe)
    if not recipe then
        return ""
    end

    if recipe.taught_by_trainer then
        return "|cFF00FF00" .. recipe.source .. "|r"
    elseif recipe.source == "Vendor" then
        return "|cFFFFFF00" .. recipe.source .. "|r"
    else
        return "|cFFFF0000" .. recipe.source .. "|r"
    end
end

ProfessionMaster.print_recipe = function(profession, recipe, msg, level)
    if not recipe then
        ProfessionMaster.print("|cFFFF0000Unknown recipe")    
        return
    end

    local link          = GetSpellLink(recipe.spell_id)
    local price         = ProfessionMaster.fetch_recipe_price(recipe)
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

ProfessionMaster.get_skill_up_chance = function(profession, recipe, skill_level)
    if profession.list.racial_bonuses and profession.list.racial_bonuses[select(2, UnitRace("Player"))] then
        skill_level = skill_level - profession.list.racial_bonuses[select(2, UnitRace("Player"))]
    end

    if not recipe then return 0 end
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

ProfessionMaster.fetch_recipes = function(profession)
    if profession == nil then
        ProfessionMaster.print("This profession does not exist!")
        return
    end

    if not CanSendAuctionQuery() then
        ProfessionMaster.print("You have to be at the auction house to use this function!")
        return
    end

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
                                best_profession   = nil,
                                vendor_price      = profession.list.items[item_id].vendor_purchase_price,
                                auction_price     = auction_price,
                                auction_fetch_at  = time(),
                                price             = lowest_price
                            }
                        end

                        local _, link = GetItemInfo(item_id)
                        if not link then link = item.name end

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

                    local price, best_profession = ProfessionMaster.fetch_recipe_product_price(recipe)

                    if price < PM.items[item_id].price then
                        PM.items[item_id].best_source     = recipe
                        PM.items[item_id].price           = price
                        PM.items[item_id].best_profession = best_profession
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
    if profession.best_recipes[skill] then
        ProfessionMaster.print("Recipe source: " .. ProfessionMaster.color_source(profession.best_recipes[skill]))
        ProfessionMaster.print("Average amount of crafts needed per skill up: " .. (1 / ProfessionMaster.get_skill_up_chance(profession, profession.best_recipes[skill], skill)))
        ProfessionMaster.print("Required materials per craft:")

        for _,material in ipairs(profession.best_recipes[skill].materials) do
            ProfessionMaster.print_material(profession, material)
        end
    end
end

-- todo: option to only check source recipes which you have already learnt
ProfessionMaster.fetch_recipe_price = function(recipe)
    local price, best_profession = 0, nil

    for _, material in ipairs(recipe.materials) do
        if PM.items[material.item_id] == nil then
            return 0
        else
            if not PM.items[material.item_id].found_best_source then
                local current_price = PM.items[material.item_id].price
                local best_recipe   = nil

                for _, profession in pairs(ProfessionMaster.professions) do
                    local has_profession = false

                    for index = 1, GetNumSkillLines() do
                        local name, _, _, level = GetSkillLineInfo(index)
                        if name == profession.name then
                            has_profession = true
                            break
                        end
                    end

                    if has_profession then
                        if profession.list and profession.list.recipes and profession.list.recipes[material.item_id] then
                            for _, material_recipe in ipairs(profession.list.recipes[material.item_id]) do
                                local recipe_price = ProfessionMaster.fetch_recipe_product_price(material_recipe)

                                if current_price == 0 or recipe_price < current_price then
                                    best_recipe     = material_recipe
                                    current_price   = recipe_price
                                    best_profession = profession
                                end
                            end
                        end
                    end
                end
                
                PM.items[material.item_id].found_best_source = true
                    
                if best_recipe ~= nil then
                    PM.items[material.item_id].best_source     = best_recipe
                    PM.items[material.item_id].best_profession = best_profession
                    PM.items[material.item_id].price           = current_price
                end
            end

            price = price + (PM.items[material.item_id].price * material.amount)
        end
    end

    return price, best_profession
end

-- todo: only check recipes you have already learnt
ProfessionMaster.fetch_best_recipe_for_item = function(item_id)
    local best_recipe = nil
    local current_price = 0

    for _, profession in pairs(ProfessionMaster.professions) do
        local has_profession = false

        for index = 1, GetNumSkillLines() do
            local name, _, _, level = GetSkillLineInfo(index)
            if name == profession.name then
                has_profession = true
                break
            end
        end

        if has_profession then
            if profession.list and profession.list.recipes and profession.list.recipes[item_id] then
                for _, recipe in ipairs(profession.list.recipes[item_id]) do
                    local recipe_price = ProfessionMaster.fetch_recipe_product_price(recipe)

                    if current_price == 0 or recipe_price < current_price then
                        best_recipe     = recipe
                        current_price   = recipe_price
                    end
                end
            end
        end
    end

    return best_recipe
end

ProfessionMaster.fetch_recipe_product_price = function(recipe)
    local price_per_craft, best_profession = ProfessionMaster.fetch_recipe_price(recipe)
    local average_products = (recipe.min_product + recipe.max_product) / 2

    return price_per_craft / average_products, best_profession
end

ProfessionMaster.fetch_recipe_price_per_skill_up = function(profession, recipe, level)
    return ProfessionMaster.fetch_recipe_price(recipe) / ProfessionMaster.get_skill_up_chance(profession, recipe, level)
end

ProfessionMaster.get_best_recipe = function(profession, level)
    if not profession or not profession.list or not profession.list.recipes then
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

ProfessionMaster.get_number_of_possible_crafts = function(item_id)
    local possible_crafts = -1
    local recipe = ProfessionMaster.fetch_best_recipe_for_item(item_id)

    if not recipe then return 0 end

    for _, material in ipairs(recipe.materials) do
        local item_count = GetItemCount(material.item_id, true) + ProfessionMaster.get_number_of_possible_crafts(material.item_id)
        local possible_crafts_this_material = math.floor(item_count / material.amount)

        if possible_crafts_this_material == 0 then return 0 end

        if possible_crafts == -1 or possible_crafts_this_material < possible_crafts then
            possible_crafts = possible_crafts_this_material
        end
    end

    return possible_crafts
end

ProfessionMaster.operations = ProfessionMaster.operations or { }

ProfessionMaster.operations.ah_price = { id = 2, handler = ProfessionMaster.process_ah_price,      size = { 4, 4, 4 } }
ProfessionMaster.operations.source   = { id = 3, handler = function() return end,                  size = {         } } -- todo
