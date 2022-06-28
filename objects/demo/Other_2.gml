gmcs_init();
_screen = new gmcs_screen();
var _container = new gmcs_container_relative(_screen,[0,0,0,0],[100,100,900,900]);
container = new gmcs_container_solid(_container,[1,1],[UI.anchor_center, UI.anchor_center],UI.scale_fit);

var _return = gmcs_grid_generate(container,3,5,2,3,5,2,1,1);

for(var i = 0; i < array_length(_return); i++){
	for(var ii = 0; ii < array_length(_return[i]); ii++){
		_return[i][ii]._method_addStyle({_sprite : spr_demo_button_base});
	};
};