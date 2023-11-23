package funkin.util.modding;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

enum HscriptFunctionCallback {
	STOP_FUNCTION;
	CONTINUE_FUNCTION;
}

class FunkScript extends hscript.Script implements IFlxDestroyable {
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
			errorPrint(e);
			return CONTINUE_FUNCTION;
		}
		return value ?? CONTINUE_FUNCTION;
	}

	public function new(hscriptCode:String, scriptID:String):Void {
		super();
		this.scriptID = scriptID;
		implement();
		try {
			executeString(hscriptCode);
		}
		catch(e) {
			errorPrint(e);
		} 
	}

	inline function getTraceID() {
		return scriptID.replace("mods/","");
	}

	inline public function errorPrint(error:Any) {
		ModdingUtil.errorPrint('${getTraceID()} / ${Std.string(error).replace("hscript:", "")}');
	}

	inline public function warningPrint(text:String) {
		ModdingUtil.warningPrint('${getTraceID()} / $text');
	}

	public function implement():Void { //Preloaded Variables

		// Wip

		set('STOP_FUNCTION', STOP_FUNCTION);

		//Mau engin

        set('PlayState', PlayState);
		set('State', cast FlxG.state);

		set('MusicBeatSubstate', MusicBeatSubstate);
		set('MusicBeatState', MusicBeatState);

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
        set('FlxSpriteExt', funkin.graphics.FlxSpriteExt); // Both r the same lol, just for backwards compatibility
		set('FlxSprite', funkin.graphics.FlxSpriteExt);
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

		#if (cpp && !linux)
		set('FlxVideo', hxcodec.flixel.FlxVideo);
		set('FlxVideoSprite', hxcodec.flixel.FlxVideoSprite);
		#end

		//HScript Functions

		// DEPRECATED
		set('importLib', function(classStr:String, packageStr:String = '', ?customName:String):Void {
			if(packageStr != '') packageStr += '.';
			if (customName != null && !exists(customName)) {
				warningPrint('importLib() is deprecated, use ``import as`` instead');
				set(customName, Type.resolveClass(packageStr + classStr));
				return;
			}
			warningPrint('importLib() is deprecated, use ``import`` instead!');
			set(classStr, Type.resolveClass(packageStr + classStr));
		});

		set('closeScript', function () {
			ModdingUtil.removeScript(this);
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
		
		set("trace", Reflect.makeVarArgs(function(el) {
			var v = el.shift();
			ModdingUtil.print(Std.string(v), NONE);
		}));

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

		set('makeCutsceneManager', function (?targetSound:FlxSound) {
			return funkin.util.frontend.CutsceneManager.makeManager(targetSound);
		});

		// DONT USE THIS, ITS A WIP
		set('makeModchartManager', function () {
			final manager = funkin.util.frontend.ModchartManager.makeManager();
			manager.setStrumLine(0, PlayState?.instance?.opponentStrums);
			manager.setStrumLine(1, PlayState?.instance?.playerStrums);
			return manager;
		});

		set('addSpr', function(spr:Dynamic, key:String = 'coolswag', onTop:Bool = false):Void {
			ScriptUtil.addSprite(spr,key,onTop);
		});

		set('setObjMap', function(object:Dynamic, key:String) {
			ScriptUtil.objMap.set(key, object);
		});
		
		set('insertSpr', function(order:Int = 0, spr:Dynamic, key:String = 'coolswag', OnTop:Bool = false) {
			ScriptUtil.objMap.set(ScriptUtil.formatSpriteKey(key, OnTop), spr);
			OnTop ? PlayState.instance.fgSpr.insert(order, spr) : PlayState.instance.bgSpr.insert(order, spr);
		});

		set('getSpr', function(key:String):Null<Dynamic> {
			return ScriptUtil.getSprite(key);					
		});

		set('getSprOrder', function(key:String):Int {
			for (i in ['fg', 'bg']) {
				var sprKey = ScriptUtil.getSpriteKey(i, key);
				if (ScriptUtil.objMap.exists(sprKey))
					return ScriptUtil.getGroup(i).members.indexOf(ScriptUtil.objMap.get(sprKey));
			}
			errorPrint('Sprite not found: $key');
			return 0;
		});

		set('existsSpr', function(key:String):Null<Dynamic> {
			for (i in ['fg', 'bg']) {
				if (ScriptUtil.objMap.exists(ScriptUtil.getSpriteKey(i, key))) {
					return true;
				}
			}
			return false;						
		});

		set('removeSpr', function(key:String) {
			for (i in ['fg', 'bg']) {
				var sprKey = ScriptUtil.getSpriteKey(i, key);
				var group = ScriptUtil.getGroup(i);
				if (ScriptUtil.objMap.exists(sprKey)) {
					group.remove(ScriptUtil.getSprite(key));
					ScriptUtil.objMap.remove(sprKey);
				}
			}
		});

		set('makeGroup', function(key:String, ?order:Int):FlxTypedGroup<Dynamic> {
			var newGroup:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
			order != null ? FlxG.state.insert(order, newGroup) : FlxG.state.add(newGroup);
			if (cast FlxG.state is PlayState) ScriptUtil.objMap.set('_group_$key', newGroup);
			return newGroup;
		});

		set('getGroup', function(key:String):Null<FlxTypedGroup<Dynamic>> {
			if (ScriptUtil.objMap.exists('_group_$key'))
				return ScriptUtil.objMap.get('_group_$key');
			else {
				errorPrint('Group not found: $key');
				return null;
			}
		});

		set('existsGroup', function(key:String):Bool {
			return ScriptUtil.objMap.exists('_group_$key');						
		});

		set('cacheCharacter', function(name:String):Character {
			return new Character(0,0,name);
		});

		// Script functions

		set('addScript', function(path:String, ?tag:String):Void {
			ModdingUtil.addScript(path, tag);
		});

		set('removeScript', function(tag:String):Void {
			ModdingUtil.removeScriptByTag(tag);
		});

		set('getScriptVar', function(script:String, key:String):Dynamic {
			var script = ModdingUtil.scriptsMap.get(script);
			if (script.exists(key)) {
				return script.get(key);
			}
			return null;
		});

		set('callScriptsFunction', function(func:String, ?args:Array<Dynamic>) {
			ModdingUtil.addCall(func, args);
		});

		set('callScriptFunction', function(script:String, func:String, ?args:Array<Dynamic>):Dynamic {
			return ModdingUtil.scriptsMap.get(script)?.callback(func, args) ?? null;
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
				errorPrint('Variable not found: $key');
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

		set('setShaderVector', function (shader:String, prop:String, value:Array<Dynamic>) {
			Shader.setVector(shader, prop, value);
		});

		// Custom state

		set('switchCustomState', function (key:String, skipTrans:Bool = false) {
			ScriptUtil.switchCustomState(key, skipTrans);
		});

		// Base state functions

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

	public function destroy() {
		this.interp = null;
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
		script = new FunkScript(scriptCode, '_custom_state_$stateTag');
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
		ModdingUtil.addPrint(_scriptKey + " / Custom State");
		if (superCallback('create')) super.create();
    }
    
    override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.F4) switchState(new StoryMenuState()); // emergency exit
		if (FlxG.keys.justPressed.F5) ScriptUtil.switchCustomState(_scriptKey, Transition.skipTrans);
		if (superCallback('update', [elapsed])) super.update(super_map.get('update').value);
    }

	override public function stepHit(curStep) 		if (superCallback('stepHit', [curStep])) 		super.stepHit(curStep);
	override public function beatHit(curBeat) 		if (superCallback('beatHit', [curBeat])) 		super.beatHit(curBeat);
	override public function sectionHit(curSection) if (superCallback('sectionHit', [curSection])) 	super.sectionHit(curSection);
	override public function destroy() 				if (superCallback('destroy')) 					super.destroy();
}