//======================================================================================================================================
//======================================================================================================================================
//--------------------------------------- GameMakerCascadeSheet (GMCS) by Dominik Kaspar -----------------------------------------------
//
// Github repository: https://github.com/IDEDARY/Game-Maker-Cascade-Sheet
// Published under MIT license.
// Version 3.0
//
//======================================================================================================================================
//===================================================== DECLARE FUNCTIONS ==============================================================
#region Func
	function ui_func_declare_container(){
		if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
			funcvar_ui[index] = {index : index,
				parent : noone,
				ui_container_type : 0,
				containers : [],elements : [],positions : [],
				ui_layer : 0,
				ui_active : 1,mouse_in : 0,
				ui_visible_parent : 1,ui_visible_self : 0,ui_visible_valid : 0,
				ui_current_pos : 0, ui_animation_pos1 : 0, ui_animation_pos2 : 0,
				ui_animation_merge : 0,ui_animation_change : 0,ui_animation_input : 0,ui_animation_speed : 5,ui_animation_input_inverze : 1,ui_animation_steady : 1,
			};
		return funcvar_ui[index];
	};
#endregion
//======================================================================================================================================
//===================================================== SCREEN FUNCTIONS ===============================================================
#region SCREENS
	function ui_screen_create(){
		var container = ui_func_declare_container();
		with(container){
			x1 = 0;
			y1 = 0;
		};
		ui_screen_recalculate(container);
		return container;
	};

	function ui_screen_recalculate(screen){
		with(screen){
			x2 = global.screen_width;
			y2 = global.screen_height;
			width = x2-x1;
			height = y2-y1;
			x = width/2;
			y = height/2;
			ui_screen_visible(self,ui_visible_self);
			//LOOP------------------------------------------
			var p = array_length(containers);
			if(p=0){exit;};
			var i = 0;
			repeat(p){
				ui_container_recalculate(containers[i]);
			i++;
			};
		};
	};

	function ui_screen_visible(screen,visibility){
		with(screen){
			ui_visible_self = visibility;
			ui_visible_valid = sign(width*height);
			if(ui_visible_self+ui_visible_valid=2){visible=true;}else{visible=false;};
			//LOOP------------------------------------------
			var p = array_length(containers);
			if(p=0){exit;};
			var i = 0;
			repeat(p){
				ui_container_visible(containers[i],containers[i].ui_visible_self);
			i++;
			};
		};
	};
