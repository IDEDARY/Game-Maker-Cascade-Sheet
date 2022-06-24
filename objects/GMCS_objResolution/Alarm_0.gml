#region Recalculation
//-------------------------
window_width = global.screen_width;
window_height = global.screen_height;
//-------------------------
display_set_gui_size(global.screen_width,global.screen_height);
surface_resize(application_surface, global.screen_width, global.screen_height);
if(global.screen_type = 2){window_set_size(global.screen_width,global.screen_height);};
camera_set_view_size(view_camera[view_id], global.screen_width, global.screen_height);
//-------------------------
//Trigger GMCS recalculation process
//ui_all_recalculate();
//global.gmcs._method_mark_recalculate(demo._screen);
//-------------------------
#endregion
