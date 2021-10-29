//Toggle logo visibility
var i = container_logoRelative.visible;
switch(i){
	case 0 : var p = 1;break;
	case 1 : var p = 0;break;
}
ui_container_visible(container_logoRelative,p);