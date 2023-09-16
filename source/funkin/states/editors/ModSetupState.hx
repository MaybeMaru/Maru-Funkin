package funkin.states.editors;

/*
    The idea is to make a quick creator for mod templates
    just adding the essentials quickly with drag n drop and shit
*/

class ModSetupState extends MusicBeatState {
    override function create() {
        var bg = new FunkinSprite("menuDesat");
        bg.setScale(1.1,false);
        bg.color = 0xff353535;
        add(bg);

        setOnDrop(function (path:String) {
            trace("DROPPED FILE FROM: " + Std.string(path));
            var newPath = "./" + "mods/test/images/crap.png";
            File.copy(path, newPath);
        });

        super.create();
    }

    function setOnDrop(func:Dynamic) {
        FlxG.stage.window.onDropFile.removeAll();
        FlxG.stage.window.onDropFile.add(func);
    }

    override function destroy() {
        super.destroy();
        FlxG.stage.window.onDropFile.removeAll();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (getKey('BACK-P')) {
            switchState(new MainMenuState());
        }
    }
}