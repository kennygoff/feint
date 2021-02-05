package feint.assets.macros;

import haxe.io.Bytes;
#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

class AssetEmbed {
  public static var embeddedAssets:Map<String, Bytes> = [];

  public static macro function getEmbeddedText(file:String) {
    // get the current fields of the class
    var fields:Array<Field> = Context.getBuildFields();

    // get the path of the current current class file, e.g. "src/path/to/MyClassName.hx"
    var posInfos = Context.getPosInfos(Context.currentPos());
    var directory = Path.directory(posInfos.file);

    // get the current class information.
    var ref:ClassType = Context.getLocalClass().get();
    // path to the template. syntax: "MyClassName.template"
    var filePath:String = Path.join([directory, file]);

    // detect if template file exists
    if (FileSystem.exists(filePath)) {
      // get the file content of the template
      var fileContent:String = File.getContent(filePath);

      // return as expression
      return macro $v{fileContent};
    } else {
      return macro null;
    }
  }

  public static macro function getEmbeddedBytes(file:String) {
    // get the current fields of the class
    var fields:Array<Field> = Context.getBuildFields();

    // get the path of the current current class file, e.g. "src/path/to/MyClassName.hx"
    var posInfos = Context.getPosInfos(Context.currentPos());
    var directory = Path.directory(posInfos.file);

    // get the current class information.
    var ref:ClassType = Context.getLocalClass().get();
    // path to the template. syntax: "MyClassName.template"
    var filePath:String = Path.join([directory, file]);

    // detect if template file exists
    if (FileSystem.exists(filePath)) {
      // get the file content of the template
      var bytes:Bytes = File.getBytes(filePath);

      // return as expression
      var str = haxe.Serializer.run(bytes);
      return macro haxe.Unserializer.run($v{str});
    } else {
      return macro null;
    }
  }
}
