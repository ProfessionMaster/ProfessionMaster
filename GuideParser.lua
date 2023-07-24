--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.guide_decoder = function(str)
    local function get_key()
        local output = 0

        for i = 1, ProfessionMaster.data:len() do
            output = output + ((3792424121245163333 + ProfessionMaster.data:sub(i, i):byte() * (i + 12)) % (937 * (ProfessionMaster.data:len() - i + 1) * (ProfessionMaster.data:len() + i - 1)))
        end
        
        return output
    end

    local key, decoded = get_key(), ""

    for i = 1, str:len() do
        decoded = decoded .. string.char(bit.bxor(str:sub(i, i):byte(), key))
    end

    return decoded
end

ProfessionMaster.guide_commands = {

}

ProfessionMaster.guide_parser = function(str)
    local decoded = ProfessionMaster.guide_decoder(str)

    ProfessionMaster.decode_stream(decoded, ProfessionMaster.guide_commands)
end
