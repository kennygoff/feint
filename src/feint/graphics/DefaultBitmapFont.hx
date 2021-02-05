package feint.graphics;

import haxe.io.Bytes;
import feint.assets.macros.AssetEmbed;

class DefaultBitmapFont extends BitmapFont {
  public static var gmsNuevoFnt:String = AssetEmbed.getEmbeddedText(
    "gmsnuevo/GenericMobileSystemNuevo.fnt"
  );
  public static var gmsNuevoPng:Bytes = AssetEmbed.getEmbeddedBytes(
    "gmsnuevo/GenericMobileSystemNuevo.png"
  );
  public static var font:BitmapFont;

  public static function getFont() {
    var embeddedAssetId = "embedded:GenericMobileSystemNuevo__png";
    AssetEmbed.embeddedAssets.set(embeddedAssetId, gmsNuevoPng);
    if (font == null) {
      font = new DefaultBitmapFont(gmsNuevoFnt, embeddedAssetId);
    }
    return font;
  }

  // TODO: Rework this
  // Crurently redefining constructor just to avoid using asset ids
  public function new(fntContent:String, textureAssetId:String) {
    super(null, textureAssetId);

    this.fontFileContent = fntContent;
    parse();
  }
}
