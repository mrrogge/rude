# Classes and OOP
`rude` uses the `middleclass` OOP library for its class definitions. Each of the built-in classes inherit from a base class, `rude.RudeObject`. You can build your own classes by making them a subclass of `rude.RudeObject`, for example:

```lua
local MyComponent = rude.RudeObject:subclass('MyComponent')

function MyComponent:initialize(foo, bar)
    self.foo = foo
    self.bar = bar
    return self
end
```

Custom scene classes can be defined by subclassing `rude.Scene`. Custom callbacks can then be defined for each specific scene class. For example:

```lua
local MyScene = rude.Scene:subclass('MyScene')

function MyScene:initialize(engine)
    rude.Scene.initialize(self, engine)    --note how the Scene base class's initialize method is called here.
    -- add additional initialization logic here
end

function MyScene:onUpdate(dt)
    -- custom update logic goes here
end
```