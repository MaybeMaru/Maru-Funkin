package funkin.objects.note;

import funkin.objects.NotesGroup;

interface INoteData {
    public var noteData:Int;
}

class Note extends FlxSpriteExt implements INoteData {
    public var noteData:Int = 0;
    public var strumTime:Float = 0;

    public var initSusLength:Float = 0;
    public var susLength(default, set):Float = 0;
    public var isSustainNote:Bool = false;

    public var noteSpeed(default, set):Float = 1;
    public var targetStrum:NoteStrum = null;
    public var mustPress:Bool = false;
    public var parentNote:Note = null; // For sustain notes
    public var childNote:Note = null; // For normal notes

    // Used for stamp() !!!
    var susPiece:FlxSprite;
    var susEnd:FlxSprite;
    var refSprite:FlxSpriteExt;

    public function updateAnims() {
        if (isSustainNote) return;
        var dir = CoolUtil.directionArray[noteData];
        playAnim('scroll$dir');
    }

    public function createGraphic(init:Bool = true) {
        var dir = CoolUtil.directionArray[noteData];

        if (isSustainNote) {
            if (init) { // Offset sustain
                var _off = getPosMill(NoteUtil.swagHeight * 0.5);
                initSusLength += _off / (NotesGroup.songSpeed * 2);
            }
        } else {
            loadFromSprite(refSprite);
            updateAnims();
        }

        setScale(skinJson.scale, true);
        antialiasing = skinJson.antialiasing ? Preferences.getPref('antialiasing') : false;

        if (!isSustainNote) {
            var _anim = 'scroll$dir';
            if (animOffsets.exists(_anim)) {
                var _off = animOffsets.get(_anim);
                offset.add(_off.x, _off.y);
            }
        }
    }

    public var susOffsetX:Float = 0;

    public function setupSustain() {
        if (isSustainNote) {
            drawSustain(true);
            susOffsetX = -(NoteUtil.swagWidth * 0.5 - width * 0.5);
            offset.set(susOffsetX,0);
            alpha = 0.6;
        }
    }
    
    public function new (noteData:Int = 0, strumTime:Float = 0, susLength:Float = 0, skin:String = 'default') {
        super();
        this.noteData = noteData;
        this.strumTime = strumTime;
        isSustainNote = susLength > 0;
        initSusLength = susLength;
        this.skin = skin;
        approachAngle = Preferences.getPref('downscroll') ? 180 : 0;

        createGraphic();
        setupSustain();
    }

    public var pressed:Bool = false;
    public var startedPress:Bool = false;
    public var missedPress(default, set):Bool = false;
    public function set_missedPress(value:Bool) {
        color = (value && mustHit) ? FlxColor.fromRGB(200,200,200) : FlxColor.WHITE;
        return missedPress = value;
    } 

