package funkin.states.editors;

import funkin.substates.PromptSubstate;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUICheckBox;
import openfl.net.FileReference;
import funkin.states.editors.chart.ChartTabs;
import funkin.states.editors.chart.ChartNote;
import flixel.util.FlxStringUtil;
import funkin.states.editors.chart.ChartGrid;

class ChartingState extends MusicBeatState {
    public static var SONG:SwagSong;
    public static var autoSaveChart:String;
    public static var instance:ChartingState = null;
    public var sectionIndex:Int = 0;

    public var bg:FunkinSprite;
    public var noteTile:FlxSprite;
    public var strumBar:FlxSprite;
    public var songTxt:FunkinText;
    public var tabs:ChartTabs;
    public var mainGrid:ChartGrid;

    public var camTop:SwagCamera;
    
    override function create() {
        instance = this;
        autoSaveChart = SaveData.getSave('autoSaveChart');
        bg = new FunkinSprite('menuDesat', [0,0], [0,0]);
		bg.color = 0xFF242424;
        bg.setScale(1.1);
		bg.screenCenter();
        bg._dynamic.update = function (elapsed) {
            if (bg.scale.x <= 1.11) return;
            bg.scale.set(
                CoolUtil.coolLerp(bg.scale.x, 1.1, 0.25),
                CoolUtil.coolLerp(bg.scale.y, 1.1, 0.25));
        }
		add(bg);

        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        FlxG.mouse.visible = true;

        camTop = new SwagCamera(); camTop.bgColor.alpha = 0;
        FlxG.cameras.add(camTop, false);
        
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

        tabs = new ChartTabs();
        tabs.setPosition(songTxt.x, songTxt.y + FlxG.height * 0.25);
        add(tabs);

        for (i in [songTxt, tabs]) i.scrollFactor.set();
        changeSection();

        super.create();
    }

    function checkNoteSound() {
        var gray = FlxColor.fromRGB(180,150,180);
        mainGrid.notesGroup.forEachAlive(function (note:ChartNote) {
            if (note.strumTime + 0.1 <= Conductor.songPosition) {
                if (note.color == FlxColor.WHITE && playing && tabs.check_hitsound.checked) CoolUtil.playSound('chart/hitclick');
                note.color = gray;
                if (note.childNote != null) note.childNote.color = gray;
            }
            else {
                note.color = FlxColor.WHITE;
                if (note.childNote != null) note.childNote.color = FlxColor.WHITE;
            }
        });
    }

    function checkBPM(updateSec:Bool = false) {  // Check for BPM changes
        var lastChange:BPMChangeEvent = Conductor.getLastBpmChange(Conductor.songPosition, SONG.bpm);
		if (Conductor.bpm != lastChange.bpm) {
            Conductor.bpm = lastChange.bpm;
            if (updateSec) changeSection();
        }
    }

    public function changeSection(change:Int = 0) {
        sectionIndex = Std.int(FlxMath.bound(sectionIndex + change, 0, SONG.notes.length - 1));
        if (change > 0) deselectNote();
        Conductor.songPosition = getSecTime(sectionIndex);
        Conductor.autoSync();
        if (SONG.notes[sectionIndex] == null) SONG.notes[sectionIndex] = Song.getDefaultSection(); // Make new section
        checkBPM();
        mainGrid.setData(SONG.notes[sectionIndex], sectionIndex);
        updateBar();
        updateSectionTabUI();
    }

    override function beatHit() {
        super.beatHit();
        if (playing && tabs.check_metronome.checked) {
            CoolUtil.playSound('chart/metronome_tick');
			var scaleMult:Float = (curBeat % Conductor.BEATS_LENGTH == 0) ? 1.25 : 1.15;
			bg.scale.set(scaleMult,scaleMult);
        }
    }

    public function updateIcons() {
        
    }

    public function updateSectionTabUI():Void {
		var sec = SONG.notes[sectionIndex];
        if (sec == null) return;
		tabs.check_mustHitSection.checked = sec.mustHitSection;
		tabs.check_changeBPM.checked = sec.changeBPM;
		tabs.stepperSectionBPM.value = sec.bpm;
        updateIcons();
	}

    public function updateNoteTabUI():Void {
        if (selectedNote == null || selectedNoteObject == null) return;
        tabs.stepperSusLength.value = selectedNote[2];
    }

