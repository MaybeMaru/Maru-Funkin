import funkin.util.song.Song;

var speaker:FlxSpriteExt;
var picoNotes_ = [];

function createChar():Void {
    ScriptChar.x += 120;
    speaker = new FlxSpriteExt(ScriptChar.x - 190, ScriptChar.y + 305.5);
    speaker.loadImage('characters/speakers');
    speaker.addAnim('speakers', 'speakers');
    speaker.playAnim('speakers', true);
    speaker.animation.curAnim.finish();
    ScriptChar.group.insert(0, speaker);

    speaker.flippedOffsets =  ScriptChar.flippedOffsets;
    speaker.flipX = ScriptChar.flipX;
    if (speaker.flippedOffsets)
        speaker.x += 140;

    if (Paths.exists(Paths.chart(PlayState.SONG.song, 'picospeaker'), "TEXT")) {
        picoNotes_ = Song.getSongNotes('picospeaker',  PlayState.SONG.song);
        initTankmenBG();
    }
}

function beatHit():Void {
    speaker.playAnim('speakers', true);
}

function startTimer():Void {
    speaker.playAnim('speakers', true);
}

function stepHit() {
    if (picoNotes_.length <= 0) return;
    var topNote = picoNotes_[0];
    if(Conductor.songPosition > topNote[0]) {
        var shootAnim:Int = 1;
        if (topNote[1] >= 2) shootAnim = 3;
        shootAnim += FlxG.random.int(0, 1);

        ScriptChar.playAnim('shoot' + shootAnim, true);
        ScriptChar.specialAnim = true;
        ScriptChar.forceDance = false;
        picoNotes_.shift();
    }
}

function updatePost(elapsed) {
    updateTankmenBG(elapsed);
}

// Tankmen Run
function initTankmenBG() {
    if (existsGroup('tankmanRun')) {
        for (i in 0...picoNotes_.length) {
            if (FlxG.random.bool(16)) {
                var spritePath = 'stress/tankmenShot' + (getPref('naughty') ? '' : '-censor');
                var tankman:FlxSpriteExt = new FlxSpriteExt(500, 200 + FlxG.random.int(50, 100)).loadImage(spritePath);
                tankman.scrollFactor.set(0.8,0.8);
                tankman.addAnim('run', 'tankman running0', 24, true);
                tankman.addAnim('shot', 'John Shot ' + FlxG.random.int(1,2) + '0');
                tankman.addOffset('shot', 250, 200);
                tankman.playAnim('run', true, false, FlxG.random.int(0, 10));
                tankman.scale.set(0.8,0.8);
                tankman.updateHitbox();

                tankman._dynamic.strumTime = picoNotes_[i][0];
                tankman.flipX = picoNotes_[i][1] > 2;
                tankman._dynamic.endingOffset = FlxG.random.float(50, 200);
                tankman._dynamic.tankSpeed = FlxG.random.float(0.6, 1);
                getGroup('tankmanRun').add(tankman);
            }
        }
    }
}

function updateTankmenBG(elapsed) {
    if (existsGroup('tankmanRun')) {
        for (i in getGroup('tankmanRun').members) {
            if (i.alive) {
                if (i._dynamic.strumTime - Conductor.songPosition < 1000) {
                    switch (i.animation.curAnim.name) {
                        case 'run':
                        i.visible = true;
                        i.active = true;
                        var endDirection:Float = (FlxG.width * 0.74) + i._dynamic.endingOffset;
                        if (i.flipX) {
                            endDirection = (FlxG.width * 0.02) - i._dynamic.endingOffset;
                            i.x = (endDirection + (Conductor.songPosition - i._dynamic.strumTime) * i._dynamic.tankSpeed);
                        } else i.x = (endDirection - (Conductor.songPosition - i._dynamic.strumTime) * i._dynamic.tankSpeed);
                        if (Conductor.songPosition >= i._dynamic.strumTime) i.playAnim('shot', true);
                        case 'shot': if (i.animation.curAnim.finished) {
                            getGroup('tankmanRun').members.remove(i);
                            i.destroy();
                        }
                    }
                } else {
                    i.visible = false;
                    i.active = false;
                }
            }
        }
    }
}