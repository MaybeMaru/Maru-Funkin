/*
    Hello and welcome to the Mau Engin template script!
    Here you can find some info on the available callbacks and pre-added crap
    Thank u for using this engine, but tbh use Psych or some other better engine smh...
*/

/*
    PRE-ADDED HSCRIPT CLASSES
*/

// States
PlayState // Current PlayState instance (you'll need this one most of the time)
GameVars // PlayState class (for static variables)
State // Current MusicBeatState

// Util
CoolUtil
Conductor
Paths
Preferences
Controls
Shader

// Objects
DialogueBox
PixelDialogueBox
FunkinSprite
FunkinText
Character
Note
Alphabet
TypedAlphabet
MenuAlphabet

// Haxe
Std
Math
Type
Reflect
StringTools // Scripts support StringTools now, u shouldnt need this much

// Haxeflixel
FlxG
FlxSpriteExt
FlxSprite // Same as FlxSpriteExt, duplicate for backwards compatibility and shortcuts
FlxText
FlxTypedGroup
FlxSpriteGroup
FlxGroup
FlxSound
FlxMath
FlxColor
FlxTimer
FlxTween
FlxEase
FlxTrail

/*
    HSCRIPT FUNCTIONS
*/

/*
    Adds a class to the script
    DEPRECATED!! (kinda) Youre now able to use ``import`` in scripts
    Can still be used for custom class tags until I add ``as``
    @param className        --> Name of the class           EX: 'FlxSprite'
    @param classPackage     --> Package of the class        EX: 'flixel'
    @param customClassName  --> Custom tag for the class    (OPTIONAL) 
*/
importLib(className:String, classPackage:String, ?customClassName:String);

/*
    Adds an object to the current state instance
    @param object --> Object to add
*/
add(object:Dynamic);

/*
    Inserts an object to the current state instance
    @param position --> Order to instert the object in
    @param object   --> Object to insert
*/
insert(position:Int, object:Dynamic);

/*
    Removes an object to the current state instance
    @param object --> Object to remove
*/
remove(object:Dynamic);

/*
    Sets an object to the PlayState instance object map
    @param object       --> Object to set
    @param objectTag    --> Tag of the object to set
*/
setObjMap(object:Dynamic, objectTag:String);

/*
    Adds a sprite of any kind to the foreground or background of PlayState
    @param spriteVar    --> Sprite object to add
    @param spriteTag    --> Tag of the sprite to add
    @param onTop        --> If to add it on the foreground or background of PlayState
*/
addSpr(spriteVar:Dynamic, spriteTag:String, onTop:Bool)

/*
    Inserts a sprite of any kind in any order to the foreground or background of PlayState
    @param spriteOrder  --> Order to insert the sprite to
    @param spriteVar    --> Sprite object to add
    @param spriteTag    --> Tag of the sprite to add
    @param onTop        --> If to add it on the foreground or background of PlayState
*/
insertSpr(spriteOrder:Int, spriteVar:Dynamic, spriteTag:String, onTop:Bool)

/*
    Returns a sprite from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to get
*/
getSpr(spriteTag:String)

/*
    Returns a sprite's order from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to get the order from
*/
getSprOrder(spriteTag:String)

/*
    Returns if a sprite from the foreground or background of PlayState exists
    @param spriteTag    --> Tag of the sprite to get
*/
existsSpr(spriteTag:String)

/*
    Removes a sprite from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to remove
*/
removeSpr(spriteTag:String)

/*
    Creates and adds a group to PlayState
    @param groupTag    --> Sprite object to add
*/
makeGroup(groupTag:String)

/*
    Returns a group from PlayState
    @param groupTag    --> Tag of the sprite to get
*/
getGroup(groupTag:String)

/*
    Returns if a group from PlayState exists
    @param groupTag    --> Tag of the sprite to get
*/
existsGroup(groupTag:String)

/*
    Returns a BlendMode type
    @param blendModeName --> Name of the blend mode EX: 'multiply'
*/
getBlendMode(blendModeName:String);

/*
    Returns the preference variable
    @param prefName --> Identifier name of the preference EX: 'ghost-tap'
*/
getPref(prefName:String);

/*
    PREFERENCES TAGS:

    // Miscellaneous
    'naughty'           => Naughtyness

    // Gameplay
    'botplay'           => Botplay Mode
    'practice'          => Practice Mode
    'downscroll'        => Downscroll
    'ghost-tap'         => Ghost Tapping
    'deghost-tap'       => Deghostify
    'stack-rating'      => Stack Ratings

    // UI
    'framerate'         => Framerate
    'fps-counter'       => Fps Counter
    'vanilla-ui'        => Vanilla UI
    'flashing-light'    => Flashing Lights
    'camera-zoom'       => Camera Zooms
    'antialiasing'      => Antialiasing
    'auto-pause'        => Auto Pause
*/

