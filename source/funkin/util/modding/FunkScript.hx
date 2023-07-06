package funkin.util.modding;
import hscript.Parser;
import hscript.Interp;

class FunkScript {
	public static var parser:Parser = new Parser();
	public var interp:Interp;
	public var variables(get, never):Map<String, Dynamic>;
	public var scriptID:String = '';

	public function get_variables() {
		return interp.variables;
	}

	public function callback(nameStr:String, ?arg:Dynamic) {
		if (varExists(nameStr)) {
			(arg != null) ? varGet(nameStr)(arg) : varGet(nameStr)();
		}
	}

	public function new(hscriptCode:String):Void {
		try {
			addScriptVars();
			execute(hscriptCode);
		}
		catch(e:Any)  {
			ModdingUtil.errorTrace('$scriptID / ${Std.string(e)}');
		}
	}

	public function addVar(varName:String, varValue:Dynamic):Void {
		interp.variables.set(varName, varValue);
	}

	public function addScriptVars():Void { //Preloaded Variables
		interp = new Interp();
		
		//Funkin Bunny

        addVar('PlayState', PlayState.game);
		addVar('GameVars', PlayState); // fuck
		addVar('State', MusicBeatState.game);

		addVar('CoolUtil', CoolUtil);
		addVar('Conductor', Conductor);
		addVar('Paths', Paths);
		addVar('Preferences', Preferences);
		addVar('Controls', Controls);

		addVar('WiggleEffect', shaders.WiggleEffect);
		addVar('DialogueBox', funkin.graphics.dialogue.NormalDialogueBox);
		addVar('PixelDialogueBox', funkin.graphics.dialogue.PixelDialogueBox);
		addVar('FunkinSprite', FunkinSprite);
		addVar('FunkinText', FunkinText);
		addVar('Character', Character);

		addVar('Alphabet', Alphabet);
		addVar('TypedAlphabet', TypedAlphabet);
		addVar('MenuAlphabet', MenuAlphabet);

		//Haxe

		addVar('Std', Std);
		addVar('Math', Math);
		addVar('Type', Type);
		addVar('StringTools', StringTools);
		
		//Flixel

		addVar('FlxG', flixel.FlxG);
        addVar('FlxSprite', FlxSpriteUtil);	//	The cooler FlxSprite
		addVar('FlxText', flixel.text.FlxText);
		addVar('FlxAnimate', flxanimate.FlxAnimate);
		addVar('FlxTypedGroup', flixel.group.FlxGroup.FlxTypedGroup);
		addVar('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
		addVar('FlxSound', flixel.sound.FlxSound);
		addVar('FlxMath', flixel.math.FlxMath);
		addVar('FlxColor', FlxColorFix); //	xd
		addVar('FlxTimer', flixel.util.FlxTimer);
		addVar('FlxTween', flixel.tweens.FlxTween);
		addVar('FlxEase', flixel.tweens.FlxEase);
		addVar('FlxTrail', flixel.addons.effects.FlxTrail);
		addVar('Reflect', Reflect);

		//HScript Functions

		addVar('importLib', function(classStr:String, packageStr:String = '', ?customName:String):Void {
			if(packageStr != '') packageStr += '.';

			if (customName != null && !varExists(customName)) {
				trace('imported hscript library $packageStr$classStr as $customName');
				addVar(customName, Type.resolveClass(packageStr + classStr));
				return;
			}

			trace('imported hscript library $packageStr$classStr');
			addVar(classStr, Type.resolveClass(packageStr + classStr));
		});

		addVar('getBlendMode', function(blendType:String):openfl.display.BlendMode {
			switch(blendType.toLowerCase().trim()) {
				case 'add': 		return ADD;
				case 'alpha': 		return ALPHA;
				case 'darken': 		return DARKEN;
				case 'difference': 	return DIFFERENCE;
				case 'erase': 		return ERASE;
				case 'hardlight': 	return HARDLIGHT;
				case 'invert': 		return INVERT;
				case 'layer': 		return LAYER;
				case 'lighten': 	return LIGHTEN;
				case 'multiply': 	return MULTIPLY;
				case 'overlay': 	return OVERLAY;
				case 'screen': 		return SCREEN;
				case 'shader': 		return SHADER;
				case 'subtract': 	return SUBTRACT;
				default:			return NORMAL;
			}
		});

		addVar('getWiggleEffectType', function(wiggleType:String):shaders.WiggleEffect.WiggleEffectType {
			switch(wiggleType.toLowerCase().trim()) {
				case 'dreamy': 					return DREAMY;
				case 'wavy': 					return WAVY;
				case 'heat_wave_horizontal': 	return HEAT_WAVE_HORIZONTAL;
				case 'heat_wave_vertical': 		return HEAT_WAVE_VERTICAL;
				case 'flag': 					return FLAG;
				default: 						return DREAMY;
			}
		});

		addVar('getPref', function(pref:String):Dynamic {
			return Preferences.getPref(pref);
		});

		addVar('getKey', function(key:String):Bool {
			return Controls.getKey(key);
		});

		addVar('trace', function(text:String, ?color:Int):Void {
			ModdingUtil.consoleTrace(text, color);
		});

		addVar('addSpr', function(spr:Dynamic, sprTag:String = 'coolswag', OnTop:Bool = false):Void {
			if (!OnTop) {
				PlayState.game.bgSpr.add(spr);
				PlayState.game.bgSprMap.set(sprTag, spr);
			}
			else {
				PlayState.game.fgSpr.add(spr);
				PlayState.game.fgSprMap.set(sprTag, spr);
			}
		});

		addVar('getSpr', function(key:String):Null<Dynamic> {
			if (PlayState.game.bgSprMap.get(key) != null)		return PlayState.game.bgSprMap.get(key);
			else if (PlayState.game.fgSprMap.get(key) != null)	return PlayState.game.fgSprMap.get(key);
			else {
				ModdingUtil.errorTrace('Sprite not found: $key');
				return null;
			}												
		});
	}

	public function execute(codeToRun:String):Dynamic {
		@:privateAccess
		parser.line = 1;
		parser.allowTypes = true;
		return interp.execute(parser.parseString(codeToRun));
	}

	public function varGet(field:String):Dynamic {
		return interp.variables.get(field);
	}

	public function varExists(field:String):Bool {
		return interp.variables.exists(field);
	}
}