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

	public function setupChar(char:String):Void {
		visible = false;
		if (char.length > 0) {
			visible = true;
			if (lastChar != char) {
				lastChar = char;
				var charJson:MenuCharJson = JsonUtil.getJson(char, charsFolder, "images");
				charJson = JsonUtil.checkJsonDefaults(DEFAULT_MENU_CHAR, charJson);
				lerpColor = charJson.lerpColor;
				if (!lerpColor) color = FlxColor.WHITE;
				
				loadJsonInput(charJson, charsFolder, true);
				playAnim('idle');	
			}
		}
	}
}