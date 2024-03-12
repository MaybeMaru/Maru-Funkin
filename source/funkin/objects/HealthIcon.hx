package funkin.objects;

class HealthIcon extends FlxSpriteExt {
	public var sprTracker:FlxObject;
	public var isPlayer:Bool = false;
	public var playIcon:Bool = false;
	public var isDying:Bool = false;
	public var singleAnim:Bool = false;
	public var staticSize:Float = 1;
	public var iconName:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, playIcon:Bool = false):Void {
		super();
		this.isPlayer = isPlayer;
		this.playIcon = playIcon;
		makeIcon(char);
	}

	static final PIXEL_ICONS:Array<String> = ["senpai", "spirit"];

	public function makeIcon(char:String = 'bf', forced:Bool = false):Void {
		if (iconName == char && !forced) return; // skip loading shit
		iconName = char;

		if (PIXEL_ICONS.contains(char) || char.contains('-pixel')) antialiasing = false;
		else antialiasing = Preferences.getPref('antialiasing');

		var icon = "face";
		if (Paths.exists(Paths.png('icons/$char', null), IMAGE)) // Check if icon exists
			icon = char;

		loadImage('icons/$icon'); // Load first to get the resolution
		
		if (packer == IMAGE) {
			singleAnim = !(width >= height * 1.25); // Id make it 2 but theres some weird ass resolutions out there
			if (!singleAnim) {
				loadGraphic(graphic, true, Math.floor(width * lodDiv * 0.5), Std.int(height * lodDiv));
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
		
		initBumpVars();
	}

	var _height:Float = 0;
	var _width:Float = 0;
	var _lodOffset:Float = 0;
	var bumpLerp:Float = 0.0;
	var coolOffset:Float = 0.0;

	function initBumpVars() {
		_height = height * __getScale() * 0.55;
		_width = width * __getScale();

		// This is probably some primary school type formula
		// ..but im too tired to fuck around and find out
		_lodOffset = singleAnim ? 0.0 : switch (Std.int(lodScale)) {
			case 2: 0.5;
			case 4: 0.75;
			case 8: 1.0;
			default: 0.0;
		}

		if (Preferences.getPref('vanilla-ui')) {
			bumpLerp = 0.75;
			coolOffset = isPlayer ? 26 : _width - 26 ;
		}
		else {
			bumpLerp = 0.15;
			coolOffset = 23 + _width * 0.333;
		}
	}

	public function bumpIcon(bumpSize:Float = 1.2):Void {
		setScale(bumpSize);
		update(0);
	}

	public dynamic function animCheck():Void {
		if (!singleAnim) {
			var newAnim:String = isDying ? 'dying' : 'healthy';
			if (newAnim != (animation.curAnim?.name ?? "")) {
				playAnim(newAnim);
				updateHitbox();
			}
		}
	}

	inline function __getScale()
		return singleAnim ? 1.0 : lodScale;

	public function setSprTrackerPos():Void {
		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - (height * __getScale() * 0.5 - sprTracker.height * 0.5));
		}
	}

	override function update(elapsed:Float):Void {
		var play = PlayState.instance;
		if (playIcon && play != null)
		{
			var healthBar = play.healthBar;
			
			if (isPlayer) {
				isDying = healthBar.flipped ? healthBar.percent > 80 : healthBar.percent < 20;
				setPosition(healthBar.barPoint.x - (_width * 0.25) + (_width * _lodOffset) + coolOffset, healthBar.barPoint.y - _height);
			}
			else {
				isDying = healthBar.flipped ? healthBar.percent < 20 : healthBar.percent > 80;
				setPosition(healthBar.barPoint.x - (width * __getScale()) + _width - coolOffset, healthBar.barPoint.y - _height);
			}

			animCheck();
			setScale(CoolUtil.coolLerp(scale.x, staticSize, bumpLerp));
		}
		else {
			setSprTrackerPos();
		}
		
		super.update(elapsed);
	}
}