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
//////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
//======================================================================================//
#region CONSTRUCTORS
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_init();
	/// @description Creates a GMCS handler object.
	function gmcs_init() {
		global.gmcs = {};
		with(global.gmcs){
		//-------------------------------
		//--MEMORY--
		_memory_screens = [];
		_memory_visibles = [];
		_callstack_recalculate = [];
		//-------------------------------
		//--METHODS--
		_method_mark_recalculate = function(__container){
			_callstack_recalculate[array_length(_callstack_recalculate)] = __container;
			var n = array_length(__container._memory_containers);
		    var i = 0;
		    repeat(n) {
		        _method_mark_recalculate(__container._memory_containers[i]);
		        i++;
		    };
		};
		_method_process_recalculate = function(){
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
	};};
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_screen();
	/// @description Creates a new GUI component.
	function gmcs_screen() constructor {
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
		//-------------------------------
		//--MEMORY--
		_memory_containers = [];
		//-------------------------------
		//--METHODS--
		static _method_recalculate = function(){
			_info_width = global.screen_width;
			_info_height = global.screen_height;
			_info_position = [0,0,global.screen_width,global.screen_height];
			_info_x = global.screen_width/2;
			_info_y = global.screen_height/2;
		};
		static _method_setVisible = function(__visibility){
			_info_visible = __visibility;
			var p = array_length(global.gmcs._memory_visibles);
		    var i = 0;
			var found = -1;
		    repeat(p) {
		        if(global.gmcs._memory_visibles[i] = self){found = i;break;};
		        i++;
		    };
			if(_info_visible = 1){
				if(found = -1){global.gmcs._memory_visibles[array_length(global.gmcs._memory_visibles)] = self;};
			} else {
				if(found != -1){array_delete(global.gmcs._memory_visibles,found,1);};
				global.gmcs._method_mark_recalculate(self);
			};
			var p = array_length(_memory_containers);
	        var i = 0;
	        repeat(p) {
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
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_relative_container(parent, solid_positions, relative_positions);
	/// @param {struct} parent
	/// @param {array} solid_positions
	/// @param {array} relative_positions
	/// @description Creates a new GUI component.
	function gmcs_relative_container(__parent, __pos_solid, __pos_relative) constructor {
		//-------------------------------
		//--INFO--
		_info_width = 0;
		_info_height = 0;
		_info_position = [0,0,0,0];
		_info_x = 0;
		_info_y = 0;
		_info_parent = __parent;
		_info_layer = _info_parent._info_layer + 1;
		_info_type = UI.type_relative;
		_info_visible = 1;
		_info_selfVisible = 1;
		//-------------------------------
		//--MEMORY--
		_memory_containers = [];
		_memory_positions = [[__pos_solid,__pos_relative]];
		//_memory_animation = [];
		//_memory_styles = [];
		//-------------------------------
		//--ANIMATION--
		_animation_positionIndex = [0,0];
		_animation_merge = 0;
		//-------------------------------
		//--METHODS--
		static _method_recalculate = function(){
			var xsc = (_info_parent._info_width) / 1000; //Takes current real width
			var ysc = (_info_parent._info_height) / 1000; //Takes current real height
			//Use matrix next time
			var x1_vector_1 = _memory_positions[_animation_positionIndex[0]][0][0] + _memory_positions[_animation_positionIndex[0]][1][0] * xsc;
			var y1_vector_1 = _memory_positions[_animation_positionIndex[0]][0][1] + _memory_positions[_animation_positionIndex[0]][1][1] * ysc;
			var x2_vector_1 = _memory_positions[_animation_positionIndex[0]][0][2] + _memory_positions[_animation_positionIndex[0]][1][2] * xsc;
			var y2_vector_1 = _memory_positions[_animation_positionIndex[0]][0][3] + _memory_positions[_animation_positionIndex[0]][1][3] * ysc;
				
			var x1_vector_2 = _memory_positions[_animation_positionIndex[1]][0][0] + _memory_positions[_animation_positionIndex[1]][1][0] * xsc;
			var y1_vector_2 = _memory_positions[_animation_positionIndex[1]][0][1] + _memory_positions[_animation_positionIndex[1]][1][1] * ysc;
			var x2_vector_2 = _memory_positions[_animation_positionIndex[1]][0][2] + _memory_positions[_animation_positionIndex[1]][1][2] * xsc;
			var y2_vector_2 = _memory_positions[_animation_positionIndex[1]][0][3] + _memory_positions[_animation_positionIndex[1]][1][3] * ysc;
				
			_info_position[0] = _info_parent._info_position[0] + x1_vector_1 + (x1_vector_2 - x1_vector_1) * _animation_merge;
			_info_position[1] = _info_parent._info_position[1] + y1_vector_1 + (y1_vector_2 - y1_vector_1) * _animation_merge;
			_info_position[2] = _info_parent._info_position[0] + x2_vector_1 + (x2_vector_2 - x2_vector_1) * _animation_merge;
			_info_position[3] = _info_parent._info_position[1] + y2_vector_1 + (y2_vector_2 - y2_vector_1) * _animation_merge;

			_info_width = _info_position[2] - _info_position[0];
			_info_height = _info_position[3] - _info_position[1];
			_info_x = _info_position[0]+_info_width/2;
			_info_y = _info_position[1]+_info_height/2;
		};
		static _method_setVisible = function(__visibility){
			_info_selfVisible = __visibility;
			_info_visible = _info_parent._info_visible && _info_selfVisible;
			if(_info_visible = 1){global.gmcs._method_mark_recalculate(self);};
			var p = array_length(_memory_containers);
	        var i = 0;
	        repeat(p) {
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
		_info_parent._memory_containers[array_length(_info_parent._memory_containers)] = self;
	};
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_solid_container(parent, size, anchor, scale_type);
	/// @param {struct} parent
	/// @param {array} size
	/// @param {array} anchor
	/// @param {enum} scale_type
	/// @description Creates a new GUI component.
	function gmcs_solid_container(__parent, __size, __anchor, __scale_type) constructor {
		//-------------------------------
		//--INFO--
		_info_width = 0;
		_info_height = 0;
		_info_position = [0,0,0,0];
		_info_x = 0;
		_info_y = 0;
		_info_parent = __parent;
		_info_layer = _info_parent._info_layer + 1;
		_info_type = UI.type_solid;
		_info_visible = 1;
		_info_selfVisible = 1;
		//-------------------------------
		//--MEMORY--
		_memory_containers = [];
		_memory_positions = [[__size,__anchor,[1,1],__scale_type]];
		//_memory_animation = [];
		//_memory_styles = [];
		//-------------------------------
		//--ANIMATION--
		_animation_positionIndex = [0,0];
		_animation_merge = 0;
		//-------------------------------
		//--METHODS--
		static _method_recalculate = function(){
			var type_1 = _memory_positions[_animation_positionIndex[0]][3];
			var width_1 = _memory_positions[_animation_positionIndex[0]][0][0];
			var height_1 = _memory_positions[_animation_positionIndex[0]][0][1];
			if (type_1 = UI.scale_fit) {var sc = gmcs_getscale_fit(_info_parent, width_1, height_1);} else {var sc = gmcs_getscale_fill(_info_parent, width_1, height_1);};
			width_1 *= sc;
			height_1 *= sc;
			
			var type_2 = _memory_positions[_animation_positionIndex[1]][3];
			var width_2 = _memory_positions[_animation_positionIndex[1]][0][0];
			var height_2 = _memory_positions[_animation_positionIndex[1]][0][1];
			if (type_2 = UI.scale_fit) {var sc = gmcs_getscale_fit(_info_parent, width_2, height_2);} else { var sc = gmcs_getscale_fill(_info_parent, width_2, height_2);};
			width_2 *= sc;
			height_2 *= sc;
			
	        _info_position[0] = _info_parent._info_x - (width_1 + (width_2-width_1) * _animation_merge) / 2;
	        _info_position[1] = _info_parent._info_y - (height_1 + (height_2-height_1) * _animation_merge) / 2;
	        _info_position[2] = _info_parent._info_x + (width_1 + (width_2-width_1) * _animation_merge) / 2;
	        _info_position[3] = _info_parent._info_y + (height_1 + (height_2-height_1) * _animation_merge) / 2;
				
	        _info_width = _info_position[2] - _info_position[0];
			_info_height = _info_position[3] - _info_position[1];
			_info_x = _info_position[0]+_info_width/2;
			_info_y = _info_position[1]+_info_height/2;
			
			switch(_memory_positions[_animation_positionIndex[0]][1][0]){
				case UI.anchor_left:
					var c = (_info_parent._info_position[0] - _info_position[0])*_memory_positions[_animation_positionIndex[0]][2][0];
					_info_x += c;
					_info_position[0] += c;
					_info_position[2] += c;
					break;
				case UI.anchor_right:
					var c = (ui_info._parent.ui_info.x1 - ui_info.x1)*ui_inventory.positions[ui_animation.position_real].x_anchor_offset;
					_info_x -= c;
					_info_position[0] -= c;
					_info_position[2] -= c;
					break;
			};
			switch(_memory_positions[_animation_positionIndex[0]][1][1]){
				case UI.anchor_bottom:
					var c = (_info_parent._info_position[1] - _info_position[1])*_memory_positions[_animation_positionIndex[0]][2][1];
					_info_y -= c;
					_info_position[1] -= c;
					_info_position[3] -= c;
					break;
				case UI.anchor_top:
					var c = (_info_parent._info_position[1] - _info_position[1])*_memory_positions[_animation_positionIndex[0]][2][1];
					_info_y += c;
					_info_position[1] += c;
					_info_position[3] += c;
					break;
			};
		};
		static _method_setVisible = function(__visibility){
			_info_selfVisible = __visibility;
			_info_visible = _info_parent._info_visible && _info_selfVisible;
			if(_info_visible = 1){global.gmcs._method_mark_recalculate(self);};
			var p = array_length(_memory_containers);
	        var i = 0;
	        repeat(p) {
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
		_info_parent._memory_containers[array_length(_info_parent._memory_containers)] = self;
	};
#endregion
//======================================================================================//
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
//======================================================================================//
#region SCRIPT CALLS
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_mark_recalculate_active();
	/// @description This command will mark all active screens for recalculation.
	function gmcs_mark_recalculate_active(){
	var p = array_length(global.gmcs._memory_visibles);
	var i = 0;
	repeat(p) {
		global.gmcs._method_mark_recalculate(global.gmcs._memory_visibles[i]);
		i++;
	};
};
#endregion
//======================================================================================//
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
//======================================================================================//
#region DRAW CALLS
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_draw_container(container);
	/// @param {struct} container
	/// @description Place this in DRAW GUI, it will draw container with all its components.
	function gmcs_draw_container(__container) {
		if(__container._info_visible){draw_rectangle(__container._info_position[0],__container._info_position[1],__container._info_position[2],__container._info_position[3],1);}
	    //LOOP------------------------------------------
	    var n = array_length(__container._memory_containers);
	    var i = 0;
	    repeat(n) {
	        gmcs_draw_container(__container._memory_containers[i]);
	        i++;
	    };
	};
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_draw_visible();
	/// @description Place this in DRAW GUI, it will draw container with all its components.
	function gmcs_draw_visible() {
		var p = array_length(global.gmcs._memory_visibles);
		var i = 0;
		repeat(p) {
			gmcs_draw_container(global.gmcs._memory_visibles[i]);
			i++;
		};
	};
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_getscale_fill(container, width, height);
	/// @param {struct} container
	/// @param {struct} width
	/// @param {struct} height
	/// @description Returns scale to fill the container
	function gmcs_getscale_fill(__container, __width, __height) {
	    return max(__container._info_width/__width, __container._info_height/__height);
	};
//////////////////////////////////////////////////////////////////////////////////////////
	/// @function gmcs_getscale_fit(container, width, height);
	/// @param {struct} container
	/// @param {struct} width
	/// @param {struct} height
	/// @description Returns scale to fit the container
	function gmcs_getscale_fit(__container, __width, __height) {
	    return min(__container._info_width/__width, __container._info_height/__height);
	};
#endregion
//======================================================================================//
//////////////////////////////////////////////////////////////////////////////////////////
#endregion