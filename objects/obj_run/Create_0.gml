//Create screen
myscreen = ui_screen_create();
ui_screen_visible(myscreen,1);

//Declare containers in myscreen
mycontainer1 = ui_container_create(myscreen,50,50,0,150,0,0,200,0);
mycontainer2 = ui_container_create(myscreen,50,50,-50,150,200,0,1000,0);

//You can stack containers in containers
mycontainer3 = ui_container_create(mycontainer2,10,10,-10,-10,0,0,800,1000);
mycontainer4 = ui_container_create(mycontainer3,10,10,-10,-10,0,0,800,1000);
mycontainer5 = ui_container_create(mycontainer4,10,10,-10,-10,0,0,800,1000);