/*
    Returns if the asked key is pressed
    @param keyName --> Name of the key to check EX: 'NOTE_LEFT'

    NOTE:
    For key holds write the name like           'NOTE_LEFT'
    For key just presses write the name like    'NOTE_LEFT-P'
    For key releases write the name like        'NOTE_LEFT-R'
*/
getKey(keyName:String);

/*
    CONTROLS TAGS:

    // Note
    'NOTE_LEFT'
    'NOTE_DOWN'
    'NOTE_UP'
    'NOTE_RIGHT'

    // UI
    'UI_LEFT'
    'UI_DOWN'
    'UI_UP'
    'UI_RIGHT'

    // Extra
    'ACCEPT'
    'BACK'
    'PAUSE'
    'RESET'
*/

/*
    Returns a FlxSound
    @param soundPath --> Path of the sound
*/
getSound(soundPath:String);

/*
    Plays a sound
    @param soundPath --> Path of the sound
    @param soundVolume --> Volume of the sound (OPTIONAL)
*/
playSound(soundPath:String, soundVolume:Float = 1);

/*
    Pauses all sounds created using getSound() or playSound()
*/
pauseSounds();

/*
    Resumes all sounds created using getSound() or playSound()
*/
resumeSounds();

/*
    Switches the state to a custom state class
    @param stateName --> Name of the state in data/scripts/customStates to switch to
*/
switchCustomState(stateName:String);

/*
    Adds a new script
    @param scriptPath       --> Path of the script
    @param scriptTag        --> Custom tag for the script           (OPTIONAL)
    @param scriptVarKeys    --> List of names of custom variables   (OPTIONAL)
    @param scriptVars       --> List of custom variables            (OPTIONAL)
*/
addScript(scriptPath:String, ?scriptTag:String, ?scriptKeys:Array<String>, ?scriptVars:Array<Dynamic>);

/*
    Removes a loaded script
    @param scriptTag  --> Tag of the script
*/
removeScript(scriptTag:String);

/*
    Returns a variable from a script
    @param scriptTag --> Path or tag of the script
    @param scriptVar --> Name of the variable to get
*/
getScriptVar(scriptTag:String, scriptVar:String);

/*
    Calls a function from a script
    @param scriptTag        --> Path or tag of the script
    @param scriptFunction   --> Name of the function to call
    @param functionArgs     --> Arguments to use in the function (OPTIONAL)
*/
callScriptFunction(scriptTag:String, scriptFunction:String, ?functionArgs:Array<Dynamic>);

/*
    Adds a variable to all current scripts
    @param variableName    --> Name of the variable to add
    @param variableValue   --> Value of the variable to add
    @param forceVariable   --> If to force the variable even if it already exists in the script (OPTIONAL)
*/
addGlobalVar(variableName:String, variableValue:Dynamic, ?forceVariable:Bool);

/*
    Returns if a variable added using setGlobalVar() exists, DOESNT GET IT FROM THE SCRIPT!
    @param variableName    --> Name of the variable to check
*/
existsGlobalVar(variableName:String);

/*
    Adds a variable for use with getGlobalVar(), DOESNT ADD IT TO THE SCRIPT!
    @param variableName    --> Name of the variable to add
    @param variableValue   --> Value of the variable to add
*/
setGlobalVar(variableName:String, variableValue:Dynamic);

/*
    Returns a variable added using setGlobalVar(), DOESNT GET IT FROM THE SCRIPT!
    @param variableName    --> Name of the variable to add
*/
getGlobalVar(variableName:String);

/*
        HSCRIPT SHADER FUNCTIONS
*/

/*
    Initiates a fragment shader
    @param shaderPath   --> File name of the shader
    @param shaderTag    --> Custom tag for the shader (allows duplicates)   (OPTIONAL)
    @param forcedCreate --> If to force the shader to be initiated again    (OPTIONAL)
*/
initShader(shaderPath:String, ?shaderTag:String, ?forcedCreate:Bool);

/*
    Sets a shader to a FlxSprite
    @param sprite       --> Sprite to add the shader to
    @param shaderTag    --> Name or tag of the shader
*/
setSpriteShader(sprite:FlxSprite, shaderTag:String);

/*
    Sets a shader to a FlxCamera
    @param camera       --> Camera to add the shader to
    @param shaderTag    --> Name or tag of the shader
*/
setCameraShader(camera:FlxCamera, shaderTag:String);

