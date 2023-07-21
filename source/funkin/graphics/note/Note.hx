package funkin.graphics.note;

typedef NoteTypeJson = {
	var mustHit:Bool;
	var hitHealth:Array<Float>;
	var missHealth:Array<Float>;
	var altAnim:String;
	var ?skin:String;
	var showText:Bool;
}

class NoteUtil {
	public static var swagWidth:Float = 155 * 0.7;
	public static var swagHeight:Float = 155 * 0.7;
	public static inline var speedOffset:Float = 0.65; //0.45?

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
		sustainScaleOffset: 1,
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
		if (noteTypesMap.get(type) != null) {
			return noteTypesMap.get(type);
		}
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
}

class Note extends FlxTypedSpriteGroup<FlxSpriteUtil> {
    public var noteSpr:FlxSpriteUtil;
    public var susSpr:FlxSpriteUtil;
    public var susTailSpr:FlxSpriteUtil;

    public var strumTime:Float = 0;
    public var noteData:Int = 0;
    public var susLength(default, set):Float = 0;
    public var noteSpeed(default, set):Float = 1;
    public var stepCrochet:Float = 0;
    public var targetSpr:FlxSprite = null;
	public var forceStrum:Bool = true;				// Forces the strum to go to the parent strum
	public var isSustainNote:Bool = false;			// Shortcut to susLength > 0

    public function set_noteSpeed(val:Float):Float {
        val = Math.abs(val);
        if (val < 0.1) {
            val = 0.1;
        }
        noteSpeed = val;
        set_susLength(susLength);
        return val;
    }

    public function set_susLength(val:Float):Float {
        val = Math.floor(val);
		susLength = val;
		isSustainNote = val > 0;
		susSpr.visible = isSustainNote;
		susTailSpr.visible = isSustainNote;
        if (isSustainNote) {
            susSpr.origin.y = 0;
			var scaledHeight = getMillScale(val) - pixelToScale(susSpr, NoteUtil.swagWidth/2) - pixelToScale(susSpr, susTailSpr.height);
			scaledHeight = (scaledHeight < 0 ? 0 : scaledHeight);
            susSpr.scale.y = scaledHeight;
            updateHitboxCustom(susSpr);
            
            susSpr.scale.y = pixelToScale(susSpr, (susSpr.height + pixelToScale(susSpr, height) - 1));
            var downScroll:Bool = Preferences.getPref('downscroll');
            susSpr.scale.y *= downScroll ? -1 : 1;
            susTailSpr.origin = susSpr.origin;
            susTailSpr.scale.y = Math.abs(susTailSpr.scale.y);
            susTailSpr.scale.y *= downScroll ? -1 : 1;
            updateSusPos();
        }
        return val;
    }

    public function new(strumTime:Float = 0, noteData:Int = 0, susLength:Float = 0, stepCrochet:Float = 0):Void {
        super(-2000,0);
        this.noteData = noteData;
        this.stepCrochet = stepCrochet;
		skin = null; // Get the default skin

        this.strumTime = strumTime;
        this.susLength = (Math.floor(susLength) > 0 ? susLength + stepCrochet : 0);
		scrollFactor.set();
    }

    public var skin(default, set):String = '';
	public var type(default, set):String = '';
    public var noteJson:NoteSkinData;

	public function set_skin(?value:String):String {
		value = (value == null ? SkinUtil.curSkin : value);
		if (value != skin) {
			skin = value;

            noteJson = SkinUtil.getSkinData(skin).noteData;
			noteJson = JsonUtil.checkJsonDefaults(NoteUtil.DEFAULT_NOTE_SKIN, noteJson);

            for (spr in this) {
                spr.visible = false;
            }

            for (i in 0...3) {
                var spr = new FlxSpriteUtil();
                spr.loadImage('skins/$skin/${noteJson.imagePath}');
                for (anim in noteJson.anims) {
                    spr.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
                }
                spr.antialiasing = noteJson.antialiasing;
                spr.antialiasing = spr.antialiasing ? Preferences.getPref('antialiasing') : false;

                switch(i) {
                    case 2: noteSpr = spr;      add(noteSpr);
                    case 1: susSpr = spr;       add(susSpr);    susSpr.clipRect = new FlxRect(0, 0, susSpr.frameWidth, susSpr.frameHeight-1);
                    case 0: susTailSpr = spr;   add(susTailSpr);
                }
            }
            playPartsAnims();
        }
		return value;
	}

