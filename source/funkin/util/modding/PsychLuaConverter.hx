package funkin.util.modding;

/*
    Yeah better if we DONT use this..
*/

class PsychLuaConverter {
    public var finalCode:String = '\n';
    public function new() {}

    var localVariables:Array<String> = [];

    public function analyze(code:String): Void {
        for (line in code.split('\n')) {
            line = line.trim();
            if (line.endsWith(')') && !line.startsWith('function'))             line += ';';
            else if (line.startsWith('function') || line.startsWith('else'))    line += ' {';
            else if (line.startsWith('if')) {
                line = line.substr(0, line.length - 'then'.length);
                var split = line.split('if');
                line = 'if (${split[1]}) {';
            }
            line = convertExpressions(line);
            line = checkEndLine(line);
            line = replaceFunctions(line);
            finalCode += '$line\n';
        }
    }

    var endLineExceptions = ['}', '{', ';'];
    function checkEndLine(line:String) {
        var addEnd:Bool = true;
        for (i in endLineExceptions) {
            if (line.endsWith(i)) {
                addEnd = false;
                break;
            }
        }
        return (addEnd ? '\t$line;' : line);
    }

    function convertExpressions(line:String) {
        line = line.replace('~=', '!=');
        line = line.replace('local', 'var');
        line = line.replace('end', '}');
        line = line.replace('--', '//');
        
        if (line.contains('[')) { // Lua arrays start in 1
            var content = line.split('[')[1].split(']')[0];
            for (i in 0...10) {
                if (content.startsWith(Std.string(i))) {
                    var num = Std.parseInt(content) - 1;
                    line = line.split('[')[0] + '[$num]' + line.split(']')[1];
                    break;
                }
            }
        }

        return line;
    }

    var functionReplacements:Map<String, String> = [
        'onCreate' => 'create',
        'onCreatePost' => 'createPost',
        'onUpdate' => 'update',
        'onUpdatePost' => 'updatePost',
        'onBeatHit' => 'beatHit',
        'onStepHit' => 'stepHit',
        'onStartCountdown' => 'startTimer',
        'onSongStart' => 'startSong',
        'onEndSong' => 'endSong',
        'noteMissPress' => 'badNoteHit',
    ];

    function replaceFunctions(line:String) {
        for (i in functionReplacements.keys()) {
            line.replace(i, functionReplacements.get(i));
        }
        return line;
    }
}

