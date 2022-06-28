//======================================================================================================================================
//======================================================================================================================================
//--------------------------------------- GameMakerCascadeSheet (GMCS) by Dominik Kaspar -----------------------------------------------
//
// Lightweight replacement for completely absent UI system in GMS2. Handles resolution scaling, user-friendly container defining,
// move-able & drag-able windows, animated containers, custom styles and images, grid generating and more!
//
// I focused to make this library as optimized as possible, but with all that fancy stuff and animations, it's not easy.
// If you have any questions or advices for improvements, reach out to me on Discord! 1DEDARY#1307
//
// Github repository: https://github.com/IDEDARY/Game-Maker-Cascade-Sheet
// Published under MIT license.
// Version 5.0
//
//TODO: get position from grid, animations for solid containers,
//Drag-able windows (can or cannot be resized???)
//Canvas for containers (surfaces)
//======================================================================================================================================
//===================================================== DEPENDENCIES ===================================================================
#region DEPENDENCIES
// Everything that needs to done so this can work.
// -----
// 1) Game options > allow window resize == true
// 2) Game options > scaling == full scale (optional, but it looks better)
// 3) Game options > allow fullscreen switching == true (optional)
// 4) global.screen_width & global.screen_height needs to be declared before working with GMCS. It can be solved by just dragging obj_resolution
//    to the room, but if you use your own object to manage window scaling and viewports, this needs to be done.
// 5) in case you use obj_resolution, you need to enable in room settings first viewport and make it visible. Make sure to set camera width and height
//    to the same numbers as width and height of the viewport.
//-----
#endregion
//======================================================================================================================================
//===================================================== DECLARE FUNCTIONS ==============================================================
#region FUNC
//These are inner working functions that are not supposed to be touched by user. TLDR: Don't touch anything that has in name "func" = inner function (applies to arrays and structs as well)

function ui_func_memory_visible_add(container){
	var index = array_length(ui.global_inventory.active_screens);
	ui.global_inventory.active_screens[index] = container;
	return index;
};
function ui_func_memory_visible_remove(index){
	array_delete(ui.global_inventory.active_screens,index,1);
};

function ui_func_declare_ui(){
	if (!variable_global_exists("ui")) {
        var obj = instance_create_depth(0, 0, 0, ui);
        global.ui = obj;
        with(obj) {
			
			/////////////////////////////
			//Generate empty white sprite
			var surface_point = surface_create(1, 1);
			surface_set_target(surface_point);
			draw_clear_alpha(c_white,1);
			surface_reset_target();
			ui_spr_point = sprite_create_from_surface(surface_point, 0, 0, 1, 1, false, false, 0, 0);
			surface_free(surface_point);
			
			/////////////////////////////
			//Generate empty white 2x2 centered sprite
			var surface_point = surface_create(2, 2);
			surface_set_target(surface_point);
			draw_clear_alpha(c_white,1);
			surface_reset_target();
			ui_spr_point2x2 = sprite_create_from_surface(surface_point, 0, 0, 2, 2, false, false, 1, 1);
			surface_free(surface_point);

			/////////////////////////////
			
			global_inventory = {
				containers : [],
				canvas : [],
				
				active_screens : [],

				containers_to_interact:[],
				containers_to_animate:[],
				containers_to_rebake:[],
				containers_to_recalculate:[],
				screens_to_recalculate:[],
				
			};
            button_previous_selected = noone;
            button_current_selected = noone;
        };
    };
};

function ui_func_declare_container() {
    var _index = array_length(ui.global_inventory.containers);
    ui.global_inventory.containers[_index] = {
		
		ui_processing : {									////--Inner workings for scripts (DON'T TOUCH!)--\\\\
			_recalculated : false,							//Was it recalculated this step already?
			_recalculate_reason : "Noone",					//Why is it being recalculated?
			_rebaked : false,
			_rebake_reason : "Noone",
		},
		ui_rebaking : {										////--Settings for style baking--\\\\
			_rebake_when_resized : false,					//Setting - Should it rebake style when resized?
			_rebake_when_animated : false,					//Setting - Should it rebake style while proceeding in animation?
			_rebake_when_created : true,					//Setting - Should it rebake style when created?
			_inclued_in_layerbake : true,					//Setting - Should it be inclued in layer baking? (Animating the container will turn this off)
		},
		ui_info : {											////--Basic values and settings--\\\\
			_index : _index,								//Read-only - Index number of the container
			_screen : noone,								//Read-only - To which screen this container belongs
			_parent : noone,								//Read-only - To which container this container belongs
			_layer : 0,										//Read-only - In which layer this container is
			_depth : 0,										//Read-only - In which depth should the container be rendered in
			_type : UI.type_screen,							//Read-only - Which type is it (type_solid, type_relative, type_screen, type_window)
			
			x_offset : 0,									//Setting - X offset the inner grid (will move all inventory with xx_solid by this amount)
			y_offset : 0,									//Setting - Y offset the inner grid (will move all inventory with yy_solid by this amount)
			zoom : 1,										//Setting - The zoom of the inner grid (will multiply nn_solid by this amount)
			//crop_elements : 0,		Not implemented		//Setting - Everything outside of the container will get cropped (Limited surface)
			//limited : {				Not implemented		//Setting - (Type_window only) - if it can be dragged outside of the parenting container
			//	enable : false,
			//	solid : [0,0,0,0],							// [top, bottom, left, right] - How much can the window be dragged outside of the parenting container (0 - width/height)
			//	relative : [0,0,0,0],						// [top, bottom, left, right] - How much can the window be dragged outside of the parenting container (0 - 1000)
			//},
			
			x1 : 0,											//Read-only - Top left X coordinate of the container
			y1 : 0,											//Read-only - Top left Y coordinate of the container
			x2 : 0,											//Read-only - Bottom right X coordinate of the container
			y2 : 0,											//Read-only - Bottom right Y coordinate of the container
			width : 0,										//Read-only - Width of the container
			height : 0,										//Read-only - Height of the container
			visible : 1,									//Read-only - Visibility of the container

		},
		ui_inventory : {
	        containers: [],									//Stores all containers inside of the container
	        elements: [],									//Stores all objects that have been created inside of the container
	        positions: [],									//Stores multiple defined positions to later animate container
			styles: [{
				version : 0,
				style : 0,									//Index of the style that we want to use when baking sprites
				image : noone,								//Image that is passed to the container instead of style
				image_scale : UI.scale_fill,				//How it should scale the image????????
				bonus_scale : 1,							//Just relative bunus scale
				unique_style : UI.style_custom,				//Should it generate image from style or use given image?
			}],
			chains: [],										// {container : container, position: [0,1]} - from, to
		},
		ui_style : {
			style_current: 0,
		},
		ui_visibility : {
			_parent : 1,										//Parent container visibility
			itself : 0,										//True/false if it should be visible
			valid : 0,										//If the container is valid (width of height is not negative);
		},
		ui_animation : {
			position_real : 0,		//Index of the actual position inside ui_inventory
			position_pseudo : 0,	//Only 0 or 1
			position_target : 0,	//Position we are moving into
			position : [0,0], 
			steady : 1,				//If it finished the animation and does not receive input
			rest : 0,				//If it is not moving
			merge : 0,
			percantage : 0,
			inversion : 1,
			
			frozen : 0,
			paused : 0,
		},
		ui_input : {
			mouse_enter : false,
			mouse_click : false,
			mouse_left : false,
			mouse_right : false,
		},
		ui_trigger : {
			animation : false,
		},
		ui_temp_memory : {
			trigger: {
				animation : 0,
			},
			rest : 0,
			value : 0,
			display_text : "",
			active_index : noone,
		},
    };
    return ui.global_inventory.containers[_index];
};

