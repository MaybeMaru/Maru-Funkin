package funkin.util;

import funkin.util.modding.ScriptUtil;
import flixel.util.typeLimit.OneOfTwo;

typedef LayerKey = OneOfTwo<Bool, String>;
typedef Layer = TypedGroup<FlxObject>;

typedef StageObject = {
    var tag:String;
    var position:Array<Float>;
    var scrolls:Array<Float>;
    var flipY:Bool;
    var blend:String;
    var alpha:Float;
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

    var layersOrder:Array<String>;
    var layers:Dynamic;
}

class Stage extends TypedGroup<Layer> implements IMusicHit
{
    public static final DEFAULT_ORDER:Array<String> = [
        "bg",
        "gf", "dad", "bf",
        "fg"
    ];

    public static final DEFAULT_LAYERS:Dynamic = {
        bg: [],
        gf: [],
        dad: [],
        bf: [],
        fg: []
    }

    public static final DEFAULT_STAGE:StageJson = {
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

        layersOrder: DEFAULT_ORDER,
        layers: DEFAULT_LAYERS
    };

    public static final DEFAULT_OBJECT:StageObject = {
        tag: "coolswag",
        imagePath: "keoiki",
        position: [0,0],
        scrolls: [1,1],
        flipX: false,
        flipY: false,
        anims: [],
        scale: 1,
        blend: "normal",
        alpha: 1,
        antialiasing: true
    }

    public var layers:Map<String, Layer> = [];
    public var layersOrder:Array<String> = [];
    public var objects:Map<String, FlxObject> = [];
    public var data:StageJson;
    public var script:FunkScript;

    public function new() {
        super();
    }

    override function destroy() {
        super.destroy();

        layers = null;
        layersOrder = null;
        script = null;
        objects = null;
    }

    public static function getJson(stage:String):StageJson
    {
        var path = Paths.json('stages/$stage');

        if (Paths.exists(path, TEXT))
        {
            var data:StageJson = JsonUtil.getJson(stage, 'stages');
            data = JsonUtil.checkJsonDefaults(DEFAULT_STAGE, data);
            return data;
        }

        return DEFAULT_STAGE;
    }

    public static function fromJson(data:StageJson, ?script:FunkScript):Stage
    {
        var stage = new Stage();
        stage.script = script;
        stage.loadInput(data);
        return stage;
    }

    public function loadInput(input:StageJson):Stage
    {
        data = input;

        for (key in input.layersOrder)
        {
            var objects:Array<StageObject> = Reflect.field(input.layers, key);
            var layer = new Layer();
            
            if (objects != null) // Layer has objects
            {
                for (i in objects)
                {
                    var object = quickSprite(i);
                    addToLayer(layer, i.tag, object);
        
                    if (script != null)
                        script.set(i.tag, object);
                }
            }

            addLayer(layer, key);
        }

        return this;
    }

    public function applyData(bf:Character, dad:Character, gf:Character)
    {
        bf.stageOffsets.set(data.bfOffsets[0], data.bfOffsets[1]);
		dad.stageOffsets.set(data.dadOffsets[0], data.dadOffsets[1]);
		gf.stageOffsets.set(data.gfOffsets[0], data.gfOffsets[1]);

		bf.stageCamOffsets.set(data.bfCamOffsets[0], data.bfCamOffsets[1]);
		dad.stageCamOffsets.set(data.dadCamOffsets[0], data.dadCamOffsets[1]);
		gf.stageCamOffsets.set(data.gfCamOffsets[0], data.gfCamOffsets[1]);
    }

    // Creating the stage

    inline static function quickSprite(input:StageObject) {
        input = JsonUtil.checkJsonDefaults(DEFAULT_OBJECT, input);

        var sprite = new FunkinSprite(null, input.position, input.scrolls);
        sprite.loadJsonInput(JsonUtil.copyJson(input)); // Deal with it
        sprite.flipX = input.flipX;
        sprite.flipY = input.flipY;
        sprite.alpha = input.alpha;

        if (sprite.animOffsets.exists("loop"))
            sprite.playAnim("loop");

        if (input.blend != "normal")
            sprite.blend = ScriptUtil.stringToBlend(input.blend);
        
        return sprite;
    }

    // Layer util crap

    public function addToLayer(layer:Layer, ?tag:String, object:FlxObject) {
        tag ??= "";
        
        if (objects.exists(tag) && tag != "")
            ModdingUtil.warningPrint('Object with tag "$tag" is duplicated');
        
        layer.add(object);
        objects.set(tag, object);
    }

    public function insertToLayer(index:Int = 0, layer:Layer, ?tag:String, object:FlxObject) {
        tag ??= "";
        
        if (objects.exists(tag) && tag != "")
            ModdingUtil.warningPrint('Object with tag "$tag" is duplicated');
        
        layer.insert(index, object);
        objects.set(tag, object);
    }

    public function __existsAddToLayer(layerkey:LayerKey, object:FlxObject) {
        if (existsLayer(layerkey))
            getLayer(layerkey).add(object);
    }

    // TODO: improve this

    public function getObjectLayer(object:FlxObject) {
        for (key => layer in layers)
        {
            var index = layer.members.indexOf(object);
            if (index != -1)
                return layer;
        }
        return null;
    }

    public function getLayers():Array<Layer> {
        var array:Array<Layer> = [];

        layersOrder.fastForEach((layer, i) -> {
            final layer = getLayer(layer);
            if (layer != null)
                array.push(layer);
        });

        return array;
    }

    public function getLayer(key:LayerKey):Layer {
        return layers.get(__resolveLayerKey(key));
    }

    public function existsLayer(key:LayerKey):Bool {
        return layers.exists(__resolveLayerKey(key));
    }

    public function addLayer(layer:Layer, layerKey:LayerKey) {
        var tag = __resolveLayerKey(layerKey);
        
        if (layersOrder.contains(tag)) {
            ModdingUtil.warningPrint('Layer with tag "$tag" is duplicated');
            layersOrder.remove(tag);
        }
        
        layers.set(tag, layer);
        layersOrder.push(tag);
        add(layer);
    }

    public function removeLayer(layerKey:LayerKey) {
        layers.remove(__resolveLayerKey(layerKey));
        layersOrder.splice(getLayerIndex(layerKey), 1);
    }

    public function insertLayer(index:Int = 0, layer:Layer, layerKey:LayerKey) {
        var tag = __resolveLayerKey(layerKey);
        
        if (layersOrder.contains(tag)) {
            ModdingUtil.warningPrint('Layer with tag "$tag" is duplicated');
            layersOrder.remove(tag);
        }
        
        layers.set(tag, layer);
        layersOrder.insert(index, tag);
    }

    public function getLayerIndex(layerKey:LayerKey) {
        return layersOrder.indexOf(__resolveLayerKey(layerKey));
    }
    
    function __resolveLayerKey(key:LayerKey):String {
        return key is Bool ? (key ? "fg" : "bg") : key;
    }

    public function stepHit(curStep:Int):Void
    {

    }

    public function beatHit(curBeat:Int):Void
    {
        
    }

    public function sectionHit(curSection:Int):Void
    {
        
    }
}