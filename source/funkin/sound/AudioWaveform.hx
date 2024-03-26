package funkin.sound;

import openfl.display.Sprite;
import flixel.util.FlxSpriteUtil;
import openfl.media.Sound;
import haxe.io.Bytes;

@:access(openfl.media.Sound)
@:access(openfl.display.Graphics)
class AudioWaveform extends FlxSpriteExt
{
    var canvas:Sprite;

    public function new(X:Float = 0, Y:Float = 0) {
        super(X, Y);
        makeGraphic(250, 500, FlxColor.TRANSPARENT, true);

        canvas = new Sprite();
    }
    
    public inline function getIndex(time:Float):Int {
        return Std.int(Math.max(time * sampleRate * 0.004, 0));
    }

    static inline var QUALITY:Int = 50;

    var sampleRate:Int;
    var bytes:Bytes;
    var avgBytes:Array<Int>;

    public function setSound(sound:Sound)
    {
        sampleRate = Std.int(sound.__buffer.sampleRate / QUALITY);
        bytes = sound.__buffer.data.toBytes();
        avgBytes = new Array<Int>();

        var i:Int = 0;
        var l:Int = bytes.length;

        var bigByte:Int = 0;

        while(i < l)
        {
            var byte = bytes.getUInt16(i);
            if (byte > bigByte)
                bigByte = byte;

            i++;

            if (i % QUALITY == 0) {
                avgBytes.push(bigByte);
                bigByte = 0;
            }
        }
    }

    var start:Int = 0;
    var end:Int = 0;

    // In milliseconds
    public function setSegment(start:Float, end:Float) {
        this.start = getIndex(start);
        this.end = getIndex(end);
        redrawWaveform();
    }

    var bounds = new Rectangle(0, 0, 0, 0);

    function redrawWaveform()
    {
        canvas.graphics.clear();
        canvas.graphics.__bounds = bounds;
        bounds.setTo(0, 0, width, height);
        
        canvas.graphics.beginFill();
        canvas.graphics.lineStyle(.5, FlxColor.WHITE);
        canvas.graphics.moveTo(width * .5, 0);

        var i:Int = start;
        var l:Int = FlxMath.minInt(end, avgBytes.length);
        var lastByte:Int = 0;

        while (i < l)
        {
            var byte:Int = avgBytes[i];//bytes.getUInt16(i);

            //if (byte == 0 || byte > 100) if (byte != lastByte)
            if (byte != lastByte)
            {
                lastByte = byte;

                if (byte > (65535 / 2))
                    byte -= 65535;

                lineTo(
                    width * .5 + ((byte / 65535) * 50),
                    FlxMath.remapToRange((i - start), 0, (l - start), 0, height)
                );
            }

            //i += 25;
            i++;
        }

        lineTo(width * .5, height);
        canvas.graphics.endFill();
        canvas.graphics.__dirty = true;

        CoolUtil.rectangle.setTo(0, 0, width, height);
        pixels.fillRect(CoolUtil.rectangle, 16777216);
        pixels.draw(canvas);
    }

    inline function lineTo(x:Float, y:Float) {
        canvas.graphics.__positionX = x;
		canvas.graphics.__positionY = y;
        canvas.graphics.__commands.lineTo(x, y);
    }

    //var points:Array<FlxPoint> = [];

    /*
    function updateDisplay()
    {
        //CoolUtil.rectangle.setTo(0, 0, width, height);
        //pixels.fillRect(CoolUtil.rectangle, 16777216);
        canvas.graphics.clear();
        canvas.graphics.beginFill();
        canvas.graphics.lineStyle(.5, FlxColor.WHITE);
        canvas.graphics.moveTo(width * .5, 0);
        
        var i:Int = start;
        var l:Int = FlxMath.minInt(end, bytes.length);

        var yIndex:Int = 0;
        //points.splice(0, points.length);

        //points.push(FlxPoint.weak(width * .5, 0));
        var lastByte:Int = 0;

        while (i < l)
        {
            var byte:Int = bytes.getUInt16(i);
            if (byte != lastByte)
            {
                lastByte = byte;

                if (byte > (65535 / 2))
                    byte -= 65535;
    
                var sample:Float = (byte / 65535);

                canvas.graphics.lineTo(
                    width * .5 + sample * 50,
                    FlxMath.remapToRange(yIndex, 0, end - start, 0, height)
                );
            }

            i = (i + 5);
            yIndex = (yIndex + 5);
        }

        canvas.graphics.lineTo(width * .5, height);
        canvas.graphics.endFill();
    }*/
}