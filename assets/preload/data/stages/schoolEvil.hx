function create():Void {
    var bg:FunkinSprite = new FunkinSprite('weeb/animatedEvilSchool', [400,200], [0.8,0.9]);
    bg.addAnim('idle', 'background 2', 24, true);
    bg.playAnim('idle');
    bg.scale.set(6,6);
    addSpr(bg);
}