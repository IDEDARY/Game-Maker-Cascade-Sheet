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

REMINDER!
Before starting, you need to declare:
 - global.screen_width
 - global.screen_height

You can use window_get or display_get based on what device you are using.

You start by declaring "Screen".

 - myscreen = ui_screen_create();

You also need to set screen visibility to true (default is false)(only for screens)

 - ui_screen_visible(myscreen,1);

You can then create a container inside the "myscreen" screen.

 - mycontainer = ui_container_create(myscreen,x1_anchor,y1_anchor,x2_anchor,y2_anchor,x1_relative,y1_relative,x2_relative,y2_relative)

Position of the container is set by 4 values for each coordinate.
 - x_anchor
 - x_relative
 - y_anchor
 - y_relative

![4](https://user-images.githubusercontent.com/49441831/138729965-620c1ee2-fb83-40bd-9c0d-c7683db3633e.png)

The anchor coordinates are solid and never change.
The relative coordinates are proportional to the parent.

The relative range from 0 (0%, MIN) to 1000 (100% of the parent, MAX).
You can combine these values to create ANY style of UI.

For every window_resize you need to recalculate position of the containers:
 - ui_screen_recalculate(myscreen);

or
 - ui_container_recalculate(mycontainer);

Both functions work the same, they update ALL CONTAINERS THAT BELONG TO UPDATED ONE!

For debugging I prepared also similar function, but instead of updating, it draws rectagles.
 - ui_container_draw(myscreen,draw_invisible); //draw_invisible (true/false) = Should it draw invalid or invisible containers?

