function ui_button_textbox_enable(button,status){
	button.element_text_status = status;
};

function ui_button_textbox_edit(button,default_text,scale,text_hide,char_lenght){
	if(button.button_text = ""){button.button_text = default_text;};
	if(global.ui.button_current_selected = button){
		if(global.ui.button_previous_selected != button){keyboard_string = button.button_value;};
		button.button_scale_input = 1*scale;
		if string_length(keyboard_string) > char_lenght{keyboard_string = string_copy(keyboard_string, 1, char_lenght);};
		button.button_text = keyboard_string;
		button.button_value = keyboard_string;
		if(text_hide = 1 && button.button_value != ""){button.button_text = string_repeat("-",string_length(keyboard_string));}
	}else{button.button_scale_input = -1*scale;};
};