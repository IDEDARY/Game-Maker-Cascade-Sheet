if(cursor_freeze = false){
	if(_inherit_checkInput_gamepad() = undefined and _raw_cursorMode != UI.mode_gamepad){
		_raw_cursorMode = UI.mode_gamepad;
	} else {
		if(_inherit_checkInput_mouse() = undefined and _raw_cursorMode != UI.mode_mouse){
			_raw_cursorMode = UI.mode_mouse;
			window_mouse_set(x,y);
		};
	};
	switch(_raw_cursorMode){
		case UI.mode_mouse:
			image_index = 0;
			x = window_mouse_get_x();
			y = window_mouse_get_y();
		break;
		case UI.mode_gamepad:
			image_index = 4;
			x += gamepad_axis_value(0, gp_axislh)*8;
			y += gamepad_axis_value(0, gp_axislv)*8;
			x = clamp(x,0,global.screen_width);
			y = clamp(y,0,global.screen_height);
			if(sprite_index = GMCS_sprCursor){window_mouse_set(x,y);};
		break;
	};
};