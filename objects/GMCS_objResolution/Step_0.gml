#region Fullscreen switch
//-------------------------
if(keyboard_check_pressed(vk_f11)){
	if(global.screen_type != 1){window_set_fullscreen(!window_get_fullscreen());};
};
//-------------------------
#endregion
//-------------------------
#region Resize GMCS if window was resized
//-------------------------
switch(global.screen_type){
	case 0: global.screen_width = window_get_width();global.screen_height = window_get_height();break;
	case 1: global.screen_width = display_get_width();global.screen_height = display_get_height();break;
	case 2: global.screen_width = browser_width;global.screen_height = browser_height;break;
};
//-------------------------
if((window_width != global.screen_width or window_height != global.screen_height)&&(global.screen_width !=0 && global.screen_height !=0)){
	event_perform(ev_alarm,0);
};
//-------------------------
#endregion
