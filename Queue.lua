--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
ProfessionMaster.queue = { }

ProfessionMaster.dequeue = function(hw_input, same_tick)
    if #ProfessionMaster.queue == 0 then return end

    for index, query in pairs(ProfessionMaster.queue) do
        if hw_input or not query.requires_hw_input then
            if query.condition() and (not same_tick or not query.forbid_same_tick) then
                query.execute()
                table.remove(ProfessionMaster.queue, index)
                ProfessionMaster.dequeue(hw_input, same_tick or query.forbid_same_tick)
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

ProfessionMaster.queue_initializer = function()
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
end
