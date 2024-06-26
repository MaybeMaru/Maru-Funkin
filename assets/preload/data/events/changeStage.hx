import funkin.util.modding.ModdingUtil;
import funkin.util.Stage;

function eventHit(event) {
    if (event.name == "changeStage") {
        changeStage(event.values[0]);
    }
}

function changeStage(stageName)
{
    var stage = cachedStages.get(stageName);
    
    if (stage == null) {
        ModdingUtil.errorPrint("Stage with name " + stageName + " not found.");  
        return;
    }
    
    var lastStage = State.stage;
    lastStage.visible = false;
    lastStage.active = false;

    if (lastStage.script != null)
        lastStage.script.safeCall("hideStage");
    
    stage.visible = true;
    stage.active = true;

    // Setup the layers and positions crap
    stage.setupPlayState(State);

    if (stage.script != null)
        stage.script.safeCall("changeStage");

    State.defaultCamZoom = stage.data.zoom;
    State.stageData = stage.data;
    State.stage = stage;
}

var cachedStages = [
    "::" => null
];

function createPost() {
    cachedStages.set(PlayState.curStage, State.stage);
    var initLevel = Paths.currentLevel; // Get the stage assets folder
    var initStage = State.stage; // Needed so the script functions work correctly
    
    for (event in State.notesGroup.events)
    {
        if (event.name == "changeStage")
        {
            var stage = event.values[0];

            // Check if stage is already cached
            if (cachedStages.exists(stage))
                continue;

            var stageData = Stage.getJson(stage);
            Paths.currentLevel = stageData.library;

            var stageScript = ModdingUtil.addScript(Paths.script('stages/' + stage), "::switchStage::" + stage);
            var stageObject = Stage.fromJson(stageData, stageScript);
            State.stage = stageObject;

            if (stageScript != null) {
                stageScript.set("ScriptStage", stageObject);
                stageScript.safeCall("create");
                stageScript.safeCall("createPost");
            }

            cachedStages.set(stage, stageObject);
            stageObject.visible = false;
            stageObject.active = false;
            State.stageGroup.add(stageObject);
        }
    }

    Paths.currentLevel = initLevel;
    State.stage = initStage;
}