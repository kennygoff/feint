package ui;

import js.Browser;
import js.html.Element;

class Dockspace {
  var element:Element;
  var panels:Array<Panel> = [];

  public function new() {
    element = Browser.document.createElement('main');
    element.classList.add('dockspace');
    Browser.document.body.appendChild(element);
  }

  public function add(panels:Array<Panel>) {
    for (panel in panels) {
      this.panels.push(panel);
      element.appendChild(panel.element);
    }
  }
}
