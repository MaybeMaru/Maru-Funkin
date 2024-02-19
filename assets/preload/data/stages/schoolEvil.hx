function createPost() {
    initShader('thornsBg', 'bgThorns');
    initShader('thornsBg', 'fgThorns');

    setShaderInt('bgThorns', 'effectType', 1);
    setShaderInt('fgThorns', 'effectType', 0);
    setShaderFloat('bgThorns', 'uFrequency', 10);
    setShaderFloat('fgThorns', 'uFrequency', 5);

    setSpriteShader(bg, 'bgThorns');
    setSpriteShader(fg, 'fgThorns');
    
    closeScript();
}