/*
    Hello and welcome to the Mau Engin template script!
    Here you can find some info on the available callbacks and pre-added crap
    Thank u for using this engine! But tbh just use Psych or some other better engines smh...
*/

/*
    PRE-ADDED HSCRIPT CLASSES
*/

// States
PlayState // PlayState class (NOT the instance)
State // Current MusicBeatState instance

MusicBeatState
MusicBeatSubstate

// Util
CoolUtil
FunkMath
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
Alphabet
TypedAlphabet
MenuAlphabet

// Gameplay Objects
Note
Sustain

// Haxe
Std
Math
Type
Reflect

@:deprecated // Scripts support StringTools now, keeping this for backwards compatibility
StringTools

// HaxeFlixel
FlxG
FlxSpriteExt
FlxSprite // Same as FlxSpriteExt, duplicate for backwards compatibility and shortcuts
FlxBackdrop
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

// hxVlc
FlxVideo
FlxVideoSprite

// Compilation Defines
BUILD_TARGET // Target the build was compiled to (windows or linux)
VIDEOS_ALLOWED // If hxvlc is enabled
DISCORD_ALLOWED // If discord presence is enabled
ZIPS_ALLOWED // If osu and quaver zips are enabled

/*
    HSCRIPT FUNCTIONS
*/

/*
    Adds a class to the script
    @param className        --> Name of the class           EX: 'FlxSprite'
    @param classPackage     --> Package of the class        EX: 'flixel'
    @param customClassName  --> Custom tag for the class    (OPTIONAL) 
*/
@:deprecated // importLib() is deprecated, use import instead
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
addSpr(spriteVar:Dynamic, spriteTag:String, onTop:Bool);

/*
    Inserts a sprite of any kind in any order to the foreground or background of PlayState
    @param spriteOrder  --> Order to insert the sprite to
    @param spriteVar    --> Sprite object to add
    @param spriteTag    --> Tag of the sprite to add
    @param onTop        --> If to add it on the foreground or background of PlayState
*/
insertSpr(spriteOrder:Int, spriteVar:Dynamic, spriteTag:String, onTop:Bool);

/*
    Returns a sprite from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to get
*/
getSpr(spriteTag:String);

/*
    Returns a sprite's order from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to get the order from
*/
getSprOrder(spriteTag:String);

/*
    Returns if a sprite from the foreground or background of PlayState exists
    @param spriteTag    --> Tag of the sprite to get
*/
existsSpr(spriteTag:String);

/*
    Removes a sprite from the foreground or background of PlayState
    @param spriteTag    --> Tag of the sprite to remove
*/
removeSpr(spriteTag:String);

/*
    Creates, adds and returns a group to the State
    @param groupTag    --> Sprite object to add
*/
makeGroup(groupTag:String);

/*
    Returns a group from PlayState
    @param groupTag     --> Tag of the sprite to get
*/
getGroup(groupTag:String);

/*
    Returns if a group from PlayState exists
    @param groupTag     --> Tag of the sprite to get
*/
existsGroup(groupTag:String);

/*
    Caches and returns a Character
    @param charName     --> Name of the character to cache
*/
cacheCharacter(charName:String);

/*
    Caches and returns an image, optionally can also precache the quad batch onto a camera
    @param imagePath     --> Path of the image to cache
    @param imageLibrary  --> Library of the image to cache (OPTIONAL)
    @param quadCamera    --> Camera to start the quad batch to (OPTIONAL)
*/
cacheImage(imagePath:String, ?imageLibrary:String, ?quadCamera:FlxCamera);

/*
    Runs a PlayState song event and adds a event script if neccesary
    @param eventName    --> Name of the event to call
    @param eventValues  --> Values of the event to call (OPTIONAL)
*/
runEvent(eventName:String, ?eventValues:Array<Dynamic>);

/*
    Returns a BlendMode type
    @param blendModeName --> Name of the blend mode EX: 'multiply'
*/
getBlendMode(blendModeName:String);

/*
    Returns a parsed json
    @param jsonString --> Contents of the json file
*/
parseJson(jsonString:String);

/*
    Returns a json as a string
    @param jsonValues --> Values of the json
    @param beautyJson --> If to compact the json or make it readable (OPTIONAL)
*/
stringifyJson(jsonValues:Dynamic, ?beautyJson:Bool);

/*
    Returns the preference variable
    @param prefName --> Identifier name of the preference EX: 'downscroll'
*/
getPref(prefName:String);

/*
    PREFERENCES TAGS:

    // Gameplay
    'botplay'           => Botplay Mode
    'practice'          => Practice Mode
    'downscroll'        => Downscroll
    'ghost-tap-style'   => Ghost Tapping ("on", "off", "dad turn")
    'stack-rating'      => Stack Ratings
    'use-const-speed'   => Use constant speed
    'const-speed'       => Constant speed

    // UI
    'framerate'         => Framerate
    'fps-counter'       => Fps Counter
    'vanilla-ui'        => Vanilla UI
    'flashing-light'    => Flashing Lights
    'camera-zoom'       => Camera Zooms

    // Performance
    'resolution'        => Game Resolution ("256x144", "640x360", "854x480", "960x540", "1024x576", "1280x720", "native")
    'antialiasing'      => Antialiasing
    'quality'           => Image LOD Quality ("high", "medium", "low", "rudy")
    'gpu-textures'      => Use GPU Textures Caching
    'song-stream'       => Use OGG Songs Streaming
    'preload'           => Preload Assets At Start

    // Miscellaneous
    'naughty'           => Naughtyness
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
    Returns a new cutscene manager instance
    @param targetSound -> Sound for the cutscene to be synced to (OPTION)
*/
makeCutsceneManager(?targetSound:FlxSound);

