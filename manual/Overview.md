# `rude` - User Manual

## What is `rude`?

`rude` is an ECS framework written in Lua. It is primarily intended for games but can be used for any lua v5.1+ application. It provides a nice abstraction layer that handles entity management, pooling, and other lower-level stuff, allowing you to focus on the fun parts of your program.

Some notable features are:
* Supports multiple scenes with independent entities and systems. Scenes can run one at a time or simultaneously.
* Easy conversion between in-game objects and external data files (e.g. JSON, CSV, binary)
* Provides custom logging configurations and exception handling
* Supports pooling of class instances for better memory management
