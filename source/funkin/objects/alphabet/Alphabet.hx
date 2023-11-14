package funkin.objects.alphabet;

enum abstract AlphabetAlign(String) {
    var LEFT = 'left';
    var CENTER = 'center';
    var RIGHT = 'right';
}

class Alphabet extends FlxTypedSpriteGroup<AlphabetCharacter> {
    public static var spaceWidth:Float = 50;
    public static var spaceHeight:Float = 70;

    public var text(default, set):String = "";
    public var alignment(default, set):AlphabetAlign = LEFT;
    public var textScale:Float = 1;
    public var bold:Bool = false;
    public var textWidth:Int = 500;

    function set_alignment(_alignment:AlphabetAlign):AlphabetAlign {
        alignment = _alignment;
        setAlign();
		return _alignment;
	}

    function set_text(value:String):String {
        if (text != value) makeText(value);
        return text = value;
    }

    private function setAlign():Void {
		for (letter in letterArray) {
            var alignOffset:Float = 0;
            switch(alignment) {
                default:        alignOffset = 0;
                case CENTER:    alignOffset = letter.lineWidth/2;
                case RIGHT:     alignOffset = letter.lineWidth;
            }
            letter.offset.x = alignOffset;
		}
	}

    public function new(X:Float = 0, Y:Float = 0, text:String = "coolswag", bold:Bool = true, textWidth:Int = 0, textScale:Float = 1):Void {
        super(X,Y);
        initPos = FlxPoint.get();
        curPos = FlxPoint.get();
        this.bold = bold;
        this.textWidth = textWidth;
        this.textScale = textScale;
        this.text = text;
    }

    override function destroy() {
        super.destroy();
        initPos = FlxDestroyUtil.put(initPos);
        curPos = FlxDestroyUtil.put(curPos);
    }

    public var cutText:Array<String> = [];
    public var letterArray:Array<AlphabetCharacter> = [];

    private var initPos:FlxPoint;
    private var curPos:FlxPoint;
    private var maxWidth:Float = 0;

    public function makeText(text:String = "coolswag"):Void {
        curPos.set(initPos.x,initPos.y);
        curLineWidth = 0;
        lastLineWidths = [];
        cutText = splitText(text);
        maxWidth = (textWidth/25)*spaceWidth*textScale;

        for (letter in letterArray) {
            letter.kill();
        }

        for (letter in cutText) {
            makeLetter(letter);
        }
        newLine();
        setAlign();
    }

    private var curLineWidth:Int = 0;
    private var lastLineWidths:Array<Int> = [];
    private var listToAddLine:Array<AlphabetCharacter> = [];
    private var endWord:Bool = false;

    public function makeLetter(letter:String):Void {
        switch (letter) {
            case " ":   // Make a space
                endWord = true;
                var addWidth:Int = Std.int(spaceWidth*textScale);
                curPos.x += addWidth;
                curLineWidth += addWidth;

            case "\n":  //New line
                newLine();

            default:
                endWord = false;
                var newLetter:AlphabetCharacter = recycle(AlphabetCharacter);
                newLetter.setupCharacter(curPos.x, curPos.y, letter, bold, textScale);
                var addWidth:Int = Std.int(newLetter.width*1.01);
                curPos.x += addWidth;
                curLineWidth += addWidth;
                listToAddLine.push(newLetter);
                letterArray.push(newLetter);
                add(newLetter);
        }

        if (curPos.x > maxWidth && textWidth > 0 && endWord) {
            newLine();
        }
    }

    private function newLine():Void {
        curPos.x = initPos.x;
        curPos.y += spaceHeight*textScale;

        lastLineWidths.push(curLineWidth);
        for (char in listToAddLine) {
            char.lineWidth = curLineWidth;
        }
        listToAddLine = [];
        curLineWidth = 0;
    }

    inline public function splitText(text:String):Array<String> {
        return text.split("");
    }
}