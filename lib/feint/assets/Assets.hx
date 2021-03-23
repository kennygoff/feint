package feint.assets;

/**
 * Asset class
 */
#if !macro
@:build(feint.assets.macros.AssetFiles.buildAssetList())
#end
class Assets {}

class FileAsset {
  public var filename:String;
  public var path:String;
}

class TextAsset extends FileAsset {}
class ImageAsset extends FileAsset {}

enum AssetType {
  Unknown;
  Text;
  Image;
}
