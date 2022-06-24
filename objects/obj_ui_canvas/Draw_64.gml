var r = array_length(canvas_container);
var i = 0;
repeat(r){
	var container = ui.global_inventory.containers[canvas_container[i]];
	if(container.ui_inventory.styles[container.ui_style.style_current].image != noone && container.ui_info.visible = true){
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_font(ui.styles[container.ui_style.style_current].font[0]);
	
		var image_width = sprite_get_width(container.ui_inventory.styles[container.ui_style.style_current].image);
		var image_height = sprite_get_height(container.ui_inventory.styles[container.ui_style.style_current].image);
		
		if(container.ui_inventory.styles[container.ui_style.style_current].image_scale = UI.scale_fit){
			var scl = ui_draw_getscale_fit(container,image_width,image_height);
			var xscl = scl;
			var yscl = scl;
		}else{
			if(container.ui_inventory.styles[container.ui_style.style_current].image_scale = UI.scale_fill){
				var scl = ui_draw_getscale_fill(container,image_width,image_height);
				var xscl = scl;
				var yscl = scl;
			}else{
				if(container.ui_inventory.styles[container.ui_style.style_current].image_scale = UI.scale_deform){
					var xscl = ui_draw_getscale_xdeform(container,image_width);
					var yscl = ui_draw_getscale_ydeform(container,image_height);
				};
			};
		};
		var number = sprite_get_number(container.ui_inventory.styles[container.ui_style.style_current].image);
		if(number = 1){
			draw_sprite_ext(container.ui_inventory.styles[container.ui_style.style_current].image,0,container.ui_info.x,container.ui_info.y,xscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,yscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,0,image_blend,image_alpha);
			draw_text_transformed_color(container.ui_info.x,container.ui_info.y,container.ui_temp_memory.display_text,xscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,yscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,0,image_blend,image_blend,image_blend,image_blend,image_alpha);
			
			//draw_sprite_ext(container.ui_inventory.styles[container.ui_style.style_current].image,0,container.ui_info.x+global.screen_xposition,container.ui_info.y+global.screen_yposition,xscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,yscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,0,image_blend,image_alpha);
			//draw_text_transformed_color(container.ui_info.x+global.screen_xposition,container.ui_info.y+global.screen_yposition,container.ui_temp_memory.display_text,xscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,yscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,0,image_blend,image_blend,image_blend,image_blend,image_alpha);
			//better_scaling_draw_sprite(container.ui_inventory.styles[container.ui_style.style_current].image,0,container.x,container.y,xscl,yscl,0,image_blend,image_alpha,0);
		}else{
			draw_sprite_animated(container.ui_inventory.styles[container.ui_style.style_current].image,1000+container.ui_info.index,container.ui_info.x,container.ui_info.y,xscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,yscl*container.ui_inventory.styles[container.ui_style.style_current].bonus_scale,0,image_blend,image_alpha);
		};
		
	};
	i++;
};