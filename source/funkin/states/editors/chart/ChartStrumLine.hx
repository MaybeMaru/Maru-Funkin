package funkin.states.editors.chart;

class ChartStrumLine extends FlxTypedSpriteGroup<Dynamic> {
    
    var strums:Array<NoteStrum> = [];

    var iconP1:HealthIcon;
    var iconP2:HealthIcon;
    
    public function new() {
        super();
        for (i in 0...Conductor.STRUMS_LENGTH) {
            var strum = new NoteStrum(i * ChartGrid.GRID_SIZE, 0, i % Conductor.NOTE_DATA_LENGTH);
            strum.alpha = 0.8;
            strum.setGraphicSize(ChartGrid.GRID_SIZE,ChartGrid.GRID_SIZE);
            strum.updateHitbox();
            strums.push(strum);
            add(strum);
        }

        iconP1 = new HealthIcon("bf");
        iconP2= new HealthIcon("dad");
        add(iconP1);
        add(iconP2);
        updateWithData();
    }

    var midX = ChartGrid.GRID_SIZE * 2;

    // Caching shit
    var charIcons:Map<String, String> = [];
    private function getCharIcon(char:String = "bf") {
        if (charIcons.exists(char)) return charIcons.get(char);
        var ico = Character.getCharData(char).icon;
        charIcons.set(char, ico);
        return ico;
    }

    public function updateWithData() {
        var sectionData = ChartingState.SONG.notes[ChartingState.instance.sectionIndex];
        if (sectionData == null) return;
        updateHeads(getCharIcon(ChartingState.SONG.players[0]), getCharIcon(ChartingState.SONG.players[1]), sectionData.mustHitSection);
    }

    public function updateHeads(p1:String = "bf", p2:String = "dad", mustHit:Bool = true) {
        iconP1.makeIcon(p1);
        iconP2.makeIcon(p2);

        for (i in [iconP1, iconP2]) {
            i.scrollFactor.set(1,1);
            i.scale.set(0.4,0.4);
            i.updateHitbox();
        }

        iconP1.setPosition(x + (midX - (iconP1.width * 0.5)) + (mustHit ? 0 : midX * 2), y - 60);
        iconP2.setPosition(x + (midX - (iconP2.width * 0.5)) + (mustHit ? midX * 2 : 0), y - 60);
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