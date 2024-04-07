package funkin.states.newchart;

class ChartStrumLine extends SpriteGroup
{
    public function new(X:Float) {
        super(X);

        for (i in 0...8) {
            var strum = new NoteStrum(i * 40, 0, i % 4);
            strum.alpha = 0.8;
            strum.setGraphicSize(40, 40);
            strum.updateHitbox();
            add(strum);
        }
    }
}