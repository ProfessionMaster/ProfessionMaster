--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

-- TODO: Enchanting mats!!!

ProfessionMaster = ProfessionMaster or { }
PMGuides = {
    jewelcrafting  = (PMGuides and PMGuides.jewelcrafting ) or _G["PM_FREE_jewelcrafting"],
    alchemy        = (PMGuides and PMGuides.alchemy       ) or _G["PM_FREE_alchemy"],
    blacksmithing  = (PMGuides and PMGuides.blacksmithing ) or _G["PM_FREE_blacksmithing"],
    enchanting     = (PMGuides and PMGuides.enchanting    ) or _G["PM_FREE_enchanting"],
    engineering    = (PMGuides and PMGuides.engineering   ) or _G["PM_FREE_engineering"],
    inscription    = (PMGuides and PMGuides.inscription   ) or _G["PM_FREE_inscription"],
    leatherworking = (PMGuides and PMGuides.leatherworking) or _G["PM_FREE_leatherworking"],
    tailoring      = (PMGuides and PMGuides.tailoring     ) or _G["PM_FREE_tailoring"],
    mining         = (PMGuides and PMGuides.mining        ) or _G["PM_FREE_mining"],
    herbalism      = (PMGuides and PMGuides.herbalism     ) or _G["PM_FREE_herbalism"],
    firstaid       = (PMGuides and PMGuides.firstaid      ) or _G["PM_FREE_firstaid"],
    cooking        = (PMGuides and PMGuides.cooking       ) or _G["PM_FREE_cooking"],
    fishing        = (PMGuides and PMGuides.fishing       ) or _G["PM_FREE_fishing"]
}

ProfessionMaster.professions = {
    jewelcrafting = {
        list = PMGuides.jewelcrafting,
        name = "Jewelcrafting",
        icon = "Interface/ICONS/INV_MISC_GEM_01",
        texture = GetSpellTexture(25229),
        required_version = 20000,
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    alchemy = {
        list = PMGuides.alchemy,
        name = "Alchemy",
        icon = "Interface/ICONS/TRADE_ALCHEMY",
        texture = GetSpellTexture(2259),
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    blacksmithing = {
        list = PMGuides.blacksmithing,
        name = "Blacksmithing",
        icon = "Interface/ICONS/TRADE_BLACKSMITHING",
        texture = GetSpellTexture(2018),
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    enchanting = {
        list = PMGuides.enchanting,
        name = "Enchanting",
        icon = "Interface/ICONS/TRADE_ENGRAVING",
        texture = GetSpellTexture(7411),
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    engineering = {
        list = PMGuides.engineering,
        name = "Engineering",
        icon = "Interface/ICONS/TRADE_ENGINEERING",
        texture = GetSpellTexture(4036),
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    inscription = {
        list = PMGuides.inscription,
        name = "Inscription",
        icon = "Interface/ICONS/INV_INSCRIPTION_TRADESKILL01",
        texture = GetSpellTexture(45357),
        required_version = 30000,
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    leatherworking = {
        list = PMGuides.leatherworking,
        name = "Leatherworking",
        icon = "Interface/ICONS/INV_MISC_ARMORKIT_17",
        texture = GetSpellTexture(2108),
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    tailoring = {
        list = PMGuides.tailoring,
        name = "Tailoring",
        icon = "Interface/ICONS/TRADE_TAILORING",
        texture = GetSpellTexture(3908),
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    mining = {
        list = PMGuides.mining,
        name = "Mining",
        icon = "Interface/ICONS/TRADE_MINING",
        texture = 134708,
        flags = {
            crafting      = true,
            gathering     = true,
            primary       = true
        }
    },
    herbalism = {
        list = PMGuides.herbalism,
        name = "Herbalism",
        icon = "Interface/ICONS/spell_nature_naturetouchgrow",
        texture = 136065,
        flags = {
            gathering     = true,
            primary       = true
        }
    },
    skinning = {
        list = nil,
        name = "Skinning",
        icon = "Interface/ICONS/INV_MISC_PELT_WOLF_01",
        texture = 134366,
        flags = {
            primary       = true
        }
    },
    firstaid = {
        list = PMGuides.firstaid,
        name = "First Aid",
        icon = "Interface/ICONS/spell_holy_sealofsacrifice",
        texture = GetSpellTexture(3273),
        flags = {
            crafting      = true
        }
    },
    cooking = {
        list = PMGuides.cooking,
        name = "Cooking",
        icon = "Interface/ICONS/INV_MISC_FOOD_15",
        texture = GetSpellTexture(2550),
        flags = {
            crafting      = true
        }
    },
    fishing = {
        list = PMGuides.fishing,
        name = "Fishing",
        icon = "Interface/ICONS/TRADE_FISHING",
        texture = 136245,
        flags = {
            gathering     = true
        }
    }
}

ProfessionMaster.latest_guide_revisions = {
    ["5e23e49c-adb5-4acd-90a8-5b293fea20c4"] = 1,
    ["723673f1-accb-4bf8-93aa-47608a8fadd0"] = 1,
    ["9b7a5e7f-7917-44f7-b207-08d8b33d92ba"] = 1,
    ["4d08697c-70a1-494e-8e42-175d9a825087"] = 1,
    ["261b5834-e463-4c3b-a0af-5798f41bf527"] = 1,
    ["8f5d0328-83b0-46b5-a50d-b04e6f828521"] = 1,
    ["fcc1de0d-1d52-46fb-8b98-fa428f3e4c27"] = 1,
    ["c4d67d10-a473-4106-a435-8cb04be516a9"] = 1,
    ["f504416a-3678-469f-9987-31f0ee71d6d4"] = 1,
    ["6a06c418-89dc-45ae-9795-d5b6d557b995"] = 1,
    ["68c78b4d-f0f0-47d1-8a6a-fa8a0bddb46e"] = 1,
    ["2c26a56e-0751-4f58-8170-1dec744f680d"] = 1,
    ["a21bd039-0ce8-42cf-97c9-5fcfcfddc70e"] = 1,
    ["5a4d9ca1-480e-4b07-bd56-94007dc6fff5"] = 1,
    ["ea9973f8-6902-4a75-b779-675f2d8ecec4"] = 1,
    ["d45c3013-c3f0-478b-9ca0-644f6be3f3b6"] = 1
}

ProfessionMaster.check_for_guide_updates = function()
    for _, profession in pairs(ProfessionMaster.professions) do
        if profession.list and ProfessionMaster.latest_guide_revisions[profession.list.id] then
            if ProfessionMaster.latest_guide_revisions[profession.list.id] > profession.list.revision then
                ProfessionMaster.print("Your guide for |cFFFF8000" .. profession.list.name .. "|r is out of date.")
            end
        end
    end
end
