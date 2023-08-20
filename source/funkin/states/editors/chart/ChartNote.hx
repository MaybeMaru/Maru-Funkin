package funkin.states.editors.chart;

class ChartNote extends Note {

    public function new() {
        super();
        scrollFactor.set(1,1);
    }

    public var gridNoteData:Int = 0;
    public var txt:FunkinText = null;

    public function init(_time, _data, _xPos, _yPos, _sus, _skin, forceSus = false, ?_parent:Note) {
        strumTime = _time;
        noteData = _data % Conductor.NOTE_DATA_LENGTH;
        gridNoteData = _data;
        isSustainNote = forceSus;
        _skin = _skin == null ? SkinUtil.curSkin : _skin;
        txt = null;
        skin = _skin;

        alpha = isSustainNote ? 0.6 : 1;
        setPosition(_xPos, _yPos);
        createGraphic(false);
        updateHitbox();

        if (isSustainNote) {
            var _scale = _parent.scale.x;
            scale.set(_scale,_scale);
            updateHitbox();
            
            var _height = Math.floor(((FlxMath.remapToRange(_sus, 0, Conductor.stepCrochet * 16, 0, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH)) + ChartGrid.GRID_SIZE / 2) / _scale);
            drawSustain(true, _height);
            updateHitbox();
            offset.x -= ChartGrid.GRID_SIZE / 2 - width / 2.125;
            offset.y -= ChartGrid.GRID_SIZE / 2;
        } else {
            setGraphicSize(ChartGrid.GRID_SIZE,ChartGrid.GRID_SIZE);
            updateHitbox();
        }
    }
}