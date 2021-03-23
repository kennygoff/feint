package feint.renderer;

import feint.utils.Matrix;

typedef Translation = {
  var x:Float;
  var y:Float;
}

/**
 * Camera object representing the view projection matrix of a scene.
 */
class Camera {
  /**
   * Translation (x,y) of the camera relative to the scene
   *
   * Setter calls `calculate()` to recalculate the `projection` matrix
   */
  public var translation(default, set):Translation = {x: 0, y: 0};

  /**
   * Rotation [radians] of the camera
   *
   * Setter calls `calculate()` to recalculate the `projection` matrix
   */
  public var rotation(default, set):Float = 0;

  /**
   * Scale of the camera
   *
   * Setter calls `calculate()` to recalculate the `projection` matrix
   */
  public var scale(default, set):Float = 1;

  /**
   * View projection matrix, passed to renderer and render context for
   * calcuating the render view.
   *
   * Re-calculated with changes to `translation`, `rotation` and `scale`
   */
  public var projection(default, null):Array<Float>;

  public function new() {
    calculate();
  }

  @:dox(hide)
  public function set_translation(translation:Translation):Translation {
    this.translation = translation;
    calculate();
    return translation;
  }

  @:dox(hide)
  public function set_rotation(rotation:Float):Float {
    this.rotation = rotation;
    calculate();
    return rotation;
  }

  @:dox(hide)
  public function set_scale(scale:Float):Float {
    this.scale = scale;
    calculate();
    return scale;
  }

  /**
   * Calculate projection matrix from translation, rotation, and scale.
   */
  @:dox(show)
  function calculate() {
    var translationMatrix = Matrix.translation(translation.x, translation.y);
    var rotationMatrix = Matrix.rotation(rotation);
    var scaleMatrix = Matrix.scaling(scale, scale);
    projection = Matrix.multiply(translationMatrix, rotationMatrix);
    projection = Matrix.multiply(projection, scaleMatrix);
  }
}
