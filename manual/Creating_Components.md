# Components
Components are the containers of data for entities in a scene. In `rude`, these are implemented as classes, where each entity can have one instance of a given class. This differs from typical ECS, where components are often simple data structures of "pure" data. The choice to use component classes with `rude` offers a few benefits:
* Each component is inherently defined with a "type", i.e its corresponding class.
* Each component instance can have default values defined in the class `initialize()` method. This is nice when you are building a component and only care about setting a couple data values, rather than having to define the entire structure.
* Components can have helper methods, if desired. This goes against typical ECS, where only systems can contain logic, but in practice there are situations where having basic methods on a component are useful, e.g. getters and setters. However, using a lot of component methods can hurt the modularity of your program, so make sure not to overdo it.

## Adding Components
You can add a component for a given entity ID by calling `Scene:addCom()`:

```lua
local engine = rude()
local scene = engine:newScene()
local ExampleComponent = rude.RudeObject:subclass('ExampleComponent')

scene:addCom('exampleId', ExampleComponent)
```

You can use `Scene:getCom()` to retrieve a component from an entity:

```lua
local exampleCom = scene:getCom('exampleId', ExampleComponent)
```

Note that `getCom()` returns a reference to the _actual_ component instance, not a copy.