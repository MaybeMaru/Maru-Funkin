package funkin.states.editors.stage;

class LayersBar extends Group
{
    var data:StageJson;

    public function new(data:StageJson) {
        super();
        
        var bar = new FlxSpriteExt(FlxG.width).makeRect(300, FlxG.height, FlxColor.BLACK);
        bar.alpha = 0.6;
        bar.x -= bar.width;
        add(bar);

        this.data = data;

        data.layersOrder.fastForEach((layer, i) -> {
            var dropDown = new LayerDropDown(layer, Reflect.field(data.layers, layer), i);
            dropDown.setPosition(bar.x, 10 + i * 50);
            add(dropDown);
        });
    }
}

class LayerDropDown extends FlxSpriteGroup
{
    public function new(layerName:String, layerData:Null<Array<StageObject>>, id:Int)
    {
        super();

        this.ID = id;

        //var bar = new FlxSpriteExt(FlxG.width).makeRect(300, 50, FlxColor.BLACK);
        //bar.x -= bar.width;
        //add(bar);

        var arrow = new FlxSpriteExt().loadImage("ui/arrow");
        arrow.setScale(1.5);
        add(arrow);

        var length = layerData != null ? layerData.length : 0;
        var layerText = layerName + ' ($length ${length == 1 ? 'Object' : 'Objects'})';

        var text = new FlxFunkText(arrow.width + 5, 2.5, layerText, FlxPoint.weak(300, 50));
        add(text);
    }
}