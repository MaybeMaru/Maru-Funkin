package funkin.objects.alphabet;

typedef LetterData = {
    ?prefix:Null<String>,
    ?upper:Array<Float>,
    ?lower:Array<Float>,
    ?bold:Array<Float>
}

class AlphabetCharacter extends FlxSpriteExt {
    public var letter:String = "A";
    public var lowerLetter:String = "a";
    public var prefix:String = "";
    public var animPrefix:String = "a";
    public var letterData:LetterData;
    public var offsetLetter:FlxPoint;
    public var letterSize:Float = 1;
    public var lineWidth:Int = 0;
    
    public static final characters:Map<String, LetterData> =  [
        //  Alphabet
        "a"=>{lower:[0,10],},               "b"=>null,
        "c"=>{lower:[0,15],},               "d"=>null,
        "e"=>{lower:[0,15],},               "f"=>null,
        "g"=>{bold:[0,3], lower:[0,17],},   "h"=>{lower:[0,5],},
        "i"=>{lower:[0,10],},               "j"=>{lower:[0,5],},
        "k"=>{lower:[0,5],},                "l"=>{lower:[0,5],},
        "m"=>{bold:[0,3], lower:[0,25],},   "n"=>{lower:[0,25],},
        "o"=>{lower:[0,20],},               "p"=>{lower:[0,20],},
        "q"=>{lower:[0,20],},               "r"=>{lower:[0,20],},
        "s"=>{lower:[0,15],},               "t"=>{lower:[0,5],},
        "u"=>{bold:[0,7], lower:[0,20],},   "v"=>{lower:[0,15],},
        "w"=>{bold:[0,3], lower:[0,20],},   "x"=>{lower:[0,10],},
        "y"=>{lower:[0,10],},               "z"=>{lower:[0,10],},

        //  Numbers
        "1"=>null,"2"=>null,"3"=>null,"4"=>null,"5"=>null,
        "6"=>null,"7"=>null,"8"=>null,"9"=>null,"0"=>null,

        //  Symbols
        "|"=> null, "~"=> null, "#"=> null,
        "$"=> null, "%"=> null, "("=> null,
        ")"=> null, "*"=> null, "+"=> null,
        "-"=> {bold: [0,25]}, ":"=> null,
        ";"=> null, "<"=> null, "="=> null,
        ">"=> null, "@"=> null, "["=> null,
        "]"=> null, "^"=> null, "_"=> null,
        
        "." => {prefix: "period", bold: [0,50], lower:[0,40]},
        "," => {prefix: "comma", lower:[0,40]},
        "'" => {prefix: "apostrophe"},
        "!" => {prefix: "exclamation", bold: [0,-10]},
        "?" => {prefix: "question", bold: [0,-5]},


        //  Spanish and Portuguese Characters
        "á" => {bold:[0,-33]}, "é" => {bold:[0,-31]},
        "í" => {bold:[0,-32]}, "ó" => {bold:[0,-31]},
        "ú" => {bold:[0,-27]}, "ñ" => {bold:[0,-22]},
    ];

        
    public function new (x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        super(x,y);
        loadImage('alphabet');
		antialiasing = Preferences.getPref('antialiasing');
        setupCharacter(x,y,letter,bold,letterSize);
        offsetLetter = FlxPoint.get();
    }

    private static var defData:LetterData = {
        prefix: null,
        bold: [0,0],
        lower: [0,0],
        upper: [0,0]
    }

    static final alphabet:String = 'abcdefghijklmnopqrstuvwxyz';
    static var mappedData:Map<String, LetterData> = [];

    public function setupCharacter(x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        setPosition(x,y);
        this.letter = letter;
        this.letterSize = letterSize;
        lowerLetter = letter.toLowerCase();
        if (lowerLetter.length <= 0) return;
        
        if (!mappedData.exists(lowerLetter)) {
            mappedData.set(lowerLetter, JsonUtil.checkJsonDefaults(defData, characters.get(lowerLetter)));
        }
        letterData = mappedData.get(lowerLetter);

        if (bold) {
            offsetLetter.set(letterData.bold[0], letterData.bold[1]);
            prefix = "bold";
        }
        else {
            if (alphabet.contains(lowerLetter)) {
                final isLower = lowerLetter == letter;
                prefix = isLower ? "lowercase" : "uppercase";

                final arr = isLower ? letterData.lower : letterData.upper;
                offsetLetter.set(arr[0],arr[1]);
            }
            else {
                offsetLetter.set(letterData.lower[0], letterData.lower[1]);
                prefix = "normal";
            }
        }

        if (characters.exists(lowerLetter)) makeChar();
    }

    public function makeChar():Void {
        animPrefix = letterData.prefix ?? lowerLetter;
        if (!animDatas.exists(letter)) addAnim(letter, '$animPrefix $prefix', 24, true);
        playAnim(letter, true);
        x += offsetLetter.x * letterSize;
        y += offsetLetter.y * letterSize;
        setScale(letterSize);
    }

    override function destroy() {
        super.destroy();
        offsetLetter = FlxDestroyUtil.put(offsetLetter);
    }
}