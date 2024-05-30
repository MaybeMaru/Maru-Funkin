package funkin.graphics;

import flixel.util.typeLimit.OneOfTwo;
import flixel.graphics.frames.FlxFrame;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.FlxBasic;

typedef SpriteAnimation = {
    var animName:String;
	var animFile:String;
	var offsets:Array<Float>;
	var indices:Array<Int>;
	var framerate:Int;
	var loop:Bool;
}

typedef SpriteJson = {
	var anims:Array<SpriteAnimation>;
	var imagePath:String;
	var allowLod:Bool;
	var scale:Float;
	var antialiasing:Bool;
	var flipX:Bool;
}

/*
    Just FlxSprite but with helper functions
*/
class FlxSpriteExt extends FlxSkewedSprite
{
	@:unreflective
	public static final DEFAULT_SPRITE:SpriteJson = {
		anims: [],
		imagePath: "keoiki",
		allowLod: true,
		scale: 1.0,
		antialiasing: true,
		flipX: false,
	}

	@:unreflective
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
	
	public var packer(default, null):PackerType = IMAGE;
	public var imageKey(default, null):String = "::null::";

	override function initVars():Void {
		super.initVars();
		animOffsets = new Map<String, FlxPoint>();
		animDatas = new Map<String, SpriteAnimation>();
	}

	inline public function setScale(_scale:Float = 1, updateBox:Bool = true):Void {
		scale.set(_scale,_scale);
		if (updateBox)
			updateHitbox();
	}

	public inline function loadFromSprite(sprite:FlxSpriteExt):FlxSpriteExt {
		frames = sprite.frames;
		animation.copyFrom(sprite.animation);
		antialiasing = sprite.antialiasing;
		scale.set(sprite.scale.x, sprite.scale.y);
		updateHitbox();
		
		animOffsets = sprite.animOffsets.copy();
		animDatas = sprite.animDatas.copy();
		return this;
	}

	public function loadImageTiled(path:String, frameWidth:Int = 0, frameHeight:Int = 0, globalAsset:Bool = false, ?useTexture:Bool, ?library:String, ?lodLevel:LodLevel):FlxSpriteExt {
		var image = Paths.image(path, library, globalAsset, useTexture, lodLevel);
		loadGraphic(image, true, Std.int(frameWidth / image.lodScale), Std.int(frameHeight / image.lodScale));
		return this;
	}

	public function loadImage(path:String, globalAsset:Bool = false, ?useTexture:Bool, ?library:String, lodLevel:LodLevel = DEFAULT):FlxSpriteExt {
		packer = Paths.getPackerType(path);
		imageKey = path;
		switch (packer) {
			default:			loadGraphic(Paths.image(path, library, globalAsset, useTexture, lodLevel));
			case SPARROW:		frames = Paths.getSparrowAtlas(path, library, useTexture, lodLevel);
			case SHEETPACKER: 	frames = Paths.getSpriteSheetAtlas(path, library, useTexture, lodLevel);
			case JSON:			frames = Paths.getAsepriteAtlas(path, library, useTexture, lodLevel);
			case ATLAS: 		//frames = Paths.getTextureAtlas(path);	
		}
		return this;
	}

	public var spriteJson:SpriteJson = null;

	public function loadSpriteJson(path:String, folder:String = '', global:Bool = false):FlxSpriteExt {
		spriteJson = JsonUtil.getJson(path, folder, 'images');
		loadJsonInput(spriteJson, folder, global);
		return this;
	}

	public function loadJsonInput(?input:SpriteJson, folder:String = '', global:Bool = false, ?specialImage:String):FlxSpriteExt
	{
		spriteJson = JsonUtil.checkJson(DEFAULT_SPRITE, input);

		folder = folder.length > 0 ? '$folder/' : '';
		
		var path:String = specialImage ?? folder + spriteJson.imagePath;
		var lod:Int = LodLevel.resolve(spriteJson.allowLod);

		loadImage(path, global, null, null, lod);

		spriteJson.anims.fastForEach((anim, i) -> {
			final anim = JsonUtil.checkJson(DEFAULT_ANIM, anim);
			addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
		});
		
		setScale(spriteJson.scale, true);
		antialiasing = spriteJson.antialiasing ? Preferences.getPref('antialiasing') : false;

		return this;
	}

	public override function update(elapsed:Float):Void {
		__superUpdate(elapsed);
	}

	public var _dynamic:Dynamic = {}; // Had to stop overriding flixel sooner or later

	@:noCompletion
	@:unreflective
	private inline function __superUpdate(elapsed:Float):Void {		
		if (moves)
			updateMotion(elapsed);
		
		if (packer != IMAGE)
			updateAnimation(elapsed);

		if (_dynamic.update != null)
			_dynamic.update(elapsed);

		#if FLX_DEBUG
		FlxBasic.activeCount++;
		#end
	}

    public override function draw():Void {
		if (flippedOffsets) {
			flipX = !flipX;
			scale.x = -scale.x;
			__superDraw();
			flipX = !flipX;
			scale.x = -scale.x;
		}
		else __superDraw();
	}

