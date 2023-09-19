package funkin.objects.alphabet;

typedef LetterData = {
    ?specialPrefix:Null<String>,
    ?offsetUpperNormal:Array<Float>,
    ?offsetLowerNormal:Array<Float>,
    ?offsetBold:Array<Float>
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

    /*
        Might make it a JSON in the future, this sucks lmao
        TODO Finish offsets and fix the shitty ones
        {offsetBold:[0,0],offsetLowerNormal:[0,0],offsetUpperNormal:[0,0]}
    */
    
    public static var characters(default, never):Map<String, Null<LetterData>> =  [
        //  Alphabet
        "a"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,10],offsetUpperNormal:[ 0, 0]},  "b"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 0],offsetUpperNormal:[ 0, 0]},
        "c"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,15],offsetUpperNormal:[ 0, 0]},  "d"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 0],offsetUpperNormal:[ 0, 0]},
        "e"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,15],offsetUpperNormal:[ 0, 0]},  "f"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 0],offsetUpperNormal:[ 0, 0]},
        "g"=>{offsetBold:[ 0, 3],offsetLowerNormal:[ 0,17],offsetUpperNormal:[ 0, 0]},  "h"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 5],offsetUpperNormal:[ 0, 0]},
        "i"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,10],offsetUpperNormal:[ 0, 0]},  "j"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 5],offsetUpperNormal:[ 0, 0]},
        "k"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 5],offsetUpperNormal:[ 0, 0]},  "l"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 5],offsetUpperNormal:[ 0, 0]},
        "m"=>{offsetBold:[ 0, 3],offsetLowerNormal:[ 0,25],offsetUpperNormal:[ 0, 0]},  "n"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,25],offsetUpperNormal:[ 0, 0]},
        "o"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},  "p"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},
        "q"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},  "r"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},
        "s"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,15],offsetUpperNormal:[ 0, 0]},  "t"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0, 5],offsetUpperNormal:[ 0, 0]},
        "u"=>{offsetBold:[ 0, 7],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},  "v"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,15],offsetUpperNormal:[ 0, 0]},
        "w"=>{offsetBold:[ 0, 3],offsetLowerNormal:[ 0,20],offsetUpperNormal:[ 0, 0]},  "x"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,10],offsetUpperNormal:[ 0, 0]},
        "y"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,10],offsetUpperNormal:[ 0, 0]},  "z"=>{offsetBold:[ 0, 0],offsetLowerNormal:[ 0,10],offsetUpperNormal:[ 0, 0]},

        //  Numbers
        "1"=>null,"2"=>null,"3"=>null,"4"=>null,"5"=>null,
        "6"=>null,"7"=>null,"8"=>null,"9"=>null,"0"=>null,

        //  Symbols
        "|"=> null, "~"=> null, "#"=> null,
        "$"=> null, "%"=> null, "("=> null,
        ")"=> null, "*"=> null, "+"=> null,
        "-"=> {offsetBold: [0,25]}, ":"=> null, ";"=> null,
        "<"=> null, "="=> null, ">"=> null,
        "@"=> null, "["=> null, "]"=> null,
        "^"=> null, "_"=> null, "."=> {specialPrefix: "period", offsetBold: [0, 50],offsetLowerNormal:[0, 40]},
        ","=> {specialPrefix: "comma",offsetLowerNormal:[0, 40]}, "'"=> {specialPrefix: "apostrophe"},"!"=> {specialPrefix: "exclamation", offsetBold: [0, -10]},
        "?"=> {specialPrefix: "question", offsetBold: [0,-5]},

        //  Spanish and Portuguese Characters
        "á"=>{offsetBold: [0, -33]},"é"=>{offsetBold: [0, -31]},
        "í"=>{offsetBold: [0, -32]},"ó"=>{offsetBold: [0, -31]},
        "ú"=>{offsetBold: [0, -27]},"ñ"=>{offsetBold: [0, -22]},
    ];

        
    public function new (x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        super(x,y);
        loadImage('alphabet');
		antialiasing = Preferences.getPref('antialiasing');
        setupCharacter(x,y,letter,bold,letterSize);
    }

    private static var defData:LetterData = {
        specialPrefix:          null,
        offsetBold:             [0,0],
        offsetLowerNormal:      [0,0],
        offsetUpperNormal:      [0,0]
    }

    public function setupCharacter(x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        setPosition(x,y);
        this.letter = letter;
        this.letterSize = letterSize;
        lowerLetter = letter.toLowerCase();
        offsetLetter = new FlxPoint(0,0);

        var newData:Null<LetterData> =  characters[lowerLetter];
        if (newData != null) {  //  Fix maybe NULL values
            newData.offsetBold = (newData.offsetBold != null) ? newData.offsetBold : defData.offsetBold;
            newData.offsetLowerNormal = (newData.offsetLowerNormal != null) ? newData.offsetLowerNormal : defData.offsetLowerNormal;
            newData.offsetUpperNormal = (newData.offsetUpperNormal != null) ? newData.offsetUpperNormal : defData.offsetUpperNormal;
            letterData = newData;
        }
        else {
            letterData = defData;
        }

        if (bold) {
            offsetLetter.set(letterData.offsetBold[0], letterData.offsetBold[1]);
            prefix = "bold";
        }
        else {
            var alphabet:String = 'abcdefghijklmnopqrstuvwxyz';
            if (alphabet.contains(lowerLetter)) {
                if (lowerLetter == letter) {
                    offsetLetter.set(letterData.offsetLowerNormal[0], letterData.offsetLowerNormal[1]);
                    prefix = "lowercase";
                }
                else {
                    offsetLetter.set(letterData.offsetUpperNormal[0], letterData.offsetUpperNormal[1]);
                    prefix = "uppercase";
                }
            }
            else {
                offsetLetter.set(letterData.offsetLowerNormal[0], letterData.offsetLowerNormal[1]);
                prefix = "normal";
            }
        }

        if (characters.exists(lowerLetter)) {
            makeCharacter();
        }
    }

    public function makeCharacter():Void {
        animPrefix = lowerLetter;
        if (letterData.specialPrefix != null) {
            animPrefix = letterData.specialPrefix;
        }
        addAnim(letter, '$animPrefix $prefix', 24, true);
        playAnim(letter);
        x += offsetLetter.x*letterSize;
        y += offsetLetter.y*letterSize;
        scale.set(letterSize,letterSize);
        updateHitbox();
    }
}