function ui_func_declare_canvas(container_index, _depth) {
    var _index = array_length(ui.global_inventory.canvas);
    var i = 0;
    var found = false;
    repeat(_index) {
        if (ui.global_inventory.canvas[i].depth = _depth) {
            found = true;
            var found_id = i;
			break;
        };
        i++;
    };

    if (found = true) {
        var i = array_length(ui.global_inventory.canvas[found_id].canvas_container);
        ui.global_inventory.canvas[found_id].canvas_container[i] = container_index;
    } else {
        ui.global_inventory.canvas[_index] = instance_create_depth(0, 0, _depth, obj_ui_canvas);
        ui.global_inventory.canvas[_index].canvas_container[0] = container_index;
    };
};
	
function ui_func_container_recalculate(container) {
//Recalculates selected container (Done automatically)
//------------------------
// container == Target container.
//------------------------
    if (container.ui_info._type = UI.type_relative) {
        with(container) {
            var xsc = (ui_info._parent.ui_info.width) / 1000; //Takes current real width
            var ysc = (ui_info._parent.ui_info.height) / 1000; //Takes current real height

            //Calculate VECTORS
			var x1_vector_1 = (ui_inventory.positions[ui_animation.position[0]].x1_solid + ui_info._parent.ui_info.x_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[0]].x1_relative * xsc;
            var y1_vector_1 = (ui_inventory.positions[ui_animation.position[0]].y1_solid + ui_info._parent.ui_info.y_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[0]].y1_relative * ysc;
            var x2_vector_1 = (ui_inventory.positions[ui_animation.position[0]].x2_solid + ui_info._parent.ui_info.x_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[0]].x2_relative * xsc;
            var y2_vector_1 = (ui_inventory.positions[ui_animation.position[0]].y2_solid + ui_info._parent.ui_info.y_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[0]].y2_relative * ysc;
			
            var x1_vector_2 = (ui_inventory.positions[ui_animation.position[1]].x1_solid + ui_info._parent.ui_info.x_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[1]].x1_relative * xsc;
            var y1_vector_2 = (ui_inventory.positions[ui_animation.position[1]].y1_solid + ui_info._parent.ui_info.y_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[1]].y1_relative * ysc;
            var x2_vector_2 = (ui_inventory.positions[ui_animation.position[1]].x2_solid + ui_info._parent.ui_info.x_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[1]].x2_relative * xsc;
            var y2_vector_2 = (ui_inventory.positions[ui_animation.position[1]].y2_solid + ui_info._parent.ui_info.y_offset)*ui_info._parent.ui_info.zoom + ui_inventory.positions[ui_animation.position[1]].y2_relative * ysc;

            ui_info.x1 = ui_info._parent.ui_info.x1 + x1_vector_1 + (x1_vector_2 - x1_vector_1) * ui_animation.merge;
            ui_info.y1 = ui_info._parent.ui_info.y1 + y1_vector_1 + (y1_vector_2 - y1_vector_1) * ui_animation.merge;
            ui_info.x2 = ui_info._parent.ui_info.x1 + x2_vector_1 + (x2_vector_2 - x2_vector_1) * ui_animation.merge;
            ui_info.y2 = ui_info._parent.ui_info.y1 + y2_vector_1 + (y2_vector_2 - y2_vector_1) * ui_animation.merge;

            ui_info.width = ui_info.x2 - ui_info.x1;
            ui_info.height = ui_info.y2 - ui_info.y1;
            ui_info.x = ui_info.x1 + ui_info.width / 2;
            ui_info.y = ui_info.y1 + ui_info.height / 2;

            ui_container_visible(self, ui_visibility.itself);
        };
    } else {
		if (container.ui_info._type = UI.type_solid) {
	        with(container) {
	            ui_info.width_ratio = ui_inventory.positions[ui_animation.position_real].width_ratio;
	            ui_info.height_ratio = ui_inventory.positions[ui_animation.position_real].height_ratio;
	            ui_info.scale_type = ui_inventory.positions[ui_animation.position_real].scale_type;

	            if (ui_info.scale_type = UI.scale_fit) {
	                var sc = ui_draw_getscale_fit(container.ui_info._parent, ui_info.width_ratio, ui_info.height_ratio);
	            } else {
	                var sc = ui_draw_getscale_fill(container.ui_info._parent, ui_info.width_ratio, ui_info.height_ratio);
	            };
			
	            ui_info.x1 = ui_info._parent.ui_info.x - ui_info.width_ratio * sc / 2;
	            ui_info.y1 = ui_info._parent.ui_info.y - ui_info.height_ratio * sc / 2;
	            ui_info.x2 = ui_info._parent.ui_info.x + ui_info.width_ratio * sc / 2;
	            ui_info.y2 = ui_info._parent.ui_info.y + ui_info.height_ratio * sc / 2;
	            ui_info.width = ui_info.x2 - ui_info.x1;
	            ui_info.height = ui_info.y2 - ui_info.y1;
	            ui_info.x = ui_info._parent.ui_info.x;
	            ui_info.y = ui_info._parent.ui_info.y;
			
				switch(ui_inventory.positions[ui_animation.position_real].x_anchor){
					case UI.anchor_left:
						var c = (ui_info._parent.ui_info.x1 - ui_info.x1)*ui_inventory.positions[ui_animation.position_real].x_anchor_offset;
						ui_info.x += c;
						ui_info.x1 += c;
						ui_info.x2 += c;
						break;
					case UI.anchor_right:
						var c = (ui_info._parent.ui_info.x1 - ui_info.x1)*ui_inventory.positions[ui_animation.position_real].x_anchor_offset;
						ui_info.x -= c;
						ui_info.x1 -= c;
						ui_info.x2 -= c;
						break;
				};
			
				switch(ui_inventory.positions[ui_animation.position_real].y_anchor){
					case UI.anchor_bottom:
						var c = (ui_info._parent.ui_info.y1 - ui_info.y1)*ui_inventory.positions[ui_animation.position_real].y_anchor_offset;
						ui_info.y -= c;
						ui_info.y1 -= c;
						ui_info.y2 -= c;
						break;
					case UI.anchor_top:
						var c = (ui_info._parent.ui_info.y1 - ui_info.y1)*ui_inventory.positions[ui_animation.position_real].y_anchor_offset;
						ui_info.y += c;
						ui_info.y1 += c;
						ui_info.y2 += c;
						break;
				};
			
	            ui_container_visible(self, ui_visibility.itself);
			
	        };
	    };
	};
	container.ui_processing._recalculated = true;
	if(container.ui_inventory.styles[container.ui_style.style_current].unique_style = UI.style_cached){ui_process_rebake_add(container);};
};
	
function ui_func_screen_recalculate(screen) {
//Recalculates the screen (Done automatically)
//------------------------
// screen == The container.
//------------------------
    with(screen) {
        ui_info.x2 = global.screen_width;
        ui_info.y2 = global.screen_height;
        ui_info.width = ui_info.x2;
        ui_info.height = ui_info.y2;
        ui_info.x = ui_info.width / 2;
        ui_info.y = ui_info.height / 2;
        ui_screen_visible(self, ui_visibility.itself);
    };
};
	
function ui_func_container_rebake(container,style){
//Rebakes sprite of a container. !! SHOULD NOT BE DONE EVERY STEP. EXTREMLY SLOW !! Use it only in create-like events, or don't use it at all, its automatic either way.
//------------------------
// container == Target container.
// style == Index of the style that you want to use.
//------------------------
	if(container.ui_inventory.styles[container.ui_style.style_current].unique_style = UI.style_cached){
		sprite_delete(container.ui_inventory.styles[container.ui_style.style_current].image);
		var bake = ui_cache_style_to_sprite(style,container.ui_info.width,container.ui_info.height);
		container.ui_inventory.styles[container.ui_style.style_current].image = bake.sprite;
		container.ui_inventory.styles[container.ui_style.style_current].bonus_scale = bake.bonus_scale;
		container.ui_processing._rebaked = true;
	};
};
	
