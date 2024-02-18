package funkin.states.editors;

import funkin.objects.FunkCamera;
import funkin.states.editors.stage.LayersBar;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class StageDebug extends MusicBeatState {
    var stageData:StageJson;
    var camFollow:FlxObject;
    
    public function new(stageData:StageJson) {
        super();
        this.stageData = stageData;
    }

    var camStage:FunkCamera;
    var camUI:FunkCamera;
    
    override function create() {
        super.create();
        
        camStage = new FunkCamera();
        camUI = new FunkCamera();
        
        camUI.bgColor.alpha = 0;
        FlxG.cameras.remove(FlxG.camera);
        FlxG.camera = camStage;

        FlxG.cameras.add(camStage, false);
		FlxG.cameras.add(camUI);
		FlxG.cameras.setDefaultDrawTarget(camUI, true);
        
        camFollow = new FlxObject(FlxG.width*0.5, FlxG.height*0.5);
        camStage.follow(camFollow);
        FlxG.mouse.visible = true;

        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.create(20, 20, 40*16, 40*16, true, 0xff7c7c7c,0xff6e6e6e).pixels);
        grid.camera = camStage;
		add(grid);

        // Characters

        var dadOff = stageData.dadOffsets;
        var bfOff = stageData.bfOffsets;

        var dad = new FunkinSprite("options/bf_offset", [100 - dadOff[0], 450 - dadOff[1]]);
        dad.alpha = 0.4;

        var bf = new FunkinSprite("options/bf_offset", [770 - bfOff[0], 450 - bfOff[1]]);
        bf.flipX = true;
        bf.alpha = 0.4;

        // Stage

        var stage = Stage.fromJson(stageData);
        stage.camera = camStage;
        add(stage);
        
        if (stage.existsLayer("dad"))
            stage.getLayer("dad").add(dad);

        if (stage.existsLayer("bf"))
            stage.getLayer("bf").add(bf);

        camStage.zoom = stageData.zoom;

        addUI();
    }

    function addUI()
    {
        var layersBar = new LayersBar(stageData);
        add(layersBar);
    }
    
    var speed = 50;

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        var moveX = FlxG.keys.pressed.A ? -speed : FlxG.keys.pressed.D ? speed : 0;
        var moveY = FlxG.keys.pressed.W ? -speed : FlxG.keys.pressed.S ? speed : 0;
        camFollow.x += moveX * elapsed * 10;
        camFollow.y += moveY * elapsed * 10;

        if (FlxG.keys.pressed.E)	FlxG.camera.zoom += 0.01 * FlxG.camera.zoom;
        if (FlxG.keys.pressed.Q)	FlxG.camera.zoom -= 0.01 * FlxG.camera.zoom;
        FlxG.camera.zoom = FlxMath.bound(FlxG.camera.zoom, 0.25, 10);

        if (FlxG.keys.justPressed.ENTER){
            switchState(new PlayState());
        }
    }
}