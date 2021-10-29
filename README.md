# GMCS
 UI Cascading sheet for GameMaker Studio 2.
 
 Demo HERE: https://idedary.itch.io/gmcs
 
 This is a substitute for a completely absent UI system in GameMaker. The library takes inspiration from HTML-CSS.
 The main feature here is the cascade layering. You can stack "containers" inside "containers". The following "containers" have the "same" size, but they each belong to the "container" in the upper layer. Their size is proportional to the "parent".
 ![2](https://user-images.githubusercontent.com/49441831/138724012-6d9d9d26-bb54-4df9-ba0f-2a590124b315.png)

The UI system contains:

SCREEN
 - The "screen" is just a "container" of the size of the window.
 - It's visibility is set to false by default

CONTAINER
 - Struct that holds positions and variables.
 - It is defined by parent, anchor position and relative position.
 - You can access: visible,x1,y1,x2,y2,x,y,width,height.
 - It also holds "containers" and "elements" within the container.

ELEMENT
 - It's an object that has been indexed when created.
 - It is holded by parenting container.
 - When window resize is called, it's variables get rewritten (x,y).
 - You can access: element_x_scale, element_y_scale, element_container.

 ![1](https://user-images.githubusercontent.com/49441831/138723083-0bcedd12-646c-48d7-bc39-ba0ad77acc5d.png)


How to start?

REMINDER!
Before starting, you need to declare:
 - global.screen_width
 - global.screen_height

You can use window_get or display_get based on what device you are using.

//Create "screen"

You start by declaring "Screen".

 - myscreen = ui_screen_create();

//Set visibility

You also need to set screen visibility to true

 - ui_screen_visible(myscreen,1);

//Create container

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

There is also a so called "solid container", that KEEPS aspect-ration.

 - ui_container_solid_create(myscreen,width,height,fit_or_fill)
 
 "width" & "height" arguments are "ratio". Based on argument "fit_or_fill" (true/false) it will either scale container to FIT in parenting container, or FILL the parenting container.

//Create element

To create for example buttons, you need to create them as elements.

 - ui_element_create(mycontainer,x_relative,y_relative,type_scale,x_scale,y_scale,object)

x_relative/y_relative is postion in the container (0-1000).
type_scale set's how the object should be scaled 
 - 0 - fit (keep aspect ratio)
 - 1 - fill (keep aspect ratio)
 - 2 - deform_fill (resize to match the container)

//Window resized

For every window_resize you need to recalculate position of the containers:
 - ui_screen_recalculate(myscreen);

or
 - ui_container_recalculate(mycontainer);

Both functions work the same, they update ALL CONTAINERS THAT BELONG TO UPDATED ONE!

For debugging I prepared also similar function, but instead of updating, it draws rectagles.
 - ui_container_draw(myscreen,draw_invisible); //draw_invisible (true/false) = Should it draw invalid or invisible containers?
