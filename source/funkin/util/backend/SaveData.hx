package funkin.util.backend;

import flixel.util.FlxSave;

/*
	CLASS TAKEN FROM BEANBAGGER DX DEMO
*/

typedef BindsSave = Map<String, Array<Int>>;

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
		final controlSave:Map<String, BindsSave> = new Map<String, BindsSave>();
		controlSave['keyboardBinds'] = new BindsSave();
		controlSave['gamepadBinds'] = new BindsSave();
		
		final prefsSave:Map<String, Dynamic> = new Map<String, Dynamic>();
		final scoresSave:Map<String, Int> = new Map<String, Int>();
		final weekUnlockSave:Map<String, Bool> = new Map<String, Bool>();
		final activeModsSave:Map<String, Bool> = new Map<String, Bool>();

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
			for (key in saves.keys()) { // Check new value
				if (saveFile.data.saves.exists(key))
					saves.set(key, saveFile.data.saves.get(key)); // Get saved value
				else
					saveFile.data.saves.set(key, saves.get(key)); // Add defaults
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