    var playing:Bool = false;
    public function play() {
        playing = true;
        Conductor.play();
        Conductor.sync();
        checkBPM(true);
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
            autosaveSong();
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

    public var selectedNote:Array<Dynamic> = null;
    public var selectedNoteObject(default, set):ChartNote = null;
    function set_selectedNoteObject(value) {
        if (value != null && selectedNoteObject != null && value != selectedNoteObject) {
            value.blend = ADD;
            selectedNoteObject.blend = NORMAL;
        }
        else if (value == null && selectedNoteObject != null) selectedNoteObject.blend = NORMAL;
        else if (value != null && selectedNoteObject == null) value.blend = ADD;
        return selectedNoteObject = value;
    }

    public function addNote() {
        var strumTime:Float = getYtime(noteTile.y) + getSecTime(sectionIndex) - Conductor.stepCrochet;
        var noteData:Int = Math.floor((noteTile.x - mainGrid.grid.x) / ChartGrid.GRID_SIZE);
        var note:Array<Dynamic> = [strumTime, noteData, 0, ChartTabs.curType];
        SONG.notes[sectionIndex].sectionNotes.push(note);
        selectedNote = note;
        selectedNoteObject = mainGrid.drawNote(note);
    }

    public function removeNote(note:ChartNote) {
        var data = mainGrid.getNoteData(note);
        if (data == selectedNote || note == selectedNoteObject) {
            deselectNote();
        }
        SONG.notes[sectionIndex].sectionNotes.remove(data);
        mainGrid.clearNote(note);
    }

    public function changeNoteSus(value:Float = 0) {
        if (selectedNote == null || selectedNoteObject == null) return;
        selectedNote[2] = (selectedNote[2] == null ? 0 : selectedNote[2]);
        selectedNote[2] = Math.max(selectedNote[2] + value, 0);
        mainGrid.updateNote(selectedNoteObject, selectedNote);
        updateNoteTabUI();
    }

    function updateSelectedNote() {
        if (selectedNote == null || selectedNoteObject == null) return;
        mainGrid.updateNote(selectedNoteObject, selectedNote);
    }

    public function clearSongNotes() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear this song notes?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            for (i in SONG.notes) i.sectionNotes = [];
            clearSectionData();
        }));
    }

    public function clearSongFull() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear this song?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            for (i in SONG.notes) {
                i.sectionNotes = [];
                i.sectionEvents = [];
                i.mustHitSection = false;
                i.changeBPM = false;
                i.bpm = 0;
            }
            clearSectionData();
            updateSectionTabUI();
        }));
    }

    public function clearSectionData() {
        SONG.notes[sectionIndex].sectionNotes = [];
        deselectNote();
        mainGrid.clearSection();
    }

    function deselectNote() {
        selectedNote = null;
        selectedNoteObject = null;
    }

    public function copyLastSection(change:Int = 1):Void {
        var copyData = SONG.notes[sectionIndex - change];
        if (copyData == null || change == 0) return;
        for (i in copyData.sectionNotes) {
            var note:Array<Dynamic> = [i[0], i[1], i[2], i[3]]; // Make sure to not reuse it?? clone() don work :cries:
            note[0] += Conductor.stepCrochet * (Conductor.STEPS_SECTION_LENGTH * change);
            SONG.notes[sectionIndex].sectionNotes.push(note);
            mainGrid.drawNote(note);
        } 
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        updatePosition();
        checkNoteSound();
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

    public function loadJson(song:String):Void {
		PlayState.SONG = Song.loadFromFile(PlayState.curDifficulty, song);
		PlayState.SONG = Song.checkSong(PlayState.SONG);
		FlxG.resetState();
	}

    public function loadAutosave():Void {
		PlayState.SONG = Song.checkSong(Song.parseJson('', autoSaveChart));
		FlxG.resetState();
	}

    public function autosaveSong():Void {
		SONG = Song.checkSong(SONG);
		autoSaveChart = getSongString();
		SaveData.setSave('autoSaveChart', autoSaveChart);
		SaveData.flushData();
	}

    public function getSongString(_:Null<String> = null) {
		return Json.stringify({
			"song": Song.optimizeJson(SONG)
		}, _);
	}

    public function saveChart() {
        SONG = Song.checkSong(SONG);
		var data:String = getSongString("\t");
		if (data.length > 0) {
			var chartFile:FileReference = new FileReference();
			chartFile.save(data.trim(), '${PlayState.curDifficulty}.json');
		}
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					SONG.notes[sectionIndex].mustHitSection = check.checked;
					updateIcons();
				case 'Change BPM':
					SONG.notes[sectionIndex].changeBPM = check.checked;
					Conductor.mapBPMChanges(ChartingState.SONG);
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch (wname) {
				case 'song_speed': SONG.speed = nums.value;
				case 'song_bpm':
					Conductor.mapBPMChanges(SONG);
					Conductor.bpm = nums.value;
				case 'song_inst_offset':
					var tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[0] = tempOffset;
					SONG.offsets[0] = tempOffset;
				case 'song_vocals_offset':
					var tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[1] = tempOffset;
					SONG.offsets[1] = tempOffset;
				case 'note_susLength':
					selectedNote[2] = nums.value;
					updateSelectedNote();
				case 'section_bpm':
                    Conductor.mapBPMChanges(ChartingState.SONG);
					SONG.notes[sectionIndex].bpm = Std.int(nums.value);
                    changeSection();
				case 'stepper_copy': //updatePreview();
			}
		}
	}
}