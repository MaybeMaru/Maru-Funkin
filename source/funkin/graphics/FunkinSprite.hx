package funkin.graphics;

// Simple FlxSpriteExt wrapper class mainly for use in hscript
class FunkinSprite extends FlxSpriteExt
{
    public var jsonData:SpriteJson;
    public var tag:String = "";
    public var animated:Bool = true;
    public var danced:Bool = false;

    public function new(?image:FlxGraphicAsset, ?coords:Array<Float>, ?scrolls:Array<Float>, useJson:Bool = false):Void {
        super();

        if (coords == null) setPosition(0,0);
        else setPosition(coords[0], coords[1]);
        
        if (scrolls == null) scrollFactor.set(1,1);
        else scrollFactor.set(scrolls[0], scrolls[1]);

        if (image != null)
        {
            if (image is String)
            {
                final path:String = cast(image, String);
                if (path.length > 0)
                {
                    loadImage(path);
                    animated = packer != IMAGE;
            
                    if (useJson) {
                        var jsonPath:String = Paths.getPath('images/$path-data.json', TEXT, null);
                        if (Paths.exists(jsonPath, TEXT)) {
                            loadSpriteJson(jsonPath, "");
                            return;
                        }
                    }
                }
            }
            else
            {
                loadGraphic(image);
            }
        }

        antialiasing = SkinUtil.curSkinData.antialiasing ? FlxSprite.defaultAntialiasing : false;
    }
    
    public function dance(forced:Bool = false):Void {
        danced = !danced;
        if (animated) {
            if (animOffsets.exists('danceRight') && animOffsets.exists('danceLeft')) {
                playAnim(danced ? 'danceRight' : 'danceLeft', forced);
            }
            else if (animOffsets.exists('idle')) {
                playAnim('idle', forced);
            }
        }
	}
}