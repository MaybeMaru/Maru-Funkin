package funkin.states.editors;

import flixel.util.FlxArrayUtil;
import funkin.states.editors.chart.ChartStrumLine;
import funkin.substates.NotesSubstate;
import funkin.substates.PromptSubstate;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
import openfl.net.FileReference;
import funkin.states.editors.chart.ChartTabs;
import flixel.util.FlxStringUtil;

import funkin.states.editors.chart.ChartGridBase;
import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;
import funkin.states.editors.chart.ChartGridBase.getGridOverlap;
import funkin.states.editors.chart.ChartGridBase.getGridCoords;
import funkin.states.editors.chart.ChartGridBase.ChartNoteGrid;
import funkin.states.editors.chart.ChartGridBase.ChartEventGrid;

class ChartingState extends MusicBeatState {
    public static var SONG:SwagSong;
    public static var autoSaveChart:String;
    public static var instance:ChartingState = null;
    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;
    public var nextSectionTime:Float = 0;

    public static var lastSection:Int = 0;
    public static var lastSong:String = "";

    public var bg:FunkinSprite;
    public var noteTile:FlxSprite;
    public var strumBar:ChartStrumLine;
    public var songTxt:FlxFunkText;
    public var tabs:ChartTabs;

    public var mainGrid:ChartNoteGrid;
    public var eventsGrid:ChartEventGrid;

    public var camTop:FlxCamera;
    public var instStr:String = "";

    public function loadMusic(value:String) {
        Conductor.loadMusic(value);
        instStr = FlxStringUtil.formatTime(Conductor.inst.length * 0.001, true);
    }
    
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

        NoteUtil.initTypes();
        EventUtil.initEvents();

        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        PlayState.inChartEditor = true;
        FlxG.mouse.visible = true;

        camTop = new FlxCamera(); camTop.bgColor.alpha = 0;
        FlxG.cameras.add(camTop, false);
        
        SONG = Song.checkSong(PlayState.SONG);
        Conductor.bpm = SONG.bpm;
        Conductor.setTimeSignature(4,4);
        loadMusic(SONG.song);
        Conductor.mapBPMChanges(SONG);
		Conductor.songOffset = SONG.offsets;
        Conductor.volume = 1;
        stop();

        mainGrid = new ChartNoteGrid();
        add(mainGrid);

        eventsGrid = new ChartEventGrid();
        add(eventsGrid);

