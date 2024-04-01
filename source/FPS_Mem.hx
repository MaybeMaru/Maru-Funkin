package;

import openfl.system.System;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;

#if cpp
import memory.Memory;
#end

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
*/

class FPS_Mem extends TextField
{
	private var times:Array<Float>;

	public function new(X:Float = 10.0, Y:Float = 10.0, Color:Int = 0x000000) 
	{
		super();

		x = X;
		y = Y;

		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 12, Color);

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

	static inline var memDiv:Float = 1 / 1024 / 1024 * 100;
	static inline function formatBytes(bytes:Float):Float {
		return Math.round(bytes * memDiv) * 0.01;
	}

	var memPeak:Float = 0;

	private function onEnter(_):Void
	{
		if (!visible)
			return;

		final now = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		final fps:Int = times.length;

		final bytes = #if (cpp && !mobile) Memory.getCurrentUsage(); #else System.totalMemory; #end
		final memCur = formatBytes(bytes);

		if (memCur > memPeak)
			memPeak = memCur;

		text =
		'FPS: ${fps > FlxG.updateFramerate ? FlxG.updateFramerate : fps}\n' +
		'RAM: $memCur mb/$memPeak mb';
	}
}