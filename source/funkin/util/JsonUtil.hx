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

//Default Json sprite format
typedef SpriteAnimation = {
    var animName:String;
	var animFile:String;
	var offsets:Array<Float>;
    var indices:Array<Int>;
	var framerate:Int;
    var loop:Bool;
}
typedef SpriteJson = {
	var anims:Array<SpriteAnimation>;
    var imagePath:String;
    var scale:Float;
	var antialiasing:Bool;
	var flipX:Bool;
}

//Story / Freeplay Format
typedef SongList = {
	var songs:Array<String>;
	var songIcon:Array<String>;
}

typedef WeekJson = {
	var songList:SongList;
	var weekDiffs:Array<String>;
	var weekImage:String;
	var weekName:String;
	var weekColor:String;
	var storyBf:String;
	var storyDad:String;
	var storyGf:String;

	var startUnlocked:Bool;
	var unlockWeek:String;
	var hideStory:Bool;
	var hideFreeplay:Bool;
}

class JsonUtil {
	public static function getSubFolderJsonList(folder:String= 'data/scripts/global', ?subFolders:Array<String>) {
        subFolders = subFolders == null ? [] : subFolders;
        var subFolderList:Array<String> = [];
        for (i in subFolders)
            subFolderList = subFolderList.concat(getJsonList(folder + "/" + i));
        return getJsonList(folder).concat(subFolderList);
    }

	inline public static function getJsonList(folder:String = 'scripts/global',
		assets:Bool = true, globalMod:Bool = true, curMod:Bool = true, allMods:Bool = false,
		fullPath:Bool = false, mainFolder:String = 'data'):Array<String> {
		
        var assetsList:Array<String> = assets ? Paths.getFileList(TEXT, fullPath, 'json', '/$mainFolder/$folder') : [];
        var modList:Array<String> = #if desktop Paths.getModFileList('$mainFolder/$folder', 'json', fullPath, globalMod, curMod, allMods); #else []; #end
        return assetsList.concat(modList);
	}

	public static function getJson(path:String, folder:String = '', library:String = 'data'):Dynamic {
		if (!getJsonList(folder,true,true,true,false,false,library).contains(path))
			return null;
		var getJson = CoolUtil.getFileContent(Paths.file('$library/$folder/$path.json', TEXT));
		var returnJson:Dynamic = Json.parse(getJson);
		return returnJson;
	}

	inline public static function getAsepritePacker(path:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		var jsonData:JsonSpritesheet = Json.parse(CoolUtil.getFileContent(Paths.file('images/$path.json', TEXT, library)));
		var graphic:FlxGraphic = FlxG.bitmap.add(Paths.image(path, library, false, false, gpu));
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

	public static function checkJsonDefaults(defaultsInput:Dynamic, ?input:Dynamic):Dynamic {
		var defaults = copyJson(defaultsInput);
		if (input == null) return defaults;

		var props = Reflect.fields(defaults);
		for (prop in props) {
			if (Reflect.hasField(input, prop)) {
				var val = Reflect.field(input, prop);
				if (val == null)
					Reflect.setField(input, prop, Reflect.field(defaults, prop));
			}
			else
				Reflect.setField(input, prop, Reflect.field(defaults, prop));
		}
		return removeUnusedVars(defaults, input);
	}

	public static function removeUnusedVars(defaults:Dynamic, input:Dynamic):Dynamic {
		var defProps = Reflect.fields(defaults);
		var inputProps = Reflect.fields(input);
		for (prop in inputProps) {
			if (!defProps.contains(prop))
				Reflect.deleteField(input, prop);
		}
		return input;
	}

	public static function copyJson<T>(c:T):T {
		var serializedData = haxe.Serializer.run(c);
        return haxe.Unserializer.run(serializedData);
	}
}

class FunkyJson extends haxe.format.JsonPrinter {
	public static inline function stringify(value:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):String {
		return print(value, replacer, space);
	}

	static public function print(o:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):String {
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