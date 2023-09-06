package funkin.graphics;

class FunkinSprite extends FlxSpriteExt {
    public var jsonData:SpriteJson;
    public var animated:Bool = true;
    public var danced:Bool = false;

    public function new(path:String = "", ?coords:Array<Float>, ?scrolls:Array<Float>, useJson:Bool = false):Void {
        super();
        coords = (coords != null) ? coords : [0,0];
        scrolls = (scrolls != null) ? scrolls : [1,1];
        setPosition(coords[0], coords[1]);
        scrollFactor.set(scrolls[0], scrolls[1]);

        if (path.length <= 0) return;

        loadImage(path);
        animated = _packer != IMAGE;

        var jsonPath:String = Paths.getPath('images/$path-data.json', TEXT, null);
        if (useJson && Paths.exists(jsonPath, TEXT)) {
            loadSpriteJson(jsonPath, '');
        } else {
            antialiasing = SkinUtil.curSkinData.antialiasing ? Preferences.getPref('antialiasing') : false;
        }
    }
    
    public function dance():Void {
        danced = !danced;
        if (animated) {
            if (animOffsets.exists('danceRight') && animOffsets.exists('danceLeft')) {
                playAnim(danced ? 'danceRight' : 'danceLeft');
            }
            else if (animOffsets.exists('idle')) {
                playAnim('idle');
            }
        }
	}
}