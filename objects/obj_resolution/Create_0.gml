//==============================================
// IGNORE ALL OF THIS - this is just my scaling system which updates
// screen_width and screen_height variables, you can to write your own
// 
// For this to work you need to have enabled viewports in rooms and made the visible, nothing else

if(os_browser = browser_not_a_browser){
	switch(os_type){
		case os_windows: global.screen_type = 0;break;
		case os_linux: global.screen_type = 0;break;
		case os_macosx: global.screen_type = 0;break;
		case os_android: global.screen_type = 1;break;
		case os_winphone: global.screen_type = 1;break;
		case os_ios: global.screen_type = 1;break;
	}
}else{global.screen_type = 2;}

window_width = 1280;
window_height = 720;
window_set_size(window_width,window_height);

switch(global.screen_type){
	case 0: global.screen_width = window_get_width();global.screen_height = window_get_height();break;
	case 1: global.screen_width = display_get_width();global.screen_height = display_get_height();break;
	case 2: global.screen_width = browser_width;global.screen_height = browser_height;break;
}

if(frac(global.screen_width/2) != 0){global.screen_width += -1;}
if(frac(global.screen_height/2) != 0){global.screen_height += -1;}

//WINDOW RESIZE
if(window_width != global.screen_width or window_height != global.screen_height){ //If there is change in window size, resize viewport to match
	window_width = global.screen_width;
	window_height = global.screen_height;
	display_set_gui_size(global.screen_width,global.screen_height);
	surface_resize(application_surface, global.screen_width, global.screen_height);
	
	if(global.screen_type = 2){window_set_size(global.screen_width,global.screen_height);}
	camera_set_view_size(view_camera[0], global.screen_width, global.screen_height);
}