--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
PM = PM or { }
PM.items = PM.items or { }

ProfessionMaster.recipe_colors = {
    orange     = "|cFFFF8040",
    yellow     = "|cFFFFFF00",
    green      = "|cFF40BF40",
    gray       = "|cFF808080",
    can_train  = "|cFFFF0000",
    cant_train = "|cFF800000"
}

ProfessionMaster.get_recipe_colors = function(recipe, level)
    if level <  recipe.levels[1]                                             then return ProfessionMaster.recipe_colors["cant_train"] end
    if not (IsSpellKnown(recipe.spell_id) or IsPlayerSpell(recipe.spell_id)) then return ProfessionMaster.recipe_colors[ "can_train"] end
    if level <  recipe.levels[2]                                             then return ProfessionMaster.recipe_colors[    "orange"] end
    if level < (recipe.levels[2] + recipe.levels[3]) / 2                     then return ProfessionMaster.recipe_colors[    "yellow"] end
    if level <  recipe.levels[3]                                             then return ProfessionMaster.recipe_colors[     "green"] end
                                                                                  return ProfessionMaster.recipe_colors[      "gray"]
end

ProfessionMaster.get_node_colors = function(node, level)
    if level <  node.levels[1]                       then return ProfessionMaster.recipe_colors["cant_train"] end
    if level <  node.levels[2]                       then return ProfessionMaster.recipe_colors[    "orange"] end
    if level < (node.levels[2] + node.levels[3]) / 2 then return ProfessionMaster.recipe_colors[    "yellow"] end
    if level <  node.levels[3]                       then return ProfessionMaster.recipe_colors[     "green"] end
                                                          return ProfessionMaster.recipe_colors[      "gray"]
end

ProfessionMaster.profession_colors = {
    trained   = "|cFFFFFF00",
    untrained = "|cFF808000"
}

ProfessionMaster.get_profession_color = function(profession)
    if ProfessionMaster.get_profession_level(profession) == 0 then return ProfessionMaster.profession_colors["untrained"] end
                                                                   return ProfessionMaster.profession_colors[  "trained"]
end

ProfessionMaster.create_item_frame = function()
    if not ProfessionMaster.item_frame then
        local frame = CreateFrame("Frame", "ProfessionMasterItemFrame", UIParent, "ButtonFrameTemplate")

        frame:SetPoint("CENTER")
        frame:SetWidth(320)
        frame:SetFrameStrata("HIGH")

        frame.title = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.title:SetText("|cFFFFFFFFProfessionMaster")
        frame.title:SetPoint("TOP", frame, "TOP", 16, -6)

        frame.corner = CreateFrame("Frame", nil, frame)
        frame.corner:SetPoint("TOPLEFT", -6, 7)
        frame.corner:SetSize(60, 60)
        frame.corner.tex = frame.corner:CreateTexture()
        frame.corner.tex:SetAllPoints(frame.corner)

        frame.item_title = frame:CreateFontString(nil, nil, "GameFontNormal")
        frame.item_title:SetText("")
        frame.item_title:SetPoint("TOP", frame, "TOP", 16, -36)

        frame.inner_frame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        frame.inner_frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -70)
        frame.inner_frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -36, 32)

        frame.content = ProfessionMaster.UILib.CreateFrame("FRAME", nil, frame.inner_frame, nil, 0)
        frame.content:SetPoint("TOPLEFT", frame.inner_frame, "TOPLEFT", 0, 0)
        frame.content:SetWidth(frame.inner_frame:GetWidth() - 10)
        frame.content:SetHeight(1)

        frame.inner_frame:SetScrollChild(frame.content)
        ProfessionMaster.item_frame = frame
    end
end

ProfessionMaster.get_item_sources = function(item_id)
    local recipes, nodes = { }, { }

    for _, profession in pairs(ProfessionMaster.professions) do
        local profession_recipes, profession_nodes = { }, { }
        local has_recipes, has_nodes = false, false

        if profession.flags.crafting then
            if profession.list ~= nil and profession.list.recipes ~= nil and profession.list.recipes[item_id] ~= nil then
                for _, recipe in ipairs(profession.list.recipes[item_id]) do
                    table.insert(profession_recipes, recipe)
                    has_recipes = true
                end
            end
        end
        
        if profession.flags.gathering and not inserted then
            if profession.list ~= nil then
                for _, node in pairs(profession.list.nodes) do
                    if node.items[item_id] ~= nil then
                        table.insert(profession_nodes, node)
                        has_nodes = true
                    end
                end
            end
        end

        if has_recipes then table.insert(recipes, { profession = profession, recipes = profession_recipes }) end
        if has_nodes   then table.insert(nodes,   { profession = profession, nodes   = profession_nodes   }) end
    end

    return recipes, nodes
