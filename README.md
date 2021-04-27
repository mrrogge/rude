# Rude

Rude is an [ECS](https://en.wikipedia.org/wiki/Entity_component_system) game engine for Lua. It's primary focus is on code reusability - pieces from one project should be easy to incorporate into other projects.

Some notable features:
* Supports multiple scenes with independent entities and systems
* Easily convert between external data files and in-game objects
* Provides customizable logging configurations
* Includes an adaptable plugin mechanism

Rude was originally designed for [LÖVE2D](https://love2d.org/), but it now can be used in any Lua v5.1+ environment. Rude includes a plugin that can add LÖVE2D-specific functionality to the engine.

## Dependencies
Rude currently has only one required dependency, the `middleclass` library: [middleclass repo].

Rude also has optional features that use the following dependencies:
* dkjson: for converting between game data and JSON strings.
* bitser: for converting between game data and bitser binary strings.

## What is ECS?
ECS stands for Entities, Components, and Systems. It is a set of rules and design patterns that highly favors composition over inheritance. 

ECS is not a strict specification; there are many different variations and interpretations each with their own pros and cons. Typically, ECS implementations follow these characteristics:
* Entities are the building blocks that make up the application. They can be added/removed dynamically while the application runs.
* Entities are assigned an identifier, typically an integer.
* Entities are composed of multiple components.
* Each component is a "bag" of data without behavior.
* Components are identified by some sort of "type" that relates them with other components of that same type.
* Components can be added/removed/modified dynamically while the application runs.
* Systems operate on sets of entities based on which types of components they have.

## Rude's ECS "flavor"
While Rude is, at its core, an ECS-based engine, it does have some design characteristics that differ from "typical" ECS:
* the engine is divided into independent scenes. Each scene has its own set of entities, components, and systems.
* Scenes can run one-at-a-time or simultaneously. They can each be drawn independently, e.g. overlaying one on top of another.
* Entities can have IDs that are strings or numbers.
* Components are instances of classes. Each entity can have one component of a given class.
* Components can have simple data properties, as well as "sub-component" instances; this allows components to be built with hierarchical structures. Note that an entity with a component-in-a-component is not the same as "having" that sub-component directly.
* Because components are built from classes, they can have methods and logic. However, this is typically limited to simple getters and setters.
* Systems are still the main source of game logic. They can be simple functions or instances of system classes. System instances can have different methods that run during specific events, e.g. an update() method and a draw() method.

## Installation
The rude module is available through luarocks:

`luarocks install rude`

You can also manually download the "rude" directory from this repository and include it in your project. Note that `rude/init.lua` must be accessible through your `require()` path.

## Hello World!
Here is a basic example that uses the rude engine:

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
* We load the rude module using require().
* Calling the rude module builds a new engine instance.
* We create a new empty scene using the engine's newScene() method and assign it an ID of 'helloWorld'.
* We define a local function that will act as a system for our helloWorld scene. Typically the system will be passed a reference to the owning scene.
* The helloSys system calls the engine's log() function, which by default prints to the console. Note that the engine is accessed through the scene instance since the scene has a reference to the engine.
* Finally, we modify the onLoad() callback function of the scene to call helloSys(). onLoad() will be called once and only once the first time a scene is activated. Since the helloWorld scene is activated automatically by default, the system will run and 'Hello World!' will be printed to the console.

## Progress
The `rude` library is still largely a work-in-progress. Feel free to use it in your projects, just don't expect everything to work correctly.

A formal API doc will be added in the future, but for now, most important parts of the code are documented with comments. If you're using `rude` in a project now and need more info about a feature, feel free to submit an issue.

## Credits
`rude` is written and maintained by [Matt Rogge](https://mattrogge.com).

## License
Rude is licensed under the MIT license.