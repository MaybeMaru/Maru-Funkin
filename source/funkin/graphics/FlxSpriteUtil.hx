package funkin.graphics;

/*
    Just FlxSprite but with helper functions
*/
class FlxSpriteUtil extends FlxSprite {

	public static var DEFAULT_SPRITE:SpriteJson = {
		anims: [],
		imagePath: "keoiki",
		scale: 1,
		antialiasing: true,
		flipX: false,
	}

	public static var DEFAULT_ANIM:SpriteAnimation = {
		animName: 'idle',
		animFile: 'idle',
		offsets: [0,0],
		indices: [],
		framerate: 24,
		loop: false
	}

    public var flippedOffsets:Bool = false; 
    public var animOffsets:Map<String, FlxPoint>;
	public var animDatas:Map<String, SpriteAnimation>;
	public var specialAnim:Bool = false;
	public var _packer:PackerType = IMAGE;

    public function new(?X:Float = 0, ?Y:Float = 0):Void {
        animOffsets = new Map<String, FlxPoint>();
		animDatas = new Map<String, SpriteAnimation>();
        super(X,Y);
    }

	public function loadImageAnimated(path:String, _frameWidth:Int = 0, _frameHeight:Int = 0, global:Bool = false, gpu:Bool = true):FlxSpriteUtil {
		loadGraphic(Paths.image(path, null, !gpu, global), true, _frameWidth, _frameHeight);
		return this;
	}

	public function loadImage(path:String, global:Bool = false, gpu:Bool = true, ?library:String):FlxSpriteUtil {
		_packer = Paths.getPackerType(path);
		switch (_packer) {
			default:			loadGraphic(Paths.image(path, library, false, global, gpu));
			case SPARROW:		frames = Paths.getSparrowAtlas(path, library, gpu);
			case SHEETPACKER: 	frames = Paths.getPackerAtlas(path, library, gpu);
			case JSON:			frames = Paths.getAsepriteAtlas(path, library, gpu);
			//case ATLAS: 		frames = Paths.getAnimateAtlas(path);	
		}
		return this;
	}

	public function loadSpriteJson(path:String, folder:String = '', global:Bool = false) {
		var spriteJson:SpriteJson = JsonUtil.getJson(path, folder, 'images');
		loadJsonInput(spriteJson, folder, global);
	}

	public function loadJsonInput(?input:SpriteJson, folder:String = '', global:Bool = false, ?specialImage:String) {
		var spriteJson:SpriteJson = JsonUtil.checkJsonDefaults(DEFAULT_SPRITE, input);
		spriteJson = JsonUtil.checkJsonDefaults(DEFAULT_SPRITE, spriteJson);

		folder = folder.length > 0 ? '$folder/' : '';
		loadImage(specialImage != null ? specialImage : '$folder${spriteJson.imagePath}', global);

		for (anim in spriteJson.anims) {
			anim = JsonUtil.checkJsonDefaults(DEFAULT_ANIM, anim);
			addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
		}

		scale.set(spriteJson.scale,spriteJson.scale);
		updateHitbox();

		antialiasing = spriteJson.antialiasing;
		antialiasing = antialiasing ? Preferences.getPref('antialiasing') : false;
	}

    public override function draw():Void {
		if (flippedOffsets) {
			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;
		}
		else super.draw();
	}

    public override function getScreenBounds(?rect:FlxRect, ?cam:FlxCamera):FlxRect {
		if (flippedOffsets) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(rect, cam);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(rect, cam);
	}

    public function switchAnim(anim1:String, anim2:String):Void {
		if (animation.getByName(anim1) != null && animation.getByName(anim2) != null) {
			var oldAnim1 = animation.getByName(anim1).frames;
			var oldOffset1 = animOffsets[anim1];
	
			animation.getByName(anim1).frames = animation.getByName(anim2).frames;
			animOffsets[anim1] = animOffsets[anim2];
			animation.getByName(anim2).frames = oldAnim1;
			animOffsets[anim2] = oldOffset1;
		}
	}

    public function playAnim(animName:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		if(animOffsets.exists(animName)) {
			specialAnim = false;
			animation.play(animName, forced, reversed, frame);
			applyCurOffset(true);
		}
	}

	public function applyCurOffset(forced:Bool = false):Void {
		if (animation.curAnim != null) {
			if(animOffsets.exists(animation.curAnim.name)) {
				var daOffset:FlxPoint = animOffsets.get(animation.curAnim.name);
				if ((daOffset.x != 0 && daOffset.y != 0) || forced) {
					var OFFSET_XY:Array<Float> = [daOffset.x, daOffset.y];
					offset.set(flippedOffsets ? -OFFSET_XY[0] : OFFSET_XY[0], OFFSET_XY[1]);
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void {
		animOffsets[name] = new FlxPoint(x, y);
	}

	public function addAnim(animName:String, animFile:String, animFramerate:Int = 24, animLoop:Bool = false, ?animIndices:Array<Int>, ?animOffsets:Array<Float>):Void {
        animIndices = animIndices != null ? animIndices : [];
        animOffsets = animOffsets != null ? animOffsets : [0,0];
		
		setAnimData(animName, {
			animName:animName,
			animFile:animFile,
			framerate:animFramerate,
			loop:animLoop,
			indices:animIndices,
			offsets:animOffsets
		});
	}

	public function getAnimData(anim:String):SpriteAnimation {
		return animDatas.exists(anim) ? animDatas.get(anim) : Reflect.copy(DEFAULT_ANIM);
	}

	public function setAnimData(anim:String, newData:SpriteAnimation):Void {
		animDatas[anim] = newData;
		addOffset(anim, newData.offsets[0], newData.offsets[1]);

		var name = newData.animName;
		var file = newData.animFile;
		var indices = newData.indices;
		var fps = newData.framerate;
		var loop = newData.loop;

		indices.length > 0 ? animation.addByIndices(name, file, indices, "", fps, loop) : animation.addByPrefix(name, file, fps, loop);
	}
}