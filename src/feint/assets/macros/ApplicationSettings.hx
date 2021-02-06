package feint.assets.macros;

#if macro
using Lambda;

import Sys;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;
#end

class ApplicationSettings {
  public static macro function getAppWidth() {
    var appWidth:Int = Std.parseInt(Context.definedValue("feint:appWidth"));

    return macro $v{appWidth};
  }

  public static macro function getAppHeight() {
    var appHeight:Int = Std.parseInt(Context.definedValue("feint:appHeight"));

    return macro $v{appHeight};
  }
}
