package funkin.util;

import flixel.util.FlxSave;

/*
	CLASS TAKEN FROM BEANBAGGER DX DEMO
*/

class SaveData
{
	public static var saves:Map<String, Dynamic> = [];
	private static var saveFile:FlxSave;
	inline public static var gameID:String = 'MARU_FUNKIN';

	private static var initSave:Bool = false;

	public static function init():Void
	{
		if (initSave)
			return;

		saveFile = new FlxSave();
		saveFile.bind(gameID + '_saveData');
		initSave = true;

		// Setup save bases
		var controlSave:Map<String, Map<String, Array<String>>> = new Map<String, Map<String, Array<String>>>();
		controlSave['keyboardBinds'] = new Map<String, Array<String>>();
		controlSave['gamepadBinds'] = new Map<String, Array<String>>();
		var prefsSave:Map<String, Dynamic> = new Map<String, Dynamic>();
		var scoresSave:Map<String, Int> = new Map<String, Int>();
		var weekUnlockSave:Map<String, Bool> = new Map<String, Bool>();
		var activeModsSave:Map<String, Bool> = new Map<String, Bool>();

		// Add save bases
		saves['controls'] = controlSave;
		saves['preferences'] = prefsSave;
		saves['scores'] = scoresSave;
		saves['weekUnlock'] = weekUnlockSave;
		saves['activeMods'] = activeModsSave;
		saves['autoSaveChart'] = "";
		saves['offset'] = 0.0;

		getDataFile();
		flushData();
	}

	public static function getDataFile():Void
	{
		var makeNewSave:Bool = false;

		if (saveFile.data.saves != null) // Check Null
		{
			for (key in saves.keys())
			{
				if (!saveFile.data.saves.exists(key)) // Check new values
				{
					makeNewSave = true;
					break;
				}
			}
		}
		else
			makeNewSave = true;

		if (makeNewSave)
		{
			trace('make new save data');
			flushData(); // Set new save
			return;
		}

		trace('gotten save data succesfully');
		saves = saveFile.data.saves; // Get save
	}

	public static function flushData():Void
	{
		saveFile.data.saves = saves;
		saveFile.flush();
	}

	public static function getSave(save:String):Dynamic
		return saves.get(save);

	public static function setSave(save:String, data:Dynamic):Void
	{
		saves.set(save, data);
		flushData();
	}
}
