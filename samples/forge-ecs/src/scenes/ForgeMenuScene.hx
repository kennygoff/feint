package scenes;

using Lambda;

import feint.input.device.Keyboard.KeyCode;
import feint.input.InputManager;
import feint.renderer.Renderer;
import feint.scene.Scene;
import feint.forge.Forge;
import feint.forge.Entity;
import feint.forge.Component;
import feint.forge.System;

class ForgeMenuScene extends Scene {
  final backgroundColor:Int = 0xFF000000;
  var forge:Forge;
  var selectedIndex:Int = 0;
  var menuOptions:Array<String> = ['Play', 'Exit'];

  override public function init() {
    super.init();

    forge = new Forge();

    // Forge Entities
    forge.addEntity(Entity.create(), [new MenuComponent('forge-ecs', 'Forge ECS', true)]);
    forge.addEntity(Entity.create(), [new MenuFieldComponent('One', 'forge-ecs')]);
    forge.addEntity(Entity.create(), [new MenuFieldComponent('Two', 'forge-ecs')]);
    forge.addEntity(Entity.create(), [new MenuFieldComponent('Three', 'forge-ecs')]);

    // Forge Systems
    forge.addSystem(new MenuNavigationSystem(game.window.inputManager));
    forge.addRenderSystem(new MenuRenderSystem());
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);

    forge.update(elapsed);
  }

  override public function render(renderer:Renderer) {
    // Render background
    renderer.drawRect(0, 0, game.window.width, game.window.height, {color: backgroundColor});

    super.render(renderer);

    forge.render(renderer);

    // Render FPS
    renderer.drawText(4, 4, 'FPS: ${game.fps}', 16, 'sans-serif');
  }
}

class MenuComponent extends Component {
  public var id:String;
  public var title:String;
  public var focused:Bool;
  public var active:Bool;

  public function new(id:String, title:String, focused:Bool = false) {
    this.id = id;
    this.title = title;
    this.focused = focused || false;
    this.active = focused || false;
  }
}

class MenuFieldComponent extends Component {
  public var menu:String;
  public var name:String;
  public var focused:Bool;

  public function new(name:String, menuId:String) {
    this.menu = menuId;
    this.name = name;
    this.focused = false;
  }
}

class MenuNavigationSystem extends System {
  var inputManager:InputManager;

  public function new(inputManager:InputManager) {
    this.inputManager = inputManager;
  }

  override public function update(elapsed:Float, forge:Forge) {
    // Get entities
    var menuEntities = forge.getEntities([MenuComponent]);
    var menuFieldEntities = forge.getEntities([MenuFieldComponent]);

    // Get entity components
    var menus = menuEntities.map(entityId -> forge.getEntityComponent(entityId, MenuComponent));
    var menuFields = menuFieldEntities.map(
      entityId -> forge.getEntityComponent(entityId, MenuFieldComponent)
    );

    // Render menu entities
    var activeMenus = menus.filter(menu -> menu.active && menu.focused);
    for (menu in activeMenus) {
      var activeFields = menuFields.filter(field -> field.menu == menu.id);

      // Select first active field by default
      var noneSelected = !activeFields.exists(field -> field.focused);
      if (noneSelected) {
        activeFields[0].focused = true;
      }

      //
      var selectedIndex = activeFields.foldi(
        (field, selected, index) -> field.focused ? index : selected,
        -1
      );
      if (selectedIndex >= 0) {
        if (inputManager.keyboard.keys[KeyCode.Down] == JustPressed) {
          activeFields[selectedIndex].focused = false;
          selectedIndex = (selectedIndex + 1) % activeFields.length;
          activeFields[selectedIndex].focused = true;
        } else if (inputManager.keyboard.keys[KeyCode.Up] == JustPressed) {
          activeFields[selectedIndex].focused = false;
          selectedIndex = (selectedIndex + activeFields.length - 1) % activeFields.length;
          activeFields[selectedIndex].focused = true;
        } else if (inputManager.keyboard.keys[KeyCode.Enter] == JustPressed) {
          // TODO: Emit event!
          trace('${activeFields[selectedIndex].name}');
          // forge.destroy();
          // game.changeScene(new ForgeMenuScene());
          return;
        }
      }
    }
  }
}

class MenuRenderSystem extends RenderSystem {
  public function new() {}

  override public function render(renderer:Renderer, forge:Forge) {
    // Get entities
    var menuEntities = forge.getEntities([MenuComponent]);
    var menuFieldEntities = forge.getEntities([MenuFieldComponent]);

    // Get entity components
    var menus = menuEntities.map(entityId -> forge.getEntityComponent(entityId, MenuComponent));
    var menuFields = menuFieldEntities.map(
      entityId -> forge.getEntityComponent(entityId, MenuFieldComponent)
    );

    // Render menu entities
    var activeMenus = menus.filter(menu -> menu.active && menu.focused);
    for (menu in activeMenus) {
      // Draw title
      renderer.drawText(32, 32, menu.title, 64, 'sans-serif');

      // Draw options
      var activeFields = menuFields.filter(field -> field.menu == menu.id);
      for (i in 0...activeFields.length) {
        var activeField = activeFields[i];
        renderer.drawText(32, 32 + 64 + 16 + ((32 + 16) * i), activeField.name, 32, 'sans-serif');

        // Draw select
        if (activeField.focused) {
          renderer.drawRect(24, 32 + 64 + 16 + ((32 + 16) * i) + 12, 4, 4, {color: 0xFFFFFFFF});
        }
      }
    }
  }
}
