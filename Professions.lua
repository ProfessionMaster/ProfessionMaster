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
        required_version = 20000,
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    alchemy = {
        list = PMGuides.alchemy,
        name = "Alchemy",
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    blacksmithing = {
        list = PMGuides.blacksmithing,
        name = "Blacksmithing",
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    enchanting = {
        list = PMGuides.enchanting,
        name = "Enchanting",
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    engineering = {
        list = PMGuides.engineering,
        name = "Engineering",
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    inscription = {
        list = PMGuides.inscription,
        name = "Inscription",
        required_version = 30000,
        flags = {
            crafting      = true,
            primary       = true
        }
    },
    leatherworking = {
        list = PMGuides.leatherworking,
        name = "Leatherworking",
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    tailoring = {
        list = PMGuides.tailoring,
        name = "Tailoring",
        flags = {
            crafting      = true,
            primary       = true,
            specializable = true
        }
    },
    mining = {
        list = PMGuides.mining,
        name = "Mining",
        flags = {
            crafting      = true,
            gathering     = true,
            primary       = true
        }
    },
    herbalism = {
        list = PMGuides.herbalism,
        name = "Herbalism",
        flags = {
            gathering     = true,
            primary       = true
        }
    },
    skinning = {
        list = nil,
        name = "Skinning",
        flags = {
            primary       = true
        }
    },
    firstaid = {
        list = PMGuides.firstaid,
        name = "First Aid",
        flags = {
            crafting      = true
        }
    },
    cooking = {
        list = PMGuides.cooking,
        name = "Cooking",
        flags = {
            crafting      = true
        }
    },
    fishing = {
        list = PMGuides.fishing,
        name = "Fishing",
        flags = {
            gathering     = true
        }
    }
}
