package feint.debug;

import haxe.Exception;

class FeintException extends Exception {
  public function new(name:String, message:String) {
    super('[Feint] ${name}: ${message}');
  }
}