#endregion
//======================================================================================================================================
//=================================================== CONTAINER FUNCTIONS ==============================================================
#region CONTAINERS
	function ui_container_create(parent,x1_solid,y1_solid,x2_solid,y2_solid,x1_relative,y1_relative,x2_relative,y2_relative){
		var container = ui_func_declare_container();
		container.parent = parent;
		with(container){ui_container_type = 1;ui_layer = parent.ui_layer+1;ui_visible_self = 1;};
			container.positions[0] = {
				x1_solid : x1_solid,
				y1_solid : y1_solid,
				x2_solid : x2_solid,
				y2_solid : y2_solid,
		
				x1_relative : x1_relative,
				y1_relative : y1_relative,
				x2_relative : x2_relative,
				y2_relative : y2_relative,
			};

		//INDEX CONTAINER TO PARENT ARRAY
		var p = array_length(parent.containers);
		parent.containers[p] = container;
		ui_container_recalculate(container);
		
		return container;
	}

	function ui_container_solid_create(parent,width,height,anchor,ui_scale_type){
		var container = ui_func_declare_container();
		container.parent = parent;
		with(container){ui_container_type = 2;ui_layer = parent.ui_layer+1;ui_visible_self = 1;};
		container.positions[0] = {
			ui_scale_type : ui_scale_type,
			ui_anchor : anchor,
			width_ratio : width,
			height_ratio : height,
		};
			
		//INDEX CONTAINER TO PARENT ARRAY
		var p = array_length(parent.containers);
		parent.containers[p] = container;
		ui_container_recalculate(container);
		
		return container;
	}

	function ui_container_recalculate(container){
		if(container.ui_container_type = 1){
			with(container){
				var xsc = (parent.width)/1000;
				var ysc = (parent.height)/1000;
						
				//Calculate VECTORS
				x1_vector_animation_change = positions[ui_animation_pos2].x1_solid + positions[ui_animation_pos2].x1_relative*xsc;
				y1_vector_animation_change = positions[ui_animation_pos2].y1_solid + positions[ui_animation_pos2].y1_relative*ysc;
				x2_vector_animation_change = positions[ui_animation_pos2].x2_solid + positions[ui_animation_pos2].x2_relative*xsc;
				y2_vector_animation_change = positions[ui_animation_pos2].y2_solid + positions[ui_animation_pos2].y2_relative*ysc;
					
				x1_vector = positions[ui_animation_pos1].x1_solid + positions[ui_animation_pos1].x1_relative*xsc;
				y1_vector = positions[ui_animation_pos1].y1_solid + positions[ui_animation_pos1].y1_relative*ysc;
				x2_vector = positions[ui_animation_pos1].x2_solid + positions[ui_animation_pos1].x2_relative*xsc;
				y2_vector = positions[ui_animation_pos1].y2_solid + positions[ui_animation_pos1].y2_relative*ysc;
					
				x1 = parent.x1 + x1_vector + (x1_vector_animation_change - x1_vector)*ui_animation_merge;
				y1 = parent.y1 + y1_vector + (y1_vector_animation_change - y1_vector)*ui_animation_merge;
				x2 = parent.x1 + x2_vector + (x2_vector_animation_change - x2_vector)*ui_animation_merge;
				y2 = parent.y1 + y2_vector + (y2_vector_animation_change - y2_vector)*ui_animation_merge;
						
				width = x2 - x1;
				height = y2 - y1;
				x = x1+width/2;
				y = y1+height/2;
				ui_container_visible(self,ui_visible_self);
			};
		};
		if(container.ui_container_type = 2){
			with(container){
				width_ratio = positions[ui_current_pos].width_ratio;
				height_ratio = positions[ui_current_pos].height_ratio;
				ui_scale_type = positions[ui_current_pos].ui_scale_type;
						
				if(ui_scale_type = 0){var sc = ui_get_scale_for_fit(container.parent,width_ratio,height_ratio);}else{var sc = ui_get_scale_for_fill(container.parent,width_ratio,height_ratio);}
				x1 = parent.x - width_ratio*sc/2;
				y1 = parent.y - height_ratio*sc/2;
				x2 = parent.x + width_ratio*sc/2;
				y2 = parent.y + height_ratio*sc/2;
				width = x2 - x1;
				height = y2 - y1;
				x = parent.x;
				y = parent.y;
				ui_container_visible(self,ui_visible_self);
			};
		};
		//LOOP------------------------------------------
		var p = array_length(container.containers);
		if(p!=0){
			var i = 0;
			repeat(p){
				ui_container_recalculate(container.containers[i]);
			i++;
			};
		};
		//LOOP------------------------------------------
		var p = array_length(container.elements);
		if(p!=0){
			var i = 0;
			repeat(p){
				ui_element_recalculate(container.elements[i])
			i++;
			};
		};
	};

	function ui_container_visible(container,visibility){
		with(container){
			ui_visible_parent = parent.visible;
			ui_visible_self = visibility;
			ui_visible_valid = sign(width*height);
			if(ui_visible_parent+ui_visible_self+ui_visible_valid=3){visible=true;}else{visible=false;};
			if(ui_animation_merge>0.5){ui_current_pos = 1;}else{ui_current_pos = 0;};
			//LOOP------------------------------------------
			var p = array_length(containers);
			if(p!=0){
				var i = 0;
				repeat(p){
					ui_container_visible(containers[i],containers[i].ui_visible_self);
				i++;
				};
			};
			//LOOP------------------------------------------
			var p = array_length(elements);
			if(p!=0){
				var i = 0;
				repeat(p){
					elements[i].visible = visible;
				i++;
				};
			};
		};
	};

	function ui_container_position_add(container,x1_solid,y1_solid,x2_solid,y2_solid,x1_relative,y1_relative,x2_relative,y2_relative){
		var ind = array_length(container.positions)
		container.positions[ind] = {
				x1_solid : x1_solid,
				y1_solid : y1_solid,
				x2_solid : x2_solid,
				y2_solid : y2_solid,
		
				x1_relative : x1_relative,
				y1_relative : y1_relative,
				x2_relative : x2_relative,
				y2_relative : y2_relative,
			};
		ui_container_recalculate(container);
		return ind;
	};
	
	function ui_container_animation_set(container,position){
		switch(container.ui_current_pos){
			case 0 :
				container.ui_animation_pos2 = position;
				container.ui_animation_input_inverze = 1;
				break;
			case 1 :
				container.ui_animation_pos1 = position;
				container.ui_animation_input_inverze = -1;
				break;
		};
	};

	function ui_container_animation_step(container){
		if((container.ui_animation_merge=0 && container.ui_animation_input=0)or(container.ui_animation_merge=1 && container.ui_animation_input=1)){container.ui_animation_steady = true;}else{container.ui_animation_steady = false;};
		if(!container.ui_animation_steady){
			with(container){
				ui_animation_merge = dsin(ui_animation_change);
				ui_animation_change += 1*ui_animation_input*ui_animation_speed*ui_animation_input_inverze;
				ui_animation_change = clamp(ui_animation_change,0,90);
			};
			ui_container_recalculate(container);
		};
		//LOOP------------------------------------------
		var p = array_length(container.containers);
		if(p!=0){
			var i = 0;
			repeat(p){
				ui_container_animation_step(container.containers[i]);
			i++;
			};
		};
	};
	
	function ui_container_animation_speed_set(container,speed){
		container.ui_animation_speed = speed;
	};
	
	function ui_container_animation_speed_get(container){
		return container.ui_animation_speed;
	};
	
	function ui_container_animation_input_set(container,input){
		container.ui_animation_input = input;
	};
	
	function ui_container_animation_input_get(container){
		return container.ui_animation_input;
	};

