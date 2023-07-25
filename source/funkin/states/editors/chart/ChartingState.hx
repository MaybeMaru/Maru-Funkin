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

import funkin.states.editors.chart.ChartPreview;
import funkin.states.editors.chart.CharSelectSubstate;
import funkin.states.editors.chart.ChartSustain;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxSave;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

class ChartingState extends MusicBeatState {
	var autoSaveFile:FlxSave;

	var _file:FileReference;
	var UI_box:FlxUITabMenu;

	var _curSection:Int = 0;
	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var strumLine:FlxSprite;

	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var dummyArrow:FlxSprite;
	var bg:FunkinSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<ChartSustain>;
	var curRenderedTextTypes:FlxTypedGroup<FunkinText>;

	var GRID_SIZE:Int = 40;
	var gridBG:FlxSprite;
	var gridBGback:FlxSprite;
	var gridBlackLine:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;
	var curSelectedNoteSpr:Note;

	var inst:FlxSound;
	var vocals:FlxSound;
	var hasVocals:Bool = true;

	var tempBpm:Float = 0;
	var songPitch(default, set):Float = 1;
	var ogPitch:Float = 1;

	function set_songPitch(value:Float):Float {
		value = FlxMath.roundDecimal(value,2);
		songPitch = value;
		Conductor.setPitch(value);
		inst.pitch = value;
		vocals.pitch = value;
		return value;
	}

	var chartPreview:ChartPreview;
	var initialized:Bool = false;

	override function destroy():Void {
		Conductor.songPitch = ogPitch;
		Conductor.setPitch(1, false);
		super.destroy();
	}

	var tabs = [
		{name: "Song", 		label: 'Song'},
		{name: "Section", 	label: 'Section'},
		{name: "Note", 		label: 'Note'},
		{name: "Editor", 	label: 'Editor'}
	];

