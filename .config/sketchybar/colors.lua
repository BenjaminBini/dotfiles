local function to0xAARRGGBB(color)
    local hex = color:gsub("#", "")

    if #hex == 6 then
        -- #RRGGBB -> 0xFFRRGxsGBB (full opacity)
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
        --  print("result", result)

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
        F = to0xAARRGGBB("#ff7139"),
        D = to0xAARRGGBB("#0078d7"),
        T = to0xAARRGGBB("#7f8490"),
        M = to0xAARRGGBB("#BA2222"),
        V = to0xAARRGGBB("#FF0000"), -- YouTube red
        AI = to0xAARRGGBB("#9966cc")
    },
    with_alpha = with_alpha

}
