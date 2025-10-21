-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/color.lua

local M = {}

function M.hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function M.rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r), math.floor(g), math.floor(b))
end

function M.darken_color(hex, factor)
  factor = factor or 0.8 -- 20% darker
  local r, g, b = M.hex_to_rgb(hex)
  r = math.max(0, r * factor)
  g = math.max(0, g * factor)
  b = math.max(0, b * factor)
  return M.rgb_to_hex(r, g, b)
end

return M
