--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

--
-- Do not edit!
-- This file has been automatically generated, and should not be modified directly.
--

_G["PM_FREE_engineering"] = {
    id = "68c78b4d-f0f0-47d1-8a6a-fa8a0bddb46e",
    revision = 1,
    name = "ProfessionMaster Engineering WotLK (base)",
    racial_bonuses = {
        ["Gnome"] = 15
    },
    items = {
        [774] = {
            name = "Malachite",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2589] = {
            name = "Linen Cloth",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2835] = {
            name = "Rough Stone",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2840] = {
            name = "Copper Bar",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2880] = {
            name = "Weak Flux",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 100,
            used_in_recipes = true
        },
        [4357] = {
            name = "Rough Blasting Powder",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [4359] = {
            name = "Handful of Copper Bolts",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [4361] = {
            name = "Copper Tube",
            craftable = true,
            sold_at_vendor = true,
            vendor_purchase_price = 500,
            used_in_recipes = true
        },
        [4399] = {
            name = "Wooden Stock",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 200,
            used_in_recipes = true
        },
        [4358] = {
            name = "Rough Dynamite",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [8067] = {
            name = "Crafted Light Shot",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4360] = {
            name = "Rough Copper Bomb",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4362] = {
            name = "Rough Boomstick",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4363] = {
            name = "Copper Modulator",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4405] = {
            name = "Crude Scope",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [6219] = {
            name = "Arclight Spanner",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        }
    },
    recipes = {
        [4357] = {
            [1] = {
                name = "Rough Blasting Powder",
                spell_id = 3918,
                levels = { 1, 20, 40 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2835, amount = 1 }
                },
                tools = { }
            }
        },
        [4358] = {
            [1] = {
                name = "Rough Dynamite",
                spell_id = 3919,
                levels = { 1, 30, 60 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 2,
                max_product = 2,
                materials = {
                    { item_id = 4357, amount = 2 },
                    { item_id = 2589, amount = 1 }
                },
                tools = { }
            }
        },
        [8067] = {
            [1] = {
                name = "Crafted Light Shot",
                spell_id = 3920,
                levels = { 1, 30, 60 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 200,
                max_product = 200,
                materials = {
                    { item_id = 4357, amount = 1 },
                    { item_id = 2840, amount = 1 }
                },
                tools = { }
            }
        },
        [4359] = {
            [1] = {
                name = "Handful of Copper Bolts",
                spell_id = 3922,
                levels = { 30, 45, 60 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 2,
                max_product = 2,
                materials = {
                    { item_id = 2840, amount = 1 }
                },
                tools = { }
            }
        },
        [4360] = {
            [1] = {
                name = "Rough Copper Bomb",
                spell_id = 3923,
                levels = { 30, 60, 90 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 2,
                max_product = 2,
                materials = {
                    { item_id = 2840, amount = 1 },
                    { item_id = 4359, amount = 1 },
                    { item_id = 4357, amount = 2 },
                    { item_id = 2589, amount = 1 }
                },
                tools = { }
            }
        },
        [4361] = {
            [1] = {
                name = "Copper Tube",
                spell_id = 3924,
                levels = { 50, 80, 110 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2840, amount = 2 },
                    { item_id = 2880, amount = 1 }
                },
                tools = { }
            }
        },
        [4362] = {
            [1] = {
                name = "Rough Boomstick",
                spell_id = 3925,
                levels = { 50, 80, 110 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 4361, amount = 1 },
                    { item_id = 4359, amount = 1 },
                    { item_id = 4399, amount = 1 }
                },
                tools = { }
            }
        },
        [4363] = {
            [1] = {
                name = "Copper Modulator",
                spell_id = 3926,
                levels = { 65, 95, 125 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 4359, amount = 2 },
                    { item_id = 2840, amount = 1 },
                    { item_id = 2589, amount = 2 }
                },
                tools = { }
            }
        },
        [4405] = {
            [1] = {
                name = "Crude Scope",
                spell_id = 3977,
                levels = { 60, 90, 120 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 4361, amount = 1 },
                    { item_id = 774, amount = 1 },
                    { item_id = 4359, amount = 1 }
                },
                tools = { }
            }
        },
        [6219] = {
            [1] = {
                name = "Arclight Spanner",
                spell_id = 7430,
                levels = { 50, 70, 90 },
                taught_by_trainer = true,
                source = "Engineering trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2840, amount = 6 }
                },
                tools = { }
            }
        }
    }
}
