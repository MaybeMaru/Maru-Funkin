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
                var testLength = g * 400;
                var susNote:TestNote = new TestNote(i,testLength, 400);
                susNote.targetSpr = conductorBar;
                add(susNote);
                susNote.x = FlxG.width/4 + 200 * i%4;
                //susNote.y = susNote.getMillPos(susNote.strumTime);
    
                var testNote:TestNote = new TestNote(i, testLength, 0);
                testNote.targetSpr = conductorBar;
                add(testNote);
                testNote.x = FlxG.width/4 + 200 * i%4;
                //testNote.y = testNote.getMillPos(susNote.strumTime);
            }
        }
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        Conductor.songPosition+=elapsed*100;
        if (FlxG.keys.justPressed.NINE)     FlxG.resetState();
        if (FlxG.keys.justPressed.EIGHT)    Preferences.setPref('downscroll', !Preferences.getPref('downscroll'));
    }
}

class TestNote extends FlxSpriteUtil {
    public var noteData:Int = 0;
    public var strumData:Int = 0;
    public var strumTime:Float = 0;

    public var initSusLength:Float = 0;
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
        refSprite.scale.set(0.7,0.7);
        refSprite.updateHitbox();
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
            scale.set(refSprite.scale.x,refSprite.scale.y);
            set_susLength(susLength);
        } else {
            loadGraphicFromSprite(refSprite);
            animOffsets = refSprite.animOffsets.copy();
            animDatas = refSprite.animDatas.copy();
            playAnim('scroll$dir');
            scale.set(refSprite.scale.x,refSprite.scale.y);
        }

        updateHitbox();

        if (isSustainNote) {
            drawSustain(true, Math.floor((height - NoteUtil.swagHeight / 2) / scale.y));
            var downscroll = Preferences.getPref('downscroll');
            offset.set(0, downscroll ? height - NoteUtil.swagHeight : 0);
            offset.x -= NoteUtil.swagWidth / 2 - width / 2.125;
            //offset.y -= NoteUtil.swagHeight * (downscroll ? 1 : 0.5);
            alpha = 0.6;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetSpr != null) { // Move to strum
            var downscroll = Preferences.getPref('downscroll');
            var noteMove = getMillPos(Conductor.songPosition - strumTime);
            var strumCenter = targetSpr.y + targetSpr.height / 2;
            var susOffset = isSustainNote ?  NoteUtil.swagHeight * 0.5 : 0;
            y = strumCenter + susOffset - (downscroll ? -noteMove : noteMove);

            if (Conductor.songPosition >= strumTime && isSustainNote) {
                var _susOffset = Math.max(getMillPos(strumTime + initSusLength - Conductor.songPosition), 0);
                y = strumCenter + _susOffset - (downscroll ? -noteMove : noteMove);

                if (Conductor.songPosition >= (strumTime + initSusLength)) {
                    destroy();
                }

                //trace(getMillPos(Conductor.songPosition - strumTime));
                //susLength = getSusLeft() - NoteUtil.swagHeight * 0.5;
            }
            
            /*if (isSustainNote) { // If its sustain and pressed calculate sustain left
                if ((downscroll ? (y >= strumCenter) : (y <= strumCenter))) {
                    y = strumCenter;
                    susLength = getSusLeft();
                    offset.y = downscroll ? height : 0;
                }
            }*/
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

    public function drawSustain(forced:Bool = false, ?newHeight:Int) {
        var _height = newHeight != null ? newHeight : Math.floor(Math.max(getMillPos(susLength) / scale.y, 0));
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

        if (_height <= 0) {
            destroy();
        }
    }

    public function getMillPos(mills:Float):Float {
        return mills * (0.45 * FlxMath.roundDecimal(noteSpeed, 2));
    }

    public function getSusLeft():Float {
        return Math.min(Math.max((strumTime + initSusLength) - Conductor.songPosition, 0), initSusLength);
    }
}