    public function playPartsAnims(?jsonScale:Float):Void {
        jsonScale = jsonScale != null ? jsonScale : noteJson.scale;
        var dir = CoolUtil.directionArray[noteData];
        var anims = [
            'hold$dir-end',
            'hold$dir',
            'scroll$dir'
        ];

        var i:Int = 0;
        for (spr in this) {
            spr.playAnim(anims[i]);
            spr.updateHitbox();
            spr.scale.set(jsonScale,jsonScale);

            switch (i) {
                case 2:  spr.updateHitbox();
                default: updateHitboxCustom(spr); spr.alpha = 0.6;
            }
            i++;
        }
    }

	public var mustHit:Bool = true; // The note gets ignored if false
	public var altAnim:String = '';
	public var hitHealth:Array<Float> = [0.025, 0.0125];
	public var missHealth:Array<Float> = [0.0475, 0.02375];

	public function set_type(value:String = 'default'):String {
		type = value;
		var noteJson:NoteTypeJson = NoteUtil.getTypeJson(type);
		mustHit = noteJson.mustHit;
		altAnim = noteJson.altAnim;
		hitHealth = noteJson.hitHealth;
		missHealth = noteJson.missHealth;
		return value;
	}

	function updateSusPos():Void {
        susSpr.y = noteSpr.y + NoteUtil.swagWidth/2;
        susTailSpr.y = susSpr.y + (Preferences.getPref('downscroll') ? -susSpr.height : susSpr.height);

        updateHitboxCustom(noteSpr);
        updateHitboxCustom(susSpr);
        susSpr.x = noteSpr.x + noteSpr.width/2 - (susSpr.width/2)/susSpr.scale.x;
        susTailSpr.x = susSpr.x;
    }

    private function updateHitboxCustom(spr:FlxSpriteUtil):Void {
        spr.width = Math.abs(spr.scale.x) * spr.frameWidth;
        spr.height = Math.abs(spr.scale.y) * spr.frameHeight;
    }
    private function pixelToScale(spr:FlxSprite, pixelSize:Float, getHeight:Bool = true):Float {
        return pixelSize / (getHeight ? spr.frameHeight : spr.frameWidth);
    }
    private function getMillScale(millLength:Float):Float {
        return Math.abs(pixelToScale(susSpr, getMillPos(millLength)));
    }
    private function getMillPos(mills:Float):Float {
		return (mills / 1000) * FlxG.height * noteSpeed * NoteUtil.speedOffset;
    }

    override public function update(elp:Float):Void {
        super.update(elp);
        if (targetSpr != null) {
			var centerX = NoteUtil.swagWidth/2 - noteSpr.width/2;
			x = (targetSpr.x + centerX);

			var downscroll = Preferences.getPref('downscroll');
			var noteMove = getMillPos(Conductor.songPosition - strumTime);
			var centerY = NoteUtil.swagHeight/2 - noteSpr.height/2;
            y = (targetSpr.y + centerY) - (downscroll ? -noteMove : noteMove);

            calcHit();
            calcSus();

			active = (downscroll ? (y < FlxG.height) : (y > -height));
        }
    }

    public var sustainPressed:Bool = false;  // Cuts the note to the middle of the struns
	public var hitSustainStart:Bool = false; // Checks if the tip of the sustain has been pressed already
    public var inSustain:Bool = false;       // If in the current song position the sustain key should be pressed
    public var mustPress:Bool = false;       // If the note should or not be on the players lane  

    public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;

	public function calcHit():Void {
		if (mustPress) {
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			}
			else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					if (strumTime < Conductor.songPosition + 0.5 * Conductor.safeZoneOffset) {
						canBeHit = true;
					}
				}
				else {
					willMiss = true;
					canBeHit = true;
				}
			}
		}
		else {
			canBeHit = false;
			if (strumTime <= Conductor.songPosition) {
				wasGoodHit = true;
			}
		}
	}

    function calcSus():Void {
        inSustain = strumTime <= Conductor.songPosition && strumTime + susLength >= Conductor.songPosition;
        if (inSustain) {
            //trace('IN SUSSS');
        }

        if (sustainPressed) {
            var susParts = [susTailSpr, susSpr];
            var downscroll = Preferences.getPref('downscroll');
            for (i in 0...susParts.length) {
                var daNote = susParts[i];
                var center = targetSpr.y + (NoteUtil.swagHeight / 2);
                var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight-i);
                if ((!downscroll ?
                    daNote.y + daNote.offset.y * daNote.scale.y <= center :
                    daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)) {
                    if (!downscroll) {
                        swagRect.y = (center - daNote.y) / daNote.scale.y;
                        swagRect.height -= swagRect.y;
                    } else {
                        swagRect.y = daNote.frameHeight - swagRect.height;
                        swagRect.height = (center - daNote.y) / daNote.scale.y;
                    }
                    daNote.clipRect = swagRect;
                }
            }
        }
    }
}