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

ProfessionMaster.chat_initializer = function()
    local chat_helper = CreateFrame("Frame", nil, UIParent)
    chat_helper:SetScript("OnEvent", ProfessionMaster.chat_handler)
    chat_helper:RegisterEvent("CHAT_MSG_CHANNEL")
end
