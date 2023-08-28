package funkin.states.editors.chart;

class ChartNote extends Note {

    public function new() {
        super();
        scrollFactor.set(1,1);
        active = false;
    }

    public var gridNoteData:Int = 0;
    public var txt:FunkinText = null;
    public var startInit:Bool = false;

    function getQuantSusOff(quant:Int):Float {
        //return 0.5 + 0.05 * (16 - quant);
        //return 1.5 * Math.pow(0.5, (32 - quant) / 8);
        //return 1.5 * Math.pow(0.5, 32 / quant);
        return 4 / Math.pow(2, quant / 8);
    }

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

            /*
            32 => 1.5
            24 => 1
            16 => 0.5
            12 => 0.3
            8 => 0

            32 => 0.66666
            24 => 1
            16 => 2
            12 => 3.33333
            8 => 1
            */

            //trace(ChartingState.getYtime(ChartGrid.GRID_SIZE * 0.5));
            //trace();
            //trace((ChartGrid.GRID_SIZE * 0.5) * (16 / ChartingState.getQuant()));

            var _off = ChartingState.getTimeY(Conductor.stepCrochet * 0.5);
            trace(_off);
            var _height = Math.floor(((FlxMath.remapToRange(_sus, 0, Conductor.stepCrochet * Conductor.STEPS_SECTION_LENGTH, 0, ChartGrid.GRID_SIZE * ChartingState.getQuant())) + _off) / _scale);
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