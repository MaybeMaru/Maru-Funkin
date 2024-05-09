package funkin.states.menus.items;

typedef MenuCharJson = SpriteJson & {
	var lerpColor:Bool;
};

class MenuCharacter extends FlxSpriteExt
{
	public function new(x:Float, y:Float, startChar:String = 'bf') {
		super(x,y);
		setupChar(startChar);
	}
	
	public static final DEFAULT_MENU_CHAR:MenuCharJson = {
		antialiasing: true,
		scale: 0.9,
		imagePath: "bf",
		allowLod: true,
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
	
	static function cacheChar(char:String):MenuCharJson
	{
		var data:MenuCharJson = JsonUtil.checkJson(DEFAULT_MENU_CHAR, JsonUtil.getJson(char, charsFolder, "images"));
		cachedChars.set(char, data);
		return data;
	}

	public function setupChar(char:String):Void
	{
		visible = false;
		active = false;
		
		if (char.length > 0)
		{
			visible = true;
			active = true;
			
			if (lastChar != char)
			{
				lastChar = char;
				
				var charJson:MenuCharJson = cachedChars.get(char);
				if (charJson == null)
					charJson = cacheChar(char);

				lerpColor = charJson.lerpColor;
				if (!lerpColor)
					color = FlxColor.WHITE;
				
				var lastFrame:Int = animation.curAnim != null ? animation.curAnim.curFrame : 0;

				loadJsonInput(Reflect.copy(charJson), charsFolder, true);
				playAnim('idle');
				
				if (animation.curAnim != null) if (lastFrame < animation.curAnim.frames.length)
					animation.curAnim.curFrame = lastFrame;
			}
		}
	}
}