end

ProfessionMaster.update_item_frame = function(item_id, is_node)
    if is_node then
        return -- todo!
    end

    if not ProfessionMaster.item_frame then
        ProfessionMaster.create_item_frame()
    end

    local frame = ProfessionMaster.item_frame

    frame.content:DeleteAllText()
    frame.content:SetHeight(1)

    if frame.item_id ~= item_id then
        SetPortraitToTexture(frame.corner.tex, select(10, GetItemInfo(item_id)))
        frame.item_id = item_id
    end

    frame:Show()

    frame.content:AddText("Used for:", 0, 0, 6, 0)

    local professions = ProfessionMaster.get_item_professions(item_id)
        
    for _, profession in ipairs(professions) do
        if profession.flags.crafting then
            local has_use = false

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
                        if not has_use then
                            has_use = true

                            frame.content:AddText("|T" .. profession.texture .. ":13|t " .. ProfessionMaster.get_profession_color(profession) .. profession.name, 6, 0)
                        end

                        local text = frame.content:AddText(ProfessionMaster.get_recipe_colors(recipe, ProfessionMaster.get_profession_level(profession)) .. recipe.name .. "|r", 1, 0)

                        text:OnClick(function()
                            if recipe.product_id then ProfessionMaster.update_item_frame(recipe.product_id) end
                        end)

                        text:AddTooltip(function()
                            ProfessionMaster.set_recipe_tooltip(recipe)
                        end)
                    end
                end
            end
        end
    end

    local recipes, nodes = ProfessionMaster.get_item_sources(item_id)
    
    if #recipes > 0 then
        frame.content:AddText("Crafted from:", 6, 0)

        for _, profession_recipes in ipairs(recipes) do
            frame.content:AddText("|T" .. profession_recipes.profession.texture .. ":13|t " .. ProfessionMaster.get_profession_color(profession_recipes.profession) .. profession_recipes.profession.name, 6, 0)

            for _, recipe in pairs(profession_recipes.recipes) do
                local text = frame.content:AddText(ProfessionMaster.get_recipe_colors(recipe, ProfessionMaster.get_profession_level(profession_recipes.profession)) .. recipe.name .. "|r", 1, 0)

                text:OnClick(function()
                    if recipe.product_id then ProfessionMaster.update_item_frame(recipe.product_id) end
                end)

                text:AddTooltip(function()
                    ProfessionMaster.set_recipe_tooltip(recipe)
                end)
            end
        end    
    end

    if #nodes > 0 then
        frame.content:AddText("Gathered from:", 6, 0)

        for _, profession_nodes in ipairs(nodes) do
            frame.content:AddText("|T" .. profession_nodes.profession.texture .. ":13|t " .. ProfessionMaster.get_profession_color(profession_nodes.profession) .. profession_nodes.profession.name, 6, 0)

            for _, node in pairs(profession_nodes.nodes) do
                local text = frame.content:AddText(ProfessionMaster.get_node_colors(node, ProfessionMaster.get_profession_level(profession_nodes.profession)) .. node.name .. "|r", 1, 0)

                text:OnClick(function()
                    if node.node_id then ProfessionMaster.update_item_frame(node.node_id, true) end
                end)

                text:AddTooltip(function()
                    ProfessionMaster.set_node_tooltip(node)
                end)
            end
        end
    end

    frame.content:SetHeight(frame.content:GetBorderBoxHeight())
    frame.item_title:SetText(select(1, GetItemInfo(item_id)))
end

ProfessionMaster.item_initializer = function()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button) 
        if IsControlKeyDown() and button == "RightButton" and self:GetParent():GetID() <= 5 then
            local item_id = 0

            if select(4, GetBuildInfo()) > 30000 then
                item_id = C_Container.GetContainerItemID(self:GetParent():GetID(), self:GetID())
            else
                item_id = GetContainerItemID(self:GetParent():GetID(), self:GetID())
            end

            for _, profession in pairs(ProfessionMaster.professions) do
                if profession.list and profession.list.items and profession.list.items[item_id] then
                    ProfessionMaster.update_item_frame(item_id)
                    return
                end
            end
        end 
    end)
end
