package tree.view.canvas {
	import flash.display.Sprite;
	import flash.events.Event;

	import tree.model.GenNode;

	public class Canvas extends Sprite implements INodeViewCollection {

		public static const ICON_WIDTH:int = 90;
		public static const ICON_HEIGHT:int = 125;
		public static const ICON_WIDTH_SPACE:int = 50;
		public static const ICON_HEIGHT_SPACE:int = 50;
		public static const LEVEL_HEIGHT:int = ICON_HEIGHT + HEIGHT_SPACE;
		public static const JOIN_BREED_STICK:int = 20;
		public static const JOIN_STICK:int = 8;

		public static const HEIGHT_SPACE:int = 50;
		private var nodesByUid:Array = [];
		private var joindByUid:Array = [];
		private var nodesHolder:Sprite;
		private var joinsHolder:Sprite;
		private var generationsHolder:Sprite;
		private var generationHolders:Array = [];

		public function Canvas() {
			generationsHolder = new Sprite();
			addChild(generationsHolder);

			joinsHolder = new Sprite();
			addChild(joinsHolder);

			nodesHolder = new Sprite();
			addChild(nodesHolder);
		}

		public function setSize(w:int, h:int):void {

		}

		public function onNodeIconComplete(n:NodeIcon):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function getNodeIcon(uid:int):NodeIcon {
			return nodesByUid[uid];
		}

		public function getNodeIconAndCreate(g:GenNode):NodeIcon {
			var n:NodeIcon = getNodeIcon(g.node.uid);
			if(!n){
				n = new NodeIcon();
				setNodeIcon(g.node.uid, n);
				n.data = g;
				nodesHolder.addChild(n);

				var generation:int = g.generation.generation;
				var h:GenerationBackground = generationHolders[generation];
				if(!h) {
					generationHolders[generation] = h = new GenerationBackground(g.generation);
					generationsHolder.addChild(h);
				}
			}
			return n;
		}

		private function setNodeIcon(uid:int, n:NodeIcon):NodeIcon {
			return nodesByUid[uid] = n;
		}

		public function getJoinLine(from:int, to:int):JoinLine {
			if(from > to) {var tmp:int = from; from = to; to = tmp;}
			return joindByUid[from + '->' + to];
			//return joindByUid[from << 0xFFFF + to];
		}

		private function setJoinLine(from:int, to:int, line:JoinLine):void {
			if(from > to) {var tmp:int = from; from = to; to = tmp;}
			joindByUid[from + '->' + to] = line;
			//joindByUid[from << 0xFFFF + to] = line;
		}

		public function getJoinLineAndCreate(from:int, to:int):JoinLine {
			var l:JoinLine = getJoinLine(from, to);
			if(!l) {
				l = new JoinLine(this);
				joinsHolder.addChild(l);
				setJoinLine(from, to, l);
			}
			return l;
		}

		public function refreshGenerations():void {
			for each(var g:GenerationBackground in generationHolders)
				g.refresh();
		}
	}
}