	override inline function checkEmptyFrame():Void {
		if (_frame == null)
			frames = Main.DEFAULT_GRAPHIC.imageFrame;
	}

	@:noCompletion
	@:unreflective
	private inline function __superDraw():Void {
		if (!visible) return;
		if (alpha == 0) return;
		
		checkEmptyFrame();
		if (_frame.type == EMPTY) return;

		__updateTrig();

		cameras.fastForEach((camera, i) -> {
			if (camera.visible) if (camera.exists) if (isOnScreen(camera)) {
				drawComplex(camera);
				#if FLX_DEBUG
				FlxBasic.visibleCount++;
				#end
			}
		});

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	@:noCompletion
	@:unreflective
	private inline function __updateTrig():Void {
		if (_angleChanged) {
			final rads:Float = angle * FunkMath.TO_RADS;
			_cosAngle = FunkMath.cos(rads);
			_sinAngle = FunkMath.sin(rads);

			_angleChanged = false;
			applyCurOffset(false); // Update display angle offset
		}
	}

	override function set_angle(value:Float):Float {
		if (angle != value) {
			if (FunkMath.isZero(value)) {
				_sinAngle = 0;
				_cosAngle = 1;
			}
			else {
				_angleChanged = true;
			}
		}
		return angle = value;
	}
	
	override function drawComplex(camera:FlxCamera):Void {
		__superDrawComplex(camera);
	}

	public var lodDiv(default, null):Float = 1.0;
	public var lodScale(default, set):Float = 1.0;
	inline function set_lodScale(value:Float) {
		lodDiv = 1 / value;
		return lodScale = value;
	}

	override function set_graphic(value:FlxGraphic):FlxGraphic
	{
		if (graphic != value) {
			lodScale = (value is LodGraphic) ? cast(value, LodGraphic).lodScale : 1.0;			
			graphic = value;
		}
		
		return value;
	}

	public function makeRect(width:Float, height:Float, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String, ?useTexture:Bool):FlxSpriteExt
	{
		makeGraphic(1, 1, color, unique, key);
		antialiasing = false;
		scale.set(width, height);
		updateHitbox();
		
		if (useTexture ?? AssetManager.gpuTextures)
			uploadGpu();
		
		return this;
	}

	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):FlxSprite
	{
		if (key == null)
			key = '::g::w$width::h$height::c$color::';
		
		if (unique) {
			var i:Int = 0;
			while (AssetManager.existsAsset(key + i))
				i++;

			key = key + i;
		}
		else {
			var asset = AssetManager.getAssetGraphic(key);
			if (asset != null) {
				imageKey = key;
				frames = asset.imageFrame;
				return this;
			}
		}

		var bitmap = new BitmapData(width, height, color.alpha != 255, color);
		imageKey = key;

		@:privateAccess
		var graphic = AssetManager.__cacheFromBitmap(key, bitmap, false, HIGH, false);
		frames = graphic.imageFrame;
		return this;
	}

	@:unreflective
	private inline function prepareFrameMatrix(frame:FlxFrame, mat:FlxMatrix):Void
	{
		var flipX = (flipX != frame.flipX);
		var flipY = (flipY != frame.flipY);
		
		if (animation.curAnim != null)
		{
			flipX = (flipX != animation.curAnim.flipX);
			flipY = (flipY != animation.curAnim.flipY);
		}
		
		@:privateAccess {
			final tileMat = frame.tileMatrix;
			mat.a = tileMat[0];
			mat.b = tileMat[1];
			mat.c = tileMat[2];
			mat.d = tileMat[3];
			mat.tx = tileMat[4];
			mat.ty = tileMat[5];
		}

		if (frame.angle == 180) {
			mat.rotateBy180();
			mat.tx = (mat.tx + frame.sourceSize.y);
			mat.ty = (mat.ty + frame.sourceSize.x);
		}

		if (lodScale != 1.0)
			FunkMath.scaleMatrix(mat, lodScale, lodScale);

		if (flipX != frame.flipX) {
			FunkMath.scaleMatrix(mat, -1, 1);
			mat.tx = (mat.tx + frame.sourceSize.x);
		}

		if (flipY != frame.flipY) {
			FunkMath.scaleMatrix(mat, 1, -1);
			mat.tx = (mat.tx + frame.sourceSize.y);
		}
	}

