function create() {
    var bg:FunkinSprite = new FunkinSprite('weeb/evilSchoolBG', [450,350], [0.8,0.9]);
    bg.setScale(6, false);
    addSpr(bg);

    var fg:FunkinSprite = new FunkinSprite('weeb/evilSchoolFG', [450,350], [0.9, 0.95]);
    fg.setScale(6, false);
    addSpr(fg);

    initShader('thornsBg', 'bgThorns');
    initShader('thornsBg', 'fgThorns');

    setShaderInt('bgThorns', 'effectType', 1);
    setShaderInt('fgThorns', 'effectType', 0);
    setShaderFloat('bgThorns', 'uFrequency', 10);
    setShaderFloat('fgThorns', 'uFrequency', 5);

    setSpriteShader(bg, 'bgThorns');
    setSpriteShader(fg, 'fgThorns');
}

var timeElapsed:Float = 0;
function update(elapsed) {
    timeElapsed += elapsed;
    for (i in ['bgThorns', 'fgThorns']) setShaderFloat(i, 'iTime', timeElapsed);
}