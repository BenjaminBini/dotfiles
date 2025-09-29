local function to0xAARRGGBB(color)
    local hex = color:gsub("#", "")

    if #hex == 6 then
        -- #RRGGBB -> 0xFFRRGGBB (full opacity)
        local result = tonumber("FF" .. hex, 16)
        --  print("result", result)
        return result
    elseif #hex == 8 then
        -- #RRGGBBAA -> 0xAARRGGBB
        local r = hex:sub(1, 2)
        local g = hex:sub(3, 4)
        local b = hex:sub(5, 6)
        local a = hex:sub(7, 8)
        local result = tonumber(a .. r .. g .. b, 16)
        print("result", result)

        return result
    else
        error("Invalid color format: " .. color)
    end
end

local function with_alpha(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
        return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return {
    bar = {
        bg = 0xd02c2e34,
        border = 0x00000000
    },
    popup = {
        bg = 0xc02c2e34,
        border = 0xff7f8490
    },
    bg1 = 0xff363944,
    bg2 = 0xff414550,

    rainbow = { 0xFFF64046, 0xFF709D28, 0xFF1982c4, 0xFFEC61AE, 0xFFfa7c2e, 0xFF6a4c93, 0xFFCAA133, 0xFF52a675 },
    to0xAARRGGBB = to0xAARRGGBB,
    apps_colors = {
        S = to0xAARRGGBB("#1DB954"),
        F = to0xAARRGGBB("#FF6347"),  -- Tomato red (was T2)
        D = to0xAARRGGBB("#0078d7"),
        T = to0xAARRGGBB("#FFFFFF"),  -- White
        M = to0xAARRGGBB("#D335D6"),
        V = to0xAARRGGBB("#FF0000"),  -- YouTube red
        AI = to0xAARRGGBB("#8A2BE2"), -- Blue violet (was T3)
        W = to0xAARRGGBB("#DAA520")   -- Goldenrod (was T4)
    },
    apps_focus_font_color = {
        S = to0xAARRGGBB("#FFFFFF"),
        F = to0xAARRGGBB("#FFFFFF"),  -- Orange red (was T2)
        D = to0xAARRGGBB("#FFFFFF"),
        T = to0xAARRGGBB("#222222"),  -- White
        M = to0xAARRGGBB("#FFFFFF"),
        V = to0xAARRGGBB("#FFFFFF"),  -- YouTube red
        AI = to0xAARRGGBB("#FFFFFF"), -- Dark violet (was T3)
        W = to0xAARRGGBB("#FFFFFF")   -- Gold (was T4)
    },
    with_alpha = with_alpha,
    white = to0xAARRGGBB("#FFFFFF"),
    dark = to0xAARRGGBB("#222222"),
    blue = to0xAARRGGBB("#1982c4"),
    yellow = to0xAARRGGBB("#CAA133"),
    orange = to0xAARRGGBB("#fa7c2e"),
    red = to0xAARRGGBB("#F64046"),
    grey = to0xAARRGGBB("#7f8490"),
    transparent = 0x00FFFFFF

}