	@:noCompletion
	@:unreflective
	private inline function __superDrawComplex(camera:FlxCamera):Void {
		__prepareDraw(camera);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	@:noCompletion
	@:unreflective
	private inline function __prepareDraw(camera:FlxCamera):Void
	{	
		prepareFrameMatrix(_frame, _matrix);

		_matrix.tx = (_matrix.tx - origin.x);
		_matrix.ty = (_matrix.ty - origin.y);
		
		FunkMath.scaleMatrix(_matrix, scale.x, scale.y);

		if (!FunkMath.isZero(angle)) {
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		if (!skew.isZero()) {
			_skewMatrix.a = _skewMatrix.d = 1;
			_skewMatrix.tx = _skewMatrix.ty = 0;
			_skewMatrix.b = Math.tan(skew.y * FunkMath.TO_RADS);
			_skewMatrix.c = Math.tan(skew.x * FunkMath.TO_RADS);
			_matrix.concat(_skewMatrix);
		}

		final point = getScreenPosition(_point, camera);
		_matrix.tx = (_matrix.tx + point.x + origin.x - offset.x);
		_matrix.ty = (_matrix.ty + point.y + origin.y - offset.y);
	}

    public override function getScreenBounds(?rect:FlxRect, ?cam:FlxCamera):FlxRect {
		if (flippedOffsets) {
			scale.x = -scale.x;
			var bounds = __superGetScreenBounds(rect, cam);
			scale.x = -scale.x;
			return bounds;
		}
		return __superGetScreenBounds(rect, cam);
	}

	@:noCompletion
	@:unreflective
	private inline function __superGetScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		newRect ??= CoolUtil.rect;
		camera ??= FlxG.camera;
		
		_scaledOrigin.x = origin.x * scale.x;
		_scaledOrigin.y = origin.y * scale.y;

		newRect.set(
			x + (-Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x),
			y + (-Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y),
			frameWidth * Math.abs(scale.x * lodScale),
			frameHeight * Math.abs(scale.y * lodScale)
		);
		
		return FunkMath.fastRotatedTrigRect(newRect, _scaledOrigin, _cosAngle, _sinAngle);
	}

    public function switchAnim(anim1:String, anim2:String):Void {
		if (animation.getByName(anim1) != null) if (animation.getByName(anim2) != null) {
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

	@:noCompletion
	static final __scaleDiff:FlxPoint = FlxPoint.get();
	inline public function getScaleDiff():FlxPoint {
		var jsonScale:Float = spriteJson.scale;
		return __scaleDiff.set(scale.x / jsonScale, scale.y / jsonScale);
	}

	public var scaleOffset:Bool = false;

	public function applyCurOffset(forced:Bool = false):Void
	{
		if (animation.curAnim != null)
		{
			if(existsOffsets(animation.curAnim.name))
			{
				final animPoint = animOffsets.get(animation.curAnim.name);
				
				if (!animPoint.isZero() || forced)
				{
					var x:Float = animPoint.x;
					var y:Float = animPoint.y;

					// Flip X
					if (flippedOffsets)
						x = -x;
					
					if (scaleOffset) // Scale offset
					{
						var diff = getScaleDiff();
						x = x * diff.x;
						y = y * diff.y;
					}

					if (FunkMath.isZero(angle)) // Normal offset
					{
						offset.set(
							x,
							y
						);
					}
					else // Rotated offset
					{
						offset.set(
							(x * _cosAngle) + (y * -_sinAngle),
							(x * _sinAngle) + (y * _cosAngle)
						);
					}
				}
			}
		}
	}

	inline public function addOffset(name:String, x:Float = 0, y:Float = 0):Void {
		animOffsets[name] = FlxPoint.get(x, y);
	}

	public function addAnim(animName:String, animFile:String, animFramerate:Int = 24, animLoop:Bool = false, ?animIndices:Array<Int>, ?animOffsets:Array<Float>):Void {
		animIndices ??= [];
		animOffsets ??= [0, 0];
		
		setAnimData(animName, {
			animName: animName,
			animFile: animFile,
			framerate: animFramerate,
			loop: animLoop,
			indices: animIndices,
			offsets: animOffsets
		});
	}

	inline public function existsOffsets(anim:String):Bool {
		return animOffsets.exists(anim);
	}

	inline public function getAnimData(anim:String):SpriteAnimation {
		if (animDatas.exists(anim))
			return animDatas.get(anim);
		
		return JsonUtil.copyJson(DEFAULT_ANIM);
	}

	public function setAnimData(anim:String, newData:SpriteAnimation):Void {
		animDatas[anim] = newData;
		addOffset(anim, newData.offsets[0], newData.offsets[1]);

		final n:String = newData.animName;
		final f:String = newData.animFile;
		final i:Array<Int> = newData.indices;
		final fps:Float = newData.framerate;
		final l:Bool = newData.loop;

		i.length > 0 ? animation.addByIndices(n, f, i, "", fps, l) : animation.addByPrefix(n, f, fps, l);
	}

	inline public function setSkew(skewX:Float = 0, skewY:Float = 0):FlxPoint {
		return skew.set(skewX, skewY);
	}

	override function destroy():Void {
		super.destroy();
		animOffsets = null;
		animDatas = null;
	}

	inline public function stampBitmap(Brush:BitmapData, X:Float = 0, Y:Float = 0):Void {
		var matrix = CoolUtil.resetMatrix();
		matrix.tx = X;
		matrix.ty = Y;
		graphic.bitmap.draw(Brush, matrix);
	}

	inline public function uploadGpu():FlxGraphic {
		return #if TEXTURES_OFF graphic; #else AssetManager.uploadGraphicTexture(graphic); #end
	}
}