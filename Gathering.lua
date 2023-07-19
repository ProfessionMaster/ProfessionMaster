--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster.acceptable_time = 5

ProfessionMaster.current_profession = nil
ProfessionMaster.current_vein = nil
ProfessionMaster.current_area = nil
ProfessionMaster.current_route = nil
ProfessionMaster.current_step = 0
ProfessionMaster.current_other_nodes = false

ProfessionMaster.en_route_since = nil
ProfessionMaster.starting_ores = nil -- todo: update value on whenever ores are auctioned/crafted into ingots/stored in bank

ProfessionMaster.request_route_usage = function(vein_id, zone_id)
    if not zone_id then zone_id = 0 end

    if GetChannelName("PMGatheringRoutesData") == 0 then
        ProfessionMaster.join_channel()
    end

    ProfessionMaster.print("Requesting best farming route... Please press any keyboard button to send the request.")

    ProfessionMaster.enqueue({
        condition = function() return true end,
        execute = function()
            ProfessionMaster.print("Request sent! Please wait a few seconds while we fetch all the latest data.")

            ProfessionMaster.requested_routes_time = GetServerTime()
            ProfessionMaster.requested_vein_id = vein_id
            ProfessionMaster.requested_zone_id = zone_id
            ProfessionMaster.best_route = nil
            ProfessionMaster.best_area = nil
            ProfessionMaster.requested_routes = { }

            for _, profession in pairs(ProfessionMaster.professions) do
                if profession.flags.gathering and profession.list and profession.list.nodes[vein_id] then
                    if zone_id == 0 then
                        for cur_zone_id, _ in pairs(profession.list.nodes[vein_id].routes) do
                            if ProfessionMaster.requested_routes[cur_zone_id] == nil then
                                ProfessionMaster.requested_routes[cur_zone_id] = { }
                            end

                            for cur_route_id, _ in ipairs(profession.list.nodes[vein_id].routes[cur_zone_id]) do
                                if ProfessionMaster.requested_routes[cur_zone_id][cur_route_id] == nil then
                                    ProfessionMaster.requested_routes[cur_zone_id][cur_route_id] = { users = 0, ores = 0 }
                                end
                            end
                        end
                    elseif profession.list.nodes[vein_id].routes[zone_id] then
                        if ProfessionMaster.requested_routes[zone_id] == nil then
                            ProfessionMaster.requested_routes[zone_id] = { }
                        end

                        for cur_route_id, _ in ipairs(profession.list.nodes[vein_id].routes[zone_id]) do
                            if ProfessionMaster.requested_routes[zone_id][cur_route_id] == nil then
                                ProfessionMaster.requested_routes[zone_id][cur_route_id] = { users = 0, ores = 0 }
                            end
                        end
                    end
                end
            end

            SendChatMessage(
                ProfessionMaster.encode(ProfessionMaster.operations["request"], { vein_id, zone_id, GetServerTime() }),
                "CHANNEL",
                nil,
                GetChannelName("PMGatheringRoutesData")
            )

            ProfessionMaster.enqueue({
                condition = function()
                    local server_time = GetServerTime()

                    return not ProfessionMaster.acceptable_time_difference(
                        ProfessionMaster.requested_routes_time,
                        server_time
                    )
                end,
                execute = function()
                    local best_area = nil
                    local best_route = -1
                    local best_users = -1
                    local route_ores = -1

                    for zone, data in pairs(ProfessionMaster.requested_routes) do
                        for route, route_data in pairs(data) do
                            if route_ores == -1 or ((route_data.users == 0 or route_ores < route_data.ores / route_data.users) and best_users > 0) then
                                best_area = zone
                                best_route = route
                                best_users = route_data.users
                                route_ores = route_data.ores / route_data.users
                            end
                        end
                    end

                    if route_users == -1 then route_users = 0 end

                    if best_route == -1 then
                        ProfessionMaster.print_verbose("No routes currently used! Pick any of the available routes")
                        return
                    end

                    -- todo: what if route is unused but a variation of the route is heavily used? 

                    if best_users == 0 then
                        ProfessionMaster.print_verbose("Best route: " .. C_Map.GetMapInfo(best_area).name .. " (" .. best_route .. "): currently empty!")
                    else
                        ProfessionMaster.print_verbose("Best route: " .. C_Map.GetMapInfo(best_area).name .. " (" .. best_route .. "): average ores: " .. route_ores .. "/5 mins - players: " .. best_users)
                    end

                    for key, profession in pairs(ProfessionMaster.professions) do
                        if profession.flags.gathering and profession.list and profession.list.nodes[vein_id] then
                            if ProfessionMaster.main_frame.profession_frames[profession.name].sub_frame.optimal_route then
                                ProfessionMaster.main_frame.profession_frames[profession.name].sub_frame.optimal_route:Enable()
                            end
                        end
                    end

                    ProfessionMaster.best_route = best_route
                    ProfessionMaster.best_area = best_area

                    ProfessionMaster.requested_routes_time = nil
                end,
                allow_skipping = true
            })
        end,
        requires_hw_input = true
    })
