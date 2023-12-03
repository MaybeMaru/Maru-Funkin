package funkin.objects.funkui;

class FunkInputText extends FourSideSprite implements IFunkUIObject {
    private var __text:FlxFunkText;
    public var ogX:Float;
	public var ogY:Float;
    
    public function new(X:Float, Y:Float, text:String = "", ?Width:Int, lines:Int = 1) {
        super(X, Y, Width ?? 375, lines = cast Math.max(lines, 1) * 20 + (5 / lines), 0xff343638);
        ogX = X;
        ogY = Y;

        __text = new FunkUIText(X, Y, text, width, cast height);
        __text.wordWrap = lines != 1;

        this.text = text;
        wordPos = text.length;
        resetHold();
    }

    public var selected(default, set):Bool = false;
    function set_selected(value:Bool):Bool {
        if (!value) {
            _addBar = false;
            _tmr = 0.0;
            __text.text = text;
        }
        targetColor = selected ? FlxColor.WHITE : HIGHLIGHT_COLOR;
        return selected = value;
    }

    public var text(default, set):String = "";
    function set_text(value:String):String {
        __text.text = text = value;
        return text = value;
    }

    static final HIGHLIGHT_COLOR = 0xFFD8D8D8;
    
    var _tmr:Float = 0;
    var _addBar(default,set):Bool = false;
    function set__addBar(value:Bool):Bool {
        __text.text = text;
        if (value) {
           __text.text = __text.text.substring(0, wordPos) + "|" + __text.text.substring(wordPos);
        }
        return _addBar = value;
    }

    var targetColor = FlxColor.WHITE;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (selected) {
            _tmr -= elapsed;
            if (_tmr <= 0) {
                _tmr = 0.75;
                _addBar = !_addBar;
            }

            textInput();
        }
        if (FlxG.mouse.overlaps(this) || selected) {
            if (!selected) __text.color = color = HIGHLIGHT_COLOR;
            if (FlxG.mouse.justPressed)
                selected = !selected;
        }

        if (color != targetColor) {
			__text.color = color = FlxColor.interpolate(color, targetColor, elapsed * 10);
		}
    }

    static var capsLock:Bool = false;

    var lastKey:FlxKey = NONE;
    var __pressTmr:Float = 0.0;
    var __pressAt:Float = 0.0;

    inline function resetHold() {
        __pressTmr = 0.4;
        __pressAt = 0.0;
    }

    function textInput() {
        // Just pressed keys
        final key = FlxG.keys.firstJustPressed();
        if (key != NONE) {
            lastKey = key;
            runKey(key);
            resetHold();
        }

        // Hold keys
        final pressKey = FlxG.keys.firstPressed();
        if (pressKey != NONE) {
            __pressTmr -= FlxG.elapsed;
            if (__pressTmr <= 0 && pressKey != NONE && pressKey == lastKey) {
                __pressAt -= FlxG.elapsed;
                if (__pressAt <= 0) {
                    __pressAt = 0.02;
                    runKey(pressKey);
                }
            }
        }
        else resetHold();
    }

    var wordPos:Int = 0;

    function runKey(key:FlxKey) {
        switch (key) {
            case SHIFT | CONTROL: // these aint do nothin
            case CAPSLOCK: capsLock = !capsLock;
            case BACKSPACE: text = text.substring(0, cast Math.max(text.length - 1, 0));

            case LEFT | RIGHT:
                wordPos += (key == LEFT ? -1 : 1);
                wordPos = cast FlxMath.bound(wordPos, 0, text.length);
            
            default:
                wordPos++;
                switch (key) {
                    case ENTER: addTxt("\n");
                    case SPACE: addTxt(" ");

                    case PERIOD: addTxt(".");
                    case COMMA: addTxt(",");
        
                    case ZERO: addTxt("0");     case ONE: addTxt("1");      case TWO: addTxt("2");
                    case THREE: addTxt("3");    case FOUR: addTxt("4");     case FIVE: addTxt("5");
                    case SIX: addTxt("6");      case SEVEN: addTxt("7");    case EIGHT: addTxt("8");
                    case NINE: addTxt("9");

                    default:
                        final word = FlxKey.toStringMap.get(key);
                        final useCaps = capsLock != FlxG.keys.pressed.SHIFT;
                        addTxt(useCaps ? word : word.toLowerCase());
                }
        }

        _addBar = true;
        _tmr = 0.75;
    }
    
    inline function addTxt(str:String) {
        text = text.substring(0, wordPos - 1) + str + text.substring(wordPos - 1);
    }

    public function setUIPosition(X:Float, Y:Float) {
		setPosition(X,Y);
        __text.setPosition(X,Y);
	}

    override function draw() {
        super.draw();
        __text.draw();
    }

    override function destroy() {
        super.destroy();
        __text.destroy();
    }
}