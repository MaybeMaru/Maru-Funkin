package funkin.states.editors;

class StageDebug extends MusicBeatState {
    public function new(stageData:StageJson) {
        super();
        Stage.createStageObjects(stageData.layers, null);
    }
    
    override function create() {
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}