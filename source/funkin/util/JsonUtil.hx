package funkin.util;

import haxe.Json;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

typedef EngineVersion = {
	var version:String;
	var patchNotes:Array<String>;
}

//Aseprite Json packer format
typedef JsonFrame = {
	var filename:String;
	var frame:{x:Float, y:Float, w:Float, h:Float};
	var rotated:Bool;
	var trimmed:Bool;
	var spriteSourceSize:{x:Float, y:Float, w:Float, h:Float};
	var sourceSize:{w:Float, h:Float};
	var duration:Float;
}
typedef JsonTag = {
	var name:String;
	var from:Int;
	var to:Int;
}
typedef JsonSpritesheet = {
	var frames:Array<JsonFrame>;
	var meta:{frameTags:Array<JsonTag>};
}

class JsonUtil
{
	public static function getSubFolderJsonList(folder:String, ?subFolders:Array<String>)
	{   
		var subFolderList:Array<String> = [];
		
		if (subFolders != null) {
			subFolders.fastForEach((subFolder, i) -> {
				subFolderList.merge(getJsonList('$folder/$subFolder'));
			});
		}
        
		return getJsonList(folder).concat(subFolderList);
    }

	public static function getJsonList(?folder:String, ?assets:Bool, ?global:Bool, ?mod:Bool, ?all:Bool, ?fullPath:Bool, ?mainFolder:String):Array<String>
	{
		folder ??= 'scripts/global';
		assets ??= true;
		global ??= true; mod ??= true; all ??= false;
		fullPath ??= false;
		mainFolder ??= 'data';

		if (!folder.startsWith('$mainFolder/'))
			folder = '$mainFolder/$folder';

		var list:Array<String> = [];

		if (assets) {
			list.merge(Paths.getFileList(TEXT, fullPath, 'json', '/$folder'));
		}

		#if MODS_ALLOWED
		if (global || mod || all) {
			list.merge(Paths.getModFileList(folder, 'json', fullPath, global, mod, all));
		}
		#end

		return list;
	}

	public static function getJson(path:String, folder:String = '', library:String = 'data'):Dynamic
	{
		var rawJson = CoolUtil.getFileContent(Paths.file('$library/$folder/$path.json', TEXT));
		return rawJson.length > 0 ? Json.parse(rawJson) : null;
	}

	inline public static function getAsepritePacker(graphic:FlxGraphic, sourceJson:String):FlxAtlasFrames {
		var jsonData:JsonSpritesheet = Json.parse(sourceJson);
		var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);

		var framesTagData:Array<Array<Dynamic>> = [];
		for (tag in jsonData.meta.frameTags)
			framesTagData.push([tag.from, tag.to, tag.name]);

		var frameCount:Int = 0;
		var frameName:String = '';
		var newFrameName:String = '_';

		var isArray:Bool = jsonData.frames is Array;
		var framesArray:Array<JsonFrame> = isArray ? jsonData.frames : Reflect.fields(jsonData.frames).map(function(field) return Reflect.field(jsonData.frames, field));

		for (i in 0...framesArray.length) {
			var frame = framesArray[i];
			for (data in framesTagData) {
				if (i >= data[0] && i <= data[1]) // Get animation tag name
					newFrameName = data[2];
				if (frameName != newFrameName) {
					frameCount = 0;
					frameName = newFrameName;
				}
			}
			var rect = FlxRect.get(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			frames.addAtlasFrame(rect, FlxPoint.get(rect.width, rect.height), FlxPoint.get(), '$frameName${CoolUtil.formatInt(frameCount, 5)}');
			frameCount++;
		}
		
		return frames;
	}

	public static function checkJson<T>(defaults:T, ?input:T):T
	{
		var defaults:T = copyJson(defaults);
		if (input == null)
			return defaults;

		Reflect.fields(defaults).fastForEach((field, i) -> {
			if (Reflect.hasField(input, field))
			{
				if (Reflect.field(input, field) == null)
					Reflect.setField(input, field, Reflect.field(defaults, field));
			}
			else
			{
				Reflect.setField(input, field, Reflect.field(defaults, field));
			}
		});

		return removeUnusedVars(defaults, input);
	}

	public static function removeUnusedVars<T>(defaults:T, input:T):T
	{
		var defaultFields = Reflect.fields(defaults);
		
		Reflect.fields(input).fastForEach((field, i) -> {
			if (!defaultFields.contains(field))
				Reflect.deleteField(input, field);
		});

		return input;
	}

	public static inline function copyJson<T>(c:T):T {
        return haxe.Unserializer.run(haxe.Serializer.run(c));
	}
}

class FunkyJson extends haxe.format.JsonPrinter
{
	public static inline function stringify(value:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):String {
		return print(value, replacer, space);
	}

	public static function print(o:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):String {
		var printer = new FunkyJson(replacer, space);
		printer.write("", o);
		return printer.buf.toString();
	}
	
	override function write(k:Dynamic, v:Dynamic) {
		if (replacer != null)
			v = replacer(k, v);
		switch (Type.typeof(v)) {
			case TUnknown:
				add('"???"');
			case TObject:
				objString(v);
			case TInt:
				add(#if (jvm || hl) Std.string(v) #else v #end);
			case TFloat:
				add(Math.isFinite(v) ? Std.string(v) : 'null');
			case TFunction:
				add('"<fun>"');
			case TClass(c):
				if (c == String)
					quote(v);
				else if (c == Array) {
					var v:Array<Dynamic> = v;
					addChar('['.code);

					var len = v.length;
					var last = len - 1;
					for (i in 0...len) {
						if (i > 0)
							addChar(','.code)
						else
							nind++;
						
						var type = Type.typeof(cast v[i]);
						var clean = true;
						switch (type) {
							case TFloat | TInt | TClass(String): clean = false;
							default:
						}
						if (clean) {
							newl();
							ipad();
						}
						write(i, v[i]);
						if (i == last) {
							nind--;
							if (clean) {
								newl();
								ipad();
							}
						}
					}
					addChar(']'.code);
				} else if (c == haxe.ds.StringMap) {
					var v:haxe.ds.StringMap<Dynamic> = v;
					var o = {};
					for (k in v.keys())
						Reflect.setField(o, k, v.get(k));
					objString(o);
				} else if (c == Date) {
					var v:Date = v;
					quote(v.toString());
				} else
					classString(v);
			case TEnum(_):
				var i = Type.enumIndex(v);
				add(Std.string(i));
			case TBool:
				add(#if (php || jvm || hl) (v ? 'true' : 'false') #else v #end);
			case TNull:
				add('null');
		}
	}
}