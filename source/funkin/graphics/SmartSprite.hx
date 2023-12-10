package funkin.graphics;

/*
 * FlxSprite capable of switching between QUAD and REPEAT render modes
 */

enum RenderMode {
    QUAD;
    REPEAT;
}

class SmartSprite extends FlxRepeatSprite {
    public var renderMode:RenderMode = QUAD;

    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
        super(X, Y, SimpleGraphic, 0, 0);
    }
    
    override function drawComplex(camera:FlxCamera) {
        switch (renderMode) {
            case REPEAT: super.drawComplex(camera);
            case QUAD:
                _frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
                _matrix.translate(-origin.x, -origin.y);
                _matrix.scale(scale.x, scale.y);
        
                if (bakedRotationAngle <= 0) {
                    updateTrig();
                    if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
                }
        
                getScreenPosition(_point, camera).subtractPoint(offset);
                _point.add(origin.x, origin.y);
                _matrix.translate(_point.x, _point.y);
        
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
        }

    }
}