function ui_func_container_position_settings(container, position, _spd,_curve_index,_finish_unpause,_return_if_done){
//Will set these variables to the global_inventory, part of ui_container_animation_position_settings
//------------------------
	with(container.ui_inventory.positions[position]){
		curve_index = _curve_index;
		finish_unpause = _finish_unpause;
		_speed = _spd;
		return_if_done = _return_if_done;
	};
};
#endregion
//======================================================================================================================================
//===================================================== SCREEN FUNCTIONS ===============================================================
#region SCREENS
//Screens are containers with the size of the window. If you want to start, make sure you have done dependencies, and then use this function.
function ui_screen_create(_depth) {
//Creates a container with the size of the current window
//------------------------
// _depth == At which depth it should be created (Use someting like -300)
//------------------------
    ui_func_declare_ui();
    var container = ui_func_declare_container();
    container.ui_info._depth = _depth;
	container.ui_info.screen_x_position = 0;
	container.ui_info.screen_y_position = 0;
	ui_process_recalculate_screen_add(container);
    ui_func_declare_canvas(container.ui_info._index, container.ui_info._depth);
	return container;
};

function ui_screen_visible(screen, visibility) {
//Set visibility to the screen
//------------------------
// screen == The container.
// visibility == True/false
//------------------------
    with(screen) {
        ui_visibility.itself = visibility;
        ui_visibility.valid = sign(ui_info.width * ui_info.height);
        if (ui_visibility.itself + ui_visibility.valid = 2) {
            ui_info.visible = true;

			if(ui_temp_memory.active_index=noone){ui_temp_memory.active_index = ui_func_memory_visible_add(self);};
        } else {
            ui_info.visible = false;
			if(ui_temp_memory.active_index!=noone){ui_func_memory_visible_remove(ui_temp_memory.active_index);};
        };
        //LOOP------------------------------------------
        var n = array_length(ui_inventory.containers);
        var i = 0;
        repeat(n) {
            ui_container_visible(ui_inventory.containers[i], ui_visibility.itself);
            i++;
        };
    };
};
	
function ui_screen_move(screen, x_position, y_position){
//This will update x and y coordinate of the screen (usefull for HUDs that have elements in them.)
	screen.ui_info.screen_x_position = x_position;
	screen.ui_info.screen_y_position = y_position;
};

#endregion
//======================================================================================================================================
//=================================================== CONTAINER FUNCTIONS ==============================================================
#region CONTAINERS

function ui_container_create(_parent, x1_solid, y1_solid, x2_solid, y2_solid, x1_relative, y1_relative, x2_relative, y2_relative) {
//Creates a container, which size is relative to the parenting container.
//------------------------
// _parent == Outer container.
// xx_solid == Positional value that stays the same no matter the scale of the parenting container.
// xx_relative == Positional value relative to parent. Range from (0 to 1000) with 1000 meaning 100% of the size of parenting container.
//------------------------
    var container = ui_func_declare_container();
    container.ui_info._parent = _parent;
    with(container) {
        ui_info._type = UI.type_relative;
        ui_info._layer = _parent.ui_info._layer + 1;
        ui_visibility.itself = 1;
        ui_info._depth = _parent.ui_info._depth - 5;
    };
    container.ui_inventory.positions[0] = {
        x1_solid: x1_solid,
        y1_solid: y1_solid,
        x2_solid: x2_solid,
        y2_solid: y2_solid,

        x1_relative: x1_relative,
        y1_relative: y1_relative,
        x2_relative: x2_relative,
        y2_relative: y2_relative,
    };
	ui_func_container_position_settings(container,0,1,0,0,0);

    //INDEX CONTAINER TO PARENT ARRAY
    var n = array_length(_parent.ui_inventory.containers);
    _parent.ui_inventory.containers[n] = container;
	ui_process_recalculate_add(container);
    ui_func_declare_canvas(container.ui_info._index, container.ui_info._depth);
    return container;
};

function ui_container_solid_create(_parent, width, height, x_anchor, y_anchor, scale_type) {
//Creates a container, that keeps its proportions. It will not deform not matter what. Will scale to the size of the parenting container.
//------------------------
// _parent == Outer container.
// width/height == Values in ratio, does not matter if 1/2 or 5/10. After all, it will get scaled to fit the _parent.
// x_anchor == Where it should be centered on x axis. Accepts: UI.anchor_nn.
// y_anchor == Where it should be centered on y axis. Accepts: UI.anchor_nn.
// scale_type == How to scale the container. Should it fill or fit the _parent? Accepts: UI.scale_fill, UI.scale_fit. !!!does not accept UI.scale_deform!!!
//------------------------
    var container = ui_func_declare_container();
    container.ui_info._parent = _parent;
    with(container) {
        ui_info._type = UI.type_solid;
        ui_info._layer = _parent.ui_info._layer + 1;
        ui_visibility.itself = 1;
        ui_info._depth = _parent.ui_info._depth - 5;
    };
    container.ui_inventory.positions[0] = {
        scale_type: scale_type,
        x_anchor: x_anchor,
		y_anchor: y_anchor,
		x_anchor_offset : 1,
		y_anchor_offset : 1,
        width_ratio: width,
        height_ratio: height,
    };

    //INDEX CONTAINER TO PARENT ARRAY
    var n = array_length(_parent.ui_inventory.containers);
    _parent.ui_inventory.containers[n] = container;
    ui_process_recalculate_add(container);
    ui_func_declare_canvas(container.ui_info._index, container.ui_info._depth);
    return container;
};

function ui_container_visible(container, visibility) {
//Sets & checks for visibility of the container
//------------------------
// container == Target container.
// visibility == True/False.
//------------------------
    with(container) {
        ui_visibility._parent = ui_info._parent.ui_info.visible;
        ui_visibility.itself = visibility;
        ui_visibility.valid = sign(ui_info.width * ui_info.height);
        if (ui_visibility._parent + ui_visibility.itself + ui_visibility.valid = 3) {
            ui_info.visible = true;
        } else {
            ui_info.visible = false;
        };

        //LOOP------------------------------------------
        var n = array_length(ui_inventory.containers);
        var i = 0;
        repeat(n) {
            ui_container_visible(ui_inventory.containers[i], ui_visibility.itself);
            i++;
        };
        //LOOP------------------------------------------
        var n = array_length(ui_inventory.elements);
        var i = 0;
        repeat(n) {
            ui_inventory.elements[i].visible = ui_info.visible;
            i++;
        };
    };
};

function ui_container_position_create(container, x1_solid, y1_solid, x2_solid, y2_solid, x1_relative, y1_relative, x2_relative, y2_relative) {
//Adds another position to the container. Using animation functions these positions can be swapped later.
//------------------------
// container == Target container.
// xx_solid == Positional value that stays the same no matter the scale of _parent.
// xx_relative == Positional value relative to _parent. Range from (0 to 1000) with 1000 meaning 100% of the size of parenting container.
//------------------------
    var i = array_length(container.ui_inventory.positions)
    container.ui_inventory.positions[i] = {
        x1_solid: x1_solid,
        y1_solid: y1_solid,
        x2_solid: x2_solid,
        y2_solid: y2_solid,

        x1_relative: x1_relative,
        y1_relative: y1_relative,
        x2_relative: x2_relative,
        y2_relative: y2_relative,
    };
	ui_func_container_position_settings(container,i,1,0,0,0);
	
    ui_func_container_recalculate(container);
    return i;
};

