package funkin.states.editors.chart;

class ChartNote extends Note {

    public function new() {
        super();
        scrollFactor.set(1,1);
        susEndHeight = 0;
        active = false;
    }

    public var gridNoteData:Int = 0;
    public var txt:FunkinText = null;
    public var startInit:Bool = false;

    public function init(_time, _data, _xPos, _yPos, _sus, _skin, forceSus = false, ?_parent:Note) {
        strumTime = _time;
        noteData = _data % Conductor.NOTE_DATA_LENGTH;
        gridNoteData = _data;
        isSustainNote = forceSus;
        _skin = _skin == null ? SkinUtil.curSkin : _skin;
        txt = null;

        alpha = isSustainNote ? 0.6 : 1;
        setPosition(_xPos, _yPos);
        if (skin != _skin || !startInit) {
            skin = _skin;
            createGraphic(false);
            startInit = true;
        } else updateAnims();
        updateHitbox();

        if (isSustainNote) {
            var _scale = _parent.scale.x;
            scale.set(_scale,_scale);
            updateHitbox();
            
            var _off = ChartingState.getYtime(ChartGrid.GRID_SIZE * 0.5);
            var _height = Math.floor(((FlxMath.remapToRange(_sus + _off, 0, Conductor.stepCrochet * Conductor.STEPS_PER_MEASURE, 0, ChartGrid.GRID_SIZE * Conductor.STEPS_PER_MEASURE))/* + ChartGrid.GRID_SIZE / 2*/) / _scale);
            drawSustainCached(_height);
            updateHitbox();
            offset.x -= ChartGrid.GRID_SIZE / 2 - width / 2.125;
            offset.y -= ChartGrid.GRID_SIZE / 2;
        } else {
            setGraphicSize(ChartGrid.GRID_SIZE,ChartGrid.GRID_SIZE);
            updateHitbox();
        }
    }
}