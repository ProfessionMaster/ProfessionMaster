--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
ProfessionMaster.operations = ProfessionMaster.operations or { }

ProfessionMaster.join_channel = function()
    JoinChannelByName("PMGatheringRoutesData")
    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.print("Failed to join gathering routes data channel")
    end
end

ProfessionMaster.chat_handler = function(...)
    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.join_channel()
        return
    end

    local _args = { ... }
    local _, channel_name = string.split(" ", _args[6])
    
    if channel_name ~= "PMGatheringRoutesData" --[[ or _args[4]:gsub("-.+", "") == UnitName("Player") ]] then return end

    local op, args = ProfessionMaster.decode(_args[3], ProfessionMaster.operations)

    if op == nil or args == nil then
        return
    end

    op.handler(args)
end

ProfessionMaster.chat_initializer = function()
    local chat_helper = CreateFrame("Frame", nil, UIParent)
    chat_helper:SetScript("OnEvent", ProfessionMaster.chat_handler)
    chat_helper:RegisterEvent("CHAT_MSG_CHANNEL")
end
