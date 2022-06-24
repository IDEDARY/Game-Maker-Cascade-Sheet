//=========================================================================================
//==================================== PRESSING ===========================================
var temp_pressed = button.input.mouse_pressed;

button.input.mouse_pressed = 0;
button.input.mouse_enter = 0;
button.input.mouse_left = 0;
button.input.mouse_right = 0;

if(visible=0)exit;

if(position_meeting(mouse_x, mouse_y, id)=true){button.input.mouse_enter = 1;};
if(button.input.mouse_enter){
	if(mouse_check_button_pressed(mb_left)){button.input.mouse_pressed = 1;button.input.mouse_left = 1;};
	if(mouse_check_button_pressed(mb_right)){button.input.mouse_pressed = 1;button.input.mouse_right = 1;};
};

if(ev_gesture_tap){button.input.mouse_pressed = 1;}

if(ui.button_current_selected = id){ui.button_previous_selected = id;}
if(temp_pressed = 0 && button.input.mouse_pressed = 1){
	ui.button_previous_selected = ui.button_current_selected;
	ui.button_current_selected = id;
	keyboard_string = "";
	if(button.interactive.enable_textbox = true){
		keyboard_virtual_show(kbv_type_default, kbv_returnkey_default, kbv_autocapitalize_none, false);
	};
};

//=========================================================================================
//==================================== SCALING ============================================

button.scale.trigger = button.input.mouse_enter;

scale_base = 1;
button.scale.change += 10*power(-1,!button.scale.trigger);
button.scale.change = clamp(button.scale.change,0,90);
scale = scale_base + scale_base*dsin(button.scale.change)*button.scale.increase;

if(button.info.unique_style = UI.style_custom){
	image_xscale = scale*sprite_get_width(button.info.sprite)/2;
	image_yscale = scale*sprite_get_height(button.info.sprite)/2;
};
if(button.info.unique_style = UI.style_cached){
	image_xscale = scale*button.info.width/2;
	image_yscale = scale*button.info.height/2;
};
