package funkin.util.modding;

import flixel.util.typeLimit.OneOfThree;

typedef SpriteLayer = OneOfThree<FlxTypedGroup<Dynamic>, String, Bool>;
// TODO make layering less hardcoded, allow for multiple layers instead of only "bg" and "fg"

class ScriptUtil {
    public static var objMap:Map<String, Dynamic> = [];
    
    inline public static function addSprite(sprite:Dynamic, key:String, layer:SpriteLayer = "bg") {
        objMap.set(formatSpriteKey(key, layer), sprite);
        getLayer(layer).add(sprite);
        return sprite;
    }

    inline static function getLayerKey(layer:SpriteLayer):String {
        if (layer is String) return layer;
        else if (layer is Bool) return layer ? "fg" : "bg";
        else return cast(layer, FlxTypedGroup<Dynamic>).ID == 1 ? "fg" : "bg";
    }

    inline static function getLayer(layer:SpriteLayer):FlxTypedGroup<Dynamic> {
        if (layer is Bool || layer is String) {
            final onTop = (layer is Bool ? layer : layer == "fg");
            return PlayState.instance != null ? (onTop ? PlayState.instance.fgSpr : PlayState.instance.bgSpr) : FlxG.state;
        }
        else return cast(layer, FlxTypedGroup<Dynamic>);
    }
    
    public static function getSprite(key:String) {
        for (i in ['fg', 'bg']) {
            final sprKey = '_${i}_sprite_$key';
            if (objMap.exists(sprKey))
                return objMap.get(sprKey);
        }
        ModdingUtil.errorPrint('Sprite not found: $key');
        return null;	
    }

    inline public static function formatSpriteKey(key:String, layer:SpriteLayer) {
        return getSpriteKey(getLayerKey(layer), key);
    }

    inline public static function getSpriteKey(group:String, key:String) {
        return '_${group}_sprite_$key';
    }

    inline public static function getGroup(key:String) {
        return key == 'fg' ? PlayState.instance.fgSpr : PlayState.instance.bgSpr;
    }

    public static var stateQueue:{state:MusicBeatState, skipTrans:Bool} = null;
    
    inline public static function switchCustomState(key:String, skipTrans:Bool) {
		final scriptCode = CoolUtil.getFileContent(Paths.script('scripts/customStates/$key'));
		if (scriptCode.length <= 0) {
			ModdingUtil.errorPrint('Custom state script not found: $key');
			return;
		}

        stateQueue = {
            state: new CustomState().initScript(scriptCode, key),
            skipTrans: skipTrans
        }
	}
}