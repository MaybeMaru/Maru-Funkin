package funkin.substates;

import flixel.text.FlxBitmapText;
import funkin.objects.NotesGroup;

class NotesSubstate extends MusicBeatSubstate
{
    public var SONG:SongJson;
    public var notesGroup:NotesGroup;
    public var position:Float = 0;
    public var stats:FlxBitmapText;

    public function new(song:SongJson, position:Float)
    {
        super(true, 0x98000000);
        this.position = position;

        //SONG = Song.checkSong(song);
        SONG = song;
        notesGroup = new NotesGroup(SONG, false);
        notesGroup.skipStrumIntro = true;
        notesGroup.init(position - 50);
        Conductor.sync();
        add(notesGroup);

        stats = new FlxBitmapText(0, FlxG.height * (Preferences.getPref('downscroll') ? 0.05 : 0.8));
        stats.antialiasing = false;
        stats.scale.set(3,3);
        stats.updateHitbox();
        stats.alignment = CENTER;
        add(stats);

        camera = CoolUtil.getTopCam();
    }

    override function stepHit(curStep:Int) {
        super.stepHit(curStep);
        Conductor.autoSync();
    }

    override function sectionHit(curSection:Int) {
        super.sectionHit(curSection);
        final curSectionData = SONG.notes[curSection];
        if (curSectionData != null && curSectionData.changeBPM && curSectionData.bpm != Conductor.bpm) {
			Conductor.bpm = curSectionData.bpm;
		}
    }

    var tmr:Float = 0.333;
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        stats.text =
        'Song Position: ${Math.floor(Conductor.songPosition)}\n'+
        'Current Step: $curStep\n'+
        'Current Beat: $curBeat\n'+
        'Current Section: $curSection\n\n'+
        'Current BPM: ${Conductor.bpm}';

        stats.screenCenter(X);
        
        if (tmr > 0) tmr -= elapsed;
        else {
            if (FlxG.keys.justPressed.ESCAPE || Conductor.songPosition >= Conductor.inst.length) {
                Conductor.songPosition = position;
                Conductor.stop();
                close();
            }
        }

    }
}