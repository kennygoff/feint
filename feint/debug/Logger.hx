package feint.debug;

/**
 * Logging helper commands.
 * Only works with --debug flag at complation.
 */
class Logger {
  public static function error(message:String) {
    #if debug
    #if js
    js.html.Console.error('[Feint] Error: ${message}');
    #else
    trace('[Feint] Error: ${message}');
    #end
    #end
  }

  public static function warn(message:String) {
    #if debug
    #if js
    js.html.Console.warn('[Feint] Warning: ${message}');
    #else
    trace('[Feint] Warning: ${message}');
    #end
    #end
  }

  public static function info(message:String) {
    #if debug
    #if js
    js.html.Console.warn('[Feint] Info: ${message}');
    #else
    trace('[Feint] Info: ${message}');
    #end
    #end
  }
}
