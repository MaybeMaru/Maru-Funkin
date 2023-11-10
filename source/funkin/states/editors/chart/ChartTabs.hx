package funkin.states.editors.chart;

import flixel.util.FlxArrayUtil;
import flixel.addons.ui.FlxUIGroup;
import funkin.substates.PromptSubstate;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;

import funkin.substates.CharSelectSubstate;

class ChartTabs extends FlxUITabMenu {
    public var tabs = [
		{name: "Song", 		label: 'Song'},
		{name: "Section", 	label: 'Section'},
		{name: "Note", 		label: 'Note'},
		{name: "Event",		label: 'Event'},
		{name: "Editor", 	label: 'Editor'}
	];
    
    public function new() {
        super(null, tabs, true);
		resize(400, 400);
		curType = 'default';

        addSongUI();
		addSectionUI();
		addNoteUI();
		addEventUI();
		addEditorUI();
    }

	function selectChar(?selectFunction:Void->Void):Void {
		ChartingState.instance.stop();
		Conductor.setPitch(1, false);
		ChartingState.instance.openSubState(new CharSelectSubstate(selectFunction));
	}

	public var focusList:Array<FlxUIInputText> = [];
	public function getFocus():Bool {
		for (i in focusList) if (i.hasFocus) return true;
		return false;
	}

    var p1Button:FlxUIButton;
	var p2Button:FlxUIButton;
	var p3Button:FlxUIButton;
	var songTitleInput:FlxUIInputText;
	function addSongUI():Void {
		songTitleInput = new FlxUIInputText(10, 20, 200, ChartingState.SONG.song, 8);
		focusList.push(songTitleInput);
		songTitleInput.callback = function(var1,var2) {
			ChartingState.SONG.song = songTitleInput.text;
		}

		var saveSongButton:FlxUIButton = new FlxUIButton(songTitleInput.x + 300, songTitleInput.y, "Save", function() {
			ChartingState.instance.saveChart();
		});

		var saveMetaButton:FlxUIButton = new FlxUIButton(saveSongButton.x, songTitleInput.y+35, "Save Meta", function() {
			ChartingState.instance.saveMeta();
		});

		var reloadSongJson:FlxUIButton = new FlxUIButton(songTitleInput.x, songTitleInput.y+25, "Reload JSON", function() {
			ChartingState.instance.loadJson(songTitleInput.text);
		});

		var reloadAudio:FlxUIButton = new FlxUIButton(reloadSongJson.x + 100, reloadSongJson.y, "Reload Audio", function() {
			ChartingState.instance.stop();
			ChartingState.instance.loadMusic(songTitleInput.text);
			ChartingState.instance.changeSection();
		});

		var autoSaveFunc = function () {
			ChartingState.instance.openSubState(new PromptSubstate('Are you sure you want to\nload the song autosave?\nUnsaved charts wont be restored\n\n\nPress back to cancel', function () {
				ChartingState.instance.loadAutosave();
			}));
		}

		var loadAutosaveBtn:FlxUIButton = new FlxUIButton(reloadAudio.x + 100, reloadAudio.y, 'Load Autosave', autoSaveFunc);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 85, 1, 1, 1, 339, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = ChartingState.SONG.speed;
		stepperSpeed.name = 'song_speed';

		//SONG OFFSETS
		var stepperOffsetInst:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x + 100, stepperBPM.y, 1, 0, -999, 999, 0);
		stepperOffsetInst.value = Conductor.songOffset[0];
		stepperOffsetInst.name = 'song_inst_offset';

		var stepperOffsetVocals:FlxUINumericStepper = new FlxUINumericStepper(stepperOffsetInst.x, stepperSpeed.y, 1, 0, -999, 999, 0);
		stepperOffsetVocals.value = Conductor.songOffset[1];
		stepperOffsetVocals.name = 'song_vocals_offset';