function ui_container_position_create_from(container, position, x1_solid, y1_solid, x2_solid, y2_solid, x1_relative, y1_relative, x2_relative, y2_relative) {
//Creates another position from anotherposition of the container. Using animation functions these positions can be swapped later.
//------------------------
// container == Target container.
// position == From which position it should create
// xx_solid == Positional value that stays the same no matter the scale of _parent.
// xx_relative == Positional value relative to _parent. Range from (0 to 1000) with 1000 meaning 100% of the size of parenting container.
// HOW TO USE!! -- If you enter REAL value, it will overwrite it, If you enter STRING value, it will add to it. Ex. "0" for keeping the same value.
//------------------------
if(is_string(x1_solid)){var temp_x1_solid = container.ui_inventory.positions[position].x1_solid+real(x1_solid);}else{var temp_x1_solid = x1_solid;};
if(is_string(x2_solid)){var temp_x2_solid = container.ui_inventory.positions[position].x2_solid+real(x2_solid);}else{var temp_x2_solid = x2_solid;};
if(is_string(y1_solid)){var temp_y1_solid = container.ui_inventory.positions[position].y1_solid+real(y1_solid);}else{var temp_y1_solid = y1_solid;};
if(is_string(y2_solid)){var temp_y2_solid = container.ui_inventory.positions[position].y2_solid+real(y2_solid);}else{var temp_y2_solid = y2_solid;};

if(is_string(x1_relative)){var temp_x1_relative = container.ui_inventory.positions[position].x1_relative+real(x1_relative);}else{var temp_x1_relative = x1_relative;};
if(is_string(x2_relative)){var temp_x2_relative = container.ui_inventory.positions[position].x2_relative+real(x2_relative);}else{var temp_x2_relative = x2_relative;};
if(is_string(y1_relative)){var temp_y1_relative = container.ui_inventory.positions[position].y1_relative+real(y1_relative);}else{var temp_y1_relative = y1_relative;};
if(is_string(y2_relative)){var temp_y2_relative = container.ui_inventory.positions[position].y2_relative+real(y2_relative);}else{var temp_y2_relative = y2_relative;};

    var i = array_length(container.ui_inventory.positions)
    container.ui_inventory.positions[i] = {
        x1_solid: temp_x1_solid,
        y1_solid: temp_y1_solid,
        x2_solid: temp_x2_solid,
        y2_solid: temp_y2_solid,

        x1_relative: temp_x1_relative,
        y1_relative: temp_y1_relative,
        x2_relative: temp_x2_relative,
        y2_relative: temp_y2_relative,
    };
	ui_func_container_position_settings(container,i,1,0,0,0);
    return i;
};

//Animating-----------------------------
function ui_container_animation_set(container, position) {
//By using this function, you will set animation to that position. It still needs to be activated by 'ui_container_animation_input_set' though.
//------------------------
// container == Target container.
// position == Position index to which the container should swap.
//------------------------
    switch (container.ui_animation.position_pseudo) {
        case 0:
            container.ui_animation.position[1] = position;
            container.ui_animation.inversion = 1;
            break;
        case 1:
            container.ui_animation.position[0] = position;
            container.ui_animation.inversion = -1;
            break;
    };
};

function ui_container_animation_position_setting(container, position, speed, curve, unpause, return_if_done){
//Will set some basic values to that position
//------------------------
// container == Target container.
// position == Position index.
// speed == Speed of the animation.
// curve == Index of the curve you want to use in GMCS_smoothing.
// unpause == If it should unpause the input after the animation is done.
// return_if_done == It will be able to go back to starting position even after the animation is done.
//------------------------
	ui_process_animation_add(container);
	ui_func_container_position_settings(container, position, speed, curve, unpause, return_if_done);
};
function ui_container_animation_link(container, container_target, position_trigger, position_target){
//With this you are able to create advanced animations. Once a triggering animation is done, it will trigger animation to targetted position on selected container
//------------------------
// container == Trigger container.
// container_target == Target container.
// position_trigger == Index of the triggering position of the container.
// position_target == Index of the targetted position of the target container
//------------------------
	var i = array_length(container.ui_inventory.chains);
    container.ui_inventory.chains[i] = {
		container : container_target,
		position : [position_trigger,position_target],
	};
};

function ui_container_animation_input_set(container, input) {
//Activate animation.
//------------------------
// container == Target container.
// input == true/false.
//------------------------
    container.ui_trigger.animation = input;
};
function ui_container_animation_input_get(container) {
//Return if animation is active.
//------------------------
// container == Target container.
//------------------------
    return container.ui_trigger.animation;
};
	
function ui_container_animation_pause(container, pause){
//This will pause your input for the animation. With this you can do one click animation instead of hold.
//------------------------
// container == Target container.
// pause == True/false.
//------------------------
	container.ui_temp_memory.trigger.animation = container.ui_trigger.animation;
	container.ui_animation.paused = pause;
};
function ui_container_animation_freeze(container, freeze){
//This will freeze the container in it's current position
//------------------------
// container == Target container.
// freeze == True/false
//------------------------
	container.ui_animation.frozen = freeze;
};
//-----------------------------------------

function ui_container_sprite(container, sprite, scale_type) {
//Give container sprite as background.
//------------------------
// container == Target container.
// sprite == self explanatory.
// scale_type == How to scale the image. Should it fill, fit or deform to fill the container? Accepts: UI.scale_fill, UI.scale_fit, UI.scale_deform
//------------------------
    container.ui_inventory.styles[container.ui_style.style_current].image = sprite;
    container.ui_inventory.styles[container.ui_style.style_current].image_scale = scale_type;
};

//These functions will offset all xx_solid values of the containers that the currrent container stores.
function ui_container_x_offset_set(container,offset) {var temp = container.ui_info.x_offset; container.ui_info.x_offset = offset; if(temp!=offset){ui_process_recalculate_add_all(container);};};
function ui_container_y_offset_set(container,offset) {var temp = container.ui_info.y_offset; container.ui_info.y_offset = offset; if(temp!=offset){ui_process_recalculate_add_all(container);};};
function ui_container_x_offset_add(container,offset) {var temp = container.ui_info.x_offset; container.ui_info.x_offset += offset; if(temp!=temp+offset){ui_process_recalculate_add_all(container);};};
function ui_container_y_offset_add(container,offset) {var temp = container.ui_info.y_offset; container.ui_info.y_offset += offset; if(temp!=temp+offset){ui_process_recalculate_add_all(container);};};

function ui_container_zoom_set(container,zoom) {var temp = container.ui_info.zoom; container.ui_info.zoom = zoom; if(temp!=temp+zoom){ui_process_recalculate_add_all(container);};};
function ui_container_zoom_add(container,zoom) {var temp = container.ui_info.zoom; container.ui_info.zoom += zoom; if(temp!=temp+zoom){ui_process_recalculate_add_all(container);};};

//These functions will edit anchor offset of the solid container (range from 0 - 1).
function ui_container_x_anchor_offset_set(container,_index,offset) {container.ui_inventory.positions[_index].x_anchor_offset = offset;};
function ui_container_y_anchor_offset_set(container,_index,offset) {container.ui_inventory.positions[_index].y_anchor_offset = offset;};
function ui_container_x_anchor_offset_get(container,_index) {return container.ui_inventory.positions[_index].x_anchor_offset;};
function ui_container_y_anchor_offset_get(container,_index) {return container.ui_inventory.positions[_index].y_anchor_offset;};


function ui_container_get_mouse_x(container){return (window_mouse_get_x() - container.ui_info.x1);};
function ui_container_get_mouse_y(container){return (window_mouse_get_y() - container.ui_info.y1);};

