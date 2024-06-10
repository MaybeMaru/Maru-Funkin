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

    var waveformWidth:Float;

    public function new(X:Float = 0.0, Y:Float = 0.0, Width:Float = 250.0, Height:Float = 500.0, ?sound:Sound):Void
    {
        super(X, Y);
        makeGraphic(Std.int(Width), Std.int(Height), FlxColor.TRANSPARENT, true);
        
        bounds = new Rectangle(0, 0, width, height);
        canvas = new Sprite();
        graphics = canvas.graphics;

        waveformWidth = Width * 0.5;

        if (sound != null)
            setSound(sound);
    }
    
    public inline function getIndex(time:Float):Int
    {
        return Std.int(Math.max(time * sampleRate * 0.004, 0));
    }

    static inline var QUALITY:Int = 250;

    var sampleRate:Float = 0.0;
    var data:Array<#if cpp cpp.Float32 #else Float #end> = [];
    
    override function destroy():Void {
        super.destroy();
        data = null;
        canvas = null;
        graphics = null;
        bounds = null;
    }
    
    public function setSound(sound:Sound):Void {
        data.clear();
    
        var buffer = sound.__buffer;
        if (buffer == null || buffer.data == null)
            return;
    
        sampleRate = buffer.sampleRate / QUALITY;
        var bytes:Bytes = buffer.data.toBytes();
    
        var i:Int = 0;
        var l:Int = bytes.length;
        var sum:Int = 0;
        var count:Int = 0;
    
        while(i < l) {
            var byte = bytes.getUInt16(i);
            if (byte > (65535 / 2))
                byte -= 65535;
    
            sum += FlxMath.absInt(byte);
            count++;
    
            if (count == QUALITY) {
                var average = sum / count;
                data.push(average * (1 / 65535 * waveformWidth));
                sum = 0;
                count = 0;
            }
    
            i++;
        }
    
        // Handle any remaining samples
        if (count > 0) {
            var average = sum / count;
            data.push(average * (1 / 65535 * waveformWidth));
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
        //graphics.__bounds = bounds;

        if (!visible || data.length <= 0 || end <= 0) {
            return;
        }

        var w:Int = Std.int(width * .5);
        
        graphics.beginFill(FlxColor.WHITE);

        var i:Int = start;
        var l:Int = FlxMath.minInt(end, data.length);

        while (i < l)
        {
            var byte = data.unsafeGet(i);

            var y:Float = inline FlxMath.remapToRange((i - start), 0, (l - start), 0, height);
            graphics.drawRect(w - (byte * 0.5), y, byte, 1);

            i++;
        }

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
}