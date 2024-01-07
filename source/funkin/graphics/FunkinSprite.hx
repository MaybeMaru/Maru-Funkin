package funkin.graphics;

class FunkinSprite extends FlxSpriteExt {
    public var jsonData:SpriteJson;
    public var tag:String = "";
    public var animated:Bool = true;
    public var danced:Bool = false;

    public function new(?image:FlxGraphicAsset, ?coords:Array<Float>, ?scrolls:Array<Float>, useJson:Bool = false):Void {
        super();
        coords = coords ?? [0,0];
        scrolls = scrolls ?? [1,1];
        x = coords[0]; y = coords[1];
        scrollFactor.set(scrolls[0], scrolls[1]);

        coords = null;
        scrolls = null;

        if (image != null) {
            if (image is String) {
                final path:String = cast(image, String);
                if (path.length > 0) {
                    loadImage(path);
                    animated = packer != IMAGE;
            
                    final jsonPath:String = Paths.getPath('images/$path-data.json', TEXT, null);
                    if (useJson && Paths.exists(jsonPath, TEXT)) loadSpriteJson(jsonPath, '');
                    else {
                        antialiasing = SkinUtil.curSkinData.antialiasing ? Preferences.getPref('antialiasing') : false;
                    }
                }
            }
            else {
                loadGraphic(image);
                antialiasing = SkinUtil.curSkinData.antialiasing ? Preferences.getPref('antialiasing') : false;
            }
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