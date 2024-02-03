package funkin.util.modding;

import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;

typedef SpriteLayer = OneOfThree<FlxTypedGroup<Dynamic>, String, Bool>;
// TODO make layering less hardcoded, allow for multiple layers instead of only "bg" and "fg"

class ScriptUtil {
    public static var objMap:Map<String, Dynamic> = [];
    
    inline public static function addSprite(sprite:Dynamic, ?key:String, layer:SpriteLayer = "bg") {
        objMap.set(formatSpriteKey(key, layer), sprite);
        getLayer(layer).add(sprite);
        return sprite;
    }

    inline public static function insertSprite(sprite:Dynamic, ?key:String, position:Int = 0, layer:SpriteLayer = "bg") {
        objMap.set(formatSpriteKey(key, layer), sprite);
        getLayer(layer).insert(position, sprite);
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
    
    public static function getSprite(key:String):Dynamic {
        for (i in ['fg', 'bg']) {
            final sprKey = getSpriteKey(i, key);
            if (objMap.exists(sprKey))
                return objMap.get(sprKey);
        }
        ModdingUtil.errorPrint('Sprite not found: $key');
        return null;
    }

    public static function existsSprite(key:String):Bool {
        for (i in ['fg', 'bg']) {
            if (objMap.exists(getSpriteKey(i, key)))
                return true;
        }
        return false;	
    }

    public static function getSpriteLayer(key:String):String {
        for (i in ['fg', 'bg']) {
            final sprKey = getSpriteKey(i, key);
            if (objMap.exists(sprKey))
                return i;
        }
        ModdingUtil.errorPrint('Sprite not found: $key');
        return null;
    }

    inline public static function formatSpriteKey(?key:String, layer:SpriteLayer) {
        var layerKey = getLayerKey(layer);
        
        if (key == null)
            key = layerKey + getLayer(layer).length;

        return getSpriteKey(layerKey, key);
    }

    inline public static function getSpriteKey(group:String, key:String) {
        return '_${group}_sprite_$key';
    }

    inline public static function existsGroup(key:String) {
        return objMap.exists(getGroupKey(key));
    }

    inline public static function getGroup(key:String) {
        switch(key) {
            case "bg": return PlayState.instance.bgSpr;
            case "fg": return PlayState.instance.fgSpr;
            default:
            if (existsGroup(key))
                return objMap.get(getGroupKey(key));
            else {
                ModdingUtil.errorPrint('Group not found: $key');
                return null;	
            }
        }
    }

    inline public static function getGroupKey(key:String) {
        return '_group_$key';
    }

    public static var stateQueue:{state:MusicBeatState, skipTransOpen:Bool, skipTransClose:Bool} = null;
    
    inline public static function switchCustomState(key:String, skipTransOpen:Bool = false, ?skipTransClose:Bool) {
		final scriptCode = CoolUtil.getFileContent(Paths.script('scripts/customStates/$key'));
		if (scriptCode.length <= 0) {
			ModdingUtil.errorPrint('Custom state script not found: $key');
			return;
		}

        stateQueue = {
            state: new CustomState().initScript(scriptCode, key),
            skipTransOpen: skipTransOpen,
            skipTransClose: skipTransClose ?? skipTransOpen
        }
	}

    public inline static function stringToBlend(value:String):openfl.display.BlendMode {
        return switch(value.toLowerCase().trim()) {
            case 'add':     ADD;        case 'alpha': 		ALPHA;
            case 'darken':  DARKEN;     case 'difference': 	DIFFERENCE;
            case 'erase':   ERASE;      case 'hardlight': 	HARDLIGHT;
            case 'invert':  INVERT;     case 'layer': 		LAYER;
            case 'lighten': LIGHTEN;    case 'multiply': 	MULTIPLY;
            case 'overlay': OVERLAY;    case 'screen': 		SCREEN;
            case 'shader':  SHADER; 	case 'subtract': 	SUBTRACT;
            default:        NORMAL;
        }
    }
}

/*
typedef LayerKey = OneOfTwo<Bool, String>;
typedef Layer = FlxTypedGroup<Dynamic>;

class StageSystem
{
    public var layers:Map<String, Layer> = [
        "bg" => new Layer(),
        "fg" => new Layer()
    ];

    public var layersOrder:Array<String> = ["bg", "fg"];

    public function getLayers():Array<Layer> {
        var array:Array<Layer> = [];

        for (layer in layersOrder) {
            var layer = getLayer(layer);
            if (layer != null)
                array.push(layer);
        }

        return array;
    }

    public function getLayer(key:LayerKey):Layer {
        return layers.get(__resolveLayerKey(key));
    }

    public function addLayer(layer:Layer, key:String) {
        layers.set(key, layer);
        layersOrder.push(key);
    }
    
    function __resolveLayerKey(key:LayerKey):String {
        return key is Bool ? (key ? "fg" : "bg") : key;
    }
}*/