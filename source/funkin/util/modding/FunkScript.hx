package funkin.util.modding;

import funkin.objects.NotesGroup;
import hscript.Script;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.util.frontend.*;

enum abstract HscriptFunctionCallback(Bool) {
	var CONTINUE_FUNCTION = true;
	var STOP_FUNCTION = false;
}

class FunkScript extends hscript.Script implements IFlxDestroyable
{
	public static var globalVariables:Map<String, Dynamic> = [];
	public var active:Bool = true;
	public var scriptID:String = '';

	public function destroy():Void {
		if (interp != null)
			dispose();
	}

	public inline function safeCall(method:String, args:Array<Dynamic>):Dynamic {
		try {
			return call(method, args);
		}
		catch(e) {
			errorPrint(e);
			return CONTINUE_FUNCTION;
		}
	}

	public function new(hscriptCode:String, scriptID:String):Void {
		super();
		
		// Make sure to DM me unsafe classes to add here
		//interp.importBlocklist = [];
		
		this.scriptID = scriptID;
		implement();
		__runCode(hscriptCode);
	}

	@:noClosure
	public inline function __runCode(hscriptCode:String = "") {
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

	static final tempEvent:Event = new Event(); // For runEvent()
	
	@:noCompletion
	public function implementNonStatic():Void { // For the runCode event and script console
		set('State', cast FlxG.state);
		set('add', FlxG.state.add);
		set('insert', FlxG.state.insert);
		set('remove', FlxG.state.remove);
	}

	public function implement():Void { //Preloaded Variables
		implementNonStatic();

		set("trace", Reflect.makeVarArgs((traces) -> {
			while (traces.length > 0) {
				var str = Std.string(traces.shift());
				ModdingUtil.print(str, NONE);
			}
		}));

		// Wip

		set('STOP_FUNCTION', STOP_FUNCTION);

		//Mau engin

        set('PlayState', PlayState);

		set('MusicBeatSubstate', MusicBeatSubstate);
		set('MusicBeatState', MusicBeatState);

		set('CoolUtil', CoolUtil);
		set('FunkMath', FunkMath);
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
		set('Sustain', Sustain);

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
		set('FlxBackdrop', funkin.graphics.FlxBackdropExt); // Just a lil fix for lod
		set('FlxText', flixel.text.FlxText);
		set('FlxTypedGroup', TypedGroup);
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

		#if hxvlc
		set('FlxVideo', hxvlc.flixel.FlxVideo);
		set('FlxVideoSprite', hxvlc.flixel.FlxVideoSprite);
		#end

		#if discord_rpc
		set("changeDiscordPresence", DiscordClient.changePresence);
		#end

		set("BUILD_TARGET",
			#if windows "windows"
			#elseif linux "linux"
			#elseif mac "mac"
			#elseif android "android"
			#elseif html5 "html5"
			#else null // ios doesnt exist
			#end
		);

		set("VIDEOS_ALLOWED", #if hxvlc true #else false #end);
		set("DISCORD_ALLOWED", #if discord_rpc true #else false #end);
		set("ZIPS_ALLOWED", #if ZIPS_ALLOWED true #else false #end);

		//HScript Functions

		// DEPRECATED
		set('importLib', (classStr:String, packageStr:String = '', ?customName:String) -> {
			if(packageStr != '') packageStr += '.';
			if (customName != null && !exists(customName)) {
				warningPrint('importLib() is deprecated, use ``import ... as`` instead');
				set(customName, Type.resolveClass(packageStr + classStr));
				return;
			}
			warningPrint('importLib() is deprecated, use ``import`` instead!');
			set(classStr, Type.resolveClass(packageStr + classStr));
		});

		set('closeScript', () -> {
			FlxG.signals.preUpdate.addOnce(() -> ModdingUtil.removeScript(this));
		});

		set('getBlendMode', ScriptUtil.stringToBlend);
		set('getEase', ScriptUtil.stringToEase);

		set('parseJson',  Json.parse);
		set('stringifyJson', (value:Dynamic, pretty:Bool = true) -> {
			return FunkyJson.stringify(value, pretty ? "\t" : null);
		});

		set('getPref', Preferences.getPref);
		set('getKey',  Controls.getKeyOld);
		
		// Sounds stuff
		set('getSound', CoolUtil.getSound);
		set('playSound', CoolUtil.playSound);
		set('pauseSounds', CoolUtil.pauseSounds);
		set('resumeSounds', CoolUtil.resumeSounds);

		set('makeCutsceneManager',  CutsceneManager.makeManager);
		set('makeModchartManager', () -> {
			final manager = ModchartManager.makeManager();
			final instance = PlayState.instance;
			if (instance != null) {
				manager.setStrumLine(0, instance.notesGroup.opponentStrums);
				manager.setStrumLine(1, instance.notesGroup.playerStrums);
			}
			return manager;
		});

		set('setObjMap', (object:FlxObject, key:String) -> {
			ScriptUtil.objects.set(key, object);
		});

		// Stage objects stuff
		set('addSpr', ScriptUtil.addObject);
		set('insertSpr', ScriptUtil.insertObject);
		set('existsSpr', ScriptUtil.existsObject);
		set('removeSpr', ScriptUtil.removeObject);
		set('getSpr', ScriptUtil.getObject);
		set('getSprOrder', ScriptUtil.getObjectIndex);

		// Stage layers stuff
		set('makeLayer', (?maxSize:Int) -> return new Layer(maxSize));
		set('addLayer', ScriptUtil.addLayer);
		set('insertLayer', ScriptUtil.insertLayer);
		set('getLayer', ScriptUtil.getLayer);
		set('existsLayer', ScriptUtil.existsLayer);

		set('cacheImage', CoolUtil.cacheImage);
		set('cacheCharacter', (name:String) -> return new Character(0, 0, name));

		set('runEvent', (name:String, ?values:Array<Dynamic>) -> {
			if (name == "runCode") // why would you-
				return false;

			if (NotesGroup.instance != null)
			{
				var	curEvents = NotesGroup.instance.songEvents;
				if (!curEvents.contains(name)) {
					ModdingUtil.addScript(Paths.script('events/$name'));
					curEvents.push(name);
				}
			}

			tempEvent.name = name;
			tempEvent.values = values ?? [];
			return ModdingUtil.getCall('eventHit', [tempEvent]);
		});

		// Script functions

		set('addScript', ModdingUtil.addScript);
		set('removeScript', ModdingUtil.removeScriptByTag);

		set('getScriptVar', (script:String, key:String) -> {
			var script = ModdingUtil.scriptsMap.get(script);
			if (script.exists(key)) {
				return script.get(key);
			}
			return null;
		});

		set('callScriptsFunction', ModdingUtil.addCall);

		set('callScriptFunction', (script:String, method:String, ?args:Array<Dynamic>) -> {
			var script = ModdingUtil.scriptsMap.get(script);
			if (script != null)
				return script.safeCall(method, args);

			return CONTINUE_FUNCTION;
		});

		set('addGlobalVar', (key:String, _var:Dynamic, forced:Bool = false) -> {
			ModdingUtil.scripts.fastForEach((script, i) -> {
				if (forced || !script.exists(key))
					script.set(key, _var);
			});
		});

		set('setGlobalVar', (key:String, value:Dynamic) -> {
			globalVariables.set(key, value);
		});

		set('existsGlobalVar', (key:String) -> {
			return globalVariables.exists(key);
		});

		set('getGlobalVar', (key:String) -> {
			if (globalVariables.exists(key)) return globalVariables.get(key);
			else {
				warningPrint('Variable not found: $key');
				return null;
			}
		});

		// Runtime shader functions

		set('initShader', function (shader:String, ?tag:String, forced:Bool = false):Null<RuntimeShader> {
			return Shader.initShader(shader, tag, forced);
		});

		set('getShader', function (shader:String):Null<RuntimeShader> {
			return Shader.shaderMap.get(shader);
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
			return value;
		});

		set('setShaderInt', function (shader:String, prop:String, value:Int) {
			Shader.setInt(shader, prop, value);
			return value;
		});

		set('setShaderBool', function (shader:String, prop:String, value:Bool) {
			Shader.setBool(shader, prop, value);
			return value;
		});

		set('setShaderVector', function (shader:String, prop:String, value:Array<Dynamic>) {
			Shader.setVector(shader, prop, value);
			return value;
		});

		// Custom state

		set('switchCustomState', ScriptUtil.switchCustomState);
	}
}

enum abstract SuperType(String) from String to String {
	var CREATE = "create";
	var UPDATE = "update";
	var STEP = "stepHit";
	var BEAT = "beatHit";
	var SECTION = "sectionHit";
}

class CustomState extends MusicBeatState {
	public var script(default, null):FunkScript;
	public var key(default, null):String;

	public function initScript(scriptCode:String, stateTag:String) {
		key = stateTag;
		script = new FunkScript(scriptCode, '_custom_state_$stateTag');
		script.set('Parent', cast this);

		// Add the super arguments
		script.set("super_" + CREATE, super_create);
		script.set("super_" + UPDATE, super_update);
		script.set("super_" + STEP, super_stepHit);
		script.set("super_" + BEAT, super_beatHit);
		script.set("super_" + SECTION, super_sectionHit);

		return this;
	}

	final function super_create() super.create();
	final function super_update(?e:Float) super.update(e ?? FlxG.elapsed);
	final function super_stepHit(s:Int) super.stepHit(s);
	final function super_beatHit(b:Int) super.beatHit(b);
	final function super_sectionHit(s:Int) super.sectionHit(s);
	
	inline function callDynamicSuper(f:SuperType, ?v:Dynamic) {
		switch(f) {
			case CREATE: super_create();
			case UPDATE: super_update(v);
			case STEP: super_stepHit(v);
			case BEAT: super_beatHit(v);
			case SECTION: super_sectionHit(v);
		}
	}

	function checkSuper(f:String, ?v:Array<Dynamic>) {
		if (script.exists(f)) {
			script.safeCall(f, v);
		} else {
			callDynamicSuper(f, v[0]); // Gets called if function doesnt have an override
		}
	}

    override public function create() {
		ModdingUtil.addPrint(key + " / Custom State");
		script.implementNonStatic();
		checkSuper(CREATE);
    }
    
    override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.F4) switchState(new MainMenuState()); // emergency exit
		if (FlxG.keys.justPressed.F5) ScriptUtil.switchCustomState(key, false, false);
		checkSuper(UPDATE, [elapsed]);
    }

	override public function stepHit(curStep) 		checkSuper(STEP, [curStep]);
	override public function beatHit(curBeat) 		checkSuper(BEAT, [curBeat]);
	override public function sectionHit(curSection) checkSuper(SECTION, [curSection]);
	
	override public function destroy() {
		script.safeCall("destroy", null);
		super.destroy();
	}
}