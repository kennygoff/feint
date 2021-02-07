package ui;

import js.html.Element;
import js.Browser;

@:allow(ui.Dockspace)
class Panel {
  var element:Element;
  var components:Array<Dynamic->String>;

  public function new(title:String, props:Dynamic, components:Array<Dynamic->String>) {
    element = Browser.document.createElement('section');
    element.classList.add('panel');

    this.components = [(props) -> '<h2>${title}</h2>'].concat(components);
    update(props);
  }

  public function update(props:Dynamic) {
    element.innerHTML = components.map(component -> component(props)).join('');
  }
}
