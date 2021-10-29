//======================================================================================================================================
//======================================================================================================================================
//--------------------------------------- GameMakerCascadeSheet (GMCS) by Dominik Kaspar -----------------------------------------------
//
// Github repository: https://github.com/IDEDARY/Game-Maker-Cascade-Sheet
// Published under MIT license.
// Version 2.0
//======================================================================================================================================
//===================================================== SCREEN FUNCTIONS ===============================================================
function ui_screen_create(){
	if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
	funcvar_ui[index] = {index : index,sId : 0,containers : [],elements : [],visible0 : 1,visible1 : 0,
		x1 : 0,
		y1 : 0,
	};
	with(funcvar_ui[index]){
		x2 = global.screen_width;
		y2 = global.screen_height;
		width = x2-x1;
		height = y2-y1;
		x = width/2;
		y = height/2;
		ui_screen_visible(self,visible1);
	};
	return funcvar_ui[index];
}

function ui_screen_recalculate(screen){
	with(screen){
		x2 = global.screen_width;
		y2 = global.screen_height;
		width = x2-x1;
		height = y2-y1;
		x = width/2;
		y = height/2;
		ui_screen_visible(self,visible1);
	};
	var p = array_length(screen.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_recalculate(screen.containers[i]);
	i++;
	}
}

function ui_screen_visible(screen,visibility){
	with(screen){
		visible1 = visibility;
		visible2 = sign(width*height);
		if(visible1+visible2=2){visible=true;}else{visible=false;};
		var p = array_length(containers);
		if(p=0){exit;}
		var i = 0;
		repeat(p){
			ui_container_visible(containers[i],containers[i].visible1);
		i++;
		}
	};
}

//======================================================================================================================================
//=================================================== CONTAINER FUNCTIONS ==============================================================
function ui_container_create(parent,x1_anchor,y1_anchor,x2_anchor,y2_anchor,x1_relative,y1_relative,x2_relative,y2_relative){
	if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
	funcvar_ui[index] = {index : index,sId : 1,containers : [],elements : [],visible1 : 1,
		parent : parent,
		
		x1_anchor : x1_anchor,
		y1_anchor : y1_anchor,
		x2_anchor : x2_anchor,
		y2_anchor : y2_anchor,
		
		x1_relative : x1_relative,
		y1_relative : y1_relative,
		x2_relative : x2_relative,
		y2_relative : y2_relative,
	};
	var p = array_length(parent.containers);
	parent.containers[p] = funcvar_ui[index];
	ui_container_recalculate(funcvar_ui[index]);
	return funcvar_ui[index];
}

function ui_container_solid_create(parent,width,height,fit_or_fill){
	if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
	funcvar_ui[index] = {index : index,sId : 2,containers : [],elements : [],visible1 : 1,
		parent : parent,
		fit_or_fill : fit_or_fill,
		width_ratio : width,
		height_ratio : height,
	};
	var p = array_length(parent.containers);
	parent.containers[p] = funcvar_ui[index];
	ui_container_recalculate(funcvar_ui[index]);
	return funcvar_ui[index];
}

function ui_container_recalculate(container){
	switch(container.sId){
		case 1 :
				with(container){
					var xsc = (parent.width)/1000;
					var ysc = (parent.height)/1000;
					x1 = parent.x1 + x1_anchor + x1_relative*xsc;
					y1 = parent.y1 + y1_anchor + y1_relative*ysc;
					x2 = parent.x1 + x2_anchor + x2_relative*xsc;
					y2 = parent.y1 + y2_anchor + y2_relative*ysc;
					width = x2 - x1;
					height = y2 - y1;
					x = x1+width/2;
					y = y1+height/2;
					ui_container_visible(self,visible1);
				}break;
		case 2 :
				with(container){
					if(fit_or_fill = 0){var sc = ui_get_scale_for_fit(container.parent,width_ratio,height_ratio);}else{var sc = ui_get_scale_for_fill(container.parent,width_ratio,height_ratio);}
					x1 = parent.x - width_ratio*sc/2;
					y1 = parent.y - height_ratio*sc/2;
					x2 = parent.x + width_ratio*sc/2;
					y2 = parent.y + height_ratio*sc/2;
					width = x2 - x1;
					height = y2 - y1;
					x = parent.x;
					y = parent.y;
					ui_container_visible(self,visible1);
				}break;
	}
	var p = array_length(container.containers);
	if(p!=0){
		var i = 0;
		repeat(p){
			ui_container_recalculate(container.containers[i]);
		i++;
		}
	}
	
	var p = array_length(container.elements);
	if(p!=0){
		var i = 0;
		repeat(p){
			ui_element_recalculate(container.elements[i])
		i++;
		}
	}
}