/*
    Sets a bitmap to a shader sampler2D
    @param shaderTag        --> Name or tag of the shader
    @param variableName     --> Name of the variable to set
    @param imagePath        --> Path of the image to get bitmap data from         (OPTIONAL)
    @param bitmap           --> Alternatively, bitmap data to set the variable to (OPTIONAL)
*/
setShaderSampler2D(shaderTag:String, variableName:String, ?imagePath:String, ?bitmap:BitmapData);

/*
    Sets a float to a shader variable
    @param shaderTag        --> Name or tag of the shader
    @param variableName     --> Name of the variable to set
    @param floatValue       --> Float value to set the variable to
*/
setShaderFloat(shaderTag:String, variableName:String, floatValue:Float);

/*
    Sets a int to a shader variable
    @param shaderTag        --> Name or tag of the shader
    @param variableName     --> Name of the variable to set
    @param intValue         --> Int value to set the variable to
*/
setShaderInt(shaderTag:String, variableName:String, intValue:Int);

/*
    Sets a bool to a shader variable
    @param shaderTag        --> Name or tag of the shader
    @param variableName     --> Name of the variable to set
    @param boolValue        --> Bool value to set the variable to
*/
setShaderBool(shaderTag:String, variableName:String, boolValue:Bool);

/*
    Sets a vector to a shader variable
    @param shaderTag        --> Name or tag of the shader
    @param variableName     --> Name of the variable to set
    @param vectorValue        --> vector value to set the variable to
*/
setShaderVector(shaderTag:String, variableName:String, vectorValue:Array<Int, Float, Bool>);

/*
    HSCRIPT PLAYSTATE CALLBACKS
*/

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

function postCreateDialogue()
{
    //  Called after dialogue boxes are created
    //  Useful for adding custom dialogue transitions changing PlayState.openDialogueFunc
}

function startDialogue()
{
    // Called when the dialogue box finishes opening and dialogue starts
}

function nextDialogueLine()
{
    // Called when the user goes to the next dialogue section
}

function skipDialogueLine()
{
    // Called when a dialogue section is skipped in the middle of talking
}

function endDialogue()
{
    // Called when the last dialogue section is pressed
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

function endWeek()
{
    //  Called when the week is finished on story mode
}

function switchSong(nextSongName:String, nextSongDifficulty:String)
{
    // Called when the next song on the story mode playlist is loaded
    //   nextSongName --> The next song's name
    //   nextSongDifficulty --> The song's difficulty
}

function generateStaticArrow(babyArrow:NoteStrum)
{
   //   Called when a strumline note is created
   //   babyArrow --> The created strumline note
}

function generateSong(songData:SwagSong)
{
    //  Called when notes and music files are loaded
    //  songData --> Song data about to be loaded in game
}

function noteHit(note:Note, isPlayer:Bool)
{
    //  Called when a note from any lane is hit correctly
    //  note --> Note hit
    //  isPlayer --> If the note is from the player lane
}

function sustainPress(note:Note, isPlayer:Bool)
{
    //  Called every frame a sustain note from any lane is beaing pressed
    //  note --> Note pressed
    //  isPlayer --> If the note is from the player lane
}

function goodNoteHit(note:Note)
{
    //  Called every time a note is hit correctly by the player
    //  note --> Note hit by the player
}

function goodSustainPress(note:Note)
{
    // Called every frame a sustain note is being pressed by the player
    // note --> Note pressed by the player
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

function opponentNoteHit(note:Note)
{
    //  Called every time a note is hit by the opponent
    //  daNote --> Note hit by the opponent
}

function opponentSustainPress(note:Note)
{
    // Called every frame a sustain note is being pressed by the opponent
    // note --> Note pressed by the opponent
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

function openGameOverSubstate()
{
    // Called when the game over substate is about to be opened
    // You can use ``return STOP_FUNCTION;`` to cancel the game over
}

function startGameOver()
{
    // Called when the game over substate is created
}

function musicGameOver()
{
    // Called when the game over music starts playing
}

function resetGameOver()
{
    // Called when the player restarts the song on game over
}

function exitGameOver()
{
    // Called when the player exits the song on game over
}

function beatHitGameOver(curBeat:Int)
{
    //  Called every time there is a beat hit in the game over music
    //  curBeat --> The current beat number
}

function stateCreate()
{
    
}

function stateUpdate(elapsed:Float)
{
    
}

function stateStepHit()
{
    
}

function stateBeatHit()
{
    
}

function stateSectionHit()
{
    
}