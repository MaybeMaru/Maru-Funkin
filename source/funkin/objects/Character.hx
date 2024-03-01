package funkin.objects;

import flixel.util.FlxDestroyUtil;

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
	public static final DEFAULT_CHARACTER:CharacterJson = {
		anims: [],
		imagePath: "week1/BOYFRIEND",
		allowLod: true,
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
	public var stageCamOffsets:FlxPoint;
	public var camOffsets:FlxPoint;
	public var OG_X:Float = 0;
	public var OG_Y:Float = 0;

	//Extra
	public var debugMode:Bool = false;
	public var botMode:Bool = false;
	public var script:FunkScript = null;
	public var type:String = "";

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
	public var forceDance:Bool = true;
	public var group:SpriteGroup;

	inline public function callScript(field:String, ?values:Array<Dynamic>):Void {
		if (script != null) script.call(field, values);
	}

	inline public static function getCharData(char:String = 'bf'):CharacterJson {
		var charJson:CharacterJson = JsonUtil.getJson(char, 'characters');
		charJson = JsonUtil.checkJsonDefaults(DEFAULT_CHARACTER, charJson);
		return charJson;
	}

	inline public function updatePosition() {
		setXY(OG_X, OG_Y);	
	}

	inline public function setX(value:Float = 0):Void {
		x = value - worldOffsets.x - stageOffsets.x;
		OG_X = value;
	}

	inline public function setY(value:Float = 0):Void {
		y = value - worldOffsets.y - stageOffsets.y;
		OG_Y = value;
	}

	inline public function setXY(valueX:Float = 0, valueY:Float = 0):Void {
		setX(valueX);
		setY(valueY);
	}

	inline public function setFlipX(value:Bool):Void {
		flippedOffsets = false;
		if (isPlayer != isPlayerJson)
			flipCharOffsets();
		flipX = isPlayer ? !value : value;
	}

	public function loadCharJson(inputJson:CharacterJson):Void
	{
		var path = inputJson.imagePath;
		if (!path.startsWith('characters/'))
			path = 'characters/$path';

		var lod:Null<LodLevel> = inputJson.allowLod ? null : HIGH;

		loadImage(path, false, null, null, lod);
		
		inputJson.anims.fastForEach((anim, i) -> {
			final anim = JsonUtil.checkJsonDefaults(JsonUtil.copyJson(FlxSpriteExt.DEFAULT_ANIM), anim);
			addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
		});
	}

	public function new(?X:Float, ?Y:Float, character:String = "bf", isPlayer:Bool = false, debugMode:Bool = false, ?inputJson:CharacterJson):Void {
		super(X, Y);
		worldOffsets = FlxPoint.get();
		stageOffsets = FlxPoint.get();
		stageCamOffsets = FlxPoint.get();
		camOffsets = FlxPoint.get();

		this.debugMode = debugMode;
		this.isPlayer = isPlayer;
		botMode = !isPlayer;

		final charJson:CharacterJson = getCharData(curCharacter = character);
		loadCharJson(charJson);
		worldOffsets.set(charJson.charOffsets[0], charJson.charOffsets[1]);
		camOffsets.set(charJson.camOffsets[0], charJson.camOffsets[1]);
		setScale(charJson.scale);
		isPlayerJson = charJson.isPlayer;
		isGF = charJson.isGF;
		gameOverChar = charJson.gameOverChar;
		gameOverSuffix = charJson.gameOverSuffix;
		setFlipX(charJson.flipX);
		setXY(x, y);
		antialiasing = charJson.antialiasing ? Preferences.getPref('antialiasing') : false;
		icon = charJson.icon;

		curDanceBeat = danceBeat = isDoubleDancer() ? 0 : 1;
		nullAnimCheck(); //	Find an anim to play to not have null curAnim
		spriteJson = charJson;
	}

	public function getAnimationPrefixes():Array<String> {
		var prefixes:Array<String> = [];
		if (frames == null) return prefixes;
		for (i in frames.frames) {
			var anim = i.name.split('0')[0];
			if (!prefixes.contains(anim)) prefixes.push(anim);
		}
		return prefixes;
	}

	public function nullAnimCheck():Void {
		getDanceAnim();
		if(animation.curAnim == null) {
			for (anim in animOffsets.keys())
				playAnim(anim);
		}
		if (animation.curAnim != null) {
			if (!getAnimData(animation.curAnim.name).loop)
				animation.curAnim.finish();
		}
	}

	public function flipCharOffsets():Void {
		flippedOffsets = true;
		camOffsets.x = -camOffsets.x;
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
		var curAnim = animation.curAnim;
		if(curAnim != null) {
			var curName = curAnim.name;
			
			if (curAnim.finished) {
				var loopAnim:String = '${curName}-loop'; 
				if (animOffsets.exists(loopAnim))
					playAnim(loopAnim);
			}

			if (!debugMode)
			{
				if (!specialAnim) if (curName.startsWith('sing')) {
					holdTimer += elapsed;

					final finishAnim:Bool = botMode ? (holdTimer >= Conductor.crochetMills) :
					(curName.endsWith('miss') && curAnim.finished);

					if (finishAnim) {
						restartDance();
						holdTimer = 0;
					}
				}
			}
		}

		__superUpdate(elapsed);
	}

	public function prepareCamPoint(?point:Null<FlxPoint>, ?bounds:Array<Float>) {
		point = getMidpoint(point);
		point.subtract(camOffsets.x, camOffsets.y);
		point.subtract(flippedOffsets ? -stageCamOffsets.x : stageCamOffsets.x, stageCamOffsets.y);
		
		if (bounds != null) {
			point.x = FlxMath.bound(point.x, bounds[0], bounds[2]);
			point.y = FlxMath.bound(point.y, bounds[1], bounds[3]);
		}
		
		return point;
	}

	public inline function copyStatusFrom(char:Character) {
		return char.copyStatusTo(this);
	}

	public function copyStatusTo(char:Character) {
		char.group = group;
		char.iconSpr = iconSpr;
		char.holdTimer = holdTimer;
		char.specialAnim = specialAnim;
		char.botMode = botMode;
		char.stageOffsets.copyFrom(stageOffsets);
		char.stageCamOffsets.copyFrom(stageCamOffsets);
		char.type = type;
		char.setXY(OG_X,OG_Y);

		final lastAnim = animation.curAnim;
		if (lastAnim != null)
			char.playAnim(lastAnim.name, true, false, lastAnim.curFrame);

		return char;
	}

	public var _singHoldTimer:Float = 0;
	public var holdFrame:Int = 2;

	public function sing(noteData:Int = 0, altAnim:String = '', hit:Bool = true):Void {
		final singAnim = 'sing${CoolUtil.directionArray[noteData%Conductor.NOTE_DATA_LENGTH]}$altAnim';
		if (!existsOffsets(singAnim)) return;
		
		holdTimer = 0;
		if (hit) {
			playAnim(singAnim, true);
			_singHoldTimer = 0;
		}
		else {
			_singHoldTimer += FlxG.elapsed;
			if (_singHoldTimer >= ((holdFrame / 24) - 0.01)) if (!specialAnim) {
				playAnim(singAnim, true);
				_singHoldTimer = 0;
			}
		}
	}

	var heyTimer:FlxTimer = null;

	public function hey():Void {
		final heyAnim = isGF ? 'cheer' : 'hey';
		if (!existsOffsets(heyAnim)) return;

		playAnim(heyAnim, true);
		specialAnim = true;
		if (heyTimer != null)
			heyTimer.cancel();

		heyTimer = new FlxTimer().start(Conductor.crochetMills, function(tmr:FlxTimer) {
			specialAnim = false;
			final curAnim = animation.curAnim;
			if (curAnim == null) return;
			if (curAnim.name == 'hey' || curAnim.name == 'cheer')
				restartDance();
		});
	}

	inline public function restartDance() {
		dance();
		curDanceBeat = danceBeat;
	}

	public var danceBeat:Int = 0;
	public var idleAlt:String = "";

	public var danced:Bool = false;
	public var curDanceBeat:Int = 0;

	public function inIdle() {
		final curAnim = animation.curAnim;
		if (curAnim == null) return false;
		return curAnim.name.startsWith('dance') || curAnim.name.startsWith('idle');
	}

	public function dance() {
		if (!debugMode) if (forceDance) if (!specialAnim)
			getDanceAnim();
	}

	public function danceInBeat() {
		final curAnim = animation.curAnim;
		if (curAnim == null) return;
		if (!animation.curAnim.name.startsWith("sing")) {
			curDanceBeat--;
			if (curDanceBeat < 0) {
				curDanceBeat = danceBeat;
				dance();
			}
		}
	}

	@:deprecated("danceCheck() is deprecated, use danceInBeat() instead")
	public inline function danceCheck() // Backwards compatibility lol
		danceInBeat();

	function isDoubleDancer() {
		for(i in animOffsets.keys()) {
			if (i.startsWith("danceRight"))
				return true;
		}
		return false;
	}

	function getDanceAnim():Void {
		final _danceRight = 'danceRight' + idleAlt;
		final _danceLeft = 'danceLeft' + idleAlt;
		final _idle = 'idle' + idleAlt;
		if (animOffsets.exists(_danceRight) && animOffsets.exists(_danceLeft)) {
			danced = !danced;
			playAnim(danced ? _danceRight : _danceLeft, true);
		}
		else if (animOffsets.exists(_idle)) {
			playAnim(_idle, !getAnimData(_idle).loop);
		}
	}

	override function destroy() {
		super.destroy();
		worldOffsets = FlxDestroyUtil.put(worldOffsets);
		stageOffsets = FlxDestroyUtil.put(stageOffsets);
		stageCamOffsets = FlxDestroyUtil.put(stageCamOffsets);
		camOffsets = FlxDestroyUtil.put(camOffsets);
		ModdingUtil.removeScript(script);

		if (heyTimer != null)
			heyTimer = FlxDestroyUtil.destroy(heyTimer);
	}
}