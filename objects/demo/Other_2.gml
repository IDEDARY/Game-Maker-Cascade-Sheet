//Start GMCS
gmcs_init();
//Declare style
var _style1 = {
	_sprite_reference : [noone, spr_demo_cyberpunk_button],
	_sprite_decoration : [
		gmcs_wrap_decoration({_sprite : spr_demo_cyberpunk_button_deco, _relative : [1000,500], _solid : [-50, 0], _x_scale : 0.7, _y_scale : 0.7}),
	],
	_sprite_alpha : 1,
	_font : fnt_demo_cyberpunk_blender,
	_font_alpha : 1,
	_font_blend : array_create(4,make_color_rgb(243,83,67)),
	_font_halign : fa_left,
	_font_margin : 32,
};

gmcs_cursor_set_image(spr_demo_cyberpunk_cursor);

//Declare containers (div)
_screen = new gmcs_container_screen();

//container = new gmcs_container_relative(_screen,[0,0,0,0],[70,0,310,1000]);
container = new gmcs_container_solid(_screen,[807,1432],[UI.anchor_left,UI.anchor_center],UI.scale_fit)
container._memory_positions[0][2][0] = 0.9;
var _container = new gmcs_container_relative(container,[0,0,0,0],[100,352,900,752]);

logo = new gmcs_container_relative(container,[0,0,0,0],[50,200,950,330]);

//Generate buttons and asign style and text to them
_return = gmcs_grid_generate(_container,1,10,1,7,10,1,1,1);
var text = ["CONTINUE","NEW GAME","LOAD GAME","SETTINGS","ADDITIONAL CONTENT","CREDITS","QUIT GAME"];

for(var i = 0; i < array_length(_return); i++){
	for(var ii = 0; ii < array_length(_return[i]); ii++){
		_return[i][ii]._method_addStyle(_style1);
		_return[i][ii]._info_text = text[i+ii]
	};
};

_screen._method_setVisible(1);
global.gmcs._method_cleanup_render();