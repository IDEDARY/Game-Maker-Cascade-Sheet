gmcs_init();
_screen = new gmcs_screen();
var _container = new gmcs_relative_container(_screen,[0,0,0,0],[100,100,900,900]);
conny = new gmcs_solid_container(_container,[1,1],[UI.anchor_center, UI.anchor_center],UI.scale_fit);
var _container = conny;
repeat(100) var _container = new gmcs_relative_container(_container, [0,0,0,0],[50,0,950,900]);

//_screen._method_setVisible(1);