package feint.assets.macros;

#if macro
using Lambda;

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
  public static function buildElectron() {
    final assets = copyAssets("build/electron");
    generateHtml("build/electron", assets);
  }

  public static function buildWeb() {
    final assets = copyAssets("build/web");
    generateHtml("build/web", assets);
  }

  public static function copyAssets(buildFolder:String):Array<String> {
    final clean = Context.defined("feint:clean");
    final projectRoot = Context.definedValue("feint:projectRoot");
    final cwd:String = Sys.getCwd();
    final assetSrcFolder = Path.join([cwd, projectRoot, "assets"]);
    final assetsDstFolder = Path.join([cwd, projectRoot, buildFolder, "assets"]);

    Sys.println("\033[1m\033[38;5;6m[Feint]\033[m \033[38;5;6mAsset Builder running...\033[m");

    if (!FileSystem.exists(assetSrcFolder)) {
      Sys.println("  No assets folder found at: ");
      Sys.println("    " + assetSrcFolder);
      Sys.println("  Skipping asset builder.");
      Sys.println("\033[1m\033[38;5;6m[Feint]\033[m \033[38;5;6mAsset Builder finished!\033[m");
      return [];
    }

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

  public static final htmlTemplate = '
  <!DOCTYPE html>
  <html>
    <head>
      <title>::appTitle::</title>
      <style type="text/css">
        ::foreach webFonts::
          @font-face {
            font-family: "::name::";
            src: ::src::;
            font-weight: normal;
            font-style: normal;
          }
        ::end::
        html {
          padding: 0;
          margin: 0;
        }
        body {
          ::foreach webFonts::
            font-family: "::name::";
          ::end::
          padding: 0;
          margin: 0;
          overflow: hidden;
        }
        canvas {
          display: block;
          font-smooth: never;
          -webkit-font-smoothing: none;
        }
        ::if debug::
        #debug-ui {
          position: absolute;
          top: 0;
          left: 0;
          background: transparent;
          z-index: 2; /*  */
        }
        ::end::
      </style>
      ::foreach preloadedAssets::
        ::if (type == "css")::
          <link rel="stylesheet" type="text/css" href="::relativePath::">
        ::end::
      ::end::
    </head>
    <body>
      ::foreach preloadedAssets::
        ::if (type == "image")::
          <img id="::id::" src="::relativePath::" style="display: none;"/>
        ::elseif (type == "font")::
        ::elseif (type == "bitmapfont")::
          <script id="::id::" type="text/plain">::textContent::</script>
        ::elseif (type == "audio")::
          <audio id="::id::" src="::relativePath::" preload="auto" style="display: none;" />
        ::end::
      ::end::
      <script src="bin/main.js"></script>
    </body>
  </html>  
  ';

  public static final assetTypes = [
    "png" => "image",
    "woff" => "font",
    "woff2" => "font",
    "ttf" => "font",
    "ogg" => "audio",
    "fnt" => "bitmapfont",
    "css" => "css"
  ];

  public static function generateHtml(buildFolder:String, assetPaths:Array<String>) {
    final projectRoot = Context.definedValue("feint:projectRoot");
    final cwd:String = Sys.getCwd();
    final assetSrcFolder = Path.join([cwd, projectRoot, "assets"]);
    final assetsDstFolder = Path.join([cwd, projectRoot, buildFolder, "assets"]);
    final buildWebFolder = Path.join([cwd, projectRoot, buildFolder]);
    var appTitle = Context.definedValue("feint:appTitle");
    if (appTitle == null) {
      appTitle = 'Feint Engine';
    }
    final template = new Template(htmlTemplate);

    final webFontFiles = assetPaths.filter(
      path -> path.split('.').pop() == 'woff' || path.split('.').pop() == 'woff2');
    final webFonts:Map<String, Dynamic> = webFontFiles.fold(
      (path, fonts : Map<String, Dynamic>) -> {
        final fontName:String = path.split('/').pop().split("-").join("_").split(".").shift();
        if (fonts[fontName] == null) {
          fonts[fontName] = {
            files: [],
          };
        }
        fonts[fontName].files.push({
          relativePath: path.split(buildWebFolder + "/").pop(),
          filetype: path.split('.').pop()
        });
        return fonts;
      },
      new Map<String, Dynamic>()
    );
    final templateVars = {
      appTitle: appTitle,
      preloadedAssets: [
        for (path in assetPaths)
          {
            id: path.split('/').pop().split("-").join("_").split(".").join("__"),
            type: assetTypes.get(path.split('.').pop()),
            relativePath: path.split(buildWebFolder + "/").pop(),
            textContent: assetTypes.get(
              path.split('.').pop()
            ) == 'bitmapfont' ? File.getContent(path) : ''
          }
      ],
      webFonts: [
        for (fontName => fontObj in webFonts)
          {
            name: fontName,
            src: fontObj.files.map(
              file -> 'url("${file.relativePath}") format("${file.filetype}")'
            )
              .join(',')}
      ]
    }

    final html = template.execute(templateVars);
    File.saveContent(Path.join([buildWebFolder, "index.html"]), html);
  }
}
#end
