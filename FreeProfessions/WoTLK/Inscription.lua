--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

--
-- Do not edit!
-- This file has been automatically generated, and should not be modified directly.
--

_G["PM_FREE_inscription"] = {
    items = {
        [39151] = {
            name = "Alabaster Pigment",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [39354] = {
            name = "Light Parchment",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 15,
            used_in_recipes = true
        },
        [1180] = {
            name = "Scroll of Stamina",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [955] = {
            name = "Scroll of Intellect",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [1181] = {
            name = "Scroll of Spirit",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [37118] = {
            name = "Scroll of Recall",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [37101] = {
            name = "Ivory Ink",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [38682] = {
            name = "Armor Vellum",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [39469] = {
            name = "Moonglow Ink",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [3012] = {
            name = "Scroll of Agility",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [954] = {
            name = "Scroll of Strength",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        }
    },
    recipes = {
        [1180] = {
            [1] = {
                name = "Scroll of Stamina",
                spell_id = 45382,
                levels = { 1, 35, 45 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 37101, amount = 1 },
                    { item_id = 39354, amount = 1 }
                },
                tools = { }
            }
        },
        [955] = {
            [1] = {
                name = "Scroll of Intellect",
                spell_id = 48114,
                levels = { 1, 35, 45 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 37101, amount = 1 },
                    { item_id = 39354, amount = 1 }
                },
                tools = { }
            }
        },
        [1181] = {
            [1] = {
                name = "Scroll of Spirit",
                spell_id = 48116,
                levels = { 1, 35, 45 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 37101, amount = 1 },
                    { item_id = 39354, amount = 1 }
                },
                tools = { }
            }
        },
        [37118] = {
            [1] = {
                name = "Scroll of Recall",
                spell_id = 48248,
                levels = { 35, 60, 75 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 39354, amount = 1 },
                    { item_id = 39469, amount = 1 }
                },
                tools = { }
            }
        },
        [37101] = {
            [1] = {
                name = "Ivory Ink",
                spell_id = 52738,
                levels = { 1, 15, 30 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 39151, amount = 1 }
                },
                tools = { }
            }
        },
        [38682] = {
            [1] = {
                name = "Armor Vellum",
                spell_id = 52739,
                levels = { 35, 75, 100 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 2,
                max_product = 2,
                materials = {
                    { item_id = 39469, amount = 1 },
                    { item_id = 39354, amount = 2 }
                },
                tools = { }
            }
        },
        [39469] = {
            [1] = {
                name = "Moonglow Ink",
                spell_id = 52843,
                levels = { 35, 45, 75 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 39151, amount = 2 }
                },
                tools = { }
            }
        },
        [3012] = {
            [1] = {
                name = "Scroll of Agility",
                spell_id = 58472,
                levels = { 15, 35, 45 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 37101, amount = 2 },
                    { item_id = 39354, amount = 1 }
                },
                tools = { }
            }
        },
        [954] = {
            [1] = {
                name = "Scroll of Strength",
                spell_id = 58484,
                levels = { 15, 35, 45 },
                taught_by_trainer = true,
                source = "Inscription trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 37101, amount = 2 },
                    { item_id = 39354, amount = 1 }
                },
                tools = { }
            }
        }
    }
}
