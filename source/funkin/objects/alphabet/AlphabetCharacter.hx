package funkin.objects.alphabet;

typedef LetterData = {
    ?p:Null<String>, // prefix
    ?u:Float, // uppercase
    ?l:Float, // lowercase
    ?b:Float // bold
}

class AlphabetCharacter extends FlxSpriteExt
{
    public var letter:String = "A";
    public var lowerLetter:String = "a";
    public var prefix:String = "";
    public var animPrefix:String = "a";
    public var letterData:LetterData;
    public var letterSize:Float = 1;
    public var lineWidth:Float = 0;
    
    public static final characters:Map<String, LetterData> =  [
        //  Alphabet
        "a"=>{l: 22},
        "b"=>{b: -3, l: 8},
        "c"=>{b: 1, l: 25, u: 1},
        "d"=>{l: 5, u: 2},
        "e"=>{b: 1, l: 21, u: 5},
        "f"=>{l: 10, u: 6},
        "g"=>{b: -3, l: 32, u: 2},
        "h"=>{l: 12, u: 5},
        "i"=>{b: 1, l: 15, u: 6},
        "j"=>{b: -3, l: 15, u: 4},
        "k"=>{b: -3, l: 10, u: 6},
        "l"=>{l: 10, u: 5},
        "m"=>{b: 3, l: 31, u: 8},
        "n"=>{l: 31, u: 8},
        "o"=>{b: -3, l: 27, u: 3},
        "p"=>{b: -3, l: 30, u: 7},
        "q"=>{l: 34, u: 6},
        "r"=>{l: 29, u: 3},
        "s"=>{l: 23, u: 3},
        "t"=>{b: 1, l: 10, u: 7},
        "u"=>{b: 7, l: 25, u: 8},
        "v"=>{l: 26, u: 9},
        "w"=>{b: 3, l: 27, u: 7},
        "x"=>{l: 25, u: 5},
        "y"=>{b: -3, l: 25, u: 5},
        "z"=>{l: 27, u: 10},

        //  Numbers
        "0"=>{l: 3},
        "1"=>{l: 4},
        "2"=>{b: 2, l: 5},
        "3"=>{b: 1, l: 2},
        "4"=>{b: 2, l: 3},
        "5"=>{l: 4},
        "6"=>{l: 4},
        "7"=>{b: 3, l: 8},
        "8"=>{l: 1},
        "9"=>{l: 1},

        //  Symbols
        "|"=> null,
        "~"=> null,
        "#"=> null,
        "$"=> null,
        "%"=> null,
        "("=> null,
        ")"=> null,
        "*"=> null,
        "+"=> null,
        "-"=> {b: 25},
        "_"=> null,
        ":"=> {b:  10},
        ";"=> null,
        "<"=> null,
        ">"=> null,
        "="=> null,
        "@"=> null,
        "["=> null,
        "]"=> null,
        "^"=> null,
        
        "." => {p: "period", b: 50, l:40},
        "," => {p: "comma", l:40},
        "'" => {p: "apostrophe"},
        "!" => {p: "exclamation", b: -10},
        "?" => {p: "question", b: -5},

        //  Spanish and Portuguese Characters
        "á" => {b: -33, l: -5, u: -24},
        "é" => {b: -31, l: -4, u: -20},
        "í" => {b: -32, l: 5, u: -19},
        "ó" => {b: -33, l: 2, u: -22},
        "ú" => {b: -27, l: 1, u: -15},
        
        "â" => {b: -27, u: -20},
        "ê" => {b: -30, u: -19},
        "ô" => {b: -31, l: 5, u: -18},

        "ã" => {b: -24, l: 5, u: -18},
        "õ" => {b: -25, l: 9, u: -15},
        "ï" => {b: -18, l: 17, u: -10},
        "ü" => {b: -13, l: 11, u: -4},

        "ñ" => {b: -22, l: 10, u: -10},
        "ç" => {b: 2, l: 26, u: 2}
    ];

    public function new (x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        super(x,y);
        loadImage("alphabet");
        antialiasing = Preferences.getPref('antialiasing');
    }

    private static final DEFAULT_LETTER:LetterData = {p: null, b: 0, l: 0, u: 0}

    static final alphabet:String = 'abcdefghijklmnopqrstuvwxyz' + 'áéíóúâêôãõïü' + 'ñç';
    static var mappedData:Map<String, LetterData> = [];
    static var offsetY:Float = 0.0;

    public function setupCharacter(x:Float = 0, y:Float = 0, letter:String = '', bold:Bool = true, letterSize:Float = 1):Void {
        setPosition(x,y);
        this.letter = letter;
        this.letterSize = letterSize;
        lowerLetter = letter.toLowerCase();
        if (lowerLetter.length <= 0)
            return;
        
        if (!mappedData.exists(lowerLetter)) {
            mappedData.set(lowerLetter, JsonUtil.checkJson(DEFAULT_LETTER, characters.get(lowerLetter)));
        }
        letterData = mappedData.get(lowerLetter);

        if (bold)
        {
            offsetY = letterData.b;
            prefix = "bold";
        }
        else
        {
            if (alphabet.contains(lowerLetter))
            {
                if (lowerLetter == letter)
                {
                    prefix = "lowercase";
                    offsetY = letterData.l;
                }
                else
                {
                    prefix = "uppercase";
                    offsetY = letterData.u;
                }
            }
            else
            {
                offsetY = letterData.l;
                prefix = "normal";
            }
        }

        if (characters.exists(lowerLetter))
            makeChar();
    }

    public function makeChar():Void
    {
        animPrefix = letterData.p ?? lowerLetter;
        
        if (!animDatas.exists(letter))
            addAnim(letter, '$animPrefix $prefix', 24, true);
        
        playAnim(letter, true);
        y += offsetY * letterSize;
        setScale(letterSize);
    }
}