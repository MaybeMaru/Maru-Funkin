package funkin.states.editors.chart;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;

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

    var p1Button:FlxButton;
	var p2Button:FlxButton;
	var p3Button:FlxButton;
	var songTitleInput:FlxUIInputText;
	function addSongUI():Void {
		songTitleInput = new FlxUIInputText(10, 20, 150, ChartingState.SONG.song, 8);
		focusList.push(songTitleInput);
		songTitleInput.callback = function(var1,var2) {
			ChartingState.SONG.song = songTitleInput.text;
		}

		var saveButton:FlxButton = new FlxButton(songTitleInput.x, songTitleInput.y+25, "Save", function() {
			ChartingState.instance.saveChart();
		});

		var reloadSongJson:FlxButton = new FlxButton(saveButton.x + 100, saveButton.y, "Reload JSON", function() {
			ChartingState.instance.loadJson(songTitleInput.text);
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x + 100, reloadSongJson.y, 'Load Autosave', ChartingState.instance.loadAutosave);

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

		p1Button = new FlxButton(10, 155, "Boyfriend", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p1Button.text = newChar;
				ChartingState.SONG.players[0] = newChar;
				ChartingState.instance.updateIcons();
			});
		});
		p1Button.text = ChartingState.SONG.players[0];

		p2Button = new FlxButton(stepperOffsetInst.x, p1Button.y, "Dad", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p2Button.text = newChar;
				ChartingState.SONG.players[1] = newChar;
				ChartingState.instance.updateIcons();
			});
		});
		p2Button.text = ChartingState.SONG.players[1];

		p3Button = new FlxButton(loadAutosaveBtn.x, p2Button.y, "Girlfriend", function() {
			selectChar(function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p3Button.text = newChar;
				ChartingState.SONG.players[2] = newChar;
				//ChartingState.instance.updateIcons();
			});
		});
		p3Button.text = ChartingState.SONG.players[2];

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
		tab_group_song.add(new FlxText(stepperOffsetVocals.x, stepperOffsetVocals.y - 15, 0, 'Vocals Offset (MS):'));

		tab_group_song.add(new FlxText(difficultyDropDown.x, difficultyDropDown.y - 15, 0, 'Difficulty:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));

		tab_group_song.add(new FlxText(p1Button.x, p1Button.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(p2Button.x, p2Button.y - 15, 0, 'Dad:'));
		tab_group_song.add(new FlxText(p3Button.x, p3Button.y - 15, 0, 'Girlfriend:'));

		tab_group_song.add(stepperOffsetInst);
		tab_group_song.add(stepperOffsetVocals);

		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);

		tab_group_song.add(p3Button);
		tab_group_song.add(p1Button);
		tab_group_song.add(p2Button);

		tab_group_song.add(difficultyDropDown);
		tab_group_song.add(stageDropDown);

		addGroup(tab_group_song);
	}

	var stepperCopy:FlxUINumericStepper;
	public var check_mustHitSection:FlxUICheckBox;
	public var check_changeBPM:FlxUICheckBox;
	public var stepperSectionBPM:FlxUINumericStepper;
	var lastSectionPreview:ChartPreview;
	var sectionNoteTypesDropDown:FlxUIDropDownMenu;

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, this);
		tab_group_section.name = 'Section';

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last", function() {
			ChartingState.instance.copyLastSection(Std.int(stepperCopy.value));
		});

		stepperCopy = new FlxUINumericStepper(copyButton.x + 100, copyButton.y, 1, 1, -999, 999, 0);
		stepperCopy.y += copyButton.height/2 - stepperCopy.height/2;
		stepperCopy.name = 'stepper_copy';

		lastSectionPreview = new ChartPreview(false);
		lastSectionPreview.setPosition(stepperCopy.x + 80, stepperCopy.y);
		lastSectionPreview.scale.y *= 4;
		lastSectionPreview.scale.x *= 0.75;
		lastSectionPreview.updateHitbox();

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", function() ChartingState.instance.clearSectionData());

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function() {
			for (note in ChartingState.SONG.notes[ChartingState.instance.sectionIndex].sectionNotes) {
				var noteObject = ChartingState.instance.mainGrid.getNoteObject(note);
				note[1] = (note[1] + Conductor.NOTE_DATA_LENGTH) % Conductor.STRUMS_LENGTH;
				ChartingState.instance.mainGrid.updateNote(noteObject, note);
			}
		});

		var setSectionNoteTypes:FlxButton = new FlxButton(swapSection.x, swapSection.y + 125, "Set types", function() {
			for (note in ChartingState.SONG.notes[ChartingState.instance.sectionIndex].sectionNotes) {
				var noteObject = ChartingState.instance.mainGrid.getNoteObject(note);
				note[3] = sectionNoteTypesDropDown.selectedLabel;
				ChartingState.instance.mainGrid.updateNote(noteObject, note);
			}
		});

		var types:Array<String> = JsonUtil.getSubFolderJsonList('notetypes', [ChartingState.SONG.song]);
		sectionNoteTypesDropDown = new FlxUIDropDownMenu(setSectionNoteTypes.x + 100, setSectionNoteTypes.y, FlxUIDropDownMenu.makeStrIdLabelArray(types, true));
		sectionNoteTypesDropDown.selectedLabel = 'default';

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(new FlxText(lastSectionPreview.x, lastSectionPreview.y - 15, 0, 'Last Section Preview:'));

		//tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(lastSectionPreview);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(setSectionNoteTypes);
		tab_group_section.add(sectionNoteTypesDropDown);

		addGroup(tab_group_section);
	}

	public var stepperSusLength:FlxUINumericStepper;
	var noteTypesDropDown:FlxUIDropDownMenu;

	public static var curType:String = 'default';

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, this);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * Conductor.STEPS_PER_MEASURE);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var types:Array<String> = JsonUtil.getSubFolderJsonList('notetypes', [ChartingState.SONG.song]);
		noteTypesDropDown = new FlxUIDropDownMenu(stepperSusLength.x, stepperSusLength.y + 35, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(type:String) {
			var curNote = ChartingState.instance.selectedNote;
			var curNoteObject = ChartingState.instance.selectedNoteObject;
			curType = types[Std.parseInt(type)];
			if (curNote == null || curNoteObject == null) return;
			curNote[3] = curType;
			ChartingState.instance.mainGrid.updateNote(curNoteObject, curNote);
		});
		curType = types[0];
		noteTypesDropDown.selectedLabel = curType;

		tab_group_note.add(new FlxText(stepperSusLength.x, stepperSusLength.y - 15, 0, 'Sustain Length:'));
		tab_group_note.add(new FlxText(noteTypesDropDown.x, noteTypesDropDown.y - 15, 0, 'Note Type:'));

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteTypesDropDown);

		addGroup(tab_group_note);
	}

	var eventsDropDown:FlxUIDropDownMenu;
	public var eventValueTab:EventTab = null;

	public static var curEvent:String = '';
	public static var curEventValues:Array<Dynamic>;

	public function setCurEvent(event:String) {
		curEvent = event;
		curEventValues = eventValueTab == null ? EventUtil.getEventData(event).values.copy() : eventValueTab.getValues().copy();
	}

	function addEventUI():Void {
		var tab_group_event = new FlxUI(null, this);
		tab_group_event.name = 'Event';

		var types:Array<String> = JsonUtil.getSubFolderJsonList('events', [ChartingState.SONG.song]);
		eventsDropDown = new FlxUIDropDownMenu(10, 25, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(type:String) {
			var newEvent = types[Std.parseInt(type)];
			if (curEvent != newEvent) {
				var _defValues = EventUtil.getEventData(newEvent).values.copy();
				eventValueTab.setValues(_defValues);
				setCurEvent(newEvent);
				ChartingState.instance.setEventData(_defValues.copy(), newEvent); // Set defaults
			}
		});
		setCurEvent(types[0]);
		eventsDropDown.selectedLabel = types[0];

		tab_group_event.add(new FlxText(eventsDropDown.x, eventsDropDown.y - 15, 0, 'Event:'));
		tab_group_event.add(eventsDropDown);

		postCreateFuncs.push(function () {
			eventValueTab = new EventTab(150, 26, curEventValues);
			eventValueTab.updateFunc = function (id:Int, value:Dynamic) {
				//trace(id + " / " + value);
				ChartingState.instance.updateEvent(id, value);
			}
			tab_group_event.add(eventValueTab);
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

		check_hitsound = new FlxUICheckBox(check_mute_inst.x, check_mute_voices.y + 30, null, null, "Use Hitsounds", 100);
		check_hitsound.checked = false;

		check_metronome = new FlxUICheckBox(check_mute_inst.x, check_hitsound.y + 30, null, null, "Use Metronome", 100);
		check_metronome.checked = false;

		var button_clearSongNotes:FlxButton = new FlxButton(250, check_mute_inst.y, "Clear Song Notes", ChartingState.instance.clearSongNotes);
		button_clearSongNotes.color = FlxColor.RED;
		button_clearSongNotes.scale.set(1.3,1.25);
		button_clearSongNotes.label.color = FlxColor.WHITE;
		button_clearSongNotes.label.fieldWidth = 0;

		var button_clearSongEvents:FlxButton = new FlxButton(button_clearSongNotes.x, button_clearSongNotes.y + 30, "Clear Song Events", ChartingState.instance.clearSongEvents);
		button_clearSongEvents.color = FlxColor.RED;
		button_clearSongEvents.scale.set(1.3,1.25);
		button_clearSongEvents.label.color = FlxColor.WHITE;
		button_clearSongEvents.label.fieldWidth = 0;

		var button_clearSongFull:FlxButton = new FlxButton(button_clearSongEvents.x, button_clearSongEvents.y + 30, "Clear Song Full", ChartingState.instance.clearSongFull);
		button_clearSongFull.color = FlxColor.RED;
		button_clearSongFull.scale.set(1.3,1.25);
		button_clearSongFull.label.color = FlxColor.WHITE;
		button_clearSongFull.label.fieldWidth = 0;

		slider_pitch = new FlxUISlider(this, 'songPitch', check_metronome.x, check_metronome.y + 30, 0.25, 2, 290, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		slider_pitch.nameLabel.text = 'Pitch/Speed';
		slider_pitch.name = 'song_pitch';

		tab_group_editor.add(check_mute_inst);
		tab_group_editor.add(check_mute_voices);
		tab_group_editor.add(check_hitsound);
		tab_group_editor.add(check_metronome);
		tab_group_editor.add(slider_pitch);

		tab_group_editor.add(button_clearSongNotes);
		tab_group_editor.add(button_clearSongEvents);
		tab_group_editor.add(button_clearSongFull);

		addGroup(tab_group_editor);
	}

	var postCreateFuncs:Array<Dynamic> = [];
	public function runPost() {
		for (i in postCreateFuncs)
			i();
	}
}