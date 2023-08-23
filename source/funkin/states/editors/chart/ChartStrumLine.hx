package funkin.states.editors.chart;

class ChartStrumLine extends FlxTypedSpriteGroup<Dynamic> {
    
    var strums:Array<NoteStrum> = [];
    
    public function new() {
        super();
        for (i in 0...Conductor.STRUMS_LENGTH) {
            var strum = new NoteStrum(i * ChartGrid.GRID_SIZE, 0, i % Conductor.NOTE_DATA_LENGTH);
            strum.alpha = 0.6;
            strum.setGraphicSize(ChartGrid.GRID_SIZE,ChartGrid.GRID_SIZE);
            strum.updateHitbox();
            strums.push(strum);
            add(strum);
        }
    }

    public function pressStrum(data:Int = 0) {
        var isStatic = strums[data].animation.curAnim.name.startsWith('static');
        isStatic ? strums[data].playStrumAnim("confirm", true) : strums[data].animation.curAnim.curFrame = 0;
        strums[data].staticTime = Conductor.stepCrochetMills;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}