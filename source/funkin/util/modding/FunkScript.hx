package funkin.util.modding;
import openfl.display.BitmapData;
import hscript.Parser;
import hscript.Interp;

enum HscriptFunctionCallback {
	STOP_FUNCTION;
	CONTINUE_FUNCTION;
}

class FunkScript {
	public static var parser:Parser = new Parser();
	public var interp:Interp;
	public var variables(get, never):Map<String, Dynamic>;
	public var scriptID:String = '';

	public function get_variables() {
		return interp.variables;
	}

	public function callback(nameStr:String, ?args:Array<Dynamic>) {
		if (varExists(nameStr)) {
			callMethod(nameStr, args == null ? [] : args);
		}
	}

	public function callMethod(nameStr:String, ?args:Array<Dynamic>):HscriptFunctionCallback {
		var value = Reflect.callMethod(this, varGet(nameStr), args);
		return value == null ? CONTINUE_FUNCTION : value;
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

		// Wip

		addVar('STOP_FUNCTION', STOP_FUNCTION);

		//Funkin Bunny

        addVar('PlayState', PlayState.game);
		addVar('GameVars', PlayState); // fuck
		addVar('State', MusicBeatState.game);

		addVar('CoolUtil', CoolUtil);
		addVar('Conductor', Conductor);
		addVar('Paths', Paths);
		addVar('Preferences', Preferences);
		addVar('Controls', Controls);
		addVar('Shader', Shader);

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
			if (OnTop) {
				PlayState.game.fgSpr.add(spr);
				PlayState.game.fgSprMap.set(sprTag, spr);
			}
			else {
				PlayState.game.bgSpr.add(spr);
				PlayState.game.bgSprMap.set(sprTag, spr);
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

		// Runtime shader functions

		addVar('initShader', function (shader:String, ?tag:String, forced:Bool = false):Void {
			Shader.initShader(shader, tag, forced);
		});

		addVar('setSpriteShader', function (sprite:FlxSprite, shader:String) {
			Shader.setSpriteShader(sprite, shader);
		});

		addVar('setShaderSampler2D', function (shader:String, prop:String, path:String = "", ?bitmap:BitmapData) {
			Shader.setSampler2D(shader, prop, path, bitmap);
		});

		addVar('setShaderFloat', function (shader:String, prop:String, value:Float) {
			Shader.setFloat(shader, prop, value);
		});

		addVar('setShaderInt', function (shader:String, prop:String, value:Int) {
			Shader.setInt(shader, prop, value);
		});

		addVar('setShaderBool', function (shader:String, prop:String, value:Bool) {
			Shader.setBool(shader, prop, value);
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