//======================================================================================================================================
//======================================================================================================================================
//--------------------------------------- GameMakerCascadeSheet (GMCS) by Dominik Kaspar -----------------------------------------------
//
// Github repository: https://github.com/IDEDARY/Game-Maker-Cascade-Sheet
// Published under MIT license.
//
//======================================================================================================================================
//===================================================== SCREEN FUNCTIONS ===============================================================
function ui_screen_create(){
	if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
	funcvar_ui[index] = {index : index,sId : 0,containers : [],elements : [],visible1 : 0,
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
		ui_container_visible(self,visible1);
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
		ui_container_visible(screen,visible1);
	};
	var p = array_length(screen.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_recalculate_content(screen.containers[i]);
	i++;
	}
}

//======================================================================================================================================
//======================================================= CONTAINER FUNCTIONS ==========================================================
function ui_container_create(parent,x1_anchor,y1_anchor,x2_anchor,y2_anchor,x1_relative,y1_relative,x2_relative,y2_relative){
	if(!variable_instance_exists(self, "funcvar_ui")){var index = 0;}else{var index = array_length(funcvar_ui);}
	funcvar_ui[index] = {index : index,sId : 1,containers : [],elements : [],visible1 : 0,
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

function ui_container_recalculate(container){
	with(container){
		xsc = (parent.width)/1000;
		ysc = (parent.height)/1000;
		x1 = parent.x1 + x1_anchor + x1_relative*xsc;
		y1 = parent.y1 + y1_anchor + y1_relative*ysc;
		x2 = parent.x1 + x2_anchor + x2_relative*xsc;
		y2 = parent.y1 + y2_anchor + y2_relative*ysc;
		width = x2 - x1;
		height = y2 - y1;
		x = width/2;
		y = height/2;
		if(width <= 0 or height <= 0){visible = false;}else{visible = true;}
	}
}

function ui_container_recalculate_content(container){
	ui_container_recalculate(container);
	var p = array_length(container.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_recalculate_content(container.containers[i]);
	i++;
	}
}

function ui_container_visible(container,visibility){
	with(container){
		visible1 = visibility;
		visible2 = sign(width*height);
		if(visible1+visible2=2){visible=true;}else{visible=false;};
	};
}

//======================================================================================================================================
//==================== DRAW DEBUG RECTANGLES ==============================
function ui_rectangle_draw(container,draw_invisible){
	if(container.visible = false){
		draw_set_color(c_red);
		if(draw_invisible=false){exit;}
	}else{draw_set_color(c_white);}
	draw_rectangle(container.x1,container.y1,container.x2,container.y2,2);
}

function ui_container_draw_content(container,draw_invisible){
	ui_rectangle_draw(container,draw_invisible);
	var p = array_length(container.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_draw_content(container.containers[i],draw_invisible);
	i++;
	}
}

function ui_screen_draw_content(screen,draw_invisible){
	ui_rectangle_draw(screen,draw_invisible);
	var p = array_length(screen.containers);
	if(p=0){exit;}
	var i = 0;
	repeat(p){
		ui_container_draw_content(screen.containers[i],draw_invisible);
	i++;
	}
}
//====================================================================================