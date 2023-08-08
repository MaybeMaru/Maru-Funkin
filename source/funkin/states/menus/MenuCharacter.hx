package funkin.states.menus;

class MenuCharacter extends FlxSpriteExt {
	public function new(x:Float, y:Float, startChar:String = 'bf') {
		super(x,y);
		setupChar(startChar);
	}

	var lastChar:String = '';
	public function setupChar(char:String):Void {
		visible = false;
		if (char.length > 0) {
			if (Paths.exists(Paths.file('images/storymenu/characters/$char.json', TEXT), TEXT)) {
				visible = true;
				if (lastChar != char) {
					lastChar = char;
					loadSpriteJson(char, 'storymenu/characters', true);
					playAnim('idle');
				}
			}
		}
	}
}