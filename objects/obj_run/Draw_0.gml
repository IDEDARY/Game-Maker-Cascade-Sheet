ui_container_draw(myscreen,true);

//Draw FPS in the middle of container1
draw_set_halign(fa_center);
draw_set_valign(fa_center);
draw_text(mycontainer1.x,mycontainer1.y,fps_real);