package funkin.sound;

import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.media.Sound;
import haxe.io.Bytes;

@:access(openfl.media.Sound)
@:access(openfl.display.Graphics)
class AudioWaveform extends FlxSpriteExt
{
    var canvas:Sprite;
    var graphics:Graphics;
    var bounds:Rectangle;

    public function new(X:Float = 0.0, Y:Float = 0.0, Width:Float = 250.0, Height:Float = 500.0, ?sound:Sound):Void
    {
        super(X, Y);
        makeGraphic(Std.int(Width), Std.int(Height), FlxColor.TRANSPARENT, true);
        
        bounds = new Rectangle(0, 0, width, height);
        canvas = new Sprite();
        graphics = canvas.graphics;

        if (sound != null)
            setSound(sound);
    }
    
    public inline function getIndex(time:Float):Int
    {
        return Std.int(Math.max(time * sampleRate * 0.004, 0));
    }

    static inline var QUALITY:Int = 250;

    var sampleRate:Float = 0.0;
    var avgBytes:Array<Int> = [];

    override function destroy():Void {
        super.destroy();
        avgBytes = null;
        canvas = null;
        graphics = null;
        bounds = null;
    }

    public function setSound(sound:Sound):Void
    {
        sampleRate = sound.__buffer.sampleRate / QUALITY;
        var bytes:Bytes = sound.__buffer.data.toBytes();
        avgBytes.splice(0, avgBytes.length);

        var i:Int = 0;
        var l:Int = bytes.length;
        var bigByte:Int = 0;

        while(i < l)
        {
            var byte = bytes.getUInt16(i);
            if (byte > (65535 / 2))
                byte -= 65535;
            
            if (Math.abs(byte) > Math.abs(bigByte))
                bigByte = byte;

            if (i % QUALITY == 0) {
                avgBytes.push(Std.int((bigByte / 65535) * 50));
                bigByte = 0;
            }

            i++;
        }
    }

    public var audioOffset:Float;

    var start:Int = 0;
    var end:Int = 0;

    // In milliseconds
    public function setSegment(start:Float, end:Float):Void {
        this.start = getIndex(start - audioOffset);
        this.end = getIndex(end - audioOffset);
        redrawWaveform();
    }

    public function redrawWaveform():Void
    {
        graphics.__bounds = bounds;

        if (!visible || avgBytes.length <= 0 || end <= 0) {
            return;
        }

        final w:Int = Std.int(width * .5);
        final h:Int = Std.int(height);
        
        graphics.beginFill();
        graphics.lineStyle(0.7, -1, 1.0);
        graphics.moveTo(w, 0);

        var i:Int = start;
        var l:Int = FlxMath.minInt(end, avgBytes.length);
        var lastByte:Int = 0;

        while (i < l)
        {
            final byte:Int = avgBytes.unsafeGet(i);

            if (byte != lastByte)
            {
                lastByte = byte;

                final y:Float = inline FlxMath.remapToRange((i - start), 0, (l - start), 0, h);
                lineTo(w + byte, y);
                //lineTo(w, y);
            }

            i = (i + 1);
        }

        lineTo(w, h);
        graphics.endFill();
        graphics.__dirty = true;

        // Draw the waveform onto the sprite
        pixels.fillRect(bounds, 16777216);
        pixels.draw(canvas);

        // Wont need the graphics data anymore
        clearGraphics();
    }

    inline function clearGraphics() {
        graphics.clear();
    }

    override function set_visible(value:Bool) {
        if (!value) {
            clearGraphics();
        }
        return super.set_visible(value);
    }

    inline function lineTo(x:Float, y:Float):Void {
        graphics.__positionX = x;
		graphics.__positionY = y;
        graphics.__commands.lineTo(x, y);
    }
}