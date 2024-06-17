package funkin.states.options.items;

class ModItem extends SpriteGroup
{
    public var mod:ModFolder = null;
    public var enabled:Bool = true;
    
    public var enableButton:FlxSpriteExt;
    public var targetY:Float;

    public function new(mod:ModFolder):Void {
        super();
        this.mod = mod;

        var modBox:FlxSprite = new FlxSprite().makeGraphic(1,1,FlxColor.BLACK);
        modBox.antialiasing = false;
        modBox.scale.set(FlxG.width / 1.5, FlxG.height / 4);
        modBox.updateHitbox();
        modBox.alpha = 0.6;
        add(modBox);

        var modIcon = 'mods/${mod.folder}/${mod.icon}.png';
        var iconGraphic = Paths.exists(modIcon, IMAGE) ? AssetManager.cacheGraphicPath(modIcon) : Paths.image('options/' + switch(mod.folder.substring(0, 4)) {
            case "osu-": "osuMod";
            case "qua-": "quaverMod";
            default: "blankMod";
        });

        var modIcon:FlxSpriteExt = new FlxSpriteExt();
        modIcon.loadGraphic(iconGraphic);
        modIcon.setScale(0.6);
        modIcon.setPosition(15, modBox.height * 0.5 - modIcon.height * 0.5);
        add(modIcon);

        var modTitle:Alphabet = new Alphabet(modIcon.x + modIcon.width + 10, 10, mod.title, true);
        modTitle.scale.scale(0.666, 0.666); // Satan entered the chat
        add(modTitle);

        @:privateAccess
        modTitle.fieldWidth = Std.int((modBox.width * 1.2) / modTitle.alphabetFont.lodScale);
        modTitle.autoSize = false;
        modTitle.wrap = WORD(NEVER);

        var modDesc:FlxFunkText = new FlxFunkText(modTitle.x, modTitle.y + modTitle.height + 5, mod.description, FlxPoint.weak(modBox.width*0.6, modBox.height), 20);
        modDesc.font = "phantommuff_";
        modDesc.style = SHADOW(FlxPoint.weak(-2, -2), FlxColor.BLACK);
        modDesc.wordWrap = true;
        add(modDesc);

        enableButton = new FlxSpriteExt(modBox.width,modBox.height).loadImageTiled('options/modButton', 60, 58);
        enableButton.animation.add('on', [0]);
        enableButton.animation.add('off', [1]);
        add(enableButton);
        
        enableButton.width *= enableButton.lodScale;
        enableButton.height *= enableButton.lodScale;
        
        enableButton.x -= enableButton.width + 5;
        enableButton.y -= enableButton.height + 5;

        enabled = ModdingUtil.activeMods.get(mod.folder);
        updateUI();
    }

    public function updateUI():Void {
        enableButton.scale.set(1.2,1.2);
        enableButton.animation.play(enabled ? 'on' : 'off');
    }

    public function clickEnable():Void {
        ModdingUtil.setModActive(mod.folder, enabled = !enabled);
        updateUI();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        y = CoolUtil.coolLerp(y, targetY, 0.16);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(enableButton)) {
            clickEnable();
        }

        if (enableButton.scale.x > 1) {
            enableButton.scale.y = enableButton.scale.x = CoolUtil.coolLerp(enableButton.scale.x, 1, 0.2);
        }
    }
}