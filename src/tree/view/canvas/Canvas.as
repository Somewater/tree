package tree.view.canvas {
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweener;

import flash.display.Bitmap;

	import flash.display.BitmapData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
	import flash.geom.Rectangle;

import tree.common.Config;

	import tree.model.GenNode;
	import tree.model.Join;
	import tree.model.Model;
	import tree.model.Node;
import tree.model.Person;
import tree.view.Tweener;
import tree.view.gui.UIComponent;

	public class Canvas extends UIComponent implements INodeViewCollection {

		public static const ICON_WIDTH:int = 90;
		public static const ICON_HEIGHT:int = 125;
		public static const HEIGHT_SPACE:int = 50;
		public static const ICON_WIDTH_SPACE:int = (ICON_WIDTH + 50) * 0.5;
		public static const LEVEL_HEIGHT:int = ICON_HEIGHT + HEIGHT_SPACE;
		public static const JOIN_BREED_STICK:int = 20;
		public static const JOIN_STICK:int = 8;

		private var nodesByUid:Array = [];
		private var joindByUid:Array = [];
		private var nodesHolder:Sprite;
		private var joinsHolder:Sprite;
		private var generationsHolder:Sprite;
		private var generationHolders:Array = [];

		private var selectedNode:NodeIcon;
		public var highlightedNode:NodeIcon;
		public var showActionBtnIfHighlight:Boolean = false;
		public var arrowMenu:ContextMenu;

		public var canDrag:Boolean = true;

		private var canvasRules:CanvasRules;

		private var cube3d:Cube3D;
		private var firstNode:Boolean = true;

		public function Canvas() {
			generationsHolder = new Sprite();
			addChild(generationsHolder);

			joinsHolder = new Sprite();
			addChild(joinsHolder);

			nodesHolder = new Sprite();
			addChild(nodesHolder);

			arrowMenu = new ContextMenu();

			canvasRules = new CanvasRules();

			cube3d = new Cube3D(this);
			addChild(cube3d);
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

				if(firstNode){
					firstNode = false;
					if(Model.instance.options.cube3d)
						cube3d.activate();
				}
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
			if(line)
				joindByUid[from + '->' + to] = line;
			else
				delete joindByUid[from + '->' + to];
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
			if(cube3d.active){
				cube3d.play()
			}else
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

		public function highlightNode(p:Person):void{
			var node:NodeIcon = p != null ? getNodeIcon(p.uid) : null;
			if(highlightedNode != node){
				if(highlightedNode){
					unhighlightNode(highlightedNode);
				}
				highlightedNode = node;
				if(node){
					node.highlighted = true;
					if(showActionBtnIfHighlight)
						node.contextMenuBtnVisibility = true;
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
			if(Model.instance.options.cube3d)
				cube3d.start();

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

			firstNode = true;
		}

		private var callRefreshVisibilityDelayed:uint = 0;
		public function refreshNodesVisibility(now:Boolean = false):void {
			if(!now){
				if(callRefreshVisibilityDelayed != Config.ticker.getTimer){
					if(callRefreshVisibilityDelayed)
						Config.ticker.removeByCallback(refreshNodesVisibility);
					Config.ticker.callLater(refreshNodesVisibility, Model.instance.refrNodesVisibDelay, [true]);
					callRefreshVisibilityDelayed = Config.ticker.getTimer;
				}
				return;
			}
			callRefreshVisibilityDelayed = 0;

			var scale:Number = this.scaleX;
			var minX:int = -this.x / scale;
			var minY:int = -this.y / scale;
			var maxX:int = minX + Model.instance.contentWidth / scale;
			var maxY:int = minY + Config.HEIGHT / scale;

			minX -= Canvas.ICON_WIDTH;
			minY -= Canvas.ICON_HEIGHT;

			for each(var n:NodeIcon in nodesByUid){
				var nx:int = n.requiredPosX;
				var ny:int = n.requiredPosY;
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
			var maxX:int = minX + Model.instance.contentWidth / scale;
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

		public function refreshAllNodePositions():void {
			for each(var n:NodeIcon in nodesByUid)
				n.refreshPosition(false);
		}

		public function refreshAllJoinLines():void {
			var j:JoinLine
			for each(j  in joindByUid)
				j.removeFromLineMatrix();

			for each(j  in joindByUid)
				j.show(false)
		}

		public function refreshAllGenerations():void {
			for each(var h:GenerationBackground in generationsHolder)
				h.refresh();
		}

		public function getPrintArea():Bitmap{
			var minX:int = int.MAX_VALUE;
			var minY:int = int.MAX_VALUE;
			var maxX:int = int.MIN_VALUE;
			var maxY:int = int.MIN_VALUE;

			for each(var n:NodeIcon in nodesByUid){
				var v:int;
				v = n.x; if(v < minX) minX = v;
				v = n.y; if(v < minY) minY = v;
				v = n.x + Canvas.ICON_WIDTH; if(v > maxX) maxX = v;
				v = n.y + Canvas.ICON_HEIGHT; if(v > maxY) maxY = v;
				if(!n.visible){
					n.visible = true;
					nodesHolder.addChild(n);
				}
			}

			const PADDING:int = 20;
			maxX += PADDING; maxY += PADDING;
			minX -= PADDING; minY -=PADDING;

			var w:int = (maxX - minX);
			var h:int = (maxY - minY);
			var landscape:Boolean = w > h;
			const W:int = 297 * 10;
			const H:int = 210 * 10;
			const MAX_W:int = landscape ? W : H;
			const MAX_H:int = landscape ? H : W;
			var scale:Number = Math.min(MAX_W/ w, MAX_H / h);
			w *= scale; h *= scale;
			var bmp:BitmapData = new BitmapData(w, h, false, 0xFFFFFFFF);

			//generationsHolder.visible = false;

			var m:Matrix = new Matrix(scale, 0, 0, scale, -minX * scale,  -minY * scale)
			bmp.draw(this, m, null, null, new Rectangle(0, 0, w, h));
			//generationsHolder.visible = true;

			var b:Bitmap = new Bitmap(bmp);
			if(!landscape){
				b.rotation = 90;
				b.x = b.width;
			}
			return b;
		}

		public function getCube3DArea():BitmapData{
			var w:int = Config.WIDTH - (Model.instance.guiOpen ? Config.GUI_WIDTH : 0);
			var h:int = Config.HEIGHT - Config.PANEL_HEIGHT;
			var startX:int = -this.x;
			var startY:int = Config.PANEL_HEIGHT - this.y;
			var scale:Number = 1;
			w *= scale; h *= scale;
			var bmp:BitmapData = new BitmapData(w, h, false, 0xFFFFFFFF);

			cube3d.visible = false;
			var m:Matrix = new Matrix(scale, 0, 0, scale, -startX * scale,  -startY * scale)
			bmp.draw(this, m, null, null, new Rectangle(0, 0, w, h));
			//bmp.colorTransform(bmp.rect, new ColorTransform(0.4, 0.4, 0.4))
			cube3d.visible = true;
			return bmp;
		}

		public function getPrintSize(area:Sprite):Rectangle{
			return new Rectangle(-1000, -1000, 1000, 1000);
		}

		public function bringToFront(n:NodeIcon):void {
			nodesHolder.addChild(n);
		}

		/**
		 * @return Массив нод, которые пересекает текущая нода
		 */
		private function checkNodePositionCollide(n:NodeIcon):Array{
			var result:Array = [];
			for each(var node:NodeIcon in nodesByUid){
				if(node != n){

				}
			}
			return result;
		}

		public function set rulesVisibility(visible:Boolean):void{
			if(visible){
				if(!canvasRules.parent){
					addChildAt(canvasRules, this.getChildIndex(generationsHolder) + 1);
					refreshRules();

					canvasRules.alpha = 0;
					Tweener.to(canvasRules, 0.3, {alpha:1})
				}
			}else{
				if(canvasRules.parent){
					Tweener.to(canvasRules, 0.3, {alpha: 0}, {onComplete: detachCanvasRules})
				}
			}
		}

		private function detachCanvasRules(g:GTween = null):void{
			canvasRules.parent.removeChild(canvasRules);
		}

		public function refreshRules():void{
			var scale:Number = this.scaleX;
			var minX:int = -this.x / scale;
			var minY:int = -this.y / scale;
			var maxX:int = minX + Model.instance.contentWidth / scale;
			var maxY:int = minY + Config.HEIGHT / scale;

			minX -= Canvas.ICON_WIDTH;
			minY -= Canvas.ICON_HEIGHT;

			// привзка к ближайшим линиям сетки
			const xStep:int = Canvas.ICON_WIDTH_SPACE;
			const yStep:int = Canvas.LEVEL_HEIGHT;
			minX = int(minX / xStep) * xStep;
			maxX = int(maxX / xStep) * xStep;
			minY = int(minY / yStep) * yStep;
			maxY = int(maxY / yStep) * yStep;

			canvasRules.refresh(minX, minY, maxX, maxY, xStep, yStep);
		}

		public function showAvailableCoords(availableCoords:Array):void {
			canvasRules.removeAvailableCoords();
			for each(var p:Point in availableCoords){
				p.x *= Canvas.ICON_WIDTH_SPACE;
				p.y *= Canvas.ICON_HEIGHT + Canvas.HEIGHT_SPACE;
				canvasRules.drawAvailableCoord(p.x, p.y);
			}
		}

		public function mouseUpAllNodes():void {
			for each(var n:NodeIcon in nodesByUid){
				n.onMouseUp();
			}
		}
	}
}