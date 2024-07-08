package funkin.states.editors;

import openfl.display.BitmapData;
import flixel.text.FlxBitmapText;
import funkin.states.editors.chart.grid.ChartNote.ChartSustain;
import haxe.ds.Vector;
import funkin.substates.NotesSubstate;
import funkin.substates.PromptSubstate;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
import openfl.net.FileReference;
import flixel.util.FlxStringUtil;

import funkin.states.editors.chart.*;
import funkin.states.editors.chart.grid.*;
import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;
import funkin.states.editors.chart.ChartGridBase.getGridOverlap;
import funkin.states.editors.chart.ChartGridBase.getGridCoords;

class ChartingState extends MusicBeatState
{
    public static var SONG:SongJson;
    public var notes:Array<SectionJson>;
    
    public static var autoSaveChart:String;
    public static var instance:ChartingState;
    public static var lastSong:String = "";

    public static var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;
    public var nextSectionTime:Float = 0;

    public var bg:FunkinSprite;
    public var noteTile:FlxSprite;
    public var strumBar:ChartStrumLine;
    public var stats:FlxBitmapText;
    public var tabs:ChartTabs;

    public var textGroup:TypedGroup<FlxBitmapText>;
    public var mainGrid:ChartNoteGrid;
    public var eventsGrid:ChartEventGrid;

    public var camTop:FlxCamera;
    public var instStr:String = "";

    public function loadMusic(value:String) {
        Conductor.loadSong(value);
        instStr = FlxStringUtil.formatTime(Conductor.inst.length * 0.001, true);
    }
    
    override function create() {
        instance = this;
        autoSaveChart = SaveData.getSave('autoSaveChart');
        
        bg = new FunkinSprite('menuDesat', [0,0], [0,0]);
		bg.color = 0xFF242424;
        bg.setScale(1.11);
		bg.screenCenter();
		add(bg);

        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        PlayState.inChartEditor = true;
        FlxG.mouse.visible = true;

        camTop = new FlxCamera(); camTop.bgColor.alpha = 0;
        FlxG.cameras.add(camTop, false);
        
        SONG = Song.checkSong(PlayState.SONG);
        notes = SONG.notes;

        Conductor.offset = Vector.fromArrayCopy(SONG.offsets);
        Conductor.setTimeSignature(4,4, SONG.bpm);
        Conductor.mapBPMChanges(SONG);
        loadMusic(SONG.song);
        Conductor.volume = 1;
        stop();

        NoteUtil.initTypes();
        EventUtil.initEvents();

        var stageSkin = Stage.getJson(SONG.stage).skin;
        SkinUtil.setCurSkin(stageSkin);

        textGroup = new TypedGroup<FlxBitmapText>();
        mainGrid = new ChartNoteGrid();
        eventsGrid = new ChartEventGrid();
        eventsGrid.grid.x -= GRID_SIZE * 5;

        var grid = mainGrid.grid;
        
        add(eventsGrid);
        add(mainGrid);

        stats = new FlxBitmapText(grid.x + grid.width + 25, grid.y + 25);
        stats.antialiasing = false;
        stats.scale.set(3,3);
        stats.scrollFactor.set();

        add(textGroup);
        add(stats);

        var gay = FlxG.bitmap.create(1, cast grid.height * 3, FlxColor.fromRGB(0,0,0,153));
        gay.bitmap.fillRect(new Rectangle(0, grid.height, 1, grid.height), FlxColor.fromRGB(0,0,0,1));

        var mainShadow = new FlxSprite(grid.x, grid.y - grid.height).loadGraphic(gay);
        mainShadow.scale.x = grid.width;
        mainShadow.updateHitbox();
        add(mainShadow);

        var eventShadow = new FlxSprite(eventsGrid.grid.x, grid.y - grid.height).loadGraphic(gay);
        eventShadow.scale.x = eventsGrid.grid.width;
        eventShadow.updateHitbox();
        add(eventShadow);

        noteTile = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
        noteTile.setGraphicSize(GRID_SIZE);
        noteTile.updateHitbox();
        noteTile.antialiasing = false;
        noteTile.alpha = 0.6;
        add(noteTile);

        strumBar = new ChartStrumLine();
        strumBar.setPosition(grid.x, grid.y);
        add(strumBar);

        if (SONG.song != lastSong) {
            sectionIndex = 0;
            lastSong = SONG.song;
        }

        tabs = new ChartTabs(stats.x, stats.y + FlxG.height * 0.25);
        tabs.scrollFactor.set();
        add(tabs);
        
        setSection(sectionIndex, true);

        super.create();
    }

    public function recycleText():FlxBitmapText {
        var text:FlxBitmapText = textGroup.recycle(FlxBitmapText);
        text.antialiasing = false;
        text.scale.set(2, 2);
        text.updateHitbox();
        textGroup.add(text);
        return text;
    }