function ui_container_visible(container,visibility){
	with(container){
		visible0 = parent.visible;
		visible1 = visibility;
		visible2 = sign(width*height);
		if(visible0+visible1+visible2=3){visible=true;}else{visible=false;};
		var p = array_length(containers);
		if(p!=0){
			var i = 0;
			repeat(p){
				ui_container_visible(containers[i],containers[i].visible1);
			i++;
			}
		}
		var p = array_length(elements);
		if(p!=0){
			var i = 0;
			repeat(p){
				elements[i].visible = visible;
			i++;
			}
		}
	};
}

//======================================================================================================================================
//=================================================== ELEMENTS FUNCTIONS ===============================================================
// Xscale, Yscale - range(0 - 1000)=[0%-100%] -- size modifier
function ui_element_create(container,x_relative,y_relative,type_scale,x_scale,y_scale,object){ //Scale: 0 - fit, 1 - fill, 2 - deform_fill
	if(!layer_exists("Elements")){layer_create(-190,"Elements");}
	
	var xsc = (container.width)/1000;
	var ysc = (container.height)/1000;
	var xx = container.x1 + x_relative*xsc;
	var yy = container.y1 + y_relative*ysc;
	
	var element = instance_create_layer(xx,yy,"Elements",object);
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
}

function ui_element_recalculate(element){
	with(element){
		var xsc = (element_container.width)/1000;
		var ysc = (element_container.height)/1000;
		x = element_container.x1 + element_x_relative*xsc;
		y = element_container.y1 + element_y_relative*ysc;
		var xmod = element_x_scale_mod/1000;
		var ymod = element_y_scale_mod/1000;
		switch(element_type_scale){
			case 0: element_x_scale = ui_get_scale_for_fit(element_container,width,height)*xmod;element_y_scale = element_x_scale;break;
			case 1: element_x_scale = ui_get_scale_for_fill(element_container,width,height)*xmod;element_y_scale = element_x_scale;break;
			case 2: element_x_scale = element_container.width/width * xmod;element_y_scale = element_container.height/height * ymod;break;
		}
	}
}

//======================================================================================================================================
//=================================================== DRAW FUNCTIONS ==================================================================
function ui_rectangle_draw(container,draw_invisible){
	if(container.visible = false){
		if(draw_invisible=false){exit;}
		draw_set_color(c_red);
	}else{draw_set_color(c_white);}
	draw_rectangle(container.x1,container.y1,container.x2,container.y2,2);
	draw_set_color(c_white);
}

function ui_container_draw(container,draw_invisible){
	ui_rectangle_draw(container,draw_invisible);
	var p = array_length(container.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_draw(container.containers[i],draw_invisible);
	i++;
	}
}

function ui_get_scale_for_fill(container,width,height){
	var xs = container.width/width;
	var ys = container.height/height;
	return max(xs,ys);
}

function ui_get_scale_for_fit(container,width,height){
	var xs = container.width/width;
	var ys = container.height/height;
	return min(xs,ys);
}

function ui_get_scale_for_xfullfill(container,width){
	var xs = container.width/width;
	return xs;
}

function ui_get_scale_for_yfullfill(container,height){
	var ys = container.height/height;
	return ys;
}
//======================================================================================================================================