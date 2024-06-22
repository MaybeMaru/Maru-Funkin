package funkin.util.frontend;

import funkin.util.backend.MusicBeat;
import funkin.util.frontend.modifiers.*;
import funkin.objects.note.BasicNote;
import funkin.objects.NotesGroup;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

enum abstract Modifiers(String) from String to String {
    var COS = "COS";
    var SIN = "SIN";
    var BOOST = "BOOST";
    var DRUNK = "DRUNK";
    var TIPSY = "TIPSY";
    var BEAT = "BEAT";
    var REVERSE = "REVERSE";
    var SWAP = "SWAP";
}

class ModchartManager extends EventHandler
{
    var modifiers:Map<String, Void->BasicModifier> = [
        COS => () -> return new CosModifier(),
        SIN => () -> return new SinModifier(),
        BOOST => () -> return new BoostModifier(),
        DRUNK => () -> return new DrunkModifier(),
        TIPSY => () -> return new TipsyModifier(),
        BEAT => () -> return new BeatModifier(),
        REVERSE => () -> return new ReverseModifier(),
        SWAP => () -> return new SwapModifier()
    ];

    public var strumLines:Map<Int, StrumLineGroup> = [];

    var __postUpdate:Void->Void;
    
    public function new():Void {
        super();
        strumLines = new Map<Int, StrumLineGroup>();
        destroyOnComplete = false;

        // TODO: fix the pause frame in substates fucking all of this up
        __postUpdate = () -> {
            if (this.active) if (FlxG.state.persistentUpdate || FlxG.state.subState == null) {
                this.postUpdate(FlxG.elapsed);
            }
        }
        FlxG.signals.postUpdate.add(__postUpdate);
    }

    override function destroy():Void {
        super.destroy();
        strumLines = null;
        FlxG.signals.postUpdate.remove(__postUpdate);
        __postUpdate = null;
    }

    public static function makeManager():ModchartManager {
        return new ModchartManager();
    }

    function modifierFromName(name:String):BasicModifier {
        if (modifiers.exists(name)) {
            return modifiers.get(name)();
        }
        return null;
    }

    // TODO: add a way for scripted modifiers to get the current mod data values

    public function makeModifier(name:String, defaultValues:Array<Dynamic>, callbacks:Dynamic) {
        name = name.toUpperCase().trim();
        modifiers.set(name, () -> {
            var mod:ScriptModifier = new ScriptModifier(
                name,
                callbacks.manageStrumNote != null,
                defaultValues
            );
    
            mod.modInit = callbacks.init;
            mod.strumNote = callbacks.manageStrumNote;
            mod.strumUpdate = callbacks.manageStrumUpdate;
            mod.strumStep = callbacks.manageStrumStep;
            mod.strumBeat = callbacks.manageStrumBeat;
            mod.strumSection = callbacks.manageStrumSection;
            
            return mod;
        });
    }

    /**
      * GETTING / SETTING STRUMS
     **/

    inline public function setStrumLine(id:Int = 0, strumline:StrumLineGroup):Void {
        strumLines.set(id, strumline);
    }

    inline public function getStrumLine(id:Int = 0):StrumLineGroup {
        return strumLines.get(id);
    }

    inline public function getStrum(strumlineID:Int = 0, strumID:Int = 0):NoteStrum {
        return getStrumLine(strumlineID)?.strums[strumID] ?? null;
    }

    inline public function getStrumLineLength(id:Int = 0):Int {
        return getStrumLine(id).strums.length;
    }

    inline public function forEachStrum(strumlineID:Int = 0, callback:(NoteStrum)->Void):Void {
        getStrumLine(strumlineID).strums.fastForEach((strum, i) -> callback(strum));
    }

    /**
      * STRUM MOVEMENT
     **/

    inline public function getStrumInitPos(l:Int, s:Int):FlxPoint {
        return FlxPoint.get().copyFrom(getStrumLine(l).initPos[s]);
    }

    inline public function setStrumInitPos(l:Int, s:Int, x:Float, y:Float):Void {
        getStrumLine(l).initPos[s].set(x, y);
    }

