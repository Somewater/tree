package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.IModel;

	public class GenNode extends ModelBase implements IModel{

		public var node:Node;
		public var join:Join;

		public var priority:int;

		public function GenNode(node:Node, join:Join) {
			this.node = node;
			this.join = join;
			this.priority = join.type.priority;
		}

		override public function get id():String {
			return node ? node.uid + '' : null;
		}
	}
}
