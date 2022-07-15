var sc = gmcs_getscale_fill(_screen,2560,1440);
draw_sprite_ext(spr_demo_cyberpunk_background,0,_screen._info_x,_screen._info_y,sc,sc,0,c_white,1);

var sc = gmcs_getscale_fill(container,807,1432);
draw_sprite_ext(spr_demo_cyberpunk_board,0,container._info_x,container._info_y,sc,sc,0,c_white,1);

var sc = gmcs_getscale_fill(logo,681,166);
draw_sprite_ext(spr_demo_cyberpunk_logo_shadow,0,logo._info_x,logo._info_y,sc,sc,0,c_white,1);
draw_sprite_ext(spr_demo_cyberpunk_logo,0,logo._info_x,logo._info_y,sc,sc,0,c_white,1);

//draw_text(100,100, _return[0][0]._animation_styleMerge);