end

ProfessionMaster.process_route_request = function(args)
    if ProfessionMaster.current_step == 0 then return end
    if args[2] ~= 0 and args[2] ~= ProfessionMaster.current_area then return end

    local server_time = GetServerTime()

    if ProfessionMaster.current_vein == args[1] and ProfessionMaster.acceptable_time_difference(
        server_time,
        args[3]
    ) then
        ProfessionMaster.enqueue({
            condition = function() return true end,
            execute = function()
                SendChatMessage(
                    ProfessionMaster.encode(ProfessionMaster.operations["route"], {
                        args[1],
                        C_Map.GetBestMapForUnit("Player"),
                        ProfessionMaster.current_route,
                        GetServerTime(),
                        (GetItemCount(ProfessionMaster.current_profession.list.nodes[ProfessionMaster.current_vein].main_item) - ProfessionMaster.starting_ores) * 300 / (GetServerTime() - ProfessionMaster.en_route_since)
                    }),
                    "CHANNEL",
                    nil,
                    GetChannelName("PMGatheringRoutesData")
                )
            end,
            requires_hw_input = true
        }, true)
    end
end

ProfessionMaster.process_route_reply = function(args)
    if ProfessionMaster.requested_routes_time == nil then return end
    
    if ProfessionMaster.current_vein == args[1] and ProfessionMaster.acceptable_time_difference(
        args[4],
        ProfessionMaster.requested_routes_time
    ) then
        if ProfessionMaster.requested_routes[args[2]] == nil then
            ProfessionMaster.requested_routes[args[2]] = { }
        end

        if ProfessionMaster.requested_routes[args[2]][args[3]] == nil then
            ProfessionMaster.requested_routes[args[2]][args[3]] = { users = 1, ores = args[5] }
        else
            ProfessionMaster.requested_routes[args[2]][args[3]].users = ProfessionMaster.requested_routes[args[2]][args[3]].users + 1
            ProfessionMaster.requested_routes[args[2]][args[3]].ores = ProfessionMaster.requested_routes[args[2]][args[3]].ores + args[5]
        end
    end
end

ProfessionMaster.acceptable_time_difference = function(t1, t2)
    local diff = t2 - t1
    return diff > -ProfessionMaster.acceptable_time and diff < ProfessionMaster.acceptable_time
end

ProfessionMaster.gathering_step = function()
    if ProfessionMaster.current_profession == nil then
        return "No route selected"
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local x, y = C_Map.GetPlayerMapPosition(zone_id, "player"):GetXY()

    x = floor(x * 1000) / 10
    y = floor(y * 1000) / 10

    if zone_id ~= ProfessionMaster.current_area then
        ProfessionMaster.en_route_since = GetServerTime()

        local player_instance = C_Map.GetWorldPosFromMapPos(zone_id, { x = x, y = y })
        local target_instance = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = 50, y = 50 })
    
        if player_instance ~= target_instance then
            return "Travel to " .. GetRealZoneText(target_instance)
        end

        return "Travel to " .. C_Map.GetMapInfo(ProfessionMaster.current_area).name
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    if ProfessionMaster.current_step < 1 then
        local best_step = 0
        local best_distance = 0

        for id, values in ipairs(route.route) do
            ProfessionMaster.current_step = id
            local distance = ProfessionMaster.get_step_distance_number()

            if best_step == 0 or distance < best_distance then
                best_step = id
                best_distance = distance
            end
        end

        ProfessionMaster.current_step = best_step
    end

    if ProfessionMaster.current_step > #route.route then
        ProfessionMaster.current_step = 1
    end

    local materials = "materials"

    if ProfessionMaster.current_profession.name == ProfessionMaster.professions.mining.name then
        materials = "ores"
    elseif ProfessionMaster.current_profession.name == ProfessionMaster.professions.herbalism.name then
        materials = "herbs"
    end

    local distance = ProfessionMaster.get_step_distance_number()

    local step = route.route[ProfessionMaster.current_step]

    local cur_level = 1

    for index = 1, GetNumSkillLines() do
        local name, _, _, level = GetSkillLineInfo(index)
        if name == profession.name then
            cur_level = level
            break
        end
    end

    -- todo: skip walking steps if last step was for wrong vein_id anyway
    if (distance and distance < 10) or (step.vein_id ~= ProfessionMaster.current_vein and not ProfessionMaster.current_other_nodes) or step.min_level > cur_level then
        ProfessionMaster.current_step = ProfessionMaster.current_step + 1

        if ProfessionMaster.current_step > #route.route then
            ProfessionMaster.current_step = 1
        end
    end
    
    local is_cave = route.route[ProfessionMaster.current_step].cave
    local is_node = route.route[ProfessionMaster.current_step].node

    local msg = "Travel here"

    if is_node then
        msg = "Check for " .. materials
    end
    
    if is_cave then
        msg = "Explore cave for " .. materials
    end

    if route.route[ProfessionMaster.current_step].msg then
        msg = route.route[ProfessionMaster.current_step].msg
    end

    return "Step " .. ProfessionMaster.current_step .. ": " .. msg
