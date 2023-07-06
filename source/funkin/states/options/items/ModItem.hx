package funkin.states.options.items;

class ModItem extends FlxSpriteGroup {
    public var modName:String;
    public var modID:Int;
    public var modEnabled:Bool = true;
    
    public var enableButton:FlxSprite;
    public var targetY:Float;

    public function new(modName:String, modID:Int = 0):Void {
        super();
        this.modName = modName;
        this.modID = modID;

        var modBox:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 1.5), Std.int(FlxG.height / 4), FlxColor.BLACK);
        modBox.alpha = 0.6;
        add(modBox);

        var sexPaths:Array<String> = [Paths.file('$modName/icon.png', IMAGE), Paths.image('options/blankMod', true)];
        var modIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.exists(sexPaths[0], IMAGE) ? sexPaths[0] : sexPaths[1]);
        modIcon.x += (modIcon.width/8)/2;   modIcon.y += (modIcon.height/8)/2;
        modIcon.antialiasing = true;
        modIcon.scale.set(0.6,0.6);
        modIcon.updateHitbox();
        add(modIcon);

        var modTitle:Alphabet = new Alphabet(modIcon.x + modIcon.width + 10, 10, modName, true, Std.int(modBox.width/2.5), 0.8);
        add(modTitle);

        var infoText:String = CoolUtil.getFileContent(Paths.file('$modName/info.txt'));
        var modInfo:Alphabet = new Alphabet(modTitle.x, modTitle.y + modTitle.height, infoText, false, Std.int(modBox.width/2.5*1.4), 0.6);
        add(modInfo);

        enableButton = new FlxSprite(modBox.width,modBox.height).loadGraphic(Paths.image('options/modButton'), true, 60, 58);
        enableButton.antialiasing = Preferences.getPref('antialiasing');
        enableButton.animation.add('on', [0]);
        enableButton.animation.add('off', [1]);
        enableButton.x -= enableButton.width + 5;
        enableButton.y -= enableButton.height + 5;
        add(enableButton);

        modEnabled = ModdingUtil.modFoldersMap.get(modName);
        updateUI();
    }

    public function updateUI():Void {
        enableButton.scale.set(1.2,1.2);
        enableButton.animation.play(modEnabled ? 'on' : 'off');
    }

    public function clickEnable():Void {
        modEnabled = !modEnabled;
        ModdingUtil.setModFolder(modName, modEnabled);
        updateUI();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        y = CoolUtil.coolLerp(y, targetY, 0.16);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(enableButton)) {
            clickEnable();
        }
        enableButton.scale.x = CoolUtil.coolLerp(enableButton.scale.x, 1, 0.2);
        enableButton.scale.y = CoolUtil.coolLerp(enableButton.scale.y, 1, 0.2);
    }
}