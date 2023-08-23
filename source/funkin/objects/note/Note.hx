package funkin.objects.note;

import funkin.objects.NotesGroup;

typedef NoteTypeJson = {
	var mustHit:Bool;
	var hitHealth:Array<Float>;
	var missHealth:Array<Float>;
	var altAnim:String;
	var ?skin:String;
	var showText:Bool;
}

class NoteUtil {
	public static var swagWidth:Float = 160 * 0.7;
	public static var swagHeight:Float = 155 * 0.7;

    public static var DEFAULT_NOTE_TYPE:NoteTypeJson = {
		mustHit: true,
		hitHealth: [0.0237, 0.029],
		missHealth: [0.0475, 0.0118],
		altAnim: '',
		skin: null,	//should be 'default', but null for the stage skin to load
		showText: true
	}

    public static var DEFAULT_NOTE_SKIN:NoteSkinData = {
		anims: [],
		imagePath: "noteAssets",
		scale: 0.7,
		antialiasing: true,
		flipX: false,
		noteColorArray: ["0xffc24b99", "0xff00ffff", "0xff12fa05", "0xfff9393f"]
	}

    public static var noteTypesMap:Map<String, NoteTypeJson> = [];
	public static var noteTypesArray:Array<String> = [];
    
    inline public static function getTypeName(type:Dynamic):Dynamic {
		return (Std.isOfType(type, String)) ? type : noteTypesArray[type];
	}

    inline public static function initTypes():Void {
		noteTypesMap = new Map<String, NoteTypeJson>();
		noteTypesArray = [];
		for (type in JsonUtil.getJsonList('notetypes')) {
			noteTypesArray.push(type);
            getTypeJson(type);
        }
	}

    inline public static function getTypeJson(type:String = 'default'):NoteTypeJson {
		if (noteTypesMap.get(type) != null) return noteTypesMap.get(type);
		var typeJson:NoteTypeJson = JsonUtil.getJson(type, 'notetypes');
		typeJson = JsonUtil.checkJsonDefaults(DEFAULT_NOTE_TYPE, typeJson);
		noteTypesMap.set(type, typeJson);
		return typeJson;
	}

	public static function setSwag(strumArray:Array<NoteStrum>):Void {
		if (strumArray.length <= 0) {
			return;
		}
		var leWidth:Float = 0;
		var leHeight:Float = 0;
		for (strum in strumArray) {
			leWidth += strum.swagWidth;
			leHeight += strum.swagHeight;
		}
		swagWidth = leWidth / strumArray.length;
		swagHeight = leHeight / strumArray.length;
	}

    public static function clearSustainCache() {
        @:privateAccess {
            if (FlxG.bitmap._cache == null) {
                FlxG.bitmap._cache = new Map();
                return;
            }
            for (key in FlxG.bitmap._cache.keys()) {
                if (key.startsWith('sus')) {
                    var obj = FlxG.bitmap.get(key);
                    if (obj != null) {
                        FlxG.bitmap.removeKey(key);
                        obj.destroy();
                    }
                }
            }
        }
    }
}

class Note extends FlxSpriteExt {
    public var noteData:Int = 0;
    public var strumTime:Float = 0;

    public var initSusLength:Float = 0;
    public var susLength(default, set):Float = 0;
    public var isSustainNote:Bool = false;

    public var noteSpeed(default, set):Float = 1;
    public var targetSpr:NoteStrum = null;
    public var mustPress:Bool = false;
    public var parentNote:Note = null; // For sustain notes
    public var childNote:Note = null; // For normal notes

    // Used for stamp() !!!
    var susPiece:FlxSprite;
    var susEnd:FlxSprite;
    var refSprite:FlxSpriteExt;

    public function updateAnims() {
        var dir = CoolUtil.directionArray[noteData];
        if (isSustainNote) {
            susPiece.animation.play('hold$dir', true);
            susPiece.updateHitbox();
            susEnd.animation.play('hold$dir-end', true);
            susEnd.updateHitbox();
        } else {
            playAnim('scroll$dir');
        }
    }

