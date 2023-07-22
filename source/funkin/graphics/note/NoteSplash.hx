package funkin.graphics.note;

class NoteSplash extends FlxSpriteUtil {
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
			curSkin = skin;
			loadJsonInput(SkinUtil.getSkinData(skin).splashData, 'skins/$skin');
			/*
				if (Preferences.getPref('vanilla-ui')) {	//Semi Hardcoded vanilla splashes, fight me
					Paths.exists(Paths.image('$path-vanilla', null, true), IMAGE) ? loadImage('$path-vanilla') : loadSkin('default');
				}
			*/
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