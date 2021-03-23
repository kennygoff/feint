package feint.library;

import feint.graphics.BitmapText;
import feint.forge.Component;

@shape('bitmapText')
class BitmapTextComponent extends Component {
  public var text:BitmapText;
  public var fontSize:Int;

  public function new(string:String, fontSize:Int) {
    text = new BitmapText(string);
    this.fontSize = fontSize;
  }
}
