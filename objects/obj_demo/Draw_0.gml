draw_set_halign(fa_center);
draw_set_valign(fa_center);

//Draw background
var xscale = ui_get_scale_for_xfullfill(screen_mainMenu,64); //sprite_width of the image
var yscale = ui_get_scale_for_yfullfill(screen_mainMenu,64); //sprite_height of the image
draw_sprite_ext(b_back,0,screen_mainMenu.x,screen_mainMenu.y,xscale,yscale,0,image_blend,0.5);
var scale = ui_get_scale_for_fill(screen_mainMenu,699,700); //sprite_width & sprite_height of the image
draw_sprite_ext(b_middle,0,screen_mainMenu.x,screen_mainMenu.y,scale,scale,0,image_blend,0.5);
var scale = ui_get_scale_for_fill(screen_mainMenu,1120,700); //sprite_width & sprite_height of the image
draw_sprite_ext(b_front,0,screen_mainMenu.x,screen_mainMenu.y,scale,scale,0,image_blend,0.5);


//Draw Logo
if(container_logoSolid.visible){ 
	var xscale = ui_get_scale_for_xfullfill(container_logoSolid,100); //sprite_width of the image
	var yscale = ui_get_scale_for_yfullfill(container_logoSolid,100); //sprite_height of the image
	draw_sprite_ext(panel_brown,0,container_logoSolid.x,container_logoSolid.y,xscale,yscale,0,image_blend,image_alpha);
	draw_text_transformed(container_logoSolid.x, container_logoSolid.y,"LOGO",xscale,yscale,0);
}

//Draw Button container image
if(container_buttonSolid.visible){ 
	var xscale = ui_get_scale_for_xfullfill(container_buttonSolid,100); //sprite_width of the image
	var yscale = ui_get_scale_for_yfullfill(container_buttonSolid,100); //sprite_height of the image
	draw_sprite_ext(panel_blue,0,container_buttonSolid.x,container_buttonSolid.y,xscale,yscale,0,image_blend,image_alpha);
}


//Draw Demo Debug in the container_demo
var text_scale = ui_get_scale_for_fit(container_demo,400,100) //Real resolution of the drawn text;
draw_text_transformed(container_demo.x, container_demo.y1 + container_demo.height/5,fps_real,text_scale,text_scale,0);
draw_text_transformed(container_demo.x, container_demo.y1 + container_demo.height/5*2, "Press 'Space' for Logo visibility toggle",text_scale,text_scale,0);
draw_text_transformed(container_demo.x, container_demo.y1 + container_demo.height/5*3, "Press 'Enter' for Window resize",text_scale,text_scale,0);
draw_text_transformed(container_demo.x, container_demo.y1 + container_demo.height/5*4, "Press 'Q' for container visibility toggle",text_scale,text_scale,0);

//Draw containers
if(debug_draw_containers) ui_container_draw(screen_mainMenu,true);