package funkin.util;

typedef NoteSkinData = {
    var ?sustainScaleOffset:Float;
    var ?noteColorArray:Array<String>;
} & SpriteJson

typedef SkinJson = {
    var noteData:NoteSkinData;
    var strumData:SpriteJson;
    var splashData:SpriteJson;
} & SpriteJson

class SkinUtil {
    public static var curSkin:String = 'default';
    public static var curSkinData:SkinJson = null;
    public static var dataMap:Map<String, SkinJson>;

    inline public static function initSkinData():Void { //  Cache skin data
        dataMap = new Map<String, SkinJson>();

        for (skin in JsonUtil.getJsonList('skins')) {
            dataMap.set(skin, getSkinJsonData(skin));
        }
        setCurSkin();
    }

    inline public static function setCurSkin(skin:String = 'default'):Void {
        curSkinData = getSkinData(skin);
        curSkin = skin;
    }

    inline public static function getSkinJsonData(skin:String = 'default'):SkinJson {
		var skinJson:SkinJson = JsonUtil.getJson(skin, 'skins');
		return skinJson;
	}

    inline public static function getSkinData(?skin:String):SkinJson {
        skin = (skin != null) ? skin : curSkin;
        if (dataMap == null) {
            initSkinData();
        }
        else if (dataMap.get(skin) == null) {
            dataMap.set(skin, getSkinJsonData(skin));
        }
        return dataMap.get(skin);
    }
}