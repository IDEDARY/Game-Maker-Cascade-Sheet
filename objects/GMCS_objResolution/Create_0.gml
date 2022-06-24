#region OS hookup
//Detect os in which the app is running...
//-------------------------
//screen_type 0 = Window can be any size or fullscreen (Game window is hooking values from window size)
//screen_type 1 = Window will allways be fullscreen (Game window is hooking values from display size)
//screen_type 2 = Game window is hooking values from browser size
//-------------------------
if(os_browser = browser_not_a_browser){
	switch(os_type){
		
		//Desktop-------------------------
		case os_windows: global.screen_type = 0;break;
		case os_win8native: global.screen_type = 0;break;
		case os_linux: global.screen_type = 0;break;
		case os_macosx: global.screen_type = 0;break;
		
		//Mobile-------------------------
		case os_android: global.screen_type = 1;break;
		case os_winphone: global.screen_type = 1;break;
		case os_ios: global.screen_type = 1;break;
		
		//TV-------------------------
		case os_tvos: global.screen_type = 1;break;
		
		//Console-------------------------
		case os_ps3: global.screen_type = 1;break;
		case os_ps4: global.screen_type = 1;break;
		case os_ps5: global.screen_type = 1;break;
		case os_psvita: global.screen_type = 1;break;
		case os_switch: global.screen_type = 1;break;
		case os_xboxone: global.screen_type = 1;break;
		case os_xboxseriesxs: global.screen_type = 1;break;
		
		//Special-------------------------
		case os_operagx: global.screen_type = 2;break;
		case os_uwp: global.screen_type = 1;break;
		
		//Default-------------------------
		default: global.screen_type = 1;break;
	};
}else{global.screen_type = 2;};
#endregion
//-------------------------
#region Window Init
//-------------------------
view_id = 0;
camera = view_camera[view_id];
//-------------------------
window_width = 1280;
window_height = 720;
//-------------------------
window_set_size(window_width,window_height);
room_set_viewport(room, 0, true, 0, 0, window_width, window_height);
camera_set_view_size(camera,window_width,window_height);
if(global.screen_type = 0){
	window_set_position(display_get_width()/2 - window_width/2,display_get_height()/2 - window_height/2);
} else {
	window_set_position(0,0);
};
//-------------------------
#endregion
//-------------------------
global.screen_width = window_width;
global.screen_height = window_height;
//-------------------------
