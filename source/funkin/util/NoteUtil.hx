package funkin.util;

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
	public static var swagHeight:Float = 155 * 0.7;

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
        var typesList = JsonUtil.getSubFolderJsonList('notetypes', [PlayState.SONG != null ? PlayState.SONG.song : ""]);
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

    public static function clearSustainCache() {
        skinSpriteMap.clear();
        for (key in Paths.cachedGraphics.keys()) {
            if (key.startsWith('sus')) Paths.removeGraphicByKey(key);
        }
        for (key in Preloader.cachedTextures.keys()) {
            if (key.startsWith('sus'))
                Preloader.disposeTexture(key);
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

        var refSprite:FlxSpriteExt = new FlxSpriteExt();
        refSprite.loadImage('skins/$skin/${skinJson.imagePath}', false, false);
        refSprite.scale.set(skinJson.scale,skinJson.scale);
        refSprite.updateHitbox();
        for (anim in skinJson.anims)
            refSprite.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);

        var susPieceMap:Map<String, BitmapData> = [];
        var susEndMap:Map<String, BitmapData> = [];

        if (Paths.existsGraphic('sus-bitmap-$skin-hold-LEFT')) { // Skip loading base sustain flxsprite
            for (i in CoolUtil.directionArray) {
                susPieceMap.set(i, Paths.getGraphic('sus-bitmap-$skin-hold-$i').bitmap);
                susEndMap.set(i,Paths.getGraphic('sus-bitmap-$skin-holdend-$i').bitmap);
            }
        }
        else {
            var susPiece = new FlxSprite().loadGraphicFromSprite(refSprite);
            var susEnd = new FlxSprite().loadGraphicFromSprite(refSprite);

            for (i in CoolUtil.directionArray) {
                susPiece.animation.play('hold$i', true);
                susPiece.updateHitbox();
                susPiece.drawFrame();
                //susPieceMap.set(i, createLoopBitmap(susPiece.framePixels.clone(), 'sus-bitmap-$skin-hold-$i'));
                susPieceMap.set(i, Paths.addGraphicFromBitmap(susPiece.framePixels.clone(), 'sus-bitmap-$skin-hold-$i', true).bitmap);
    
                susEnd.animation.play('hold$i-end', true);
                susEnd.updateHitbox();
                susEnd.drawFrame();
                susEndMap.set(i, Paths.addGraphicFromBitmap(susEnd.framePixels.clone(), 'sus-bitmap-$skin-holdend-$i', true).bitmap);
            }
    
            // Wont need these anymore
            susPiece.destroy();
            susEnd.destroy();
        }

        var addMap:SkinSpriteData = {
            baseSprite: refSprite,
            susPieces: susPieceMap,
            susEnds: susEndMap,
            skinJson: skinJson
        }
        skinSpriteMap.set(skin, addMap);
        return addMap;
    }

    /*
     *  Save on calculations????
     */

    /*static function createLoopBitmap(input:BitmapData, key:String):BitmapData { // Wont use until i fix clipping bitmaps
        var loops:Int = Std.int(Math.max(input.height/12, 1));
        var loopedBitmap:BitmapData = new BitmapData(input.width, input.height*loops, true, FlxColor.fromRGB(0,0,0,0));
        for (i in 0...loops) {
           var matrix:FlxMatrix = new FlxMatrix();
           matrix.translate(0, i*input.height);
           loopedBitmap.draw(input, matrix);
        }
        input.dispose();
        input.disposeImage();
        return Paths.addGraphicFromBitmap(loopedBitmap, key, true).bitmap;
    }*/
    
    public static function getSkinSprites(skin:String, noteData:Int = 0):SkinMapData {
        if (!skinSpriteMap.exists(skin)) setupSkinSprites(skin);
        var dir = CoolUtil.directionArray[noteData];
        var spriteData:SkinSpriteData = skinSpriteMap.get(skin);
        return {
            baseSprite: spriteData.baseSprite,
            susPiece: spriteData.susPieces.get(dir),
            susEnd: spriteData.susEnds.get(dir),
            skinJson: spriteData.skinJson
        }
    }

    public static var DEFAULT_COLORS_INNER:Array<Array<Float>> = [[194,75,153],[0,255,255],[18,250,5],[249,57,63]];
    public static var DEFAULT_COLORS_RIM:Array<Array<Float>> = [[255,255,255],[255,255,255],[255,255,255],[255,255,255]];
    public static var DEFAULT_COLORS_OUTER:Array<Array<Float>> = [[60,31,86],[21,66,183],[10,68,71],[101,16,56]];

    public static function applyColorFilter(sprite:FlxSprite, red:Array<Float>, green:Array<Float>, blue:Array<Float>) {
        sprite.pixels.applyFilter(sprite.pixels, sprite.pixels.rect, new openfl.geom.Point(),
		new openfl.filters.ColorMatrixFilter(getColorMatrix(red,green,blue)));
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

typedef SkinMapData = {
    baseSprite:FlxSpriteExt,
    susPiece:BitmapData,
    susEnd:BitmapData,
    skinJson:NoteSkinData
}

typedef SkinSpriteData = {
    baseSprite:FlxSpriteExt,
    susPieces:Map<String, BitmapData>,
    susEnds:Map<String, BitmapData>,
    skinJson:NoteSkinData
}