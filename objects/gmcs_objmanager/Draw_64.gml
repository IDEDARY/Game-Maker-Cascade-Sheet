draw_set_halign(fa_center);
draw_set_valign(fa_center);
var i = 0;
var n = array_length(canvas);
repeat(n){
	var ii = 0;
	var nn = array_length(canvas[i]);
	repeat(nn){
		global.gmcs._method_process_render(canvas[i][ii]);
	ii++;
	};
i++;
};