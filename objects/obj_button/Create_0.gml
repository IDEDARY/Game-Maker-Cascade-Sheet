//=========================================================================================
sprite_index = ui.ui_spr_point2x2;
button = {
	info : {
		width : 1,
		height : 1,
		sprite : ui.ui_spr_point2x2,
		unique_style : UI.style_cached,
		style : 0,
	},
	input : {
		mouse_pressed : 0,
		mouse_enter : 0,
		mouse_left : 0,
		mouse_right : 0,
	},
	scale : {
		trigger : 0,
		change : 0,
		increase : 0.2,
		scale : 1,
	},
	interactive : {
		value : "",
		display_text : "Default",
		enable_textbox : 0,
	},
};
//=========================================================================================
event_user(0);