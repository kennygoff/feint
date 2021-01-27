package feint.renderer;

import feint.utils.Matrix;

typedef Translation = {
  var x:Float;
  var y:Float;
}

class Camera {
  public var translation(default, set):Translation = {x: 0, y: 0};
  public var rotation(default, set):Float = 0;
  public var scale(default, set):Float = 1;
  public var projection(default, null):Array<Float>;

  public function new() {
    calculate();
  }

  public function set_translation(translation:Translation):Translation {
    this.translation = translation;
    calculate();
    return translation;
  }

  public function set_rotation(rotation:Float):Float {
    this.rotation = rotation;
    calculate();
    return rotation;
  }

  public function set_scale(scale:Float):Float {
    this.scale = scale;
    calculate();
    return scale;
  }

  function calculate() {
    var translationMatrix = Matrix.translation(translation.x, translation.y);
    var rotationMatrix = Matrix.rotation(rotation);
    var scaleMatrix = Matrix.scaling(scale, scale);
    projection = Matrix.multiply(translationMatrix, rotationMatrix);
    projection = Matrix.multiply(projection, scaleMatrix);
  }
}
