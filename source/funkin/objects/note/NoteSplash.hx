package funkin.objects.note;

import funkin.objects.note.BasicNote.INoteData;

class SplashGroup extends TypedGroup<NoteSplash> {
    public function new(startCache:Int = 4) {
        super();
        for (i in 0...startCache) spawnSplash();
        clearGroup();
    }

    public function clearGroup() {
        this.members.fastForEach((splash, i) -> splash.kill());
    }

	public function spawnSplash(?note:Note) {
		final splash:NoteSplash = recycle(NoteSplash);
		if (note != null) splash.setupNoteSplash(note.x, note.y, note.noteData, note);
		add(splash);
        return splash;
	}
}

class NoteSplash extends FlxSpriteExt implements INoteData
{
    public var noteData:Int8 = 0;
    public var curSkin:String = '';

	public function new(x:Float, y:Float, noteData:Int8 = 0):Void {
		super(x,y);
        this.noteData = noteData;
        loadSkin();
        alpha = 0.6;
        setupNoteSplash(x,y,noteData);
        moves = false;
	}

	public function setupNoteSplash(X:Float, Y:Float, noteData:Int8 = 0, ?note:Note):Void {
        if (note != null) {
            if (note.skin != curSkin) {
                loadSkin(note.skin);
            }
            updateHitbox();
            X = note.x + NoteUtil.noteWidth * 0.5;
            Y = note.y + NoteUtil.noteHeight * 0.5;
            noteData = note.noteData;
        }
        this.noteData = noteData;
        setPosition(X,Y);
        playAnim('splash${CoolUtil.directionArray[noteData]}');
        active = true;
		x -= width * 0.5;
		y -= height * 0.5;
	}

    public function loadSkin(?skin:String):Void {
		skin ??= SkinUtil.curSkin;

        var vanilla:Bool = Preferences.getPref('vanilla-ui');
        if (vanilla) skin = "default";
		
        if (curSkin != skin) {
            var skinData = SkinUtil.getSkinData(skin);
            if (skinData.splashData != null) {
                curSkin = skin;
                loadJsonInput(SkinUtil.getSkinData(curSkin).splashData, 'skins/$curSkin', false, vanilla ? 'skins/$curSkin/splashAssets-vanilla' : null);
            }
		}
	}

	override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (animation.curAnim != null) {
            if (animation.curAnim.finished) {
                kill();
                active = false;
            }
        }
	}
}