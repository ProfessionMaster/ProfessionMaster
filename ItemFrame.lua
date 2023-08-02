--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
PM = PM or { }
PM.items = PM.items or { }

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

        frame.content = CreateFrame("FRAME", nil, frame.inner_frame)
        frame.content:SetPoint("TOPLEFT", frame.inner_frame, "TOPLEFT", 0, 0)
        frame.content:SetWidth(frame.inner_frame:GetWidth() - 10)
        frame.content:SetHeight(1)

        frame.text = frame.content:CreateFontString(nil, nil, "GameFontNormal")
        frame.text:SetText("")
        frame.text:SetJustifyH("LEFT")
        frame.text:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, 0)
        frame.text:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, 0)

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

ProfessionMaster.update_item_frame = function(item_id)
    if not ProfessionMaster.item_frame then
        ProfessionMaster.create_item_frame()
    end

    local frame = ProfessionMaster.item_frame

    if frame.item_id ~= item_id then
        SetPortraitToTexture(frame.corner.tex, select(10, GetItemInfo(item_id)))
        frame.item_id = item_id
    end

    frame:Show()

    local text = "Used for:\n"

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

                            text = text .. "\n|T" .. profession.texture .. ":13|t " .. profession.name .. "\n"
                        end

                        text = text .. "|cFFFFFFFF" .. recipe.name .. "|r\n"
                    end
                end
            end
        end
    end

    local recipes, nodes = ProfessionMaster.get_item_sources(item_id)
    
    if #recipes > 0 then
        text = text .. "\n\nCrafted from:\n"

        for _, profession_recipes in ipairs(recipes) do
            text = text .. "\n|T" .. profession_recipes.profession.texture .. ":13|t " .. profession_recipes.profession.name .. "\n"

            for _, recipe in pairs(profession_recipes.recipes) do
                text = text .. "|cFFFFFFFF" .. recipe.name .. "|r\n"
            end
        end    
    end

    if #nodes > 0 then
        text = text .. "\n\nGathered from:\n"

        for _, profession_nodes in ipairs(nodes) do
            text = text .. "\n|T" .. profession_nodes.profession.texture .. ":13|t " .. profession_nodes.profession.name .. "\n"

            for _, node in pairs(profession_nodes.nodes) do
                text = text .. "|cFFFFFFFF" .. node.name .. "|r\n"
            end
        end
    end

    frame.text:SetText(text)

    frame.item_title:SetText(select(1, GetItemInfo(item_id)))
end

ProfessionMaster.item_initializer = function()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button) 
        if IsControlKeyDown() and button == "RightButton" and self:GetParent():GetID() <= 5 then 
            local item_id = GetContainerItemID(self:GetParent():GetID(), self:GetID())
            if PM.items[item_id] then
                ProfessionMaster.update_item_frame(item_id)
            end
        end 
    end)
end