#endregion
//======================================================================================================================================
//=================================================== ELEMENTS FUNCTIONS ===============================================================
#region ELEMENTS
//Don't use them, no idea if they work rn
function ui_element_create(container, x_relative, y_relative,type_resize, type_scale, x_scale, y_scale, object) {
//Creates an object, with struct ui_element and indexes it into system.
//------------------------
// container == Outer container.
// x_relative, y_relative == percintile location proportional to the parenting container.
// type_scale == How to scale the container. Should it fill or fit the _parent? Accepts: UI.scale_fill, UI.scale_fit. !!!does not accept UI.scale_deform!!!
//------------------------
    var xsc = (container.ui_info.width) / 1000;
    var ysc = (container.ui_info.height) / 1000;
    var xx = container.ui_info.x1 + x_relative * xsc;
    var yy = container.ui_info.y1 + y_relative * ysc;

    var element = instance_create_depth(xx, yy, container.ui_info._depth, object);
	element.ui_element = {};
    element.ui_element.active = true;
    element.ui_element._layer = container.ui_info._layer;
    element.ui_element.container = container;
    element.ui_element.x_relative = x_relative;
    element.ui_element.y_relative = y_relative;
	element.ui_element.type_resize = type_resize; //Solid - no modular resize, Relative - modular resize when everything is resized
    element.ui_element.scale_type = type_scale;
    element.ui_element.container_x_scale = x_scale; //Relative scale to _parent container
    element.ui_element.container_y_scale = y_scale;
    ui_element_recalculate(element);

    var n = array_length(container.ui_inventory.elements);
    container.ui_inventory.elements[n] = element;

    return element;
};

function ui_element_recalculate(element) {
    with(element) {
        var xsc = (ui_element.container.ui_info.width) / 1000;
        var ysc = (ui_element.container.ui_info.height) / 1000;
        x = ui_element.container.ui_info.x1 + ui_element.x_relative * xsc;
        y = ui_element.container.ui_info.y1 + ui_element.y_relative * ysc;
        var xmod = ui_element.container_x_scale / 1000;
        var ymod = ui_element.container_y_scale / 1000;
		if(ui_element.type_resize = UI.type_solid){
	        switch (ui_element.scale_type) {
	            case UI.scale_fit:
	                x_scale = ui_draw_getscale_fit(ui_element.container, button.info.width, button.info.height) * xmod;
	                y_scale = x_scale * sign(ymod);
	                break;
	            case UI.scale_fill:
	                x_scale = ui_draw_getscale_fill(ui_element.container, button.info.width, button.info.height) * xmod;
	                y_scale = x_scale * sign(ymod);
	                break;
	            case UI.scale_deform:
	                x_scale = ui_element.container.ui_info.width / button.info.width * xmod;
	                y_scale = ui_element.container.ui_info.height / button.info.height * ymod;
	                break;
	        };
		}else{
			button.info.width = ui_element.container.ui_info.width;	
			button.info.height = ui_element.container.ui_info.height;
			//x_scale = ui_element.container.ui_info.width / button.info.width * xmod;
	        //y_scale = ui_element.container.ui_info.height / button.info.height * ymod;
			//event_user(0);
		};
    };
};

function ui_element_sprite_bake(element,style,width,height){
	with(element){
		button.info.unique_style = UI.style_cached;
		button.info.style = style;
		button.info.width = width;
		button.info.height = height;
		event_user(0);
	};
};

function ui_element_sprite_set(element,sprite){
	with(element){
		button.info.unique_style = UI.style_custom;
		button.info.sprite = sprite;
		button.info.width = sprite_get_width(sprite);
		button.info.height = sprite_get_height(sprite);
	};
};

function ui_element_set_height(element,height){
	with(element){
		button.info.height = height;
	};
};

function ui_element_set_width(element,width){
	with(element){
		button.info.width = width;
	};
};
	
function ui_element_rebake(element){
	with(element){
		event_user(0);
	};
};

#endregion
//======================================================================================================================================
//=================================================== DRAW FUNCTIONS ===================================================================
#region DRAW

function ui_draw_rectangle(container, draw_invisible) {
//Draws a rectangle which represents the container.
//------------------------
// container == Target container.
// draw_invisible == True/false if it should draw invalid or invisible containers as well.
//------------------------
    if (container.ui_info.visible = false) {
        if (draw_invisible = false) {
            exit;
        };
        draw_set_color(c_red);
    } else {
        draw_set_color(c_white);
    };
    draw_rectangle(container.ui_info.x1, container.ui_info.y1, container.ui_info.x2-2, container.ui_info.y2-2, 2);
    draw_set_color(c_white);
};

function ui_draw_container(container, draw_invisible) {
//Return if animation is active.
//------------------------
// container == Target container.
//------------------------
    ui_draw_rectangle(container, draw_invisible);
    //LOOP------------------------------------------
    var n = array_length(container.ui_inventory.containers);
    var i = 0;
    repeat(n) {
        ui_draw_container(container.ui_inventory.containers[i], draw_invisible);
        i++;
    };
};

function ui_draw_getscale_fill(container, width, height) {
    var xs = container.ui_info.width / width;
    var ys = container.ui_info.height / height;
    return max(xs, ys);
};

function ui_draw_getscale_fit(container, width, height) {
    var xs = container.ui_info.width / width;
    var ys = container.ui_info.height / height;
    return min(xs, ys);
};

function ui_draw_getscale_xdeform(container, width) {
    var xs = container.ui_info.width / width;
    return xs;
};

function ui_draw_getscale_ydeform(container, height) {
    var ys = container.ui_info.height / height;
    return ys;
};

function draw_sprite_animated(sprite, _index, xx, yy, xscale, yscale, rot, blend, alpha) {
//===== FUNCTION TO DRAW ANIMATED SPRITE === by Dominik Kaspar =========
//
// INDEX = Unique ID of the drawn sprite. Multiple calls of the function
// with the same Index in the same instance will break things up.
//
    var max_frames = sprite_get_number(sprite);
    var framerate = sprite_get_speed(sprite);
    if (!variable_instance_exists(self, "funcvar_draw_sprite_animated")) {
        funcvar_draw_sprite_animated[_index] = 0;
    } else {
        var anim_speed = framerate / room_speed;
        funcvar_draw_sprite_animated[_index] += anim_speed;
        if (floor(funcvar_draw_sprite_animated[_index]) = max_frames + 1) {
            funcvar_draw_sprite_animated[_index] = 0;
        };
    };
    draw_sprite_ext(sprite, floor(funcvar_draw_sprite_animated[_index]), xx, yy, xscale, yscale, rot, blend, alpha);
};

//Sprite generation
function sprite_style_index(style_struct){
	ui_func_declare_ui();
	if(variable_instance_exists(ui,"styles")){var ID = array_length(ui.styles);}else{var ID = 0;ui.styles = [];};
	ui.styles[ID] = style_struct;
	/*
	with(ui.styles[ID]){
		font = [undefined];
		border = [{
			sprite: spr_hud_button_border1,
			x_scale : 1,
			y_scale : 1,
		}];
		
		filler = [{
			sprite: spr_hud_button_base,
			x_scale : 1,
			y_scale : 1,
		}];
		
		content = [
		{
			sprite : spr_hud_button_border1,
			x_relative: 0,
			y_relative : 0,
			x_solid : 0,
			y_solid : 0,
			x_scale : 1,
			y_scale : 1,
			x_mirror : 1,
			y_mirror : 1,
			true_mirror : 1, //Should the direction of the elements be also mirrored?
			rotation: 0,
			blend : c_white,
			alpha : 1,
		}
		];
		
	};//*/
	return ID;
}

