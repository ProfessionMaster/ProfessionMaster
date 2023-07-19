--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

local FreePMGuides = {
    jewelcrafting  = _G["PM_FREE_jewelcrafting"],
    alchemy        = _G["PM_FREE_alchemy"],
    blacksmithing  = _G["PM_FREE_blacksmithing"],
    enchanting     = _G["PM_FREE_enchanting"],
    engineering    = _G["PM_FREE_engineering"],
    inscription    = _G["PM_FREE_inscription"],
    leatherworking = _G["PM_FREE_leatherworking"],
    tailoring      = _G["PM_FREE_tailoring"],
    mining         = _G["PM_FREE_mining"],
    herbalism      = _G["PM_FREE_herbalism"],
    firstaid       = _G["PM_FREE_firstaid"],
    cooking        = _G["PM_FREE_cooking"],
    fishing        = _G["PM_FREE_fishing"]
}

ProfessionMaster = ProfessionMaster or { }
PMGuides = PMGuides or FreePMGuides

ProfessionMaster.professions = {
    jewelcrafting = {
        list = PMGuides.jewelcrafting,
        name = "Jewelcrafting",
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
