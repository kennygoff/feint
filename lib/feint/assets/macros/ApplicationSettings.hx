package feint.assets.macros;

import haxe.Json;

#if macro
using Lambda;

import Sys;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;
#end

typedef ApplicationConfig = {
  var title:String;
  var window:{
    var width:Int;
    var height:Int;
  };
}

class ApplicationSettings {
  public static macro function getApplicationConfig() {
    final projectRoot = Context.definedValue("feint:projectRoot");
    final cwd:String = Sys.getCwd();
    final configFile = Path.join([cwd, projectRoot, "feint.config.json"]);

    var config:ApplicationConfig = {
      title: 'Feint',
      window: {width: 640, height: 360}
    }
    if (FileSystem.exists(configFile)) {
      config = Json.parse(File.getContent(configFile));
    }

    return macro $v{config};
  }

  public static macro function getAppWidth() {
    var appWidth:Int = Std.parseInt(Context.definedValue("feint:appWidth"));

    return macro $v{appWidth};
  }

  public static macro function getAppHeight() {
    var appHeight:Int = Std.parseInt(Context.definedValue("feint:appHeight"));

    return macro $v{appHeight};
  }
}
