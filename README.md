# GMCS
 UI Cascading sheet for GameMaker Studio 2.
 
 This is a substitute for a completely absent UI system in GameMaker. The library takes inspiration from HTML-CSS.
 The UI system contains:
  - Screen
  - Container
 
 The "screen" is just a "container" of the size of the window.
 ![1](https://user-images.githubusercontent.com/49441831/138723083-0bcedd12-646c-48d7-bc39-ba0ad77acc5d.png)
 
 The main feature here is the cascade layering. You can stack "containers" inside "containers". The following "containers" have the "same" size, but they each belong to the "container" in the upper layer. Their size is proportional to the "parent".
 ![2](https://user-images.githubusercontent.com/49441831/138724012-6d9d9d26-bb54-4df9-ba0f-2a590124b315.png)
