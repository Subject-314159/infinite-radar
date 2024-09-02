if global.forces then
    -- Loop through each radar in global
    for force_index, gf in pairs(global.forces) do
        for surface_index, gfs in pairs(gf.surfaces) do
            for unit_number, gfsr in pairs(gfs.radars) do
                -- Reset current chunk XY position
                gfsr.x = -1
                gfsr.y = -1
            end
        end
    end
end
