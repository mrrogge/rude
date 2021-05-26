# Using with LOVE
LOVE is a popular framework for developing games using Lua code. Originally, `rude` was designed specifically for LOVE, but it can now be used in any Lua v5.1+ environment.

`rude` includes a plugin at `rude.plugins.lovePlugin` that makes it easy to integrate directly with LOVE:

```lua
local rude = require('rude')
local engine = rude()
engine:usePlugin(rude.plugins.lovePlugin)
engine.love.attach()
```

Once used, the plugin allows the LOVE callback functions to be routed to the engine's event functions. Calling `engine.love.attach()` will enable these routings, and `engine.love.detach()` will disable them. For example, `love.update()` will call `engine.update()`, `love.draw()` will call `engine.draw()`, and so on.