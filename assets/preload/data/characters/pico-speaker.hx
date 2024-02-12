import funkin.util.song.Song;

var speaker;
var picoNotes_ = [];
var hasLayer = false;
var layer;

function createChar() {
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
}

function createPost() {
    if (Paths.exists(Paths.chart(PlayState.SONG.song, 'picospeaker'), "TEXT")) {
        picoNotes_ = Song.getSongNotes('picospeaker',  PlayState.SONG.song);
        initTankmen();
    }
}

function beatHit()
    speaker.playAnim('speakers', true);

function startTimer()
    speaker.playAnim('speakers', true);

function stepHit() {
    if (picoNotes_.length <= 0) return;
    var topNote = picoNotes_[0];
    if(Conductor.songPosition > topNote[0]) {
        var shootAnim = 1;
        if (topNote[1] >= 2) shootAnim = 3;
        shootAnim += FlxG.random.int(0, 1);

        ScriptChar.playAnim('shoot' + shootAnim, true);
        ScriptChar.specialAnim = true;
        ScriptChar.forceDance = false;
        picoNotes_.shift();
    }
}

function updatePost(e)
    updateTankmen();

// Tankmen Run
function initTankmen() {
    hasLayer = existsLayer("tankmenRun");
    
    if (hasLayer) {
        layer = getLayer("tankmenRun");
        
        for (i in 0...picoNotes_.length) {
            if (FlxG.random.bool(16)) {
                var spritePath = 'stress/tankmenShot' + (getPref('naughty') ? '' : '-censor');
                
                var tankman = new FlxSpriteExt(500, 200 + FlxG.random.int(50, 100)).loadImage(spritePath);
                tankman.flipX = picoNotes_[i][1] > 2;
                tankman.scrollFactor.set(0.9, 0.9);
                tankman.setScale(0.8);

                tankman.addAnim('run', 'tankman running0', 24, true);
                tankman.addAnim('shot', 'John Shot ' + FlxG.random.int(1,2) + '0', 24, false, null, [250, 200]);
                tankman.playAnim('run', true, false, FlxG.random.int(0, 10));

                var tankClass = tankman._dynamic;
                tankClass.strumTime = picoNotes_[i][0];
                tankClass.endingOffset = FlxG.random.float(50, 200);
                tankClass.tankSpeed = FlxG.random.float(0.6, 1);
                layer.add(tankman);
            }
        }
    }
}

function updateTankmen() {
    if (hasLayer)
    {
        for (i in layer.members)
        {
            if (i.alive)
            {
                var tankClass = i._dynamic;
                if (tankClass.strumTime - Conductor.songPosition < 1000)
                {
                    handleTankmen(i, tankClass);
                }
                else
                {
                    i.visible = false;
                    i.active = false;
                }
            }
        }
    }
}

function handleTankmen(tankman, tankClass)
{
    switch (tankman.animation.curAnim.name)
    {
        case 'run':
            tankman.visible = true;
            tankman.active = true;
        
            var diff = (Conductor.songPosition - tankClass.strumTime) * tankClass.tankSpeed;
            
            if (tankman.flipX)
            {
                var end = (FlxG.width * 0.02) - tankClass.endingOffset;
                tankman.x = end + diff;
            }
            else {
                var end = (FlxG.width * 0.74) + tankClass.endingOffset; 
                tankman.x = end - diff;
            }
        
            if (Conductor.songPosition >= tankClass.strumTime)
                tankman.playAnim('shot', true);
        
        case 'shot':
            if (tankman.animation.curAnim.finished) {
                layer.remove(tankman, true);
                tankman.destroy();
            }
    }
}