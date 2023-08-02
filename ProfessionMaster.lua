--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
PM = PM or { }

if PM.items == nil then PM.items = { } end

ProfessionMaster.verbose = true -- Disable in production

ProfessionMaster.print = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8000ProfessionMaster|r: " .. msg)
end

ProfessionMaster.print_verbose = function(msg)
    if ProfessionMaster.verbose then
        ProfessionMaster.print(msg)
    end
end

ProfessionMaster.format_price = function(price)
    if price == 0 then return "|cFFFF0000not available|r" end

    local copper = math.floor(price % 100)
    local silver = math.floor(price / 100) % 100
    local gold   = math.floor(price / 10000)

    if gold > 0 then
        return "|cFFFFD700" .. gold .. "g |r|cFFC0C0C0" .. silver .. "s |r|cFFB87333" .. copper .. "c|r"
    elseif silver > 0 then
        return "|cFFC0C0C0" .. silver .. "s |r|cFFB87333" .. copper .. "c|r"
    else
        return "|cFFB87333" .. copper .. "c|r"
    end
end

if select(4, GetBuildInfo()) > 30000 then
    ProfessionMaster.min_level_for_professions = {
        crafting = {
            1,
            10,
            20,
            35,
            50,
            65
        },
        gathering = {
            1,
            1,
            10,
            25,
            40,
            55
        }
    }
else
    ProfessionMaster.min_level_for_professions = {
        crafting = {
            5,
            10,
            20,
            35
        },
        gathering = {
            5,
            10,
            20,
            35
        }
    }
end

ProfessionMaster.profession_level_names = {
    "Apprentice",
    "Journeyman",
    "Expert",
    "Artisan",
    "Master",
    "Grand Master"
}

ProfessionMaster.check_for_levelups = function(profession)
    local skill_level, skill_max_level = 0, 0
    local min_levels = ProfessionMaster.min_level_for_professions.crafting

    if profession.flags.gathering then
        min_levels = ProfessionMaster.min_level_for_professions.gathering
    end

    for index = 1, GetNumSkillLines() do
        local name, _, _, level, _, _, max_level = GetSkillLineInfo(index)
        if name == profession.name then
            skill_level     = level
            skill_max_level = max_level
        end
    end

    if (skill_max_level == 450 and select(4, GetBuildInfo()) > 30000) or (skill_max_level == 300 and select(4, GetBuildInfo()) < 20000) then
        return "Current level: " .. skill_level .. " / " .. skill_max_level .. " (" .. ProfessionMaster.profession_level_names[#min_levels] .. ")"
    end

    if skill_level + 25 >= skill_max_level and UnitLevel("player") >= min_levels[skill_max_level / 75 + 1] then
        return "Current level: " .. skill_level .. " / " .. skill_max_level .. " - Can train " .. ProfessionMaster.profession_level_names[math.floor(skill_max_level / 75) + 1] .. "!"
    end

    return "Current level: " .. skill_level .. " / " .. skill_max_level .. " (" .. ProfessionMaster.profession_level_names[math.floor(skill_max_level / 75)] .. ")"
end

ProfessionMaster.init = function()
    ProfessionMaster.frame_initializer()
    ProfessionMaster.trade_skill_frames_initializer()
    ProfessionMaster.queue_initializer()
    ProfessionMaster.tooltip_initializer()
    ProfessionMaster.chat_initializer()
    ProfessionMaster.command_initializer()
    ProfessionMaster.item_initializer()
end

ProfessionMaster.init()