/*
    Returns a new modchart manager instance
*/
makeModchartManager();

/*
    Changes the current Discord client presence
    @param details      --> Small text of the Discord presence
    @param title        --> Big text of the Discord presence
    @param smallImage   --> Small image key of the Discord presence (OPTIONAL)
    @param hasTime      --> If to display the time on the presence (OPTIONAL)
    @param endTime      --> Time length to display on the presence (OPTIONAL)
*/
changeDiscordPresence(details:String, title:String, ?smallImage:String, ?hasTime:Bool, ?endTime:Float);

/*
    Switches the state to a custom state class
    @param stateName --> Name of the state in data/scripts/customStates to switch to
*/
switchCustomState(stateName:String);

/*
    Closes the script from ussage and removes it from the scripts list
    Useful for performance improvements for script without updates
*/
closeScript();

/*
    Adds and returns a new script from a path
    @param scriptPath       --> Path of the script
    @param scriptTag        --> Custom tag for the script (OPTIONAL)
*/
addScript(scriptPath:String, ?scriptTag:String);

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
    Calls a function to all scripts
    @param scriptFunction   --> Name of the function to call
    @param functionArgs     --> Arguments to use in the function (OPTIONAL)
*/
callScriptFunction(scriptFunction:String, ?functionArgs:Array<Dynamic>);

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
 * HSCRIPT PLAYSTATE CALLBACKS
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
   //   Called when a cutscene starts if State.inCutscene is true
   //   atEndSong --> if the function is being called at the end of a song
}

function createDialogue()
{
    //  Called before dialogue boxes are created
    //  You can add custom ones changing State.dialogueBox when this callback is called
}

function postCreateDialogue()
{
    //  Called after dialogue boxes are created
    //  Useful for adding custom dialogue transitions changing State.openDialogueFunc
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
   //  Called when the countdown is about to start
}

function startTimer(swagCounter:Int)
{
    //  Called every time a tick occurs in the countdown
    //  swagCounter --> The current countdown num
    //  0 = Three, 1 = Two, 2 = One, 3 = Go!
}

function startSong()
{
   //  Called when the countdown ends and the song starts
}

function endSong()
{
    //  Called when the song is finished
}

function endWeek()
{
    //  Called when the week is finished on story mode
}

function exitFreeplay()
{
    // Called when a freeplay song is finished
}

function switchSong(nextSongName:String, nextSongDifficulty:String)
{
    //  Called when the next song on the story mode playlist is loaded
    //  nextSongName --> The next song's name
    //  nextSongDifficulty --> The song's difficulty
}

function generateStrum(strumNote:NoteStrum, isPlayer:Bool)
{
   //  Called when a strumline note is created
   //  strumNote --> The created strumline note
   //  isPlayer  --> If the current strum note is part of the player's strumline
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

function sustainPress(sustain:Sustain, isPlayer:Bool)
{
    //  Called every frame a sustain from any lane is beaing pressed
    //  sustain --> Sustain pressed
    //  isPlayer --> If the note is from the player lane
}

function goodNoteHit(note:Note)
{
    //  Called every time a note is hit correctly by the player
    //  note --> Note hit by the player
}

function goodSustainPress(sustain:Sustain)
{
    // Called every frame a sustain is being pressed by the player
    // sustain --> Sustain pressed by the player
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
    //  note --> Note hit by the opponent
}

function opponentSustainPress(sustain:Sustain)
{
    // Called every frame a sustain is being pressed by the opponent
    // sustain --> Sustain pressed by the opponent
}

function updateScore(songScore:Int, songMisses:Int, songAccuracy:Float, songRating:String)
{
    //   Called every time State.scoreTxt is updated
    //   songScore --> The current score in the game
    //   songMisses --> The current number of misses in the game
    //   songAccuracy --> The current accuracy from 0% to 100% in the game
    //   songRating --> The current rating name in the game
}

function popUpScore(note:Note)
{
    //  Called when a note hit is judged, before splashes and ratings are created
    //  note --> Note to be judged
}

function cameraMovement(character:Int, camPosition:FlxPoint)
{
   //   Called when the camera moves to the player or opponent
   //   character --> Current pointed character
   //   0 = opponent, 1 = player
   //   camPosition --> New position the camera with lock into
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

function openPauseSubState()
{
    // Called when the paused substate is about to be opened
    // You can use ``return STOP_FUNCTION;`` to cancel the pause menu from opening
}

function openGameOverSubstate()
{
    // Called when the game over substate is about to be opened
    // You can use ``return STOP_FUNCTION;`` to cancel the game over
}

/*
 * GameOverSubstate callbacks
 */

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

/*
 * MusicBeatState callbacks
 */

function stateCreate()
{
    //  Called after the state has created essentials like the transition graphic
}

function stateUpdate(elapsed:Float)
{
    //   Called every frame in a state
    //   elapsed --> amount of time elapsed since the last frame
}

function stateStepHit(curStep:Int)
{
    //  Called every time there is a step hit in the state
    //  curStep --> The current step number
}

function stateBeatHit(curBeat:Int)
{
    //  Called every time there is a beat hit in the state
    //  curBeat --> The current beat number
}

function stateSectionHit(curSection:Int)
{
    //  Called every time there is a section hit in the state
    //  curSection --> The current section number
}