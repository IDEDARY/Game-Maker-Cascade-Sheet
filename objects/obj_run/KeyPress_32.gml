//Get visibility from container2 and invert it
var i = mycontainer2.visible;
switch(i){
	case 0 : var p = 1;break;
	case 1 : var p = 0;break;
}
ui_container_visible(mycontainer2,p);