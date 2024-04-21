package funkin.objects.alphabet;

class TypedAlphabet extends Alphabet
{
    public var sounds:Array<String> = [];
    public var volume:Float = 1;
    public var paused:Bool = true;
    public var delay:Float = 0.05;
    public var finishCallback:()->Void;

    private var targetText:String = "";
    private var splitWords:Array<String>;
    private var curWordNum:Int = 0;
    private var erasing:Bool = false;
    
    var tmr:FlxTimer;

    public function new(x:Float = 0, y:Float = 0, text:String = "", bold:Bool = true, fieldWidth:Int):Void {
        super(x, y, "", bold);
        tmr = new FlxTimer();

        autoSize = false;
        wrap = WORD(NEVER);
        this.fieldWidth = Std.int(fieldWidth / alphabetFont.lodScale);

        resetText(text);
    }

    // Changes the target text
    public inline function resetText(newText:String):Void {
        targetText = newText;
        splitWords = newText.split("");
        curWordNum = 0;
        text = "";
    }

    // Writes text from left to right
    public function start(delay:Float = 0.05):Void {
        this.delay = delay;
        paused = false;
        erasing = false;

        tmr.start(delay, (tmr) -> {
            if (curWordNum < splitWords.length && !paused) {
                playRandomSound();
                text = '$text${splitWords[curWordNum]}';
                curWordNum++;
                tmr.reset(delay);
            }
            else {
                paused = true;
                curWordNum = splitWords.length - 1;
                tmr.cancel();
                callCheck();
            }
        });
    }

    // Removes text from right to left
    public function erase():Void {
        paused = false;
        erasing = true;
        
        tmr.start(delay, (tmr) -> {
            if (curWordNum > 0 && !paused) {
                playRandomSound();
                text = text.substring(0,text.length-1);
                curWordNum--;
                tmr.reset(delay);
            }
            else {
                paused = true;
                curWordNum = splitWords.length - 1;
                tmr.cancel();
                callCheck();
            }
        });
    }

    // Plays the sound from array
    public inline function playRandomSound():Void {
        if (sounds.length > 0) {
            CoolUtil.playSound(sounds[FlxG.random.int(0, sounds.length - 1)], volume);
        }
    }

    // Skips the start() or erase()
    public inline function skip():Void {
        text = (erasing ? "" : targetText);
        paused = true;
        curWordNum = (erasing ? 0 : splitWords.length - 1);
    }

    private inline function callCheck():Void {
        if (finishCallback != null) {
            finishCallback();
        }
    }
}