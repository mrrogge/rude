# The Engine
The Engine is the core object of the `rude` framework; it manages each of the scenes for your application. You typically only need one Engine instance per application.

Create a new Engine by calling the class:

```lua
local rude = require('rude')
local engine = rude.Engine()
```

Alternatively, you can create an engine by just calling rude directly:

```lua
local engine = rude()
```

## Configuring the engine
There are various configuration options for engine instances. You can pass a table of key/value pairs that defines these config values when building the engine:

```lua
engine = rude({
    updateStep=0.1,
    sceneMode='multi'
})
```

The following key values are supported:
* updateStep: controls the frame rate for scene `update()` calls. When updateStep is a positive number > 0, each `update()` will be called with this fixed rate in seconds. A negative number will update scenes with a variable frame rate (each engine `update()` will pass dt to the scene `update()` calls). The default is variable frame rate.
* sceneMode: controls how scenes are managed by the engine. When this value is "single", only one scene is active at a time; all engine event methods are routed to the active scene. When this value is "multi", the engine allows multiple scenes to be used simultaneously. The engine event methods route to each enabled scene in stack order.

## Engine event methods
The engine does not actually do anything until you call its event methods. The two most important are `update()` and `draw()`. `update()` will advance the scenes based on a time step parameter, dt (in seconds). `draw()` will call the scene draw methods. These allow the user to control these actions separately depending on their environment - for example, `update()` and `draw()` could each be called from separate threads, allowing graphics to be rendered without blocking the update logic.

Here is a basic setup that calls these event methods in a loop:

```lua
local rude = require('rude')
local engine = rude()
while true do
    engine:update(0.1)
    engine:draw()
end
```

This will run the engine by calling update() and draw() until the program is exited. Note that the 0.1 time step in `update()` isn't actually tied to real world time; the loop will call `update()` as fast as the system allows it. It is up to the user to decide how and when these events are called.

Here is a list of all the engine event methods:
* `update(dt)`: advances the scenes by a time step
* `draw()`: used to render scenes to the screen
* `load()`: intended to be called once when the program loads.
* `keyPressed(key, scancode, isrepeat)`: sends a key press event to the scenes.
* `keyReleased(key, scancode)`: sends a key released event to the scenes.

For those familiar with LOVE, these event methods map directly to corresponding LOVE callback methods. Thus, if running `rude` from within LOVE, you could do the following:

```lua
local rude = require('rude')
local engine = rude()

function love.load()
    engine:load()
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
```

This would route each of the LOVE callbacks to the corresponding engine event methods. Note that there is also the `rude.plugins.lovePlugin` that sets up this routing automatically - see "Using with LOVE".