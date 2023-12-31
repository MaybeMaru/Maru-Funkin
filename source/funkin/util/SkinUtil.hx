package funkin.util;
import openfl.utils.AssetType;

typedef NoteSkinData = {
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
		final skinJson:SkinJson = JsonUtil.getJson(skin, 'skins');
		return skinJson;
	}

    public static function getSkinData(?skin:String):SkinJson {
        skin = skin ?? curSkin;
        if (dataMap == null)
            initSkinData();
        else if (!dataMap.exists(skin))
            dataMap.set(skin, getSkinJsonData(skin));

        return dataMap.get(skin);
    }

    public static function getAssetKey(key:String, type:AssetType = IMAGE, ?skin:String) {
        skin = skin == null ? SkinUtil.curSkin : skin;
        final skinKey = 'skins/$skin/$key';
        final defaultSkinKey = 'skins/default/$key';

        final skinPath = Paths.getAssetPath(skinKey, type);
        return Paths.exists(skinPath, type) ? skinKey :  defaultSkinKey;
    }
}