		p1Button = new FlxUIButton(10, 155, "Boyfriend", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p1Button.label.text = newChar;
				ChartingState.SONG.players[0] = newChar;
				ChartingState.instance.updateIcons();
			});
		});
		p1Button.label.text = ChartingState.SONG.players[0];

		p2Button = new FlxUIButton(stepperOffsetInst.x, p1Button.y, "Dad", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p2Button.label.text = newChar;
				ChartingState.SONG.players[1] = newChar;
				ChartingState.instance.updateIcons();
			});
		});
		p2Button.label.text = ChartingState.SONG.players[1];

		p3Button = new FlxUIButton(p2Button.x + 100, p2Button.y, "Girlfriend", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p3Button.label.text = newChar;
				ChartingState.SONG.players[2] = newChar;
				//ChartingState.instance.updateIcons();
			});
		});
		p3Button.label.text = ChartingState.SONG.players[2];

		var stages:Array<String> = JsonUtil.getJsonList('stages');
		var stageDropDown = new FlxUIDropDownMenu(p1Button.x, p1Button.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) {
			ChartingState.SONG.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = ChartingState.SONG.stage;

		var difficulties:Array<String> = WeekSetup.curWeekDiffs;
		var difficultyDropDown = new FlxUIDropDownMenu(stageDropDown.x + stageDropDown.width + 15, stageDropDown.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(difficulties, true), function (difficulty:String) {
				var newDiff = difficulties[Std.parseInt(difficulty)];
				if (newDiff != PlayState.curDifficulty) {
					PlayState.curDifficulty = newDiff;
					ChartingState.instance.loadJson(ChartingState.SONG.song);
				}});
		difficultyDropDown.selectedLabel = PlayState.curDifficulty;
		
		var tab_group_song = new FlxUI(null, this);
		tab_group_song.name = "Song";
		tab_group_song.add(songTitleInput);

		tab_group_song.add(new FlxText(songTitleInput.x, songTitleInput.y - 15, 0, 'Song Title:'));
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'BPM:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(stepperOffsetInst.x, stepperOffsetInst.y - 15, 0, 'Inst Offset (MS):'));
		if (Conductor.hasVocals) tab_group_song.add(new FlxText(stepperOffsetVocals.x, stepperOffsetVocals.y - 15, 0, 'Vocals Offset (MS):'));

		tab_group_song.add(new FlxText(difficultyDropDown.x, difficultyDropDown.y - 15, 0, 'Difficulty:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));

		tab_group_song.add(new FlxText(p1Button.x, p1Button.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(p2Button.x, p2Button.y - 15, 0, 'Dad:'));
		tab_group_song.add(new FlxText(p3Button.x, p3Button.y - 15, 0, 'Girlfriend:'));

		tab_group_song.add(stepperOffsetInst);
		if (Conductor.hasVocals) tab_group_song.add(stepperOffsetVocals);

		addGrpObj([
			saveSongButton, saveMetaButton, reloadSongJson, reloadAudio, loadAutosaveBtn, stepperBPM,stepperSpeed,
			p3Button, p1Button, p2Button,
			difficultyDropDown, stageDropDown
		], tab_group_song);
	}

	function addGrpObj(arr:Array<Dynamic>, grp:FlxUIGroup) {
		for (i in arr) grp.add(i);
		addGroup(grp);
	}

	var stepperCopy:FlxUINumericStepper;
	public var check_mustHitSection:FlxUICheckBox;
	public var check_changeBPM:FlxUICheckBox;
	public var stepperSectionBPM:FlxUINumericStepper;
	var lastSectionPreview:ChartPreview;
	var sectionNoteTypesDropDown:FlxUIDropDownMenu;

	var sectionClipboard:{section:SwagSection, time:Float} = {
		section: null,
		time: 0.0
	};

	public function updatePreview() {
		var index = Std.int(ChartingState.instance.sectionIndex - stepperCopy.value);
		var copyData = ChartingState.SONG.notes[index];
       	if (copyData == null || stepperCopy.value == 0) return;
		lastSectionPreview.resetDraw(index);
	}

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, this);
		tab_group_section.name = 'Section';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(check_changeBPM.x + 100, check_changeBPM.y, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		final copyNotes:FlxUICheckBox = new FlxUICheckBox(check_changeBPM.x, check_changeBPM.y + 45, null, null, "Copy Notes");
		final copyEvents:FlxUICheckBox = new FlxUICheckBox(copyNotes.x + 100, copyNotes.y, null, null, "Copy Events");
		copyNotes.checked = copyEvents.checked = true;

		var copyButton:FlxUIButton = new FlxUIButton(10, 130, "Copy Last", function() {
			ChartingState.instance.copyLastSection(Std.int(stepperCopy.value), copyNotes.checked, copyEvents.checked);
		});

		stepperCopy = new FlxUINumericStepper(copyButton.x + 100, copyButton.y, 1, 1, -999, 999, 0);
		stepperCopy.y += copyButton.height * .5 - stepperCopy.height * .5;
		stepperCopy.name = 'stepper_copy';

		lastSectionPreview = new ChartPreview(ChartingState.SONG);
		lastSectionPreview.setPosition(stepperCopy.x + 100, stepperCopy.y);
		lastSectionPreview.offset.x = -50;
		updatePreview();

		var clearSectionButton:FlxUIButton = new FlxUIButton(10, 155, "Clear", function() {
			ChartingState.instance.clearSectionData(true, true, false);
		});

		var swapSection:FlxUIButton = new FlxUIButton(10, 180, "Swap Section", function() {
			for (note in ChartingState.SONG.notes[ChartingState.instance.sectionIndex].sectionNotes) {
				var noteObject = ChartingState.instance.mainGrid.getDataObject(note);
				note[1] = (note[1] + Conductor.NOTE_DATA_LENGTH) % Conductor.STRUMS_LENGTH;
				ChartingState.instance.mainGrid.updateObject(noteObject, note);
			}
		});

		var copySection:FlxUIButton = new FlxUIButton(swapSection.x, swapSection.y + 50, "Copy Section", function () {
			sectionClipboard.section = JsonUtil.copyJson(ChartingState.SONG.notes[ChartingState.instance.sectionIndex]);
			sectionClipboard.time = ChartingState.instance.sectionTime;
		});
		
		var pasteSection:FlxUIButton = new FlxUIButton(copySection.x, copySection.y + 25, "Paste Section", function () {
			ChartingState.instance.copySection(sectionClipboard.section, sectionClipboard.time, copyNotes.checked, copyEvents.checked);
		});

		final setTypesLeft:FlxUICheckBox = new FlxUICheckBox(swapSection.x, swapSection.y + 150, null, null, "Left Side");
		final setTypesRight:FlxUICheckBox = new FlxUICheckBox(setTypesLeft.x + 100, setTypesLeft.y, null, null, "Right Side");
		setTypesLeft.checked = setTypesRight.checked = true;
	
		var setSectionNoteTypes:FlxUIButton = new FlxUIButton(swapSection.x, swapSection.y + 125, "Set Types", function() {
			for (note in ChartingState.SONG.notes[ChartingState.instance.sectionIndex].sectionNotes) {
				final sideLength = Conductor.NOTE_DATA_LENGTH - 1;
				if ((note[1] <= sideLength && setTypesLeft.checked) || (note[1] > sideLength && setTypesRight.checked)) {
					final noteObject = ChartingState.instance.mainGrid.getDataObject(note);
					note[3] = sectionNoteTypesDropDown.selectedLabel;
					ChartingState.instance.mainGrid.updateObject(noteObject, note);
				}
			}
		});

		sectionNoteTypesDropDown = new FlxUIDropDownMenu(setSectionNoteTypes.x + 100, setSectionNoteTypes.y, FlxUIDropDownMenu.makeStrIdLabelArray(NoteUtil.noteTypesArray.copy(), true));
		sectionNoteTypesDropDown.selectedLabel = 'default';

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must Hit Section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		tab_group_section.add(new FlxText(lastSectionPreview.x, lastSectionPreview.y - 15, 0, 'Last Section Preview:'));

		addGrpObj([stepperSectionBPM,stepperCopy,copyNotes,copyEvents,lastSectionPreview,check_mustHitSection,check_changeBPM,
			copyButton,clearSectionButton, swapSection, copySection, pasteSection, setTypesLeft, setTypesRight,
			setSectionNoteTypes,sectionNoteTypesDropDown], tab_group_section);
	}

	public var stepperSusLength:FlxUINumericStepper;
	var noteTypesDropDown:FlxUIDropDownMenu;

	public static var curType:String = 'default';

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, this);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet * .5, 0, 0, Conductor.stepCrochet * Conductor.STEPS_PER_MEASURE);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var types:Array<String> = NoteUtil.noteTypesArray.copy();
		noteTypesDropDown = new FlxUIDropDownMenu(stepperSusLength.x, stepperSusLength.y + 35, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(type:String) {
			var curNote = ChartingState.instance.selectedNote;
			var curNoteObject = ChartingState.instance.selectedNoteObject;
			curType = types[Std.parseInt(type)];
			if (curNote == null || curNoteObject == null) return;
			curNote[3] = curType;
			ChartingState.instance.mainGrid.updateObject(curNoteObject, curNote);
		});
		curType = types[0];
		noteTypesDropDown.selectedLabel = curType;

		tab_group_note.add(new FlxText(stepperSusLength.x, stepperSusLength.y - 15, 0, 'Sustain Length:'));
		tab_group_note.add(new FlxText(noteTypesDropDown.x, noteTypesDropDown.y - 15, 0, 'Note Type:'));

		addGrpObj([stepperSusLength, noteTypesDropDown], tab_group_note);
	}

	var eventsDropDown:FlxUIDropDownMenu;
	var eventDescription:FlxText;
	public var eventValueTab:EventTab = null;

	public static var curEventDatas:Array<{name:String, values:Array<Dynamic>}> = [];
	public static var curEventNames:Array<String> = [];

	function updateCurData(event:String) {
		curEventDatas[eventID()] = {
			curEventDatas[eventID()] = {
				name: event,
				values: eventValueTab == null ? EventUtil.getEventData(event).values.copy() : eventValueTab.getValues().copy()
			}
		}
	}

	public function setCurEvent(event:String) {
		curEventNames[eventID()] = event;
		updateCurData(event);
		updateEventTxt();
	}

	var eventListTxt:FlxText;
	var eventLeft:FlxUIButton;
	var eventAdd:FlxUIButton;
	var eventRemove:FlxUIButton;
	var eventRight:FlxUIButton;

	inline function eventID() 	 	return ChartingState.instance.eventID;
	inline function eventObj() 	 	return ChartingState.instance.selectedEventObject;
	
	var initEvent:String = "NULL_EVENT";

	function setEventTab(newEvent:String, ?values:Array<Dynamic>) {
		final eventData = EventUtil.getEventData(newEvent);
		final _defValues = eventData.values.copy();
		eventDescription.text = eventData.description;
		eventValueTab.createUI(_defValues);

		if (values != null) {
			eventsDropDown.selectedLabel = newEvent;
			eventValueTab.setValues(values);
		}
		else {
			setCurEvent(newEvent);
			ChartingState.instance.setEventData(_defValues.copy(), newEvent); // Set defaults
		}
		
		
		/*if (values != null) {
			eventDescription.text = eventData.description;
			eventValueTab.setValues(values.copy());
			//setCurEvent(newEvent);
		} else {
			final _defValues = eventData.values.copy();
			eventDescription.text = eventData.description;
			eventValueTab.setValues(_defValues);
			setCurEvent(newEvent);
			ChartingState.instance.setEventData(_defValues.copy(), newEvent); // Set defaults
		}*/
	}

	public function updateEventTxt() {
		eventListTxt.text = "[ " +
		(eventID() + 1) + " / " +
		(curEventNames.length) + " ] " +
		(curEventNames[eventID()] ?? "NULL_EVENT");
	}

	function addEventUI():Void {
		FlxArrayUtil.clearArray(curEventDatas);
		FlxArrayUtil.clearArray(curEventNames);

		var tab_group_event = new FlxUI(null, this);
		tab_group_event.name = 'Event';

		eventListTxt = new FlxText(110, 10, 0, "", 12);
		eventListTxt.antialiasing = false;
		eventListTxt.alignment = RIGHT;

		eventLeft = new FlxUIButton(10,10, "<", function () {
			final id:Int = eventID();
			updateCurData(curEventNames[id]);
			ChartingState.instance.eventID = FlxMath.wrap(id - 1, 0, curEventDatas.length - 1);
			if (eventID() != id) {
				setEventTab(curEventNames[eventID()], curEventDatas[eventID()].values);
				updateEventTxt();
			}
		});

		eventRight = new FlxUIButton(eventLeft.x + (25*3),eventLeft.y, ">", function () {
			final id:Int = eventID();
			updateCurData(curEventNames[id]);
			ChartingState.instance.eventID = FlxMath.wrap(id + 1, 0, curEventDatas.length - 1);
			if (eventID() != id) {
				setEventTab(curEventNames[eventID()], curEventDatas[eventID()].values);
				updateEventTxt();
			}
		});

		eventAdd = new FlxUIButton(eventLeft.x + 25,eventLeft.y, "+", function () {
			if (curEventDatas.length < 16) {
				final e:String = eventsDropDown.selectedLabel;
				final d = eventValueTab == null ? EventUtil.getEventData(e).values.copy() : eventValueTab.getValues().copy();
				
				curEventNames.push(e);
				curEventDatas.push({
					name: e,
					values: d
				});

				ChartingState.instance.pushEvent([0, e, d]);
				ChartingState.instance.eventID = curEventDatas.length - 1;
				updateEventTxt();
			}
		});
		eventAdd.color = FlxColor.LIME;
		eventAdd.label.color = FlxColor.WHITE;

		eventRemove = new FlxUIButton(eventLeft.x + (25*2),eventLeft.y, "-", function () {
			if (curEventDatas.length > 1) {
				final id = eventID();
				curEventDatas.remove(curEventDatas[id]);
				curEventNames.remove(curEventNames[id]);

				ChartingState.instance.spliceEvent(id);
				ChartingState.instance.eventID = curEventDatas.length - 1;
				updateEventTxt();
			}
		});
		eventRemove.color = FlxColor.RED;
		eventRemove.label.color = FlxColor.WHITE;

		var types:Array<String> = EventUtil.eventsArray.copy();
		eventsDropDown = new FlxUIDropDownMenu(10, 50, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(type:String) {
			final newEvent = types[Std.parseInt(type)];
			if (curEventDatas[eventID()].name != newEvent) {
				setEventTab(newEvent);
			}
		});

		for (i in [eventLeft, eventAdd, eventRemove, eventRight]) {
			tab_group_event.add(i);
			i.resize(20,20);
		}
		tab_group_event.add(eventListTxt);

		eventDescription = new FlxText(eventsDropDown.x,eventsDropDown.y + 25, 125, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.");
		tab_group_event.add(eventDescription);

		tab_group_event.add(new FlxText(eventsDropDown.x, eventsDropDown.y - 15, 0, 'Event:'));
		tab_group_event.add(eventsDropDown);

		postCreateFuncs.push(function () {
			initEvent = types[0];
			if (initEvent != null) {
				setCurEvent(initEvent);
				eventsDropDown.selectedLabel = initEvent;
				eventDescription.text = EventUtil.getEventData(initEvent).description;
			}
			
			eventValueTab = new EventTab(150, 50, curEventDatas[eventID()].values);
			eventValueTab.updateFunc = function (id:Int, value:Dynamic)
				ChartingState.instance.updateEvent(id, value);
			tab_group_event.add(eventValueTab);
			updateEventTxt();
		});
		
		addGroup(tab_group_event);
	}

	public var check_hitsound:FlxUICheckBox;
	public var check_metronome:FlxUICheckBox;
	public var slider_pitch:FlxUISlider;

	var songPitch(default, set):Float = 1;
	function set_songPitch(value:Float):Float {
		value = FlxMath.roundDecimal(value,2);
		songPitch = value;
		Conductor.setPitch(value);
		return value;
	}

	function addEditorUI():Void {
		var tab_group_editor = new FlxUI(null, this);
		tab_group_editor.name = 'Editor';

		var check_mute_inst = new FlxUICheckBox(10, 35, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			Conductor.inst.volume = check_mute_inst.checked ? 0 : 1;
		};

		var check_mute_voices = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 30, null, null, "Mute Voices", 100);
		check_mute_voices.checked = false;
		check_mute_voices.callback = function() {
			Conductor.vocals.volume = check_mute_voices.checked ? 0 : 1;
		};

		var check_waveform_inst = new FlxUICheckBox(check_mute_inst.x + 125, check_mute_inst.y, null, null, "Instrumental Waveform", 100);
		check_waveform_inst.checked = false;
		check_waveform_inst.callback = function() {
			ChartingState.instance.mainGrid.waveformInst.visible = check_waveform_inst.checked;
			ChartingState.instance.mainGrid.waveformInst.updateWaveform();
		};

		var check_waveform_voices = new FlxUICheckBox(check_waveform_inst.x, check_waveform_inst.y + 30, null, null, "Voices Waveform", 100);
		check_waveform_voices.checked = false;
		check_waveform_voices.callback = function() {
			ChartingState.instance.mainGrid.waveformVocals.visible = check_waveform_voices.checked;
			ChartingState.instance.mainGrid.waveformVocals.updateWaveform();
		};

		check_hitsound = new FlxUICheckBox(check_mute_inst.x, check_mute_voices.y + 30, null, null, "Use Hitsounds", 100);
		check_hitsound.checked = false;

		check_metronome = new FlxUICheckBox(check_mute_inst.x, check_hitsound.y + 30, null, null, "Use Metronome", 100);
		check_metronome.checked = false;

		var formatButton = function (btn:FlxUIButton) {
			btn.color = FlxColor.RED;
			btn.resize(100,25);
			btn.label.color = FlxColor.WHITE;
			btn.label.fieldWidth = 0;
		}

		var button_clearSongNotes:FlxUIButton = new FlxUIButton(275, check_mute_inst.y, "Clear Song Notes", ChartingState.instance.clearSongNotes);
		formatButton(button_clearSongNotes);

		var button_clearSongEvents:FlxUIButton = new FlxUIButton(button_clearSongNotes.x, button_clearSongNotes.y + 30, "Clear Song Events", ChartingState.instance.clearSongEvents);
		formatButton(button_clearSongEvents);

		var button_clearSongFull:FlxUIButton = new FlxUIButton(button_clearSongEvents.x, button_clearSongEvents.y + 30, "Clear Song Full", ChartingState.instance.clearSongFull);
		formatButton(button_clearSongFull);

		slider_pitch = new FlxUISlider(this, 'songPitch', check_metronome.x, check_metronome.y + 30, 0.25, 2, 290, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		slider_pitch.nameLabel.text = 'Pitch/Speed';
		slider_pitch.name = 'song_pitch';

		if (Conductor.hasVocals) for (i in [check_mute_voices,check_waveform_voices])
			tab_group_editor.add(i);

		addGrpObj([check_mute_inst,check_waveform_inst,
			check_hitsound,check_metronome,slider_pitch,
			button_clearSongNotes, button_clearSongEvents, button_clearSongFull], tab_group_editor);
	}

	var postCreateFuncs:Array<Dynamic> = [];
	public function runPost() {
		for (i in postCreateFuncs) i();
	}
}