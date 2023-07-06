function updatePost():Void {
    if (ScriptChar.animation.curAnim != null) {
        if (ScriptChar.forceDance) {
            ScriptChar.forceDance = !StringTools.startsWith(ScriptChar.animation.curAnim.name, 'hair');
        }

        switch (ScriptChar.animation.curAnim.name) {
            case 'singLEFT':            ScriptChar.danced = true;
            case 'singRIGHT':           ScriptChar.danced = false;
            case 'singUP' | 'singDOWN': ScriptChar.danced = !ScriptChar.danced;
            case 'hairFall':
                if (ScriptChar.animation.curAnim.finished) {
                    ScriptChar.forceDance = true;
                    ScriptChar.playAnim('danceRight', true);
                }
        }
    }
}