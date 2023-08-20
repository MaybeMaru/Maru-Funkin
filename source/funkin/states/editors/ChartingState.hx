package funkin.states.editors;

import funkin.states.editors.chart.ChartNote;
import flixel.util.FlxStringUtil;
import funkin.states.editors.chart.ChartGrid;

class ChartingState extends MusicBeatState {
    public static var SONG:SwagSong;
    public var sectionIndex:Int = 0;

    var bg:FunkinSprite;
    var noteTile:FlxSprite;
    var strumBar:FlxSprite;
    var songTxt:FunkinText;
    var mainGrid:ChartGrid;

    var camHUD:SwagCamera;
    
    override function create() {
        super.create();
        bg = new FunkinSprite('menuDesat', [0,0], [0,0]);
		bg.color = 0xFF242424;
        bg.setScale(1.1);
		bg.screenCenter();
		add(bg);

        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        FlxG.mouse.visible = true;

        camHUD = new SwagCamera(); camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD, false);
        
        SONG = Song.checkSong(PlayState.SONG);
        Conductor.bpm = SONG.bpm;
        Conductor.loadMusic(SONG.song);
        Conductor.mapBPMChanges(SONG);
		Conductor.songOffset = SONG.offsets;
        Conductor.stop();

        mainGrid = new ChartGrid();
        add(mainGrid);

        noteTile = new FlxSprite().makeGraphic(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE, FlxColor.fromRGB(255,255,255,180));
        noteTile._dynamic.update = function (elapsed) {
            if (ChartGrid.getGridOverlap(FlxG.mouse, mainGrid.grid)) { // display dummy arrow
                noteTile.visible = true;
                noteTile.x = Math.floor(FlxG.mouse.x / ChartGrid.GRID_SIZE) * ChartGrid.GRID_SIZE;
                noteTile.y = (FlxG.keys.pressed.SHIFT) ? FlxG.mouse.y : Math.floor(FlxG.mouse.y / ChartGrid.GRID_SIZE) * ChartGrid.GRID_SIZE;
            } else {
                noteTile.visible = false;
            }
        }
        add(noteTile);

        strumBar = new FlxSprite(mainGrid.grid.x, mainGrid.grid.y).makeGraphic(Std.int(mainGrid.grid.width), 4, FlxColor.WHITE);
        add(strumBar);

        songTxt = new FunkinText(mainGrid.grid.x + mainGrid.grid.width + 25, mainGrid.grid.y, "coolswag", 25);
        songTxt._dynamic.update = function (elapsed) {
            var info =  "Time: " + FlxStringUtil.formatTime(Conductor.songPosition / 1000, true) + " / " + FlxStringUtil.formatTime(Conductor.inst.length / 1000, true) + "\n" +
                        "Step: " + Math.max(0, curStep) + "\n" +
                        "Beat: " + Math.max(0, curBeat) + "\n" +
                        "Section: " + Math.max(0, curSection) + "\n\n" +
                        "Position: " + Math.floor(Conductor.songPosition) + "\n" +
                        "BPM: " + Conductor.bpm;
            songTxt.text = info;
        }
        add(songTxt);

        for (i in [songTxt]) i.cameras = [camHUD];

