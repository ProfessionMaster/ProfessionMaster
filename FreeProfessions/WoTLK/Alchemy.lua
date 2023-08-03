--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

--
-- Do not edit!
-- This file has been automatically generated, and should not be modified directly.
--

_G["PM_FREE_alchemy"] = {
    id = "c4d67d10-a473-4106-a435-8cb04be516a9",
    revision = 1,
    name = "ProfessionMaster Alchemy WotLK (base)",
    items = {
        [765] = {
            name = "Silverleaf",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [785] = {
            name = "Mageroyal",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2447] = {
            name = "Peacebloom",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2449] = {
            name = "Earthroot",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2450] = {
            name = "Briarthorn",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2452] = {
            name = "Swiftthistle",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [3164] = {
            name = "Discolored Worg Heart",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [3371] = {
            name = "Empty Vial",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 20,
            used_in_recipes = true
        },
        [5635] = {
            name = "Sharp Claw",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [118] = {
            name = "Minor Healing Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [2454] = {
            name = "Elixir of Lion's Strength",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2455] = {
            name = "Minor Mana Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2456] = {
            name = "Minor Rejuvenation Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2458] = {
            name = "Elixir of Minor Fortitude",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2459] = {
            name = "Swiftness Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [858] = {
            name = "Lesser Healing Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [3382] = {
            name = "Weak Troll's Blood Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [2457] = {
            name = "Elixir of Minor Agility",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [4596] = {
            name = "Discolored Healing Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [5631] = {
            name = "Rage Potion",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [5997] = {
            name = "Elixir of Minor Defense",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        }
    },
    recipes = {
        [2454] = {
            [1] = {
                name = "Elixir of Lion's Strength",
                product_id = 2454,
                spell_id = 2329,
                levels = { 1, 55, 95 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2449, amount = 1 },
                    { item_id = 765, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [118] = {
            [1] = {
                name = "Minor Healing Potion",
                product_id = 118,
                spell_id = 2330,
                levels = { 1, 55, 95 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2447, amount = 1 },
                    { item_id = 765, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [2455] = {
            [1] = {
                name = "Minor Mana Potion",
                product_id = 2455,
                spell_id = 2331,
                levels = { 25, 65, 105 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 785, amount = 1 },
                    { item_id = 765, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [2456] = {
            [1] = {
                name = "Minor Rejuvenation Potion",
                product_id = 2456,
                spell_id = 2332,
                levels = { 40, 70, 110 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 785, amount = 2 },
                    { item_id = 2447, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [2458] = {
            [1] = {
                name = "Elixir of Minor Fortitude",
                product_id = 2458,
                spell_id = 2334,
                levels = { 50, 80, 120 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2449, amount = 2 },
                    { item_id = 2447, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [2459] = {
            [1] = {
                name = "Swiftness Potion",
                product_id = 2459,
                spell_id = 2335,
                levels = { 60, 90, 130 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2452, amount = 1 },
                    { item_id = 2450, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [858] = {
            [1] = {
                name = "Lesser Healing Potion",
                product_id = 858,
                spell_id = 2337,
                levels = { 55, 85, 125 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 118, amount = 1 },
                    { item_id = 2450, amount = 1 }
                },
                tools = { }
            }
        },
        [3382] = {
            [1] = {
                name = "Weak Troll's Blood Potion",
                product_id = 3382,
                spell_id = 3170,
                levels = { 15, 60, 100 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2447, amount = 1 },
                    { item_id = 2449, amount = 2 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [2457] = {
            [1] = {
                name = "Elixir of Minor Agility",
                product_id = 2457,
                spell_id = 3230,
                levels = { 50, 80, 120 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 2452, amount = 1 },
                    { item_id = 765, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [4596] = {
            [1] = {
                name = "Discolored Healing Potion",
                product_id = 4596,
                spell_id = 4508,
                levels = { 50, 80, 120 },
                taught_by_trainer = false,
                source = "Quest",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 3164, amount = 1 },
                    { item_id = 2447, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [5631] = {
            [1] = {
                name = "Rage Potion",
                product_id = 5631,
                spell_id = 6617,
                levels = { 60, 90, 130 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 5635, amount = 1 },
                    { item_id = 2450, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        },
        [5997] = {
            [1] = {
                name = "Elixir of Minor Defense",
                product_id = 5997,
                spell_id = 7183,
                levels = { 1, 55, 95 },
                taught_by_trainer = true,
                source = "Alchemy trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 765, amount = 2 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        }
    }
}
