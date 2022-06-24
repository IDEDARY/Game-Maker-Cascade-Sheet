gmcs_init();
_screen = new screen();
var _container = new relative_container(_screen,[0,0,0,0],[100,100,900,900]);
var _container = new solid_container(_container,[1,1],[UI.anchor_center, UI.anchor_center],UI.scale_fit);

_screen._method_setVisible(1);