package funkin.util.modding;

enum HscriptFunctionCallback {
	STOP_FUNCTION;
	CONTINUE_FUNCTION;
}

class FunkScript extends SScript {
	public var scriptID:String = '';

	public function callback(method:String, ?args:Array<Dynamic>):Dynamic {
		if (!exists(method)) {
			return CONTINUE_FUNCTION;
		}
		return callMethod(method, args == null ? [] : args);
	}

	public function callMethod(method:String, ?args:Array<Dynamic>):HscriptFunctionCallback {
		var call_ =  call(method, args);
		if (!call_.succeeded) {
			for (error in call_.exceptions) {
				if (error != null) ModdingUtil.errorTrace('$scriptID / ${error.toString()}');
			}
			return CONTINUE_FUNCTION;
		}
		var value = call_.returnValue;
		return value == null ? CONTINUE_FUNCTION : value;
	}

	public function new(hscriptCode:String):Void {
		super();
		implement();
		doString(hscriptCode);
	}

	public function implement():Void { //Preloaded Variables

		// Wip

		set('STOP_FUNCTION', STOP_FUNCTION);

		//Mau engin

        set('PlayState', PlayState.game);
		set('GameVars', PlayState); // fuck
		set('State', MusicBeatState.game);

		set('CoolUtil', CoolUtil);
		set('Conductor', Conductor);
		set('Paths', Paths);
		set('Preferences', Preferences);
		set('Controls', Controls);
		set('Shader', Shader);

		set('DialogueBox', funkin.graphics.dialogue.NormalDialogueBox);
		set('PixelDialogueBox', funkin.graphics.dialogue.PixelDialogueBox);
		set('FunkinSprite', FunkinSprite);
		set('FunkinText', FunkinText);
		set('Character', Character);
		set('Note', Note);

		set('Alphabet', Alphabet);
		set('TypedAlphabet', TypedAlphabet);
		set('MenuAlphabet', MenuAlphabet);

		//Haxe

		set('Std', Std);
		set('Math', Math);
		set('Type', Type);
		set('StringTools', StringTools);
		set('Reflect', Reflect);
		
		//Flixel

		set('FlxG', flixel.FlxG);
        set('FlxSpriteExt', funkin.graphics.FlxSpriteExt);	//	The cooler FlxSprite
		set('FlxSprite', FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxTypedGroup', flixel.group.FlxGroup.FlxTypedGroup);
		set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
		set('FlxGroup', flixel.group.FlxGroup);
		set('FlxSound', flixel.sound.FlxSound);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxColor', FlxColorFix); //	xd
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);

		//HScript Functions

		set('importLib', function(classStr:String, packageStr:String = '', ?customName:String):Void {
			if(packageStr != '') packageStr += '.';
			if (customName != null && !exists(customName)) {
				set(customName, Type.resolveClass(packageStr + classStr));
				return;
			}
			set(classStr, Type.resolveClass(packageStr + classStr));
		});

		set('getBlendMode', function(blendType:String):openfl.display.BlendMode {
			switch(blendType.toLowerCase().trim()) {
				case 'add': 		return ADD; 	case 'alpha': 		return ALPHA;
				case 'darken': 		return DARKEN; 	case 'difference': 	return DIFFERENCE;
				case 'erase': 		return ERASE; 	case 'hardlight': 	return HARDLIGHT;
				case 'invert': 		return INVERT; 	case 'layer': 		return LAYER;
				case 'lighten': 	return LIGHTEN; case 'multiply': 	return MULTIPLY;
				case 'overlay': 	return OVERLAY; case 'screen': 		return SCREEN;
				case 'shader': 		return SHADER; 	case 'subtract': 	return SUBTRACT;
				default:			return NORMAL;
			}
		});

		set('getPref', function(pref:String):Dynamic {
			return Preferences.getPref(pref);
		});

		set('getKey', function(key:String):Bool {
			return Controls.getKey(key);
		});

		set('trace', function(text:String, ?color:Int):Void {
			ModdingUtil.consoleTrace(text, color);
		});

		set('addSpr', function(spr:Dynamic, key:String = 'coolswag', OnTop:Bool = false):Void {
			var sprKey = '_${OnTop ? 'fg' : 'bg'}_sprite_$key';
			PlayState.game.objMap.set(sprKey, spr);
			OnTop ? PlayState.game.fgSpr.add(spr) : PlayState.game.bgSpr.add(spr);
		});
		
		set('insertSpr', function(order:Int = 0, spr:Dynamic, key:String = 'coolswag', OnTop:Bool = false) {
			var sprKey = '_${OnTop ? 'fg' : 'bg'}_sprite_$key';
			PlayState.game.objMap.set(sprKey, spr);
			OnTop ? PlayState.game.fgSpr.insert(order, spr) : PlayState.game.bgSpr.insert(order, spr);
		});

		set('getSpr', function(key:String):Null<Dynamic> {
			for (i in ['fg', 'bg']) {
				var sprKey = '_${i}_sprite_$key';
				if (PlayState.game.objMap.exists(sprKey))
					return PlayState.game.objMap.get(sprKey);
			}
			ModdingUtil.errorTrace('Sprite not found: $key');
			return null;								
		});

		set('getSprOrder', function(key:String):Int {
			for (i in ['fg', 'bg']) {
				var sprKey = '_${i}_sprite_$key';
				var group = (i == 'fg' ? PlayState.game.fgSpr : PlayState.game.bgSpr);
				if (PlayState.game.objMap.exists(sprKey))
					return group.members.indexOf(PlayState.game.objMap.get(sprKey));
			}
			ModdingUtil.errorTrace('Sprite not found: $key');
			return 0;
		});

		set('existsSpr', function(key:String):Null<Dynamic> {
			for (i in ['fg', 'bg']) {
				var sprKey = '_${i}_sprite_$key';
				if (PlayState.game.objMap.exists(sprKey)) {
					return true;
				}
			}
			return false;						
		});

		set('makeGroup', function(key:String, ?order:Int):Void {
			var newGroup:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
			order != null ? PlayState.game.insert(order, newGroup) : PlayState.game.add(newGroup);
			PlayState.game.objMap.set('_group_$key', newGroup);
		});

		set('getGroup', function(key:String):Null<FlxTypedGroup<Dynamic>> {
			if (PlayState.game.objMap.exists('_group_$key'))
				return PlayState.game.objMap.get('_group_$key');
			else {
				ModdingUtil.errorTrace('Group not found: $key');
				return null;
			}
		});

		set('existsGroup', function(key:String):Bool {
			return PlayState.game.objMap.exists('_group_$key');						
		});

		// Script functions

		set('addScript', function(path:String, ?tag:String):Void {
			ModdingUtil.addScript(path, false, tag);
		});

		set('getScriptVar', function(script:String, key:String):Dynamic {
			var script = ModdingUtil.scriptsMap.get(script);
			if (script.exists(key)) {
				return script.get(key);
			}
			return null;
		});

		set('callScriptFunction', function(script:String, func:String, ?args:Array<Dynamic>):Dynamic {
			return ModdingUtil.scriptsMap.get(script).callback(func, args);
		});

		set('addGlobalVar', function(key:String, _var:Dynamic, forced:Bool = false) {
			for (i in ModdingUtil.playStateScripts.concat(ModdingUtil.globalScripts)) {
				if (forced || !i.exists(key))
					i.set(key, _var);
			}
		});

		// Runtime shader functions

		set('initShader', function (shader:String, ?tag:String, forced:Bool = false):Void {
			Shader.initShader(shader, tag, forced);
		});

		set('setSpriteShader', function (sprite:FlxSprite, shader:String) {
			Shader.setSpriteShader(sprite, shader);
		});

		set('setCameraShader', function(camera:FlxCamera, shader:String) {
			Shader.setCameraShader(camera, shader);
		});

		set('setShaderSampler2D', function (shader:String, prop:String, path:String = "", ?bitmap:openfl.display.BitmapData) {
			Shader.setSampler2D(shader, prop, path, bitmap);
		});

		set('setShaderFloat', function (shader:String, prop:String, value:Float) {
			Shader.setFloat(shader, prop, value);
		});

		set('setShaderInt', function (shader:String, prop:String, value:Int) {
			Shader.setInt(shader, prop, value);
		});

		set('setShaderBool', function (shader:String, prop:String, value:Bool) {
			Shader.setBool(shader, prop, value);
		});

		set('switchCustomState', function (key:String) {
			switchCustomState(key);
		});
	}

