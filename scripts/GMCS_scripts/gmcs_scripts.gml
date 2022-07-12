//======================================================================================================================================
//======================================================================================================================================
//--------------------------------------- GameMakerCascadeSheet (GMCS) by Dominik Kaspar -----------------------------------------------
//
// Lightweight replacement for completely absent UI system in GMS2. Handles resolution scaling, user-friendly container defining,
// animations, custom styles and image baking, grid box generation and more!
//
// I focused to make this library as optimized as possible, but with all that fancy stuff and animations, it's not that easy.
// If you have any questions or advices for improvements, reach out to me on Discord! 1DEDARY#1307
//
// Github repository: https://github.com/IDEDARY/Game-Maker-Cascade-Sheet
// Published under MIT license.
// Version 6.0
//
//======================================================================================================================================
//===================================================== DEPENDENCIES ===================================================================
#region DEPENDENCIES
	// Everything that needs to be done so this can work.
	// -----
	// 1) Game options > allow window resize == true
	// 2) Game options > scaling == full scale (optional, but it looks better)
	// 3) Game options > allow fullscreen switching == true (optional)
	// 4) global.screen_width & global.screen_height needs to be declared before working with GMCS. It can be solved by just dragging GMCS_objResolution
	//    to the room, but if you use your own object to manage window scaling and viewports, this needs to be done.
	//-----
