image_speed = 0;
image_xscale = 0.4;
image_yscale = 0.4;
gamepad_set_axis_deadzone(0, 0.15);
_raw_input_clicked_primary = 0; //Left click or A button
_raw_input_clicked_secondary = 0;	//Right click or B button

_raw_cursorMode = UI.mode_mouse;
_raw_xmouse = 0;
_raw_ymouse = 0;
_inherit_checkInput_mouse = function(){
	if(abs(window_mouse_get_x()-_raw_xmouse) > 5){_raw_xmouse = window_mouse_get_x();return undefined;};
	if(abs(window_mouse_get_y()-_raw_ymouse) > 5){_raw_ymouse = window_mouse_get_y();return undefined;};
	if(device_mouse_check_button(0,mb_any)){return undefined;};
	return noone;
};
_inherit_checkInput_gamepad = function(){
	if(gamepad_axis_value(0, gp_axislh) != 0){return undefined;};
	if(gamepad_axis_value(0, gp_axislv) != 0){return undefined;};
	if(gamepad_button_check(0,gp_face1)){return undefined;};
	if(gamepad_button_check(0,gp_face2)){return undefined;};
	if(gamepad_button_check(0,gp_face3)){return undefined;};
	if(gamepad_button_check(0,gp_face4)){return undefined;};
	if(gamepad_button_check(0,gp_padd)){return undefined;};
	if(gamepad_button_check(0,gp_padu)){return undefined;};
	if(gamepad_button_check(0,gp_padl)){return undefined;};
	if(gamepad_button_check(0,gp_padr)){return undefined;};
	return noone;
};
cursor_freeze = 0;