    function checkNoteSound()
    {
        mainGrid.group.forEachAlive((note:ChartNote) ->
        {
            final hasChild:Bool = (note.child != null);

            if (note.strumTime < Conductor.songPosition)
            {
                if (note.strumTime + 0.1 >= sectionTime)
                {
                    // Press note
                    if (note.color == FlxColor.WHITE) {
                        strumBar.pressStrum(note.gridNoteData);
                        if (playing) if (tabs.check_hitsound.checked)
                            CoolUtil.playSound('chart/hitclick', 1, 1);
                    } 

                    // Press note sustain
                    if (hasChild) {
                        var chartData = note.chartData;
                        if (chartData != null) {
                            var time = chartData[0];
                            var length = chartData[2];
                            if (Conductor.songPosition >= time) if (Conductor.songPosition <= time + (Conductor.stepCrochet * .5) + length)
                            {
                                strumBar.pressStrum(chartData[1]);
                            }
                        }
                    }

                }
                
                note.color = 0xffb496b4;
            }
            else
            {
                note.color = FlxColor.WHITE;
            }

            if (hasChild) {
                note.child.color = note.color;
            }
        });

        eventsGrid.group.forEachAlive((event:ChartEvent) -> {
            event.color = (event.strumTime + 0.1 <= Conductor.songPosition)
            ? event.color = 0xffb496b4
            : FlxColor.WHITE;
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

    public inline function changeSection(change:Int = 0) {
        setSection(FlxMath.maxInt(sectionIndex + change, 0));
    }

    var curSectionData:SectionJson;

    public function setSection(newIndex:Int = 0, forced:Bool = false) {
        if (!forced) if (sectionIndex == newIndex) { // Same section, doesnt need update
            bpmPositionCheck(sectionTime);
            return; 
        }

        deselectNote();
        deselectEvent();
        Song.checkAddSections(SONG, newIndex, sectionIndex);  // Check for null new sections
        
        sectionIndex = newIndex;
        curSectionData = notes[sectionIndex];

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
        if (playing) if (tabs.check_metronome.checked) {
            CoolUtil.playSound('chart/metronome_tick', 1, 1);
			var scaleMult:Float = (curBeat % Conductor.BEATS_PER_MEASURE == 0) ? 1.25 : 1.15;
			bg.scale.set(scaleMult, scaleMult);
        }
    }

    public function updateIcons() {
        strumBar.updateWithData();
    }

    public function updateSectionTabUI():Void {
        if (curSectionData == null) return;
		tabs.check_mustHitSection.checked = curSectionData.mustHitSection;
		tabs.check_changeBPM.checked = curSectionData.changeBPM;
		tabs.stepperSectionBPM.value = curSectionData.bpm;
        tabs.updatePreview();
        updateIcons();
	}

    public function updateNoteTabUI():Void {
        if (nullNote()) return;
        tabs.stepperSusLength.value = selectedNote.length;
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

    function keys() {
        if (FlxG.keys.justPressed.SPACE) {
            playing ? stop() : play();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
			openTestSubstate();
			return;
		}

        if (FlxG.keys.justPressed.R) {
            stop();
            setSection(FlxG.keys.pressed.SHIFT ? 0 : sectionIndex);
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

    var overlapNotes:Bool;

    function mouse()
    {
        if (!noteTile.visible)
            return;

        var clickL = FlxG.mouse.justPressed;
        var clickR = FlxG.mouse.justPressedRight;

        if (clickL || clickR)
        {
            if (overlapNotes)
            {
                var hasOverlap:Bool = false;
                mainGrid.group.members.fastForEach((note, i) -> {
                    if (note != null) if (note.alive)
                    if (note.strumTime >= (sectionTime - 1)) if (FlxG.mouse.overlaps(note)) {
                        hasOverlap = true;
                        clickL ? removeNote(note) : selectNote(note); // Remove events
                        break;
                    }
                });

                if (!hasOverlap) if (clickL)
                    addNote();
            }
            else
            {
                var hasOverlap:Bool = false;
                eventsGrid.group.members.fastForEach((event, i) -> {
                    if (event != null) if (event.alive)
                    if (event.strumTime >= (sectionTime - 1)) if (FlxG.mouse.overlaps(event.sprite)) {
                        hasOverlap = true;
                        clickL ? removeEvent(event) : selectEvent(event); // Remove events
                        break;
                    }
                });

                if (!hasOverlap) if (clickL)
                    addEvent();
            }
        }
    }

    public var selectedNote:NoteJson;
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

    inline function getTileTime():Float return getYtime(noteTile.y + GRID_SIZE) + sectionTime - Conductor.stepCrochet;

    public function addNote() {
        var strumTime:Float = getTileTime();
        var noteData:Int = Math.floor((noteTile.x - mainGrid.grid.x) / GRID_SIZE);
        var note:Array<Dynamic> = [strumTime, noteData, 0, ChartTabs.curType];
        curSectionData.sectionNotes.push(note);
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
            curSectionData.sectionNotes.remove(note.chartData);
            mainGrid.clearObject(note);
        }
    }

    public var selectedEvents:Array<EventJson> = [];
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
        tabs.setCurEvent(ChartTabs.curEventDatas[eventID].name); // Update values
        deselectEvent();

        selectedEvents = [];
        
        var strumTime:Float = getTileTime();
        ChartTabs.curEventDatas.fastForEach((data, i) -> {
            var event:Array<Dynamic> = [strumTime, data.name, convertEventValues(data.values)];
            curSectionData.sectionEvents.push(event);
            selectedEvents.push(event);
        });

        selectedEventObject = eventsGrid.drawPackedObject(strumTime, selectedEvents);
    }

    public function selectEvent(event:ChartEvent) {
        selectedEvents = event.chartData;
        selectedEventObject = event;
        tabs.updateEventTxt();
    }

    inline function nullEvent():Bool return selectedEvents.length == 0 || selectedEventObject == null;

    public function pushEvent(data:Array<Dynamic>) {
        if (nullEvent()) return;
        
        data[0] = selectedEventObject.strumTime;
        curSectionData.sectionEvents.push(data);
        selectedEvents.push(data);
        selectedEventObject.pushData(data);
    }

    public function spliceEvent(id:Int = 0) {
        if (nullEvent()) return;
        
        var data = selectedEventObject.chartData[id];
        curSectionData.sectionEvents.remove(data);
        selectedEvents.remove(data);
        selectedEventObject.removeData(id);
    }

    public function updateEvent(id:Int = 0, newValue:Dynamic) {
        if (nullEvent()) return;

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
        event.chartData.fastForEach((data, i) -> {
            if (selectedEvents.contains(data) || event == selectedEventObject) {
                tabs.updateEventTxt();
                deselectEvent();
            }
            curSectionData.sectionEvents.remove(data);
        });
        eventsGrid.clearObject(event);
    }

    inline function nullNote():Bool return selectedNote == null || selectedNoteObject == null;

    public function changeNoteSus(value:Float = 0) {
        if (nullNote()) return;
        selectedNote.length = Math.max((selectedNote.length ?? 0) + value, 0);
        mainGrid.updateObject(selectedNoteObject, selectedNote);
        updateNoteTabUI();
    }

    function updateSelectedNote() {
        if (nullNote()) return;
        mainGrid.updateObject(selectedNoteObject, selectedNote);
    }

    public function clearSongEvents() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear these song events?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            notes.fastForEach((section, i) -> section.sectionEvents.clear());
            clearSectionData(false, true);
        }));
    }

