# What is ECS?
ECS stands for Entities, Components, and Systems. It is a set of rules and design patterns that highly favors composition over inheritance. 

Here are some links to information regarding ECS:
* https://en.wikipedia.org/wiki/Entity_component_system
* https://gameprogrammingpatterns.com/component.html

ECS is not a strict specification; there are many different variations and interpretations each with their own pros and cons. Typically, ECS implementations follow these characteristics:
* Entities are the building blocks that make up the application. They can be added/removed dynamically while the application runs.
* Entities are assigned an identifier, typically an integer.
* Entities are composed of multiple components.
* Each component is a "bag of data" without behavior or logic.
* Components are identified by some sort of "type" that relates them with other components of that same type.
* Components can be added/removed/modified dynamically while the application runs.
* Systems operate on sets of entities based on which types of components they have.

## `rude`'s ECS "flavor"
While `rude` is, at its core, an ECS-based engine, it does have some design characteristics that differ from "typical" ECS:
* the engine is divided into independent scenes. Each scene has its own set of entities, components, and systems.
* Scenes can run one-at-a-time or simultaneously. They can each be drawn independently, e.g. overlaying one on top of another.
* Entities can have IDs that are strings or numbers.
* Components are instances of classes. Each entity can have one component of a given class.
* Components can have simple data properties, as well as "sub-component" instances; this allows components to be built with hierarchical structures.
* Because components are built from classes, they can have their own methods and logic. However, the scope of these methods should be limited to the component's data, e.g. getters and setters.
* Systems are still the main source of game logic. A system can just be a function, or it can be an object that groups some set of methods together.
* Scenes are built using a set of systems that provide the necessary behavior. Systems are called within the scene's callback methods, e.g. update() and draw(). Typically, this behavior is fixed for a given scene; systems should not be enabled/disabled at runtime.

## ECS all the things!
Historically, the ECS pattern has been used mostly for managing game objects that exist in some spatial world: stuff like NPCs, player avatars, enemies, projectiles, barriers, etc. ECS is a natural fit for these types of objects, where there are lots of different characteristic combinations to work with.

With `rude`, ECS is the primary data management mechanism - this means that _everything_ can and should be made into entities and components. This includes audio, state machines, UI elements, timers, RNGs...anything!