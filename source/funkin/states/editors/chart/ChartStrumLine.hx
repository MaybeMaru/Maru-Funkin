package funkin.states.editors.chart;

import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;

class ChartStrumLine extends SpriteGroup
{
    var strums:Array<NoteStrum> = [];
    var eventBar:FlxSprite;

    var iconP1:HealthIcon;
    var iconP2:HealthIcon;
    
    public function new() {
        super();
        for (i in 0...Conductor.STRUMS_LENGTH) {
            var strum = new NoteStrum(i * GRID_SIZE, 0, i % Conductor.NOTE_DATA_LENGTH);
            strum.alpha = 0.8;
            strum.setGraphicSize(GRID_SIZE, GRID_SIZE);
            strum.getWidth(); // recalculate this because fuck shit ass fuck fuck crap ass
            strums.push(strum);
            add(strum);
        }

        eventBar = new FlxSprite(-GRID_SIZE * 1.5, 0).makeGraphic(1,1);
        eventBar.antialiasing = false;
        eventBar.scale.set(GRID_SIZE, 4);
        eventBar.updateHitbox();
        add(eventBar);

        iconP1 = new HealthIcon("bf");
        iconP2 = new HealthIcon("dad");
        
        add(iconP1);
        add(iconP2);
        
        updateWithData();
    }

    static final midX = GRID_SIZE * 2;

    // Caching shit
    var charIcons:Map<String, String> = [];
    private function getCharIcon(char:String = "bf") {
        if (charIcons.exists(char)) return charIcons.get(char);
        var icon = Character.getCharData(char).icon;
        charIcons.set(char, icon);
        return icon;
    }

    public function updateWithData() {
        var sectionData = ChartingState.instance.notes[ChartingState.sectionIndex];
        if (sectionData == null) return;
        updateHeads(getCharIcon(ChartingState.SONG.players[0]), getCharIcon(ChartingState.SONG.players[1]), sectionData.mustHitSection);
    }

    public function updateHeads(p1:String = "bf", p2:String = "dad", mustHit:Bool = true) {
        iconP1.makeIcon(p1);
        iconP2.makeIcon(p2);

        for (i in [iconP1, iconP2]) {
            i.scrollFactor.set(1, 1);
            i.scale.set(0.4, 0.4);
            i.updateHitbox();
        }

        iconP1.setPosition(x + (midX - (iconP1.width * 0.5)) + (mustHit ? 0 : midX * 2), y - iconP1.height);
        iconP2.setPosition(x + (midX - (iconP2.width * 0.5)) + (mustHit ? midX * 2 : 0), y - iconP2.height);
    }

    public function pressStrum(data:Int = 0) {
        data %= Conductor.STRUMS_LENGTH;
        var strum = strums[data];
        if (strum == null) return;

        var isConfirm = (strum.animation.curAnim != null && strum.animation.curAnim.name.startsWith('confirm'));
        isConfirm ? strum.animation.curAnim.curFrame = 0 : strum.playStrumAnim("confirm", true);
        strum.staticTime = Conductor.stepCrochetMills;
    }
}