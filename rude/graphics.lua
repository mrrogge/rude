---graphics functions.
-- @module graphics

local c = require('rude._contract')

local module = {
    _fonts={}
}

--create table for memoizing images
module.imageCache = {}
setmetatable(module.imageCache, {__mode='v'})

---Returns an image object for a given file path.
function module.getImage(path)
    c('rs')
    if not module.imageCache[path] then
        module.imageCache[path] = love.graphics.newImage(path)
    end
    return module.imageCache[path]
end

---Registers a LOVE font to the module with the specified id.
-- Fonts can be created using love.graphics.newFont(). The id can be referenced
-- later in component data, e.g. drawable text components.
function module.registerFont(id, font)
    c('rn|s,ru')
    module._fonts[id] = font
end

--Build the default font (vera sans 12pt)
local defaultFont = love.graphics.newFont(12)
module.registerFont('default', defaultFont)

---Returns a registered font.
-- If font does not exist, a default will be returned.
function module.getFont(id)
    return module._fonts[id] or module._fonts['default'] or defaultFont
end

--Register some default fonts
--TODO

return module