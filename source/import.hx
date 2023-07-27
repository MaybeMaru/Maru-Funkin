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
import funkin.util.Shader;
#if desktop
import funkin.util.Discord;
import funkin.util.Discord.DiscordClient;
import sys.io.File;
import sys.FileSystem;
#end
import funkin.util.modding.FunkScript;
import funkin.util.modding.ScriptConsole;
import funkin.util.modding.ModdingUtil;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import funkin.util.FlxColorFix;
import funkin.util.JsonUtil;
import funkin.util.Stage;
import funkin.util.SaveData;

//Note
import funkin.graphics.note.Note;
import funkin.graphics.note.NoteSplash;
import funkin.graphics.note.NoteStrum;

//PlayState Others
import funkin.graphics.Rating;
import funkin.graphics.dialogue.DialogueBoxBase;
import funkin.graphics.dialogue.PixelDialogueBox;
import funkin.graphics.dialogue.NormalDialogueBox;
import funkin.util.SwagCamera;

//Alphabet
import funkin.graphics.alphabet.Alphabet;
import funkin.graphics.alphabet.AlphabetCharacter;
import funkin.graphics.alphabet.MenuAlphabet;
import funkin.graphics.alphabet.TypedAlphabet;

//Main graphics
import funkin.graphics.FlxSpriteUtil;
import funkin.graphics.FunkinSprite;
import funkin.graphics.Character;
import funkin.graphics.FunkinText;
import funkin.graphics.HealthIcon;

//Main states
import funkin.states.LoadingState;
import funkin.states.MusicBeatState;
import funkin.states.PlayState;

//Main substates
import funkin.substates.MusicBeatSubstate;
import funkin.substates.GameOverSubstate;
import funkin.substates.PauseSubState;

//States shorcuts
import funkin.states.EmptyState;

import funkin.states.menus.FreeplayState;
import funkin.states.menus.MainMenuState;
import funkin.states.menus.StoryMenuState;
import funkin.states.menus.TitleState;
import funkin.states.options.OptionsState;

import funkin.states.editors.AnimationDebug;
import funkin.states.editors.chart.ChartingState;

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

import haxe.Json;
import flixel.graphics.frames.FlxFramesCollection;

using StringTools;