	public static function switchCustomState(key:String) {
		var scriptCode = CoolUtil.getFileContent(Paths.script('scripts/customStates/$key'));
		if (scriptCode.length <= 0) {
			ModdingUtil.errorTrace('Custom state script not found: $key');
			return;
		}

		var state = new CustomState().initScript(scriptCode, key);
		FlxG.switchState(state);
	}
}

typedef SuperMethod = {
	var callback:HscriptFunctionCallback;
	var ?value:Dynamic;
}

class CustomState extends MusicBeatState {
	public var script:FunkScript;
	private var _scriptKey:String;

	var super_map:Map<String, SuperMethod> = [];
	var super_methods:Array<String> = ['create', 'update', 'stepHit', 'beatHit', 'sectionHit', 'destroy'];

	public function initScript(scriptCode:String, stateTag:String) {
		_scriptKey = stateTag;
		script = new FunkScript(scriptCode);
		script.scriptID = '_custom_state_$stateTag';
		script.set('Parent', this);
		script.set('add', function(object:Dynamic) add(object));
		script.set('insert', function(position:Int, object:Dynamic) insert(position, object));
		script.set('remove', function(object:Dynamic) remove(object));

		// This method sucks, but it works, sooooooo yeah... sorry
		for (i in super_methods) {
			script.set('super_' + i, function(?value:Dynamic) {
				super_map.set(i, {
					callback: CONTINUE_FUNCTION,
					value: value,
				});
			});
		}
		return this;
	}

	function superCallback(method:String, ?args:Dynamic) {
		super_map.set(method, {
			callback: STOP_FUNCTION,
			value: null,
		});
		script.callback(method, args);
		return super_map.get(method).callback == CONTINUE_FUNCTION;
	}

    override public function create() {
		ModdingUtil.consoleTrace('[ADD] $_scriptKey / Custom State', FlxColor.LIME);
		if (superCallback('create')) super.create();
    }
    
    override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.F4) FlxG.switchState(new StoryMenuState()); // emergency exit
		if (FlxG.keys.justPressed.F5) FunkScript.switchCustomState(_scriptKey);
		if (superCallback('update', [elapsed])) super.update(super_map.get('update').value);
    }

	override public function stepHit() 		if (superCallback('stepHit')) 		super.stepHit();
	override public function beatHit() 		if (superCallback('beatHit')) 		super.beatHit();
	override public function sectionHit() 	if (superCallback('sectionHit')) 	super.sectionHit();
	override public function destroy() 		if (superCallback('destroy')) 		super.destroy();
}