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
                var testLength = g * 1000;
                var susNote:TestNote = new TestNote(i,testLength, 1000);
                susNote.targetSpr = conductorBar;
                add(susNote);
                susNote.x = FlxG.width/4 + 150 * i%4;
    
                var testNote:TestNote = new TestNote(i, testLength, 0);
                testNote.targetSpr = conductorBar;
                add(testNote);
                testNote.x = FlxG.width/4 + 150 * i%4;
            }
        }
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        Conductor.songPosition+=elapsed*200;
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
            
            //Offset sustain
            var _off = getPosMill(NoteUtil.swagHeight * 0.5);
            initSusLength -= _off;
        } else {
            loadGraphicFromSprite(refSprite);
            animOffsets = refSprite.animOffsets.copy();
            animDatas = refSprite.animDatas.copy();
            playAnim('scroll$dir');
            scale.set(refSprite.scale.x,refSprite.scale.y);
        }

        updateHitbox();

        if (isSustainNote) { // Setup sustain
            drawSustain(true);
            var downscroll = Preferences.getPref('downscroll');
            offset.set();
            offset.x -= NoteUtil.swagWidth / 2 - width / 2.125;
            angle = downscroll ? 180 : 0;
            flipX = downscroll;
            alpha = 0.6;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetSpr != null) { // Move to strum
            var downscroll = Preferences.getPref('downscroll');
            
            var noteMove = getMillPos(Conductor.songPosition - strumTime); // Position with strumtime
            var strumCenter = targetSpr.y + targetSpr.height / 2; // Center of the target strum
            strumCenter -= isSustainNote ? 0 : NoteUtil.swagHeight / 2;
            y = strumCenter - (downscroll ? -noteMove : noteMove); // Set Position
            
            if (Conductor.songPosition >= strumTime) { 
                if (isSustainNote) {    // Sustain is being pressed
                    y = strumCenter;
                    drawSustain();
                } else {
                    destroy();
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
        drawSustain();
        return value;
    }

    public function drawSustain(forced:Bool = false, ?newHeight:Int) {
        var _height = newHeight != null ? newHeight : Math.floor(Math.max((getMillPos(getSusLeft()) / scale.y), 0));
        if ((_height != height && _height > 0) || forced) {
            makeGraphic(Std.int(susPiece.width), _height, FlxColor.TRANSPARENT, false, 'sus$noteData$_height');
            origin.set(width / 2, 0);

            // draw piece
            var loops = Math.floor(_height / susPiece.height) + 1;
            for (i in 0...loops) 
                stamp(susPiece, 0, Std.int(i * susPiece.height));
    
            //draw end
            var endPos = _height - susEnd.height;
            pixels.fillRect(new openfl.geom.Rectangle(0, endPos, width, susEnd.height), FlxColor.fromRGB(0,0,0,0));
            stamp(susEnd, 0, Std.int(endPos));
        }

        if (_height <= 0) {
            destroy();
        }
    }

    public function getPosMill(pos:Float):Float { // Converts a position on screen to song milliseconds
        return pos / (0.45 * FlxMath.roundDecimal(noteSpeed, 2));
    }

    public function getMillPos(mills:Float):Float { // Converts song milliseconds to a position on screen
        return mills * (0.45 * FlxMath.roundDecimal(noteSpeed, 2));
    }

    public function getSusLeft():Float {
        return Math.min(Math.max((strumTime + initSusLength) - Conductor.songPosition, 0), initSusLength);
    }
}