var i = 0;
var n = canvas_index;
repeat(n){
	var ii = 0;
	var nn = array_length(canvas[i]);
	repeat(nn){
		
		draw_sprite_stretched(canvas[i][ii]._memory_styles[0]._sprite,0,canvas[i][ii]._info_position[0],canvas[i][ii]._info_position[1],canvas[i][ii]._info_width,canvas[i][ii]._info_height);
		
		
		
	ii++;
	};
i++;
};
