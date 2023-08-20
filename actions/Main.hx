/* 
	Original from https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/commandline/commands/Update.hx
	Sliced apart by Gabi/CrowPlexus (https://github.com/CrowPlexus/Forever-Engine-Legacy/blob/master/actions/Main.hx)
*/

package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef Library =
{
	var name:String;
	var type:String;
	var version:String;
	var dir:String;
	var ref:String;
	var url:String;
}

class Main
{
	public static function main():Void
	{
		// To prevent messing with currently installed libs
		if (!FileSystem.exists('.haxelib'))
			FileSystem.createDirectory('.haxelib');

		final libraries:Array<Library> = Json.parse(File.getContent('./actions/libraries.xml')).dependencies;

		for (lib in libraries)
		{
			// Install libs
			switch (lib.type)
			{
				case "install":
					Sys.command('haxelib --quiet install ${lib.name} ${lib.version != null ? lib.version : ""}');
				case "git":
					Sys.command('haxelib --quiet git ${lib.name} ${lib.url}');
				default:
					Sys.println('Cannot resolve library of type "${lib.type}"');
			}
		}

		Sys.exit(0); // shutting this down
	}
}
