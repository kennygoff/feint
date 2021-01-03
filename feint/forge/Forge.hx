package feint.forge;

import feint.forge.System.RenderSystem;
import feint.renderer.Renderer;

using Lambda;

import feint.debug.Logger;
import feint.debug.FeintException;
import feint.forge.Entity;
import feint.forge.Component;

class Forge {
  var entities:Array<EntityId> = [];
  var components:Map<ComponentType, Array<Component>> = [];
  var systems:Array<System> = [];
  var renderSystems:Array<RenderSystem> = [];

  public var map:Map<EntityId, Array<Component>> = [];

  public function new() {}

  public function update(elapsed:Float) {
    for (system in systems) {
      system.update(elapsed, this);
    }
  }

  public function render(renderer:Renderer) {
    for (renderSystem in renderSystems) {
      renderSystem.render(renderer, this);
    }
  }

  /**
   * Add entity by id with given components
   * @param id Entity id
   * @param comps Array of components registered to this Entity
   */
  public function addEntity(id:EntityId, comps:Array<Component>) {
    entities.push(id);
    map[id] = [];
    for (component in comps) {
      component.entity = id;
      if (components[Type.getClassName(Type.getClass(component))] == null) {
        components[Type.getClassName(Type.getClass(component))] = [];
      }
      components[Type.getClassName(Type.getClass(component))].push(component);
      map[id].push(component);
    }
  }

  /**
   * Get EntityIds for all entities that have all listed components
   * @param componentClassNames Class names of components to check for
   * @return Array<EntityId>
   */
  public function getEntities(componentClassNames:Array<ComponentType>):Array<EntityId> {
    if (componentClassNames.length == 1) {
      return components[componentClassNames[0]].map(component -> component.entity);
    }

    var compArr:Array<Array<Component>> = componentClassNames.filter(
      componentClassName -> components[componentClassName] != null
    )
      .map(componentClassName -> components[componentClassName]);

    return compArr.fold((components, jointEntities) -> {
      var componentEntities = components.map(component -> component.entity);
      if (jointEntities == null) {
        return componentEntities;
      }
      return componentEntities.filter(id -> jointEntities.contains(id));
    }, null);
  }

  public function getEntityComponent<T:Component>(entityId:EntityId, componentType:Class<T>):T {
    return cast map[entityId].find(
      component -> component.getComponentType() == (cast componentType : Class<Component>)
    );
  }

  public function addSystem(system:System) {
    systems.push(system);
  }

  public function addRenderSystem(system:RenderSystem) {
    renderSystems.push(system);
  }

  public function destroy() {
    entities = [];
    components = [];
    systems = [];
    renderSystems = [];
  }
}
// class Forge {
//   public var entities:Map<String, EntityId> = new Map<String, EntityId>();
//   public var components:Map<Class<Component>, Array<Component>>;
//   public var systems:Array<System> = [];
//   public function addSystem(system:System) {
//     systems.push(system);
//   }
//   public function addEntity(key:String, id:EntityId):EntityId {
//     if (entities.exists(key)) {
//       Logger.error('Cannot register multiple entities with the same key!');
//       throw new FeintException(
//         'ForgeEntityKeyExists',
//         'A Forge Entity with the key ${key} already exists.'
//       );
//     }
//     entities[key] = id;
//     return id;
//   }
//   public function getEntities(componentTypes:Array<Class<Component>>):Array<EntityId> {
//     return [];
//   }
//   public function update(elapsed:Float) {
//     for (system in systems) {
//       system.update(elapsed, this);
//     }
//   }
// }
