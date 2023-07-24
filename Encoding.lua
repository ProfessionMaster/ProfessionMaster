--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

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

ProfessionMaster.decode = function(str, ops, allow_larger_size)
    if #str < 2 then
        ProfessionMaster.print_verbose("|cFFFF0000Decoding error: invalid operation")
        return nil, nil
    end

    local op = ProfessionMaster.operation_lookup(bit.bor(from_hex(str:sub(1, 1)), bit.lshift(from_hex(str:sub(2, 2)), 0x0F)), ops)
    
    if op == nil then
        ProfessionMaster.print_verbose("|cFFFF0000Decoding error: invalid operation")
        return nil, nil
    end
    
    local reqsize = 0

    for _, size in ipairs(op.size) do
        reqsize = reqsize + size
    end

    local actualsize = (str:len() - 2) / 2

    if actualsize < reqsize or (actualsize > reqsize and not allow_larger_size) then
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

ProfessionMaster.decode_stream = function(str, ops)
    local pos = 1

    while pos < str:len() do
        local op, args = ProfessionMaster.decode(str:sub(pos, str:len()), ops, true)
        if op == nil then return end

        pos = pos + 2
        for _, size in ipairs(op.size) do
            pos = pos + size + size
        end

        op.handler(args)
    end
end

ProfessionMaster.operation_lookup = function(id, ops)
    for _, data in pairs(ops) do
        if data.id == id then
            return data
        end
    end

    return nil
end
