package funkin.substates;

import funkin.objects.NotesGroup;

class NotesSubstate extends MusicBeatSubstate {
    
    public var SONG:SwagSong;
    public var notesGroup:NotesGroup;
    public var position:Float = 0;

    public function new(_SONG:SwagSong, position:Float) {
        super();
        this.position = position;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

        SONG = Song.checkSong(_SONG);
        notesGroup = new NotesGroup(SONG, false);
        notesGroup.skipStrumIntro = true;
        notesGroup.init(position - 50);
        Conductor.sync();
        add(notesGroup);

        var lastStep = 0;

        var txt:FunkinText = new FunkinText(0, FlxG.height * (Preferences.getPref('downscroll') ? 0.1 : 0.8), "coolswag", 25, 0, "center");
        txt._dynamic.update = function (elapsed) {
            var curStep = Math.floor((Conductor.songPosition - Conductor.settingOffset) / Conductor.stepCrochet);
            if (curStep != lastStep)  Conductor.autoSync();
            lastStep = curStep;
            var curBeat = Math.floor(curStep / Conductor.STEPS_PER_BEAT);
            var curSection = Math.floor(curBeat / Conductor.BEATS_PER_MEASURE);
            txt.text = 'Song Position: ${Math.floor(Conductor.songPosition)}\nCurrent Step: $curStep\nCurrent Beat: $curBeat\nCurrent Section: $curSection';
            txt.screenCenter(X);
        }
        add(txt);

        cameras = [CoolUtil.getTopCam()];
    }

    var tmr:Float = 0.333;
    override function update(elapsed:Float) {
        super.update(elapsed);
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