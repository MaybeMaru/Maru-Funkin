package funkin;

import openfl.events.TouchEvent;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import flixel.input.FlxInput;

class MobileTouch extends Sprite
{
    public static var touch:MobileTouch;

    public var mode(default, set):TouchMode = NONE;
    function set_mode(value:TouchMode):TouchMode
    {
        noteButtons.fastForEach((button, i) -> button.visible = value == NOTES);
        uiButtons.fastForEach((button, i) -> button.visible = value == MENU);
        
        return mode = value;
    }

    public static function setMode(mode:TouchMode) {
        touch.mode = mode;
    }

    final noteButtons:Array<MobileButton> = [];
    final uiButtons:Array<MobileButton> = [];

    public function getButton(id:MobileButtonID):MobileButton {
        return uiButtons.unsafeGet(cast id);
    }

    public function new() @:privateAccess {
        super();

        addEventListener(Event.ADDED_TO_STAGE, (e) -> {
            var w = FlxG.stage.fullScreenWidth;
            var h = FlxG.stage.fullScreenHeight;
            
            var length:Int = 4;
            var outline:Int = 5;
            
            // Note buttons
            for (i in 0...length) {
                var button = new MobileButton();
                button.alpha = 0;
                
                var bmp = new BitmapData(Std.int(w / length), h, CoolUtil.noteColorArray[i]);
                CoolUtil.rectangle.setTo(outline, outline, bmp.width - (outline * 2), bmp.height - (outline * 2));
                bmp.fillRect(CoolUtil.rectangle, 16777216);
                
                button.addChild(new Bitmap(bmp));
                button.x = bmp.width * i;
    
                noteButtons.push(button);
                addChild(button);

                button.input = FlxG.keys.getKey(switch(i) {
                    case 0: D;
                    case 1: F;
                    case 2: J;
                    case _: K;
                });
            }

            final images:Array<String> = ["left", "right", "up", "down", "accept", "back", "pause"];
            final inputs:Array<FlxKey> = [LEFT, RIGHT, UP, DOWN, ENTER, ESCAPE, BACKSPACE];

            // UI buttons
            for (i in 0...7)
            {
                var button = new MobileButton();
                button.alpha = 0.2;
                
                var bitmap = OpenFlAssets.getBitmapData('assets/images/mobile/buttons/' + images[i] + '.png', false);
                button.addChild(new Bitmap(bitmap));
                button.input = FlxG.keys.getKey(inputs[i]);

                button.scaleX = button.scaleY = (Math.min(w, h) / Math.min(bitmap.width, bitmap.height)) * 0.23;
                button.x = button.scaleX * bitmap.width * i;
                
                uiButtons.push(button);
                addChild(button);
            }

            mode = NONE;
        });
    }

    public function update(elapsed:Float)
    {
        switch(mode) {
            case NONE:
            case NOTES:
                noteButtons.fastForEach((button, i) -> {
                    button.update(elapsed);
                    if (button.pressed) button.alpha = 0.6;
                    else                button.alpha -= elapsed * 2;
                });
            case MENU:
                uiButtons.fastForEach((button, i) -> {
                    button.update(elapsed);
                    if (button.pressed) button.alpha = 0.4;
                    else                button.alpha = FlxMath.lerp(button.alpha, 0.2, elapsed);
                });
        }
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

// Simple openfl sprite that can make virtual key inputs from mobile touch inputs
class MobileButton extends Sprite
{
    public var pressed(default, null):Bool = false;
    public var justPressed(default, null):Bool = false;
    public var input:FlxInput<Int>;

    var _begin:Bool = false;
    
    public function new() {
        super();

        addEventListener(TouchEvent.TOUCH_BEGIN, function (e) {
            _begin = true;
            justPressed = true;
            pressed = true;
        });

        var endTouch = (e:Event) -> {
            justPressed = false;
            pressed = false;
        }

        addEventListener(TouchEvent.TOUCH_END, endTouch);
        addEventListener(TouchEvent.TOUCH_OUT, endTouch);
    }

    public function update(elapsed:Float) {
        if (justPressed) if (!_begin) justPressed = false;
        if (_begin) _begin = false;
        
        if (input != null)
            input.current = justPressed ? FlxInputState.JUST_PRESSED : pressed ? FlxInputState.PRESSED : FlxInputState.RELEASED;
    }
}

enum abstract TouchMode(Int) from Int to Int
{
    var NONE:Int = 0;
    var NOTES:Int = 1;
    var MENU:Int = 2;
}

enum abstract MobileButtonID(Int) from Int to Int
{
    var LEFT:Int = 0;
    var RIGHT:Int = 1;
    var UP:Int = 2;
    var DOWN:Int = 3;
    var ACCEPT:Int = 4;
    var BACK:Int = 5;
    var PAUSE:Int = 6;
}