function ui_cache_style_to_sprite(style,width,height){
	
	#region Preload
	var _xneg_increase = 0;
	var _yneg_increase = 0;
	var _xpos_increase = 0;
	var _ypos_increase = 0;
	
	var global_inventory = ui.styles[style].content;
	var LoopMax = array_length(global_inventory);
	for(var i = 0; i < LoopMax; i++){
		if(global_inventory[i].sprite = undefined){continue;};
		
		var _x = (global_inventory[i].x_relative/1000)*width+global_inventory[i].x_solid;
		var _y = (global_inventory[i].y_relative/1000)*height+global_inventory[i].y_solid;
		var _w = sprite_get_width(global_inventory[i].sprite)*global_inventory[i].x_scale;
		var _h = sprite_get_height(global_inventory[i].sprite)*global_inventory[i].y_scale;
		var _xo = sprite_get_xoffset(global_inventory[i].sprite)*global_inventory[i].x_scale;
		var _yo = sprite_get_yoffset(global_inventory[i].sprite)*global_inventory[i].y_scale;
		
		////////////////////////
		
		var _c1 = _x - _xo; //True negative location
		if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
		var _c2 = ((_x - _xo)+_w); //True positive location
		if(_c2>_xpos_increase+width){_xpos_increase += _c2-(_xpos_increase+width)};
		
		var _c1 = _y - _yo; //True negative location
		if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
		var _c2 = ((_y - _yo)+_h); //True positive location
		if(_c2>_ypos_increase+height){_ypos_increase += _c2-(_ypos_increase+height)};
		
		/////////////////

		//---------------------------------
		//Mirror
		var __x = (_x-0.5*width)*-1 + 0.5*width;
		var __y = (_y-0.5*height)*-1 + 0.5*height;
		if(global_inventory[i].x_mirror){
			////////////////////////
		
			var _c1 = ((__x + _xo)-_w); //True negative location
			if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
			var _c2 = (__x + _xo); //True positive location
			if(_c2>_xpos_increase+width){_xpos_increase += _c2-(_xpos_increase+width)};
		
			var _c1 = _y - _yo; //True negative location
			if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
			var _c2 = ((_y - _yo)+_h); //True positive location
			if(_c2>_ypos_increase+height){_ypos_increase += _c2-(_ypos_increase+height)};
		
			/////////////////
		};
		if(global_inventory[i].y_mirror){
			////////////////////////
		
			var _c1 = _x - _xo; //True negative location
			if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
			var _c2 = ((_x - _xo)+_w); //True positive location
			if(_c2>_xpos_increase+width){_xpos_increase += _c2-(_xpos_increase+width)};
		
			var _c1 = ((__y + _yo)-_h); //True negative location
			if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
			var _c2 = (__y + _yo); //True positive location
			if(_c2>_ypos_increase+height){_ypos_increase += _c2-(_ypos_increase+height)};
		
			/////////////////

		};
	};
	
	var _xx = _xneg_increase;
	var _yy = _yneg_increase;
	
	var sum_width = width + _xneg_increase + _xpos_increase;
	var sum_height = height + _yneg_increase + _ypos_increase;
	#endregion	
	var filler_surface = surface_create(sum_width, sum_height);
	var cutout_surface = surface_create(sum_width, sum_height);
	var border_surface = surface_create(sum_width, sum_height);
	var content_surface = surface_create(sum_width, sum_height);
	
	#region FILL /////////////////////////////////
	surface_set_target(filler_surface);
	
	var global_inventory = ui.styles[style].filler;
	var LoopMax = array_length(global_inventory);
	for(var i = 0; i < LoopMax; i++){
		
		_w = sprite_get_width(global_inventory[i].sprite)*global_inventory[i].x_scale;
		_h = sprite_get_height(global_inventory[i].sprite)*global_inventory[i].y_scale;
		
		var _n1 = ceil(sum_width / _w);
		var _n2 = ceil(sum_height / _h);
		
		var _LoopMax = _n1;
		for(var ii = 0; ii < _LoopMax; ii++){
			var __LoopMax = _n2;
			for(var iii = 0; iii < __LoopMax; iii++){
				draw_sprite_ext(global_inventory[i].sprite,0,_w*ii,_h*iii,global_inventory[i].x_scale,global_inventory[i].y_scale,0,c_white,1);
			};
		};
		
	};
	
	surface_reset_target();
	#endregion ////////////////////////////////////
	
	#region BORDER /////////////////////////////////
	//surface_set_target(filler_surface);
	
	var global_inventory = ui.styles[style].border;
	var LoopMax = array_length(global_inventory);
	for(var i = 0; i < LoopMax; i++){
		if(global_inventory[i].limit_surface){surface_set_target(filler_surface);}else{surface_set_target(border_surface);};
		
		_w = sprite_get_width(global_inventory[i].sprite)*global_inventory[i].x_scale;
		_h = sprite_get_height(global_inventory[i].sprite)*global_inventory[i].y_scale;
		
		var _n1 = ceil(width / _w);
		var _n2 = ceil(height / _h);
		
		if(global_inventory[i].top){
			var __LoopMax = _n1+1;
			for(var ii = 0; ii < __LoopMax; ii++){
				var ___x = _xx+_w*ii;
				draw_sprite_ext(global_inventory[i].sprite,0,___x,_yy,global_inventory[i].x_scale,global_inventory[i].y_scale,90,c_white,1);
			};
		};
		if(global_inventory[i].bottom){
			var __LoopMax = _n1+1;
			for(var ii = 0; ii < __LoopMax; ii++){
				var ___x = _xx+_w*ii;
				draw_sprite_ext(global_inventory[i].sprite,0,___x,_yy+height,-global_inventory[i].x_scale,global_inventory[i].y_scale,90,c_white,1);
			};
		};
		if(global_inventory[i].left){
			var __LoopMax = _n2+1;
			for(var ii = 0; ii < __LoopMax; ii++){
				var ___y = _yy+_h*ii;
				draw_sprite_ext(global_inventory[i].sprite,0,_xx,___y,-global_inventory[i].x_scale,global_inventory[i].y_scale,0,c_white,1);
			};
		};
		if(global_inventory[i].right){
			var __LoopMax = _n2+1;
			for(var ii = 0; ii < __LoopMax; ii++){
				var ___y = _yy+_h*ii;
				draw_sprite_ext(global_inventory[i].sprite,0,+_xx+width,___y,global_inventory[i].x_scale,-global_inventory[i].y_scale,0,c_white,1);
			};
		};
		surface_reset_target();
	};
	
	//surface_reset_target();
	#endregion ////////////////////////////////////
	
	#region CUTOUT /////////////////////////////////
	surface_set_target(cutout_surface);
		
		draw_clear_alpha(c_black,1);
		
		gpu_set_blendmode(bm_subtract);
		draw_sprite_ext(ui.ui_spr_point,0,_xx,_yy,width,height,0,c_white,1);
		gpu_set_blendmode(bm_normal);
		
		surface_set_target(filler_surface);
		
			gpu_set_blendmode(bm_subtract);
			draw_surface(cutout_surface,0,0);
			gpu_set_blendmode(bm_normal);
			
		surface_reset_target();
		
	
	surface_reset_target();
	#endregion ////////////////////////////////////
	
	#region CONTENT ///////////////////////////////
	surface_set_target(content_surface);
	draw_surface(filler_surface,0,0);
	draw_surface(border_surface,0,0);
	
	//draw_clear(c_grey);
	//draw_rectangle(_xx+2,_yy+2,_xx+width-2,_yy+height-2,2);
	//draw_rectangle(2,2,sum_width-2,sum_height-2,2);
	
	/*
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_font(ui.styles[style].font[0]);
	draw_text(_xx+width/2,_yy+height/2,"JOIN");
	*/
	var global_inventory = ui.styles[style].content;
	var LoopMax = array_length(global_inventory);
	for(var i = 0; i < LoopMax; i++){
		if(global_inventory[i].sprite = undefined){continue;};
		var _x = (global_inventory[i].x_relative/1000)*width+global_inventory[i].x_solid;
		var _y = (global_inventory[i].y_relative/1000)*height+global_inventory[i].y_solid;
		var __x = (_x-0.5*width)*-1 + 0.5*width;
		var __y = (_y-0.5*height)*-1 + 0.5*height;
		
		//better_scaling_draw_sprite(global_inventory[i].sprite,0,_xx+_x,_yy+_y,global_inventory[i].x_scale,global_inventory[i].y_scale,global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha,0);
		draw_sprite_ext(global_inventory[i].sprite,0,_xx+_x,_yy+_y,global_inventory[i].x_scale,global_inventory[i].y_scale,global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha);
		
		if(global_inventory[i].x_mirror){
			//better_scaling_draw_sprite(global_inventory[i].sprite,0,_xx+__x,_yy+_y,global_inventory[i].x_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].y_scale,global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha,0);
			draw_sprite_ext(global_inventory[i].sprite,0,_xx+__x,_yy+_y,global_inventory[i].x_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].y_scale,global_inventory[i].rotation*power(-1,global_inventory[i].true_mirror),global_inventory[i].blend,global_inventory[i].alpha);
		};
		if(global_inventory[i].y_mirror){
			//better_scaling_draw_sprite(global_inventory[i].sprite,0,_xx+_x,_yy+__y,global_inventory[i].x_scale,global_inventory[i].y_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha,0);
			draw_sprite_ext(global_inventory[i].sprite,0,_xx+_x,_yy+__y,global_inventory[i].x_scale,global_inventory[i].y_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].rotation*power(-1,global_inventory[i].true_mirror),global_inventory[i].blend,global_inventory[i].alpha);
		};
		if(global_inventory[i].x_mirror & global_inventory[i].y_mirror){
			//better_scaling_draw_sprite(global_inventory[i].sprite,0,_xx+__x,_yy+__y,global_inventory[i].x_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].y_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha,0);
			draw_sprite_ext(global_inventory[i].sprite,0,_xx+__x,_yy+__y,global_inventory[i].x_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].y_scale*power(-1,global_inventory[i].true_mirror),global_inventory[i].rotation,global_inventory[i].blend,global_inventory[i].alpha);
		};
	};
	
	surface_reset_target();
	#endregion ///////////////////////////////////
	
	var bake = {};
	
	bake.sprite = sprite_create_from_surface(content_surface, 0, 0, sum_width, sum_height, false, false, _xx+width/2, _yy+height/2);
	bake.bonus_scale = sum_width / width;
	
	surface_free(filler_surface);
	surface_free(cutout_surface);
	surface_free(border_surface);
	surface_free(content_surface);
	
	
	return bake;
};

