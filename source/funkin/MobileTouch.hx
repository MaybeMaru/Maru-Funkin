package funkin;

import openfl.events.TouchEvent;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import flixel.input.FlxInput;

class MobileTouch extends Sprite
{
    public static var instance:MobileTouch;

    var buttons:Array<MobileButton> = [];

    public function new() @:privateAccess {
        super();

        addEventListener(Event.ADDED_TO_STAGE, (e) -> {
            
            var w = FlxG.stage.fullScreenWidth;
            var h = FlxG.stage.fullScreenHeight;
            
            var length:Int = 4;
            var outline:Int = 5;
            
            for (i in 0...length) {
                var button = new MobileButton();
                button.alpha = 0;
                
                var bmp = new BitmapData(Std.int(w / length), h, CoolUtil.noteColorArray[i]);
                CoolUtil.rectangle.setTo(outline, outline, bmp.width - (outline * 2), bmp.height - (outline * 2));
                bmp.fillRect(CoolUtil.rectangle, 16777216);
                
                button.addChild(new Bitmap(bmp));
                button.x = bmp.width * i;
    
                buttons.push(button);
                addChild(button);

                button.input = FlxG.keys.getKey(switch(i) {
                    case 0: LEFT;
                    case 1: DOWN;
                    case 2: UP;
                    case _: RIGHT;
                });
            }
        });
    }

    public function update(elapsed:Float) {
        buttons.fastForEach((button, i) -> {
            button.update(elapsed);
            if (!button.pressed)
                button.alpha -= elapsed * 2;
        });
    }

    public static function released():Bool {
        return !pressed();
    }

    public static function pressed():Bool {
        FlxG.touches.list.fastForEach((touch, i) -> {
            if (touch.pressed)
                return true;
        });
        return false;
    }

    public static function justPressed():Bool {
        FlxG.touches.list.fastForEach((touch, i) -> {
            if (touch.justPressed)
                return true;
        });
        return false;
    }
}

class MobileButton extends Sprite
{
    public var pressed(default, null):Bool = false;
    public var justPressed(default, null):Bool = false;
    public var input:FlxInput<Int>;

    var _begin:Bool = false;
    
    public function new() {
        super();

        addEventListener(TouchEvent.TOUCH_BEGIN, function (e) {
            alpha = 0.6;

            _begin = true;
            justPressed = true;
            pressed = true;
        });

        var endTouch = (e:Event) -> {
            justPressed = false;
            pressed = false;
        }

        //addEventListener(TouchEvent.TOUCH_END, endTouch);
        //addEventListener(TouchEvent.TOUCH_OUT, endTouch);
        addEventListener(TouchEvent.TOUCH_OVER, endTouch);
    }

    public function update(elapsed:Float) {
        if (justPressed) if (!_begin) justPressed = false;
        if (_begin) _begin = false;
        
        input.current = justPressed ? FlxInputState.JUST_PRESSED : pressed ? FlxInputState.PRESSED : FlxInputState.RELEASED;
    }
}

enum abstract TouchMode(Int) from Int to Int
{
    var NONE:Int = 0;
    var NOTES:Int = 1;
    var MENU:Int = 2;
}