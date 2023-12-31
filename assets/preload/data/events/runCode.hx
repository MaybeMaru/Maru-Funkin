import funkin.ScriptConsole;

function eventHit(event) {
    if (event.name == 'runCode') {
        ScriptConsole.runCode(event.values[0]);
    }
}