	override function create():Void {
		ogPitch = Conductor.songPitch;
		FlxG.mouse.visible = true;
		PlayState.inChartEditor = true;
		autoSaveFile = new FlxSave();
        autoSaveFile.bind('funkinChart');

		_curSection = lastSection;

		bg = new FunkinSprite('menuDesat');
		bg.color = 0xFF242424;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

		gridBGback = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * Conductor.STRUMS_LENGTH, GRID_SIZE * Conductor.STEPS_SECTION_LENGTH * 3, true, 0xff7c7c7c, 0xff6e6e6e);
		gridBGback.y -= GRID_SIZE * Conductor.STEPS_SECTION_LENGTH;
		gridBGback.color = FlxColor.fromRGB(150,150,150);
		add(gridBGback);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * Conductor.STRUMS_LENGTH, GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, true, 0xff7c7c7c, 0xff6e6e6e);
		add(gridBG);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2, -GRID_SIZE * Conductor.STEPS_SECTION_LENGTH).makeGraphic(2, Std.int(gridBGback.height), FlxColor.BLACK);
		gridBlackLine.offset.x = gridBlackLine.width;
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<ChartSustain>();
		curRenderedTextTypes = new FlxTypedGroup<FunkinText>();

		_song = Song.checkSong(PlayState.SONG);

		tempBpm = _song.bpm;
		iconP1 = new HealthIcon(_song.players[0]);
		iconP2 = new HealthIcon(_song.players[1]);

		addSection();
		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
		Conductor.songOffset = _song.offsets;

		bpmTxt = new FlxText(1000, 50, 0, "", Conductor.STEPS_SECTION_LENGTH);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), Conductor.NOTE_DATA_LENGTH);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(325, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEditorUI();

		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedTextTypes);

		add(iconP1);
		add(iconP2);
		updateHeads(true);

		Conductor.songPosition = 0;
		Conductor.sync(inst,vocals);

		updateSectionUI();
		changeSection();

		chartPreview = new ChartPreview();
		chartPreview.scrollFactor.set();
		add(chartPreview);

		var previewLine:FlxSprite = new FlxSprite(chartPreview.x, chartPreview.y-2).makeGraphic(Std.int(chartPreview.width), 2, FlxColor.WHITE);
		previewLine.scrollFactor.set();
		add(previewLine);

		initialized = true;
		updateGrid();
		super.create();
	}

	function selectChar(?selectFunction:Void->Void):Void {
		stopSong();
		Conductor.setPitch(1, false);
		openSubState(new CharSelectSubstate(selectFunction));
	}

	var p1Button:FlxButton;
	var p2Button:FlxButton;
	var p3Button:FlxButton;
	function addSongUI():Void {
		var songTitleInput = new FlxUIInputText(10, 20, 150, _song.song, 8);
		typingShit = songTitleInput;

		var saveButton:FlxButton = new FlxButton(songTitleInput.x, songTitleInput.y+25, "Save", function() {
			saveLevel();
		});

		var reloadSongJson:FlxButton = new FlxButton(saveButton.x + 100, saveButton.y, "Reload JSON", function() {
			loadJson(_song.song);
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x + 100, reloadSongJson.y, 'Load Autosave', loadAutosave);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 85, 1, 1, 1, 339, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		//SONG OFFSETS
		var stepperOffsetInst:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x + 100, stepperBPM.y, 1, 0, -999, 999, 0);
		stepperOffsetInst.value = Conductor.songOffset[0];
		stepperOffsetInst.name = 'song_inst_offset';

		var stepperOffsetVocals:FlxUINumericStepper = new FlxUINumericStepper(stepperOffsetInst.x, stepperSpeed.y, 1, 0, -999, 999, 0);
		stepperOffsetVocals.value = Conductor.songOffset[1];
		stepperOffsetVocals.name = 'song_vocals_offset';

		p1Button = new FlxButton(10, 155, "Boyfriend", function() {
			var getP1 = function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p1Button.text = newChar;
				_song.players[0] = newChar;
				updateHeads();
			}
			selectChar(getP1);
		});
		p1Button.text = _song.players[0];

		p2Button = new FlxButton(stepperOffsetInst.x, p1Button.y, "Dad", function() {
			var getP2 = function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p2Button.text = newChar;
				_song.players[1] = newChar;
				updateHeads();
			}
			selectChar(getP2);
		});
		p2Button.text = _song.players[1];

		p3Button = new FlxButton(loadAutosaveBtn.x, p2Button.y, "Girlfriend", function() {
			var getP3 = function () {
				var newChar:String = CharSelectSubstate.lastChar;
				p3Button.text = newChar;
				_song.players[2] = newChar;
				//updateHeads();
			}
			selectChar(getP3);
		});
		p3Button.text = _song.players[2];

		var stages:Array<String> = JsonUtil.getJsonList('stages');
		var stageDropDown = new FlxUIDropDownMenu(p1Button.x, p1Button.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) {
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;

		var difficulties:Array<String> = WeekSetup.curWeekDiffs;
		var difficultyDropDown = new FlxUIDropDownMenu(stageDropDown.x + stageDropDown.width + 15, stageDropDown.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(difficulties, true), function (difficulty:String) {
				var newDiff = difficulties[Std.parseInt(difficulty)];
				if (newDiff != PlayState.curDifficulty) {
					PlayState.curDifficulty = newDiff;
					loadJson(_song.song);
				}});
		difficultyDropDown.selectedLabel = PlayState.curDifficulty;
		
		var tab_group_song = new FlxUI(null, UI_box);
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

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperCopy:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var lastSectionPreview:ChartPreview;
	var sectionNoteTypesDropDown:FlxUIDropDownMenu;

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last", function() {
			copySection(Std.int(stepperCopy.value));
		});

		stepperCopy = new FlxUINumericStepper(copyButton.x + 100, copyButton.y, 1, 1, -999, 999, 0);
		stepperCopy.y += copyButton.height/2 - stepperCopy.height/2;
		stepperCopy.name = 'stepper_copy';

		lastSectionPreview = new ChartPreview(false);
		lastSectionPreview.setPosition(stepperCopy.x + 80, stepperCopy.y);
		lastSectionPreview.scale.y *= 4;
		lastSectionPreview.scale.x *= 0.75;
		lastSectionPreview.updateHitbox();

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function() {
			for (i in 0..._song.notes[_curSection].sectionNotes.length) {
				var note = _song.notes[_curSection].sectionNotes[i];
				note[1] = (note[1] + Conductor.NOTE_DATA_LENGTH) % Conductor.STRUMS_LENGTH;
				_song.notes[_curSection].sectionNotes[i] = note;
			}
			updateGrid();
		});

		var setSectionNoteTypes:FlxButton = new FlxButton(swapSection.x, swapSection.y + 125, "Set types", function() {
			for (i in 0..._song.notes[_curSection].sectionNotes.length) {
				_song.notes[_curSection].sectionNotes[i][3] = sectionNoteTypesDropDown.selectedLabel;
			}
			updateGrid();
		});

		var types:Array<String> = JsonUtil.getJsonList('notetypes');
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

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var noteTypesDropDown:FlxUIDropDownMenu;

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * Conductor.STEPS_SECTION_LENGTH);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var types:Array<String> = JsonUtil.getJsonList('notetypes');
		noteTypesDropDown = new FlxUIDropDownMenu(stepperSusLength.x, stepperSusLength.y + 35, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(type:String) {
			if (curSelectedNote != null) {
				curSelectedNote[3] = types[Std.parseInt(type)];
				updateGrid();
			}
		});
		noteTypesDropDown.selectedLabel = 'default';

		tab_group_note.add(new FlxText(stepperSusLength.x, stepperSusLength.y - 15, 0, 'Sustain Length:'));
		tab_group_note.add(new FlxText(noteTypesDropDown.x, noteTypesDropDown.y - 15, 0, 'Note Type:'));

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteTypesDropDown);

		UI_box.addGroup(tab_group_note);
	}

	var check_hitsound:FlxUICheckBox;
	var check_metronome:FlxUICheckBox;
	var slider_pitch:FlxUISlider;

	function addEditorUI():Void {
		var tab_group_editor = new FlxUI(null, UI_box);
		tab_group_editor.name = 'Editor';

		var check_mute_inst = new FlxUICheckBox(10, 35, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			var vol:Float = hasVocals ? 0.6 : 1;
			if (check_mute_inst.checked) vol = 0;
			inst.volume = vol;
		};

		var check_mute_voices = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 30, null, null, "Mute Voices", 100);
		check_mute_voices.checked = false;
		check_mute_voices.callback = function() {
			var vol:Float = check_mute_voices.checked ? 0 : 1;
			vocals.volume = vol;
		};

		check_hitsound = new FlxUICheckBox(check_mute_inst.x, check_mute_voices.y + 30, null, null, "Use Hitsounds", 100);
		check_hitsound.checked = false;

		check_metronome = new FlxUICheckBox(check_mute_inst.x, check_hitsound.y + 30, null, null, "Use Metronome", 100);
		check_metronome.checked = false;

		var button_clearSong:FlxButton = new FlxButton(200, check_mute_inst.y, "Clear Song", clearSong);
		button_clearSong.color = FlxColor.RED;

		slider_pitch = new FlxUISlider(this, 'songPitch', check_metronome.x, check_metronome.y + 30, 0.25, 2, 290, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		slider_pitch.nameLabel.text = 'Pitch/Speed';
		slider_pitch.name = 'song_pitch';

		tab_group_editor.add(check_mute_inst);
		if (hasVocals) tab_group_editor.add(check_mute_voices);
		tab_group_editor.add(check_hitsound);
		tab_group_editor.add(check_metronome);
		tab_group_editor.add(slider_pitch);
		tab_group_editor.add(button_clearSong);

		UI_box.addGroup(tab_group_editor);
	}

	function loadSong(daSong:String):Void {

		stopSong();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}
	
		inst = new FlxSound().loadEmbedded(Paths.inst(daSong));
		FlxG.sound.list.add(inst);

		var vocalsPath:String = Paths.voices(daSong, true);
		hasVocals = Paths.exists(vocalsPath, MUSIC);
		if (hasVocals) {
			vocals = new FlxSound().loadEmbedded(vocalsPath);
			inst.volume = 0.6;
		}
		else {
			vocals = new FlxSound();
			inst.volume = 1;
		}
		FlxG.sound.list.add(vocals);

		stopSong();

		inst.onComplete = function() {
			Conductor.songPosition = 0;
			pauseSong();
			changeSection();
		}
	}
	
	override function closeSubState():Void {
		super.closeSubState();
		Conductor.setPitch(Conductor.songPitch);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					_song.notes[_curSection].mustHitSection = check.checked;
					updateHeads();

				case 'Change BPM':
					_song.notes[_curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);

			switch (wname) {
				case 'song_speed':
					_song.speed = nums.value;

				case 'song_bpm':
					tempBpm = nums.value;
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(tempBpm);
				
				case 'song_inst_offset':
					var tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[0] = tempOffset;
					_song.offsets[0] = tempOffset;
								
				case 'song_vocals_offset':
					var tempOffset:Int = Std.int(nums.value);
					Conductor.songOffset[1] = tempOffset;
					_song.offsets[1] = tempOffset;
				
				case 'note_susLength':
					curSelectedNote[2] = nums.value;
					updateGrid();
				
				case 'section_bpm':
					_song.notes[_curSection].bpm = Std.int(nums.value);
					updateGrid();

				case 'stepper_copy':
					updatePreview();

			}
		}
	}

	function sectionStartTime(?sectionNum:Int):Float {
		if (sectionNum == null)	sectionNum = _curSection;
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...sectionNum) {
			if (_song.notes[i].changeBPM) {
				daBPM = _song.notes[i].bpm;
			}
			daPos += Conductor.BEATS_LENGTH * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	/*
	 * FAKE BEAT HIT AND STEP HIT FOR CHART EDITOR
	*/

	function beathit():Void {
		if (check_metronome.checked) {
			FlxG.sound.play(Paths.sound('chart/metronome_tick'));
			var scaleMult:Float = (curBeat % Conductor.BEATS_LENGTH == 0) ? 1.25 : 1.15;
			bg.scale.set(scaleMult,scaleMult);
		}
	}

	function stephit():Void {} //not used yet but its neat to have

	var laststep:Int = 0;
	var timeElp:Float = 0;

	var songPlaying:Bool = false;

	override function update(elapsed:Float):Void {
		if (songPlaying) {
			Conductor.songPosition += elapsed * 1000;
			Conductor.autoSync(inst,vocals);

			if (Conductor.songPosition >= inst.length) { // end song
				Conductor.songPosition = 0;
				pauseSong();
				changeSection();
			}
		}

		curStep = recalculateSteps();
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * Conductor.STEPS_SECTION_LENGTH));
		iconP1.y = strumLine.y - iconP1.height/1.25;
		iconP2.y = strumLine.y - iconP2.height/1.25;

		if (songPlaying) {
			if (curStep != laststep)											stephit();
			if (curStep % Conductor.BEATS_LENGTH == 0 && curStep != laststep)	beathit();
		}
		laststep = curStep;
		bg.scale.set(
		CoolUtil.coolLerp(bg.scale.x, 1.1, 0.25),
		CoolUtil.coolLerp(bg.scale.y, 1.1, 0.25));

		if (curBeat % Conductor.BEATS_LENGTH == 0 && curStep >= Conductor.STEPS_SECTION_LENGTH * (_curSection + 1)) {
			if (_song.notes[_curSection + 1] == null) {
				addSection();
			}
			changeSection(_curSection + 1, false);
		}

		if (curBeat < sectionStartTime() && curStep < Conductor.STEPS_SECTION_LENGTH*_curSection && _song.notes[_curSection + 1] != null) {
			changeSection(_curSection - 1, false);
		}

		keysStuff();

		if (Conductor.songPosition < 0)
			Conductor.songPosition = 0;

		FlxG.watch.addQuick('curBeat', curBeat);
		FlxG.watch.addQuick('curStep', curStep);

		_song.bpm = tempBpm;
		mouseDetection();
		updateBPMtext();
		displayNotes();

		super.update(elapsed);
	}

	function keysStuff():Void {
		if (FlxG.keys.justPressed.ENTER) {
			lastSection = _curSection;
			PlayState.SONG = Song.checkSong(_song);
			stopSong();
			autosaveSong();
			Conductor.setPitch(1, false);
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.TAB) {
			UI_box.selected_tab += (FlxG.keys.pressed.SHIFT) ? -1 : 1;
			if (UI_box.selected_tab > tabs.length-1)	UI_box.selected_tab = 0;
			if (UI_box.selected_tab < 0)				UI_box.selected_tab = tabs.length-1;
		}

		if (!typingShit.hasFocus) {
			if (FlxG.keys.justPressed.E) {
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q) {
				changeNoteSustain(-Conductor.stepCrochet);
			}

			if (FlxG.keys.justPressed.SPACE) {
				songPlaying ? pauseSong() : playSong();
			}

			if (FlxG.keys.justPressed.R) {
				resetSection((FlxG.keys.pressed.SHIFT));
			}

			if (FlxG.mouse.wheel != 0) {
				Conductor.songPosition -= (FlxG.mouse.wheel * Conductor.stepCrochet);
				pauseSong();
			}

			if (!FlxG.keys.pressed.SHIFT) {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
					var daTime:Float = 1000 * FlxG.elapsed / FlxG.timeScale;
					Conductor.songPosition += (FlxG.keys.pressed.W) ? -daTime : daTime;
					pauseSong();
				}
			}
			else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					var daTime:Float = Conductor.stepCrochet * 2;
					Conductor.songPosition += (FlxG.keys.pressed.W) ? -daTime : daTime;
					pauseSong();
				}
			}

			var shiftThing:Int = (FlxG.keys.pressed.SHIFT) ? Conductor.BEATS_LENGTH : 1;
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
				changeSection(_curSection + shiftThing);
			}
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
				changeSection(_curSection - shiftThing);
			}
		}

	}

	function updateBPMtext():Void {
		bpmTxt.text =
		'${Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))} / ${Std.string(FlxMath.roundDecimal(inst.length / 1000, 2))}
		BPM: ${Conductor.bpm}
		Section: $_curSection
		Beat: $curBeat
		Step: $curStep';
	}

	function displayNotes():Void {
		curRenderedNotes.forEachAlive(function(note:Note) { //Play hit sounds
			if(note.strumTime <= Conductor.songPosition) {
				if (note.alpha == 1 && songPlaying && check_hitsound.checked) {
					FlxG.sound.play(Paths.sound('chart/hitclick'));
				}
				note.alpha = 0.3;
			}
			else {
				note.alpha = 1;
			}
		});

		if (curSelectedNoteSpr != null) {
			timeElp = (timeElp+FlxG.elapsed*5/FlxG.timeScale)%180;
			curSelectedNoteSpr.alpha = (Math.abs(Math.sin(timeElp))+0.6)/2.5;
		}
	}

	function mouseDetection():Void {
		if (getGridOverlap(FlxG.mouse, gridBG)) { // display dummy arrow
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			dummyArrow.y = (FlxG.keys.pressed.SHIFT) ? FlxG.mouse.y : Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		} else {
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.justPressed) { //select / add notes
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)) {
						FlxG.keys.pressed.CONTROL ? selectNote(note) : deleteNote(note);
					}
				});
			}
			else if (getGridOverlap(FlxG.mouse, gridBG)) {
				addNote();
			}
		}
	}

	function getGridOverlap(obj1:Dynamic, obj2:Dynamic):Bool {
		return obj1.x > obj2.x && obj1.x < obj2.x + obj2.width
		&& obj1.y > obj2.y && obj1.y < obj2.y + (GRID_SIZE * Conductor.STEPS_SECTION_LENGTH);
	}

	function changeNoteSustain(value:Float):Void {
		if (curSelectedNote != null) {
			if (curSelectedNote[2] != null) {
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}
		updateGrid();
		updateNoteUI();
	}

	function stopSong():Void { // is this and pause song different at all lol
		songPlaying = false;
		if (inst != null) inst.stop();
		if (vocals != null) vocals.stop();
	}
	function pauseSong():Void {
		songPlaying = false;
		if (inst != null) inst.pause();
		if (vocals != null) vocals.pause();
		Conductor.sync(inst,vocals);
	}
	function playSong():Void {
		songPlaying = true;
		if (inst != null) inst.play();
		if (vocals != null) vocals.play();
		Conductor.sync(inst,vocals);
	}

	function recalculateSteps():Int {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime) {
				lastChange = Conductor.bpmChangeMap[i];
			}
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();
		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void {
		// Basically old shit from changeSection???
		Conductor.songPosition = sectionStartTime();

		if (songBeginning) {
			Conductor.songPosition = 0;
			_curSection = 0;
		}

		pauseSong();
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, updateMusic:Bool = true):Void {
		sec = sec < 0 ? 0 : sec;
		if (_curSection == sec && _song.notes[sec] != null && sec > 0) return;
		_curSection = sec;
		_song.notes[sec] = Song.checkSection(_song.notes[sec]); //double check
		updateGrid();

		if (updateMusic) {
			Conductor.songPosition = sectionStartTime();
			pauseSong();
			updateCurStep();
		}

		updateGrid();
		updateSectionUI();
		gridBGback.offset.y = _song.notes[sec-1]==null?-1:_song.notes[sec+1]==null?1:0;
		gridBGback.offset.y *= GRID_SIZE*Conductor.STEPS_SECTION_LENGTH;
		gridBlackLine.offset.y = gridBGback.offset.y;
	}

	function copySection(?sectionNum:Int = 1):Void {
		var daSec:Int = FlxMath.maxInt(_curSection, sectionNum);
		if (_song.notes[daSec - sectionNum] != null) {
			for (note in _song.notes[daSec - sectionNum].sectionNotes) {
				var strum = note[0] + Conductor.stepCrochet * (Conductor.STEPS_SECTION_LENGTH * sectionNum);
				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}
			updateGrid();
		}
	}

	function updateSectionUI():Void {
		var sec = _song.notes[_curSection];
		check_mustHitSection.checked = sec.mustHitSection;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
		updateHeads();
	}

	function updateHeads(forced:Bool = false):Void {
		var arr = [iconP1,iconP2];
		for (i in 0...arr.length) {
			var ico = arr[i];
			var data = Character.getCharData(_song.players[i]);
			if (data != null) {
				if ((ico.iconName != data.icon) || forced) {
					ico.makeIcon(data.icon);
					ico.setGraphicSize(0,60);
					ico.updateHitbox();
					ico.scrollFactor.set(1,1);
				} 
			} 
			ico.setPosition(check_mustHitSection.checked ?  (i == 0 ? 0 : gridBG.width/2) : (i != 0 ? 0 : gridBG.width/2), -100);
		}
	}

	function updateNoteUI():Void {
		if (curSelectedNote != null) {
			stepperSusLength.value = curSelectedNote[2];
			noteTypesDropDown.selectedLabel = NoteUtil.getTypeName(curSelectedNote[3]);
		}
	}

	function updatePreview():Void {
		if (initialized && _song.notes != null) {
			chartPreview.startDraw(_song.notes);
			var copyLastSec:Int = _curSection - Std.int(stepperCopy.value);
			lastSectionPreview.startDraw([_song.notes[copyLastSec]], sectionStartTime(copyLastSec));
		}
	}

	function updateGrid():Void {
		updatePreview();

		var hitList:Array<FlxTypedGroup<Dynamic>> = [curRenderedNotes, curRenderedSustains, curRenderedTextTypes];
		for (g in hitList) {
			for (i in g.members)
				i.kill();
		}

		var changeBPM:Null<Bool> = _song.notes[_curSection].changeBPM;
		if (changeBPM != null || !changeBPM) {
			if (changeBPM && _song.notes[_curSection].bpm > 0) {
				Conductor.changeBPM(_song.notes[_curSection].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		} else { // get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0..._curSection) {
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			}
			Conductor.changeBPM(daBPM);
		}
		
		curSelectedNoteSpr = null;
		var displaySections:Array<Null<SwagSection>> = [_song.notes[_curSection-1], _song.notes[_curSection], _song.notes[_curSection+1]];
		for (s in 0...displaySections.length) {
			if (displaySections[s] != null) {
				var sectionData = displaySections[s];
				var sectionNotes:Array<Dynamic> = sectionData.sectionNotes;
				if (sectionNotes != null) {
					for (i in sectionNotes) {
						var daStrumTime = i[0];
						var daNoteData = i[1];
						var daSus = i[2];
						var daType:String = NoteUtil.getTypeName(i[3]);
						var mustPress:Bool = sectionData.mustHitSection;
						var typeData:NoteTypeJson = NoteUtil.getTypeJson(daType);

						var note:Note = curRenderedNotes.recycle(Note);
						note.strumTime = daStrumTime;
						note.noteData = daNoteData % Conductor.NOTE_DATA_LENGTH;
						note.mustPress = (daNoteData > 3) ? !mustPress : mustPress; 
						note.noteType = daType;
						note.skin = typeData.skin;
						note.createGraphic();
						
						note.scrollFactor.set(1,1);
						note.setGraphicSize(GRID_SIZE, GRID_SIZE);
						note.updateHitbox();
						note.setPosition(Math.floor(daNoteData * GRID_SIZE), Math.floor(getYfromStrum((daStrumTime - sectionStartTime()))));
						curRenderedNotes.add(note);

						if (s == 1) {
							note.alpha = 1;	//	Start section click sounds
							note.color = FlxColor.WHITE;
						} else {
							note.alpha = 0.3;
							note.color = FlxColor.fromRGB(150,150,150);
						}
			
						/*var note:Note = curRenderedNotes.recycle(Note);	//	Recycle is faster than creating a new one
						note.strumTime = daStrumTime;
						note.noteData = daNoteData % Conductor.NOTE_DATA_LENGTH;
						note.loadNoteAnims();
						note.loadType(daType);
						note.loadSkin(typeData.skin);
						note.sustainLength = daSus;
						note.mustPress = (daNoteData > 3) ? !mustHit : mustHit; 
						note.setGraphicSize(GRID_SIZE, GRID_SIZE);
						note.updateHitbox();
						note.x = Math.floor(daNoteData * GRID_SIZE);
						note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime())));
						curRenderedNotes.add(note);
						if (s == 1) {
							note.alpha = 1;	//	Start section click sounds
							note.color = FlxColor.WHITE;
						} else {
							note.alpha = 0.3;
							note.color = FlxColor.fromRGB(150,150,150);
						}*/
			
						/*if (daSus > 0) {
							var GRID_DATA:Array<Int> = [Std.int(GRID_SIZE),Std.int(gridBG.height)];
							var susVis:ChartSustain = curRenderedSustains.recycle(ChartSustain);
							susVis.setupSus(note,daSus,GRID_DATA);
							curRenderedSustains.add(susVis);
						}*/
			
						if (typeData.showText) {
							var crap:String = (daType.startsWith('default')) ? daType.split('default')[1] : daType;
							var typeText:FunkinText = curRenderedTextTypes.recycle(FunkinText);
							typeText.text = crap;
							typeText.setPosition(note.x - (typeText.width/2 - note.width/2), note.y - (typeText.height/2 - note.height/2));
							typeText.color = note.color;
							typeText.scrollFactor.set(1,1);
							curRenderedTextTypes.add(typeText);
						}
			
						if (i == curSelectedNote) {
							curSelectedNoteSpr = note;
						}
					}
				}
			}
		}
	}

	private function addSection():Void {
		var sec:SwagSection = Song.getDefaultSection();
		_song.notes.push(sec);
	}

	function getNoteData(note:Note):Int {
		var fixedData:Int = note.noteData;
		if(note.mustPress != _song.notes[_curSection].mustHitSection)
			fixedData += Conductor.NOTE_DATA_LENGTH;
		return fixedData;
	}

	function selectNote(note:Note):Void {
		var fixedData:Int = getNoteData(note);
		for (i in _song.notes[_curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] == fixedData) {
				curSelectedNote = _song.notes[_curSection].sectionNotes[i];
				break;
			}
		}
		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void {
		var fixedData:Int = getNoteData(note);
		for (i in _song.notes[_curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] == fixedData) {
				if(i == curSelectedNote) curSelectedNote = null;
				_song.notes[_curSection].sectionNotes.remove(i);
				break;
			}
		}
		updateGrid();
	}

	function clearSection():Void {
		_song.notes[_curSection].sectionNotes = [];
		updateGrid();
	}

	function clearSong():Void {
		for (i in 0..._song.notes.length) {
			_song.notes[i].sectionNotes = [];
		}
		stopSong();
		changeSection();
		updateGrid();
	}

	private function addNote():Void {
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteType = noteTypesDropDown.selectedLabel;

		var leNoteShit:Array<Dynamic> = [noteStrum, noteData, noteSus, noteType];
		_song.notes[_curSection].sectionNotes.push(leNoteShit);

		curSelectedNote = _song.notes[_curSection].sectionNotes[_song.notes[_curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL) {
			_song.notes[_curSection].sectionNotes.push([noteStrum, (noteData + Conductor.NOTE_DATA_LENGTH) % Conductor.STRUMS_LENGTH, noteSus, noteType]);
		}

		updateGrid();
		updateNoteUI();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, Conductor.STEPS_SECTION_LENGTH * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, Conductor.STEPS_SECTION_LENGTH * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function loadJson(song:String):Void {
		PlayState.SONG = Song.loadFromFile(PlayState.curDifficulty, song);
		PlayState.SONG = Song.checkSong(PlayState.SONG);
		FlxG.resetState();
	}

	function loadAutosave():Void {
		PlayState.SONG = Song.parseJson('', autoSaveFile.data.autosave);
		PlayState.SONG = Song.checkSong(PlayState.SONG);
		FlxG.resetState();
	}

	function getSongString(_:Null<String> = null) {
		return Json.stringify({
			"song": Song.optimizeJson(_song)
		}, _);
	}

	function autosaveSong():Void {
		_song = Song.checkSong(_song);
		autoSaveFile.data.autosave = getSongString();
		autoSaveFile.flush();
	}

	private function saveLevel():Void {
		_song = Song.checkSong(_song);
		var data:String = getSongString("\t");
		if (data.length > 0) {
			_file = new FileReference();
			_file.save(data.trim(), '${PlayState.curDifficulty}.json');
		}
	}
}