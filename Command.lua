--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }

ProfessionMaster.slash_command = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
end

ProfessionMaster.command_initializer = function()
    SLASH_PROFESSIONMASTER1, SLASH_PROFESSIONMASTER2 = "/pm", "/professionmaster"
    SlashCmdList["PROFESSIONMASTER"] = ProfessionMaster.slash_command

    ProfessionMaster.data = select(2, BNGetInfo())
end
