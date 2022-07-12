//Start GMCS
gmcs_init();
//Declare style
var _style1 = {
	_sprite_reference : [noone, spr_demo_cyberpunk_button],
	_sprite_decoration : [
		gmcs_wrap_decoration({_sprite : spr_demo_cyberpunk_button_deco, _relative : [1000,500], _solid : [-50, 0], _x_scale : 1, _y_scale : 1}),
		//gmcs_wrap_decoration({_sprite : spr_demo_button_deco2, _relative : [0,0], _x_scale : 2, _y_scale : 2, _x_mirror : 1, _y_mirror : 1}),
		//gmcs_wrap_decoration({_sprite : spr_demo_button_deco3, _relative : [0,500], _x_scale : 2, _y_scale : 2, _x_mirror : 1}),
	],
	_font : fnt_demo_cyberpunk_blender,
	_font_alpha : 1,
	_font_blend : array_create(4,make_color_rgb(243,83,67)),
};

//Declare containers (div)
_screen = new gmcs_container_screen();
//_screen._method_setVisible(!_screen._info_visible);

container = new gmcs_container_relative(_screen,[0,0,0,0],[100,100,900,900]);
//add_postion(container,0,["0","0","0","0"],["0","100","0","0"]);
//container._animation_positionIndex[1]=1;

//Generate buttons and asign style and text to them
_return = gmcs_grid_generate(container,1,5,1,3,1,1,0,1);
var text = ["CONTINUE","NEW GAME","LOAD GAME","SETTINGS","ADDITIONAL CONTENT","CREDITS","QUIT GAME"];

for(var i = 0; i < array_length(_return); i++){
	for(var ii = 0; ii < array_length(_return[i]); ii++){
		_return[i][ii]._method_addStyle(_style1);
		_return[i][ii]._info_text = text[i+ii]
	};
};