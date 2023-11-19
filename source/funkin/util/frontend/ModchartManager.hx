package funkin.util.frontend;
import funkin.util.frontend.CutsceneManager;

class ModchartManager extends EventHandler {
    public function new() {
        super();
    }

    public static function makeModchart() {
        return new ModchartManager();
    }
}