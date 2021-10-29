debug_draw_containers = 0;


//Create screen
screen_mainMenu = ui_screen_create();

//Set screen's visibility to true (for screens default is false)
ui_screen_visible(screen_mainMenu,true);

//Create container for logo
container_logoRelative = ui_container_create(screen_mainMenu,0,0,0,0,0,170,1000,420);
container_logoSolid = ui_container_solid_create(container_logoRelative,140,100,0);

//Create container for buttons
container_buttonRelative = ui_container_create(screen_mainMenu,0,0,0,0,100,550,900,900);
container_buttonSolid = ui_container_solid_create(container_buttonRelative,200,100,0);

//Create elements(indexed objects in containers)
button1 = ui_element_create(container_buttonSolid,500,333,0,500,1000,obj_demo_button);
button2 = ui_element_create(container_buttonSolid,500,666,0,500,1000,obj_demo_button);

//Create container for demo info
container_demo = ui_container_create(screen_mainMenu,15,15,0,0,0,0,300,150);