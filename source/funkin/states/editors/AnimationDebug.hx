package funkin.states.editors;

import funkin.states.editors.chart.CharSelectSubstate;
import flixel.addons.display.FlxGridOverlay;

import flixel.ui.FlxButton;
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
		{name: "Character", label: 'Character'},
		{name: "Animation", label: 'Animation'},
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

	var animsText:FlxTypedGroup<FlxText>;
	var curAnimText:FunkinText;
	var charGroup:FlxSpriteGroup;

	var createChar:String = 'bf';
	public function new(createChar:String = 'bf'):Void {
		super();
		this.createChar = createChar;
	}

	override function create():Void {
		FlxG.mouse.visible = true;
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}
		camChar = new FlxCamera();
		camUI = new FlxCamera();
		camChar.bgColor.alpha = 0;
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camChar, false);
		FlxG.cameras.add(camUI);
		FlxG.cameras.setDefaultDrawTarget(camUI, true);

		var gridBG:FlxSprite = FlxGridOverlay.create(20, 20, FlxG.width*2, FlxG.height*2, true, 0xff7c7c7c,0xff6e6e6e);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter();
		add(gridBG);
		gridBG.cameras = [camChar];

		animsText = new FlxTypedGroup<FlxText>();
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

	var charButton:FlxButton;
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

		charButton = new FlxButton(10, 20, "Boyfriend", function() {
			var getChar = function () {
				var newChar:String = CharSelectSubstate.lastChar;
				charButton.text = newChar;
				loadCharacter(newChar);
			}
			openSubState(new CharSelectSubstate(getChar));
		});
		charButton.text = createChar;

		var reloadButton:FlxButton = new FlxButton(charButton.x,charButton.y+30, "Reload Image", function () {
			formatJsonChar();
			var lastGhostAnim:Null<String> = (ghostChar.animation.curAnim != null) ? ghostChar.animation.curAnim.name : null;
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

		check_isPlayer = new FlxUICheckBox(stepper_scale.x, stepper_scale.y + 20, null, null, "Is Player", 100);
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

		var saveButton:FlxButton = new FlxButton(charButton.x, UI_box.height, "Save JSON", function() {
			saveLevel();
		});
		saveButton.y -= saveButton.height*2.25;

		tab_group_char.add(new FlxText(charButton.x, charButton.y - 15, 0, 'Select Character:'));
		tab_group_char.add(new FlxText(input_imagePath.x, input_imagePath.y - 15, 0, 'Image Path:'));
		tab_group_char.add(new FlxText(input_icon.x, input_icon.y - 15, 0, 'Icon:'));
		tab_group_char.add(new FlxText(stepper_scale.x, stepper_scale.y - 15, 0, 'Scale:'));
		tab_group_char.add(new FlxText(stepper_offsetX.x, stepper_offsetX.y - 15, 0, 'Character Offsets:'));
		tab_group_char.add(new FlxText(stepper_camX.x, stepper_camX.y - 15, 0, 'Camera Offsets:'));

		tab_group_char.add(charButton);		tab_group_char.add(input_icon);
		tab_group_char.add(reloadButton);	tab_group_char.add(input_imagePath);

		tab_group_char.add(stepper_scale);	tab_group_char.add(stepper_offsetX);	tab_group_char.add(stepper_offsetY); tab_group_char.add(stepper_camX);	tab_group_char.add(stepper_camY);
		tab_group_char.add(check_isPlayer);	tab_group_char.add(check_isPlayerGame);
		tab_group_char.add(check_flipX);	tab_group_char.add(check_antialiasing);

		tab_group_char.add(saveButton);

		displayIcon = new HealthIcon();
		displayIcon.setPosition(UI_box.width);//UI_box.x + UI_box.width, UI_box.y + UI_box.width/16);
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
	var updateButton:FlxButton;

	var dropDown_anims:FlxUIDropDownMenu;

	function addAnimationUI():Void {
		var tab_group_anim = new FlxUI(null, UI_box);
		tab_group_anim.name = 'Animation';

			//	TODO ADD ANIMATION TAB

		input_animName = new FlxUIInputText(10, 20, 200, '', 8);
		input_animFile = new FlxUIInputText(input_animName.x, input_animName.y + 35, 200, '', 8);

		stepper_animFramerate = new FlxUINumericStepper(input_animFile.x, input_animFile.y + 35, 1, 24, 0, 60);
		
		check_loop = new FlxUICheckBox(stepper_animFramerate.x + 80, stepper_animFramerate.y, null, null, "Loop Anim", 100);
		check_loop.callback = function() {
				// TODO CHECK LOOP
		};

		input_indices = new FlxUIInputText(stepper_animFramerate.x, stepper_animFramerate.y + 35, 200, '', 8);

		updateButton = new FlxButton(input_indices.x, input_indices.y + 25, "Update Animation", function() {
				// TODO UPDATE ANIMATION
			displayChar.setAnimData(dropDown_anims.selectedLabel, getUpdatedAnimData());
			set_dropDown_anims(dropDown_anims.selectedLabel);
			updateOffsetText(true);
			updateGhostAnims();
			formatJsonChar();
			setAnimUIValues();
		});

		dropDown_anims = new FlxUIDropDownMenu(input_animName.x + 210, input_animName.y, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(anim:String) {
				//TODO SELECT ANIMATION
			dropDown_anims.selectedLabel = anim;
			setAnimUIValues();
		});

		tab_group_anim.add(new FlxText(input_animName.x, input_animName.y - 15, 0, 'Animation Name:'));
		tab_group_anim.add(new FlxText(input_animFile.x, input_animFile.y - 15, 0, 'Animation Name In File:'));
		tab_group_anim.add(new FlxText(stepper_animFramerate.x, stepper_animFramerate.y - 15, 0, 'Framerate:'));
		tab_group_anim.add(new FlxText(input_indices.x, input_indices.y - 15, 0, 'Animation Indices:'));
		tab_group_anim.add(new FlxText(dropDown_anims.x, dropDown_anims.y - 15, 0, 'Select Animation:'));

		tab_group_anim.add(input_animName);
		tab_group_anim.add(input_animFile);
		tab_group_anim.add(stepper_animFramerate);
		tab_group_anim.add(check_loop);
		tab_group_anim.add(input_indices);
		tab_group_anim.add(updateButton);
		tab_group_anim.add(dropDown_anims);

		UI_box.addGroup(tab_group_anim);
	}

	function set_dropDown_anims(?lastAnim:String):Void {
		var anims:Array<String> = [];
		for (anim => charOffsets in displayChar.animOffsets) {
			anims.push(anim);
		}
		dropDown_anims.setData(FlxUIDropDownMenu.makeStrIdLabelArray(anims, true));
		if (lastAnim != null && anims.contains(lastAnim)) {
			dropDown_anims.selectedLabel = lastAnim;
		}
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
		iconChangeCheck(true);
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

	function updateOffsetText(create:Bool = false):Void {
		if (create) {
			animsList = [];
			for (text in animsText) {
				text.visible = false;
				text.kill();
				animsText.remove(text);
				text.destroy();
			}
		}
		var i:Int = 0;
		for (anim => charOffsets in displayChar.animOffsets) {
			var offsetText:String = '$anim: [${charOffsets.x}, ${charOffsets.y}]';
			if (create) {
				var animText:FunkinText = new FunkinText(10, curAnimText.y+40+(22*i), offsetText, 20);
				animText.alpha = (i == curAnimIndex) ? 1 : 0.6;
				animText.color = (i == curAnimIndex) ? FlxColor.YELLOW : FlxColor.WHITE;
				animsText.add(animText);
				animsList.push(anim);
			}
			else {
				if (animsText.members[i] != null) {
					animsText.members[i].alpha = (i == curAnimIndex) ? 1 : 0.6;
					animsText.members[i].color = (i == curAnimIndex) ? FlxColor.YELLOW : FlxColor.WHITE;
					animsText.members[i].text = offsetText;
				}
				if (animsList[i] != null) {
					animsList[i] = anim;
				}
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
		var newAnimData = Reflect.copy(displayChar.getAnimData(curAnim));
		newAnimData.animName = input_animName.text;
		newAnimData.animFile = input_animFile.text;
		newAnimData.framerate = Std.int(stepper_animFramerate.value);
		newAnimData.loop = check_loop.checked;
		newAnimData.indices = txtToIndices(input_indices.text);
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
		for (i in indices) {
			retStr+='$i,';
		}
		return retStr;
	}

	function txtToIndices(text:String):Array<Int> {
		var retIndices:Array<Int> = [];
		if (text.length > 0) {
			var txtSplit = text.split(',');
			for (i in txtSplit) {
				i = i.trim();
				var nums:String = '0123456789';
				if (nums.contains(i) && i.length > 0) {
					retIndices.push(Std.parseInt(i));
				}
			}
		}
		return retIndices;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
				//	SCALE STEPPER
			if (sender == stepper_scale) {
				character.scale = stepper_scale.value;
				displayChar.scale.set(stepper_scale.value,stepper_scale.value);
				displayChar.updateHitbox();
				ghostChar.scale.set(stepper_scale.value,stepper_scale.value);
				ghostChar.updateHitbox();
				updateGhostAnims();
			}
				//	WORLD OFFSET STEPPERS
			else if ((sender == stepper_offsetX) || (sender == stepper_offsetY)) {
				updateFlips();
				updateWorldOffsets();
			}
				// CAMERA OFFSET STEPPERS
			else if ((sender == stepper_camX) || (sender == stepper_camY)) {
				updateCamOffsets();
			}
		}
	}

	var lastText:String = 'bf';
	function iconChangeCheck(forced:Bool = false):Void {
		if (input_icon.text != lastText || forced) {
			displayIcon.makeIcon(input_icon.text);
			displayIconDead.visible = !displayIcon.singleAnim;
			displayIconDead.makeIcon(input_icon.text);
			displayIconDead.animCheck();
			lastText = input_icon.text;
		}
	}

	function updateCamOffsets():Void {
		var offsetValues:Array<Int> = [Std.int(stepper_camX.value),Std.int(stepper_camY.value)];
		character.camOffsets = offsetValues;
		cam_offset.setPosition(displayChar.getMidpoint().x,displayChar.getMidpoint().y);
		cam_offset.x -= displayChar.flippedOffsets ? -offsetValues[0] : offsetValues[0];
		cam_offset.flipX = (displayChar.flippedOffsets != check_isPlayer.checked);
		cam_offset.y -= offsetValues[1];
	}

	function updateWorldOffsets():Void {
		var offsetValues:Array<Int> = [Std.int(stepper_offsetX.value),Std.int(stepper_offsetY.value)];
		character.charOffsets = offsetValues;
		offsetValues[0] *= (displayChar.flippedOffsets) ? -1 : 1;
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
		var updateAnim:Null<String> = (displayChar.animation.curAnim != null) ? displayChar.animation.curAnim.name : null;
		var ghostAnim:Null<String> = (ghostChar.animation.curAnim != null) ? ghostChar.animation.curAnim.name : null;
		if (forcedAnim != null) {
			updateAnim = forcedAnim;
		}
		if (updateAnim != null) {
			displayChar.playAnim(updateAnim, true);
			if (ghostAnim == null) {	//	TODO TEMPORAL NULL GHOST ANIM FIX
				ghostAnim = updateAnim;
			}
		}
		ghostChar.animOffsets = displayChar.animOffsets;
		ghostChar.playAnim(ghostAnim, true);
	}

	function formatJsonChar():Void {
		character.imagePath = input_imagePath.text;
		character.icon = input_icon.text;
		for (i in 0...character.anims.length) {	//	UPDATE JSON ANIM OFFSETS
			var animName:String = character.anims[i].animName;
			var animOffsets:FlxPoint = displayChar.animOffsets.get(animName);
			character.anims[i].offsets = [animOffsets.x,animOffsets.y];

			var animData:SpriteAnimation = displayChar.getAnimData(animName);
			character.anims[i].animFile = animData.animFile;
			character.anims[i].framerate = animData.framerate;
			character.anims[i].loop =  animData.loop;
			character.anims[i].indices =  animData.indices;
		}
	}

	function checkFocus():Bool {
		var focusInputs = [input_icon, input_imagePath, input_animName, input_animFile, input_indices];
		for (input in focusInputs) {
			if (input.hasFocus) {
				return true;
			}
		}
		return false;
	}

	override function update(elapsed:Float):Void {
		curAnimText.text = (displayChar.animation.curAnim != null) ? displayChar.animation.curAnim.name : 'NULL_ANIM';
		curAnimText.color = (displayChar.animation.curAnim != null) ? FlxColor.WHITE : FlxColor.RED;
		iconChangeCheck();

		if (!checkFocus()) {
			var multiplier:Float = (FlxG.keys.pressed.SHIFT) ? 5 : 1;
			if (FlxG.keys.justPressed.ENTER){
				FlxG.switchState(new PlayState());
			}
	
				//	MOVE CAMERA
			camFollow.velocity.y = (FlxG.keys.pressed.I || FlxG.keys.pressed.K) ? 90 * multiplier : 0;
			camFollow.velocity.y *= (FlxG.keys.pressed.I) ? -1 : 1;
			camFollow.velocity.x = (FlxG.keys.pressed.J || FlxG.keys.pressed.L) ? 90 * multiplier : 0;
			camFollow.velocity.x *= (FlxG.keys.pressed.J) ? -1 : 1;
			if (FlxG.keys.pressed.E)	camChar.zoom += 0.01 * multiplier * camChar.zoom;
			if (FlxG.keys.pressed.Q)	camChar.zoom -= 0.01 * multiplier * camChar.zoom;
	
				// CHANGE ANIM
			if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
				if (FlxG.keys.justPressed.W) curAnimIndex--;
				if (FlxG.keys.justPressed.S) curAnimIndex++;
				if (curAnimIndex < 0) curAnimIndex = animsList.length-1;
				if (curAnimIndex >= animsList.length) curAnimIndex = 0;
				displayChar.playAnim(animsList[curAnimIndex], true);
				updateOffsetText();
			}
	
			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
				displayChar.playAnim(animsList[curAnimIndex], true);
			}

			var upP:Bool = FlxG.keys.justPressed.UP;
			var rightP:Bool = FlxG.keys.justPressed.RIGHT;
			var downP:Bool = FlxG.keys.justPressed.DOWN;
			var leftP:Bool = FlxG.keys.justPressed.LEFT;
	
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
	}

	var _file:FileReference;
	private function saveLevel():Void {
		formatJsonChar();
		var data:String = Json.stringify(character, "\t");
		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), '${displayChar.curCharacter}.json');
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}