end

ProfessionMaster.correct_instance = function()
    if ProfessionMaster.current_profession == nil then
        return
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")

    local player_instance = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))
    local target_instance = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = 50, y = 50 })

    if player_instance ~= target_instance then
        return
    end

    return true
end

ProfessionMaster.get_step_distance_number = function()
    if ProfessionMaster.current_profession == nil then
        return nil
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    local step = ProfessionMaster.current_step

    if ProfessionMaster.current_step < 1 or ProfessionMaster.current_step > #route.route then
        step = 1
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local instance_id, pos = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))

    local step_x, step_y = route.route[step].x, route.route[step].y

    local step_instance_id, step_pos = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = step_x / 100, y = step_y / 100 })

    local dx = pos.x - step_pos.x
    local dy = pos.y - step_pos.y

    local distance = floor(sqrt(dy * dy + dx * dx))
    
    return distance
end

ProfessionMaster.get_step_distance = function()
    return ProfessionMaster.get_step_distance_number() .. " yards"
end

ProfessionMaster.get_step_direction = function()
    if ProfessionMaster.current_profession == nil then
        return nil
    end

    local profession = ProfessionMaster.current_profession
    local vein = profession.list.nodes[ProfessionMaster.current_vein]
    local area = vein.routes[ProfessionMaster.current_area]
    local route = area[ProfessionMaster.current_route]

    local step = ProfessionMaster.current_step

    if ProfessionMaster.current_step < 1 or ProfessionMaster.current_step > #route.route then
        step = 1
    end

    local zone_id = C_Map.GetBestMapForUnit("Player")
    local instance_id, pos = C_Map.GetWorldPosFromMapPos(zone_id, C_Map.GetPlayerMapPosition(zone_id, "player"))

    local step_x, step_y = route.route[step].x, route.route[step].y

    local step_instance_id, step_pos = C_Map.GetWorldPosFromMapPos(ProfessionMaster.current_area, { x = step_x / 100, y = step_y / 100 })

    local dx = step_pos.x - pos.x
    local dy = step_pos.y - pos.y

    if dx == 0 then return 0 end

    local angle = GetPlayerFacing() - atan(dy / dx) * math.pi / 180

    if dx < 0 then return angle - math.pi end

    return angle
end

ProfessionMaster.update_step_frame = function()
    if ProfessionMaster.current_profession == nil then
        ProfessionMaster.step_frame:Hide()
        return
    end

    local msg = ProfessionMaster.gathering_step()
    local angle = ProfessionMaster.get_step_direction() * 180 / math.pi

    ProfessionMaster.step_frame:Show()

    if ProfessionMaster.correct_instance() then
        ProfessionMaster.step_frame.inner_frame:Show()
        ProfessionMaster.step_frame.inner_frame:SetPoint("CENTER", sin(angle) * 14, cos(angle) * 14)
        ProfessionMaster.step_frame.text:SetText("|cFFFFFFFF" .. msg .. "\n" .. ProfessionMaster.get_step_distance())
    else
        ProfessionMaster.step_frame.inner_frame:Hide()
        ProfessionMaster.step_frame.text:SetText("|cFFFFFFFF" .. msg)
    end
end

ProfessionMaster.start_route = function(profession_name, vein, zone, route, current_other_nodes)
    ProfessionMaster.current_profession = ProfessionMaster.professions[profession_name]
    ProfessionMaster.current_vein = vein
    ProfessionMaster.current_area = zone
    ProfessionMaster.current_route = route
    ProfessionMaster.current_step = 0
    ProfessionMaster.current_other_nodes = current_other_nodes
    ProfessionMaster.en_route_since = GetServerTime()
    ProfessionMaster.starting_ores = GetItemCount(ProfessionMaster.current_profession.list.nodes[ProfessionMaster.current_vein].main_item)
end

ProfessionMaster.stop_route = function()
    ProfessionMaster.current_profession = nil
    ProfessionMaster.current_vein = nil
    ProfessionMaster.current_area = nil
    ProfessionMaster.current_route = nil
    ProfessionMaster.current_step = 0
    ProfessionMaster.current_other_nodes = false
    ProfessionMaster.en_route_since = nil
    ProfessionMaster.starting_ores = nil
end

ProfessionMaster.operations = ProfessionMaster.operations or { }

ProfessionMaster.operations.request = { id = 0, handler = ProfessionMaster.process_route_request, size = { 4, 4, 4       } }
ProfessionMaster.operations.route   = { id = 1, handler = ProfessionMaster.process_route_reply,   size = { 4, 4, 1, 4, 4 } }
