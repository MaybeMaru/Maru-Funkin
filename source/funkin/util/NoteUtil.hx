package funkin.util;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;

typedef NoteTypeJson = {
	var mustHit:Bool;
	var hitHealth:Array<Float>;
	var missHealth:Array<Float>;
	var altAnim:String;
	var ?skin:String;
	var showText:Bool;
    var hitMult:Float;
}

class NoteUtil {
	public static var swagWidth:Float = 160 * 0.7;
	public static var swagHeight:Float = 150 * 0.7;

    public static var DEFAULT_NOTE_TYPE(default, never):NoteTypeJson = {
		mustHit: true,
		hitHealth: [0.0237, 0.029],
		missHealth: [0.0475, 0.0118],
		altAnim: '',
		skin: null,	//should be 'default', but null for the stage skin to load
		showText: true,
        hitMult: 1 // I recommend making this value smaller for fire-like notes
	}

    public static var DEFAULT_NOTE_SKIN(default, never):NoteSkinData = {
		anims: [],
		imagePath: "noteAssets",
		scale: 0.7,
		antialiasing: true,
		flipX: false,
		noteColorArray: ["0xffc24b99", "0xff00ffff", "0xff12fa05", "0xfff9393f"]
	}

    public static var noteTypesMap:Map<String, NoteTypeJson> = [];
	public static var noteTypesArray:Array<String> = [];
    
    inline public static function getTypeName(type:Dynamic):Dynamic {
		return (Std.isOfType(type, String)) ? type : noteTypesArray[type];
	}

    static function getList() {
        var typesSort = CoolUtil.getFileContent(Paths.txt("notetypes/types-sort", null)).split(",");
        var typesList = JsonUtil.getSubFolderJsonList('notetypes', [Song.formatSongFolder(PlayState?.SONG?.song ?? "")]);
        return CoolUtil.customSort(typesList, typesSort);
    }

    public static function initTypes():Void {
		noteTypesMap = new Map<String, NoteTypeJson>();
		noteTypesArray = [];
		for (type in getList()) {
			noteTypesArray.push(type);
            getTypeJson(type);
        }
	}

    public static function getTypeJson(type:String = 'default'):NoteTypeJson {
		if (noteTypesMap.exists(type)) return noteTypesMap.get(type);
		var typeJson:NoteTypeJson = JsonUtil.getJson(type, 'notetypes');
		typeJson = JsonUtil.checkJsonDefaults(DEFAULT_NOTE_TYPE, typeJson);
		noteTypesMap.set(type, typeJson);
		return typeJson;
	}

    public static function clearSkinCache() {
        for (skin => data in skinSpriteMap) {
            AssetManager.removeGraphicByKey(data.baseSprite.imageKey);
            #if !hl
            Preloader.disposeTexture(data.baseSprite.imageKey);
            #end
            data.baseSprite = FlxDestroyUtil.destroy(data.baseSprite);
            data.skinJson = null;
            skinSpriteMap.remove(skin);
        }
    }

    /*
     *  Setup the bitmaps for the sustains and the default note FlxSprite
     */

    public static var skinSpriteMap:Map<String, SkinSpriteData> = [];
    public static function setupSkinSprites(skin:String):SkinSpriteData {
        if (skinSpriteMap.exists(skin)) return skinSpriteMap.get(skin);
        var skinJson:NoteSkinData;
        try { // Prevent null skins
            skinJson = SkinUtil.getSkinData(skin).noteData;
        } catch(e) {
            skin = '_missing_skin';
            skinJson = SkinUtil.getSkinData(skin).noteData;
        }
        skinJson = JsonUtil.checkJsonDefaults(NoteUtil.DEFAULT_NOTE_SKIN, skinJson);

        final refSprite:FlxSpriteExt = new FlxSpriteExt();
        refSprite.loadImage('skins/$skin/${skinJson.imagePath}');
        refSprite.setScale(skinJson.scale);
        refSprite.antialiasing = skinJson.antialiasing ? Preferences.getPref("antialiasing") : false;
        for (anim in skinJson.anims)
            refSprite.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);

        if ((PlayState.instance != null) && (refSprite.frame != null)) {
            CoolUtil.cacheImage(refSprite.frame.parent, null, PlayState.instance.camHUD);
        }

        final addMap:SkinSpriteData = {
            baseSprite: refSprite,
            skinJson: skinJson
        }
        skinSpriteMap.set(skin, addMap);
        return addMap;
    }
    
    public static function getSkinSprites(skin:String):SkinSpriteData {
        if (!skinSpriteMap.exists(skin)) setupSkinSprites(skin);
        return skinSpriteMap.get(skin);
    }
}

typedef SkinSpriteData = {
    baseSprite:FlxSpriteExt,
    skinJson:NoteSkinData
}

typedef NoteRGB = {
    r:Array<Float>,
    g:Array<Float>,
    b:Array<Float>
}

class NoteAtlas {
    public static function createAtlas(frames:FlxFramesCollection, colors:Array<NoteRGB>) {
        // Color notes
        var coloredGraphics:Array<FlxGraphic> = [];
        for (rgb in colors) {
            var newBitmap = frames.parent.bitmap.clone();
            var graphic = FlxGraphic.fromBitmapData(applyColorFilter(newBitmap, rgb.r, rgb.g, rgb.b));
            coloredGraphics.push(graphic);
        }

        // Create atlas
        var atlasCollection:Array<FlxAtlasFrames> = [];
        for (_ in 0...coloredGraphics.length) {
            var newAtlas = new FlxAtlasFrames(coloredGraphics[_]);
            newAtlas.frames = frames.frames;
            
            for (frame in newAtlas.frames) {
                frame.parent = newAtlas.parent;
                
                var angle = cast(frame.angle, Int);
                angle += DEFAULT_NOTE_ANGLES[_];
                angle %= 360;
            }

            atlasCollection.push(newAtlas);
        }

        // Combine the atlas
        final newCollection = new FlxAtlasFrames(coloredGraphics[0]);
        for (atlas in atlasCollection) {
            newCollection.addAtlas(atlas);
        }

        return newCollection;
    }

    public static final DEFAULT_COLORS_INNER:Array<Array<Float>> = [[194,75,153],[0,255,255],[18,250,5],[249,57,63]];
    public static final DEFAULT_COLORS_RIM:Array<Array<Float>> = [[255,255,255],[255,255,255],[255,255,255],[255,255,255]];
    public static final DEFAULT_COLORS_OUTER:Array<Array<Float>> = [[60,31,86],[21,66,183],[10,68,71],[101,16,56]];
    public static final DEFAULT_NOTE_ANGLES:Array<Int>= [0, -90, 90, 180];

    static final _point = new openfl.geom.Point();

    public static function applyColorFilter(bitmap:BitmapData, red:Array<Float>, green:Array<Float>, blue:Array<Float>):BitmapData {
        bitmap.applyFilter(bitmap, bitmap.rect, _point, new openfl.filters.ColorMatrixFilter(getColorMatrix(red,green,blue)));
        return bitmap;
    }

    public static function getColorMatrix(r:Array<Float>, g:Array<Float>, b:Array<Float>):Array<Float> {
        for (i in 0...3) {
            r[i] /= 255;
            g[i] /= 255;
            b[i] /= 255;
        }

        return [
			r[0], g[0], b[0], 0, 0,
			r[1], g[1], b[1], 0, 0,
			r[2], g[2], b[2], 0, 0,
			0, 0, 0, 1, 0,
		];
    }
}