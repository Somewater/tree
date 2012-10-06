package tree.view.canvas {
	import com.gskinner.motion.GTweener;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import tree.common.Config;

	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Node;
	import tree.view.gui.UIComponent;

	public class Canvas extends UIComponent implements INodeViewCollection {

		public static const ICON_WIDTH:int = 90;
		public static const ICON_HEIGHT:int = 125;
		public static const ICON_WIDTH_SPACE:int = (ICON_WIDTH + 50) * 0.5;
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

		private var selectedNode:NodeIcon;
		public var highlightedNode:NodeIcon;
		public var arrowMenu:ArrowMenu;

		public function Canvas() {
			generationsHolder = new Sprite();
			addChild(generationsHolder);

			joinsHolder = new Sprite();
			addChild(joinsHolder);

			nodesHolder = new Sprite();
			addChild(nodesHolder);

			arrowMenu = new ArrowMenu();
			Config.tooltips.addChild(arrowMenu);
			arrowMenu.visible = false;
		}

		override public function setSize(w:int, h:int):void {
			refreshNodesVisibility();
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

				var generation:int = g.generation.generation;
				var h:GenerationBackground = generationHolders[generation];
				if(!h) {
					generationHolders[generation] = h = new GenerationBackground(g.generation);
					generationsHolder.addChild(h);
				}

				n.visible = false;
				refreshNodeVisibility(n);
			}
			return n;
		}

		private function setNodeIcon(uid:int, n:NodeIcon):NodeIcon {
			if(n)
				nodesByUid[uid] = n;
			else
				delete(nodesByUid[uid])
			return n;
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
			var forRemove:Array = [];
			var g:GenerationBackground;
			for each(g in generationHolders)
			{
				if(g.generation.length)
					g.refresh();
				else
					forRemove.push(g);
			}
			for each(g in forRemove){
				delete(generationHolders[g.generation.generation]);
				if(g.parent) g.parent.removeChild(g);
				g.clear();
			}
		}

		public function destroyNode(node:NodeIcon):void {
			var n:Node = node.data.node;
			setNodeIcon(n.uid, null);
			if(node.parent)
				node.parent.removeChild(node);
			node.clear();
			if(selectedNode == node)
				selectedNode = null;
			if(highlightedNode == node)
				highlightedNode = null;
		}

		public function destroyLine(line:JoinLine):void {
			var j:Join = line.data;
			setJoinLine(j.uid, j.from.uid, null);
			if(line.parent)
				line.parent.removeChild(line);
			line.clear();
		}

		public function fireComplete():void{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get iterator():*{
			return nodesByUid;
		}

		public function selectNode(uid:int):void{
			var node:NodeIcon = getNodeIcon(uid);
			if(node != selectedNode){
				if(selectedNode){
					selectedNode.selected = false;
				}
				selectedNode = node;
				if(node){
					node.selected = true;
				}
			}
		}

		public function highlightNode(node:NodeIcon):void{
			if(highlightedNode != node){
				if(highlightedNode){
					highlightedNode.deleteArrows();
					unhighlightNode(highlightedNode);
				}
				highlightedNode = node;
				if(node){
					node.highlighted = true;
				}
			}
		}

		public function unhighlightNode(node:NodeIcon):void{
			if(highlightedNode && highlightedNode == node){
				node.highlighted = false;
				highlightedNode = null;
			}
		}

		override protected function _onOut(event:MouseEvent):void {
			if(event.relatedObject && (event.relatedObject == arrowMenu || arrowMenu.contains(event.relatedObject)))
				return;
			super._onOut(event);
		}

		public function utilize():void {
			for each(var n:NodeIcon in nodesByUid)
				if(n)
					n.clear();
			nodesByUid = [];

			for each(var j:JoinLine in joindByUid)
				if(j)
					j.clear();
			joindByUid = [];

			while(nodesHolder.numChildren)
				nodesHolder.removeChildAt(0);
			while(joinsHolder.numChildren)
				joinsHolder.removeChildAt(0);
			while(generationsHolder.numChildren)
				generationsHolder.removeChildAt(0);
			generationHolders = [];

			selectedNode = null;
			highlightedNode = null;
			arrowMenu.visible = false;
			GTweener.removeTweens(this);
		}

		private var callRefreshVisibilityDelayed:uint = 0;
		public function refreshNodesVisibility(now:Boolean = false):void {
			if(!now){
				if(callRefreshVisibilityDelayed != Config.ticker.getTimer){
					if(callRefreshVisibilityDelayed)
						Config.ticker.removeByCallback(refreshNodesVisibility);
					Config.ticker.callLater(refreshNodesVisibility, 2, [true]);
					callRefreshVisibilityDelayed = Config.ticker.getTimer;
				}
				return;
			}
			callRefreshVisibilityDelayed = 0;

			var scale:Number = this.scaleX;
			var minX:int = -this.x / scale;
			var minY:int = -this.y / scale;
			var maxX:int = minX + (Config.WIDTH - Config.GUI_WIDTH) / scale;
			var maxY:int = minY + Config.HEIGHT / scale;

			minX -= Canvas.ICON_WIDTH;
			minY -= Canvas.ICON_HEIGHT;

			for each(var n:NodeIcon in nodesByUid){
				var nx:int = n.x;
				var ny:int = n.y;
				var nv:Boolean = nx < maxX && nx > minX && ny < maxY && ny > minY;
				if(nv){
					if(!n.visible){
						n.visible = true;
						nodesHolder.addChild(n);
					}
				} else {
					if(n.visible){
						n.visible = false;
						nodesHolder.removeChild(n);
					}
				}
			}
		}

		private function refreshNodeVisibility(n:NodeIcon):void{
			var scale:Number = this.scaleX;
			var minX:int = -this.x / scale;
			var minY:int = -this.y / scale;
			var maxX:int = minX + (Config.WIDTH - Config.GUI_WIDTH) / scale;
			var maxY:int = minY + Config.HEIGHT / scale;

			minX -= Canvas.ICON_WIDTH;
			minY -= Canvas.ICON_HEIGHT;

			var np:Point = n.position();
			var nx:int = np.x;
			var ny:int = np.y;
			var nv:Boolean = nx < maxX && nx > minX && ny < maxY && ny > minY;
			if(nv){
				if(!n.visible){
					n.visible = true;
					nodesHolder.addChild(n);
				}
			} else {
				if(n.visible){
					n.visible = false;
					nodesHolder.removeChild(n);
				}
			}
		}
	}
}