    public function createGraphic(init:Bool = true) {
        var dir = CoolUtil.directionArray[noteData];

        if (isSustainNote) {
            susPiece = new FlxSprite().loadGraphicFromSprite(refSprite);
            susEnd = new FlxSprite().loadGraphicFromSprite(refSprite);

            if (init) { // Offset sustain
                var _off = getPosMill(NoteUtil.swagHeight * 0.5);
                initSusLength += _off / (NotesGroup.songSpeed * 2);
            }
        } else {
            loadGraphicFromSprite(refSprite);
            animOffsets = refSprite.animOffsets.copy();
            animDatas = refSprite.animDatas.copy();
        }

        updateAnims();

        scale.set(refSprite.scale.x, refSprite.scale.y);
        updateHitbox();
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
    public var inSustain:Bool = false;
    public var approachAngle:Float = 0;
    var strumCenter:Float = 0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetSpr != null) { // Move to strum
            var noteMove = getMillPos(Conductor.songPosition - strumTime); // Position with strumtime
            strumCenter = targetSpr.y + targetSpr.swagHeight / 2; // Center of the target strum
            strumCenter -= isSustainNote ? 0 : NoteUtil.swagHeight / 2;
            y = strumCenter - (noteMove * getCos(approachAngle)); // Set Position
            x = targetSpr.x - (noteMove * -getSin(approachAngle));

            if (isSustainNote) { // Get if the sustain is between pressing bounds
                angle = approachAngle;
                flipX = (approachAngle % 360) >= 180;
                
                inSustain = getInSustain(17); // lil offset to be sure
                offset.y = 0;

                if (Conductor.songPosition >= strumTime && pressed) { // Sustain is being pressed
                    setSusPressed();
                }
            } else {
                calcHit();
            }

            active = Conductor.songPosition < (strumTime + initSusLength + getPosMill(NoteUtil.swagHeight * 2));//(getPosMill(height * Math.max(scale.y, 1)) + 100));
        }
    }

    public function getInSustain(extra:Float = 0):Bool {
        return Conductor.songPosition >= strumTime && Conductor.songPosition <= strumTime + initSusLength + extra;
    }

    public function setSusPressed() {
        y = strumCenter;
        drawSustain();
    }

    public function getCos(?_angle) {
        return Math.cos(FlxAngle.asRadians(_angle == null ? approachAngle : _angle));
    }

    public function getSin(?_angle) {
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
    public static inline var susEndHeight:Int = 6; // 0

    public function drawSustain(forced:Bool = false, ?newHeight:Int) {
        if (!isSustainNote) return;
        var _height = newHeight != null ? newHeight : Math.floor(Math.max((getMillPos(getSusLeft()) / scale.y), 0));
        if (_height > (susEndHeight / scale.y)) {
            if (forced || (_height > height)) {// New graphic
                var key:String = 'sus$noteData-$_height-$skin';
                if (FlxG.bitmap.checkCache(key)) { // Save on drawing the graphic more than one time?
                    frames = FlxG.bitmap.get(key).imageFrame;
                    origin.set(width / 2, 0);
                    return;
                } else {
                    makeGraphic(Std.int(susPiece.width), _height, FlxColor.TRANSPARENT, false, 'sus$noteData$_height$skin');
                    origin.set(width / 2, 0);
        
                    // draw piece
                    var loops = Math.floor(_height / susPiece.height) + 1;
                    for (i in 0...loops)
                        stamp(susPiece, 0, Std.int((_height - susEnd.height) - (i * susPiece.height)));
            
                    //draw end
                    var endPos = _height - susEnd.height;
                    pixels.fillRect(new Rectangle(0, endPos, width, susEnd.height), FlxColor.fromRGB(0,0,0,0));
                    stamp(susEnd, 0, Std.int(endPos));
                }
            } else {// Cut
                clipRect = new FlxRect(0, height - _height, width, _height);
                offset.y = (_height - height) * scale.y * -getCos();
                percentCut = (1 / height * _height);
            }
        } else {
            kill();
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
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
				if (strumTime < Conductor.songPosition + 0.5 * Conductor.safeZoneOffset)
					canBeHit = true;
			}
			else {
				willMiss = true;
				canBeHit = true;
			}
		}
	}

    public function changeSkin(value:String = 'default') {
        skin = value;
        createGraphic(false);
        setupSustain();
    }

    public var skin(default, set):String = '';
    public var skinJson:NoteSkinData;
	public function set_skin(value:String = 'default'):String {
		value = (value == null ? SkinUtil.curSkin : value);
		if (value != skin) {
            skin = value;
            try { // Prevent null skins
                skinJson = SkinUtil.getSkinData(skin).noteData;
                skinJson = JsonUtil.checkJsonDefaults(NoteUtil.DEFAULT_NOTE_SKIN, skinJson);
            } catch(e) {
                skin = '_missing_skin';
                skinJson = SkinUtil.getSkinData(skin).noteData;
                skinJson = JsonUtil.checkJsonDefaults(NoteUtil.DEFAULT_NOTE_SKIN, skinJson);
            }

            refSprite = new FlxSpriteExt();
            refSprite.loadImage('skins/$skin/${skinJson.imagePath}', false, false);
            refSprite.scale.set(skinJson.scale,skinJson.scale);
            refSprite.updateHitbox();
            for (anim in skinJson.anims)
                refSprite.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
        }
		return value;
	}

    //function reloadRefSprite = 

    public var noteType(default, set):String = '';
	public var mustHit:Bool = true; // The note gets ignored if false
	public var altAnim:String = '';
	public var hitHealth:Array<Float> = [0.025, 0.0125];
	public var missHealth:Array<Float> = [0.0475, 0.02375];

	public function set_noteType(value:String = 'default'):String {
		var noteJson:NoteTypeJson = NoteUtil.getTypeJson(value);
		mustHit = noteJson.mustHit;
		altAnim = noteJson.altAnim;
		hitHealth = noteJson.hitHealth;
		missHealth = noteJson.missHealth;
		return noteType = value;
	}
}