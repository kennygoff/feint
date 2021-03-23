package ui;

import js.html.Element;
import js.Browser;

@:allow(ui.Dockspace)
class Panel {
  var element:Element;
  var wrapper:Element;
  var components:Array<Dynamic->String>;

  public function new(
    title:String,
    props:Dynamic,
    components:Array<Dynamic->String>,
    parent:String = 'div'
  ) {
    element = Browser.document.createElement('section');
    element.classList.add('panel');
    element.innerHTML = '<h2>${title}</h2>';

    wrapper = Browser.document.createElement(parent);
    element.appendChild(wrapper);

    this.components = components;
    update(props);
  }

  public function update(props:Dynamic) {
    wrapper.innerHTML = components.map(component -> component(props)).join('');
  }
}
