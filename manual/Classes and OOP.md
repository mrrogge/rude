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

Custom scene classes can be defined by subclassing `rude.Scene`:

```lua
local MyScene = rude.Scene:subclass('MyScene')

function MyScene:onUpdate(dt)
    -- update logic goes here
end
```