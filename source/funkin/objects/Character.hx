package funkin.objects;

typedef CharacterJson = {
    var icon:String;
	var camOffsets:Array<Int>;
	var charOffsets:Array<Int>;
	var gameOverChar:String;
	var gameOverSuffix:String;
	var isPlayer:Bool;
	var isGF:Bool;
} & SpriteJson;

class Character extends FlxSpriteExt {
	public static var DEFAULT_CHARACTER:CharacterJson = {
		anims: [],
		imagePath: "week1/BOYFRIEND",
		icon: 'bf',
		scale: 1,
		antialiasing: true,
		flipX: false,
		camOffsets: [0,0],
		charOffsets: [0,0],
		gameOverChar: 'bf-dead',
		gameOverSuffix: '',
		isPlayer: false,
		isGF: false
	}

	//	Offsets
	public var worldOffsets:FlxPoint;
	public var stageOffsets:FlxPoint;
	public var camOffsets:FlxPoint;
	public var OG_X:Float = 0;
	public var OG_Y:Float = 0;

	//Extra
	public var debugMode:Bool = false;
	public var botMode:Bool = false;

	//	Display
	public var icon:String = 'face';
	public var iconSpr:HealthIcon = null;
	public var curCharacter:String = 'bf';
	public var isPlayer:Bool = false;
	public var isPlayerJson:Bool = false;
	public var isGF:Bool = false;
	public var gameOverChar:String = 'bf-dead';
	public var gameOverSuffix:String = '';

	//	Gameplay
	public var holdTimer:Float = 0;
	public var stunned:Bool = false;
	public var forceDance:Bool = true;
	public var group:FlxTypedSpriteGroup<Dynamic> = null;

	inline public static function getCharData(char:String = 'bf'):CharacterJson {
		var charJson:CharacterJson = JsonUtil.getJson(char, 'characters');
		charJson = JsonUtil.checkJsonDefaults(DEFAULT_CHARACTER, charJson);
		return charJson;
	}

	public function updatePosition() {
		setXY(OG_X, OG_Y);	
	}
	public function setX(value:Float = 0):Void {
		x = value - worldOffsets.x - stageOffsets.x;
		OG_X = value;
	}
	public function setY(value:Float = 0):Void {
		y = value - worldOffsets.y - stageOffsets.y;
		OG_Y = value;
	}
	public function setXY(valueX:Float = 0, valueY:Float = 0):Void {
		setX(valueX);
		setY(valueY);
	}
	public function setFlipX(value:Bool):Void {
		flippedOffsets = false;
		if (isPlayer != isPlayerJson) {
			flipCharOffsets();
		}
		flipX = isPlayer ? !value : value;
	}

	public function loadCharJson(inputJson:CharacterJson):Void {
		var imagePath:String = (!inputJson.imagePath.startsWith('characters/')) ? 'characters/${inputJson.imagePath}' : inputJson.imagePath;
		loadImage(imagePath);
		for (anim in inputJson.anims) {
			anim = JsonUtil.checkJsonDefaults(JsonUtil.copyJson(FlxSpriteExt.DEFAULT_ANIM), anim);
			addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
		}
	}

	public function new(?X:Float, ?Y:Float, character:String = "bf", isPlayer:Bool = false, debugMode:Bool = false, ?inputJson:CharacterJson):Void {
		super(X,Y);
		worldOffsets = new FlxPoint().set(0,0);
		stageOffsets = new FlxPoint().set(0,0);
		camOffsets = new FlxPoint().set(0,0);

		this.debugMode = debugMode;
		this.isPlayer = isPlayer;
		botMode = !isPlayer;

		var charJson:CharacterJson = getCharData(curCharacter = character);
		loadCharJson(charJson);
		worldOffsets.set(charJson.charOffsets[0], charJson.charOffsets[1]);
		camOffsets.set(charJson.camOffsets[0], charJson.camOffsets[1]);
		scale.set(charJson.scale,charJson.scale);
		updateHitbox();
		isPlayerJson = charJson.isPlayer;
		isGF = charJson.isGF;
		gameOverChar = charJson.gameOverChar;
		gameOverSuffix = charJson.gameOverSuffix;
		setFlipX(charJson.flipX);
		setXY(x,y);
		antialiasing = charJson.antialiasing ? Preferences.getPref('antialiasing') : false;
		icon = charJson.icon;
		nullAnimCheck(); //	Find an anim to play to not have null curAnim
	}

