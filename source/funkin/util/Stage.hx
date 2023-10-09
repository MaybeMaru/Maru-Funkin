package funkin.util;

import funkin.util.modding.ScriptUtil;

typedef StageObject = {
    var tag:String;
    var position:Array<Float>;
    var scrolls:Array<Float>;
    var flipY:Bool;
} & SpriteJson;

typedef StageJson = {
	var library:String;
    var zoom:Float;
    var skin:String;

	var gfOffsets:Array<Float>;
	var dadOffsets:Array<Float>;
	var bfOffsets:Array<Float>;

	var startCamOffsets:Array<Float>;
	var gfCamOffsets:Array<Float>;
	var dadCamOffsets:Array<Float>;
	var bfCamOffsets:Array<Float>;

    var layers:Dynamic;
}

class Stage {
    public static var DEFAULT_STAGE(default, never):StageJson = {
        library: "",
        skin: "default",
        zoom: 1.05,

        gfOffsets: [0,0],
        dadOffsets: [0,0],
        bfOffsets: [0,0],

        startCamOffsets: [0,0],
        gfCamOffsets: [0,0],
        dadCamOffsets: [0,0],
        bfCamOffsets: [0,0],

        layers: null,
    };

    public static function getJsonData(stage:String):StageJson {
        if (Paths.exists(Paths.json('stages/$stage'), TEXT)) {
            var stageJson:StageJson = JsonUtil.getJson(stage, 'stages');
            return JsonUtil.checkJsonDefaults(DEFAULT_STAGE, stageJson);
        }
        return DEFAULT_STAGE;
    }

    public static function createStageObjects(?_layers:Dynamic, ?script:FunkScript) {
        if (_layers == null) return;
        var layers = cast _layers;  

        for (layer in Reflect.fields(layers)) {
            var objects:Array<Dynamic> = cast Reflect.field(layers, layer);
            for (object in objects) {
                final objectTag = object.tag;
                var sprite = quickSprite(object);
                if (script != null) script.set(objectTag, sprite);
                ScriptUtil.addSprite(sprite, objectTag, layer == 'fg');
            }
        }
    }

    public static var DEFAULT_STAGE_OBJECT(default, never):StageObject = {
        tag: "coolswag",
        imagePath: "keoiki",
        position: [0,0],
        scrolls: [1,1],
        flipY: false,
        flipX: false,
        anims: [],
        scale: 1,
        antialiasing: true
    }

    static function quickSprite(input:StageObject) {
        input = JsonUtil.checkJsonDefaults(DEFAULT_STAGE_OBJECT, input);
        var sprite = new FunkinSprite("keoiki", input.position, input.scrolls);
        sprite.loadJsonInput(input);
        sprite.flipX = input.flipX;
        sprite.flipY = input.flipY;
        return sprite;
    }
}