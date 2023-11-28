package funkin.objects;

class HealthIcon extends FlxSpriteExt {
	public var sprTracker:FlxObject;
	public var isPlayer:Bool = false;
	public var playIcon:Bool = false;
	public var isDying:Bool = false;
	public var singleAnim:Bool = false;
	public var staticSize:Float = 1;
	public var iconName:String = '';

	var _height:Float = 0;
	var _width:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false, playIcon:Bool = false):Void {
		super();
		this.isPlayer = isPlayer;
		this.playIcon = playIcon;
		makeIcon(char);
	}

	public function makeIcon(char:String = 'bf', forced:Bool = false):Void {
		if (iconName == char && !forced) return; // skip loading shit
		antialiasing = Preferences.getPref('antialiasing');
		iconName = char;
		if (["senpai", "spirit"].contains(char) || char.contains('-pixel')) antialiasing = false;

		var icon:FlxGraphicAsset = Paths.image('icons/face');
		if (Paths.exists(Paths.image('icons/$char', null, true), IMAGE))
			icon = Paths.image('icons/$char', null, false);

		loadImage('icons/$char');	//	Load it first to get the width and height
		if (_packer == IMAGE) {
			singleAnim = !(width >= height * 1.25); // Id make it 2 but theres some weird ass resolutions out there
			if (!singleAnim) {
				loadGraphic(icon, true, Math.floor(width * 0.5), cast height);
				animation.add('healthy', [0], 0, false);
				animation.add('dying', [1], 0, false);
				addOffset('healthy', 0,0);
				addOffset('dying', 0,0);
			}
		}
		else {
			singleAnim = false;
			addAnim('healthy', 'healthy', 24, true);
			addAnim('dying', 'dying', 24, true);
		}
		animCheck();
		flipX = isPlayer;
		scrollFactor.set();
		_height = height * 0.55;
		_width = width;
	}

	public function bumpIcon(bumpSize:Float = 1.2):Void {
		setScale(bumpSize);
		update(0);
	}

	public dynamic function animCheck():Void {
		if (!singleAnim) {
			final newAnim:String = isDying ? 'dying' : 'healthy';
			if (newAnim != (animation?.curAnim?.name ?? "")) {
				playAnim(newAnim);
				updateHitbox();
			}
		}
	}

	public function setSprTrackerPos():Void {
		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - (height * 0.5 - sprTracker.height * 0.5));
		}
	}

	override function update(elapsed:Float):Void {
		if (playIcon && PlayState.instance != null) {
			final healthBar = PlayState.instance.healthBar;
			var bumpLerp = 0.15;
			var coolOffset = 23 + width * 0.333;
			if (Preferences.getPref('vanilla-ui')) {
				bumpLerp = 0.75;
				coolOffset = isPlayer ? 26 : _width - 26 ;
			}

			if (isPlayer) {
				isDying = healthBar.percent < 20;
				setPosition(healthBar.barPoint.x - (_width * 0.25) + coolOffset, healthBar.barPoint.y - _height);
			}
			else {
				isDying = healthBar.percent > 80;
				setPosition(healthBar.barPoint.x - width + _width - coolOffset, healthBar.barPoint.y - _height);
			}

			animCheck();
			setScale(CoolUtil.coolLerp(scale.x, staticSize, bumpLerp));
		}
		else setSprTrackerPos();
		super.update(elapsed);
	}
}