	public function nullAnimCheck():Void {
		getDanceAnim();
		if(animation.curAnim == null) {
			for (anim in animOffsets.keys())
				playAnim(anim);
		}
		if (animation.curAnim != null)
			animation.curAnim.finish();
	}

	public function flipCharOffsets():Void {
		flippedOffsets = true;
		//worldOffsets.x *= -1; IDK
		//stageOffsets.x *= -1;
		camOffsets.x *= -1;
		if (!debugMode) { // Switch anims
			switchAnim('danceLeft', 'danceRight');
			for (i in animOffsets.keys()) {
				if (i.startsWith("singRIGHT")) {
					var prefix = i.split("singRIGHT")[1];
					switchAnim('singRIGHT$prefix', 'singLEFT$prefix');
				}
			}
		}
	}

	override function update(elapsed:Float):Void {
		if(animation.curAnim != null) {
			var _curAnim = animation.curAnim;
			if (_curAnim.finished) {
				var loopAnim:String = '${_curAnim.name}-loop'; 
				if (animOffsets.exists(loopAnim))
					playAnim(loopAnim);
			}

			if (_curAnim.name.startsWith('sing') && !specialAnim && !debugMode) {
				holdTimer += elapsed;

				var finishAnim:Bool = botMode ? (holdTimer >= Conductor.crochetMills) :
				(_curAnim.name.endsWith('miss') && _curAnim.finished && !debugMode);

				if (finishAnim) {
					dance();
					holdTimer = 0;
				}
			}
		}

		super.update(elapsed);
	}

	public function copyStatusFrom(char:Character) {
		return char.copyStatusTo(this);
	}

	public function copyStatusTo(char:Character) {
		char.group = group;
		char.iconSpr = iconSpr;
		char.holdTimer = holdTimer;
		char.specialAnim = specialAnim;
		char.botMode = botMode;
		stageOffsets.copyFrom(char.stageOffsets);
		char.setXY(OG_X,OG_Y);

		var lastAnim = animation.curAnim;
		if (lastAnim != null)
			char.playAnim(lastAnim.name, true, false, lastAnim.curFrame);

		return char;
	}

	public var _singHoldTimer:Float = 0;
	public var holdFrame:Int = 2;

	public function sing(noteData:Int = 0, altAnim:String = '', hit:Bool = true):Void {
		var singAnim = 'sing${CoolUtil.directionArray[noteData%Conductor.NOTE_DATA_LENGTH]}$altAnim';
		if (!existsOffsets(singAnim)) return;
		
		holdTimer = 0;
		if (hit) {
			playAnim(singAnim, true);
			_singHoldTimer = 0;
		} else {
			_singHoldTimer += FlxG.elapsed;
			if (_singHoldTimer >= ((holdFrame / 24) - 0.01) && !specialAnim) {
				playAnim(singAnim, true);
				_singHoldTimer = 0;
			}
		}
	}

	public function hey():Void {
		var heyAnim = isGF ? 'cheer' : 'hey';
		if (!existsOffsets(heyAnim)) return;

		playAnim(heyAnim, true);
		specialAnim = true;
		new FlxTimer().start(Conductor.crochetMills, function(tmr:FlxTimer) {
			specialAnim = false;
			dance();
		});
	}

	public var danced:Bool = false;
	public var idleAlt:String = "";

	public function danceCheck() {
		if (animation.curAnim == null) return;
		if (!animation.curAnim.name.startsWith("sing"))
			dance();
	}

	public function dance():Void {
		if (!debugMode && forceDance && !specialAnim) {
			getDanceAnim();
		}
	}

	function getDanceAnim():Void {
		var _danceRight = 'danceRight' + idleAlt;
		var _danceLeft = 'danceLeft' + idleAlt;
		var _idle = 'idle' + idleAlt;
		if (animOffsets.exists(_danceRight) && animOffsets.exists(_danceLeft)) {
			danced = !danced;
			playAnim(danced ? _danceRight : _danceLeft);
		}
		else if (animOffsets.exists(_idle)) {
			playAnim(_idle);
		}
	}
}