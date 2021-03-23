package feint.library;

import feint.forge.Component;
import feint.graphics.Sprite;

@shape('sprite')
class SpriteComponent extends Component {
  public var sprite:Sprite;

  public function new(sprite:Sprite) {
    this.sprite = sprite;
  }
}
