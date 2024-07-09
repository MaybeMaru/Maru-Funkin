package macros;

import haxe.macro.Compiler;
using StringTools;

class PackagesMacro
{   
    public static macro function include()
    {
        final includePackages:Array<String> = [
            #if sys "sys", #end
            // Copy pasted from codename cuz im lazy lol
            "flixel.addons.api", "flixel.addons.display", "flixel.addons.effects", "flixel.addons.ui",
            "flixel.addons.plugin", "flixel.addons.text", "flixel.addons.tile", "flixel.addons.transition",
            "flixel.addons.util"
        ];

        for (pack in includePackages)
            Compiler.include(pack);

        return macro $v{null};
    }
}