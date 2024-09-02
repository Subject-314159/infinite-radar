local scan_next_chunk = function(force_index, surface_index, radar_unit)
    -- Get global force
    local gfsr = global.forces[force_index].surfaces[surface_index].radars[radar_unit]
    local force = game.forces[force_index]
    local surface = game.get_surface(surface_index)
    -- Get radius
    local radius = gfsr.radius
    local max_radius = settings.global["inf_max-chunk-radius"].value

    -- Get min/max chunk position of 2 million tiles / 32 in each direction
    -- Max chunk minus 1 because the box for the 2 millionth tile would be outside map boundaries
    local max_chunk_position = 62499
    local min_chunk_position = -62500

    -- Early exit if the scan radius for this radar is bigger than the setting, and settings is not set to -1
    if radius > max_radius and max_radius >= 0 then
        if gfsr.entity and gfsr.entity.valid then
            gfsr.entity.active = false
        end
        return
    end

    -- Get entity center chunk
    local center = {
        x = math.floor(gfsr.entity.x / 32),
        y = math.floor(gfsr.entity.y / 32)
    }

    -- Increase XY coordinate until we have an unreveiled and uncharted chunk
    local chunk_charted, chunk_generated
    local chunk_is_available = true
    while chunk_is_available do

        -- Get position
        local chunk = {
            x = math.min(math.max(gfsr.x + center.x, min_chunk_position), max_chunk_position),
            y = math.min(math.max(gfsr.y + center.y, min_chunk_position), max_chunk_position)
        }
        local pos = {
            x = (chunk.x * 32),
            y = (chunk.y * 32)
        }
        local box = {pos, {
            x = pos.x + 31,
            y = pos.y + 31
        }}

        -- Check if chunk is available
        chunk_charted = force.is_chunk_charted(surface_index, chunk)
        chunk_generated = surface.is_chunk_generated(chunk)
        chunk_is_available = chunk_charted and chunk_generated
        if not chunk_is_available then
            -- Chart the chunk
            force.chart(surface_index, box)
            gfsr.ticks_since_last_scan = 0

            -- Store the radius in global because it might have been changed in the else part
            gfsr.radius = radius
        else
            -- Increase the index
            if gfsr.direction == 1 then
                if gfsr.x == radius then
                    gfsr.direction = gfsr.direction + 1
                else
                    gfsr.x = gfsr.x + 1
                end
            elseif gfsr.direction == 2 then
                if gfsr.y == radius then
                    gfsr.direction = gfsr.direction + 1
                else
                    gfsr.y = gfsr.y + 1
                end
            elseif gfsr.direction == 3 then
                if gfsr.x == -radius then
                    gfsr.direction = gfsr.direction + 1
                else
                    gfsr.x = gfsr.x - 1
                end
            else -- direction == 4
                if gfsr.y < -radius then
                    gfsr.direction = 1
                    radius = radius + 1
                else
                    gfsr.y = gfsr.y - 1
                end
            end
        end
    end
end

local set_active_all = function(active)
    for force_index, gf in pairs(global.forces) do
        for surface_index, gfs in pairs(gf.surfaces) do
            for unit_number, gfsr in pairs(gfs.radars) do
                if gfsr.entity.valid then
                    gfsr.entity.active = active
                end
            end
        end
    end
end

local init = function()
end

script.on_configuration_changed(function()
    init()
end)

script.on_init(function()
    init()
end)

script.on_event(defines.events.on_tick, function(e)
    if not global.forces then
        return
    end
    -- Loop through each radar in global
    for force_index, gf in pairs(global.forces) do
        for surface_index, gfs in pairs(gf.surfaces) do
            for unit_number, gfsr in pairs(gfs.radars) do
                if gfsr.entity.valid then
                    -- Check if radar on this surface is powered
                    if gfsr.entity.status == defines.entity_status.working then
                        -- Increase tick count
                        gfsr.ticks_since_last_scan = gfsr.ticks_since_last_scan + 1

                        -- Scan next chunk if bigger than thicc threshold
                        if gfsr.ticks_since_last_scan > 5 * 60 then
                            scan_next_chunk(force_index, surface_index, unit_number)
                        end
                    end
                else
                    gfs.radars[unit_number] = nil
                end
            end

        end
    end
end)

local on_radar_built = function(radar, force_index, surface_index)
    -- Construct global array
    if not global.forces then
        global.forces = {}
    end
    if not global.forces[force_index] then
        global.forces[force_index] = {}
    end
    local gf = global.forces[force_index]
    if not gf.surfaces then
        gf.surfaces = {}
    end
    if not gf.surfaces[surface_index] then
        gf.surfaces[surface_index] = {}
    end
    local gfs = gf.surfaces[surface_index]
    if not gfs.radars then
        gfs.radars = {}
    end

    -- Update radar entry
    gfs.radars[radar.unit_number] = {
        entity = radar,
        radius = 1,
        direction = 1,
        x = -1,
        y = -1,
        ticks_since_last_scan = 9999999999
    }
end

script.on_event(defines.events.on_robot_built_entity, function(e)
    if (e.created_entity and e.created_entity.name == "infiniradar") then
        on_radar_built(e.created_entity, e.robot.force.index, e.created_entity.surface.index)
    end
end)

script.on_event(defines.events.on_built_entity, function(e)
    if (e.created_entity and e.created_entity.name == "infiniradar") then
        local player = game.get_player(e.player_index)
        on_radar_built(e.created_entity, player.force.index, e.created_entity.surface.index)
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
    if e.setting_type == "runtime-global" and e.setting == "inf_max-chunk-radius" then
        -- Reactivate all our radars
        set_active_all(true)
    end
end)

----------
-- Mod compatibility

script.on_event(defines.events.on_gui_click, function(event)
    -- Early exit if we do not have any radars yet
    if not global.forces then
        return
    end

    -- Copy trigger
    local gui = event.element
    if not (gui and gui.valid) then
        return
    end
    if gui.name ~= "DeleteEmptyChunks" then
        return
    end
    if event.player_index then
        local player = game.players[event.player_index]
        if not (player and player.valid) then
            return
        end
        if player.admin then
            local target_surface = settings.global["DeleteEmptyChunks_surface"].value
            local surface = game.get_surface(target_surface)
            local radius = settings.global["DeleteEmptyChunks_radius"].value
            local _paving = settings.global["DeleteEmptyChunks_paving"].value

            -- Stop our radars from scanning
            for force_index, gf in pairs(global.forces) do
                for surface_index, gfs in pairs(gf.surfaces) do
                    if surface_index == surface.index then
                        for unit_number, gfsr in pairs(gfs.radars) do
                            if gfsr.entity.valid then
                                gfsr.entity.active = false
                            end
                        end
                    end
                end
            end

            -- Notify player
            player.print({"infiniradar.notify-disabled-all_delete-empty_chunks", target_surface})
        end
    end
end)
