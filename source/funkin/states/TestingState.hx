package funkin.states;

class TestingState extends MusicBeatState {
    override function create() {
        super.create();
        Conductor.songPosition = 0;
        
        var conductorBar:FlxSprite = new FlxSprite().makeGraphic(500, 5,FlxColor.WHITE);
        conductorBar.screenCenter();
        conductorBar.y -= Preferences.getPref('downscroll') ? -FlxG.height/4 : FlxG.height/4;
        add(conductorBar);

        for (g in 0...16) {
            for (i in 0...4) {
                var susNote:TestNote = new TestNote(i, g*1000, 1000);
                susNote.targetSpr = conductorBar;
                add(susNote);
                susNote.x = FlxG.width/4 + 200 * i%4;
    
                var testNote:TestNote = new TestNote(i, g*1000, 0);
                testNote.targetSpr = conductorBar;
                add(testNote);
                testNote.x = FlxG.width/4 + 200 * i%4;
            }
        }
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        Conductor.songPosition+=elapsed*1000;
        if (FlxG.keys.justPressed.NINE)     FlxG.resetState();
        if (FlxG.keys.justPressed.EIGHT)    Preferences.setPref('downscroll', !Preferences.getPref('downscroll'));
    }
}

class TestNote extends FlxSpriteUtil {
    public var noteData:Int = 0;
    public var strumData:Int = 0;
    public var strumTime:Float = 0;

    var initSusLength:Float = 0;
    public var susLength(default, set):Float = 0;
    public var isSustainNote:Bool = false;

    public var noteSpeed(default, set):Float = 1;
    public var targetSpr:FlxSprite = null;

    // Used for stamp() !!!
    var susPiece:FlxSprite;
    var susEnd:FlxSprite;
    
    public function new (noteData:Int = 0, strumTime:Float = 0, susLength:Float = 0) {
        super();
        this.noteData = noteData;
        this.strumTime = strumTime;
        isSustainNote = susLength > 0;
        initSusLength = susLength;

        var dir = CoolUtil.directionArray[noteData];
        var refSprite = new FlxSpriteUtil();
        refSprite.loadImage("skins/default/noteAssets");
        for (i in 0...4) {
            var nd = CoolUtil.directionArray[i];
            var nc = CoolUtil.colorArray[i];
            refSprite.addAnim('scroll$nd', '${nc}0');
            refSprite.addAnim('hold$nd', '$nc hold piece0');
            refSprite.addAnim('holdEnd$nd', '$nc hold end0');
        }

        if (isSustainNote) {
            susPiece = new FlxSprite().loadGraphicFromSprite(refSprite);
            susPiece.animation.play('hold$dir', true);
            susPiece.updateHitbox();
            susEnd = new FlxSprite().loadGraphicFromSprite(refSprite);
            susEnd.animation.play('holdEnd$dir', true);
            susEnd.updateHitbox();

            set_susLength(susLength);
        } else {
            loadGraphicFromSprite(refSprite);
            animOffsets = refSprite.animOffsets.copy();
            animDatas = refSprite.animDatas.copy();
            playAnim('scroll$dir');
        }

        scale.set(0.7, 0.7);
        updateHitbox();

        if (isSustainNote) {
            offset.set(0, Preferences.getPref('downscroll') ? height : 0);
            offset.x -= NoteUtil.swagWidth / 2 - width / 1.375;
            //offset.y -= NoteUtil.swagHeight / 2;
            alpha = 0.6;
            drawSustain(true); //double check
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetSpr != null) { // Move to strum
            var downscroll = Preferences.getPref('downscroll');
            var noteMove = getMillPos(Conductor.songPosition - strumTime);
            var strumCenter = targetSpr.y;
            y = strumCenter - (downscroll ? -noteMove : noteMove);
            
            if (isSustainNote) { // If its sustain and pressed calculate sustain left
                if ((downscroll ? (y >= strumCenter) : (y <= strumCenter))) {
                    y = strumCenter;
                    susLength = getSusLeft();
                    offset.y = downscroll ? height : 0;
                    //offset.y = downscroll ? getMillPos(susLength) * scale.y : 0;
                    if (susLength <= 0) {
                        destroy();
                    }
                }
            }
        }
    }

    function set_susLength(value:Float):Float {
        susLength = Math.max(value, 0);
        drawSustain();
        return value;
    }

    function set_noteSpeed(value:Float):Float {
        noteSpeed = value;
        drawSustain(true);
        return value;
    }

    public function drawSustain(forced:Bool = false) {
        var _height = Math.floor(Math.max(getMillPos(susLength) * scale.y, 0));
        if ((_height != height && _height > 0) || forced) {
            makeGraphic(Std.int(susPiece.width), _height, FlxColor.TRANSPARENT, false, 'sus$noteData$_height');
            origin.set(susPiece.width / 2, 0);

            // draw piece
            var loops = Math.floor(_height / susPiece.height) + 1;
            for (i in 0...loops) 
                stamp(susPiece, 0, Std.int(i * susPiece.height));
    
            //draw end
            var downScroll = Preferences.getPref('downscroll');
            var endPos = _height - susEnd.height;
            pixels.fillRect(new openfl.geom.Rectangle(0, downScroll ? 0 : endPos, width, susEnd.height), FlxColor.fromRGB(0,0,0,0));
            susEnd.flipY = downScroll;
            stamp(susEnd, 0, downScroll ? 0 : Std.int(endPos));
        }
    }

    function getMillPos(mills:Float):Float {
        return mills * (0.45 * FlxMath.roundDecimal(noteSpeed, 2));
    }

    function getSusLeft():Float {
        return Math.min(Math.max((strumTime + initSusLength) - Conductor.songPosition, 0), initSusLength);
    }
}