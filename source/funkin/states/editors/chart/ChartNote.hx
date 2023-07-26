package funkin.states.editors.chart;

class ChartNote extends Note {

    public function new() {
        super();
        scrollFactor.set(1,1);
    }

    public var gridNoteData:Int = 0;

    public function init(_time, _data, _xPos, _yPos, _sus, _skin, _mustPress, forceSus = false, ?_parent:Note, _sec:Int) {
        strumTime = _time;
        noteData = _data % Conductor.NOTE_DATA_LENGTH;
        gridNoteData = _data;
        isSustainNote = forceSus;
        mustPress = _mustPress;
        _skin = _skin == null ? SkinUtil.curSkin : _skin;
        skin = _skin;

        alpha = isSustainNote ? 0.6 : 1;
        setPosition(_xPos, _yPos);
        createGraphic(false);
        updateHitbox();

        if (isSustainNote) {
            var _scale = _parent.scale.x;
            scale.set(_scale,_scale);
            updateHitbox();
            
            var _height = Math.floor(((FlxMath.remapToRange(_sus, 0, Conductor.stepCrochet * 16, 0, ChartingState.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH)) + ChartingState.GRID_SIZE / 2) / _scale);
            drawSustain(true, _height);
            updateHitbox();
            offset.x -= ChartingState.GRID_SIZE / 2 - width / 2.125;
            offset.y -= ChartingState.GRID_SIZE / 2;
        } else {
            setGraphicSize(ChartingState.GRID_SIZE,ChartingState.GRID_SIZE);
            updateHitbox();
        }

        if (_sec == 1) color = FlxColor.WHITE;
        else {
            color = FlxColor.fromRGB(150,150,150);
            alpha *= 0.3;
        }
    }
}