package funkin.objects.dialogue;

/*
	Helper to create dialogue boxes
	Doesnt contain any graphics stuff, just loads jsons n shit
*/

typedef DialoguePart = {
	var char:Int;
	var ?anim:String;
	var ?bubble:String;
	var text:String;
}

typedef DialogueJson = {
	var lines:Array<DialoguePart>;

	var ?sound:String;
	var ?music:String;

	var ?bf:String;
	var ?dad:String;
	var ?gf:String;
}

class DialogueBoxBase extends FlxTypedGroup<Dynamic> {
	public var skipIntro:Bool = false;
	public var dialogueChars:Array<String> = ['senpai-pixel', 'bf-pixel', 'gf-pixel'];
	public var jsonParsed:DialogueJson = null;

	public var targetDialogue:String = 'coolswag';
	public var curCharData:Int = 0;
	public var curCharName:String = 'senpai-pixel';
	public var curTalkAnim:String = 'talk';
	public var curBubbleType:String = '';

	//	Im too lazy to find better ways
	public var startCallback:Void->Void;
	public var skipCallback:Void->Void;
	public var nextCallback:Void->Void;
	public var endCallback:Void->Void;
	public var closeCallback:Void->Void;

	public function new():Void {
		super();

		var jsonThing:String = "";
		jsonThing = CoolUtil.getFileContent(Paths.getPath('${Song.formatSongFolder(PlayState.SONG.song)}/dialogue.json', TEXT, 'songs'));
		jsonParsed = Json.parse(jsonThing);

		var defaultDialogue:DialogueJson = {
			lines: [],
			music: (SkinUtil.curSkin == 'pixel') ? 'skins/pixel/Lunchbox' : 'breakfast',
			bf: 'bf-pixel',
			dad: 'senpai-pixel',
			gf: 'gf-pixel'
		}

		jsonParsed = JsonUtil.checkJsonDefaults(defaultDialogue, jsonParsed);
		dialogueChars = [jsonParsed.dad,jsonParsed.bf,jsonParsed.gf];
		
		if (Paths.exists(Paths.music(jsonParsed.music, true), MUSIC)) {
			FlxG.sound.playMusic(Paths.music(jsonParsed.music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
	}

	public var dialogueOpened:Bool = false;
	public var dialogueStarted:Bool = false;
	public var textFinished:Bool = false;

	override function update(elapsed:Float):Void {
		if (dialogueOpened && !dialogueStarted) {
			dialogueStarted = true;
			startDialogue();
			startCallback();
			ModdingUtil.addCall('startDialogue');
		}

		if (Controls.getKey('ACCEPT-P') && dialogueStarted && !isEnding) {
			if (!textFinished) {
				skipCallback();
				ModdingUtil.addCall('skipDialogueLine', [jsonParsed.lines[0]]);
			}
			else {
				if (jsonParsed.lines[1] == null && jsonParsed.lines[0] != null) {
					endDialogue();
					endCallback();
					ModdingUtil.addCall('endDialogue');
				}
				else {
					jsonParsed.lines.remove(jsonParsed.lines[0]);
					startDialogue();
					nextCallback();
					ModdingUtil.addCall('nextDialogueLine', [jsonParsed.lines[0]]);
				}
			}

		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function endDialogue():Void {
		if (!isEnding) {
			isEnding = true;
			if (FlxG.sound.music != null) {
				FlxG.sound.music.fadeOut(2.2, 0);
			}

			new FlxTimer().start(1.2, function(tmr:FlxTimer) {
				closeCallback();
				kill();
			});
		}
	}

	function startDialogue():Void {
		targetDialogue = jsonParsed.lines[0].text;
		curCharData = jsonParsed.lines[0].char;
		curCharName = dialogueChars[curCharData];

		curTalkAnim = (jsonParsed.lines[0].anim != null) ? jsonParsed.lines[0].anim : "talk";
		curBubbleType = (jsonParsed.lines[0].bubble != null) ? jsonParsed.lines[0].bubble : "normal";
	}
}