#endregion
//======================================================================================================================================
//=================================================== MASS LOOPS FUNCTIONS =============================================================
#region LOOPS

function ui_visible_draw(draw_invisible) {
    var i = -1;
	var n = array_length(ui.global_inventory.containers)
    repeat(n) {
        i++;
        if (ui.global_inventory.containers[i].ui_info._type != UI.type_screen && ui.global_inventory.containers[i].ui_visibility.itself = 0) {
            continue;
        };
        ui_draw_container(ui.global_inventory.containers[i], draw_invisible);
    };
};
	
function ui_generate_containers(container, xn, xsize, xgap, yn, ysize, ygap, xborder, yborder) {
// Will generate CS-grid-like containers.
//------------------------
// container == The container in which the generated grid will take place.
// xn == Number of containers in x row (direction).
// xsize == X size (width) of the containers.
// xgap == The x gap between containers.
// yn == Number of containers in y column (direction).
// ysize == Y size (height) of the containers.
// ygap == The y gap between containers.
// xborder == True/False - Should the containers stick to the edge of the _parent or shoud there be a gap (border).
// yborder == True/False - Should the containers stick to the edge of the _parent or shoud there be a gap (border).
// returns == !!! Will return an 2D global_inventory with containers - return[x _index][y _index] !!!
// example: I want container in third row and second column ==> return[3][2]


    var xcalc = (1000 / (xgap * (xn - 1 + (2 * xborder)) + xsize * xn));
    var _xgap = xgap * xcalc;
    var _xsize = xsize * xcalc;

    var ycalc = (1000 / (ygap * (yn - 1 + (2 * yborder)) + ysize * yn));
    var _ygap = ygap * ycalc;
    var _ysize = ysize * ycalc;

    var gen = [];
    var i = 0;
    repeat(xn) {
        var xx = _xgap * (i + (1 * xborder)) + _xsize * (i);
        var xxx = _xgap * (i + (1 * xborder)) + _xsize * (i + 1);
        var ii = 0;
        repeat(yn) {
            var yy = _ygap * (ii + (1 * yborder)) + _ysize * (ii);
            var yyy = _ygap * (ii + (1 * yborder)) + _ysize * (ii + 1);
            gen[i][ii] = ui_container_create(container, 0, 0, 0, 0, xx, yy, xxx, yyy);
            ii++;
        };
        i++;
    };
    return gen;
};

//NEW FUNCTIONS
function ui_all_recalculate(){
//This will go through all visible screens and recalculate them
    var i = 0;
	var n = array_length(ui.global_inventory.active_screens);
    repeat(n) {
        ui_process_recalculate_screen_add(ui.global_inventory.active_screens[i]);
		i++;
    };
};

function ui_all_rebake(){
//This will go through all visible screens and recalculate them
    var i = 0;
	var n = array_length(ui.global_inventory.active_screens);
    repeat(n) {
        ui_process_rebake_add_all(ui.global_inventory.active_screens[i]);
		i++;
    };
};

function ui_process_recalculate(){
// This function will sort and iterate through all containers that should be recalculated
//------------------------
	//Recalculate screens
	var n = array_length(ui.global_inventory.screens_to_recalculate);
	
	var i = -1;
	repeat(n){
	    i++;
	    if(ui.global_inventory.screens_to_recalculate[i].ui_processing._recalculated = true){continue;};
	    ui_func_screen_recalculate(ui.global_inventory.screens_to_recalculate[i]);
		with(ui.global_inventory.screens_to_recalculate[i]){
			//LOOP------------------------------------------
	        var nn = array_length(ui_inventory.containers);
	        var i = 0;
	        repeat(nn) {
				ui_process_recalculate_add_all(ui_inventory.containers[i]);
	            i++;
	        };
		};
	};

	var i = -1;
    repeat(n){
        i++;
        ui.global_inventory.screens_to_recalculate[i].ui_processing._recalculated = false;
    };
	/////////////////

	array_sort(ui.global_inventory.containers_to_recalculate, function(elm1, elm2){return elm1.ui_info._layer - elm2.ui_info._layer;});
	var n = array_length(ui.global_inventory.containers_to_recalculate);
	
	var i = -1;
	repeat(n){
	    i++;
	    if(ui.global_inventory.containers_to_recalculate[i].ui_processing._recalculated = true){continue;};
	    ui_func_container_recalculate(ui.global_inventory.containers_to_recalculate[i]);
	};

	var i = -1;
    repeat(n){
        i++;
        ui.global_inventory.containers_to_recalculate[i].ui_processing._recalculated = false;
    };
	ui_process_recalculate_wipe();
};
function ui_process_recalculate_wipe(){
	var n = array_length(ui.global_inventory.screens_to_recalculate);
	array_delete(ui.global_inventory.screens_to_recalculate,0,n);
	
	var n = array_length(ui.global_inventory.containers_to_recalculate);
	array_delete(ui.global_inventory.containers_to_recalculate,0,n);
};
function ui_process_recalculate_add(container){
	var i = array_length(ui.global_inventory.containers_to_recalculate);
	ui.global_inventory.containers_to_recalculate[i] = container;
};
function ui_process_recalculate_add_all(container){
	ui_process_recalculate_add(container);
	//LOOP------------------------------------------
    var n = array_length(container.ui_inventory.containers);
    var i = 0;
    repeat(n) {
        ui_process_recalculate_add_all(container.ui_inventory.containers[i]);
        i++;
    };
};

