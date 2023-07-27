package funkin.states.options;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

class PromptSubstate extends MusicBeatSubstate {
    public static var keyToChange:String = '';
    public static var keyBindIndex:Int = 0;

	public function new() {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

        var prompBox:FlxSprite = new FlxSprite().makeGraphic(1200, 500, 0xFFFAFD6D);
        prompBox.screenCenter();
        add(prompBox);

        var prompText:Alphabet = new Alphabet(FlxG.width/2,prompBox.y+75, 'Press any key to rebind\n\n\n\nEscape to cancel');
        prompText.alignment = CENTER;
        add(prompText);
    }

    var waitTime:Float = 0.1;   // Make sure u dont set an incorrect key by accident

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            close();
        }
        if (waitTime > 0) {
            waitTime -= elapsed;
        } else if (Controls.inGamepad() ? Controls.gamepad.firstJustPressedID() != FlxGamepadInputID.NONE : FlxG.keys.firstJustPressed() != FlxKey.NONE) {
            var keyCode:Int = Controls.inGamepad() ? Controls.gamepad.firstJustPressedID() : FlxG.keys.firstJustPressed();
            var pressedKey:String = Controls.inGamepad() ? FlxGamepadInputID.toStringMap.get(keyCode) : FlxKey.toStringMap.get(keyCode);
            if (pressedKey != 'ESCAPE') {
                Controls.setBinding(keyToChange, pressedKey, keyBindIndex);
                CoolUtil.playSound('confirmMenu');
            }
            close();
        }
    }
}