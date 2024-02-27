var zoomsPref;
function createPost() {
    zoomsPref = getPref('camera-zoom');
}

function eventHit(event) {
    if (event.name == 'addZoom' && zoomsPref) {
        var vals = event.values;
        if (Math.isNaN(Std.parseFloat(vals[0]))) vals[0] = 0.015;   
        if (Math.isNaN(Std.parseFloat(vals[1]))) vals[1] = 0.03;   

        State.camGame.zoom += Std.parseFloat(vals[0]);
        State.camHUD.zoom += Std.parseFloat(vals[1]);
    }
}