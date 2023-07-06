/*
    Hello and welcome to the Mau Engin template script!
    Here you can find some info on the available callbacks and pre-added crap
    Thank u for using this engine, but tbh use Psych or some other better engine smh...
*/

//  HSCRIPT FUNCTIONS

/*
    Adds to the hscript interpreter a class
    @param className    --> Name of the class       EX: 'FlxSprite'
    @param classPackage --> Package of the class    EX: 'flixel'
*/
importLib(className:String, classPackage:String);

/*
    Adds a FunkinSprite to the foreground or background of PlayState
    @param spriteVar    --> FunkinSprite object to add
    @param spriteTag    --> Tag of the sprite to add
    @param onTop        --> If to add it on the foreground or background of PlayState
*/
addSpr(spriteVar:FunkinSprite, spriteTag:String, onTop:Bool)

/*
    Returns a FunkinSprite from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to get
*/
getSpr(spriteTag:String)

/*
    Returns a BlendMode type
    @param blendModeName --> Name of the blend mode EX: 'multiply'
*/
getBlendMode(blendModeName:String);

/*
    Returns a WiggleEffectType
    @param wiggleName --> Name of the wiggle type EX: 'heat_wave_horizontal'
*/
getWiggleEffectType(wiggleName:String);

/*
    Returns the preference variable
    @param prefName --> Identifier name of the preference EX: 'ghost-tap'
*/
getPref(prefName:String);

/*
    Returns if the asked key is pressed
    @param keyName --> Name of the key to check EX: 'NOTE_LEFT'

    NOTE:
    For key holds write the name like           'NOTE_LEFT'
    For key just presses write the name like    'NOTE_LEFT-P'
    For key releases write the name like        'NOTE_LEFT-R'
*/
getKey(keyName:String);

//  PLAYSTATE CALLBACKS

function create()
{
    //  Called after all scripts are loaded before adding PlayState objects like characters and UI
}

function createPost()
{
   //   Called after all PlayState objects are added
}

function update(elapsed:Float)
{
   //   Called every frame
   //   elapsed --> amount of time elapsed since the last frame
}

function updatePost(elapsed:Float)
{
    //   Called every frame after all the PlayState functions
    //   elapsed --> amount of time elapsed since the last frame
}

function destroy()
{
    //  Called when PlayState closes
}

function startCutscene(atEndSong:Bool)
{
   //   Called when a cutscene starts if PlayState.inCutscene is true
   //   atEndSong --> if the function is being called at the end of a song
}

function createDialogue()
{
    //  Called before dialogue boxes are created
    //  You can add custom ones changing PlayState.dialogueBox when this callback is called
}

function startCountdown()
{
   //   Called when the countdown is about to start
}

function startTimer(swagCounter:Int)
{
    //  Called every time a tick occurs in the countdown
    //  swagCounter --> The current countdown num
    //  0 = Three, 1 = Two, 2 = One, 3 = Go!
}

function startSong()
{
   //   Called when the countdown ends and the song starts
}

function endSong()
{
    //  Called when the song is finished
}

function generateStaticArrow(babyArrow:NoteStrum)
{
   //   Called when a strumline note is created
   //   babyArrow --> The created strumline note
}

function goodNoteHit(note:Note)
{
    //  Called every time a note is hit correctly by the player
    //  note --> Note hit by the player
}

function badNoteHit(direction:Int)
{
    //  Called when a key is pressed with ghost tapping off
    //  direction --> Note data of the pressed key
    //  0 = Left, 1 = Down, 2 = Up, 3 = Right
}

function noteMiss(noteMissed:Note)
{
    //  Called when a note goes off screen without being pressed
    //  noteMissed --> The missed note
}

function opponentNoteHit(daNote:Note)
{
    //  Called every time a note is hit by the opponent
    //  daNote --> Note hit by the opponent
}

function updateScore(songScore:Int)
{
   //   Called every time PlayState.scoreTxt is updated
   //   songScore --> The current score in the game
}

function popUpScore(daNote:Note)
{
    //  Called when a note hit is judged, before splashes and ratings are created
    //  daNote --> Note to be judged
}

function cameraMovement(character:Int)
{
   //   Called when the camera moves to the player or opponent
   //   character --> Current pointed character
   //   0 = opponent, 1 = player
}

function stepHit(curStep:Int)
{
    //  Called every time there is a step hit in the song
    //  curStep --> The current step number
}

function beatHit(curBeat:Int)
{
    //  Called every time there is a beat hit in the song
    //  curBeat --> The current beat number
}

function sectionHit(curSection:Int)
{
    //  Called every time there is a section hit in the song
    //  curSection --> The current section number
}