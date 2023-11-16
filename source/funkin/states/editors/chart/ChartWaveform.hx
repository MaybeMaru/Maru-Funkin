package funkin.states.editors.chart;

import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;

/*
    Inspired by the Kade Engine waveform class
    https://github.com/Kade-github/Kade-Engine/blob/stable/source/Waveform.hx
*/

class ChartWaveform extends FlxSprite {
    public var audioBuffer:AudioBuffer;
	public var audioBytes:Bytes;
    public var soundOffset:Float = 0;

    public function new(sound:FlxSound, _color:FlxColor = 0x5e3c92) {
        super();
        if (sound == null || sound.length <= 0) {
            visible = false;
            return;
        }
        @:privateAccess {
            if (sound._sound == null || sound._sound.__buffer == null) return;
            audioBuffer = sound._sound.__buffer;
            audioBytes = sound._sound.__buffer.data.toBytes();
        }
        frames = AssetManager.addGraphic(GRID_SIZE * Conductor.STRUMS_LENGTH, GRID_SIZE * Conductor.STEPS_PER_MEASURE, FlxColor.TRANSPARENT, 'waveform$_color').imageFrame;
        antialiasing = false;

        color = _color;
        alpha = 0.8;
        drawWaveform();
    }

    public function updateWaveform() {
        drawWaveform(ChartingState.getSecTime(ChartingState.instance.sectionIndex) - soundOffset, ChartingState.getSecTime(ChartingState.instance.sectionIndex + 1) - soundOffset);
    }

    function clearPixels() {
        pixels.fillRect(new Rectangle(0,0,width,height), FlxColor.fromRGB(0,0,0,1));
    }

    public function getIndexTime(time:Float) {
        return Math.max(time * audioBuffer.sampleRate / 1000, 0);
    }

    public function drawWaveform(startTime:Float = 0, endTime:Float = 0) {
        if (!visible) return;
        clearPixels();
        final startIndex:Int = Std.int(getIndexTime(startTime) * 4);
        final endIndex:Int = Std.int(getIndexTime(endTime) * 4);
        final indexLength:Int = endIndex - startIndex;

        var lastBytes:Array<Int> = [];
        final useBytes:Array<Int> = [];

        /*
            TODO:
            Instead of getting an average (which fucks up the min and max)
            Divide em n shit idk ill do it later
        */

        var i:Int = 0; // Get a scaled down average
        while(i < indexLength) {
            final byte:Int = audioBytes.getUInt16(i + startIndex);
            lastBytes.push(byte);
            if (lastBytes.length == 128) {
                var sum:Int = 0;
                for (num in lastBytes) sum += num;
                final average:Int = Std.int(sum / lastBytes.length);
                useBytes.push(average);
                lastBytes = [];
            }
            i++;
        }

        final mid = width * 0.5;
        final points:Array<FlxPoint> = [new FlxPoint(mid,0)];

        i = 0;
        final _length = useBytes.length;  // Get draw points
        while(i < _length) {
            final byte = useBytes[i];
            final sample:Float = (byte / 65535);
            final lineWidth =  sample * 100;
            final lineY = FlxMath.remapToRange(i, 0, _length, 0, height);
            points.push(new FlxPoint(mid + lineWidth, lineY));
            points.push(new FlxPoint(mid - lineWidth, lineY));
            i++;
        }
        points.push(new FlxPoint(mid,height));
        FlxSpriteUtil.drawPolygon(this, points, FlxColor.WHITE, {thickness: 0.75, color:FlxColor.WHITE}); // Draw waveform
    }
}