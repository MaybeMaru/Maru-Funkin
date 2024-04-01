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

    public static function initSkinData():Void //  Cache skin data
    {
        dataMap = new Map<String, SkinJson>();
        JsonUtil.getJsonList('skins').fastForEach((skin, i) -> dataMap.set(skin, getSkinJsonData(skin)));
        setCurSkin();
    }

    inline public static function setCurSkin(skin:String = 'default'):Void {
        curSkinData = getSkinData(skin);
        curSkin = skin;
    }

    inline public static function getSkinJsonData(skin:String = 'default'):SkinJson {
		return JsonUtil.getJson(skin, 'skins');
	}

    public static function getSkinData(skin:String = ""):SkinJson {
        if (skin.length <= 0)
            skin = curSkin;
        
        if (dataMap == null)                initSkinData();
        else if (!dataMap.exists(skin))     dataMap.set(skin, getSkinJsonData(skin));

        return dataMap.get(skin);
    }

    public static function getAssetKey(key:String, type:AssetType = IMAGE, skin:String = ""):String
    {
        if (skin.length <= 0)
            skin = curSkin;
        
        var skinKey:String = 'skins/$skin/$key';
        var defaultSkinKey:String = 'skins/default/$key';

        final skinPath = Paths.getAssetPath(skinKey, type);
        return Paths.exists(skinPath, type) ? skinKey :  defaultSkinKey;
    }
}