//Demo
debug_draw_containers = 0;


//=================================================================================================================
//=================================== CREATE UI ===================================================================

//Create screen
screen_mainMenu = ui_screen_create();

//Set screen's visibility to true (for screens default is false)
ui_screen_visible(screen_mainMenu,true);

//Create container for logo
container_logoRelative = ui_container_create(screen_mainMenu,0,0,0,0,0,-250,1000,0);
container_logoSolid = ui_container_solid_create(container_logoRelative,140,100,0,0);

//Create container for buttons
container_buttonRelative = ui_container_create(screen_mainMenu,0,0,0,0,100,1000,900,1350);
container_buttonSolid = ui_container_solid_create(container_buttonRelative,200,100,0,0);

//Create elements(indexed objects in containers)
button1 = ui_element_create(container_buttonSolid,500,333,0,500,1000,obj_demo_button);
button2 = ui_element_create(container_buttonSolid,500,666,0,500,1000,obj_demo_button);

//Create container for demo info
container_demo = ui_container_create(screen_mainMenu,15,15,0,0,0,0,300,150);

//=================================================================================================================
//=================================== ANIMATE UI ==================================================================
var revealed_position_logo = ui_container_position_add(container_logoRelative,0,0,0,0,0,170,1000,420);
ui_container_animation_set(container_logoRelative,revealed_position_logo);
ui_container_animation_input_set(container_logoRelative,true);
ui_container_animation_speed_set(container_logoRelative, 0.6);

var revealed_position_button = ui_container_position_add(container_buttonRelative,0,0,0,0,100,550,900,900);
ui_container_animation_set(container_buttonRelative,revealed_position_button);
ui_container_animation_input_set(container_buttonRelative,true);
ui_container_animation_speed_set(container_buttonRelative, 0.5);
