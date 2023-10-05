#if !macro
//Main shit
import funkin.Controls;
import funkin.Preferences;

//Song
import funkin.util.song.Conductor;
import funkin.util.song.Highscore;
import funkin.util.song.Song;
import funkin.util.song.WeekSetup;

//Util
import funkin.util.Paths;
import funkin.util.CoolUtil;
import funkin.util.SkinUtil;
import funkin.util.frontend.Shader;
#if desktop
import funkin.util.backend.Discord;
import funkin.util.backend.Discord.DiscordClient;
#if cpp
import hxcodec.flixel.FlxVideo;
#end
import sys.io.File;
import sys.FileSystem;
#end
import funkin.util.modding.FunkScript;
import funkin.util.modding.ScriptConsole;
import funkin.util.modding.ModdingUtil;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import funkin.util.frontend.FlxColorFix;
import funkin.util.JsonUtil;
import funkin.util.Stage;
import funkin.util.backend.SaveData;
import funkin.objects.CustomTransition;
import funkin.util.backend.FunkThread;

//Note
import funkin.objects.note.Note;
import funkin.util.NoteUtil;
import funkin.objects.note.NoteSplash;
import funkin.objects.note.NoteStrum;
import funkin.objects.note.Event;

//PlayState Others
import funkin.objects.RatingGroup;
import funkin.objects.dialogue.DialogueBoxBase;
import funkin.objects.dialogue.PixelDialogueBox;
import funkin.objects.dialogue.NormalDialogueBox;
import funkin.objects.Character;
import funkin.objects.HealthIcon;

//Alphabet
import funkin.objects.alphabet.Alphabet;
import funkin.objects.alphabet.AlphabetCharacter;
import funkin.objects.alphabet.MenuAlphabet;
import funkin.objects.alphabet.TypedAlphabet;

//Main graphics
import funkin.graphics.FlxSpriteExt;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

//Main states
import funkin.states.LoadingState;
import funkin.states.MusicBeatState;
import funkin.states.PlayState;

//Main substates
import funkin.substates.MusicBeatSubstate;
import funkin.substates.GameOverSubstate;
import funkin.substates.PauseSubState;

//States shorcuts
import funkin.states.menus.FreeplayState;
import funkin.states.menus.MainMenuState;
import funkin.states.menus.StoryMenuState;
import funkin.states.menus.TitleState;
import funkin.states.options.OptionsState;

import funkin.states.editors.AnimationDebug;
import funkin.states.editors.ChartingState;

//Haxeflixel shit
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import openfl.geom.Rectangle;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;
import flixel.math.FlxAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;

import haxe.Json;
import flixel.graphics.frames.FlxFramesCollection;

using StringTools;
#end