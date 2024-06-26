package funkin.util;
import openfl.utils.AssetType;

typedef NoteSkinData = SpriteJson & {
    var ?noteColorArray:Array<String>;
}

typedef SkinJson = SpriteJson & {
    var noteData:NoteSkinData;
    var strumData:SpriteJson;
    var splashData:SpriteJson;
}

class SkinUtil
{
    public static var curSkin:String = 'default';
    public static var curSkinData:SkinJson;
    public static var dataMap:Map<String, SkinJson>;

    public static function initSkinData():Void //  Cache skin data
    {
        dataMap = [];
        JsonUtil.getJsonList('skins').fastForEach((skin, i) -> dataMap.set(skin, getSkinJsonData(skin)));
        setCurSkin();
    }

    inline public static function setCurSkin(skin:String = 'default'):Void {
        curSkinData = getSkinData(skin);
        curSkin = skin;
    }

    inline public static function getSkinAssets(skin:String = "default"):Array<LoadImage>
    {
        var assets:Array<LoadImage> = [];
        var data = getSkinData(skin);

        assets.push({path: getAssetKey(data.noteData.imagePath, IMAGE, skin), lod: data.noteData.allowLod ? DEFAULT : HIGH});
        assets.push({path: getAssetKey(data.strumData.imagePath, IMAGE, skin), lod: data.strumData.allowLod ? DEFAULT : HIGH});
        assets.push({path: getAssetKey(data.splashData.imagePath, IMAGE, skin), lod: data.splashData.allowLod ? DEFAULT : HIGH});

        // TODO: add other skin assets here too
        
        return assets;
    }

    inline public static function getSkinJsonData(skin:String = 'default'):SkinJson {
		return JsonUtil.getJson(skin, 'skins');
	}

    public static function getSkinData(?skin:String):SkinJson {
        if (skin == null || skin.length <= 0)
            skin = curSkin;
        
        if (dataMap == null)                initSkinData();
        else if (!dataMap.exists(skin))     dataMap.set(skin, getSkinJsonData(skin));

        return dataMap.get(skin);
    }

    public static function getAssetKey(key:String, type:AssetType = IMAGE, ?skin:String):String
    {
        if (skin == null || skin.length <= 0)
            skin = curSkin;
        
        var skinKey:String = 'skins/$skin/$key';

        final skinPath = Paths.getAssetPath(skinKey, type);
        return Paths.exists(skinPath, type) ? skinKey :  'skins/default/$key';
    }
}