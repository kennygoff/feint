package feint.assets.macros;

#if macro
using Lambda;

import haxe.macro.Context;
import haxe.macro.Expr;
import Sys;
import sys.FileSystem;
import haxe.io.Path;

class AssetFiles {
  public static function buildAssetList():Array<Field> {
    var fields:Array<Field> = Context.getBuildFields();

    var projectRoot = Context.definedValue("feint:projectRoot");
    var assetSrcFolder = Path.join([Sys.getCwd(), projectRoot, "src", "assets"]);
    var files:Array<String> = listFiles(assetSrcFolder);

    for (file in files) {
      var relativePath:String = file.substr(assetSrcFolder.length + 1);
      // map characters not allowed in variable names to ones that are
      var name:String = relativePath.split("/").pop();
      if (name == null) {
        throw 'AssetFiles.buildAssetCollection() recieved invalid filename.';
      }

      name = name.split("-").join("_").split(".").join("__");
      relativePath = "assets/" + relativePath;

      #if js
      // Use the id for the html tag
      final value = name;
      #else
      final value = relativePath;
      #end

      fields.push({
        name: name,
        doc: 'Relative path for file ${file}',
        access: [Access.APublic, Access.AStatic, Access.AInline, Access.AFinal],
        pos: Context.currentPos(),
        kind: FieldType.FVar(macro:String, macro $v{name})
      });
    }

    return fields;
  }

  static function listFiles(directory:String):Array<String> {
    if (!FileSystem.exists(directory)) {
      return [];
    }

    var files:Array<String> = [];
    for (entry in FileSystem.readDirectory(directory)) {
      var entryPath:String = Path.join([directory, entry]);

      if (FileSystem.isDirectory(entryPath)) {
        files = files.concat(listFiles(entryPath));
      } else {
        files.push(entryPath);
      }
    }
    return files;
  }
}
#end
