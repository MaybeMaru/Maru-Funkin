package funkin.graphics;

import flixel.math.FlxPoint;

class FunkinSprite extends FlxSpriteUtil {
    public var jsonData:SpriteJson;
    public var animated:Bool = true;
    public var danced:Bool = false;

    public function new(path:String, ?coords:Array<Float>, ?scrolls:Array<Float>, useJson:Bool = true):Void {
        super();

        animated = Paths.getPackerType(path) != IMAGE;
        loadImage(path);

        var jsonPath:String = Paths.getPath('images/$path-data.json', TEXT, null);
        if (Paths.exists(jsonPath, TEXT) && useJson) {
            jsonData = Json.parse(CoolUtil.getFileContent(jsonPath));
            if (animated) {
                for (anim in jsonData.anims) {
                    addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
                }
            }
            flipX = jsonData.flipX;
            scale.set(jsonData.scale,jsonData.scale);
            antialiasing = (jsonData.antialiasing) ? Preferences.getPref('antialiasing') : false;
        }
        else {
            antialiasing = (SkinUtil.curSkinData.antialiasing) ? Preferences.getPref('antialiasing') : false;
        }
        
        coords = (coords != null) ? coords : [0,0];
        scrolls = (scrolls != null) ? scrolls : [1,1];
        setPosition(coords[0], coords[1]);
        scrollFactor.set(scrolls[0], scrolls[1]);
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