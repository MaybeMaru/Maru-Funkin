package funkin.util.modding;

import openfl.display.BlendMode;
import flixel.tweens.FlxEase;

class ScriptUtil
{
    // Just some shortcuts, lol

    public static var stage(get, never):Stage;
    inline static function get_stage():Stage
        return PlayState.instance.stage;

    public static var objects(get, never):Map<String, FlxObject>;
    inline static function get_objects():Map<String, FlxObject>
        return stage.objects;

    // Ok now the actual stage script util crap

    public static function addObject<T:FlxObject>(object:T, ?tag:String, layerKey:LayerKey = "bg"):T
    {
        var layer = getLayer(layerKey);
        if (layer != null)
            stage.addToLayer(layer, tag, object);
        
        return object;
    }

    public static function insertObject<T:FlxObject>(?position:Int, object:T, ?tag:String, layerKey:LayerKey = "bg"):T
    {
        var layer = getLayer(layerKey);
        if (layer != null)
            stage.insertToLayer(layer, tag, object);
        
        return object;
    }

    public static function getObject(tag:String):Null<FlxObject>
    {
        var object = stage.objects.get(tag);
        if (object == null)
            ModdingUtil.errorPrint('Object not found: $tag');

        return object;
    }

    public static function existsObject(tag:String):Bool
    {
        return stage.objects.exists(tag);
    }

    public static function addLayer(layer:Layer, layerKey:String):Layer
    {
        stage.addLayer(layer, layerKey);
        return layer;
    }

    public static function getLayer(layerKey:LayerKey):Null<Layer>
    {
        var layer = stage.getLayer(layerKey);
        if (layer == null)
            ModdingUtil.errorPrint('Layer not found: $layerKey');

        return layer;
    }

    public static function existsLayer(layerKey:LayerKey):Bool
    {
        return stage.existsLayer(layerKey);
    }
    
    //inline public static function getSpriteKey(group:String, key:String) {
    //    return '_${group}_sprite_$key';
    //}

    //inline public static function getGroupKey(key:String) {
    //    return '_group_$key';
    //}

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

    public static function stringToEase(ease:String):Float->Float {
        return switch (ease.toLowerCase().trim()) {
            case "quadin": FlxEase.quadIn;                      case "quadout": FlxEase.quadOut;
            case "quadinout": FlxEase.quadInOut;                case "cubein": FlxEase.cubeIn;
            case "cubeout": FlxEase.cubeOut;                    case "cubeinout": FlxEase.cubeInOut;
            case "quartin": FlxEase.quartIn;                    case "quartout": FlxEase.quartOut;
            case "quartinout": FlxEase.quartInOut;              case "quintin": FlxEase.quintIn;
            case "quintout": FlxEase.quintOut;                  case "quintinout": FlxEase.quintInOut;
            case "smoothstepin": FlxEase.smoothStepIn;          case "smoothstepout": FlxEase.smoothStepOut;
            case "smoothstepinout": FlxEase.smoothStepInOut;    case "smootherstepin": FlxEase.smootherStepIn;
            case "smootherstepout": FlxEase.smootherStepOut;    case "smootherstepinout": FlxEase.smootherStepInOut;
            case "sinein": FlxEase.sineIn;                      case "sineout": FlxEase.sineOut;
            case "sineinout": FlxEase.sineInOut;                case "bouncein": FlxEase.bounceIn;
            case "bounceout": FlxEase.bounceOut;                case "bounceinout": FlxEase.bounceInOut;
            case "circin": FlxEase.circIn;                      case "circout": FlxEase.circOut;
            case "circinout": FlxEase.circInOut;                case "expoin": FlxEase.expoIn;
            case "expoout": FlxEase.expoOut;                    case "expoinout": FlxEase.expoInOut;
            case "backin": FlxEase.backIn;                      case "backout": FlxEase.backOut;
            case "backinout": FlxEase.backInOut;                case "elasticin": FlxEase.elasticIn;
            case "elasticout": FlxEase.elasticOut;              case "elasticinout": FlxEase.elasticInOut;
            default: FlxEase.linear;
        }
    }

    public static function stringToBlend(blend:String):BlendMode {
        return switch(blend.toLowerCase().trim()) {
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