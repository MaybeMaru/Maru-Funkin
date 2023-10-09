package funkin.states.editors;

import funkin.substates.PromptSubstate;

import flixel.addons.display.FlxBackdrop;
import funkin.substates.CharSelectSubstate;
import flixel.addons.display.FlxGridOverlay;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxInputText;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;

class AnimationDebug extends MusicBeatState {
	var UI_box:FlxUITabMenu;
	var tabs = [
		{name: "Animation", label: 'Animation'},
		{name: "Character", label: 'Character'}
	];

	var displayChar:Character;
	var ghostChar:Character;
	var displayIcon:HealthIcon;
	var displayIconDead:HealthIcon;
	var bf_offset:FunkinSprite;	//	USED AS A BASE TO OFFSET
	var cam_offset:FunkinSprite;

	var character:CharacterJson;
	var animsList:Array<String> = [];
	var curAnimIndex:Int = 0;

	var camUI:FlxCamera;
	var camChar:FlxCamera;
	var camFollow:FlxObject;

	var animsText:FlxTypedGroup<FunkinText>;
	var curAnimText:FunkinText;
	var charGroup:FlxSpriteGroup;

	var createChar:String = 'bf';
	public function new(createChar:String = 'bf'):Void {
		super();
		this.createChar = createChar;
	}

	override function create():Void {
		FlxG.mouse.visible = true;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camChar = new FlxCamera();
		camUI = new FlxCamera();
		camChar.bgColor.alpha = 0;
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camChar, false);
		FlxG.cameras.add(camUI);
		FlxG.cameras.setDefaultDrawTarget(camUI, true);