#endregion
//======================================================================================================================================
//=================================================== ELEMENTS FUNCTIONS ===============================================================
#region Elements
function ui_element_create(container,x_relative,y_relative,type_scale,x_scale,y_scale,object){ //Scale: 0 - fit, 1 - fill, 2 - deform_fill
	if(!layer_exists("Elements")){layer_create(-190,"Elements");}
	
	var xsc = (container.width)/1000;
	var ysc = (container.height)/1000;
	var xx = container.x1 + x_relative*xsc;
	var yy = container.y1 + y_relative*ysc;
	
	var element = instance_create_layer(xx,yy,"Elements",object);
	element.element_active = 1;
	element.element_current_layer = container.ui_layer;
	element.element_container = container;
	element.element_x_relative = x_relative;
	element.element_y_relative = y_relative;
	element.element_type_scale = type_scale;
	element.element_x_scale_mod = x_scale;
	element.element_y_scale_mod = y_scale;
	ui_element_recalculate(element);
	
	var p = array_length(container.elements);
	container.elements[p] = element;
	
	return element;
};

function ui_element_recalculate(element){
	with(element){
		var xsc = (element_container.width)/1000;
		var ysc = (element_container.height)/1000;
		x = element_container.x1 + element_x_relative*xsc;
		y = element_container.y1 + element_y_relative*ysc;
		var xmod = element_x_scale_mod/1000;
		var ymod = element_y_scale_mod/1000;
		switch(element_type_scale){
			case 0: element_x_scale = ui_get_scale_for_fit(element_container,width,height)*xmod;element_y_scale = element_x_scale*sign(ymod);break;
			case 1: element_x_scale = ui_get_scale_for_fill(element_container,width,height)*xmod;element_y_scale = element_x_scale*sign(ymod);break;
			case 2: element_x_scale = element_container.width/width * xmod;element_y_scale = element_container.height/height * ymod;break;
		};
	};
};

function ui_container_step(container){
	with(container){
		if(visible = true && (x1 < mouse_x && mouse_x < x2) && (y1 < mouse_y && mouse_y < y2)){mouse_in = 1;}else{mouse_in = 0;};
	};
	//LOOP------------------------------------------
	var p = array_length(container.containers);
		if(p!=0){
			var i = 0;
			repeat(p){
				ui_container_step(container.containers[i]);
			i++;
			};
		};
};
#endregion
//======================================================================================================================================
//=================================================== DRAW FUNCTIONS ===================================================================
#region Draw
function ui_rectangle_draw(container,draw_invisible){
	if(container.visible = false){
		if(draw_invisible=false){exit;};
		draw_set_color(c_red);
	}else{draw_set_color(c_white);};
	draw_rectangle(container.x1,container.y1,container.x2,container.y2,2);
	draw_set_color(c_white);
};

