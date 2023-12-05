package funkin.objects.funkui;

class FunkInputText extends FourSideSprite implements IFunkUIObject {
    private var __text:FlxFunkText;
    public var ogX:Float;
	public var ogY:Float;
    
    public function new(X:Float, Y:Float, text:String = "", ?Width:Int, lines:Int = 1) {
        super(X, Y, Width ?? 375, (lines = cast Math.max(lines, 1) * 20 + (5 / lines)) + 6, 0xff343638);
        ogX = X;
        ogY = Y;

        __text = new FunkUIText(X, Y, text, width - 3, cast height - 2);
        __text.offset.set(-3,-2);
        __text.wordWrap = lines != 1;
        __text.deselect();

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
            __text.deselect();
            if (overlap) setColor(FlxColor.WHITE);
        }
        return selected = value;
    }

    public var text(default, set):String = "";
    function set_text(value:String):String {
        __text.text = text = value;
        return text = value;
    }

    static final HIGHLIGHT_COLOR = 0xFFD8D8D8;
    static final CLICK_COLOR = 0xFFA3A3A3;
    
    var _tmr:Float = 0;
    var _addBar(default,set):Bool = false;
    function set__addBar(value:Bool):Bool {
        __text.text = text;
        if (value && !__text.selected) {
           __text.text = text.substring(0, wordPos) + "|" + text.substring(wordPos);
        }
        return _addBar = value;
    }

    var targetColor = FlxColor.WHITE;
    inline function setColor(c:FlxColor) {
        __text.color = color = c;
    }

    var overlap:Bool = false;
    var mouseClick:Bool = false;
    var mousePress:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);
        overlap = FlxG.mouse.overlaps(this);
        mouseClick = FlxG.mouse.justPressed;
        mousePress = FlxG.mouse.pressed;

        if (selected) {
            _tmr -= elapsed;
            if (_tmr <= 0) {
                _tmr = 0.75;
                _addBar = !_addBar;
            }


            if (mouseClick && !overlap) {  // DESELECT
                selected = false;
            }
            else {
                mouseInput();
                textInput();
            }   
        }
        else {
            if (overlap) {
                targetColor = HIGHLIGHT_COLOR;
                if (mouseClick) {
                    selected = true;
                    setColor(CLICK_COLOR);
                }
            }
            else {
                targetColor = FlxColor.WHITE;
            }
        }

        if (color != targetColor) {
			setColor(FlxColor.interpolate(color, targetColor, elapsed * 10));
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

    function mouseInput() {
        if (mousePress) {
            final mousePos = FlxG.mouse.getScreenPosition();
            final fieldPos = __text.getScreenPosition();
            var mouseIndex = __text.getTextField().getCharIndexAtPoint(mousePos.x - fieldPos.x, mousePos.y - fieldPos.y);

            if (mouseClick)
                __text.setSelection(mouseIndex, mouseIndex);
            else {
                if (mouseIndex > 0) mouseIndex++;
                __text.setSelection(__text.startSelection, mouseIndex == -1 ? __text.startSelection : mouseIndex);
            }
        }
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
    var curLine:Int = 0;

    inline function updateCurLine() {
        curLine = __text.getTextField().getLineIndexOfChar(wordPos);
    }
    
    var shiftPress:Bool;
    var ctrlPress:Bool;

    static var clipBoard:String = "";

    function ctrlKeys(key:FlxKey) {
        switch(key) {
            case A: // Get all
                __text.setSelection(0, text.length);
            case C: // Copy
                copySelection();
            case V: // Paste
                pasteSelection();
            case X: // Cut
                copySelection();
                removeSelection();
            default:
                return false;
        }

        _addBar = true;
        _tmr = 0.75;
        return true;
    }

    inline function pasteSelection() {
        final prefix = text.substring(0, wordPos);
        final suffix = text.substring(wordPos);

        text = prefix + clipBoard;
        wordPos = text.length;
        text += suffix;
    }

    inline function copySelection() {
        if (__text.selected)
            clipBoard = text.substring(__text.startSelection, __text.endSelection);
    }

    inline function removeSelection() {
        text = text.substring(0, __text.startSelection) + text.substring(__text.endSelection);
        wordPos =  __text.startSelection;
        __text.deselect();
    }

    function runKey(key:FlxKey) {
        shiftPress = FlxG.keys.pressed.SHIFT;
        ctrlPress = FlxG.keys.pressed.CONTROL;
        
        set_text(text);
        final field = __text.getTextField(); 

        if (ctrlPress) {
            if (ctrlKeys(key)) return;
        }

        switch (key) {
            case ESCAPE:
                selected = false;
                return;
            
            case SHIFT | CONTROL | TAB: // these aint do nothin
            case CAPSLOCK: capsLock = !capsLock;
            case BACKSPACE:
                if (__text.selected) {
                    removeSelection();
                }
                else {
                    text = text.substring(0, wordPos - 1) + text.substring(wordPos);
                    wordPos--;
                    wordPos = cast Math.max(wordPos, 0);
                }
                updateCurLine();

            case LEFT | RIGHT:
                if (__text.selected) { // SELECTED jump scrolling
                    final start:Int = cast Math.min( __text.startSelection, __text.endSelection);
                    final end:Int = cast Math.max( __text.startSelection, __text.endSelection);
                    wordPos = (key == LEFT) ? start : end;
                }
                else if (!ctrlPress) { // Normal scrolling
                    wordPos += (key == LEFT ? -1 : 1);
                    wordPos = cast FlxMath.bound(wordPos, 0, text.length);
                    updateCurLine();
                }
                else { // CONTROL jump scrolling
                    updateCurLine(); // Making sure we are at the correct line
                    wordPos = field.getLineOffset(curLine);

                    if (key == RIGHT) { // Go to the end of the line
                        var lineLength:Int = field.getLineLength(curLine) - 1;
                        if (curLine == (field.numLines - 1)) lineLength++;
                        wordPos += lineLength;
                    }
                }
                __text.deselect();

            case UP | DOWN:
                __text.deselect();
                if (!__text.wordWrap) return; // Input text doesnt have multiple lines
                
                final charLineIndex:Int = wordPos - field.getLineOffset(curLine);
                if (key == UP) {
                    final prevLineIndex:Int = cast Math.max(curLine - 1, 0);
                    final prevLineStartIndex:Int = field.getLineOffset(prevLineIndex);
                    wordPos = cast prevLineStartIndex + Math.min(charLineIndex, field.getLineLength(prevLineIndex) - 1);
                }
                else {
                    final nextLineIndex:Int = cast Math.min(curLine + 1, field.numLines - 1);
                    final nextLineStartIndex:Int = field.getLineOffset(nextLineIndex);
                    wordPos = cast nextLineStartIndex + Math.min(charLineIndex, field.getLineLength(nextLineIndex) - 1);
                }
                updateCurLine();
            
            default:
                wordPos++;
                switch (key) {
                    case SPACE: addTxt(" ");
                    case ENTER: if (__text.wordWrap) addTxt("\n");

                    case PERIOD: addTxt(".", ":");
                    case COMMA: addTxt(",", ";");
                    case MINUS | NUMPADMINUS: addTxt("-", "_");
                    case PLUS | NUMPADPLUS: addTxt("+", "*");
                    case QUOTE: addTxt("'", "?");
        
                    case ZERO | NUMPADZERO: addTxt("0", "=");
                    case ONE | NUMPADONE: addTxt("1", "!", "|");
                    case TWO | NUMPADTWO: addTxt("2", '"', "@");
                    case THREE | NUMPADTHREE: addTxt("3", "·", "#");
                    case FOUR | NUMPADFOUR: addTxt("4", "$");
                    case FIVE | NUMPADFIVE: addTxt("5", "%");
                    case SIX | NUMPADSIX: addTxt("6","&");
                    case SEVEN | NUMPADSEVEN: addTxt("7", "/");
                    case EIGHT | NUMPADEIGHT: addTxt("8", "(");
                    case NINE | NUMPADNINE: addTxt("9", ")");

                    default:
                        final word = FlxKey.toStringMap.get(key);
                        final useCaps = capsLock != FlxG.keys.pressed.SHIFT;
                        addTxt(useCaps ? word : word.toLowerCase());
                }
                updateCurLine();
        }

        _addBar = true;
        _tmr = 0.75;
    }
    
    inline function addTxt(str:String, ?shiftTxt:String, ?ctrlTxt:String) {
        if (shiftTxt != null && shiftPress) str = shiftTxt;
        else if (ctrlTxt != null && ctrlPress) str = ctrlTxt;
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