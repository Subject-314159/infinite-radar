require('util')
data:extend({{
    type = "radar",
    name = "infiniradar",
    icon = "__base__/graphics/icons/radar.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-player", "player-creation"},
    minable = {
        mining_time = 0.1,
        result = "radar"
    },
    max_health = 500,
    corpse = "radar-remnants",
    dying_explosion = "radar-explosion",
    resistances = {{
        type = "fire",
        percent = 70
    }, {
        type = "impact",
        percent = 30
    }},
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    energy_per_sector = "10MJ",
    max_distance_of_sector_revealed = 6,
    max_distance_of_nearby_sector_revealed = 6,
    energy_per_nearby_scan = "500kJ",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
    },
    energy_usage = "600kW",
    integration_patch = {
        filename = "__base__/graphics/entity/radar/hr-radar-integration.png",
        priority = "low",
        width = 238,
        height = 216,
        direction_count = 1,
        shift = util.by_pixel(3, 8),
        scale = 0.5,
        hr_version = {
            filename = "__base__/graphics/entity/radar/hr-radar-integration.png",
            priority = "low",
            width = 238,
            height = 216,
            direction_count = 1,
            shift = util.by_pixel(1.5, 4),
            scale = 1
        }
    },
    pictures = {
        layers = {{
            filename = "__base__/graphics/entity/radar/hr-radar.png",
            priority = "low",
            width = 196,
            height = 254,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(2, -32),
            scale = 0.5,
            tint = {0.8, 1, 0.8},
            hr_version = {
                filename = "__base__/graphics/entity/radar/hr-radar.png",
                priority = "low",
                width = 196,
                height = 254,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(2, -32),
                scale = 1,
                tint = {0.8, 1, 0.8}
            }
        }, {
            filename = "__base__/graphics/entity/radar/hr-radar-shadow.png",
            priority = "low",
            width = 343,
            height = 186,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(78, 6),
            draw_as_shadow = true,
            scale = 0.5,
            hr_version = {
                filename = "__base__/graphics/entity/radar/hr-radar-shadow.png",
                priority = "low",
                width = 343,
                height = 186,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(78, 6),
                draw_as_shadow = true,
                scale = 1
            }
        }}
    },
    working_sound = {
        sound = {{
            filename = "__base__/sound/radar.ogg",
            volume = 0.8
        }},
        max_sounds_per_type = 3,
        -- audible_distance_modifier = 0.8,
        use_doppler_shift = false
    },
    radius_minimap_visualisation_color = {
        r = 0.059,
        g = 0.092,
        b = 0.235,
        a = 0.275
    },
    rotation_speed = 0.018
}, {
    type = "item",
    name = "infiniradar",
    icons = {{
        icon = "__base__/graphics/icons/radar.png",
        icon_size = 64,
        icon_mipmaps = 4,
        tint = {0.8, 1, 0.8}
    }},
    subgroup = "defensive-structure",
    order = "d[radar]-b[radar]",
    place_result = "infiniradar",
    stack_size = 50
}, {
    type = "recipe",
    name = "infiniradar",
    ingredients = {{"electronic-circuit", 10}, {"iron-gear-wheel", 10}, {"iron-plate", 20}},
    result = "infiniradar"
}})
