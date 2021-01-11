package feint.forge;

using Lambda;

import feint.forge.System.RenderSystem;
import feint.forge.Entity;
import feint.forge.Component;
import feint.renderer.Renderer;

class Forge {
  var entities:Array<EntityId> = [];
  var components:Map<ComponentType, Array<Component>> = [];
  var systems:Array<System> = [];
  var renderSystems:Array<RenderSystem> = [];
  var labelMap:Map<String, Array<EntityId>> = [];
  var entityLabels:Map<EntityId, Array<String>> = [];

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
   * @param labels (Optional) Array of labels for filtering in systems
   */
  public function addEntity(id:EntityId, comps:Array<Component>, ?labels:Array<String>) {
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

    if (labels != null) {
      for (label in labels) {
        if (this.labelMap[label] == null) {
          this.labelMap[label] = [];
        }

        this.labelMap[label].push(id);
      }
      this.entityLabels[id] = labels.copy();
    } else {
      this.entityLabels[id] = [];
    }
  }

  /**
   * Get EntityIds for all entities that have all listed components
   * @param componentClassNames Class names of components to check for
   * @param labels (Optional) Array of labels to filter entities by
   * @return Array<EntityId>
   */
  public function getEntities(
    componentClassNames:Array<ComponentType>,
    ?labels:Array<String>
  ):Array<EntityId> {
    if (componentClassNames.length == 1) {
      var matchingEntities = components[componentClassNames[0]].map(component -> component.entity);
      if (labels != null) {
        matchingEntities = matchingEntities.filter(
          entityId -> labels.foreach(label -> entityLabels[entityId].contains(label))
        );
      }
      return matchingEntities;
    }

    var compArr:Array<Array<Component>> = componentClassNames.filter(
      componentClassName -> components[componentClassName] != null
    )
      .map(componentClassName -> components[componentClassName]);

    var matchingEntities = compArr.fold((components, jointEntities) -> {
      var componentEntities = components.map(component -> component.entity);
      if (jointEntities == null) {
        return componentEntities;
      }
      return componentEntities.filter(id -> jointEntities.contains(id));
    }, null);

    if (labels != null) {
      matchingEntities = matchingEntities.filter(
        entityId -> labels.foreach(label -> entityLabels[entityId].contains(label))
      );
    }

    return matchingEntities;
  }

  public function getEntityComponent<T:Component>(entityId:EntityId, componentType:Class<T>):T {
    return cast map[entityId].find(
      component -> component.getComponentType() == (cast componentType : Class<Component>)
    );
  }

  public function removeEntity(entityId:EntityId) {
    entities.remove(entityId);
    for (_ => entityList in labelMap) {
      entityList.remove(entityId);
    }
    entityLabels.remove(entityId);
    for (_ => componentList in components) {
      for (component in componentList) {
        if (map[entityId].contains(component)) {
          componentList.remove(component);
        }
      }
    }
    map.remove(entityId);
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
