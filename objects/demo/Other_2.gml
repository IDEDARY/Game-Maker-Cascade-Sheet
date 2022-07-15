gmcs_init();

var _style1 = gmcs_create_globalStyle({
	_surface_reference : [noone, spr_demo_cyberpunk_button],
	_surface_decoration : [
		gmcs_wrap_decoration({_sprite : spr_demo_cyberpunk_button_deco, _relative : [1000,500], _solid : [-50, 0], _x_scale : 0.7, _y_scale : 0.7}),
	],
	_surface_alpha : 0,
	_font : fnt_demo_cyberpunk_blender,
	_font_alpha : 1,
	_font_blend : array_create(4,make_color_rgb(243,83,67)),
	_font_halign : fa_left,
	_font_margin : 32,
});
var _style2 = gmcs_create_globalStyle({
	_surface_reference : [noone, spr_demo_cyberpunk_button],
	_surface_decoration : [
		gmcs_wrap_decoration({_sprite : spr_demo_cyberpunk_button_deco, _relative : [1000,500], _solid : [-50, 0], _x_scale : 0.7, _y_scale : 0.7}),
	],
	_surface_alpha : 0.7,
	_font : fnt_demo_cyberpunk_blender,
	_font_alpha : 1,
	_font_blend : array_create(4,make_color_rgb(243,83,67)),
	_font_halign : fa_left,
	_font_margin : 32,
});
gmcs_cursor_set_image(spr_demo_cyberpunk_cursor);


_screen = new gmcs_container_screen();

container = new gmcs_container_solid(_screen,[807,1432],[UI.anchor_left,UI.anchor_center],UI.scale_fit)
container._memory_positions[0][2][0] = 0.9;
var __container = new gmcs_container_relative(container,[0,0,0,0],[100,352,900,752]);

logo = new gmcs_container_relative(container,[0,0,0,0],[50,200,950,330]);

_return = gmcs_grid_generate(__container,1,10,1,7,10,1,1,1);

var func_in = function(_self){
	_self._animation_trigger = true;
};
var func_out = function(_self){
	_self._animation_trigger = false;
};
var func_quit = function(_self){
	_self._animation_trigger = true;
	if(mouse_check_button_pressed(mb_any)){game_end();};
};
	
var text = ["CONTINUE","NEW GAME","LOAD GAME","SETTINGS","ADDITIONAL CONTENT","CREDITS","QUIT GAME"];
var funcs = [func_in,func_in,func_in,func_in,func_in,func_in,func_quit];


for(var i = 0; i < array_length(_return); i++){
	for(var ii = 0; ii < array_length(_return[i]); ii++){
		global.gmcs._inherit_add_position_solid_from(_return[i][ii],0,["5","0","5","0"],["0","0","0","0"]);
		_return[i][ii]._render_text = text[i+ii];
		
		gmcs_add_localStyle(_return[i][ii],_style1);
		gmcs_add_localStyle(_return[i][ii],_style2);
		
		gmcs_add_animation(_return[i][ii],{
			_end_position : 1,
			_end_style : 1,
			_pesistent : true,
			_interrupt : -1,
			_duration : 10,
		});
		gmcs_call_animation(_return[i][ii], 0);
		
		gmcs_set_interaction(_return[i][ii],funcs[i+ii],func_out);
	};
};

_screen._method_setVisible(1);
global.gmcs._method_flush_render();
global.gmcs._method_flush_interaction();
global.gmcs._method_flush_animation();