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
		mode_mouse,
		mode_gamepad,
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
			cursor = instance_create_depth(0,0,-500,GMCS_objCursor);
			time_delta = 1;
			//-------------------------------
			//--MEMORY--
			_memory_screens = [];
			
			//Feedstack (rename later)
			_memory_visibles = [];
			
			//Feed from visible screen's _memory_stash_interactives
			_feedstack_interaction = [];
			_feedstack_animation = [];
			//_feedstack_render = [];
			
			//Added and then processed
			_callstack_recalculate = [];
			
			_memory_styles = [];
			//-------------------------------
			//--METHODS--
			_method_flush_animation = function(){
				array_delete(_feedstack_animation,0,array_length(_feedstack_animation));
				var n = array_length(_memory_visibles);
				var i = 0;
				repeat(n) {
					var nn = array_length(_memory_visibles[i]._memory_stash_animation);
					var ii = 0;
					repeat(nn) {
						array_push(_feedstack_animation,_memory_visibles[i]._memory_stash_animation[ii]);
					ii++;
					};
				i++;
				};
			};
			_method_flush_interaction = function(){
				array_delete(_feedstack_interaction,0,array_length(_feedstack_interaction));
				var n = array_length(_memory_visibles);
				var i = 0;
				repeat(n) {
					var nn = array_length(_memory_visibles[i]._memory_stash_interaction);
					var ii = 0;
					repeat(nn) {
						array_push(_feedstack_interaction,_memory_visibles[i]._memory_stash_interaction[ii]);
					ii++;
					};
				i++;
				};
			};
			_method_flush_render = function(){
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
				
			_method_process_animated = function(){
				for(var i = 0; i < array_length(_feedstack_animation); i++){
					if(array_length(_feedstack_animation[i]._callstack_animation)=0){continue;};
					var anim = _feedstack_animation[i]._callstack_animation[0];
					var memory = _feedstack_animation[i]._memory_animation[anim._animation];
					
					if(!anim._animation_initiated){
						if(_feedstack_animation[i]._animation_invert){
							_feedstack_animation[i]._animation_positionIndex = [memory._start_position,memory._end_position];
							_feedstack_animation[i]._animation_styleIndex = [memory._start_style,memory._end_style];
						}else{
							_feedstack_animation[i]._animation_positionIndex = [memory._end_position,memory._start_position];
							_feedstack_animation[i]._animation_styleIndex = [memory._end_style,memory._start_style];
						};
					};
					if(anim._remaining_duration <= 0 && memory._pesistent = false){
						memory._finish_method(_feedstack_animation[i]);
						//_feedstack_animation[i]._animation_invert = !_feedstack_animation[i]._animation_invert;
						array_delete(_feedstack_animation[i]._callstack_animation,0,1);
						continue;
					};
					var percentage = anim._remaining_duration/memory._duration;
					if(percentage <= memory._interrupt){
						_feedstack_animation[i]._animation_reverse = 1;
					}else{_feedstack_animation[i]._animation_reverse = power(-1,!_feedstack_animation[i]._animation_trigger);};
					
					anim._remaining_duration += -global.gmcs.time_delta * _feedstack_animation[i]._animation_reverse;
					anim._remaining_duration = clamp(anim._remaining_duration,0,memory._duration);
					var pos_percentage = animcurve_channel_evaluate(animcurve_get_channel(memory._position_easing_asset, memory._position_easing_index),percentage);
					var stl_percentage = animcurve_channel_evaluate(animcurve_get_channel(memory._style_easing_asset, memory._style_easing_index),percentage);
					if(_feedstack_animation[i]._animation_invert){_feedstack_animation[i]._animation_positionMerge = 1-pos_percentage;}else{_feedstack_animation[i]._animation_positionMerge = pos_percentage;};
					if(_feedstack_animation[i]._animation_invert){_feedstack_animation[i]._animation_styleMerge = 1-stl_percentage;}else{_feedstack_animation[i]._animation_styleMerge = stl_percentage;};
					global.gmcs._method_mark_recalculate(_feedstack_animation[i]);
				};
			
			};
			_method_process_interaction = function(){
				var i = 0;
				var n = array_length(_feedstack_interaction);
				repeat(n){
					if(	(_feedstack_interaction[i]._info_position[0] < global.gmcs.cursor.x && global.gmcs.cursor.x < _feedstack_interaction[i]._info_position[2]) && 
						(_feedstack_interaction[i]._info_position[1] < global.gmcs.cursor.y && global.gmcs.cursor.y < _feedstack_interaction[i]._info_position[3])){
						_feedstack_interaction[i]._interaction_method_inside(_feedstack_interaction[i]);
					}else{
						_feedstack_interaction[i]._interaction_method_outside(_feedstack_interaction[i]);
					};
				i++;
				};
			};
			_method_process_render = function(c){
				if(c._info_width != c._render_width or c._info_height != c._render_height or c._render_style_merge != c._animation_styleMerge or (!surface_exists(c._memory_styles[c._animation_styleIndex[0]]._surface) or !surface_exists(c._memory_styles[c._animation_styleIndex[1]]._surface))){
					c._render_width = c._info_width;
					c._render_height = c._info_height;
					c._render_style_merge = c._animation_styleMerge;
					
					var p = 0;
					repeat(2){
						#region Preload
						var _xneg_increase = 0;
						var _yneg_increase = 0;
						var _xpos_increase = 0;
						var _ypos_increase = 0;
	
						var _style = c._memory_styles[c._animation_styleIndex[p]]._get_surface_decoration();
						var m = array_length(_style);
						for(var l = 0; l < m; l++){
							if(_style[l]._sprite = noone){continue;};
		
							var _x = (_style[l]._relative[0]/1000)*c._info_width+_style[l]._solid[0];
							var _y = (_style[l]._relative[1]/1000)*c._info_height+_style[l]._solid[1];
							var _w = sprite_get_width(_style[l]._sprite)*_style[l]._x_scale;
							var _h = sprite_get_height(_style[l]._sprite)*_style[l]._y_scale;
							var _xo = sprite_get_xoffset(_style[l]._sprite)*_style[l]._x_scale;
							var _yo = sprite_get_yoffset(_style[l]._sprite)*_style[l]._y_scale;
		
							////////////////////////
		
							var _c1 = _x - _xo; //True negative location
							if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
							var _c2 = ((_x - _xo)+_w); //True positive location
							if(_c2>_xpos_increase+c._info_width){_xpos_increase += _c2-(_xpos_increase+c._info_width)};
		
							var _c1 = _y - _yo; //True negative location
							if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
							var _c2 = ((_y - _yo)+_h); //True positive location
							if(_c2>_ypos_increase+c._info_height){_ypos_increase += _c2-(_ypos_increase+c._info_height)};
		
							/////////////////

							//---------------------------------
							//Mirror
							var __x = (_x-0.5*c._info_width)*-1 + 0.5*c._info_width;
							var __y = (_y-0.5*c._info_height)*-1 + 0.5*c._info_height;
							if(_style[l]._x_mirror){
								var _c1 = ((__x + _xo)-_w); //True negative location
								if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
								var _c2 = (__x + _xo); //True positive location
								if(_c2>_xpos_increase+c._info_width){_xpos_increase += _c2-(_xpos_increase+c._info_width)};
		
								var _c1 = _y - _yo; //True negative location
								if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
								var _c2 = ((_y - _yo)+_h); //True positive location
								if(_c2>_ypos_increase+c._info_height){_ypos_increase += _c2-(_ypos_increase+c._info_height)};
							};
							if(_style[l]._y_mirror){
								var _c1 = _x - _xo; //True negative location
								if(_c1<-_xneg_increase){_xneg_increase += (_c1+_xneg_increase)*-1};
								var _c2 = ((_x - _xo)+_w); //True positive location
								if(_c2>_xpos_increase+c._info_width){_xpos_increase += _c2-(_xpos_increase+c._info_width)};
		
								var _c1 = ((__y + _yo)-_h); //True negative location
								if(_c1<-_yneg_increase){_yneg_increase += (_c1+_yneg_increase)*-1};
								var _c2 = (__y + _yo); //True positive location
								if(_c2>_ypos_increase+c._info_height){_ypos_increase += _c2-(_ypos_increase+c._info_height)};
							};
						};
	
						//var _xx = _xneg_increase;
						//var _yy = _yneg_increase;
	
						var sum_width = c._info_width + _xneg_increase + _xpos_increase;
						var sum_height = c._info_height + _yneg_increase + _ypos_increase;
						c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_offset = [_xneg_increase, _yneg_increase];
						c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_size = [sum_width,sum_height];
						#endregion
						#region Bleach surface
						if(!surface_exists(c._memory_styles[c._animation_styleIndex[p]]._surface)){
							c._memory_styles[c._animation_styleIndex[p]]._surface = surface_create(sum_width,sum_height);
						}else{
							surface_resize(c._memory_styles[c._animation_styleIndex[p]]._surface,sum_width,sum_height);
						};
						surface_set_target(c._memory_styles[c._animation_styleIndex[p]]._surface);
						draw_clear_alpha(c_black,0);
						#endregion
						#region Draw base
						var refer = c._memory_styles[c._animation_styleIndex[p]]._get_surface_reference();
						if(refer[1] != noone){
							draw_sprite_stretched(refer[1],0,_xneg_increase,_yneg_increase,c._info_width,c._info_height);
						};
						#endregion
						#region Decoration
						for(var l = 0; l < m; l++){
							if(_style[l]._sprite = noone){continue;};
							var _x = (_style[l]._relative[0]/1000)*c._info_width+_style[l]._solid[0];
							var _y = (_style[l]._relative[1]/1000)*c._info_height+_style[l]._solid[1];
							var __x = (_x-0.5*c._info_width)*-1 + 0.5*c._info_width;
							var __y = (_y-0.5*c._info_height)*-1 + 0.5*c._info_height;
		
							draw_sprite_ext(_style[l]._sprite,0,_xneg_increase+_x,_yneg_increase+_y,_style[l]._x_scale,_style[l]._y_scale,_style[l]._rotation,_style[l]._blend,_style[l]._alpha);
		
							if(_style[l]._x_mirror){
								draw_sprite_ext(_style[l]._sprite,0,_xneg_increase+__x,_yneg_increase+_y,_style[l]._x_scale*power(-1,_style[l]._true_mirror),_style[l]._y_scale,_style[l]._rotation*power(-1,_style[l]._true_mirror),_style[l]._blend,_style[l]._alpha);
							};
							if(_style[l]._y_mirror){
								draw_sprite_ext(_style[l]._sprite,0,_xneg_increase+_x,_yneg_increase+__y,_style[l]._x_scale,_style[l]._y_scale*power(-1,_style[l]._true_mirror),_style[l]._rotation*power(-1,_style[l]._true_mirror),_style[l]._blend,_style[l]._alpha);
							};
							if(_style[l]._x_mirror & _style[l]._y_mirror){
								draw_sprite_ext(_style[l]._sprite,0,_xneg_increase+__x,_yneg_increase+__y,_style[l]._x_scale*power(-1,_style[l]._true_mirror),_style[l]._y_scale*power(-1,_style[l]._true_mirror),_style[l]._rotation,_style[l]._blend,_style[l]._alpha);
							};
						};
						surface_reset_target();
						#endregion
						#region Calculate font
						if(c._memory_styles[c._animation_styleIndex[p]]._get_font() != noone){draw_set_font(c._memory_styles[c._animation_styleIndex[p]]._get_font());};
						
						var sc = gmcs_getscale_fit(c,string_width(c._render_text),string_height(c._render_text));
						switch(c._memory_styles[c._animation_styleIndex[p]]._get_font_halign()){
							default:
								var xx = c._info_x;
							break;
							case fa_left:
								var real_string_width = string_width(c._render_text)*sc;
								//var real_string_height = string_height(c._render_text)*sc;
								var xx = c._info_position[0] + real_string_width/2;
								xx += c._memory_styles[c._animation_styleIndex[p]]._get_font_margin()*sc;
								//xx += (real_string_height - real_string_height*c._memory_styles[c._animation_styleIndex[p]]._font_size)*0.5;
								xx -= real_string_width*(1-c._memory_styles[c._animation_styleIndex[p]]._get_font_size())*0.5;
							break;
							case fa_right:
								var real_string_width = string_width(c._render_text)*sc;
								//var real_string_height = string_height(c._render_text)*sc;
								var xx = c._info_position[2] - real_string_width/2;
								xx -= c._memory_styles[c._animation_styleIndex[p]]._get_font_margin()*sc;
								//xx -= (real_string_height - real_string_height*c._memory_styles[c._animation_styleIndex[p]]._font_size)*0.5;
								xx += real_string_width*(1-c._memory_styles[c._animation_styleIndex[p]]._get_font_size())*0.5;
							break;
						};
						sc *= c._memory_styles[c._animation_styleIndex[p]]._get_font_size();
						
						c._memory_styles[c._animation_styleIndex[p]]._font_x = xx + c._memory_styles[c._animation_styleIndex[p]]._get_font_hoffset();
						c._memory_styles[c._animation_styleIndex[p]]._font_y = c._info_y + c._memory_styles[c._animation_styleIndex[p]]._get_font_voffset()
						c._memory_styles[c._animation_styleIndex[p]]._font_scale = sc;
						#endregion
					p++;
					};

					c._memory_styles[c._animation_styleIndex[0]]._surface_alpha_merged = lerp(c._memory_styles[c._animation_styleIndex[0]]._get_surface_alpha(),0,c._animation_styleMerge);
					c._memory_styles[c._animation_styleIndex[1]]._surface_alpha_merged = lerp(0,c._memory_styles[c._animation_styleIndex[1]]._get_surface_alpha(),c._animation_styleMerge);
					
					var b1 = c._memory_styles[c._animation_styleIndex[0]]._get_font_blend();
					var b2 = c._memory_styles[c._animation_styleIndex[1]]._get_font_blend();
					c._render_style._font_blend[0] = merge_color(b1[0],b2[0],c._animation_styleMerge);
					c._render_style._font_blend[1] = merge_color(b1[1],b2[1],c._animation_styleMerge);
					c._render_style._font_blend[2] = merge_color(b1[2],b2[2],c._animation_styleMerge);
					c._render_style._font_blend[3] = merge_color(b1[3],b2[3],c._animation_styleMerge);
					c._render_style._font_alpha = lerp(c._memory_styles[c._animation_styleIndex[0]]._get_font_alpha(),c._memory_styles[c._animation_styleIndex[1]]._get_font_alpha(),c._animation_styleMerge);
					
					c._render_style._font_x = lerp(c._memory_styles[c._animation_styleIndex[0]]._font_x,c._memory_styles[c._animation_styleIndex[1]]._font_x,c._animation_styleMerge);
					c._render_style._font_y = lerp(c._memory_styles[c._animation_styleIndex[0]]._font_y,c._memory_styles[c._animation_styleIndex[1]]._font_y,c._animation_styleMerge);
					c._render_style._font_scale = lerp(c._memory_styles[c._animation_styleIndex[0]]._font_scale,c._memory_styles[c._animation_styleIndex[1]]._font_scale,c._animation_styleMerge);
				};
				var p = 0;
				repeat(2){
					draw_surface_stretched_ext(c._memory_styles[c._animation_styleIndex[p]]._surface,
					c._info_position[0] - c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_offset[0],
					c._info_position[1] - c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_offset[1],
					c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_size[0],
					c._memory_styles[c._animation_styleIndex[p]]._spriteReturn_deco_size[1],
					c_white,
					c._memory_styles[c._animation_styleIndex[p]]._surface_alpha_merged
					);
				p++;
				};
				draw_text_transformed_color(c._render_style._font_x,c._render_style._font_y,c._render_text,c._render_style._font_scale,c._render_style._font_scale,0,c._render_style._font_blend[0],c._render_style._font_blend[1],c._render_style._font_blend[2],c._render_style._font_blend[3],c._render_style._font_alpha);
			};
			//////////////////////////////////////////////////////////////////////////////////////////	
			_inherit_get_position_relative = function(__container,__position){
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
			_inherit_get_position_solid = function(__container,__position){
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
			
			_inherit_set_visible = function(__container, __visibility){
				__container._info_visible_self = __visibility;
				__container._info_visible_real = __container._info_parent._info_visible_real && __container._info_visible_self;
				if(__container._info_visible_real = 1){
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
			_inherit_add_position_solid = function(__container, __pos_solid, __pos_relative) {
				var i = array_length(__container._memory_positions);
			    __container._memory_positions[i] = [__pos_solid, __pos_relative, UI.type_solid];
			    return i;
			};
			_inherit_add_position_relative = function(__container, __pos_solid, __pos_relative, __target) {
				var i = array_length(__container._memory_positions);
			    __container._memory_positions[i] = [__pos_solid, __pos_relative, UI.type_relative, __target];
			    return i;
			};
			_inherit_add_position_solid_from = function(__container, __position, __pos_solid, __pos_relative){
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
			    return _inherit_add_position_solid(__container,[_x1_s,_x2_s,_y1_s,_y2_s],[_x1_r,_x2_r,_y1_r,_y2_r]);
			};
			
			_inherit_emptyFunction = function(_self){};
			
			_inherit_add_localStyle = function(__container,__global_style_index,_local_style) {
				var index = array_length(__container._memory_styles);
				__container._memory_styles[index] = _local_style;
				with(__container._memory_styles[index]){
					_surface = -1;
					_spriteReturn_deco_offset = [];
					_spriteReturn_deco_size = [];
					_global_style_index = __global_style_index;
					
					//_sprite_alpha_merged = 0;
					_surface_alpha_merged = 0;
					_font_x = 0;
					_font_y = 0;
					_font_scale = 0;
					
					_get_sprite = function(){return global.gmcs._memory_styles[_global_style_index]._sprite;};
					_get_sprite_scale = function(){return global.gmcs._memory_styles[_global_style_index]._sprite_scale;};
					_get_sprite_alpha = function(){return global.gmcs._memory_styles[_global_style_index]._sprite_alpha;};
					_get_surface_scale = function(){return global.gmcs._memory_styles[_global_style_index]._surface_scale;};
					_get_surface_reference = function(){return global.gmcs._memory_styles[_global_style_index]._surface_reference;};
					_get_surface_decoration = function(){return global.gmcs._memory_styles[_global_style_index]._surface_decoration;};
					_get_surface_alpha = function(){return global.gmcs._memory_styles[_global_style_index]._surface_alpha;};
					_get_font = function(){return global.gmcs._memory_styles[_global_style_index]._font;};
					_get_font_blend = function(){return global.gmcs._memory_styles[_global_style_index]._font_blend;};
					_get_font_alpha = function(){return global.gmcs._memory_styles[_global_style_index]._font_alpha;};
					_get_font_size = function(){return global.gmcs._memory_styles[_global_style_index]._font_size;};
					_get_font_halign = function(){return global.gmcs._memory_styles[_global_style_index]._font_halign;};
					_get_font_margin = function(){return global.gmcs._memory_styles[_global_style_index]._font_margin;};
					_get_font_hoffset = function(){return global.gmcs._memory_styles[_global_style_index]._font_hoffset;};
					_get_font_voffset = function(){return global.gmcs._memory_styles[_global_style_index]._font_voffset;};
					
					_getG_sprite = function(){return _sprite;};
					_getG_sprite_scale = function(){return _sprite_scale;};
					_getG_sprite_alpha = function(){return _sprite_alpha;};
					_getG_surface_scale = function(){return _surface_scale;};
					_getG_surface_reference = function(){return _surface_reference;};
					_getG_surface_decoration = function(){return _surface_decoration;};
					_getG_surface_alpha = function(){return _surface_alpha;};
					_getG_font = function(){return _font;};
					_getG_font_blend = function(){return _font_blend;};
					_getG_font_alpha = function(){return _font_alpha;};
					_getG_font_size = function(){return _font_size;};
					_getG_font_halign = function(){return _font_halign;};
					_getG_font_margin = function(){return _font_margin;};
					_getG_font_hoffset = function(){return _font_hoffset;};
					_getG_font_voffset = function(){return _font_voffset;};
					
				};
				var s = __container._memory_styles[index];
				if(variable_struct_exists(s,"_sprite")){s._get_sprite = s._getG_sprite;};
				if(variable_struct_exists(s,"_sprite_scale")){s._get_sprite_scale = s._getG_sprite_scale;};
				if(variable_struct_exists(s,"_sprite_alpha")){s._get_sprite_alpha = s._getG_sprite_alpha;};
				if(variable_struct_exists(s,"_surface_scale")){s._get_surface_scale = s._getG_surface_scale;};
				if(variable_struct_exists(s,"_surface_reference")){s._get_surface_reference = s._getG_surface_reference;};
				if(variable_struct_exists(s,"_surface_decoration")){s._get_surface_decoration = s._getG_surface_decoration;};
				if(variable_struct_exists(s,"_surface_alpha")){s._get_surface_alpha = s._getG_surface_alpha;};
				if(variable_struct_exists(s,"_font")){s._get_font = s._getG_font;};
				if(variable_struct_exists(s,"_font_blend")){s._get_font_blend = s._getG_font_blend;};
				if(variable_struct_exists(s,"_font_alpha")){s._get_font_alpha = s._getG_font_alpha;};
				if(variable_struct_exists(s,"_font_size")){s._get_font_size = s._getG_font_size;};
				if(variable_struct_exists(s,"_font_halign")){s._get_font_halign = s._getG_font_halign;};
				if(variable_struct_exists(s,"_font_margin")){s._get_font_margin = s._getG_font_margin;};
				if(variable_struct_exists(s,"_font_hoffset")){s._get_font_hoffset = s._getG_font_hoffset;};
				if(variable_struct_exists(s,"_font_voffset")){s._get_font_voffset = s._getG_font_voffset;};
				return index;
				
			};
			_inherit_create_globalStyle = function(_style) {
				var index = array_length(_memory_styles);
				_memory_styles[index] = {
					_sprite : noone,
					_sprite_scale : 1,
					_sprite_alpha : 1,
					
					_surface_scale : 1,
					_surface_reference : [noone, noone],
					_surface_decoration : [],
					_surface_alpha : 1,
					_font : noone,
					_font_blend : [c_white,c_white,c_white,c_white],
					_font_alpha : 1,
					_font_size : 0.5,
					
					_font_halign : fa_center,
					_font_margin : 0,
					_font_hoffset : 0,
					_font_voffset : 0,
				};
				var s = _memory_styles[index];
				if(variable_struct_exists(_style,"_sprite")){s._sprite = _style._sprite;};
				if(variable_struct_exists(_style,"_sprite_scale")){s._sprite_scale = _style._sprite_scale;};
				if(variable_struct_exists(_style,"_sprite_alpha")){s._sprite_alpha = _style._sprite_alpha;};
				if(variable_struct_exists(_style,"_surface_scale")){s._surface_scale = _style._surface_scale;};
				if(variable_struct_exists(_style,"_surface_reference")){s._surface_reference = _style._surface_reference;};
				if(variable_struct_exists(_style,"_surface_decoration")){s._surface_decoration = _style._surface_decoration;};
				if(variable_struct_exists(_style,"_surface_alpha")){s._surface_alpha = _style._surface_alpha;};
				if(variable_struct_exists(_style,"_font")){s._font = _style._font;};
				if(variable_struct_exists(_style,"_font_blend")){s._font_blend = _style._font_blend;};
				if(variable_struct_exists(_style,"_font_alpha")){s._font_alpha = _style._font_alpha;};
				if(variable_struct_exists(_style,"_font_size")){s._font_size = _style._font_size;};
				if(variable_struct_exists(_style,"_font_halign")){s._font_halign = _style._font_halign;};
				if(variable_struct_exists(_style,"_font_margin")){s._font_margin = _style._font_margin;};
				if(variable_struct_exists(_style,"_font_hoffset")){s._font_hoffset = _style._font_hoffset;};
				if(variable_struct_exists(_style,"_font_voffset")){s._font_voffset = _style._font_voffset;};
				return index;
			};
			
			_inherit_add_animation = function(__container,__animation){
				var index = array_length(__container._memory_animation);
				__container._memory_animation[index] = {
					_self : __container,
					_start_position : 0,
					_end_position : 0,
					_duration : 100,
					_interrupt : 0,
					_pesistent : 0,
					_finish_method : global.gmcs._inherit_emptyFunction,
					_position_easing_asset : GMCS_smoothing,
					_position_easing_index : 0,
					_start_style : 0,
					_end_style : 0,
					_style_easing_asset : GMCS_smoothing,
					_style_easing_index : 0,
				};
				if(variable_struct_exists(__animation,"_start_position")){__container._memory_animation[index]._start_position = __animation._start_position;};
				if(variable_struct_exists(__animation,"_end_position")){__container._memory_animation[index]._end_position = __animation._end_position;};
				if(variable_struct_exists(__animation,"_duration")){__container._memory_animation[index]._duration = __animation._duration;};
				if(variable_struct_exists(__animation,"_interrupt")){__container._memory_animation[index]._interrupt = __animation._interrupt;};
				if(variable_struct_exists(__animation,"_pesistent")){__container._memory_animation[index]._pesistent = __animation._pesistent;};
				if(variable_struct_exists(__animation,"_finish_method")){__container._memory_animation[index]._finish_method = __animation._finish_method;};
				if(variable_struct_exists(__animation,"_position_easing_asset")){__container._memory_animation[index]._position_easing_asset = __animation._position_easing_asset;};
				if(variable_struct_exists(__animation,"_position_easing_index")){__container._memory_animation[index]._position_easing_index = __animation._position_easing_index;};
				if(variable_struct_exists(__animation,"_start_style")){__container._memory_animation[index]._start_style = __animation._start_style;};
				if(variable_struct_exists(__animation,"_end_style")){__container._memory_animation[index]._end_style = __animation._end_style;};
				if(variable_struct_exists(__animation,"_style_easing_asset")){__container._memory_animation[index]._style_easing_asset = __animation._style_easing_asset;};
				if(variable_struct_exists(__animation,"_style_easing_index")){__container._memory_animation[index]._style_easing_index = __animation._style_easing_index;};
				return index;
			};
			_inherit_call_animation = function(__container,__animation){
				
				//Register itself into the screen animation stash
				var n = array_length(__container._info_screen._memory_stash_animation);
			    var i = 0;
				var found = -1;
			    repeat(n) {
			        if(__container._info_screen._memory_stash_animation[i] = __container){found = i;break;};
			        i++;
			    };
				if(found = -1){__container._info_screen._memory_stash_animation[n] = __container};
				
				
				var index = array_length(__container._callstack_animation);
				__container._callstack_animation[index] = {
					_animation_initiated : false,
					_animation : __animation,
					_remaining_duration : __container._memory_animation[__animation]._duration,
				};
			};
			_inherit_set_interaction = function(__container,__interaction_inside,__interaction_outside){
				//Register itself into the screen interaction stash
				var n = array_length(__container._info_screen._memory_stash_interaction);
			    var i = 0;
				var found = -1;
			    repeat(n) {
			        if(__container._info_screen._memory_stash_interaction[i] = __container){found = i;break;};
			        i++;
			    };
				if(found = -1){__container._info_screen._memory_stash_interaction[n] = __container};
				
				__container._interaction_method_inside = __interaction_inside;
				__container._interaction_method_outside = __interaction_outside;
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
			_info_visible_real = 0;
			_info_screen = self;
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			
			_memory_stash_render = [];
			_memory_stash_animation = [];
			_memory_stash_interaction = [];
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
				_info_visible_real = __visibility;
				var n = array_length(global.gmcs._memory_visibles);
			    var i = 0;
				var found = -1;
			    repeat(n) {
			        if(global.gmcs._memory_visibles[i] = self){found = i;break;};
			        i++;
			    };
				if(_info_visible_real = 1){
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
			_method_setVisible(_info_visible_real);
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
			_info_visible_real = 1;
			_info_visible_self = 1;
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			_memory_positions = [[__pos_solid,__pos_relative, UI.type_solid]];
			_memory_animation = [];
			//-------------------------------
			//--INTERACTION--
			_interaction_method_inside = global.gmcs._inherit_emptyFunction;
			_interaction_method_outside = global.gmcs._inherit_emptyFunction;
			//-------------------------------
			//--ANIMATION--
			_animation_positionIndex = [0,0];
			_animation_styleIndex = [0,0];
			_animation_positionMerge = 0;
			_animation_styleMerge = 0;
			_animation_trigger = 0;
			_animation_invert = 0; //Not needed anymore
			_animation_reverse = 1; // 1 or -1 depending if trigger is on or off.

			_callstack_animation = [];
			//-------------------------------
			//--RENDER--
			_memory_styles = [];
			
			_render_height = 0;
			_render_width = 0;
			_render_style_merge = 0;
			_render_text = "";
			_render_style = {
				_font : noone,
				_font_blend : [c_white,c_white,c_white,c_white],
				_font_alpha : 1,
				_font_scale : 1,
				_font_x : 0,
				_font_y : 0,
			};
			//-------------------------------
			//--METHODS--
			static _method_recalculate = function(){
				var _v1 = global.gmcs._inherit_get_position_relative(self,_animation_positionIndex[0]);
				var _v2 = global.gmcs._inherit_get_position_relative(self,_animation_positionIndex[1]);
				_info_position[0] = lerp(_v1[0],_v2[0],_animation_positionMerge);
				_info_position[1] = lerp(_v1[1],_v2[1],_animation_positionMerge);
				_info_position[2] = lerp(_v1[2],_v2[2],_animation_positionMerge);
				_info_position[3] = lerp(_v1[3],_v2[3],_animation_positionMerge);
				_info_width = _info_position[2] - _info_position[0];
				_info_height = _info_position[3] - _info_position[1];
				_info_x = _info_position[0]+_info_width/2;
				_info_y = _info_position[1]+_info_height/2;
			};
			static _method_setVisible = function(__visibility){
				global.gmcs._inherit_set_visible(self, __visibility);
			};
			static _method_addStyle = function(__style = {}) {
				global.gmcs._inherit_add_localStyle(self, __style);
			};
		
			_method_recalculate();
			_method_setVisible(_info_visible_real);
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
			_info_visible_real = 1;
			_info_visible_self = 1;
			//-------------------------------
			//--MEMORY--
			_memory_containers = [];
			_memory_positions = [[__size,__anchor,[1,1],__scale_type]];
			_memory_animation = [];
			//-------------------------------
			//--INTERACTION--
			_interaction_method_inside = global.gmcs._inherit_emptyFunction;
			_interaction_method_outside = global.gmcs._inherit_emptyFunction;
			//-------------------------------
			//--ANIMATION--
			_animation_positionIndex = [0,0];
			_animation_styleIndex = [0,0];
			_animation_positionMerge = 0;
			_animation_styleMerge = 0;
			_animation_trigger = 0;
			_animation_invert = 0; //Not needed anymore
			_animation_reverse = 1; // 1 or -1 depending if trigger is on or off.

			_callstack_animation = [];
			//-------------------------------
			//--RENDER--
			_memory_styles = [];
			
			_render_height = 0;
			_render_width = 0;
			_render_style_merge = 0;
			_render_text = "";
			_render_style = {
				_font : noone,
				_font_blend : [c_white,c_white,c_white,c_white],
				_font_alpha : 1,
				_font_scale : 1,
				_font_x : 0,
				_font_y : 0,
			};
			//-------------------------------
			//--METHODS--
			static _method_recalculate = function(){
				//This will recalculate the container
				var _v1 = global.gmcs._inherit_get_position_solid(self,_animation_positionIndex[0]);
				var _v2 = global.gmcs._inherit_get_position_solid(self,_animation_positionIndex[1]);
				
				_info_position[0] = lerp(_v1[0],_v2[0],_animation_positionMerge);
				_info_position[1] = lerp(_v1[1],_v2[1],_animation_positionMerge);
				_info_position[2] = lerp(_v1[2],_v2[2],_animation_positionMerge);
				_info_position[3] = lerp(_v1[3],_v2[3],_animation_positionMerge);

				_info_width = _info_position[2] - _info_position[0];
				_info_height = _info_position[3] - _info_position[1];
				_info_x = _info_position[0]+_info_width/2;
				_info_y = _info_position[1]+_info_height/2;
			};
			static _method_setVisible = function(__visibility){
				global.gmcs._inherit_set_visible(self, __visibility);
			}
			static _method_addStyle = function(__style = {}) {
				global.gmcs._inherit_add_localStyle(self, __style);
			};
			
			_method_recalculate();
			_method_setVisible(_info_visible_real);
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
	function gmcs_create_globalStyle(_style = {}){
		return global.gmcs._inherit_create_globalStyle(_style);
	};
	function gmcs_add_localStyle(_container, _global_style, _style = {}){
		return global.gmcs._inherit_add_localStyle(_container,_global_style,_style);
	};
	function gmcs_add_animation(_container, _animation = {}){
		return global.gmcs._inherit_add_animation(_container,_animation);
	};
	function gmcs_call_animation(_container, _animation){
		global.gmcs._inherit_call_animation(_container,_animation);
	};
	function gmcs_set_interaction(_container,_interaction_inside = global.gmcs._inherit_emptyFunction,_interaction_outside = global.gmcs._inherit_emptyFunction){
		global.gmcs._inherit_set_interaction(_container,_interaction_inside,_interaction_outside);
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
	#region Cursor set
		/// @description This will set sprite to a cursor. Frame 1 - default, Frame 2 - default highlight,
		/// Frame 3 - hand, Frame 4 - hand highlight, Frame 5 - gamepad, Frame 6 - gamepad highlight
		/// @function gmcs_cursor_set_image(image_sheet)
		/// @param {GM.sprite} image_sheet Sprite with 6 frames containing diffrent cursor versions
		/// @self
		/// @return noone
		function gmcs_cursor_set_image(__sheet){
			global.gmcs.cursor.sprite_index = __sheet;
			window_set_cursor(cr_none);
		}
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
			if(__container._info_visible_real){
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