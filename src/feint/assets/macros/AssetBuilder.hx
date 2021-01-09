package feint.assets.macros;

#if macro
import Sys;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;

/**
 * Inspired by Kenton Hamaluik's post
 * @see https://blog.hamaluik.ca/posts/getting-started-with-haxe-macros/
 */
class AssetBuilder {
  public static function buildWeb() {
    final assets = copyAssets();
    generateHtml(assets);
  }

  public static function copyAssets():Array<String> {
    final clean = Context.defined("feint:clean");
    final projectRoot = Context.definedValue("feint:projectRoot");
    final cwd:String = Sys.getCwd();
    final assetSrcFolder = Path.join([cwd, projectRoot, "src", "assets"]);
    final assetsDstFolder = Path.join([cwd, projectRoot, "build/web", "assets"]);

    Sys.println("\033[1m\033[38;5;6m[Feint]\033[m \033[38;5;6mAsset Builder running...\033[m");
    Sys.println("  Copying assets from ");
    Sys.println("    " + assetSrcFolder);
    Sys.println("  to:");
    Sys.println("    " + assetsDstFolder);
    Sys.println("  ...");

    if (clean && FileSystem.exists(assetsDstFolder)) {
      deleteDirectory(assetsDstFolder);
    }

    if (!FileSystem.exists(assetsDstFolder)) {
      FileSystem.createDirectory(assetsDstFolder);
    }
    final copiedAssets = copyDirectory(assetSrcFolder, assetsDstFolder);
    Sys.println('  Copied ${copiedAssets.length} assets to ${assetsDstFolder}!');

    Sys.println("\033[1m\033[38;5;6m[Feint]\033[m \033[38;5;6mAsset Builder finished!\033[m");

    return copiedAssets;
  }

  public static function copyDirectory(source:String, destination:String):Array<String> {
    var assetsCopied:Array<String> = [];

    if (!FileSystem.exists(destination))
      FileSystem.createDirectory(destination);

    for (entry in FileSystem.readDirectory(source)) {
      var srcFile:String = Path.join([source, entry]);
      var dstFile:String = Path.join([destination, entry]);

      if (FileSystem.isDirectory(srcFile))
        assetsCopied = assetsCopied.concat(copyDirectory(srcFile, dstFile));
      else {
        File.copy(srcFile, dstFile);
        assetsCopied.push(dstFile);
      }
    }
    return assetsCopied;
  }

  public static function deleteDirectory(directory:String) {
    if (!FileSystem.exists(directory)) {
      return;
    }

    for (entry in FileSystem.readDirectory(directory)) {
      var path:String = Path.join([directory, entry]);

      if (FileSystem.isDirectory(path))
        deleteDirectory(path);
      else {
        FileSystem.deleteFile(path);
      }
    }
  }

  public static final htmlTemplate = '<!DOCTYPE html>
<html>
  <body>
    ::foreach preloadedAssets::<img id="::id::" src="::relativePath::" style="display: none;" />
    ::end::
    <script src="bin/main.js"></script>
  </body>
</html>
';

  public static function generateHtml(assetPaths:Array<String>) {
    final projectRoot = Context.definedValue("feint:projectRoot");
    final cwd:String = Sys.getCwd();
    final assetSrcFolder = Path.join([cwd, projectRoot, "src", "assets"]);
    final assetsDstFolder = Path.join([cwd, projectRoot, "build/web", "assets"]);
    final buildWebFolder = Path.join([cwd, projectRoot, "build/web"]);
    final template = new Template(htmlTemplate);

    final assets = {
      preloadedAssets: [
        for (path in assetPaths)
          ({
            id:path.split('/')
              .pop()
              .split("-")
              .join("_")
              .split(".")
              .join("__"), relativePath:path.split(buildWebFolder + "/").pop()
          })
      ]
    }

    final html = template.execute(assets);
    File.saveContent(Path.join([buildWebFolder, "index.html"]), html);
  }
}
#end
