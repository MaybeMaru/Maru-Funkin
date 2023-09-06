package funkin.states.options.items;

class ModItem extends FlxSpriteGroup {
    public var modName:String;
    public var modEnabled:Bool = true;
    
    public var enableButton:FlxSpriteExt;
    public var targetY:Float;

    public function new(modName:String):Void {
        super();
        this.modName = modName;

        var modBox:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 1.5), Std.int(FlxG.height / 4), FlxColor.BLACK);
        modBox.alpha = 0.6;
        add(modBox);

        var aa = Preferences.getPref('antialiasing');

        var icon = Paths.file('$modName/icon.png', IMAGE);
        var modIcon:FlxSpriteExt = new FlxSpriteExt();
        modIcon.loadGraphic(Paths.exists(icon, IMAGE) ? Paths.getImage(icon) : Paths.image('options/blankMod'));
        modIcon.antialiasing = aa;
        modIcon.setScale(0.6);
        modIcon.setPosition(15, modBox.height * 0.5 - modIcon.height * 0.5);
        add(modIcon);

        var modTitle:Alphabet = new Alphabet(modIcon.x + modIcon.width + 10, 10, modName, true, Std.int(modBox.width/2), 0.666); // SATAN
        add(modTitle);

        var infoText:String = CoolUtil.getFileContent(Paths.file('$modName/info.txt'));
        var modInfo:FlxText = new FlxText(modTitle.x, modTitle.y + modTitle.height + 5, Std.int(modBox.width*0.6), infoText);
        modInfo.setFormat(Paths.font('phantommuff_'), 20, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        modInfo.borderSize = 1.333;
        add(modInfo);

        enableButton = new FlxSpriteExt(modBox.width,modBox.height).loadImageAnimated('options/modButton', 60, 58);
        enableButton.antialiasing = aa;
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

        if (enableButton.scale.x > 1) {
            enableButton.scale.x = CoolUtil.coolLerp(enableButton.scale.x, 1, 0.2);
            enableButton.scale.y = CoolUtil.coolLerp(enableButton.scale.y, 1, 0.2);
        }
    }
}