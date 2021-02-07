package feint.audio;

import feint.debug.FeintException;
import js.html.AudioElement;

class AudioFile {
  #if js
  var audioElement:AudioElement;
  #end

  public function new(assetId:String, volume:Float = 0.5) {
    #if js
    audioElement = cast js.Browser.document.getElementById(assetId);
    audioElement.volume = volume;
    #else
    throw new FeintException(
      'AudioNotImplemented',
      "Audio system not implemented for this platform"
    );
    #end
  }

  public function play() {
    #if js
    audioElement.play().catchError(e -> {});
    #else
    throw new FeintException(
      'AudioNotImplemented',
      "Audio system not implemented for this platform"
    );
    #end
  }
}