    public var inSustain:Bool = false;
    public var approachAngle:Float = 0;
    public var spawnMult:Float = 1;
    var strumCenter:Float = 0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetStrum == null) return; // Move to strum
        var noteMove = getMillPos(Conductor.songPosition - strumTime); // Position with strumtime
        strumCenter = targetStrum.y + targetStrum.swagHeight / 2; // Center of the target strum
        strumCenter -= isSustainNote ? 0 : NoteUtil.swagHeight / 2;
        y = strumCenter - (noteMove * getCos(approachAngle)); // Set Position
        x = targetStrum.x - (noteMove * -getSin(approachAngle));

        if (isSustainNote) { // Get if the sustain is between pressing bounds
            angle = approachAngle;
            flipX = (approachAngle % 360) >= 180;
                
            inSustain = getInSustain(20); // lil extra time to be sure
            offset.y = 0;

            if (Conductor.songPosition >= strumTime && pressed && !missedPress) { // Sustain is being pressed
                setSusPressed();
            }
        } else {
            calcHit();
        }

        active = Conductor.songPosition < (strumTime + initSusLength + getPosMill(NoteUtil.swagHeight * 2));
    }

    inline public function getInSustain(endExtra:Float = 0, startExtra:Float = 0):Bool {
        return Conductor.songPosition >= strumTime + startExtra && Conductor.songPosition <= strumTime + initSusLength + endExtra;
    }

    inline public function setSusPressed() {
        y = strumCenter;
        drawSustain();
    }

    inline public function getCos(?_angle) {
        return Math.cos(FlxAngle.asRadians(_angle == null ? approachAngle : _angle));
    }

    inline public function getSin(?_angle) {
        return Math.sin(FlxAngle.asRadians(_angle == null ? approachAngle : _angle));
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

    public var percentCut:Float = 1;
    public var susEndHeight:Int = 12; // 0

    public function drawSustain(forced:Bool = false, ?newHeight:Int) {
        if (!isSustainNote) return;
        var _height = newHeight != null ? newHeight : Math.floor(Math.max((getMillPos(getSusLeft()) / scale.y), 0));
        if (_height > (susEndHeight / scale.y)) {
            if (forced || (_height > height)) {// New graphic
                drawSustainCached(_height);
            } else {// Cut
                clipRect = new FlxRect(0, height - _height, width, _height);
                offset.y = (_height - height) * scale.y * -getCos();
                percentCut = (1 / height * _height);
            }
        } else {
            kill();
        }
    }

    public function drawSustainCached(_height:Int) {
        var key:String = 'sus$noteData-$_height-$skin';
        if (Paths.existsGraphic(key)) { // Save on drawing the graphic more than one time?
            frames = Paths.getGraphic(key).imageFrame;
            origin.set(width / 2, 0);
            return;
        } else {
            updateSprites();
            frames = Paths.addGraphic(cast susPiece.width, _height, FlxColor.TRANSPARENT, key).imageFrame;
            origin.set(width / 2, 0);
        
            // draw piece
            var loops = Math.floor(_height / susPiece.height) + 1;
            for (i in 0...loops)
                    stamp(susPiece, 0, Std.int((_height - susEnd.height) - (i * susPiece.height)));
            
            //draw end
            var endPos = _height - susEnd.height;
            pixels.fillRect(new Rectangle(0, endPos, width, susEnd.height), FlxColor.fromRGB(0,0,0,0));
            stamp(susEnd, 0, cast endPos);
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

    public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;

	public function calcHit():Void {
		if (willMiss && !wasGoodHit) {
			tooLate = true;
			canBeHit = false;
		}
		else {
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * hitMult) {
				if (strumTime < Conductor.songPosition + 0.5 * Conductor.safeZoneOffset * hitMult)
					canBeHit = true;
			}
			else {
				willMiss = true;
				canBeHit = true;
			}
		}
	}

    inline public function changeSkin(value:String = 'default') {
        skin = value;
        createGraphic(false);
        setupSustain();
    }

    public var skin(default, set):String = '';
    public var skinJson:NoteSkinData;
	public function set_skin(value:String = 'default'):String {
		value = (value == null ? SkinUtil.curSkin : value);
        skin = value;
        updateSprites();
        return value;
	}

    public function updateSprites() {
        var mapData = NoteUtil.getSkinSprites(skin, noteData);
        refSprite = mapData.baseSprite;
        susPiece = mapData.susPiece;
        susEnd = mapData.susEnd;
        skinJson = mapData.skinJson;
    }

    public var noteType(default, set):String = '';
	public var mustHit:Bool = true; // The note gets ignored if false
	public var altAnim:String = '';
	public var hitHealth:Array<Float> = [0.025, 0.0125];
	public var missHealth:Array<Float> = [0.0475, 0.02375];
    public var hitMult:Float = 1;

	public function set_noteType(value:String = 'default'):String {
		var noteJson:NoteTypeJson = NoteUtil.getTypeJson(value);
		mustHit = noteJson.mustHit;
		altAnim = noteJson.altAnim;
		hitHealth = noteJson.hitHealth;
		missHealth = noteJson.missHealth;
        hitMult = FlxMath.bound(noteJson.hitMult, 0.01, 1);
		return noteType = value;
	}
}