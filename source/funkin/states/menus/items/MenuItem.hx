package funkin.states.menus.items;

class MenuItem extends SpriteGroup
{
	public var lockSpr:FunkinSprite;
	public var weekSpr:FlxSprite;

	public var locked:Bool = false;
	public var targetY:Float = 0;

	public function new(targetY:Int = 0, weekName:String = 'week1', locked:Bool = false):Void {
		super();
		
		var png = Paths.png('storymenu/weeks/$weekName');
		
		weekSpr = Paths.exists(png, IMAGE) ?
		new FlxSpriteExt().loadImage('storymenu/weeks/$weekName') :
		new FlxText(0, 0, 0, weekName).setFormat(Paths.font("phantommuff"), 80);
		add(weekSpr);

		if (weekSpr.height > 100)
			weekSpr.offset.y += (weekSpr.height - 100) * 0.5;

		screenCenter(X);
		this.targetY = targetY;
		y = (targetY * 120) + 480;

		lockSpr = new FunkinSprite('storymenu/weekLock');
		lockSpr.x -= lockSpr.width + 10;
		lockSpr.y = weekSpr.height * 0.5 - lockSpr.height * 0.5;
		add(lockSpr);

		this.locked = locked;
		lockSpr.visible = locked;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol

	// I indeed enjoyed reading this, thanks for your amazing words mr Muffin
	
	var flashingInt:Int = 0;
	var fakeFramerate:Int = 0;
	var isFlashing:Bool = false;
	var isShaking:Bool = false;

	public function startFlashing():Void {
		isFlashing = !locked;
		isShaking = locked;
		if (locked) {
			new FlxTimer().start(0.3, function(tmr:FlxTimer) {
				isShaking = false;
				weekSpr.offset.x = 0;
				weekSpr.color = FlxColor.WHITE;
			});
		}
	}

	public var lockShake:Float = 0;

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		y = CoolUtil.coolLerp(y, (targetY * 120) + 480, 0.17);
		weekSpr.alpha = (targetY == 0 && !locked) ? 1 : 0.6;

		if (lockShake != 0) {
			lockSpr.offset.set(
				FlxG.random.float(-1, 1) * lockShake,
				FlxG.random.float(-1, 1) * lockShake
			);
		}

		if (isShaking || isFlashing) {
			flashingInt++;
			fakeFramerate = Std.int(Math.max(Math.round((1 / Math.max(elapsed, 0.001)) * 0.1), 1)); // prevent mod by 0 error???

			if (isShaking) {
				weekSpr.color = (flashingInt % fakeFramerate >= Math.floor(fakeFramerate * 0.5)) ? FlxColor.RED : FlxColor.WHITE;
				weekSpr.offset.x = FlxG.random.int(-10,10);
				weekSpr.alpha = (weekSpr.color == FlxColor.RED) ? 1 : 0.6;
			}
	
			if (isFlashing) {
				weekSpr.color = (flashingInt % fakeFramerate >= Math.floor(fakeFramerate * 0.5)) ? 0xFF33ffff : FlxColor.WHITE;
			}
		}
	}
}