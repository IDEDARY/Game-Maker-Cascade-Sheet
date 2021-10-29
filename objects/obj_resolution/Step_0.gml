//==============================================
// IGNORE ALL OF THIS - this is just my scaling system which updates
// screen_width and screen_height variables, you can to write your own
// 
// For this to work you need to have enabled viewports in rooms and made the visible, nothing else

//screen_type 0 = windows
//screen_type 1 = android
//screen_type 2 = browser

if(keyboard_check_pressed(vk_f11) = 1){
	if(window_get_fullscreen() = true & global.screen_type = 0){
		window_set_fullscreen(false);
	}else{
		window_set_fullscreen(true);
	}
}

switch(global.screen_type){
	case 0: global.screen_width = window_get_width();global.screen_height = window_get_height();break;
	case 1: global.screen_width = display_get_width();global.screen_height = display_get_height();break;
	case 2: global.screen_width = browser_width;global.screen_height = browser_height;break;
}

if(frac(global.screen_width/2) != 0){global.screen_width += -1;}
if(frac(global.screen_height/2) != 0){global.screen_height += -1;}

//WINDOW RESIZE
if((window_width != global.screen_width or window_height != global.screen_height)&&(global.screen_width !=0 && global.screen_height !=0)){ //If there is change in window size, resize viewport to match
	window_width = global.screen_width;
	window_height = global.screen_height;
	display_set_gui_size(global.screen_width,global.screen_height);
	surface_resize(application_surface, global.screen_width, global.screen_height);
	
	if(global.screen_type = 2){window_set_size(global.screen_width,global.screen_height);}
	camera_set_view_size(view_camera[0], global.screen_width, global.screen_height);
	
	//=============================================================================================================
	script_called_windowResize();
	//=============================================================================================================
	
}