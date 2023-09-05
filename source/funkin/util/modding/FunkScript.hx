package funkin.util.modding;

import hscript.Script;

enum HscriptFunctionCallback {
	STOP_FUNCTION;
	CONTINUE_FUNCTION;
}

class FunkScript extends Script {
	public static var globalVariables:Map<String, Dynamic> = [];
	public var scriptID:String = '';

	public function callback(method:String, ?args:Array<Dynamic>):Dynamic {
		if (!exists(method)) return CONTINUE_FUNCTION;
		return tryCall(method, args);
	}

	public function tryCall(method:String, ?args:Array<Dynamic>) {
		var value = null;
		try {
			value = call(method, args);
		} catch(e) {
			errorTrace(e);
			return CONTINUE_FUNCTION;
		}
		return value == null ? CONTINUE_FUNCTION : value;
	}

	public function new(hscriptCode:String):Void {
		super();
		implement();
		try {
			executeString(hscriptCode);
		}
		catch(e) {
			errorTrace(e);
		} 
	}

	inline public function errorTrace(error:Any) {
		ModdingUtil.errorTrace('$scriptID / ${Std.string(error)}');
	}

	public function implement():Void { //Preloaded Variables

		// Wip

		set('STOP_FUNCTION', STOP_FUNCTION);

		//Mau engin

        set('PlayState', PlayState.instance);
		set('GameVars', PlayState); // fuck
		set('State', cast MusicBeatState.instance);

		set('CoolUtil', CoolUtil);
		set('Conductor', Conductor);
		set('Paths', Paths);
		set('Preferences', Preferences);
		set('Controls', Controls);
		set('Shader', Shader);

		set('DialogueBox', funkin.objects.dialogue.NormalDialogueBox);
		set('PixelDialogueBox', funkin.objects.dialogue.PixelDialogueBox);
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
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxTypedGroup', flixel.group.FlxGroup.FlxTypedGroup);
		set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
		set('FlxGroup', flixel.group.FlxGroup);
		set('FlxSound', flixel.sound.FlxSound);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxAngle', flixel.math.FlxAngle);
		set('FlxColor', FlxColorFix); //	xd
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);

		#if cpp
		set('FlxVideo', hxcodec.flixel.FlxVideo);
		set('FlxVideoSprite', hxcodec.flixel.FlxVideoSprite);
		#end

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

		set('parseJson', function (value:String):Dynamic {
			return Json.parse(value);
		});

		set('stringifyJson', function (value:Dynamic, pretty:Bool = true):String {
			return FunkyJson.stringify(value, pretty ? "\t" : null);
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

		set('getSound', function (key:String):FlxSound {
			return CoolUtil.getSound(key);
		});

		set('playSound', function (key:String, volume:Float = 1) {
			CoolUtil.playSound(key, volume);
		});

		set('pauseSounds', function () {
			CoolUtil.pauseSounds();
		});

		// Needs pauseSounds() first
		set('resumeSounds', function () {
			CoolUtil.resumeSounds();
		});

		set('addSpr', function(spr:Dynamic, key:String = 'coolswag', onTop:Bool = false):Void {
			ScriptUtil.addSprite(spr,key,onTop);
		});

		set('setObjMap', function(object:Dynamic, key:String) {
			PlayState.instance.objMap.set(key, object);
		});
		
		set('insertSpr', function(order:Int = 0, spr:Dynamic, key:String = 'coolswag', OnTop:Bool = false) {
			PlayState.instance.objMap.set(ScriptUtil.formatSpriteKey(key, OnTop), spr);
			OnTop ? PlayState.instance.fgSpr.insert(order, spr) : PlayState.instance.bgSpr.insert(order, spr);
		});

		set('getSpr', function(key:String):Null<Dynamic> {
			return ScriptUtil.getSprite(key);					
		});

		set('getSprOrder', function(key:String):Int {
			for (i in ['fg', 'bg']) {
				var sprKey = ScriptUtil.getSpriteKey(i, key);
				if (PlayState.instance.objMap.exists(sprKey))
					return ScriptUtil.getGroup(i).members.indexOf(PlayState.instance.objMap.get(sprKey));
			}
			errorTrace('Sprite not found: $key');
			return 0;
		});

		set('existsSpr', function(key:String):Null<Dynamic> {
			for (i in ['fg', 'bg']) {
				if (PlayState.instance.objMap.exists(ScriptUtil.getSpriteKey(i, key))) {
					return true;
				}
			}
			return false;						
		});

		set('removeSpr', function(key:String) {
			for (i in ['fg', 'bg']) {
				var sprKey = ScriptUtil.getSpriteKey(i, key);
				var group = ScriptUtil.getGroup(i);
				if (PlayState.instance.objMap.exists(sprKey)) {
					group.remove(ScriptUtil.getSprite(key));
					PlayState.instance.objMap.remove(sprKey);
				}
			}
		});

		set('makeGroup', function(key:String, ?order:Int):Void {
			var newGroup:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
			order != null ? PlayState.instance.insert(order, newGroup) : PlayState.instance.add(newGroup);
			PlayState.instance.objMap.set('_group_$key', newGroup);
		});

		set('getGroup', function(key:String):Null<FlxTypedGroup<Dynamic>> {
			if (PlayState.instance.objMap.exists('_group_$key'))
				return PlayState.instance.objMap.get('_group_$key');
			else {
				errorTrace('Group not found: $key');
				return null;
			}
		});

		set('existsGroup', function(key:String):Bool {
			return PlayState.instance.objMap.exists('_group_$key');						
		});

		// Script functions

		set('addScript', function(path:String, ?tag:String):Void {
			ModdingUtil.addScript(path, tag);
		});

		set('removeScript', function(tag:String):Void {
			ModdingUtil.removeScript(tag);
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
			for (i in ModdingUtil.scripts) {
				if (forced || !i.exists(key))
					i.set(key, _var);
			}
		});

		set('setGlobalVar', function (key:String, _var:Dynamic) {
			globalVariables.set(key, _var);
		});

		set('existsGlobalVar', function (key:String) {
			return globalVariables.exists(key);
		});

		set('getGlobalVar', function (key:String) {
			if (globalVariables.exists(key)) return globalVariables.get(key);
			else {
				errorTrace('Variable not found: $key');
				return null;
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
			ScriptUtil.switchCustomState(key);
		});

		set('add', function(object:Dynamic) {
			FlxG.state.add(object);
		});

		set('insert', function(position:Int, object:Dynamic) {
			FlxG.state.insert(position, object);
		});

		set('remove', function(object:Dynamic) {
			FlxG.state.remove(object);
		});
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
		script.set('Parent', cast this);

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
		if (FlxG.keys.justPressed.F4) switchState(new StoryMenuState()); // emergency exit
		if (FlxG.keys.justPressed.F5) ScriptUtil.switchCustomState(_scriptKey);
		if (superCallback('update', [elapsed])) super.update(super_map.get('update').value);
    }

	override public function stepHit() 		if (superCallback('stepHit', [curStep])) 		super.stepHit();
	override public function beatHit() 		if (superCallback('beatHit', [curBeat])) 		super.beatHit();
	override public function sectionHit() 	if (superCallback('sectionHit', [curSection])) 	super.sectionHit();
	override public function destroy() 		if (superCallback('destroy')) 					super.destroy();
}