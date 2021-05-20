# Rude Changelog

## v0.6.1
Release date: TBD

Complete overhaul of pretty much everything! See PR for a more detailed explanation of the topics listed here.

### Dependencies
* LOVE2D is no longer a required dependency. Integrations with LOVE2D can now be applied with plugins/lovePlugin.lua.
* dkjson is no longer a required dependency. Integrations with dkjson can now be applied with plugins/dkjsonPlugin.lua.
* bitser is no longer a required dependency. Integrations with bitser can now be applied with plugins/bitserPlugin.lua.

### Data contexts and registration
* Added DataContext concept for managing registered components, functions, asset loaders, etc. This replaces all the registration methods found in Engine and Scene.
* Removed system registrations for engines and scenes.
* Removed graphics module. Reworked this into asset loader mechanism found in DataContext.
* Component queries now accept either the explicit class or a registered ID from a DataContext.

### Logging, error handling, etc.
* Removed assert and alert modules, replaced with Exceptions and logging.
* Added Exception classes, intended to be a better strategy compared to alert module.
* Added log module.

### Misc
* Changed the way entities and components are stored in scenes. Components of a given class are now stored in a dedicated table rather than one table for each entity. As a result, hasComIter() performance greatly improves.
* Removed getEnt(), since entity IDs are no longer explicitly stored to the scene.
* Added mouse-related callbacks to Engine and Scene.
* Scene:addEnt(), removeEnt(), addCom(), and removeCom() now correctly emit "addedEnt", "addedCom", "removingCom", "removingEnt", and "removedEnt" events.
* Added nearestNum() method to util module.
* Added some actual documentation!
* Started keeping track of changes with this changelog file.