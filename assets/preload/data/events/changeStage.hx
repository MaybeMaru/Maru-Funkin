import funkin.util.modding.ModdingUtil;
import funkin.util.Stage;

function eventHit(event) {
    if (event.name == "changeStage") {
        changeStage(cachedStages.get(event.values[0]));
    }
}

function changeStage(stage) {
    State.stage.visible = false;
    State.stage.active = false;

    if (State.stage.script != null)
        State.stage.script.callback("hideStage");
    
    stage.visible = true;
    stage.active = true;
    
    stage.applyData(State.boyfriend, State.dad, State.gf);
    State.boyfriend.setXY(770, 450);
    State.dad.setXY(100, 450);
    //State.gf.setXY(400, 360);

    if (stage.script != null)
        stage.script.callback("changeStage");

    State.defaultCamZoom = stage.data.zoom;
    
    State.stage = stage;
}

var cachedStages = [
    "::" => null
];

function createPost() {
    cachedStages.set(PlayState.curStage, State.stage);
    var initLevel = Paths.currentLevel; // Get the stage assets folder
    var initStage = State.stage; // Needed so the script functions work correctly
    
    for (event in State.notesGroup.events) {
        if (event.name == "changeStage") {
            var stage = event.values[0];
            if (cachedStages.exists(stage)) continue; // Stage is already cached

            var stageData = Stage.getJson(stage);
            Paths.currentLevel = stageData.library;

            var stageScript = ModdingUtil.addScript(Paths.script('stages/' + stage), "::switchStage::" + stage);
            var stageObject = Stage.fromJson(stageData, stageScript);
            State.stage = stageObject;

            // Setup the layers crap
            stageObject.__existsAddToLayer("bf", State.boyfriendGroup);
            stageObject.__existsAddToLayer("dad", State.dadGroup);
            stageObject.__existsAddToLayer("gf", State.gfGroup);

            if (stageScript != null) {
                stageScript.set("ScriptStage", stageObject);
                stageScript.callback("create");
                stageScript.callback("createPost");
            }

            cachedStages.set(stage, stageObject);
            stageObject.visible = false;
            stageObject.active = false;
            State.add(stageObject);
        }
    }

    Paths.currentLevel = initLevel;
    State.stage = initStage;
}