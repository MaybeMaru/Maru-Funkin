package openfl.display._internal;

enum abstract DrawCommandType(Int)
{
	var BEGIN_BITMAP_FILL = 0;
	var BEGIN_FILL = 1;
	var BEGIN_GRADIENT_FILL = 2;
	var BEGIN_SHADER_FILL = 3;
	var CUBIC_CURVE_TO = 4;
	var CURVE_TO = 5;
	var DRAW_CIRCLE = 6;
	var DRAW_ELLIPSE = 7;
	var DRAW_QUADS = 8;
	var DRAW_RECT = 9;
	var DRAW_ROUND_RECT = 10;
	var DRAW_TILES = 11;
	var DRAW_TRIANGLES = 12;
	var END_FILL = 13;
	var LINE_BITMAP_STYLE = 14;
	var LINE_GRADIENT_STYLE = 15;
	var LINE_STYLE = 16;
	var LINE_TO = 17;
	var MOVE_TO = 18;
	var OVERRIDE_BLEND_MODE = 19;
	var OVERRIDE_MATRIX = 20;
	var WINDING_EVEN_ODD = 21;
	var WINDING_NON_ZERO = 22;
	var UNKNOWN = -1;
}
