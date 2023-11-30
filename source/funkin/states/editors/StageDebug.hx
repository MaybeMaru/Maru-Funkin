package funkin.states.editors;

import funkin.objects.ui.FunkButton;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

typedef LayerGroup = FlxTypedGroup<Dynamic>;

class StageDebug extends MusicBeatState {
    var stageData:StageJson;
    var camFollow:FlxObject;
    
    public function new(stageData:StageJson) {
        super();
        this.stageData = stageData;
    }
    
    override function create() {
        super.create();
        camFollow = new FlxObject(FlxG.width*0.5, FlxG.height*0.5);
        FlxG.camera.follow(camFollow);
        FlxG.mouse.visible = true;

        final gridBG:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.create(20, 20, 40*16, 40*16, true, 0xff7c7c7c,0xff6e6e6e).pixels);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

        final bgGroup = new LayerGroup(); bgGroup.ID = 0;
        add(bgGroup);

        /// Characters

        final __dad = new FunkinSprite("options/bf_offset", [100, 450]);
        __dad.alpha = 0.4;
        add(__dad);

        final __bf = new FunkinSprite("options/bf_offset", [770, 450]);
        __bf.flipX = true;
        __bf.alpha = 0.4;
        add(__bf);

        /// Characters

        final fgGroup = new LayerGroup(); fgGroup.ID = 1;
        add(fgGroup);

        // TODO add a better layer system you big goof
        Stage.createStageObjects(stageData.layers, null, ["bg" => bgGroup, "fg" => fgGroup]);

        //add(new FunkButton(50,50));
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