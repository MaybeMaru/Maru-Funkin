package funkin.util;

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
    }

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
        for (anim in skinJson.anims) refSprite.addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);

        var susPiece = new FlxSprite().loadGraphicFromSprite(refSprite);
        var susEnd = new FlxSprite().loadGraphicFromSprite(refSprite);

        var addMap:SkinSpriteData = {
            baseSprite: refSprite,
            susPiece: susPiece,
            susEnd: susEnd,
            skinJson: skinJson
        }
        skinSpriteMap.set(skin, addMap);
        return addMap;
    }
    
    public static function getSkinSprites(skin:String, noteData:Int = 0) {
        var dir = CoolUtil.directionArray[noteData];
        if (!skinSpriteMap.exists(skin)) setupSkinSprites(skin);
        var mapData:SkinSpriteData = skinSpriteMap.get(skin);
        mapData.susPiece.animation.play('hold$dir', true);
        mapData.susPiece.updateHitbox();
        mapData.susEnd.animation.play('hold$dir-end', true);
        mapData.susEnd.updateHitbox();
        return mapData;
    }
}

typedef SkinSpriteData = {
    baseSprite:FlxSpriteExt,
    susPiece:FlxSprite,
    susEnd:FlxSprite,
    skinJson:NoteSkinData
}