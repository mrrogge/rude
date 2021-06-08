---Provides support for the LÖVE 2D framework.
-- LÖVE can be found here: [https://love2d.org/](https://love2d.org/).

local c = require('rude._contract')

---Builds a font from an id using `love.graphics.newFont()`.
-- id must be a string of comma-separated values that matches an interface for `newFont()`. For example:
-- 
-- "myfont.ttf,12"
-- @assetLoader font
-- @tparam string id a string of comma-separated font parameters.
-- @return the font object.
local function fontAssetLoader(id)
    local args = {}
    local i = 1
    local j = string.find(id, ',', i)
    while j do
        table.insert(args, string.sub(id, i, j-1))
        i, j = j+1, string.find(id, ',', j+1)
    end
    table.insert(args, string.sub(id, i))
    local fileName, size, hinting, dpiScale, imageFileName
    if tonumber(args[1]) then
        size, hinting, dpiScale = tonumber(args[1]), args[2], 
            tonumber(args[3])
    else
        if args[1] then
            fileName = args[1]
            if tonumber(args[2]) then
                size, hinting, dpiScale = tonumber(args[2]), args[3],
                    tonumber(args[4])
            else
                imageFileName = args[2]
            end
        end
    end
    if fileName and imageFileName then
        return love.graphics.newFont(fileName, imageFileName)
    elseif fileName then
        return love.graphics.newFont(fileName, size, hinting, dpiScale)
    else
        return love.graphics.newFont(size, hinting, dpiScale)
    end
end

---Builds an image from an external file using `love.graphics.newImage()`.
-- @assetLoader image
-- @tparam string path the path to the external image file.
-- @return the image object.

---Applies this plugin to an engine.
-- @function __call
-- @tparam rude.Engine engine The targeted engine.
return function(engine, context)
    local missingLoveMsg = 'This plugin requires LÖVE framework v11.0 or newer to run correctly. See: https://love2d.org.'
    if not love then
        error(missingLoveMsg)
    end
    local major, minor, revision = love.getVersion()
    if major < 11 then
        error(missingLoveMsg)
    end

    --register asset loaders
    engine:registerAssetLoader('image', love.graphics.newImage, context)
    engine:registerAssetLoader('font', fontAssetLoader, context)

    --add a table for LOVE-related functionality
    engine.love = engine.love or {
        _initCallbacks={},
        _attached = false
    }

    ---Sets up the LOVE environment to use callback functions defined for this engine.
    -- Any modifications made to the LOVE callbacks prior to calling attach() will be preserved.
    -- @patch love.attach
    engine.love.attach = function()
        if engine.love._attached then return end
        engine.love._initCallbacks.load = love.load
        engine.love._initCallbacks.update = love.update
        engine.love._initCallbacks.draw = love.draw
        engine.love._initCallbacks.keypressed = love.keypressed
        engine.love._initCallbacks.keyreleased = love.keyreleased
        engine.love._initCallbacks.mousemoved = love.mousemoved
        engine.love._initCallbacks.mousepressed = love.mousepressed
        engine.love._initCallbacks.mousereleased = love.mousereleased
        engine.love._initCallbacks.wheelmoved = love.wheelmoved
        love.load = function(...)
            if engine.love._initCallbacks.load then
                engine.love._initCallbacks.load(...)
            end
            engine:load(...)
        end
        love.update = function(dt, ...)
            c('rn')
            if engine.love._initCallbacks.update then
                engine.love._initCallbacks.update(dt, ...)
            end
            engine:update(dt, ...)
        end
        love.draw = function(...)
            if engine.love._initCallbacks.draw then
                engine.love._initCallbacks.draw(...)
            end
            engine:draw(...)
        end
        love.keypressed = function(key, scancode, isrepeat)
            c('rs,rs,rb')
            if engine.love._initCallbacks.keypressed then
                engine.love._initCallbacks.keypressed(key, scancode, isrepeat)
            end
            engine:keyPressed(key, scancode, isrepeat)
        end
        love.keyreleased = function(key, scancode)
            c('rs,rs')
            if engine.love._initCallbacks.keyreleased then
                engine.love._initCallbacks.keyreleased(key, scancode)
            end
            engine:keyReleased(key, scancode)
        end
        love.mousemoved = function(x,y,dx,dy,istouch)
            c('rn,rn,rn,rn,rb')
            if engine.love._initCallbacks.mousemoved then
                engine.love._initCallbacks.mousemoved(x,y,dx,dy,istouch)
            end
            engine:mouseMoved(x,y,dx,dy,istouch)
        end
        love.mousepressed = function(x,y,button,istouch,presses)
            c('rn,rn,rn,rb,rn')
            if engine.love._initCallbacks.mousepressed then
                engine.love._initCallbacks.mousepressed(x,y,button,istouch,presses)
            end
            engine:mousePressed(x,y,button,istouch,presses)
        end
        love.mousereleased = function(x,y,button,istouch,presses)
            c('rn,rn,rn,rb,rn')
            if engine.love._initCallbacks.mousereleased then
                engine.love._initCallbacks.mousereleased(x,y,button,istouch,presses)
            end
            engine:mouseReleased(x,y,button,istouch,presses)
        end
        love.wheelmoved = function(x,y)
            c('rn,rn')
            if engine.love._initCallbacks.wheelmoved then
                engine.love._initCallbacks.wheelmoved(x,y)
            end
            engine:wheelMoved(x,y)
        end
        engine.love._attached = true
    end

    ---Detaches the engine from the LOVE environment.
    -- This resets all LOVE callbacks to their original functions. Does nothing if the engine is not currently attached.
    -- @patch love.detach
    engine.love.detach = function()
        if not engine.love._attached then return end
        for k,v in pairs(engine.love._initCallbacks) do
            love[k] = v
            engine.love._initCallbacks[k] = nil
        end
        engine.love._attached = false
    end
end