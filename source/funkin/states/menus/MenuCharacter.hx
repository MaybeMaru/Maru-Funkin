package funkin.states.menus;

typedef MenuCharJson = {
	var lerpColor:Bool;
} & SpriteJson;

class MenuCharacter extends FlxSpriteExt {
	public function new(x:Float, y:Float, startChar:String = 'bf') {
		super(x,y);
		setupChar(startChar);
	}
	
	public static var DEFAULT_MENU_CHAR(default, never):MenuCharJson = {
		antialiasing: true,
		scale: 0.9,
		imagePath: "bf",
		anims: [
			FlxSpriteExt.DEFAULT_ANIM
		],
		flipX: false,
		lerpColor: true
	}

	static inline var charsFolder = "storymenu/characters";

	public var lastChar:String = '';
	public var lerpColor:Bool = true;

	public static var cachedChars:Map<String, MenuCharJson> = [];

	public function setupChar(char:String):Void {
		alpha = 0; // doesnt use draw() i think?
		active = false;
		if (char.length > 0) {
			alpha = 1;
			active = true;
			if (lastChar != char) {
				lastChar = char;
				var charJson:MenuCharJson = cachedChars.get(char);
				if (charJson == null) {
					final _json = JsonUtil.getJson(char, charsFolder, "images");
					charJson = JsonUtil.checkJsonDefaults(DEFAULT_MENU_CHAR, _json);
					cachedChars.set(char, charJson);
				}

				lerpColor = charJson.lerpColor;
				if (!lerpColor) color = FlxColor.WHITE;
				
				final lastFrame:Int = animation?.curAnim?.curFrame ?? 0;
				loadJsonInput(JsonUtil.copyJson(charJson), charsFolder, true);
				playAnim('idle');
				if (animation.curAnim != null && lastFrame < animation.curAnim.frames.length) {
					animation.curAnim.curFrame = lastFrame;
				}
			}
		}
	}
}