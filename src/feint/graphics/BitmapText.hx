package feint.graphics;

import feint.renderer.Renderer;

class BitmapText {
  public var text(default, null):String;
  public var font(default, null):BitmapFont;

  public function new(text:String, font:BitmapFont) {
    this.text = text;
    this.font = font;
  }

  public function draw(renderer:Renderer, x:Int, y:Int, fontSize:Int) {
    var xChar = 0;
    var yChar = 0;
    var scale = fontSize / font.lineHeight;
    for (charIndex in 0...text.length) {
      var char = text.charAt(charIndex);
      if (char == '\n') {
        xChar = 0;
        yChar += Math.floor(font.lineHeight * scale);
        continue;
      }
      if (char == '') {
        continue;
      }
      renderer.drawImage(
        Math.floor(x + xChar + (font.characters[char].xOffset * scale)),
        Math.floor(y + yChar + (font.characters[char].yOffset * scale)),
        font.textureAssetId,
        font.textureWidth,
        font.textureHeight,
        0,
        scale,
        0xFFFFFFFF,
        1,
        0.0,
        {
          x: font.characters[char].x,
          y: font.characters[char].y,
          width: font.characters[char].width,
          height: font.characters[char].height
        }
      );
      xChar += Math.floor(font.characters[char].xAdvance * scale);
    }
  }
}
