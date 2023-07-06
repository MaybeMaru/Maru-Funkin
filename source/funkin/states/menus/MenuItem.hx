package funkin.states.menus;

class MenuItem extends FlxSpriteGroup {
	public var lockSpr:FunkinSprite;
	public var weekSpr:FunkinSprite;

	public var locked:Bool = false;
	public var targetY:Float = 0;

	public function new(targetY:Int = 0, weekName:String = 'week1'):Void {
		super();
		weekSpr = new FunkinSprite('storymenu/weeks/$weekName');
		weekSpr.loadGraphic(Paths.image('storymenu/weeks/$weekName', null, false, true));
		add(weekSpr);
		screenCenter(X);

		this.targetY = targetY;
		y = (targetY * 120) + 480;

		lockSpr = new FunkinSprite('storymenu/weekLock');
		lockSpr.x -= lockSpr.width + 10;
		lockSpr.y = weekSpr.height/2 - lockSpr.height/2;
		add(lockSpr);
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

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		y = CoolUtil.coolLerp(y, (targetY * 120) + 480, 0.17);
		weekSpr.alpha = (targetY == 0 && !locked) ? 1 : 0.6;
		lockSpr.visible = locked;

		if (isShaking || isFlashing) {
			flashingInt++;
			fakeFramerate = Math.round((1 / elapsed) / 10);

			if (isShaking) {
				weekSpr.color = (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2)) ? FlxColor.RED : FlxColor.WHITE;
				weekSpr.offset.x = FlxG.random.int(-10,10);
				weekSpr.alpha = (weekSpr.color == FlxColor.RED) ? 1 : 0.6;
			}
	
			if (isFlashing) {
				weekSpr.color = (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2)) ? 0xFF33ffff : FlxColor.WHITE;
			}
		}
	}
}