        noteTile = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE, FlxColor.WHITE);
        noteTile.alpha = 0.6;
        add(noteTile);

        strumBar = new ChartStrumLine();
        strumBar.setPosition(mainGrid.grid.x, mainGrid.grid.y);
        add(strumBar);

        final _grid = mainGrid.grid;
        songTxt = new FlxFunkText(_grid.x + _grid.width + 25, _grid.y + 25, "swag", FlxPoint.get(FlxG.width*0.5,FlxG.height*0.5), 25);
        songTxt._dynamic.update = function (elapsed) {
            songTxt.text =  "Time: " + FlxStringUtil.formatTime(Conductor.songPosition * 0.001, true) + " / " + instStr + "\n" +
                            "Step: " + Math.max(0, curStep) + "\n" +
                            "Beat: " + Math.max(0, curBeat) + "\n" +
                            "Section: " + Math.max(0, curSection) + "\n\n" +
                            "Position: " + Math.floor(Conductor.songPosition) + "\n" +
                            "BPM: " + Conductor.bpm;
        }
        add(songTxt);

        tabs = new ChartTabs();
        tabs.setPosition(songTxt.x, songTxt.y + FlxG.height * 0.25);
        tabs.runPost();
        add(tabs);

        for (i in [songTxt, tabs]) i.scrollFactor.set();

        
        if (SONG.song != lastSong) {
            lastSection = 0;
            lastSong = SONG.song;
        }
        setSection(lastSection, true);

        super.create();
    }

    static final PRESSED_COLOR:Int = 0xffb496b4;

    inline function checkNoteSound() {
        mainGrid.objectsGroup.forEachAlive(function (note:ChartNote) {
            if (note.strumTime + 0.1 <= Conductor.songPosition && note.strumTime + 0.1 >= sectionTime) {
                if (note.color == FlxColor.WHITE) {
                    strumBar.pressStrum(note.gridNoteData);
                    if (playing && tabs.check_hitsound.checked) CoolUtil.playSound('chart/hitclick', 1, 1);
                } 
                note.color = PRESSED_COLOR;
                if (note.child != null) note.child.color = PRESSED_COLOR;
            }
            else {
                note.color = FlxColor.WHITE;
                if (note.child != null) note.child.color = FlxColor.WHITE;
            }
        });

        mainGrid.sustainsGroup.forEachAlive(function (sustain:ChartSustain) {
            final note = sustain?.chartParent?.chartData;
            if (note != null && Conductor.songPosition >= note[0] && Conductor.songPosition <= note[0] + (Conductor.stepCrochet * .5) + note[2]) {
                strumBar.pressStrum(note[1]);
            }
        });

        eventsGrid.group.forEachAlive(function (event:ChartEvent) {
            if (event.strumTime + 0.1 <= Conductor.songPosition) event.color = PRESSED_COLOR;
            else event.color = FlxColor.WHITE;
        });
    }

    function checkBPM(updateSec:Bool = false) {  // Check for BPM changes
        var lastChange:BPMChangeEvent = Conductor.getLastBpmChange(Conductor.songPosition, SONG.bpm);
		if (Conductor.bpm != lastChange.bpm) {
            Conductor.bpm = lastChange.bpm;
            if (updateSec) changeSection();
        }
    }

    function bpmPositionCheck(newPosition:Float = 0) {
        Conductor.songPosition = newPosition; // Bpm conductor crap
        Conductor.autoSync();
        checkBPM();
        updateBar();
    }

    public function changeSection(change:Int = 0) {
        final newIndex = Std.int(Math.max(sectionIndex + change, 0));
        setSection(newIndex);
    }

    public function setSection(newIndex:Int = 0, forced:Bool = false) {
        if (!forced && sectionIndex == newIndex) { // Same section, doesnt need update
            bpmPositionCheck(sectionTime);
            return; 
        }

        deselectNote();
        deselectEvent();
        Song.checkAddSections(SONG, newIndex, sectionIndex);  // Check for null new sections
        sectionIndex = newIndex;
        sectionTime = getSecTime(sectionIndex);
        nextSectionTime = getSecTime(sectionIndex + 1);

        if (sectionTime >= Conductor.inst.length) {  // Set song bounds
            setSection(Song.getTimeSection(SONG, Conductor.inst.length));
            stop();
            return;
        }
        
        bpmPositionCheck(sectionTime);

        // Change visual stuff
        mainGrid.setData(sectionIndex); 
        mainGrid.updateWaveform();
        eventsGrid.setData(sectionIndex);
        updateSectionTabUI();
    }

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);
        if (playing && tabs.check_metronome.checked) {
            CoolUtil.playSound('chart/metronome_tick', 1, 1);
			var scaleMult:Float = (curBeat % Conductor.BEATS_PER_MEASURE == 0) ? 1.25 : 1.15;
			bg.scale.set(scaleMult,scaleMult);
        }
    }

    public function updateIcons() {
        strumBar.updateWithData();
    }

    public function updateSectionTabUI():Void {
        final sec = SONG.notes[sectionIndex];
        if (sec == null) return;
		tabs.check_mustHitSection.checked = sec.mustHitSection;
		tabs.check_changeBPM.checked = sec.changeBPM;
		tabs.stepperSectionBPM.value = sec.bpm;
        tabs.updatePreview();
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
        if (Conductor.songPosition >= nextSectionTime) changeSection(1); // Go to next section
        if (getTimeY(Conductor.songPosition - sectionTime) < 0 && sectionIndex > 0) { // Go to prev section
            changeSection(-1);
            Conductor.songPosition = nextSectionTime - 1;
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

    inline function updatePosition() {
        if (playing) moveTime(FlxG.elapsed);
    }

    inline function updateBar() {
        final yPos = getTimeY(Conductor.songPosition - sectionTime);
        strumBar.y = yPos;
        FlxG.camera.scroll.y = yPos - FlxG.height * 0.333;
    }

    function openTestSubstate() {
        stop();
        Conductor.songPitch = 1;
		Conductor.setPitch(1, false);
		openSubState(new NotesSubstate(SONG, Conductor.songPosition));
    }

    override function closeSubState() {
        super.closeSubState();
        tabs.songPitch = tabs.slider_pitch.value;
    }

    inline function keys() {
        if (FlxG.keys.justPressed.SPACE) {
            playing ? stop() : play();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
			openTestSubstate();
			return;
		}

        if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.A || FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
            stop();
            final mult = (FlxG.keys.pressed.SHIFT ? 4 : 1);
            if (FlxG.keys.justPressed.D) changeSection(1 * mult);
            if (FlxG.keys.justPressed.A) changeSection(-1 * mult);
            if (FlxG.keys.pressed.W) moveTime(-FlxG.elapsed * mult / FlxG.timeScale);
            if (FlxG.keys.pressed.S) moveTime(FlxG.elapsed * mult / FlxG.timeScale);
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
			switchState(new PlayState());
        }
    }

    inline function mouse() {
        final eventsOverlap = getGridOverlap(FlxG.mouse, eventsGrid.grid);
        if (!getGridOverlap(FlxG.mouse, mainGrid.grid) && !eventsOverlap) return;

        final clickL = FlxG.mouse.justPressed;
        final clickR = FlxG.mouse.justPressedRight;

        if (clickL || clickR) {
            if (!eventsOverlap) {
                if (FlxG.mouse.overlaps(mainGrid.objectsGroup)) { // Remove notes
                    mainGrid.objectsGroup.forEachAlive(function (note:ChartNote) {
                        if (note.strumTime < sectionTime) return;
                        if (FlxG.mouse.overlaps(note)) clickL ? removeNote(note) : selectNote(note);
                    });
                } else if (clickL) addNote(); // Add notes
            }
            else {
                var _overlap:Bool = false; // It is what it is
                for (i in eventsGrid.group) {
                    if (i.alive && i.strumTime >= sectionTime && FlxG.mouse.overlaps(i.sprite)) {
                        _overlap = true;
                        clickL ? removeEvent(i) : selectEvent(i); // Remove events
                        break;
                    }
                }
                if (!_overlap && clickL) addEvent(); // Add events
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
        trace(noteTile);
        final strumTime:Float = getYtime(noteTile.y + GRID_SIZE) + sectionTime - Conductor.stepCrochet;
        final noteData:Int = Math.floor((noteTile.x - mainGrid.grid.x) / GRID_SIZE);
        final note:Array<Dynamic> = [strumTime, noteData, 0, ChartTabs.curType];
        SONG.notes[sectionIndex].sectionNotes.push(note);
        selectedNote = note;
        selectedNoteObject = mainGrid.drawObject(note);
    }

    public function selectNote(note:ChartNote) {
        if (note.chartData != null) {
            if (note == selectedNoteObject) deselectNote();
            else {
                selectedNote = note.chartData;
                selectedNoteObject = note;
                updateNoteTabUI();
            }
        }
    }

    public function removeNote(note:ChartNote) {
        if (note.chartData != null) {
            if (note.chartData == selectedNote || note == selectedNoteObject) {
                deselectNote();
            }
            SONG.notes[sectionIndex].sectionNotes.remove(note.chartData);
            mainGrid.clearObject(note);
        }
    }

    public var selectedEvents:Array<EventData> = [];
    public var selectedEventObject(default, set):ChartEvent = null;
    public var eventID:Int = 0;

    function set_selectedEventObject(value) {
        if (value != null && selectedEventObject != null && value != selectedEventObject) {
            value.blend = ADD;
            selectedEventObject.blend = NORMAL;
        }
        else if (value == null && selectedEventObject != null) selectedEventObject.blend = NORMAL;
        else if (value != null && selectedEventObject == null) value.blend = ADD;
        return selectedEventObject = value;
    }

    public function addEvent() {
        final strumTime:Float = getYtime(noteTile.y + GRID_SIZE) + sectionTime - Conductor.stepCrochet;
        tabs.setCurEvent(ChartTabs.curEventDatas[eventID].name); // Update values
        deselectEvent();

        selectedEvents = [];
        for (i in ChartTabs.curEventDatas) {
            final event:EventData = [strumTime, i.name, convertEventValues(i.values)];
            SONG.notes[sectionIndex].sectionEvents.push(event);
            selectedEvents.push(event);
        }

        selectedEventObject = eventsGrid.drawPackedObject(strumTime, selectedEvents);
    }

    public function selectEvent(event:ChartEvent) {
        selectedEvents = event.chartData;
        selectedEventObject = event;
        tabs.updateEventTxt();
    }

    public function pushEvent(data:EventData) {
        if (selectedEvents.length == 0 || selectedEventObject == null) return;
        data[0] = selectedEventObject.strumTime;

        SONG.notes[sectionIndex].sectionEvents.push(data);
        selectedEvents.push(data);
        selectedEventObject.pushData(data);
    }

    public function spliceEvent(id:Int = 0) {
        if (selectedEvents.length == 0 || selectedEventObject == null) return;
        final data = selectedEventObject.chartData[id];

        SONG.notes[sectionIndex].sectionEvents.remove(data);
        selectedEvents.remove(data);
        selectedEventObject.removeData(id);
    }

    public function updateEvent(id:Int = 0, newValue:Dynamic) {
        if (selectedEvents.length == 0 || selectedEventObject == null) return;

        final curEvent = selectedEvents[eventID];
        final values = curEvent[2].copy();
        values[id] = newValue;
        curEvent[2] = values;
        selectedEventObject.data[eventID].values = curEvent[2].copy();
        selectedEventObject.updateText();
    }

    public function convertEventValues(values:Array<Dynamic>) {
		for (i in 0...values.length) {
			switch (Type.typeof(values[i])) {
				case TClass(Array): values[i] = values[i].copy()[0];
				default:
			}
		}
		return values;
	}

    public function setEventData(newData:Array<Dynamic>, name:String) {
        if (selectedEvents.length == 0 || selectedEventObject == null) return;
        
        final curEvent = selectedEvents[eventID];
        curEvent[1] = name;
        curEvent[2] = convertEventValues(newData.copy());
        selectedEventObject.data[eventID].values = curEvent[2].copy();
        selectedEventObject.data[eventID].name = curEvent[1];
        selectedEventObject.updateText();
        selectedEventObject.loadSettings();
    }

    public function removeEvent(event:ChartEvent) {
        for (data in event.chartData) {
            if (selectedEvents.contains(data) || event == selectedEventObject) {
                tabs.updateEventTxt();
                deselectEvent();
            }
            SONG.notes[sectionIndex].sectionEvents.remove(data);
        }
        eventsGrid.clearObject(event);
    }

    public function changeNoteSus(value:Float = 0) {
        if (selectedNote == null || selectedNoteObject == null) return;
        selectedNote[2] = Math.max((selectedNote[2] ?? 0) + value, 0);
        mainGrid.updateObject(selectedNoteObject, selectedNote);
        updateNoteTabUI();
    }

    function updateSelectedNote() {
        if (selectedNote == null || selectedNoteObject == null) return;
        mainGrid.updateObject(selectedNoteObject, selectedNote);
    }

    public function clearSongEvents() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear these song events?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            for (i in SONG.notes) FlxArrayUtil.clearArray(i.sectionEvents);
            clearSectionData(false, true);
        }));
    }

    public function clearSongNotes() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear these song notes?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            for (i in SONG.notes) FlxArrayUtil.clearArray(i.sectionNotes);
            clearSectionData(true, false);
        }));
    }

    public function clearSongFull() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear this song?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            for (i in SONG.notes) {
                FlxArrayUtil.clearArray(i.sectionNotes);
                FlxArrayUtil.clearArray(i.sectionEvents);
                i.mustHitSection = true;
                i.changeBPM = false;
                i.bpm = 0;
            }
            clearSectionData();
            updateSectionTabUI();
        }));
    }

    public function clearSectionData(clearNotes:Bool = true, clearEvents:Bool = true, full:Bool = true) {
        if (clearNotes) {
            FlxArrayUtil.clearArray(SONG.notes[sectionIndex].sectionNotes);
            deselectNote();
            mainGrid.setData(sectionIndex);
        }
        if (clearEvents) {
            FlxArrayUtil.clearArray(SONG.notes[sectionIndex].sectionEvents);
            deselectEvent();
            eventsGrid.setData(sectionIndex);
        }
    }

    function deselectNote() {
        selectedNote = null;
        selectedNoteObject = null;
    }

    function deselectEvent() {
        eventID = 0;
        FlxArrayUtil.clearArray(selectedEvents);
        selectedEventObject = null;
    }

    public function copySection(?copyData:SwagSection, secTime:Float = 0.0, copyNotes:Bool = true, copyEvents:Bool = true) {
        if (copyData != null) {
            if (copyNotes) {
                for (i in copyData.sectionNotes) {
                    final note:Array<Dynamic> = [i[0], i[1], i[2], i[3]];
                    note[0] -= secTime - sectionTime;
                    SONG.notes[sectionIndex].sectionNotes.push(note);
                    mainGrid.drawObject(note);
                } 
            }
            if (copyEvents) {
                for (i in copyData.sectionEvents) {
                    final event:Array<Dynamic> = [i[0], i[1], cast(i[2], Array<Dynamic>).copy()];
                    event[0] -= secTime - sectionTime;
                    SONG.notes[sectionIndex].sectionEvents.push(event);
                    eventsGrid.drawObject(event);
                }
            }
        }
    }

    public function copyLastSection(change:Int = 1, copyNotes:Bool = true, copyEvents:Bool = true):Void {
        if (change != 0) {
            final secIndex = sectionIndex - change;
            copySection(SONG.notes[secIndex], getSecTime(secIndex), copyNotes, copyEvents);
        }
	}

    inline function updateNoteTile() {
        var eventsOverlap = getGridOverlap(FlxG.mouse, eventsGrid.grid);
        if (getGridOverlap(FlxG.mouse, mainGrid.grid) || eventsOverlap) {
            noteTile.visible = true;
            var tilePos = getGridCoords(FlxG.mouse, eventsOverlap ? eventsGrid.grid : mainGrid.grid, !FlxG.keys.pressed.SHIFT);
            noteTile.setPosition(tilePos.x, tilePos.y);
        } else noteTile.visible = false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        updateNoteTile();
        updatePosition();
        checkNoteSound();
        if (!tabs.getFocus()) keys();
        mouse();
    }

    override function stepHit(curStep:Int) {
        super.stepHit(curStep);
        if (playing) Conductor.autoSync();
    }

    public static inline function getTimeY(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, Conductor.STEPS_PER_MEASURE * Conductor.stepCrochet, 0, GRID_SIZE * Conductor.STEPS_PER_MEASURE);
	}

    public static inline function getYtime(y:Float):Float {
        return FlxMath.remapToRange(y, 0, GRID_SIZE * Conductor.STEPS_PER_MEASURE, 0, Conductor.STEPS_PER_MEASURE * Conductor.stepCrochet);
    }

    public static inline function getSecTime(index:Int = 0) {
        return Song.getSectionTime(SONG, index);
    }

    public static inline function getSecBpm(index:Int = 0):Float {
        Conductor.mapBPMChanges(SONG);
        return Conductor.getLastBpmChange(getSecBpm(index), SONG.bpm).bpm;
    }

    public function loadJson(song:String):Void {
        stop();
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
		return FunkyJson.stringify({
			"song": Song.optimizeJson(SONG)
		}, _);
	}

    function saveJson(input:Dynamic, fileName:String) {
        final data:String = input is String ? input : FunkyJson.stringify(input, "\t");
        if (data.length > 0) {
			final chartFile:FileReference = new FileReference();
			chartFile.save(data.trim(), '$fileName.json');
		}
    }

    public function saveChart() {
        SONG = Song.checkSong(SONG);
        saveJson(getSongString("\t"), PlayState.curDifficulty);
    }

    public function saveMeta() {
        final metaEvents:Array<SwagSection> = [];
        for (i in SONG.notes) {
            if (i.sectionEvents.length > 0) {
                metaEvents.push({
                    sectionEvents: i.sectionEvents.copy()
                });
            }
            else metaEvents.push({});
        }

        if (metaEvents.length > 1) {
			while (true) {
				final lastSec = metaEvents[metaEvents.length-1];
				if (lastSec == null) break;
				if (Reflect.fields(lastSec).length <= 0) 	metaEvents.pop();
				else 										break;
			}
		}
        
        final meta:SongMeta = {
            diffs: [PlayState.curDifficulty],
            offsets: SONG.offsets.copy(),
            events: metaEvents
        }

        saveJson(meta, "songMeta");
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			final check:FlxUICheckBox = cast sender;
			final label = check.getLabel().text;
			switch (label) {
				case 'Must Hit Section':
					SONG.notes[sectionIndex].mustHitSection = check.checked;
					updateIcons();

				case 'Change BPM':
					SONG.notes[sectionIndex].changeBPM = check.checked;
					Conductor.mapBPMChanges(ChartingState.SONG);
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			final nums:FlxUINumericStepper = cast sender;
			final wname = nums.name;
			switch (wname) {
				case 'song_speed':
                    SONG.speed = nums.value;

				case 'song_bpm':
                    SONG.bpm = nums.value;
					Conductor.mapBPMChanges(SONG);
                    changeSection();

				case 'song_inst_offset':
					final tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[0] = tempOffset;
					SONG.offsets[0] = tempOffset;
                    mainGrid.updateWaveform();

				case 'song_vocals_offset':
					final tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[1] = tempOffset;
					SONG.offsets[1] = tempOffset;
                    mainGrid.updateWaveform();

				case 'note_susLength':
					selectedNote[2] = nums.value;
					updateSelectedNote();

				case 'section_bpm':
                    Conductor.mapBPMChanges(ChartingState.SONG);
					SONG.notes[sectionIndex].bpm = nums.value;
                    changeSection();

				case 'stepper_copy':
                    tabs.updatePreview();
			}
		}
	}

    override function destroy():Void {
        Conductor.songPitch = 1;
		Conductor.setPitch(1, false);
        lastSection = sectionIndex;
		super.destroy();
	}
}