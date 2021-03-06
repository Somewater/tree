package tree.model {
	import org.osflash.signals.ISignal;

	import tree.model.base.IModel;

	public class GenNode extends ModelBase implements IModel{

		public var node:Node;
		public var join:Join;
		public var generation:Generation;

		public var priority:int;
		public var vector:int;// с какой стороны от source пытаться разместить ноду

		public function GenNode(join:Join, generation:Generation) {
			this.node = join.associate.node;
			this.join = join;
			this.generation = generation;

			this.priority =  (1000 / (node.dist + 1)) +  join.type.priority;
			this.vector = join.type.vector;
		}

		override public function get id():String {
			return node ? node.uid + '' : null;
		}

		public function get name():String {
			return node ? node.name : null;
		}

		public function toString():String {
			return node ? 'g' + node.toString() : '[GenNode]';
		}
	}
}