    public function clearSongNotes() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear these song notes?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            notes.fastForEach((section, i) -> section.sectionNotes.clear());
            clearSectionData(true, false);
        }));
    }

    public function clearSongFull() {
        stop();
        openSubState(new PromptSubstate('Are you sure you want to\nclear this song?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
            notes.fastForEach((section, i) -> {
                section.sectionNotes.clear();
                section.sectionEvents.clear();
                section.mustHitSection = true;
                section.changeBPM = false;
                section.bpm = 0;
            });
            clearSectionData();
            updateSectionTabUI();
        }));
    }

    public function clearSectionData(clearNotes:Bool = true, clearEvents:Bool = true, full:Bool = true) {
        if (clearNotes) {
            curSectionData.sectionNotes.clear();
            deselectNote();
            mainGrid.setData(sectionIndex);
        }
        if (clearEvents) {
            curSectionData.sectionEvents.clear();
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
        selectedEvents.clear();
        selectedEventObject = null;
    }

    public function copySection(?copyData:SectionJson, secTime:Float = 0.0, copyNotes:Bool = true, copyEvents:Bool = true) {
        if (copyData != null) {
            if (copyNotes) {
                for (i in copyData.sectionNotes) {
                    final note:Array<Dynamic> = [i[0], i[1], i[2], i[3]];
                    note[0] -= secTime - sectionTime;
                    curSectionData.sectionNotes.push(note);
                    mainGrid.drawObject(note);
                } 
            }
            if (copyEvents) {
                for (i in copyData.sectionEvents) {
                    final event:Array<Dynamic> = [i[0], i[1], cast(i[2], Array<Dynamic>).copy()];
                    event[0] -= secTime - sectionTime;
                    curSectionData.sectionEvents.push(event);
                    eventsGrid.drawObject(event);
                }
            }
        }
    }

    public function copyLastSection(change:Int = 1, copyNotes:Bool = true, copyEvents:Bool = true):Void {
        if (change != 0) {
            final secIndex = sectionIndex - change;
            copySection(notes[secIndex], getSecTime(secIndex), copyNotes, copyEvents);
        }
	}

    function updateNoteTile() {
        var mouseX = FlxG.mouse.x;
        var mouseY = FlxG.mouse.y;
        
        overlapNotes = getGridOverlap(mouseX, mouseY, mainGrid.grid);
        noteTile.visible = (overlapNotes || getGridOverlap(mouseX, mouseY, eventsGrid.grid));
        
        if (noteTile.visible) {
            var grid = overlapNotes ? mainGrid.grid : eventsGrid.grid;
            var tile = getGridCoords(mouseX, mouseY, grid.x, grid.y, !FlxG.keys.pressed.SHIFT);
            noteTile.setPosition(tile.x, tile.y);
        }
    }

    override function update(elapsed:Float):Void
    {
        stats.text = 
        "Time: "        + FlxStringUtil.formatTime(Conductor.songPosition * 0.001, true) + " / " + instStr + "\n" +
        "Step: "        + Math.max(0, curStep) + "\n" +
        "Beat: "        + Math.max(0, curBeat) + "\n" +
        "Section: "     + Math.max(0, curSection) + "\n\n" +
        "Position: "    + Math.floor(Conductor.songPosition) + "\n" +
        "BPM: "         + Conductor.bpm;

        if (bg.scale.x > 1.11) {
            var x = CoolUtil.coolLerp(bg.scale.x, 1.1, 0.25);
            bg.scale.set(x, x);
        }
        
        super.update(elapsed);

        updateNoteTile();
        updatePosition();
        checkNoteSound();
        
        if (!tabs.getFocus())
            keys();
        
        mouse();
    }

    public static inline function getTimeY(strumTime:Float):Float {
		return FlxMath.remapToRange(
            strumTime, 0,
            Conductor.STEPS_PER_MEASURE * Conductor.stepCrochet, 0,
            GRID_SIZE * Conductor.STEPS_PER_MEASURE
        );
	}

    public static inline function getYtime(y:Float):Float {
        return FlxMath.remapToRange(
            y, 0,
            GRID_SIZE * Conductor.STEPS_PER_MEASURE, 0,
            Conductor.STEPS_PER_MEASURE * Conductor.stepCrochet
        );
    }

    public static inline function getSecTime(index:Int = 0) {
        return Song.getSectionTime(SONG, index);
    }

    public static inline function getSecBpm(index:Int = 0):Float {
        Conductor.mapBPMChanges(SONG);
        return Conductor.getLastBpmChange(getSecTime(index), SONG.bpm).bpm;
    }

    public function loadJson(song:String):Void {
        stop();
		PlayState.SONG = Song.checkSong(Song.loadFromFile(PlayState.curDifficulty, song));
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

    public function saveMeta()
    {
        var metaEvents:Array<SectionJson> = [];
        notes.fastForEach((section, i) -> {
            metaEvents.push(section.sectionEvents.length <= 0 ? {} : {
                sectionEvents: section.sectionEvents.copy()
            });
        });

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

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
    {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			final check:FlxUICheckBox = cast sender;
			switch (check.getLabel().text) {
				case 'Must Hit Section':
					curSectionData.mustHitSection = check.checked;
					updateIcons();

				case 'Change BPM':
					curSectionData.changeBPM = check.checked;
					Conductor.mapBPMChanges(ChartingState.SONG);
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
        {
			final nums:FlxUINumericStepper = cast sender;
			switch (nums.name) {
				case 'song_speed':
                    SONG.speed = nums.value;

				case 'song_bpm':
                    SONG.bpm = nums.value;
					Conductor.mapBPMChanges(SONG);
                    changeSection();

				case 'song_inst_offset':
					var offset:Int = Std.int(nums.value);
					Conductor.offset[0] = offset;
					SONG.offsets[0] = offset;
                    mainGrid.updateWaveform();

				case 'song_vocals_offset':
					var offset:Int = Std.int(nums.value);
					Conductor.offset[1] = offset;
					SONG.offsets[1] = offset;
                    mainGrid.updateWaveform();

				case 'note_susLength':
                    if (!nullNote()) {
                        selectedNote.length = nums.value;
                        updateSelectedNote();
                    }

				case 'section_bpm':
                    Conductor.mapBPMChanges(ChartingState.SONG);
					curSectionData.bpm = nums.value;
                    changeSection();

				case 'stepper_copy':
                    tabs.updatePreview();
			}
		}
	}

    override function destroy():Void {
        super.destroy();
        Conductor.songPitch = 1;
		Conductor.setPitch(1, false);
        if (instance == this)
            instance = null;
	}
}