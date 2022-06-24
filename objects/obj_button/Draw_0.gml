draw_sprite_ext(button.info.sprite,0,x,y,scale,scale,0,c_white,1);
draw_set_halign(fa_center);
draw_set_valign(fa_center);
draw_text_transformed(x,y,button.interactive.display_text,scale,scale,0);

//draw_rectangle(x-button.info.width/2,y-button.info.height/2,x+button.info.width/2,y+button.info.height/2,3);