package funkin.util.modding;

class ScriptUtil {
    public static var objMap:Map<String, Dynamic> = [];
    
    inline public static function addSprite(sprite:Dynamic, key:String, onTop:Bool = false) {
        objMap.set(formatSpriteKey(key, onTop), sprite);
        getLayer(onTop).add(sprite);
    }

    inline static function getLayer(onTop:Bool):FlxTypedGroup<Dynamic> {
        return PlayState.instance != null ? (onTop ? PlayState.instance.fgSpr : PlayState.instance.bgSpr) : FlxG.state;
    }
    
    public static function getSprite(key:String) {
        for (i in ['fg', 'bg']) {
            var sprKey = '_${i}_sprite_$key';
            if (objMap.exists(sprKey))
                return objMap.get(sprKey);
        }
        ModdingUtil.errorPrint('Sprite not found: $key');
        return null;	
    }

    inline public static function formatSpriteKey(key:String, OnTop:Bool) {
        return getSpriteKey(OnTop ? 'fg' : 'bg', key);
    }

    inline public static function getSpriteKey(group:String, key:String) {
        return '_${group}_sprite_$key';
    }

    inline public static function getGroup(key:String) {
        return key == 'fg' ? PlayState.instance.fgSpr : PlayState.instance.bgSpr;
    }
    
    inline public static function switchCustomState(key:String) {
		final scriptCode = CoolUtil.getFileContent(Paths.script('scripts/customStates/$key'));
		if (scriptCode.length <= 0) {
			ModdingUtil.errorPrint('Custom state script not found: $key');
			return;
		}

		final state = new CustomState().initScript(scriptCode, key);
		CoolUtil.switchState(state);
	}
}