        changeSection();
    }

    function checkBPM() {
        var lastChange:BPMChangeEvent = Conductor.getLastBpmChange();
		if (Conductor.bpm != lastChange.bpm) Conductor.bpm = lastChange.bpm;
    }

    public function changeSection(change:Int = 0) {
        sectionIndex = Std.int(FlxMath.bound(sectionIndex + change, 0, SONG.notes.length - 1));
        Conductor.songPosition = getSecTime(sectionIndex);
        Conductor.autoSync();
        checkBPM();
        mainGrid.setData(SONG.notes[sectionIndex], sectionIndex);
        updateBar();
    }

    var playing:Bool = false;
    public function play() {
        playing = true;
        Conductor.play();
        Conductor.sync();
    }

    public function stop() {
        playing = false;
        Conductor.stop();
        Conductor.sync();
    }

    function moveTime(elapsed:Float = 0) {
        Conductor.songPosition += elapsed * 1000; // Advance time
        if (Conductor.songPosition >= getSecTime(sectionIndex + 1)) changeSection(1); // Go to next section
        if (getTimeY(Conductor.songPosition - getSecTime(sectionIndex)) < 0 && sectionIndex > 0) { // Go to prev section
            changeSection(-1);
            Conductor.songPosition = getSecTime(sectionIndex + 1) - 1;
            Conductor.autoSync();
        }
        if (Conductor.songPosition > Conductor.inst.length) { // End song
            Conductor.songPosition = Conductor.inst.length;
            stop();
            changeSection();
        }
        Conductor.songPosition = FlxMath.bound(Conductor.songPosition, 0, Conductor.inst.length); // Stay between bounds
        updateBar();
    }

    function updatePosition() {
        if (!playing) return;
        moveTime(FlxG.elapsed);
    }

    function updateBar() {
        var yPos = getTimeY(Conductor.songPosition - getSecTime(sectionIndex));
        strumBar.y = mainGrid.grid.y + yPos;
        FlxG.camera.scroll.y = yPos - FlxG.height * 0.333;
    }

    function keys() {
        if (FlxG.keys.justPressed.SPACE) {
            playing ? stop() : play();
        }

        if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.A || FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
            stop();
            var mult = (FlxG.keys.pressed.SHIFT ? 4 : 1);
            if (FlxG.keys.justPressed.D) changeSection(1 * mult);
            if (FlxG.keys.justPressed.A) changeSection(-1 * mult);
            if (FlxG.keys.pressed.W) moveTime(-FlxG.elapsed* mult);
            if (FlxG.keys.pressed.S) moveTime(FlxG.elapsed* mult);
        }

        if (FlxG.keys.justPressed.E || FlxG.keys.justPressed.Q) {
            if (FlxG.keys.justPressed.E) changeNoteSus(Conductor.stepCrochet);
            if (FlxG.keys.justPressed.Q) changeNoteSus(-Conductor.stepCrochet );
        }

        if (FlxG.keys.justPressed.ENTER) {
            PlayState.SONG = SONG;
            Conductor.stop();
            Conductor.setPitch(1, false);
			FlxG.switchState(new PlayState());
        }
    }

    function mouse() {
        if (!ChartGrid.getGridOverlap(FlxG.mouse, mainGrid.grid)) return;
        if (FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(mainGrid.notesGroup)) { // Remove notes
                mainGrid.notesGroup.forEachAlive(function (note:ChartNote) {
                    if (FlxG.mouse.overlaps(note)) removeNote(note);
                });
            } else { // Add notes
                addNote();
            }
        }
    }

    var selectedNote:Array<Dynamic> = null;
    var selectedNoteObject:ChartNote = null;

    function addNote() {
        var strumTime:Float = getYtime(noteTile.y) + getSecTime(sectionIndex) - Conductor.stepCrochet;
        var noteData:Int = Math.floor((noteTile.x - mainGrid.grid.x) / ChartGrid.GRID_SIZE);
        var note:Array<Dynamic> = [strumTime, noteData];
        SONG.notes[sectionIndex].sectionNotes.push(note);
        selectedNote = note;
        selectedNoteObject = mainGrid.drawNote(note);
    }

    function removeNote(note:ChartNote) {
        var data = mainGrid.getNoteData(note);
        if (data == selectedNote || note == selectedNoteObject) {
            selectedNote = null;
            selectedNoteObject = null;
        }
        SONG.notes[sectionIndex].sectionNotes.remove(data);
        mainGrid.clearNote(note);
    }

    function changeNoteSus(value:Float = 0) {
        if (selectedNote == null || selectedNoteObject == null) return;
        selectedNote[2] = (selectedNote[2] == null ? 0 : selectedNote[2]);
        selectedNote[2] = Math.max(selectedNote[2] + value, 0);
        mainGrid.updateNote(selectedNoteObject, selectedNote);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        updatePosition();
        keys();
        mouse();
    }

    override function stepHit() {
        super.stepHit();
        if (playing) {
            Conductor.autoSync();
        }
    }

    public static inline function getTimeY(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, Conductor.STEPS_SECTION_LENGTH * Conductor.stepCrochet, 0, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH);
	}

    public static inline function getYtime(y:Float):Float {
        return FlxMath.remapToRange(y, 0, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, 0, Conductor.STEPS_SECTION_LENGTH * Conductor.stepCrochet);
    }

    public static inline function getSecTime(index:Int = 0) {
        var BPM:Float = SONG.bpm;
        var time:Float = 0;
        for (i in 0...index) {
            if (SONG.notes[i].changeBPM) BPM = SONG.notes[i].bpm;
			time += Conductor.BEATS_LENGTH * (1000 * 60 / BPM);
        }
        return time;
    }
}