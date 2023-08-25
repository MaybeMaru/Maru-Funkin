package funkin.substates;

class CharSelectSubstate extends MusicBeatSubstate {
    public static var lastChar:String = 'bf';
    var selectFunction:Void->Void = null;

    var curFolder:Int = 0;
    var curSelected:Array<Int> = [0,0];
    var iconArray:Array<Array<HealthIcon>> = [[],[]];
    var charArray:Array<Array<MenuAlphabet>> = [[],[]];
    var folderTxt:Alphabet;

	public function new(?selectFunction:Void->Void):Void {
		super();
        this.selectFunction = selectFunction;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

        folderTxt = new Alphabet(FlxG.width - 10, 10);
        folderTxt.scrollFactor.set();
        folderTxt.alignment = RIGHT;
        folderTxt.color = FlxColor.YELLOW;

        var vanillaSort = CoolUtil.getFileContent(Paths.txt("characters/characters-sort", null, false)).split(",");
        var modSort = CoolUtil.getFileContent(Paths.txt("characters/characters-sort")).split(',');
       
        var vanillaChars:Array<String> = CoolUtil.customSort(Paths.getFileList(TEXT, false, 'json', 'data/characters'), vanillaSort);
        var modChars:Array<String> = CoolUtil.customSort(Paths.getModFileList('data/characters', 'json', false), modSort);

        var listsToAdd:Array<Array<String>> = [vanillaChars, modChars];

        for (f in 0...listsToAdd.length) {
            for (i in 0...listsToAdd[f].length) {
                var list = listsToAdd[f];
                var charText:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, list[i], true);
                charText.scrollFactor.set();
                charText.targetY = i;
                charText.forceX = false;
                charText.setTargetPos();
                add(charText);
                    
                var iconName:String = Character.getCharData(list[i]).icon;
                var charIcon:HealthIcon = new HealthIcon(iconName);
                charIcon.scrollFactor.set();
                charIcon.sprTracker = charText;
                add(charIcon);

                iconArray[f].push(charIcon);
                charArray[f].push(charText);
            }
        }
        changeFolder();
        add(folderTxt);
        cameras = [CoolUtil.getTopCam()];
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (getKey('UI_UP-P'))		changeSelection(-1);
		if (getKey('UI_DOWN-P'))	changeSelection(1);
        if (getKey('UI_LEFT-P'))	changeFolder(-1);
		if (getKey('UI_RIGHT-P'))	changeFolder(1);
        if (getKey('ACCEPT-P'))     selectChar();
        else if (getKey('BACK-P'))  close();
    }
    
    function selectChar():Void {
        lastChar = charArray[curFolder][curSelected[curFolder]].text;
        if (selectFunction != null) selectFunction();
        close();
    }

    function changeFolder(change:Int = 0):Void {
        try {
            curFolder = FlxMath.wrap(curFolder + change, 0, curSelected.length - 1);
            if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);
    
            switch(curFolder) {
                case 0: folderTxt.text = 'Base game';
                case 1: folderTxt.text = 'Mods';
            }
    
            for (f in 0...charArray.length) {
                var showBool:Bool = (f == curFolder);
                for (i in 0...charArray[f].length) {
                    charArray[f][i].visible = showBool;
                    iconArray[f][i].visible = showBool;
                }
            }
            changeSelection();
        }
        catch(e) {
            trace('EMPTY FOLDER');
        }
    }

    function changeSelection(change:Int = 0):Void {
        try {
            curSelected[curFolder] = FlxMath.wrap(curSelected[curFolder] + change, 0, charArray[curFolder].length - 1);
            if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);

            for (i in 0...charArray[curFolder].length) {
                charArray[curFolder][i].targetY = i - curSelected[curFolder];
                charArray[curFolder][i].alpha = (charArray[curFolder][i].targetY == 0) ? 1 : 0.6;
                iconArray[curFolder][i].alpha = charArray[curFolder][i].alpha;
            }
        }
        catch(e) {
            trace('EMPTY FOLDER');
        }
	}
}