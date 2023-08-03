--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

--
-- Do not edit!
-- This file has been automatically generated, and should not be modified directly.
--

_G["PM_FREE_leatherworking"] = {
    id = "5a4d9ca1-480e-4b07-bd56-94007dc6fff5",
    revision = 1,
    name = "ProfessionMaster Leatherworking WotLK (base)",
    items = {
        [783] = {
            name = "Light Hide",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2318] = {
            name = "Light leather",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2320] = {
            name = "Coarse Thread",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 10,
            used_in_recipes = true
        },
        [2324] = {
            name = "Bleach",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 25,
            used_in_recipes = true
        },
        [2934] = {
            name = "Ruined Leather Scraps",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [4289] = {
            name = "Salt",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 50,
            used_in_recipes = true
        },
        [5082] = {
            name = "Thin Kodo Leather",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2302] = {
            name = "Handstitched Leather Boots",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2304] = {
            name = "Light Armor Kit",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2303] = {
            name = "Handstitched Leather Pants",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2300] = {
            name = "Embossed Leather Vest",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2309] = {
            name = "Embossed Leather Boots",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2310] = {
            name = "Embossed Leather Cloak",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2311] = {
            name = "White Leather Jerkin",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4237] = {
            name = "Handstitched Leather Belt",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4239] = {
            name = "Embossed Leather Gloves",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4231] = {
            name = "Cured Light Hide",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [5081] = {
            name = "Kodo Hide Bag",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [5957] = {
            name = "Handstitched Leather Vest",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7276] = {
            name = "Handstitched Leather Cloak",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7277] = {
            name = "Handstitched Leather Bracers",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7278] = {
            name = "Light Leather Quiver",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7279] = {
            name = "Small Leather Ammo Pouch",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7280] = {
            name = "Rugged Leather Pants",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [7281] = {
            name = "Light Leather Bracers",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        }
    },
    recipes = {
        [2302] = {
            [1] = {
                name = "Handstitched Leather Boots",
                product_id = 2302,
                spell_id = 2149,
                levels = { 1, 40, 70 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 2 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [2304] = {
            [1] = {
                name = "Light Armor Kit",
                product_id = 2304,
                spell_id = 2152,
                levels = { 1, 30, 60 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 1 }
                },
                tools = { }
            }
        },
        [2303] = {
            [1] = {
                name = "Handstitched Leather Pants",
                product_id = 2303,
                spell_id = 2153,
                levels = { 15, 45, 75 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 4 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [2300] = {
            [1] = {
                name = "Embossed Leather Vest",
                product_id = 2300,
                spell_id = 2160,
                levels = { 40, 70, 100 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 8 },
                    { item_id = 2320, amount = 4 }
                },
                tools = { }
            }
        },
        [2309] = {
            [1] = {
                name = "Embossed Leather Boots",
                product_id = 2309,
                spell_id = 2161,
                levels = { 55, 85, 115 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 8 },
                    { item_id = 2320, amount = 5 }
                },
                tools = { }
            }
        },
        [2310] = {
            [1] = {
                name = "Embossed Leather Cloak",
                product_id = 2310,
                spell_id = 2162,
                levels = { 60, 90, 120 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 5 },
                    { item_id = 2320, amount = 2 }
                },
                tools = { }
            }
        },
        [2311] = {
            [1] = {
                name = "White Leather Jerkin",
                product_id = 2311,
                spell_id = 2163,
                levels = { 60, 90, 120 },
                taught_by_trainer = false,
                source = "Drop, Pickpocketed",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 8 },
                    { item_id = 2320, amount = 2 },
                    { item_id = 2324, amount = 1 }
                },
                tools = { }
            }
        },
        [2318] = {
            [1] = {
                name = "Light Leather",
                product_id = 2318,
                spell_id = 2881,
                levels = { 1, 20, 40 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2934, amount = 3 }
                },
                tools = { }
            }
        },
        [4237] = {
            [1] = {
                name = "Handstitched Leather Belt",
                product_id = 4237,
                spell_id = 3753,
                levels = { 25, 55, 85 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 6 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [4239] = {
            [1] = {
                name = "Embossed Leather Gloves",
                product_id = 4239,
                spell_id = 3756,
                levels = { 55, 85, 115 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 3 },
                    { item_id = 2320, amount = 2 }
                },
                tools = { }
            }
        },
        [4231] = {
            [1] = {
                name = "Cured Light Hide",
                product_id = 4231,
                spell_id = 3816,
                levels = { 35, 55, 75 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 783, amount = 1 },
                    { item_id = 4289, amount = 1 }
                },
                tools = { }
            }
        },
        [5081] = {
            [1] = {
                name = "Kodo Hide Bag",
                product_id = 5081,
                spell_id = 5244,
                levels = { 40, 70, 100 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 5082, amount = 3 },
                    { item_id = 2318, amount = 4 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [5957] = {
            [1] = {
                name = "Handstitched Leather Vest",
                product_id = 5957,
                spell_id = 7126,
                levels = { 1, 40, 70 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 3 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [7276] = {
            [1] = {
                name = "Handstitched Leather Cloak",
                product_id = 7276,
                spell_id = 9058,
                levels = { 1, 40, 70 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 2 },
                    { item_id = 2320, amount = 1 }
                },
                tools = { }
            }
        },
        [7277] = {
            [1] = {
                name = "Handstitched Leather Bracers",
                product_id = 7277,
                spell_id = 9059,
                levels = { 1, 40, 70 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 2 },
                    { item_id = 2320, amount = 3 }
                },
                tools = { }
            }
        },
        [7278] = {
            [1] = {
                name = "Light Leather Quiver",
                product_id = 7278,
                spell_id = 9060,
                levels = { 30, 60, 90 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 4 },
                    { item_id = 2320, amount = 2 }
                },
                tools = { }
            }
        },
        [7279] = {
            [1] = {
                name = "Small Leather Ammo Pouch",
                product_id = 7279,
                spell_id = 9062,
                levels = { 30, 60, 90 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 3 },
                    { item_id = 2320, amount = 4 }
                },
                tools = { }
            }
        },
        [7280] = {
            [1] = {
                name = "Rugged Leather Pants",
                product_id = 7280,
                spell_id = 9064,
                levels = { 35, 65, 95 },
                taught_by_trainer = false,
                source = "Drop, Pickpocketed",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 5 },
                    { item_id = 2320, amount = 5 }
                },
                tools = { }
            }
        },
        [7281] = {
            [1] = {
                name = "Light Leather Bracers",
                product_id = 7281,
                spell_id = 9065,
                levels = { 70, 100, 130 },
                taught_by_trainer = true,
                source = "Leatherworking trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2318, amount = 6 },
                    { item_id = 2320, amount = 4 }
                },
                tools = { }
            }
        }
    }
}
