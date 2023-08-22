package funkin.util;

// TODO stage json thing
typedef StageProject = {
    var layers:Array<StageLayer>;
    var zoom:Float;
    var scripts:Array<String>;
}

typedef StageLayer = {
    var order:Int;
    var objects:Array<StageObject>;
    var camera:String;
}

typedef StageObject = {
    var order:Int;
    var position:Array<Float>;
    var scrolls:Array<Float>;
    var flipY:Bool;
} & SpriteJson;

typedef StageJson = {
	var library:String;
    var skin:String;

	var gfOffsets:Array<Float>;
	var dadOffsets:Array<Float>;
	var bfOffsets:Array<Float>;

	var startCamOffsets:Array<Float>;
	var gfCamOffsets:Array<Float>;
	var dadCamOffsets:Array<Float>;
	var bfCamOffsets:Array<Float>;
}

class Stage {
    public var curStage:String = 'stage';
    public static var defaultStage:StageJson = {
        library: "",
        skin: "default",

        gfOffsets: [0,0],
        dadOffsets: [0,0],
        bfOffsets: [0,0],

        startCamOffsets: [0,0],
        gfCamOffsets: [0,0],
        dadCamOffsets: [0,0],
        bfCamOffsets: [0,0],
    };

    public static function getJsonData(stage:String):StageJson {
        if (Paths.exists(Paths.json('stages/$stage'), TEXT)) {
            var stageJson:StageJson = JsonUtil.getJson(stage, 'stages');
            return JsonUtil.checkJsonDefaults(defaultStage, stageJson);
        }
        return defaultStage;
    }
}