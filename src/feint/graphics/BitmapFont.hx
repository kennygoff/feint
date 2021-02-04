package feint.graphics;

using StringTools;

typedef Padding = {
  var up:Int;
  var down:Int;
  var left:Int;
  var right:Int;
}

typedef Spacing = {
  var horizontal:Int;
  var vertical:Int;
}

typedef CharacterClip = {
  var x:Int;
  var y:Int;
  var width:Int;
  var height:Int;
  var xOffset:Int;
  var yOffset:Int;
  var xAdvance:Int;
}

class BitmapFont {
  public var name(default, null):String;
  public var size(default, null):Int;
  public var lineHeight(default, null):Int;
  public var baseline(default, null):Int;
  public var textureWidth(default, null):Int;
  public var textureHeight(default, null):Int;
  public var characters(default, null):Map<String, CharacterClip> = [];

  var padding:Padding;
  var spacing:Spacing;

  var fontAssetId:String;

  public var textureAssetId(default, null):String;

  var fontFileContent:String;

  public function new(fontAssetId:String, textureAssetId:String) {
    this.fontAssetId = fontAssetId;
    this.textureAssetId = textureAssetId;

    load();
    parse();
  }

  function load() {
    #if js
    fontFileContent = cast js.Browser.document.getElementById(fontAssetId).textContent;
    #else
    throw new FeintException(
      'BitmapFontNotImplemented',
      "Bitmap Fonts not implemented for this platform"
    );
    #end
  }

  function parse() {
    var lines = fontFileContent.split("\n");
    for (line in lines) {
      if (line.substr(0, 4) == "info") {
        parseInfo(line.substr(5));
      } else if (line.substr(0, 6) == "common") {
        parseCommon(line.substr(7));
      } else if (line.substr(0, 4) == "page") {
        // parsePage
      } else if (line.substr(0, 5) == "chars") {
        // parseChars
      } else if (line.substr(0, 4) == "char") {
        parseChar(line.substr(5));
      } else if (line.substr(0, 8) == "kernings") {
        // parseKernings
      }
    }
  }

  function parseInfo(line:String) {
    var index:Int = 0;

    while (index < line.length) {
      var eqPos = line.indexOf('=', index);
      var property = line.substring(index, eqPos).replace(' ', '');
      var value:String;
      if (line.charAt(eqPos + 1) == "\"") {
        var openQuotePos = eqPos + 1;
        var endQuotePos = line.indexOf("\"", eqPos + 2);
        value = line.substring(openQuotePos + 1, endQuotePos);
        index = endQuotePos + 1;
      } else {
        var spacePos = line.indexOf(" ", eqPos);
        if (spacePos != -1) {
          value = line.substring(eqPos + 1, spacePos);
        } else {
          value = line.substring(eqPos + 1);
        }
        index = spacePos + 1;
      }

      switch (property) {
        case "face":
          name = value;
        case "size":
          size = Std.parseInt(value);
        case "padding":
          var pads = value.split(",");
          padding = {
            up: Std.parseInt(pads[0]),
            down: Std.parseInt(pads[1]),
            left: Std.parseInt(pads[2]),
            right: Std.parseInt(pads[3])
          };
        case "spacing":
          var spaces = value.split(",");
          trace(value);
          trace(spaces);
          spacing = {
            horizontal: Std.parseInt(spaces[0]),
            vertical: Std.parseInt(spaces[1]),
          };
      }

      if (index == 0) {
        break;
      }
    }
  }

  function parseCommon(line:String) {
    var index:Int = 0;

    while (index < line.length) {
      var eqPos = line.indexOf('=', index);
      var property = line.substring(index, eqPos).replace(' ', '');
      var value:String;
      if (line.charAt(eqPos + 1) == "\"") {
        var openQuotePos = eqPos + 1;
        var endQuotePos = line.indexOf("\"", eqPos + 2);
        value = line.substring(openQuotePos + 1, endQuotePos);
        index = endQuotePos + 1;
      } else {
        var spacePos = line.indexOf(" ", eqPos);
        if (spacePos != -1) {
          value = line.substring(eqPos + 1, spacePos);
        } else {
          value = line.substring(eqPos + 1);
        }
        index = spacePos + 1;
      }

      switch (property) {
        case "lineHeight":
          lineHeight = Std.parseInt(value);
        case "base":
          baseline = Std.parseInt(value);
        case "scaleW":
          textureWidth = Std.parseInt(value);
        case "scaleH":
          textureHeight = Std.parseInt(value);
      }

      if (index == 0) {
        break;
      }
    }
  }

  function parseChar(line:String) {
    var index:Int = 0;

    var character:CharacterClip = {
      x: 0,
      y: 0,
      width: 0,
      height: 0,
      xOffset: 0,
      yOffset: 0,
      xAdvance: 0
    };
    var charId:String = '';
    while (index < line.length) {
      var eqPos = line.indexOf('=', index);
      var property = line.substring(index, eqPos).replace(' ', '');
      var value:String;
      if (line.charAt(eqPos + 1) == "\"") {
        var openQuotePos = eqPos + 1;
        var endQuotePos = line.indexOf("\"", eqPos + 2);
        value = line.substring(openQuotePos + 1, endQuotePos);
        index = endQuotePos + 1;
      } else {
        var spacePos = line.indexOf(" ", eqPos);
        if (spacePos != -1) {
          value = line.substring(eqPos + 1, spacePos);
        } else {
          value = line.substring(eqPos + 1);
        }
        index = spacePos + 1;
      }

      switch (property) {
        case "id":
          charId = String.fromCharCode(Std.parseInt(value));
        case "x":
          character.x = Std.parseInt(value);
        case "y":
          character.y = Std.parseInt(value);
        case "width":
          character.width = Std.parseInt(value);
        case "height":
          character.height = Std.parseInt(value);
        case "xoffset":
          character.xOffset = Std.parseInt(value);
        case "yoffset":
          character.yOffset = Std.parseInt(value);
        case "xadvance":
          character.xAdvance = Std.parseInt(value);
      }

      if (index == 0) {
        break;
      }
    }
    characters[charId] = character;
  }
}
