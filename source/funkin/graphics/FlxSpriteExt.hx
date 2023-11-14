package funkin.graphics;

import flixel.util.FlxDestroyUtil;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;

/*
    Just FlxSprite but with helper functions
*/
class FlxSpriteExt extends FlxSkewedSprite {

	public static final DEFAULT_SPRITE:SpriteJson = {
		anims: [],
		imagePath: "keoiki",
		scale: 1,
		antialiasing: true,
		flipX: false,
	}

	public static final DEFAULT_ANIM:SpriteAnimation = {
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

	inline public function setScale(_scale:Float = 1, updateBox:Bool = true) {
		scale.set(_scale,_scale);
		if (updateBox)
			updateHitbox();
	}

	public function loadFromSprite(sprite:FlxSpriteExt) {
		loadGraphicFromSprite(sprite);
		animOffsets = sprite.animOffsets.copy();
		animDatas = sprite.animDatas.copy();
		return this;
	}

	public function loadImageAnimated(path:String, _frameWidth:Int = 0, _frameHeight:Int = 0, global:Bool = false, gpu:Bool = true):FlxSpriteExt {
		loadGraphic(Paths.image(path, null, !gpu, global), true, _frameWidth, _frameHeight);
		return this;
	}

	public function loadImage(path:String, global:Bool = false, gpu:Bool = true, ?library:String):FlxSpriteExt {
		_packer = Paths.getPackerType(path);
		switch (_packer) {
			default:			loadGraphic(Paths.image(path, library, false, global, gpu));
			case SPARROW:		frames = Paths.getSparrowAtlas(path, library, gpu);
			case SHEETPACKER: 	frames = Paths.getPackerAtlas(path, library, gpu);
			case JSON:			frames = Paths.getAsepriteAtlas(path, library, gpu);
			case ATLAS: 		frames = Paths.getTextureAtlas(path);	
		}
		return this;
	}

	public var spriteJson:SpriteJson = null;

	public function loadSpriteJson(path:String, folder:String = '', global:Bool = false) {
		spriteJson = JsonUtil.getJson(path, folder, 'images');
		loadJsonInput(spriteJson, folder, global);
	}

	public function loadJsonInput(?input:SpriteJson, folder:String = '', global:Bool = false, ?specialImage:String) {
		spriteJson = JsonUtil.checkJsonDefaults(DEFAULT_SPRITE, input);

		folder = folder.length > 0 ? '$folder/' : '';
		loadImage(specialImage ?? '$folder${spriteJson.imagePath}', global);

		for (anim in spriteJson.anims) {
			anim = JsonUtil.checkJsonDefaults(DEFAULT_ANIM, anim);
			addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
		}
		
		setScale(spriteJson.scale, true);

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
			final bounds = super.getScreenBounds(rect, cam);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(rect, cam);
	}

    public function switchAnim(anim1:String, anim2:String):Void {
		if (animation.getByName(anim1) != null && animation.getByName(anim2) != null) {
			final oldAnim1 = animation.getByName(anim1).frames;
			final oldOffset1 = animOffsets[anim1];
	
			animation.getByName(anim1).frames = animation.getByName(anim2).frames;
			animOffsets[anim1] = animOffsets[anim2];
			animation.getByName(anim2).frames = oldAnim1;
			animOffsets[anim2] = oldOffset1;
		}
	}

    public function playAnim(animName:String, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		if(existsOffsets(animName)) {
			specialAnim = false;
			animation.play(animName, forced, reversed, frame);
			applyCurOffset(true);
		}
	}

	inline public function getScaleDiff() {
		return FlxPoint.get(scale.x / spriteJson.scale, scale.y / spriteJson.scale);
	}

	public function applyCurOffset(forced:Bool = false):Void {
		if (animation.curAnim != null) {
			if(existsOffsets(animation.curAnim.name)) {
				final animOffset:FlxPoint = new FlxPoint().copyFrom(animOffsets.get(animation.curAnim.name));
				if (!animOffset.isZero() || forced) {
					animOffset.x *= (flippedOffsets ? -1 : 1);
					offset.set(animOffset.x, animOffset.y);
				}
			}
		}
	}

	inline public function addOffset(name:String, x:Float = 0, y:Float = 0):Void {
		animOffsets[name] = FlxPoint.get(x, y);
	}

	public function addAnim(animName:String, animFile:String, animFramerate:Int = 24, animLoop:Bool = false, ?animIndices:Array<Int>, ?animOffsets:Array<Float>):Void {
		setAnimData(animName, {
			animName:animName,
			animFile:animFile,
			framerate:animFramerate,
			loop:animLoop,
			indices:animIndices ?? [],
			offsets:animOffsets ?? [0,0]
		});
	}

	inline public function existsOffsets(anim:String):Bool {
		return animOffsets.exists(anim);
	}

	inline public function getAnimData(anim:String):SpriteAnimation {
		return animDatas.get(anim) ?? JsonUtil.copyJson(DEFAULT_ANIM);
	}

	public function setAnimData(anim:String, newData:SpriteAnimation):Void {
		animDatas[anim] = newData;
		addOffset(anim, newData.offsets[0], newData.offsets[1]);

		final n = newData.animName;
		final f = newData.animFile;
		final i = newData.indices;
		final fps = newData.framerate;
		final l = newData.loop;

		i.length > 0 ? animation.addByIndices(n, f, i, "", fps, l) : animation.addByPrefix(n, f, fps, l);
	}

	inline public function setSkew(?skewX:Float, ?skewY:Float) {
		skew.set(skewX ?? skew.x, skewY ?? skew.y);
	}

	override function destroy() {
		super.destroy();
		animOffsets = null;
		animDatas = null;
	}

	public function stampBitmap(Brush:BitmapData, X:Float = 0, Y:Float = 0) {
		final matrix:FlxMatrix = new FlxMatrix();
		matrix.translate(X,Y);
		graphic.bitmap.draw(Brush, matrix);
	}
}