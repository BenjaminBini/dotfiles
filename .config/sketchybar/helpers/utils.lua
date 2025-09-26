local utils = {}

function utils.pretty_print(obj, name, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)

    if type(obj) == "table" then
        if name then
            print(prefix .. name .. " = {")
        else
            print(prefix .. "{")
        end

        for key, value in pairs(obj) do
            local key_str = type(key) == "string" and key or "[" .. tostring(key) .. "]"

            if type(value) == "table" then
                utils.pretty_print(value, key_str, indent + 1)
            else
                local value_str = type(value) == "string" and '"' .. value .. '"' or tostring(value)
                print(prefix .. "  " .. key_str .. " = " .. value_str)
            end
        end

        print(prefix .. "}")
    else
        local value_str = type(obj) == "string" and '"' .. obj .. '"' or tostring(obj)
        if name then
            print(prefix .. name .. " = " .. value_str)
        else
            print(prefix .. value_str)
        end
    end
end

return utils