#endregion
//======================================================================================================================================
//===================================================== DECLARE FUNCTIONS ==============================================================
#region FUNCTIONS
	//======================================================================================//
	//======================================================================================//
	#region ENUMS
	//These are inner working functions that are not supposed to be touched by user. TLDR: Don't touch anything that has in name "func" = inner function (applies to arrays and structs as well)
	enum UI {
		//Anchor positions (used when scaling type_solid container)
		anchor_center,
		anchor_bottom,
		anchor_top,
		anchor_left,
		anchor_right,
		//Method of scaling (used when scaling type_solid container or in custom draw functions)
		scale_fit,												//Makes the container "fit" inside of another container
		scale_fill,												//Makes the container "fill" everthing of another container
		scale_deform,											//Stretches the container to "fill" everthing of another container
		//Type of the container or element - will define how things behave.
		type_screen,											//Container only - container of the size of the screen
		type_relative,											//Used in containers and elements
		type_solid,												//Used in containers and elements
		type_window,											//Container only - container behaves as drag-able window //Only solid and can be draggable outside and cannot on/off
		//Style of the container - poor choice will result in wastefull processing time.
		style_custom,											//The baking is turned off and you supply the image.
		style_synthetic,										//The baking is turned off but all style elements are drawn separately and dynamically.
		style_cached,											//Baked style into sprite every time container is resized (Use it on containers that DON'T percantage size often).
		style_baked,											//Baked style into sprite when created or called by user (Use it on containers that DON'T percantage size often).
		style_amphibious,										//Style that dynamically changes between baking and sythetizing.
	};
	#endregion
	//======================================================================================//
	//======================================================================================//
	#region CONSTRUCTORS
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Init
		/// @description This will prepare GMCS for you, declare this only once in game_start event. All container declaration should follow in the same event.
		/// @function gmcs_init()
		/// @self
		/// @return noone
		function gmcs_init() {
			global.gmcs = {};
			with(global.gmcs){
			manager = instance_create_depth(0,0,-300,GMCS_objManager);
			//-------------------------------
			//--MEMORY--
			_memory_screens = [];
			_memory_visibles = [];
			//_memory_interactives = [];
			_callstack_recalculate = [];
			//-------------------------------
			//--METHODS--
			_method_mark_recalculate = function(__container){
				//This will mark a container to be recalculated
				_callstack_recalculate[array_length(_callstack_recalculate)] = __container;
				var n = array_length(__container._memory_containers);
			    var i = 0;
			    repeat(n) {
			        _method_mark_recalculate(__container._memory_containers[i]);
			        i++;
			    };
			};
			_method_cleanup_render = function(){
				//This will push all containers from active screens onto the render array
				manager.canvas_index = 0;
				array_delete(manager.canvas,0,array_length(manager.canvas));
				var n = array_length(_memory_visibles);
				var i = 0;
				//Loop through all visibles
				repeat(n) {
					var nn = array_length(_memory_visibles[i]._memory_stash_render);
					var ii = 0;
					repeat(nn) {
						while(manager.canvas_index <= _memory_visibles[i]._memory_stash_render[ii]._info_layer){
							array_push(manager.canvas,[]);
							manager.canvas_index = array_length(manager.canvas);
						};
						manager.canvas[_memory_visibles[i]._memory_stash_render[ii]._info_layer][array_length(manager.canvas[_memory_visibles[i]._memory_stash_render[ii]._info_layer])] = _memory_visibles[i]._memory_stash_render[ii];
					ii++;
					};
				i++;
				};
			
			};
			_method_process_recalculate = function(){
				//This will recalculate all marked containers
				var n = array_length(_callstack_recalculate);
			    var i = 0;
			    repeat(n) {
					if(_callstack_recalculate[i]._processing_doneRecalculated = 1){i++;continue;};
			        _callstack_recalculate[i]._method_recalculate();
					_callstack_recalculate[i]._processing_doneRecalculated = 1;
			        i++;
			    };
				var n = array_length(_callstack_recalculate);
			    var i = 0;
			    repeat(n) {
					_callstack_recalculate[i]._processing_doneRecalculated = 0;
			        i++;
			    };
				array_delete(_callstack_recalculate,0,array_length(_callstack_recalculate));
			};
			//////////////////////////////////////////////////////////////////////////////////////////	
			_inherit_getPositionRelative = function(__container,__position){
				var xsc = (__container._info_parent._info_width) / 1000;
				var ysc = (__container._info_parent._info_height) / 1000;
				var x1 = __container._memory_positions[__position][0][0] + __container._memory_positions[__position][1][0] * xsc;
				var y1 = __container._memory_positions[__position][0][1] + __container._memory_positions[__position][1][1] * ysc;
				var x2 = __container._memory_positions[__position][0][2] + __container._memory_positions[__position][1][2] * xsc;
				var y2 = __container._memory_positions[__position][0][3] + __container._memory_positions[__position][1][3] * ysc;
				
				return [
				__container._info_parent._info_position[0] + x1,
				__container._info_parent._info_position[1] + y1,
				__container._info_parent._info_position[0] + x2,
				__container._info_parent._info_position[1] + y2,
				];
			
			};
			_inherit_getPositionSolid = function(__container,__position){
				var _width = __container._memory_positions[__position][0][0];
				var _height = __container._memory_positions[__position][0][1];
				if (__container._memory_positions[__position][3] = UI.scale_fit) {var sc = gmcs_getscale_fit(__container._info_parent, _width, _height);} else { var sc = gmcs_getscale_fill(__container._info_parent, _width, _height);};
				_width *= sc/2;
				_height *= sc/2;
				var array = [
		        __container._info_parent._info_x - _width,
		        __container._info_parent._info_y - _height,
		        __container._info_parent._info_x + _width,
		        __container._info_parent._info_y + _height,
				];
				switch(__container._memory_positions[__position][1][0]){
					case UI.anchor_left:
						var c = (__container._info_parent._info_position[0] - array[0])*__container._memory_positions[__position][2][0];
						array[0] += c;
						array[2] += c;
						break;
					case UI.anchor_right:
						var c = (__container._info_parent._info_position[0] - array[0])*__container._memory_positions[__position][2][0];
						array[0] -= c;
						array[2] -= c;
						break;
				};
				switch(__container._memory_positions[__position][1][1]){
					case UI.anchor_bottom:
						var c = (__container._info_parent._info_position[1] - array[1])*__container._memory_positions[__position][2][1];
						array[1] -= c;
						array[3] -= c;
						break;
					case UI.anchor_top:
						var c = (__container._info_parent._info_position[1] - array[1])*__container._memory_positions[__position][2][1];
						array[1] += c;
						array[3] += c;
						break;
				};
				return array;
			};
			
			_inherit_setVisible = function(__container, __visibility){
				__container._info_selfVisible = __visibility;
				__container._info_visible = __container._info_parent._info_visible && __container._info_selfVisible;
				if(__container._info_visible = 1){
					global.gmcs._method_mark_recalculate(__container);
					if(array_length(__container._memory_styles) != 0){
						var found = false;
						var i = 0; var n = array_length(__container._info_screen._memory_stash_render);
						repeat(n){
							if(__container._info_screen._memory_stash_render[i] = __container){found = true;break;};
						i++;
						};
						if(found = false){__container._info_screen._memory_stash_render[array_length(__container._info_screen._memory_stash_render)] = __container;};
					};
				}else{
					if(array_length(__container._memory_styles) != 0){
						var found = false;
						var i = 0; var n = array_length(__container._info_screen._memory_stash_render);
						repeat(n){
							if(__container._info_screen._memory_stash_render[i] = __container){found = true;break;};
						i++;
						};
						if(found = true){array_delete(__container._info_screen._memory_stash_render,i,1);};
					};
				};
				var n = array_length(__container._memory_containers);
		        var i = 0;
		        repeat(n) {
					__container._memory_containers[i]._method_setVisible(__visibility);
					i++;
		        };
			};
			_inherit_addPosition_solid = function(__container, __pos_solid, __pos_relative) {
				var i = array_length(__container._memory_positions);
			    __container._memory_positions[i] = [__pos_solid, __pos_relative, UI.type_solid];
			    return i;
			};
			_inherit_addPosition_relative = function(__container, __pos_solid, __pos_relative, __target) {
				var i = array_length(__container._memory_positions);
			    __container._memory_positions[i] = [__pos_solid, __pos_relative, UI.type_relative, __target];
			    return i;
			};
			_inherit_addPositionFrom_solid = function(__container, __position, __pos_solid, __pos_relative){
				//------------------------
				// HOW TO USE!! -- If you enter REAL value, it will overwrite it, If you enter STRING value, it will add to it. Ex. "0" for keeping the same value.
				//------------------------
				if(is_string(__pos_solid[0])){var _x1_s = __container._memory_positions[__position][0][0]+real(__pos_solid[0]);}else{var _x1_s = __pos_solid[0];};
				if(is_string(__pos_solid[1])){var _x2_s = __container._memory_positions[__position][0][1]+real(__pos_solid[1]);}else{var _x2_s = __pos_solid[1];};
				if(is_string(__pos_solid[2])){var _y1_s = __container._memory_positions[__position][0][2]+real(__pos_solid[2]);}else{var _y1_s = __pos_solid[2];};
				if(is_string(__pos_solid[3])){var _y2_s = __container._memory_positions[__position][0][3]+real(__pos_solid[3]);}else{var _y2_s = __pos_solid[3];};
				if(is_string(__pos_relative[0])){var _x1_r = __container._memory_positions[__position][1][0]+real(__pos_relative[0]);}else{var _x1_r = __pos_relative[0];};
				if(is_string(__pos_relative[1])){var _x2_r = __container._memory_positions[__position][1][1]+real(__pos_relative[1]);}else{var _x2_r = __pos_relative[1];};
				if(is_string(__pos_relative[2])){var _y1_r = __container._memory_positions[__position][1][2]+real(__pos_relative[2]);}else{var _y1_r = __pos_relative[2];};
				if(is_string(__pos_relative[3])){var _y2_r = __container._memory_positions[__position][1][3]+real(__pos_relative[3]);}else{var _y2_r = __pos_relative[3];};
			    return _inherit_addPosition_solid(__container,[_x1_s,_x2_s,_y1_s,_y2_s],[_x1_r,_x2_r,_y1_r,_y2_r]);
			};
			
			_inherit_addStyle = function(__container,_style) {
				__container._memory_styles[array_length(__container._memory_styles)] = {
					_sprite : noone,
					_surface : -1,
					_sprite_scale : 1,
					_sprite_reference : [noone, noone],
					_sprite_decoration : [],
					_font : noone,
					_font_blend : [c_white,c_white,c_white,c_white],
					_font_alpha : 1,
					_font_size : 0.5,
					
					_font_halign : fa_right,
					_font_valign : fa_center,
					_font_margin : 32,
					_font_hoffset : 0,
					_font_voffset : 0,
			
					_spriteReturn_deco_offset : [],
					_spriteReturn_deco_size : [],
				};
				var s = __container._memory_styles[array_length(__container._memory_styles)-1];
				if(variable_struct_exists(_style,"_sprite")){s._sprite = _style._sprite;};
				if(variable_struct_exists(_style,"_sprite_scale")){s._sprite_scale = _style._sprite_scale;};
				if(variable_struct_exists(_style,"_sprite_reference")){s._sprite_reference = _style._sprite_reference;};
				if(variable_struct_exists(_style,"_sprite_decoration")){s._sprite_decoration = _style._sprite_decoration;};
				if(variable_struct_exists(_style,"_font")){s._font = _style._font;};
				if(variable_struct_exists(_style,"_font_blend")){s._font_blend = _style._font_blend;};
				if(variable_struct_exists(_style,"_font_alpha")){s._font_alpha = _style._font_alpha;};	
			};
			
		};};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Screen
		/// @description This will create & return a "screen" type of container, it is equvalent of GM rooms, but for UI. Example: "screen_inventory", "screen_main_menu", etc.
		/// @function gmcs_container_screen()
		/// @self
		/// @return struct
		function gmcs_container_screen() constructor {
			//-------------------------------
			//--INFO--
			_info_width = global.screen_width;
			_info_height = global.screen_height;
			_info_position = [0,0,global.screen_width,global.screen_height];
			_info_x = global.screen_width/2;
			_info_y = global.screen_height/2;
			_info_layer = 0;
			_info_type = UI.type_screen;
			_info_visible = 0;
			_info_screen = self;
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			_memory_stash_render = [];
			_memory_stash_animation = [];
			//_memory_stash_interactive = [];
			//-------------------------------
			//--METHODS--
			static _method_recalculate = function(){
				//This will recalculate the container
				_info_width = global.screen_width;
				_info_height = global.screen_height;
				_info_position = [0,0,global.screen_width,global.screen_height];
				_info_x = global.screen_width/2;
				_info_y = global.screen_height/2;
			};
			static _method_setVisible = function(__visibility){
				//This will set visibility of a container
				_info_visible = __visibility;
				var n = array_length(global.gmcs._memory_visibles);
			    var i = 0;
				var found = -1;
			    repeat(n) {
			        if(global.gmcs._memory_visibles[i] = self){found = i;break;};
			        i++;
			    };
				if(_info_visible = 1){
					if(found = -1){global.gmcs._memory_visibles[array_length(global.gmcs._memory_visibles)] = self;};
					global.gmcs._method_mark_recalculate(self);
				} else {
					if(found != -1){array_delete(global.gmcs._memory_visibles,found,1);};
				};
				var n = array_length(_memory_containers);
		        var i = 0;
		        repeat(n) {
		            _memory_containers[i]._method_setVisible(__visibility);
		            i++;
		        };
			};
			_method_recalculate();
			_method_setVisible(_info_visible);
			//-------------------------------
			//--PROCESSING--
			_processing_doneRecalculated = 0;
			//-------------------------------
			//--CALLBACK--
			global.gmcs._memory_screens[array_length(global.gmcs._memory_screens)] = self;
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Relative
		/// @description This will create & return a "relative" type of container, which is nested in another container refered to as "parent" and it's size is proportional to that of the parent.
		/// @function gmcs_container_relative(parent, solid_positions, relative_positions)
		/// @self
		/// @param {struct} parent Container in which it should be nested
		/// @param {array} solid_positions (x1,y1,x2,y2) - Array with 4 real values defining solid (non-proportional) positions of the bounding points of the container
		/// @param {array} relative_positions (x1,y1,x2,y2) - Array with 4 real values defining relative (proportional) positions of the bounding points of the container (0 - 1000 = 0% - 100% size of parent)
		/// @return struct
		function gmcs_container_relative(__parent, __pos_solid, __pos_relative) constructor {
			//-------------------------------
			//--INFO--
			_info_width = 0;
			_info_height = 0;
			_info_position = [0,0,0,0];
			_info_x = 0;
			_info_y = 0;
			_info_parent = __parent;
			_info_screen = __parent._info_screen;
			_info_layer = _info_parent._info_layer + 1;
			_info_type = UI.type_relative;
			_info_visible = 1;
			_info_selfVisible = 1;
			_info_text = "";
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			_memory_positions = [[__pos_solid,__pos_relative, UI.type_solid]];
			_memory_styles = [];
			_cache_height = 0;
			_cache_width = 0;
			_callstack_animation = [];
			//-------------------------------
			//--ANIMATION--
			_animation_positionIndex = [0,0];
			_animation_merge = 0;
			//-------------------------------
			//--METHODS--
			static _method_recalculate = function(){
				var _v1 = global.gmcs._inherit_getPositionRelative(self,_animation_positionIndex[0]);
				var _v2 = global.gmcs._inherit_getPositionRelative(self,_animation_positionIndex[1]);
				_info_position[0] = lerp(_v1[0],_v2[0],_animation_merge);
				_info_position[1] = lerp(_v1[1],_v2[1],_animation_merge);
				_info_position[2] = lerp(_v1[2],_v2[2],_animation_merge);
				_info_position[3] = lerp(_v1[3],_v2[3],_animation_merge);
				_info_width = _info_position[2] - _info_position[0];
				_info_height = _info_position[3] - _info_position[1];
				_info_x = _info_position[0]+_info_width/2;
				_info_y = _info_position[1]+_info_height/2;
			};
			static _method_setVisible = function(__visibility){
				global.gmcs._inherit_setVisible(self, __visibility);
			};
			static _method_addStyle = function(__style = {}) {
				global.gmcs._inherit_addStyle(self, __style);
			};
		
			_method_recalculate();
			_method_setVisible(_info_visible);
			//-------------------------------
			//--PROCESSING--
			_processing_doneRecalculated = 0;
			//-------------------------------
			//--CALLBACK--
			_info_parent._memory_containers[array_length(_info_parent._memory_containers)] = self;
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Solid
		/// @description This will create & return a "solid" type of container, which is nested in another container refered to as "parent" and it's width/height ratio will always stay the same and will fit/fill that of the parent.
		/// @function gmcs_container_solid(parent, size, anchor, scale_type)
		/// @self
		/// @param {struct} parent Container in which it should be nested
		/// @param {array} size (width,height) - Array with 2 real values defining ratio of sides
		/// @param {array} anchor (horizontal, vertical) - Array with 2 enum values defining alignment of the container. Example: "[UI.anchor_center, UI.anchor_center]"
		/// @param {real} scale_type Enum defining overflow, either "UI.scale_fit" or "UI.scale_fill", 90% of the case you want to use "UI.scale_fit"
		/// @return struct
		function gmcs_container_solid(__parent, __size, __anchor, __scale_type) constructor {
			//-------------------------------
			//--INFO--
			_info_width = 0;
			_info_height = 0;
			_info_position = [0,0,0,0];
			_info_x = 0;
			_info_y = 0;
			_info_parent = __parent;
			_info_screen = __parent._info_screen;
			_info_layer = _info_parent._info_layer + 1;
			_info_type = UI.type_solid;
			_info_visible = 1;
			_info_selfVisible = 1;
			_info_text = "";
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			_memory_positions = [[__size,__anchor,[1,1],__scale_type]];
			_memory_styles = [];
			_cache_height = 0;
			_cache_width = 0;
			_callstack_animation = [];
			//-------------------------------
			//--ANIMATION--
			_animation_positionIndex = [0,0];
			_animation_merge = 0;
			//-------------------------------
			//--METHODS--
			static _method_recalculate = function(){
				//This will recalculate the container
				var _v1 = global.gmcs._inherit_getPositionSolid(self,_animation_positionIndex[0]);
				var _v2 = global.gmcs._inherit_getPositionSolid(self,_animation_positionIndex[1]);
				
				_info_position[0] = lerp(_v1[0],_v2[0],_animation_merge);
				_info_position[1] = lerp(_v1[1],_v2[1],_animation_merge);
				_info_position[2] = lerp(_v1[2],_v2[2],_animation_merge);
				_info_position[3] = lerp(_v1[3],_v2[3],_animation_merge);

				_info_width = _info_position[2] - _info_position[0];
				_info_height = _info_position[3] - _info_position[1];
				_info_x = _info_position[0]+_info_width/2;
				_info_y = _info_position[1]+_info_height/2;
			};
			static _method_setVisible = function(__visibility){
				global.gmcs._inherit_setVisible(self, __visibility);
			}
			static _method_addStyle = function(__style = {}) {
				global.gmcs._inherit_addStyle(self, __style);
			};
			
			_method_recalculate();
			_method_setVisible(_info_visible);
			//-------------------------------
			//--PROCESSING--
			_processing_doneRecalculated = 0;
			//-------------------------------
			//--CALLBACK--
			_info_parent._memory_containers[array_length(_info_parent._memory_containers)] = self;
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Wrappers
		/// @description You will input basic specifications and the function will return autofilled struct ready to be used by GMCS styling
		/// @function gmcs_wrap_decoration(style)
		/// @self
		/// @param {struct} style struct that should be wrapped for use as a decoration in GMCS styling
	function gmcs_wrap_decoration(_style = {}){
		var s = {
			_sprite : noone,
			_relative : [0,0],
			_solid : [0,0],
			_x_scale : 1,
			_y_scale : 1,
			_x_mirror : 0,
			_y_mirror : 0,
			_true_mirror : 1,
			_rotation : 0,
			_blend : c_white,
			_alpha : 1,
		};
		if(variable_struct_exists(_style,"_sprite")){s._sprite = _style._sprite;};
		if(variable_struct_exists(_style,"_relative")){s._relative = _style._relative;};
		if(variable_struct_exists(_style,"_solid")){s._solid = _style._solid;};
		if(variable_struct_exists(_style,"_x_scale")){s._x_scale = _style._x_scale;};
		if(variable_struct_exists(_style,"_y_scale")){s._y_scale = _style._y_scale;};
		if(variable_struct_exists(_style,"_x_mirror")){s._x_mirror = _style._x_mirror;};
		if(variable_struct_exists(_style,"_y_mirror")){s._y_mirror = _style._y_mirror;};
		//if(variable_struct_exists(_style,"_true_mirror")){s._true_mirror = _style._true_mirror;};
		//Currently disabled - this option is not done yet
		if(variable_struct_exists(_style,"_rotation")){s._rotation = _style._rotation;};
		if(variable_struct_exists(_style,"_blend")){s._blend = _style._blend;};
		if(variable_struct_exists(_style,"_alpha")){s._alpha = _style._alpha;};
		return s;
	};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#endregion
	//======================================================================================//
	//======================================================================================//
	#region SCRIPT CALLS
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Mark active
		/// @description This command will mark all active screens for recalculation.
		/// @function gmcs_mark_recalculate_active()
		/// @self
		/// @return noone
		function gmcs_mark_recalculate_active(){
		var n = array_length(global.gmcs._memory_visibles);
		var i = 0;
		repeat(n) {
			global.gmcs._method_mark_recalculate(global.gmcs._memory_visibles[i]);
			i++;
		};
	};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Grid generation
		/// @description This will generate several relative containers in grid-like structure and returns them as 2D array - return[x _index][y _index]
		/// @function gmcs_grid_generate(parent, x_number, width, gap_width, y_number, height, gap_height, border_x, border_y);
		/// @self
		/// @param {struct} parent Container in which it should be nested
		/// @param {real} x_number Number of containers on x axis
		/// @param {real} width Width ratio of containers
		/// @param {real} gap_width Gaps size ratio between columns
		/// @param {real} y_number Number of containers on y axis
		/// @param {real} height Height ratio of containers
		/// @param {real} gap_height Gaps size ratio between rows
		/// @param {bool} border_x Should it add gaps from sides?
		/// @param {bool} border_y Should it add gaps from sides?
		/// @return array
		function gmcs_grid_generate(__container, __xn, __xsize, __xgap, __yn, __ysize, __ygap, __xborder, __yborder) {
		    var xcalc = (1000 / (__xgap * (__xn - 1 + (2 * __xborder)) + __xsize * __xn));
		    var _xgap = __xgap * xcalc;
		    var _xsize = __xsize * xcalc;

		    var ycalc = (1000 / (__ygap * (__yn - 1 + (2 * __yborder)) + __ysize * __yn));
		    var _ygap = __ygap * ycalc;
		    var _ysize = __ysize * ycalc;

		    var gen = [];
		    var i = 0;
		    repeat(__xn) {
		        var xx = _xgap * (i + (1 * __xborder)) + _xsize * (i);
		        var xxx = _xgap * (i + (1 * __xborder)) + _xsize * (i + 1);
		        var ii = 0;
		        repeat(__yn) {
		            var yy = _ygap * (ii + (1 * __yborder)) + _ysize * (ii);
		            var yyy = _ygap * (ii + (1 * __yborder)) + _ysize * (ii + 1);
		            gen[i][ii] = new gmcs_container_relative(__container, [0, 0, 0, 0], [xx, yy, xxx, yyy]);
		            ii++;
		        };
		        i++;
		    };
		    return gen;
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#endregion
	//======================================================================================//
	//======================================================================================//
	#region DRAW CALLS
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Draw container
		/// @description Place this in DRAW GUI, it will draw container with all its components.
		/// @function gmcs_draw_container(container)
		/// @self
		/// @param {struct} container Container which you want to draw
		/// @return noone
		function gmcs_draw_container(__container) {
			if(__container._info_visible){
				draw_rectangle(__container._info_position[0],__container._info_position[1],__container._info_position[2]-1,__container._info_position[3]-1,1);
			};
		    //LOOP------------------------------------------
		    var n = array_length(__container._memory_containers);
		    var i = 0;
		    repeat(n) {
		        gmcs_draw_container(__container._memory_containers[i]);
		        i++;
		    };
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Draw all active containers
		/// @description Place this in DRAW GUI, it will draw all currently visible container with all its components.
		/// @function gmcs_draw_visible()
		/// @self
		/// @return noone
		function gmcs_draw_visible() {
			var n = array_length(global.gmcs._memory_visibles);
			var i = 0;
			repeat(n) {
				gmcs_draw_container(global.gmcs._memory_visibles[i]);
				i++;
			};
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Get scale for filling container
		/// @description This will return scale value for filling a container
		/// @function gmcs_getscale_fill(container, width, height)
		/// @self
		/// @param {struct} container Container in which it should be filled
		/// @param {struct} width Width for scaling (ratio)
		/// @param {struct} height Height for scaling (ratio)
		function gmcs_getscale_fill(__container, __width, __height) {
		    return max(__container._info_width/__width, __container._info_height/__height);
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#region Get scale for fitting container
		/// @description This will return scale value for fitting a container
		/// @function gmcs_getscale_fit(container, width, height)
		/// @self
		/// @param {struct} container Container in which it should be fitted
		/// @param {struct} width Width for scaling (ratio)
		/// @param {struct} height Height for scaling (ratio)
		function gmcs_getscale_fit(__container, __width, __height) {
		    return min(__container._info_width/__width, __container._info_height/__height);
		};
	#endregion
	//////////////////////////////////////////////////////////////////////////////////////////
	#endregion
	//======================================================================================//
	//======================================================================================//
#endregion