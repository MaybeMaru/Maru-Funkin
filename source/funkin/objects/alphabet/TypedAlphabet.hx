package funkin.objects.alphabet;

class TypedAlphabet extends Alphabet {
    public var sounds:Array<String> = [];
    public var volume:Float = 1;
    public var paused:Bool = true;
    public var delay:Float = 0.05;
    public var finishCallback:Void->Void = null;

    private var targetText:String = "";
    private var splitWords:Array<String> = [];
    private var curWordNum:Int = 0;
    private var erasing:Bool = false;

    public function new(x:Float, y:Float, text:String = "coolswag", bold:Bool = true, textWidth:Int = 1000, textScale:Float = 1):Void {
        super(x,y,"",bold,textWidth,textScale);
        resetText(text);
    }

    public function resetText(newText:String):Void { //Changes the target text
        targetText = newText;
        splitWords = splitText(newText);
        cacheLetters();
        curWordNum = 0;
        text = '';
    }

    public function cacheLetters():Void {
        while (splitWords.length > letterArray.length) {
            var cacheChar:AlphabetCharacter = new AlphabetCharacter();
            letterArray.push(cacheChar);
            add(cacheChar);
            cacheChar.kill();
        }
    }

    public function start(delay:Float = 0.05):Void { //Writes text from left to right
        this.delay = delay;
        paused = false;
        erasing = false;

        new FlxTimer().start(delay, function(leTimer:FlxTimer) {
            if (curWordNum < splitWords.length && !paused) {
                playRandomSound();
                text = '$text${splitWords[curWordNum]}';
                curWordNum++;
                leTimer.reset(delay);
            }
            else {
                paused = true;
                curWordNum = letterArray.length-1;
                leTimer.cancel();
                callCheck();
            }
        });
    }

    public function erase():Void { //Removes text from right to left
        paused = false;
        erasing = true;
        
        new FlxTimer().start(delay, function(leTimer:FlxTimer) {
            if (curWordNum > 0 && !paused) {
                playRandomSound();
                text = text.substring(0,text.length-1);
                curWordNum--;
                leTimer.reset(delay);
            }
            else {
                paused = true;
                curWordNum = letterArray.length-1;
                leTimer.cancel();
                callCheck();
            }
        });
    }

    public function playRandomSound():Void { //Plays the sound from array
        if (sounds.length > 0) {
            var randomSoundNum:Int = FlxG.random.int(0, sounds.length-1);
            CoolUtil.playSound(sounds[randomSoundNum], volume);
        }
    }

    public function skip():Void { //Skips the start() or erase()
        text = (erasing ? "" : targetText);
        paused = true;
        curWordNum = (erasing ? 0 : letterArray.length-1);
    }

    private function callCheck():Void {
        if (finishCallback != null) {
            finishCallback();
        }
    }
}