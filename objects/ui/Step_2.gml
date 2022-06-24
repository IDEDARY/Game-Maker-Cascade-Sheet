/*
if((mouse_check_button_pressed(mb_left) = 1 or mouse_check_button_pressed(mb_right) = 1 or ev_global_gesture_tap = 1) and position_meeting(mouse_x,mouse_y,obj_button) = false){
	button_current_selected = noone;
	keyboard_virtual_hide();
	keyboard_string = "";
};*/

//ui_process_interactive();
//ui_process_animation();
ui_process_recalculate();
//ui_process_rebake();