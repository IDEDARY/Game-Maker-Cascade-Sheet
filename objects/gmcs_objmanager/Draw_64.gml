draw_set_halign(fa_center);
draw_set_valign(fa_center);
var i = 0;
var n = array_length(canvas);
repeat(n){
	var ii = 0;
	var nn = array_length(canvas[i]);
	repeat(nn){
		var p = 0;
		if(!surface_exists(canvas[i][ii]._memory_styles[p]._surface) or canvas[i][ii]._info_width != canvas[i][ii]._cache_width or canvas[i][ii]._info_height != canvas[i][ii]._cache_height){
			if(surface_exists(canvas[i][ii]._memory_styles[p]._surface)){surface_free(canvas[i][ii]._memory_styles[p]._surface);};
			canvas[i][ii]._cache_width = canvas[i][ii]._info_width;
			canvas[i][ii]._cache_height = canvas[i][ii]._info_height;
			#region Preload
			var p = 0;
			var width = canvas[i][ii]._info_width;
			var height = canvas[i][ii]._info_height;
			
			var _xneg_increase = 0;
			var _yneg_increase = 0;
			var _xpos_increase = 0;
			var _ypos_increase = 0;
	
			var _style = canvas[i][ii]._memory_styles[p]._sprite_decoration;
			var nnn = array_length(_style);
			for(var l = 0; l < nnn; l++){
				if(_style[l]._sprite = noone){continue;};
		
				var _x = (_style[l]._relative[0]/1000)*width+_style[l]._solid[0];
				var _y = (_style[l]._relative[1]/1000)*height+_style[l]._solid[1];
				var _w = sprite_get_width(_style[l]._sprite)*_style[l]._x_scale;
				var _h = sprite_get_height(_style[l]._sprite)*_style[l]._y_scale;
				var _xo = sprite_get_xoffset(_style[l]._sprite)*_style[l]._x_scale;
				var _yo = sprite_get_yoffset(_style[l]._sprite)*_style[l]._y_scale;
		
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
				if(_style[l]._x_mirror){
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
				if(_style[l]._y_mirror){
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
			canvas[i][ii]._memory_styles[p]._spriteReturn_deco_offset = [_xx, _yy];
			canvas[i][ii]._memory_styles[p]._spriteReturn_deco_size = [sum_width,sum_height];
			#endregion	
			#region Init surface
			canvas[i][ii]._memory_styles[p]._surface = surface_create(sum_width,sum_height);
			surface_set_target(canvas[i][ii]._memory_styles[p]._surface);
			draw_clear_alpha(c_black,0);
			#endregion
			
			if(canvas[i][ii]._memory_styles[p]._sprite_reference[1] != noone){
				draw_sprite_stretched(canvas[i][ii]._memory_styles[p]._sprite_reference[1],0,_xx,_yy,canvas[i][ii]._info_width,canvas[i][ii]._info_height);
			};
			
			#region Decoration
			for(var l = 0; l < nnn; l++){
				if(_style[l]._sprite = noone){continue;};
				var _x = (_style[l]._relative[0]/1000)*width+_style[l]._solid[0];
				var _y = (_style[l]._relative[1]/1000)*height+_style[l]._solid[1];
				var __x = (_x-0.5*width)*-1 + 0.5*width;
				var __y = (_y-0.5*height)*-1 + 0.5*height;
		
				draw_sprite_ext(_style[l]._sprite,0,_xx+_x,_yy+_y,_style[l]._x_scale,_style[l]._y_scale,_style[l]._rotation,_style[l]._blend,_style[l]._alpha);
		
				if(_style[l]._x_mirror){
					draw_sprite_ext(_style[l]._sprite,0,_xx+__x,_yy+_y,_style[l]._x_scale*power(-1,_style[l]._true_mirror),_style[l]._y_scale,_style[l]._rotation*power(-1,_style[l]._true_mirror),_style[l]._blend,_style[l]._alpha);
				};
				if(_style[l]._y_mirror){
					draw_sprite_ext(_style[l]._sprite,0,_xx+_x,_yy+__y,_style[l]._x_scale,_style[l]._y_scale*power(-1,_style[l]._true_mirror),_style[l]._rotation*power(-1,_style[l]._true_mirror),_style[l]._blend,_style[l]._alpha);
				};
				if(_style[l]._x_mirror & _style[l]._y_mirror){
					draw_sprite_ext(_style[l]._sprite,0,_xx+__x,_yy+__y,_style[l]._x_scale*power(-1,_style[l]._true_mirror),_style[l]._y_scale*power(-1,_style[l]._true_mirror),_style[l]._rotation,_style[l]._blend,_style[l]._alpha);
				};
			};
			#endregion
			surface_reset_target();
		};
		var p = 0;
		draw_surface_stretched_ext(canvas[i][ii]._memory_styles[p]._surface,
		canvas[i][ii]._info_position[0] - canvas[i][ii]._memory_styles[p]._spriteReturn_deco_offset[0],
		canvas[i][ii]._info_position[1] - canvas[i][ii]._memory_styles[p]._spriteReturn_deco_offset[1],
		canvas[i][ii]._memory_styles[p]._spriteReturn_deco_size[0],
		canvas[i][ii]._memory_styles[p]._spriteReturn_deco_size[1],
		c_white,
		canvas[i][ii]._memory_styles[p]._sprite_alpha
		);
		if(canvas[i][ii]._memory_styles[p]._font != noone){draw_set_font(canvas[i][ii]._memory_styles[p]._font);};
		
		
		var sc = gmcs_getscale_fit(canvas[i][ii],string_width(canvas[i][ii]._info_text),string_height(canvas[i][ii]._info_text));
		switch(canvas[i][ii]._memory_styles[p]._font_halign){
			default:
				var xx = canvas[i][ii]._info_x;
			break;
			case fa_left:
				var real_string_width = string_width(canvas[i][ii]._info_text)*sc;
				//var real_string_height = string_height(canvas[i][ii]._info_text)*sc;
				var xx = canvas[i][ii]._info_position[0] + real_string_width/2;
				xx += canvas[i][ii]._memory_styles[p]._font_margin*sc;
				//xx += (real_string_height - real_string_height*canvas[i][ii]._memory_styles[p]._font_size)*0.5;
				xx -= real_string_width*(1-canvas[i][ii]._memory_styles[p]._font_size)*0.5;
			break;
			case fa_right:
				var real_string_width = string_width(canvas[i][ii]._info_text)*sc;
				//var real_string_height = string_height(canvas[i][ii]._info_text)*sc;
				var xx = canvas[i][ii]._info_position[2] - real_string_width/2;
				xx -= canvas[i][ii]._memory_styles[p]._font_margin*sc;
				//xx -= (real_string_height - real_string_height*canvas[i][ii]._memory_styles[p]._font_size)*0.5;
				xx += real_string_width*(1-canvas[i][ii]._memory_styles[p]._font_size)*0.5;
			break;
		};
		sc *= canvas[i][ii]._memory_styles[p]._font_size;
		draw_text_transformed_color(xx + canvas[i][ii]._memory_styles[p]._font_hoffset,canvas[i][ii]._info_y + canvas[i][ii]._memory_styles[p]._font_voffset,canvas[i][ii]._info_text,sc,sc,0,canvas[i][ii]._memory_styles[p]._font_blend[0],canvas[i][ii]._memory_styles[p]._font_blend[1],canvas[i][ii]._memory_styles[p]._font_blend[2],canvas[i][ii]._memory_styles[p]._font_blend[3],canvas[i][ii]._memory_styles[p]._font_alpha);
	ii++;
	};
i++;
};