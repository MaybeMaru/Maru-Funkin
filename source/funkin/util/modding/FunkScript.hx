package funkin.util.modding;

import funkin.objects.NotesGroup;
import funkin.objects.NotesGroup;
import hscript.Script;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

enum abstract HscriptFunctionCallback(Int) from Int to Int {
	var CONTINUE_FUNCTION = 0;
	var STOP_FUNCTION = 1;
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
	}

	public function implement():Void { //Preloaded Variables
		implementNonStatic();

		set("trace", Reflect.makeVarArgs(function(el) {
			var v = el.shift();
			ModdingUtil.print(Std.string(v), NONE);
		}));

		// Wip

		set('STOP_FUNCTION', STOP_FUNCTION);

		//Mau engin

        set('PlayState', PlayState);

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
			#else null // ios and html5 dont exist and will never do
			#end
		);

		set("VIDEOS_ALLOWED", #if hxvlc true #else false #end);
		set("DISCORD_ALLOWED", #if discord_rpc true #else false #end);
		set("ZIPS_ALLOWED", #if ZIPS_ALLOWED true #else false #end);

		//HScript Functions

		// DEPRECATED
		set('importLib', function(classStr:String, packageStr:String = '', ?customName:String):Void {
			if(packageStr != '') packageStr += '.';
			if (customName != null && !exists(customName)) {
				warningPrint('importLib() is deprecated, use ``import ... as`` instead');
				set(customName, Type.resolveClass(packageStr + classStr));
				return;
			}
			warningPrint('importLib() is deprecated, use ``import`` instead!');
			set(classStr, Type.resolveClass(packageStr + classStr));
		});

		set('closeScript', function () {
			FlxG.signals.preUpdate.addOnce(function () {
				ModdingUtil.removeScript(this);
			});
		});

		set('getBlendMode', function(blendType:String):openfl.display.BlendMode {
			return ScriptUtil.stringToBlend(blendType);
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
			return Controls.getKeyOld(key);
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

		set('makeCutsceneManager', function (?targetSound:FlxSound) {
			return funkin.util.frontend.CutsceneManager.makeManager(targetSound);
		});

		// DONT USE THIS, ITS A WIP
		set('makeModchartManager', function () {
			final manager = funkin.util.frontend.ModchartManager.makeManager();
			final instance = PlayState.instance;
			if (instance != null) {
				manager.setStrumLine(0, instance.notesGroup.opponentStrums);
				manager.setStrumLine(1, instance.notesGroup.playerStrums);
			}
			return manager;
		});

		set('addSpr', function(spr:Dynamic, ?key:String, onTop:Bool = false):Dynamic {
			return ScriptUtil.addObject(spr, key, onTop);
		});

		set('insertSpr', function(position:Int = 0, spr:Dynamic, ?key:String, onTop:Bool = false):Dynamic {
			return ScriptUtil.insertObject(position, spr, key, onTop);
		});

		/*set('insertBehind', function(spr:Dynamic, ?key:String, behindKey:String) {
			var layer = ScriptUtil.getSpriteLayer(behindKey);
			var bSpr = ScriptUtil.getSprite(behindKey);
			ScriptUtil.insertSprite(spr, key, layer.indexOf(bSpr) - 1, layer);
		});

		set('insertAbove', function(spr:Dynamic, ?key:String, aboveKey:String) {
			var layer = ScriptUtil.getSpriteLayer(aboveKey);
			var aSpr = ScriptUtil.getSprite(aboveKey);
			ScriptUtil.insertSprite(spr, key, layer.indexOf(aSpr), layer);
		});*/

		set('setObjMap', function(object:Dynamic, key:String):Void {
			ScriptUtil.objects.set(key, object);
		});

		set('getSpr', function(key:String):Null<FlxObject> {
			return ScriptUtil.getObject(key);
		});

		// TODO: improve this shit
		set('getSprOrder', function(key:String):Int {
			var sprite = ScriptUtil.getObject(key);
			if (sprite != null)
			{
				var layer = ScriptUtil.stage.getObjectLayer(sprite);
				return	layer == null ? -1 : layer.members.indexOf(sprite);
			}

			return -1;
		});

		set('existsSpr', function(key:String):Bool {
			return ScriptUtil.existsObject(key);					
		});

		// TODO: improve this shit
		set('removeSpr', function(key:String) {
			var sprite = ScriptUtil.getObject(key);
			if (sprite != null)
			{
				var layer = ScriptUtil.stage.getObjectLayer(sprite);
				if (layer != null)
					layer.remove(sprite, true);

				ScriptUtil.objects.remove(key);
			}
		});

		set('makeLayer', function(?maxSize:Int) {
			return new Layer(maxSize);
		});

		set('addLayer', function(layer:Layer, key:String) {
			ScriptUtil.addLayer(layer, key);
		});

		set('insertLayer', function (index:Int = 0, layer:Layer, key:String) {
			ScriptUtil.stage.insertLayer(index, layer, key);
		});

		set('getLayer', function (key:String) {
			return ScriptUtil.getLayer(key);
		});

		set('existsLayer', function (key:String) {
			return ScriptUtil.existsLayer(key);
		});

		set('cacheCharacter', function(name:String):Character {
			final cachedChar = new Character(0, 0, name);
			if ((PlayState.instance != null) && (cachedChar.frame != null)) {
				CoolUtil.cacheImage(cachedChar.frame.parent, null, PlayState.instance.camGame);
			}
			return cachedChar;
		});

		set('cacheImage', function(image:FlxGraphicAsset, ?library:String, ?camera:FlxCamera):FlxGraphicAsset {
			return CoolUtil.cacheImage(image, library, camera);
		});

		set('runEvent', function(name:String, ?values:Array<Dynamic>):Bool {
			if (name == "runCode") // why would you-
				return false;

			if (NotesGroup.instance != null)
			{
				var	curEvents = NotesGroup.instance.songEvents;
				if (!curEvents.contains(name)) {
					var script = ModdingUtil.addScript(Paths.script('events/$name'));
					curEvents.push(name);
				}
			}

			tempEvent.name = name;
			tempEvent.values = values ?? [];
			return ModdingUtil.getCall('eventHit', [tempEvent]);
		});

		// Script functions

		set('addScript', function(path:String, ?tag:String):Null<FunkScript> {
			return ModdingUtil.addScript(path, tag);
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

		set('callScriptFunction', function(script:String, method:String, ?args:Array<Dynamic>):Dynamic {
			var script = ModdingUtil.scriptsMap.get(script);
			if (script != null)
				return script.safeCall(method, args);

			return CONTINUE_FUNCTION;
		});

		set('addGlobalVar', function(key:String, _var:Dynamic, forced:Bool = false) {
			ModdingUtil.scripts.fastForEach((script, i) -> {
				if (forced || !script.exists(key))
					script.set(key, _var);
			});
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

		set('switchCustomState', function (key:String, skipTransOpen:Bool = false, ?skipTransClose:Bool) {
			ScriptUtil.switchCustomState(key, skipTransOpen, skipTransClose);
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