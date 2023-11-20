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

    public static inline function applyData(data:StageJson, bf:Character, dad:Character, gf:Character) {
        bf.stageOffsets.set(data.bfOffsets[0], data.bfOffsets[1]);
		dad.stageOffsets.set(data.dadOffsets[0], data.dadOffsets[1]);
		gf.stageOffsets.set(data.gfOffsets[0], data.gfOffsets[1]);

		bf.stageCamOffsets.set(data.bfCamOffsets[0], data.bfCamOffsets[1]);
		dad.stageCamOffsets.set(data.dadCamOffsets[0], data.dadCamOffsets[1]);
		gf.stageCamOffsets.set(data.gfCamOffsets[0], data.gfCamOffsets[1]);
    }

    public static function createStageObjects(?_layers:Dynamic, ?script:FunkScript, ?groups:Map<String, SpriteLayer>) {
        if (_layers == null) return;
        final layers = cast _layers;  

        for (layer in Reflect.fields(layers)) {
            final objects:Array<Dynamic> = cast Reflect.field(layers, layer);
            for (i in objects) {
                final object:StageObject = i;
                final sprite = quickSprite(object);
                if (script != null) script.set(object.tag, sprite);
                final group = groups?.get(layer) ?? layer;
                ScriptUtil.addSprite(sprite, object.tag, group).tag = ScriptUtil.formatSpriteKey(object.tag, group);
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
        final sprite = new FunkinSprite("keoiki", input.position, input.scrolls);
        sprite.loadJsonInput(JsonUtil.copyJson(input));
        sprite.flipX = input.flipX;
        sprite.flipY = input.flipY;
        return sprite;
    }
}