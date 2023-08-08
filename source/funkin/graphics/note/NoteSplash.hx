package funkin.graphics.note;

class NoteSplash extends FlxSpriteExt {
    public var noteData:Int = 0;
    public var curSkin:String = '';

	public function new(x:Float, y:Float, noteData:Int = 0):Void {
		super(x,y);
        this.noteData = noteData;
        loadSkin();
        setupNoteSplash(x,y,noteData);
	}

	public function setupNoteSplash(X:Float, Y:Float, noteData:Int = 0, ?note:Note):Void {
        if (note != null) {
            /*if (note.skin != curSkin) {
                loadSkin(note.skin);
            }*/
            updateHitbox();
            X = note.x + NoteUtil.swagWidth/2;
            Y = note.y + NoteUtil.swagWidth/2;
            noteData = note.noteData;
        }
        this.noteData = noteData;
        alpha = 0.6;
        setPosition(X,Y);
        playAnim('splash${CoolUtil.directionArray[noteData]}');
		updateHitbox();
		x-=width/2;
		y-=height/2;
	}

    public function loadSkin(?skin:String):Void {
		skin = skin == null ? SkinUtil.curSkin : skin;
		if (curSkin != skin) {
			animOffsets = new Map<String, FlxPoint>();
			curSkin = Preferences.getPref('vanilla-ui') ? 'default' : skin;
			loadJsonInput(SkinUtil.getSkinData(curSkin).splashData, 'skins/$curSkin', false, Preferences.getPref('vanilla-ui') ? 'skins/$curSkin/splashAssets-vanilla' : null);
		}
	}

	override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (animation.curAnim != null) {
            if (animation.curAnim.finished) {
                kill();
            }
        }
	}
}