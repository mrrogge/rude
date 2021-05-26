# Hello World!
Here is a basic example using the `rude` framework. 

```lua
local rude = require('rude')
local engine = rude()
local scene = engine:newScene('helloWorld')

-- create a simple system function
local function helloSys(scene)
    scene.engine:log('Hello World!')
end

-- add the system to the scene load callback
function scene:onLoad()
    helloSys(self)
end
```

Let's break this down line-by-line:
* We load the rude module using `require()`.
* Calling the rude module builds a new engine instance.
* We create a new empty scene using the engine's `newScene()` method and assign it an ID of `helloWorld`.
* We define a local function that will act as a system for our `helloWorld` scene. Typically the system will be passed a reference to the owning scene.
* The `helloSys()` system calls the engine's `log()` function, which by default prints to the console. Note that the engine is accessed through the scene instance since the scene has a reference to the engine.
* Finally, we modify the `onLoad()` callback function of the scene to call `helloSys()`. `onLoad()` will be called once and only once the first time a scene is activated. Since the `helloWorld` scene is activated automatically by default, the system will run and `'Hello World!'` will be printed to the console.