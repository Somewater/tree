package tree.view.canvas {
	import flash.display.Sprite;
	import flash.events.Event;

	import tree.model.GenNode;

	import tree.model.Join;
	import tree.model.Node;

	public class Canvas extends Sprite{

		public static const ICON_WIDTH:int = 90;
		public static const ICON_HEIGHT:int = 125;
		public static const ICON_WIDTH_SPACE:int = 50;
		public static const ICON_HEIGHT_SPACE:int = 50;
		public static const LEVEL_HEIGHT:int = ICON_HEIGHT + HEIGHT_SPACE;

		public static const HEIGHT_SPACE:int = 50;
		private var nodes:Vector.<NodeIcon> = new Vector.<NodeIcon>();// array of NodeIcon
		private var nodesHolder:Sprite;
		private var generationsHolder:Sprite;
		private var generationHolders:Array = [];

		public function Canvas() {
			generationsHolder = new Sprite();
			addChild(generationsHolder);

			nodesHolder = new Sprite();
			addChild(nodesHolder);
		}

		public function drawJoin(g:GenNode):void {
			var n:NodeIcon = new NodeIcon();
			n.addEventListener(Event.COMPLETE, onNodeIconComplete);
			nodes.push(n);
			n.data = g;
			generationHolder(g.node.generation).addNode(n);
		}

		private function generationHolder(generation:int):GenerationBackground {
			var h:GenerationBackground = generationHolders[generation];
			if(!h) {
				generationHolders[generation] = h = new GenerationBackground(generation, nodesHolder);
				h.changed.add(onGenerationHolderChanged);
				generationsHolder.addChild(h);
			}
			return h;
		}

		private function onGenerationHolderChanged(generationHolder:GenerationBackground):void {

		}

		public function setSize(w:int, h:int):void {

		}

		private function onNodeIconComplete(event:Event):void {
			dispatchEvent(event);
		}
	}
}