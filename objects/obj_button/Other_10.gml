//=========================================================================================
//==================================== GENERATE ===========================================
if(button.info.sprite != ui.ui_spr_point && button.info.sprite != ui.ui_spr_point2x2){sprite_delete(button.info.sprite);};
var bake = ui_cache_style_to_sprite(button.info.style,button.info.width,button.info.height);
button.info.sprite = bake.sprite;
button.scale.scale = bake.bonus_scale;
//=========================================================================================