    inline public function setStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float):Void {
        getStrum(l, s).setPosition(X,Y);
    }

    inline public function moveStrum(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0):Void {
        var strum = getStrum(l, s);
        strum.x += X;
        strum.y += Y;
    }

    inline public function offsetStrum(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0):Void {
        moveStrum(l, s, -X, -Y);
    }

    inline public function tweenStrum(l:Int = 0, s:Int = 0, ?values:Dynamic, time:Float = 1.0, ?settings:Dynamic) {
        return FlxTween.tween(getStrum(l, s), values, time, settings);
    }

    inline public function tweenStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float, time:Float = 1.0, ?ease:Dynamic) {
        var values:Dynamic = {};
        if (X != null) values.x = X;
        if (Y != null) values.y = Y;
        return tweenStrum(l, s, values, time, {ease: ease ?? FlxEase.linear});
    }

    inline public function tweenStrumInitPos(l:Int, s:Int, time:Float = 1.0, ?ease:Dynamic) {
        var initPos = getStrumInitPos(l, s);
        return tweenStrumPos(l, s, initPos.x, initPos.y, time, ease);
    }

    /**
      * STRUM MODIFIERS
     **/

    // TODO: add the typical modchart effects like drunk, wavy n all that shit

    public function setValue(value:String, ?data:Array<Dynamic>) {
        for (strumline in strumLines.keys())
            setStrumLineValue(strumline, value, data);
    }

    public function setStrumLineValue(strumline:Int, value:String, ?data:Array<Dynamic>) {
        for (i in 0...getStrumLineLength(strumline))
            setStrumValue(strumline, i, value, data);
    }

    public function setStrumValue(strumline:Int, id:Int, value:String, ?valueData:Array<Dynamic>)
    {
        var strumline = getStrumLine(strumline);
        var strum = strumline.strums[id];
        var strumMods = strum.modifiers;

        value = value.toUpperCase().trim();        
        
        var mod:BasicModifier = strumMods.get(value);
        mod ??= modifierFromName(value);

        if (mod != null)
        {
            strumMods.set(value, mod);
            valueData ??= mod.getDefaultValues();

            mod.parentStrumLine = strumline;
            mod.parentStrum = strum;
            mod.manager = this;

            valueData.fastForEach((value, i) -> {
                if (i < mod.data.length) {
                    mod.data.unsafeSet(i, value);
                }
                else {
                    mod.data.push(value);
                }
            });

            mod.init();
        }
        else
        {
            ModdingUtil.warningPrint("Couldn't find modchart value for " + '"$value"');
        }
    }

    public function getStrumValue(strumline:Int, id:Int, value:String):BasicModifier {
        return getStrum(strumline, id).modifiers.get(value.toUpperCase().trim());
    }
    
    public var speed:Float = 1.0;
    var startTick:Float = 0; // Game tick the modchart started at, for cosine stuff
    var timeElapsed:Float;

    override function start() {
        startTick = FlxG.game.ticks;
        super.start();
    }

    override function updatePosition() {
        position = Conductor.songPosition;
    }

    override function stepHit(curStep:Int) {
        for (key => strumline in strumLines) {
            strumline.strums.fastForEach((strum, i) -> {
                forEachStrumMod(strum, (mod) -> mod.manageStrumStep(strum, curStep));
            });
        }
    }

    override function beatHit(curBeat:Int) {
        for (key => strumline in strumLines) {
            strumline.strums.fastForEach((strum, i) -> {
                forEachStrumMod(strum, (mod) -> mod.manageStrumBeat(strum, curBeat));
            });
        }
    }

    override function sectionHit(curSection:Int) {
        for (key => strumline in strumLines) {
            strumline.strums.fastForEach((strum, i) -> {
                forEachStrumMod(strum, (mod) -> mod.manageStrumSection(strum, curSection));
            });
        }
    }

    var eachNoteMods:Array<BasicModifier> = [];

    // Adding modifiers after everything is already positioned :p
    function postUpdate(elapsed:Float)
    {
        timeElapsed = ((FlxG.game.ticks - startTick) * speed * 0.0001) % FunkMath.DOUBLE_PI;

        for (key => strumline in strumLines)
        {
            strumline.strums.fastForEach((strum, i) -> {
                strum.xModchart = 0;
                strum.yModchart = 0;

                eachNoteMods.clear();

                // Strum update
                forEachStrumMod(strum, (mod) -> {
                    mod.manageStrumUpdate(strum, elapsed, MusicBeat.get().curBeatDecimal);
                    if (mod.eachNote) eachNoteMods.push(mod);
                });

                // Each note update
                if (eachNoteMods.length > 0) {
                    forEachStrumNote(strum, (note) -> {
                        note.speedMult = 1;
                        eachNoteMods.fastForEach((mod, i) -> {
                            mod.manageStrumNote(strum, note);
                        });

                        if (note.isSustainNote) {
                            note.toSustain().updateSusLength();
                        }
                    });    
                }
            });
        }
    }

    // Backend crap

    inline function forEachStrumMod(strum:NoteStrum, callback:BasicModifier->Void) {
        for (key => mod in strum.modifiers) {
            callback(mod);
        }
    }

    // TODO: may rethink this
    // mainly because speedMult isnt cutting it, should make another notespeed modifier system thingy
    inline function forEachStrumNote(strum:NoteStrum, callback:BasicNote->Void) {
        NotesGroup.instance.notes.members.fastForEach((note, i) -> {
            if (note != null) if (note.targetStrum == strum) {
                callback(note);
            }
        });
    }
}