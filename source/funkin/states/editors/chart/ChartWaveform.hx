package funkin.states.editors.chart;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import haxe.io.Bytes;
import lime.media.AudioBuffer;

/*
    Inspired by the Kade Engine waveform class
    https://github.com/Kade-github/Kade-Engine/blob/stable/source/Waveform.hx
*/

class ChartWaveform extends FlxSprite {
    public var audioBuffer:AudioBuffer;
	public var audioBytes:Bytes;
	public var audioLength:Int;

    var sound:FlxSound;
    public var soundOffset:Float = 0;

    public function new(sound:FlxSound) {
        super();
        this.sound = sound;
        @:privateAccess {
            if (sound._sound == null || sound._sound.__buffer == null) return;
            audioBuffer = sound._sound.__buffer;
            audioBytes = sound._sound.__buffer.data.toBytes();
        }
        makeGraphic(ChartGrid.GRID_SIZE * Conductor.STRUMS_LENGTH, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, FlxColor.TRANSPARENT);

        alpha = 0.6;
        drawWaveform();
    }

    public function updateWaveform() {
        drawWaveform(ChartingState.getSecTime(ChartingState.instance.sectionIndex) - soundOffset, ChartingState.getSecTime(ChartingState.instance.sectionIndex + 1) - soundOffset);
    }

    function clearPixels() {
        pixels = new BitmapData(cast width, cast height, true, FlxColor.TRANSPARENT);
    }

    public function getIndexTime(time:Float) {
        var index = time * audioBuffer.sampleRate / 1000;
        index = Math.max(index, 0);
        return index;
    }

    public function drawWaveform(startTime:Float = 0, endTime:Float = 0) {
        clearPixels();
        var startIndex:Int = Std.int(getIndexTime(startTime) * 4);
        var endIndex = getIndexTime(endTime) * 4;
		var min:Float = 0;
		var max:Float = 0;

        var indexLength = Std.int(endIndex - startIndex);

        for (i in 0...indexLength) {
            //if (i % 512 != 0) continue;
            var byteIndex:Int = i + startIndex;
            var byte:Int = audioBytes.getUInt16(byteIndex);

            if (byte > 65535 / 2) byte -= 65535;

			var sample:Float = (byte / 65535);
			if (sample > 0)         if (sample > max) max = sample;
			else if (sample < 0)    if (sample < min) min = sample;

            var pixelsMin:Float = Math.abs(min * 300);
			var pixelsMax:Float = max * 300;
            min = max = 0;

            var lineWidth = pixelsMin + pixelsMax;
            if (lineWidth <= 0) continue;
            var lineY = FlxMath.remapToRange(i, 0, indexLength, 0, height);

            var _color = FlxColor.fromRGB(255, 0, Math.floor(lineWidth));
            pixels.fillRect(new Rectangle((width * 0.5) - lineWidth, lineY, lineWidth * 2, 1), _color);
        }
    }
}