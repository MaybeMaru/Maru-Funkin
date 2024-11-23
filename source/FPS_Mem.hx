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
	public function new(X:Float = 10.0, Y:Float = 10.0, Color:Int = 0x000000) 
	{
		super();

		x = X;
		y = Y;

		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 12, Color);

		text = "FPS: ";

		addEventListener(Event.ENTER_FRAME, onEnter);
		addEventListener(Event.ADDED_TO_STAGE, create);

		width = 200;
		height = 80;
	}

	function create(_):Void {
        stage.addEventListener(Event.RESIZE, onResize);
    }

	function onResize(_):Void {
		lastTime = Timer.stamp();
        final _scale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
        scaleX = _scale;
        scaleY = _scale;
    }

	static inline var memDiv:Float = 1 / 1024 / 1024 * 100;
	static inline function formatBytes(bytes:Float):Float {
		#if web
		return FlxMath.roundDecimal(Math.round(bytes * memDiv) * 0.01, 2 );
		#else
		return Math.round(bytes * memDiv) * 0.01;
		#end
	}

	var memPeak:Float = 0;
	var lastTime:Float = 0;

	var timeFrame:Float = 0;
	var frames:Int = 0;

	private function onEnter(_):Void
	{
		if (!visible)
			return;

		final now = Timer.stamp();
		timeFrame += (now - lastTime);
		frames++;

		if (timeFrame >= (1 / 6))
		{
			final fps = Std.int(frames / timeFrame);
			final bytes = #if (cpp && !mobile) Memory.getCurrentUsage(); #else System.totalMemory; #end
			final memCur = formatBytes(bytes);

			if (memCur > memPeak)
				memPeak = memCur;

			text = 'FPS: ${Math.min(fps, FlxG.updateFramerate)}\nRAM: $memCur mb/$memPeak mb';

			frames = 0;
			while (timeFrame > 0)
				timeFrame = timeFrame - (1 / 6);
		}

		lastTime = now;
	}
}