--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

--
-- Do not edit!
-- This file has been automatically generated, and should not be modified directly.
--

_G["PM_FREE_enchanting"] = {
    racial_bonuses = {
        ["BloodElf"] = 10
    },
    items = {
        [3371] = {
            name = "Empty Vial",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 20,
            used_in_recipes = true
        },
        [4470] = {
            name = "Simple Wood",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 40,
            used_in_recipes = true
        },
        [6217] = {
            name = "Copper Rod",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 125,
            used_in_recipes = true
        },
        [10938] = {
            name = "Lesser Magic Essence",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [10939] = {
            name = "Greater Magic Essence",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [10940] = {
            name = "Strange Dust",
            craftable = false,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [17034] = {
            name = "Maple Seed",
            craftable = false,
            sold_at_vendor = true,
            vendor_purchase_price = 200,
            used_in_recipes = true
        },
        [6218] = {
            name = "Runed Copper Rod",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = true
        },
        [11287] = {
            name = "Lesser Magic Wand",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [11288] = {
            name = "Greater Magic Wand",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        },
        [20744] = {
            name = "Minor Wizard Oil",
            craftable = true,
            sold_at_vendor = false,
            vendor_purchase_price = 0,
            used_in_recipes = false
        }
    },
    recipes = {
        [7418] = {
            [1] = {
                name = "Enchant Bracer - Minor Health",
                spell_id = 7418,
                levels = { 1, 70, 110 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 1 }
                },
                tools = { }
            }
        },
        [7420] = {
            [1] = {
                name = "Enchant Chest - Minor Health",
                spell_id = 7420,
                levels = { 15, 70, 110 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 1 }
                },
                tools = { }
            }
        },
        [6218] = {
            [1] = {
                name = "Runed Copper Rod",
                spell_id = 7421,
                levels = { 1, 5, 10 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 6217, amount = 1 },
                    { item_id = 10940, amount = 1 },
                    { item_id = 10938, amount = 1 }
                },
                tools = { }
            }
        },
        [7426] = {
            [1] = {
                name = "Enchant Chest - Minor Absorption",
                spell_id = 7426,
                levels = { 40, 90, 130 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 2 },
                    { item_id = 10938, amount = 1 }
                },
                tools = { }
            }
        },
        [7443] = {
            [1] = {
                name = "Enchant Chest - Minor Mana",
                spell_id = 7443,
                levels = { 20, 80, 120 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10938, amount = 1 }
                },
                tools = { }
            }
        },
        [7454] = {
            [1] = {
                name = "Enchant Cloak - Minor Resistance",
                spell_id = 7454,
                levels = { 45, 95, 135 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 1 },
                    { item_id = 10938, amount = 2 }
                },
                tools = { }
            }
        },
        [7457] = {
            [1] = {
                name = "Enchant Bracer - Minor Stamina",
                spell_id = 7457,
                levels = { 50, 100, 140 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 3 }
                },
                tools = { }
            }
        },
        [7748] = {
            [1] = {
                name = "Enchant Chest - Lesser Health",
                spell_id = 7748,
                levels = { 60, 105, 145 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 2 },
                    { item_id = 10938, amount = 2 }
                },
                tools = { }
            }
        },
        [7766] = {
            [1] = {
                name = "Enchant Bracer - Minor Spirit",
                spell_id = 7766,
                levels = { 60, 105, 145 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10938, amount = 1 }
                },
                tools = { }
            }
        },
        [7771] = {
            [1] = {
                name = "Enchant Cloak - Minor Protection",
                spell_id = 7771,
                levels = { 70, 110, 150 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 3 },
                    { item_id = 10939, amount = 1 }
                },
                tools = { }
            }
        },
        [11287] = {
            [1] = {
                name = "Lesser Magic Wand",
                spell_id = 14293,
                levels = { 10, 75, 115 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 4470, amount = 1 },
                    { item_id = 10938, amount = 1 }
                },
                tools = { }
            }
        },
        [11288] = {
            [1] = {
                name = "Greater Magic Wand",
                spell_id = 14807,
                levels = { 70, 110, 150 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 4470, amount = 1 },
                    { item_id = 10939, amount = 1 }
                },
                tools = { }
            }
        },
        [20744] = {
            [1] = {
                name = "Minor Wizard Oil",
                spell_id = 25124,
                levels = { 45, 55, 75 },
                taught_by_trainer = true,
                source = "Enchanting trainer",
                min_product = 1,
                max_product = 1,
                materials = {
                    { item_id = 10940, amount = 2 },
                    { item_id = 17034, amount = 1 },
                    { item_id = 3371, amount = 1 }
                },
                tools = { }
            }
        }
    }
}
