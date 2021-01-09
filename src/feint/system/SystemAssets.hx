package feint.system;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class SystemAssets {
  macro static public function buildAssets():Array<Field> {
    // Context.resolvePath(dir)
    var fields = Context.getBuildFields();
    var newField = {
      name: 'files',
      doc: null,
      meta: [],
      access: [AStatic, APublic],
      kind: FVar(macro:Array<String>, macro ["my default"]),
      pos: Context.currentPos()
    };
    fields.push(newField);
    return fields;
  }
  // static public function buildAssetCollection() {
  //   switch (Context.getLocalType()) {
  //     case TInst(_.get() => cls, [instanceType]):
  //       var typename:String = switch (instanceType) {
  //         case TInst(name, _): name.toString();
  //         default: 'UnknownAsset';
  //       };
  //       trace(typename);
  //       // var classname:String = '${typename.substr(typename.lastIndexOf('.') + 1)}Collection';
  //       var classname = "FileAssetCollection";
  //       var complexType = haxe.macro.TypeTools.toComplexType(instanceType);
  //       var def = macro class $classname {
  //         public var someAsset:$complexType;
  //         public function new() {}
  //       }
  //       haxe.macro.Context.defineType(def, 'feint.assets.Assets');
  //       return haxe.macro.Context.getType(classname);
  //     case t:
  //       Context.error("Class expected", Context.currentPos());
  //   }
  //   return null;
  // }
}
#end
