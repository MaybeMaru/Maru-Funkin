package;

import lime.text.UTF8String;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
*/

class FPS_Mem extends TextField
{

	private var times:Array<Float>;
	private var memPeak:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000) 
	{
		super();

		x = inX;
		y = inY;

		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 12, inCol);

		text = "FPS: ";
		times = [];

		addEventListener(Event.ENTER_FRAME, onEnter);
		addEventListener(Event.ADDED_TO_STAGE, create);

		width = 200;
		height = 80;
	}

	function create(_):Void {
        stage.addEventListener(Event.RESIZE, onResize);
    }

	function onResize(_):Void {
        final _scale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
        scaleX = _scale;
        scaleY = _scale;
    }

	static final memDiv:Float = 0.00009536743;

	private function onEnter(_)
	{	
		if (!visible) return;

		final now = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		final fps:Int = times.length;
		final mem:Float = Math.round(System.totalMemory * memDiv) * 0.01;
		if (mem > memPeak) memPeak = mem;

		final result:UTF8String =
		'FPS: ${fps > FlxG.updateFramerate ? FlxG.updateFramerate : fps}\n' +
		'RAM: $mem mb/$memPeak mb';

		if (text != result)
			text = result;
	}
}