		var gridBG:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.create(20, 20, 40*16, 40*16, true, 0xff7c7c7c,0xff6e6e6e).pixels);
		gridBG.cameras = [camChar];
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		animsText = new FlxTypedGroup<FunkinText>();
		add(animsText);

		curAnimText = new FunkinText(10, 45, 'NULL_ANIM', 26);
		add(curAnimText);

		bf_offset = new FunkinSprite('options/bf_offset', [FlxG.width/2, FlxG.height/2]);
		bf_offset.setPosition(bf_offset.x-bf_offset.width/2,bf_offset.y-bf_offset.height/2);
		bf_offset.alpha = 0.4;
		add(bf_offset);
		bf_offset.cameras = [camChar];

		charGroup = new FlxSpriteGroup();
		add(charGroup);
		charGroup.cameras = [camChar];

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		camFollow.cameras = [camChar];
		camChar.follow(camFollow);

		cam_offset = new FunkinSprite('options/cam_offset');
		cam_offset.offset.set(cam_offset.width/2, cam_offset.height/2);
		add(cam_offset);
		cam_offset.cameras = [camChar];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(350, 200);
		UI_box.x = FlxG.width / 1.5;
		UI_box.y = 20;
		add(UI_box);

		addCharacterUI();
		addAnimationUI();
		loadCharacter(createChar);
		super.create();
	}

	var charButton:FlxUIButton;
	var input_imagePath:FlxUIInputText;
	var input_icon:FlxUIInputText;
	var check_antialiasing:FlxUICheckBox;
	var stepper_scale:FlxUINumericStepper;
	var stepper_offsetX:FlxUINumericStepper;
	var stepper_offsetY:FlxUINumericStepper;
	var stepper_camX:FlxUINumericStepper;
	var stepper_camY:FlxUINumericStepper;
	var check_flipX:FlxUICheckBox;
	var check_isPlayer:FlxUICheckBox;
	var check_isPlayerGame:FlxUICheckBox;

	function addCharacterUI():Void {
		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = 'Character';

		charButton = new FlxUIButton(10, 20, "Boyfriend", function() {
			var getChar = function () {
				var newChar:String = CharSelectSubstate.lastChar;
				charButton.label.text = newChar;
				loadCharacter(newChar);
			}
			openSubState(new CharSelectSubstate(getChar));
		});
		charButton.label.text = createChar;

		var reloadButton:FlxUIButton = new FlxUIButton(charButton.x,charButton.y+30, "Reload Image", function () {
			formatJsonChar();
			final lastGhostAnim = ghostChar.animation.curAnim?.name ?? null;
			displayChar.loadCharJson(character);
			ghostChar.loadCharJson(character);
			displayChar.playAnim(animsList[curAnimIndex], true);
			(lastGhostAnim != null) ? ghostChar.playAnim(lastGhostAnim, true) : updateGhostAnims();
		});

		input_icon = new FlxUIInputText(charButton.x + charButton.width + 15, charButton.y + charButton.height/8, 100, '', 8);
		input_imagePath = new FlxUIInputText(reloadButton.x + reloadButton.width + 15, reloadButton.y + reloadButton.height/8, 200, '', 8);

		stepper_scale = new FlxUINumericStepper(reloadButton.x, reloadButton.y + 40, 0.1, 1, 0.05, 10, 1);
		stepper_offsetX = new FlxUINumericStepper(stepper_scale.x + stepper_scale.width + 20, stepper_scale.y, 10);
		stepper_offsetY = new FlxUINumericStepper(stepper_offsetX.x + stepper_offsetX.width, stepper_scale.y, 10);
		stepper_camX = new FlxUINumericStepper(stepper_offsetY.x + stepper_offsetY.width + 20, stepper_scale.y, 10);
		stepper_camY = new FlxUINumericStepper(stepper_camX.x + stepper_camX.width, stepper_scale.y, 10);

		check_isPlayer = new FlxUICheckBox(stepper_scale.x, stepper_scale.y + 20, null, null, "Is Player (Game)", 100);
		check_isPlayer.callback = function() {
			character.isPlayer = check_isPlayer.checked;
			displayChar.isPlayerJson = check_isPlayer.checked;
			ghostChar.isPlayerJson = check_isPlayer.checked;
			updateFlips();
		};

		check_isPlayerGame = new FlxUICheckBox(check_isPlayer.x + check_isPlayer.width + 10, check_isPlayer.y, null, null, "Is Player (Editor)", 100);
		check_isPlayerGame.callback = function() {
			displayChar.isPlayer = check_isPlayerGame.checked;
			ghostChar.isPlayer = check_isPlayerGame.checked;
			bf_offset.flipX = check_isPlayerGame.checked;
			updateFlips();
			updateWorldOffsets();
		};

		check_flipX = new FlxUICheckBox(check_isPlayer.x, check_isPlayer.y + 20, null, null, "Flip X", 100);
		check_flipX.callback = function() {
			character.flipX = check_flipX.checked;
			updateFlips();
		};

		check_antialiasing = new FlxUICheckBox(check_isPlayerGame.x, check_flipX.y, null, null, "Antialiasing", 100);
		check_antialiasing.callback = function() {
			displayChar.antialiasing = check_antialiasing.checked;
			ghostChar.antialiasing = check_antialiasing.checked;
			character.antialiasing = check_antialiasing.checked;
		};

		var saveButton:FlxUIButton = new FlxUIButton(charButton.x, UI_box.height, "Save JSON", function() {
			saveLevel();
		});
		saveButton.y -= saveButton.height*2.25;

		final _tab = tab_group_char;
		addTabTxt(_tab, charButton, "Select Character:");
		addTabTxt(_tab, input_imagePath, "Image Path:");
		addTabTxt(_tab, input_icon, "Icon:");
		addTabTxt(_tab, stepper_scale, "Scale:");
		addTabTxt(_tab, stepper_offsetX, "Character Offsets:");
		addTabTxt(_tab, stepper_camX, "Camera Offsets:");

		tab_group_char.add(charButton);		tab_group_char.add(input_icon);
		tab_group_char.add(reloadButton);	tab_group_char.add(input_imagePath);

		tab_group_char.add(stepper_scale);	tab_group_char.add(stepper_offsetX);	tab_group_char.add(stepper_offsetY); tab_group_char.add(stepper_camX);	tab_group_char.add(stepper_camY);
		tab_group_char.add(check_isPlayer);	tab_group_char.add(check_isPlayerGame);
		tab_group_char.add(check_flipX);	tab_group_char.add(check_antialiasing);

		tab_group_char.add(saveButton);

		displayIcon = new HealthIcon();
		displayIcon.setPosition(UI_box.width);
		displayIcon.scale.set(0.5,0.5);
		displayIcon.updateHitbox();
		tab_group_char.add(displayIcon);

		displayIconDead = new HealthIcon();
		displayIconDead.isDying = true;
		displayIconDead.setPosition(displayIcon.x, displayIcon.y + displayIcon.height + 5);
		displayIconDead.scale.set(0.5,0.5);
		displayIconDead.updateHitbox();
		tab_group_char.add(displayIconDead);

		UI_box.addGroup(tab_group_char);
	}

	var input_animName:FlxUIInputText;
	var input_animFile:FlxUIInputText;
	var stepper_animFramerate:FlxUINumericStepper;
	var check_loop:FlxUICheckBox;
	var input_indices:FlxUIInputText;

	var updateButton:FlxUIButton;
	var removeButton:FlxUIButton;

	var dropDown_anims:FlxUIDropDownMenu;

	function addAnimationUI():Void {
		var tab_group_anim = new FlxUI(null, UI_box);
		tab_group_anim.name = 'Animation';

		input_animName = new FlxUIInputText(10, 20, 200, '', 8);
		input_animFile = new FlxUIInputText(input_animName.x, input_animName.y + 35, 200, '', 8);
		stepper_animFramerate = new FlxUINumericStepper(input_animFile.x, input_animFile.y + 35, 1, 24, 0, 60);
		check_loop = new FlxUICheckBox(stepper_animFramerate.x + 80, stepper_animFramerate.y, null, null, "Loop Anim", 100);
		input_indices = new FlxUIInputText(stepper_animFramerate.x, stepper_animFramerate.y + 35, 200, '', 8);

		updateButton = new FlxUIButton(input_indices.x, input_indices.y + 25, "Update / Add", function() {
			var existsInputAnim = displayChar.animOffsets.exists(input_animName.text);
			existsInputAnim ? updateAnimation(dropDown_anims.selectedLabel, getUpdatedAnimData()) : addAnimation(getUpdatedAnimData());
			changeCurAnim();
		});
		updateButton.color = FlxColor.LIME;
		updateButton.label.color = FlxColor.WHITE;

		removeButton = new FlxUIButton(updateButton.x + 100, updateButton.y, 'Remove', function () {
			removeAnimation(dropDown_anims.selectedLabel);
			changeCurAnim();
		});
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;

		var autoButton:FlxUIButton = new FlxUIButton(updateButton.x, removeButton.y + 45, 'Auto Anims', function () {
			openSubState(new PromptSubstate('Are you sure you want to\nuse auto animations?\nPreviously created animations\nwill be deleted\n\n\nPress back to cancel', function () {
				final prefixes = displayChar.getAnimationPrefixes();
				for (i in displayChar.animDatas.keys()) removeAnimation(i);
				for (i in prefixes) {
					addAnimation({
						animName: i,
						animFile: i,
						offsets: [0.0,0.0],
						framerate: Std.int(stepper_animFramerate.value),
						indices: [],
						loop: false
					});
				}
				changeCurAnim();
			}));
		});

		var loopButton:FlxUIButton = new FlxUIButton(autoButton.x + 100, autoButton.y, 'Loop Anim', function () {
			var uiAnimData = getUpdatedAnimData();
			uiAnimData.indices = [3,4,5];
			uiAnimData.offsets = getOffsetFromChar(displayChar, uiAnimData.animName);
			uiAnimData.animName += '-loop';
			uiAnimData.loop = true;
			addAnimation(uiAnimData);
		});

		dropDown_anims = new FlxUIDropDownMenu(input_animName.x + 210, input_animName.y, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(anim:String) {
			dropDown_anims.selectedLabel = anim;
			setAnimUIValues();
		});

		final _tab = tab_group_anim;
		addTabTxt(_tab, input_animName, 'Animation Name:');
		addTabTxt(_tab, input_animFile, 'Animation Name In File:');
		addTabTxt(_tab, stepper_animFramerate, 'Framerate:');
		addTabTxt(_tab, input_indices, 'Animation Indices:');
		addTabTxt(_tab, dropDown_anims, 'Select Animation:');

		tab_group_anim.add(input_animName);
		tab_group_anim.add(input_animFile);
		tab_group_anim.add(stepper_animFramerate);
		tab_group_anim.add(check_loop);
		tab_group_anim.add(input_indices);

		tab_group_anim.add(updateButton);
		tab_group_anim.add(removeButton);

		tab_group_anim.add(autoButton); // For lazy people (like me)
		tab_group_anim.add(loopButton);
		
		tab_group_anim.add(dropDown_anims);

		UI_box.addGroup(tab_group_anim);
	}

	inline static function pointToArray(point:FlxPoint) {
		return [point.x, point.y];
	}

	inline static function getOffsetFromChar(char:Character, anim:String) {
		return char.animOffsets.exists(anim) ? pointToArray(char.animOffsets.get(anim)) : [0.0, 0.0];
	}

	inline function addTabTxt(_tab:FlxUI, _obj:FlxSprite, txt:String) {
		_tab.add(new FlxText(_obj.x, _obj.y - 15, 0, txt));
	}

	function addAnimation(animData:SpriteAnimation) {
		displayChar.addAnim(animData.animName, animData.animFile, animData.framerate, animData.loop, animData.indices, animData.offsets);
		ghostChar.addAnim(animData.animName, animData.animFile, animData.framerate, animData.loop, animData.indices, animData.offsets);
		updateAnimUI(animData.animName);
	}

	function updateAnimation(anim:String, animData:SpriteAnimation) {
		displayChar.setAnimData(anim, animData);
		ghostChar.setAnimData(anim, animData);
		updateAnimUI(anim);
	}

	function updateAnimUI(?lastAnim) {
		set_dropDown_anims(lastAnim);
		updateOffsetText(true);
		updateGhostAnims();
		formatJsonChar();
		setAnimUIValues();
	}

	function removeAnimation(label:String) {
		if (dropDown_anims.list.length > 0 && displayChar.animOffsets.exists(label)) {
			displayChar.animOffsets.remove(label);
			ghostChar.animOffsets.remove(label);
			displayChar.animDatas.remove(label);
			ghostChar.animDatas.remove(label);
		}
		updateAnimUI(null);
	}

	function pushJsonAnims() {
		character.anims = [];
		for (anim in displayChar.animDatas.keys()) {
			final animData = displayChar.animDatas.get(anim);
			final animOffset = displayChar.animOffsets.get(anim);
			character.anims.push({
				animName: animData.animName,
				animFile: animData.animFile,
				offsets: [animOffset.x, animOffset.y],
				loop: animData.loop,
				indices: animData.indices,
				framerate: animData.framerate,
			});
		}
	}

	function set_dropDown_anims(?lastAnim:String):Void {
		var anims:Array<String> = [];
		for (anim => charOffsets in displayChar.animOffsets) anims.push(anim);
		anims = anims.length > 0 ? anims : ['newAnim']; // Prevent null
		anims.sort(CoolUtil.sortAlphabetically);
		dropDown_anims.setData(FlxUIDropDownMenu.makeStrIdLabelArray(anims, true));

		if (lastAnim != null && anims.contains(lastAnim))
			dropDown_anims.selectedLabel = lastAnim;
	}

	function loadCharacter(newChar:String = 'bf'):Void {
		character = JsonUtil.getJson(newChar, 'characters');
		character = JsonUtil.checkJsonDefaults(Character.DEFAULT_CHARACTER, character);

		clearCharGroup();
		displayChar = new Character(bf_offset.x,bf_offset.y,newChar,false,true,character);
		ghostChar = new Character(bf_offset.x,bf_offset.y,newChar,false,true,character);
		ghostChar.alpha = 0.6;
		charGroup.add(ghostChar);
		charGroup.add(displayChar);

		updateOffsetText(true);
		setUIValues();
		updateCamOffsets();
		makeIcon();
		set_dropDown_anims();
		setAnimUIValues();
	}

	function clearCharGroup():Void {
		for (member in charGroup.members) {
			member.visible = false;
			member.kill();
			charGroup.remove(member);
			member.destroy();
		}
	}

	function clearOffsetText() {
		animsList = [];
		for (i in animsText) i.kill();
	}

	function updateOffsetText(create:Bool = false):Void {
		var _anims:Array<String> = [];
		for (i in displayChar.animOffsets.keys()) _anims.push(i);
		_anims.sort(CoolUtil.sortAlphabetically);
		
		if (create) clearOffsetText();
		var i:Int = 0;
		for (anim in _anims) {
			final charOffsets = displayChar.animOffsets.get(anim);
			var offsetText:String = '$anim: [${charOffsets.x}, ${charOffsets.y}]';
			final isCurAnim = i == curAnimIndex;
			if (create) {
				var animText:FunkinText = animsText.recycle(FunkinText);
				animText.setPosition(10, curAnimText.y+40+(22*i));
				animText.text = offsetText;
				animText.alpha = isCurAnim ? 1 : 0.6;
				animText.color = isCurAnim ? FlxColor.YELLOW : FlxColor.WHITE;
				animsText.add(animText);
				animsList.push(anim);
			}
			else {
				if (animsText.members[i] != null) {
					animsText.members[i].alpha = isCurAnim ? 1 : 0.6;
					animsText.members[i].color = isCurAnim ? FlxColor.YELLOW : FlxColor.WHITE;
					animsText.members[i].text = offsetText;
				}
				if (animsList[i] != null)
					animsList[i] = anim;
			}
			i++;
		}
	}

	function setUIValues():Void {
		check_isPlayerGame.checked = false;
		bf_offset.flipX = false;
		check_antialiasing.checked = displayChar.antialiasing;
		input_imagePath.text = character.imagePath;
		input_icon.text = character.icon;
		stepper_scale.value = character.scale;
		stepper_offsetX.value = character.charOffsets[0];
		stepper_offsetY.value = character.charOffsets[1];
		stepper_camX.value = character.camOffsets[0];
		stepper_camY.value = character.camOffsets[1];
		check_flipX.checked = character.flipX;
		check_isPlayer.checked = displayChar.isPlayerJson;
	}

	function getUpdatedAnimData():SpriteAnimation {
		var curAnim:String = dropDown_anims.selectedLabel;
		var newAnimData = JsonUtil.copyJson(displayChar.getAnimData(curAnim));
		var animOffsets:FlxPoint = displayChar.animOffsets.get(curAnim) ?? new FlxPoint();
		newAnimData.animName = input_animName.text;
		newAnimData.animFile = input_animFile.text;
		newAnimData.framerate = Std.int(stepper_animFramerate.value);
		newAnimData.loop = check_loop.checked;
		newAnimData.indices = txtToIndices(input_indices.text);
		newAnimData.offsets = [animOffsets.x, animOffsets.y];
		return newAnimData;
	}

	function setAnimUIValues():Void {
		var curAnim:String = dropDown_anims.selectedLabel;
		var curAnimData = displayChar.getAnimData(curAnim);
		input_animName.text = curAnimData.animName;
		input_animFile.text = curAnimData.animFile;
		stepper_animFramerate.value = curAnimData.framerate;
		check_loop.checked = curAnimData.loop;
		input_indices.text = indicesToTxt(curAnimData.indices);
	}

	function indicesToTxt(indices:Array<Int>):String {
		var retStr:String = '';
		for (i in 0...indices.length)
			retStr += '${indices[i]}' + (i < indices.length - 1 ? ',' : '');
		return retStr;
	}

	function txtToIndices(text:String):Array<Int> {
		if (text.length <= 0) return [];
        var intArray:Array<Int> = [];
        for (str in text.split(",")) {
            var value:Null<Int> = Std.parseInt(str);
            if (value != null)
                intArray.push(value);
        }
        return intArray;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			// Scale stepper
			if (sender == stepper_scale) {
				character.scale = stepper_scale.value;
				displayChar.scale.set(stepper_scale.value,stepper_scale.value);
				displayChar.updateHitbox();
				ghostChar.scale.set(stepper_scale.value,stepper_scale.value);
				ghostChar.updateHitbox();
				updateGhostAnims();
			}
			// World offset steppers
			else if ((sender == stepper_offsetX) || (sender == stepper_offsetY)) {
				updateFlips();
				updateWorldOffsets();
			}
			// Camera offset steppers
			else if ((sender == stepper_camX) || (sender == stepper_camY)) {
				updateCamOffsets();
			}
		}
		if (id == FlxUIInputText.INPUT_EVENT && (sender is FlxUIInputText)) {
			// Icon text input
			if ((sender == input_icon)) {
				makeIcon();
			}
		}
	}

	function makeIcon() {
		displayIcon.makeIcon(input_icon.text);
		displayIconDead.visible = !displayIcon.singleAnim;
		displayIconDead.makeIcon(input_icon.text);
		displayIconDead.animCheck();
	}

	function updateCamOffsets():Void {
		var offsetValues:Array<Int> = [Std.int(stepper_camX.value),Std.int(stepper_camY.value)];
		character.camOffsets = offsetValues;
		cam_offset.setPosition(displayChar.getMidpoint().x,displayChar.getMidpoint().y);
		cam_offset.x -= displayChar.flippedOffsets ? -offsetValues[0] : offsetValues[0];
		cam_offset.y -= offsetValues[1];
		cam_offset.flipX = (displayChar.flippedOffsets != check_isPlayer.checked);
	}

	function updateWorldOffsets():Void {
		var offsetValues:Array<Int> = [Std.int(stepper_offsetX.value),Std.int(stepper_offsetY.value)];
		character.charOffsets = offsetValues;
		//offsetValues[0] *= (displayChar.flippedOffsets) ? -1 : 1;
		displayChar.worldOffsets.set(offsetValues[0], offsetValues[1]);
		ghostChar.worldOffsets.set(offsetValues[0], offsetValues[1]);
		ghostChar.setXY(bf_offset.x,bf_offset.y);
		displayChar.setXY(bf_offset.x,bf_offset.y);
	}

	function updateFlips():Void {
		displayChar.setFlipX(check_flipX.checked);
		ghostChar.setFlipX(check_flipX.checked);
		updateGhostAnims();
		updateCamOffsets();
	}

	function updateGhostAnims(?forcedAnim:String):Void {
		var updateAnim = displayChar.animation.curAnim?.name ?? null;
		var ghostAnim = ghostChar.animation.curAnim?.name ?? null;
		if (forcedAnim != null) updateAnim = forcedAnim;

		if (updateAnim != null) {
			displayChar.playAnim(updateAnim, true);
			if (ghostAnim == null) ghostAnim = updateAnim;
		}
		ghostChar.animOffsets = displayChar.animOffsets.copy();
		ghostChar.playAnim(ghostAnim, true);
	}

	function formatJsonChar():Void {
		character.imagePath = input_imagePath.text;
		character.icon = input_icon.text;
		pushJsonAnims();
	}

	function checkFocus():Bool {
		var focusInputs = [input_icon, input_imagePath, input_animName, input_animFile, input_indices];
		for (input in focusInputs) {
			if (input.hasFocus) return true;
		}
		return false;
	}

	function changeCurAnim(change:Int = 0) {
		if (animsList.length <= 0) return;

		final animLength = animsList.length-1;
		curAnimIndex = change != 0 ?
		FlxMath.wrap(curAnimIndex + change, 0, animLength) :
		cast FlxMath.bound(curAnimIndex, 0, animLength);

		displayChar.playAnim(animsList[curAnimIndex], true);
		updateOffsetText();
	}

	override function update(elapsed:Float):Void {
		if (!checkFocus()) {
			if (FlxG.keys.justPressed.ENTER){
				openSubState(new PromptSubstate('Are you sure you want to exit?\nUnsaved characters\nwont be recovered\n\n\nPress back to cancel', function () {
					switchState(new PlayState());
				}));
			}

			var multiplier:Float = (FlxG.keys.pressed.SHIFT) ? 5 : (FlxG.keys.pressed.CONTROL) ? 0.1 : 1;
			final pressI = FlxG.keys.pressed.I;
			final pressJ = FlxG.keys.pressed.J;

			// Move the camera
			camFollow.velocity.y = (pressI || FlxG.keys.pressed.K) ? 90 * multiplier : 0;
			camFollow.velocity.y *= pressI ? -1 : 1;
			camFollow.velocity.x = (pressJ || FlxG.keys.pressed.L) ? 90 * multiplier : 0;
			camFollow.velocity.x *= pressJ ? -1 : 1;
			if (FlxG.keys.pressed.E)	camChar.zoom += 0.01 * multiplier * camChar.zoom;
			if (FlxG.keys.pressed.Q)	camChar.zoom -= 0.01 * multiplier * camChar.zoom;
			camChar.zoom = FlxMath.bound(camChar.zoom, 0.25, 10);
	
			// Change / update playing animation
			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				changeCurAnim(FlxG.keys.justPressed.W ? -1 : FlxG.keys.justPressed.S ? 1 : 0);

			final upP:Bool = FlxG.keys.justPressed.UP;
			final rightP:Bool = FlxG.keys.justPressed.RIGHT;
			final downP:Bool = FlxG.keys.justPressed.DOWN;
			final leftP:Bool = FlxG.keys.justPressed.LEFT;
	
			if (upP || downP || leftP || rightP) {
				multiplier *= (multiplier > 1) ? 2 : 1;
				var changeAnim:String = animsList[curAnimIndex];
				var changeX:Float = (leftP || rightP) ? multiplier : 0;
				var changeY:Float = (upP || downP) ? multiplier : 0;
				changeX *= (rightP) ? -1 : 1; 
				changeY *= (downP) ? -1 : 1;
				displayChar.animOffsets.get(changeAnim).x += changeX;
				displayChar.animOffsets.get(changeAnim).y += changeY;
				updateGhostAnims(changeAnim);
				updateOffsetText();
				formatJsonChar();
			}
		}
		super.update(elapsed);

		final hasAnim = displayChar.animation.curAnim != null && animsList.length > 0;
		curAnimText.text = hasAnim ? displayChar.animation.curAnim.name : 'NULL_ANIM';
		curAnimText.color = hasAnim ? FlxColor.WHITE : FlxColor.RED;
	}

	var _file:FileReference;
	private function saveLevel():Void {
		formatJsonChar();
		var data:String = FunkyJson.stringify(character, "\t");
		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.save(data.trim(), '${displayChar.curCharacter}.json');
		}
	}
}