package funkin.util.modding;

class ScriptUtil {
    public static function getSprite(key:String) {
        for (i in ['fg', 'bg']) {
            var sprKey = '_${i}_sprite_$key';
            if (PlayState.game.objMap.exists(sprKey))
                return PlayState.game.objMap.get(sprKey);
        }
        ModdingUtil.errorTrace('Sprite not found: $key');
        return null;	
    }

    inline public static function formatSpriteKey(key:String, OnTop:Bool) {
        return getSpriteKey(OnTop ? 'fg' : 'bg', key);
    }

    inline public static function getSpriteKey(group:String, key:String) {
        return '_${group}_sprite_$key';
    }

    inline public static function getGroup(key:String) {
        return key == 'fg' ? PlayState.game.fgSpr : PlayState.game.bgSpr;
    }

    inline public static function getCurStateInstance<T>():T {
        var instance = MusicBeatState.game;
        return cast instance;
    }

    inline public static function switchCustomState(key:String) {
		var scriptCode = CoolUtil.getFileContent(Paths.script('scripts/customStates/$key'));
		if (scriptCode.length <= 0) {
			ModdingUtil.errorTrace('Custom state script not found: $key');
			return;
		}

		var state = new CustomState().initScript(scriptCode, key);
		CoolUtil.switchState(state);
	}
}