function ui_process_recalculate_screen_add(screen){
	var i = array_length(ui.global_inventory.screens_to_recalculate);
	ui.global_inventory.screens_to_recalculate[i] = screen;
};
	
function ui_process_interactive(){
	var mousex = window_mouse_get_x();
	var mousey = window_mouse_get_y();
	
	var mousepr = mouse_check_button_pressed(mb_right);
	var mousepl = mouse_check_button_pressed(mb_left);
	var mouseen = 1;
	
	////////////////////////////////////////////////////////
	//SORT ALL RECALCULATES (FROM HIGHEST LAYER TO LOWEST)
	array_sort(ui.global_inventory.containers_to_interact, function(elm1, elm2){
		return elm1.ui_info._layer - elm2.ui_info._layer;
	});
	
	var i = -1;var n = array_length(ui.global_inventory.containers_to_interact);
    repeat(n){
        i++;
        if(ui.global_inventory.containers_to_interact[i].ui_info.visible = false){continue;};
        //if(point_in_rectangle(mousex,mousey,ui.global_inventory.containers_to_interact[i].ui_info.x1,ui.global_inventory.containers_to_interact[i].ui_info.y1,ui.global_inventory.containers_to_interact[i].ui_info.x2,ui.global_inventory.containers_to_interact[i].ui_info.y2)){
		if((ui.global_inventory.containers_to_interact[i].ui_info.x1 < mousex && mousex < ui.global_inventory.containers_to_interact[i].ui_info.x2) && (ui.global_inventory.containers_to_interact[i].ui_info.y1 < mousey && mousey < ui.global_inventory.containers_to_interact[i].ui_info.y2)){
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_enter = mouseen;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_click = mousepr or mousepl;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_right = mousepr;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_left = mousepl;
			if(mousepr or mousepl){mousepr=0;mousepl=0;mouseen=0;}; //This will make sure that all following containers do not receive input, only 1.
			//Would be better to break it here and loop through rest i and set it all to 0.
		}else{
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_enter = 0;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_click = 0;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_right = 0;
			ui.global_inventory.containers_to_interact[i].ui_input.mouse_left = 0;
		};
    };
	


};
function ui_process_interactive_add(container){
	var i = array_length(ui.global_inventory.containers_to_interact);
	ui.global_inventory.containers_to_interact[i] = container;
};
function ui_process_interactive_add_all(container){
	ui_process_interactive_add(container);
	//LOOP------------------------------------------
    var n = array_length(container.ui_inventory.containers);
    var i = 0;
    repeat(n) {
        ui_process_interactive_add_all(container.ui_inventory.containers[i]);
        i++;
    };
};

function ui_process_animation(){
//If you are using animations, this command needs to be run every step.
//------------------------
// container == Target container.
//------------------------
var i = -1;var n = array_length(ui.global_inventory.containers_to_animate);
    repeat(n){
        i++;
		var container = ui.global_inventory.containers_to_animate[i];
		if (container.ui_info.visible = 1) {
			if (container.ui_animation.frozen = 0) {
	
				container.ui_animation.position_pseudo = round(container.ui_animation.merge); //Is it closer to 0 or 1?
				container.ui_animation.position_real = container.ui_animation.position[container.ui_animation.position_pseudo]; //Get real active position
				container.ui_animation.position_target = sign(container.ui_animation.inversion+1);
	
				container.ui_temp_memory.rest = container.ui_animation.rest;	//Cache state last tick
	
				container.ui_animation.steady = (container.ui_animation.merge = 0 or container.ui_animation.merge = 1) and container.ui_trigger.animation = 0 and container.ui_inventory.positions[container.ui_animation.position_target].return_if_done = 0;
				container.ui_animation.rest = container.ui_animation.merge = 0 or container.ui_animation.merge = 1;
			    if(container.ui_animation.steady = 0){
			        with(container) {
						if(ui_animation.paused = true){
							var trigger = ui_temp_memory.trigger.animation;
						}else{
							var trigger = ui_trigger.animation;
						};
						ui_animation.merge = animcurve_channel_evaluate(animcurve_get_channel(GMCS_smoothing, ui_inventory.positions[ui_animation.position_target].curve_index), ui_animation.percantage/100);
						ui_animation.percantage += power(-1,!trigger) * ui_inventory.positions[ui_animation.position_target]._speed * ui_animation.inversion;
			            ui_animation.percantage = clamp(ui_animation.percantage, 0, 100);
			        };
			        if(container.ui_animation.rest = 0){ui_process_recalculate_add_all(container);};
			    };
				//What will happen when the animation is done?
				if(container.ui_temp_memory.rest = 0 and container.ui_animation.rest = 1){
					if(container.ui_inventory.positions[container.ui_animation.position_target].finish_unpause = 1){ui_container_animation_pause(container,0)};
					var n = array_length(container.ui_inventory.chains);
					var i = 0;
				    repeat(n){
				        if(container.ui_animation.position_real = container.ui_inventory.chains[i].position[0]){
							ui_container_animation_set(container.ui_inventory.chains[i].container,container.ui_inventory.chains[i].position[1]);
						};i++;
				    };
		
				};
			};
		};
	
	};

};
function ui_process_animation_add(container){
	var i = array_length(ui.global_inventory.containers_to_animate);
	ui.global_inventory.containers_to_animate[i] = container;
};
function ui_process_animation_add_all(container){
	ui_process_animation_add(container);
	//LOOP------------------------------------------
    var n = array_length(container.ui_inventory.containers);
    var i = 0;
    repeat(n) {
        ui_process_animation_add_all(container.ui_inventory.containers[i]);
        i++;
    };
};
	
function ui_process_rebake(){
// This function will sort and iterate through all containers that should be rebaked
//------------------------
	/////////////////////////////////////////////////////////
	//INDEX ALL CHILDRED FROM THE ITERATED CONTAINERS
	    var i = 0;var n = array_length(ui.global_inventory.containers_to_rebake);
	    repeat(n){
	        ui_process_rebake_add_all(ui.global_inventory.containers_to_rebake[i]);
			i++;
	    };
	

	/////////////////////////////////////////////////////////
	//ITERATE THROUGH ALL MEMBERS OF THE ARRAY
	    var i = -1;var n = array_length(ui.global_inventory.containers_to_rebake);
	    repeat(n){
	        i++;
	        if(ui.global_inventory.containers_to_rebake[i].ui_processing._rebaked = true){continue;};
			ui_func_container_rebake(ui.global_inventory.containers_to_rebake[i],ui.global_inventory.containers_to_rebake[i].ui_inventory.styles[ui.global_inventory.containers_to_rebake[i].ui_style.style_current].style);
	    };
	//////////////////////////////////////////////////////////
	//Loop through them again and reset them for next iteration
	var i = -1;
    repeat(n){
        i++;
        ui.global_inventory.containers_to_rebake[i].ui_processing._rebaked = false;
    };
	//Remove everything from that global_inventory
	array_delete(ui.global_inventory.containers_to_rebake,0,n);
};
function ui_process_rebake_add(container){
	var i = array_length(ui.global_inventory.containers_to_rebake);
	ui.global_inventory.containers_to_rebake[i] = container;
};
function ui_process_rebake_add_all(container){
	ui_process_rebake_add(container);
	//LOOP------------------------------------------
    var n = array_length(container.ui_inventory.containers);
    var i = 0;
    repeat(n) {
        ui_process_rebake_add_all(container.ui_inventory.containers[i]);
        i++;
    };
};
#endregion
