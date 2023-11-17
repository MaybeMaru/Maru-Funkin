package funkin.states.editors;

class StageDebug extends MusicBeatState {
    var stageData:StageJson;
    var camFollow:FlxObject;
    
    public function new(stageData:StageJson) {
        super();
        this.stageData = stageData;
    }
    
    override function create() {
        super.create();
        camFollow = new FlxObject();
        FlxG.camera.follow(camFollow);
        FlxG.mouse.visible = true;
        Stage.createStageObjects(stageData.layers, null);
    }
    
    final speed = 50;

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        final moveX = FlxG.keys.pressed.A ? -speed : FlxG.keys.pressed.D ? speed : 0;
        final moveY = FlxG.keys.pressed.W ? -speed : FlxG.keys.pressed.S ? speed : 0;
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