package funkin.util;

import flixel.graphics.frames.FlxFrame;
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

        var spriteKey = 'skins/$skin/${skinJson.imagePath}';
        var refSprite:FlxSpriteExt = new FlxSpriteExt();
        refSprite.loadImage(spriteKey);
        refSprite.setScale(skinJson.scale);
        refSprite.antialiasing = skinJson.antialiasing ? Preferences.getPref("antialiasing") : false;
        for (anim in skinJson.anims)
            refSprite.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);

        if ((PlayState.instance != null) && (refSprite.frame != null)) {
            CoolUtil.cacheImage(refSprite.frame.parent, null, PlayState.instance.camHUD);
        }

        var skinData:SkinSpriteData = {
            baseSprite: refSprite,
            skinJson: skinJson
        }

        AssetManager.getAsset(Paths.png(spriteKey)).onDispose = () -> {
            if (skinData != null) {
                skinData.baseSprite = FlxDestroyUtil.destroy(skinData.baseSprite);
                skinData.skinJson = null;
                skinSpriteMap.remove(skin);
                skinData = null;
            }
        }

        skinSpriteMap.set(skin, skinData);
        return skinData;
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

enum NoteAtlasType {
    NOTE;
    SPLASH;
    STRUM;
}

class NoteAtlas {

    static final __calcMatrix:FlxMatrix = new FlxMatrix();

    // Creates a colored spritesheet with the forced 4 note colors
    public static function createBasicAtlas(frames:FlxFramesCollection, ?colors:Array<NoteRGB>, type:NoteAtlasType = NOTE) {
        if (colors == null)
            colors = DEFAULT_COLORS;
        
        final parent = frames.parent.bitmap;
        final bitmap:BitmapData = new BitmapData(parent.width * colors.length, parent.height, true, FlxColor.TRANSPARENT);

        // Create colored spritesheet
        for (i in 0...colors.length) {
            var rgb = colors[i];
            var colorBitmap = applyColorFilter(parent.clone(), rgb.r, rgb.g, rgb.b);

            __calcMatrix.setTo(1, 0, 0, 1, i * parent.width, 0);
            bitmap.draw(colorBitmap, __calcMatrix);

            colorBitmap.dispose();
        }
        
        // Store base frames
        var animationFrames:Map<String, Array<FlxFrame>> = switch (type) {
            case NOTE: [
                "note" => [],
                "piece" => [],
                "tail" => []
            ];
            case SPLASH: [
                "splash" => []
            ];
            case STRUM: [
                "press" => [],
                "confirm" => []
            ];
        }

        for (frame in frames.frames) {
            var frameName = frame.name.toLowerCase().trim();
            switch (type) {
                case NOTE:
                    if (frameName.contains("end")) animationFrames.get("tail").push(frame);
                    else if (frameName.contains("piece")) animationFrames.get("piece").push(frame);
                    else animationFrames.get("note").push(frame);
                case SPLASH:
                    animationFrames.get("splash").push(frame);
                case STRUM:
                    if (frameName.contains("confirm")) animationFrames.get("confirm").push(frame);
                    else if (frameName.contains("press")) animationFrames.get("press").push(frame);
            }
        }

        final graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
        var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);

        // Generate new frames
        for (i in 0...CoolUtil.directionArray.length) {
            var direction = CoolUtil.directionArray[i];

            for (key => keyFrames in animationFrames) {
                var frameIndex:Int = 0;
                for (_ in keyFrames) {
                    @:privateAccess
                    var frame = new FlxFrame(graphic);
                    _.copyTo(frame);

                    frame.parent = graphic;
                    frame.frame.x += parent.width * i;
                    frame.name = key + direction + CoolUtil.formatInt(frameIndex, 5);
                    frameIndex++;

                    if (key == "note" || type == STRUM)
                        frame.angle += DEFAULT_NOTE_ANGLES[i];

                    frames.pushFrame(frame);
                }
            }
        }
        
        return frames;
    }

    // Creates a colored spritesheet with the 4 note colors, strum static color and press color
    public static function createStrumAtlas(frames:FlxFramesCollection, ?colors:Array<NoteRGB>) {
        if (colors == null)
            colors = DEFAULT_COLORS;

        // Get bitmaps
        var parent = frames.parent;
        var coloredFrames = createBasicAtlas(frames, colors, STRUM);
        var coloredParent = coloredFrames.parent;

        // Draw uncolored bitmap
        var strumBitmap = new BitmapData(coloredParent.width + parent.width, coloredParent.height, true, FlxColor.TRANSPARENT);
        
        __calcMatrix.setTo(1, 0, 0, 1, 0, 0);
        strumBitmap.draw(coloredParent.bitmap, __calcMatrix);
        
        __calcMatrix.tx += coloredParent.width;
        strumBitmap.draw(parent.bitmap, __calcMatrix);

        // And replace old bitmap
        coloredParent.bitmap.dispose();
        coloredParent.bitmap.disposeImage();
        coloredParent.bitmap = strumBitmap;

        // TODO: add default frames and optimize the ammount of stuff needed to add on the bitmap

        return strumBitmap;
    }

    public static final DEFAULT_COLORS_INNER:Array<Array<Float>> = [[194,75,153],[0,255,255],[18,250,5],[249,57,63]];
    public static final DEFAULT_COLORS_RIM:Array<Array<Float>> = [[255,255,255],[255,255,255],[255,255,255],[255,255,255]];
    public static final DEFAULT_COLORS_OUTER:Array<Array<Float>> = [[60,31,86],[21,66,183],[10,68,71],[101,16,56]];
    public static final DEFAULT_NOTE_ANGLES:Array<Int>= [0, -90, 90, 180];

    public static final DEFAULT_COLORS:Array<NoteRGB> = [
        {r: DEFAULT_COLORS_INNER[0], g:DEFAULT_COLORS_RIM[0], b:DEFAULT_COLORS_OUTER[0]},
        {r: DEFAULT_COLORS_INNER[1], g:DEFAULT_COLORS_RIM[1], b:DEFAULT_COLORS_OUTER[1]},
        {r: DEFAULT_COLORS_INNER[2], g:DEFAULT_COLORS_RIM[2], b:DEFAULT_COLORS_OUTER[2]},
        {r: DEFAULT_COLORS_INNER[3], g:DEFAULT_COLORS_RIM[3], b:DEFAULT_COLORS_OUTER[3]}
    ];

    static final _point = new openfl.geom.Point();

    public static function applyColorFilter(bitmap:BitmapData, red:Array<Float>, green:Array<Float>, blue:Array<Float>):BitmapData {
        bitmap.applyFilter(bitmap, bitmap.rect, _point, new openfl.filters.ColorMatrixFilter(getColorMatrix(red,green,blue)));
        return bitmap;
    }

    public static function getColorMatrix(r:Array<Float>, g:Array<Float>, b:Array<Float>):Array<Float> {
        for (i in 0...3) {
            r[i] *= FlxColorFix.COLOR_DIV;
            g[i] *= FlxColorFix.COLOR_DIV;
            b[i] *= FlxColorFix.COLOR_DIV;
        }

        return [
			r[0], g[0], b[0], 0, 0,
			r[1], g[1], b[1], 0, 0,
			r[2], g[2], b[2], 0, 0,
			0, 0, 0, 1, 0,
		];
    }
}