function ui_container_draw(container,draw_invisible){
	ui_rectangle_draw(container,draw_invisible);
	//LOOP------------------------------------------
	var p = array_length(container.containers);
	if(p=0){exit;};
	var i = 0;
	repeat(p){
		ui_container_draw(container.containers[i],draw_invisible);
	i++;
	};
};

function ui_get_scale_for_fill(container,width,height){
	var xs = container.width/width;
	var ys = container.height/height;
	return max(xs,ys);
};

function ui_get_scale_for_fit(container,width,height){
	var xs = container.width/width;
	var ys = container.height/height;
	return min(xs,ys);
};

function ui_get_scale_for_xfullfill(container,width){
	var xs = container.width/width;
	return xs;
};

function ui_get_scale_for_yfullfill(container,height){
	var ys = container.height/height;
	return ys;
};

function draw_sprite_animated(sprite,index,frps,max_frames,xx,yy,xscale,yscale,blend,alpha){
	//===== FUNCTION TO DRAW ANIMATED SPRITE === by Dominik Kaspar =========
	//
	// INDEX = Unique ID of the drawn sprite. Multiple calls of the function
	// with the same Index in the same instance will break things up.
	// FRPS = Speed of the sprite in frames per second.
	// MAX_FRAMES = Number of frames the sprite has.
	//
	if(!variable_instance_exists(self, "funcvar_draw_sprite_animated")){funcvar_draw_sprite_animated[index] = 0;}else{
		var anim_speed = frps/room_speed;
		funcvar_draw_sprite_animated[index] += anim_speed;
		if(floor(funcvar_draw_sprite_animated[index])=max_frames+1){funcvar_draw_sprite_animated[index] = 0;};
	};
	draw_sprite_ext(sprite,floor(funcvar_draw_sprite_animated[index]),xx,yy,xscale,yscale,0,blend,alpha);
};
#endregion
//======================================================================================================================================
//=================================================== MASS LOOPS FUNCTIONS =============================================================
#region Loops
function ui_container_visible_all(visibility){
	var i = -1;
	repeat(array_length(funcvar_ui)){
		i++;
		if(funcvar_ui[i].ui_container_type != 1 && funcvar_ui[i].ui_container_type != 2){continue;};
		ui_container_visible(funcvar_ui[i],visibility);
	};
};

function ui_screen_visible_all(visibility){
	var i = -1;
	repeat(array_length(funcvar_ui)){
		i++;
		if(funcvar_ui[i].ui_container_type != 0){continue;};
		ui_screen_visible(funcvar_ui[i],visibility);
	};
};

function ui_container_recalculate_all(){
	var i = -1;
	repeat(array_length(funcvar_ui)){
		i++;
		if(funcvar_ui[i].ui_container_type != 1 && funcvar_ui[i].ui_container_type != 2){continue;};
		ui_container_recalculate(funcvar_ui[i]);
	};
};

function ui_screen_recalculate_all(){
	var i = -1;
	repeat(array_length(funcvar_ui)){
		i++;
		if(funcvar_ui[i].ui_container_type != 0){continue;};
		ui_screen_recalculate(funcvar_ui[i]);
	};
};

function ui_screen_recalculate_visible(){
	var i = -1;
	repeat(array_length(funcvar_ui)){
		i++;
		if(funcvar_ui[i].ui_container_type != 0){continue;};
		if(funcvar_ui[i].ui_visible_self = 0){continue;};
		ui_screen_recalculate(funcvar_ui[i]);
	};
};
	
function ui_draw_sprite_fill(container,sprite){
	var xscl = ui_get_scale_for_xfullfill(container,16);
	var yscl = ui_get_scale_for_yfullfill(container,16);
	draw_sprite_ext(sprite,0,container.x,container.y,xscl,yscl,0,image_blend,image_alpha);
};
#endregion