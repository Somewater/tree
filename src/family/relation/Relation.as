package family.relation {
	
	import family.tree.control.TreeController;
	import family.desktop.Desktop;
	import family.item.TreeItem;
	import family.level.Level;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import menu.RelationSetter;
	
	import utils.Utils;

	public class Relation implements IUpdate,IDisposable {
		
		private static const PARENT_SHIFT:int = -15;
		private static const SHIFT:uint = 10;
		private static const SIBLING_SHIFT:uint = 20;
		
		/** Типы групп родственников */
		/** Другими словами, типы родственных связей */
		public static const PARENT:uint = 0;	
		public static const PRESENT_PARTNER:uint = 1;
		public static const PAST_PARTNER:uint = 2;
		public static const CHILD:uint = 3;
		public static const OWN_SIBLING:uint = 4;	
		public static const SIBLING:uint = 5;
		
		/** Цвета линий связей, в соответствии с типами родственных связей */
		private static const RELATE_COLORS:Array = [
			0xFF0000,
			0xFF0000,
			0xA20000,
			0xFF0000,
			0x00B2B8,
			0x00B2B8
		];
		
		private static const SOLID_LINE:uint = 0;
		private static const DASH_LINE:uint = 1;
		private static const DOT_LINE:uint = 2;
		
		private static const RELATE_LINE_SHIFT:uint = 5;
		
		/** Типы линий, в соответствии с типом родственной связи */ 
		private static const RELATE_LINE_STYLE:Array = [
			0, // Solid
			0, // Solid
			2, // Dot
			0, // Solid
			0, // Solid
			1 // Dash
		];
		
		private static const ALPHA:Number = .5;
		
		private var _relations:Relations;
		private var _treeItemBegin:TreeItem;
		private var _treeItemEnd:TreeItem;
		private var _unions:Unions;
		
		private var _type:uint;

		private var _allPointsToDraw:Array; // Все, что нужно нарисовать...
		private var _nowPointsToDraw:Array; // То, что рисуется в данную единицу времени...
		private var _nowLineColor:Number; // Текущий цвет лений связи...
		
		public function Relation(
			relations:Relations,
			treeItemBegin:TreeItem,
			treeItemEnd:TreeItem,
			unions:Unions
		) {
			_relations = relations;
			_treeItemBegin = treeItemBegin;
			_treeItemEnd = treeItemEnd;
			_unions = unions;
		}
		
		public function init():void {
			_unions.init();
		}
		
		public function get treeItemBegin():TreeItem { return _treeItemBegin; }
		public function get treeItemEnd():TreeItem { return _treeItemEnd; }
			
		private function drawSimpleLine():void {
			_relations.graphics.lineStyle(1, _nowLineColor, ALPHA);
			var pointBlock:Array;
			var p:Point;
			for (var i:uint = 0; i < _nowPointsToDraw.length; i++) {
				pointBlock = _nowPointsToDraw[i];
				for (var j:uint = 0; j < pointBlock.length; j++) {
					p = pointBlock[j];
					if (!j) _relations.graphics.moveTo(p.x, p.y);
					else _relations.graphics.lineTo(p.x, p.y);
				}
			}
		}
		
		private function drawBrokenLine(target:Function):void {
			var pointBlock:Array;
			var p:Point;
			var pp:Point;
			for (var i:uint = 0; i < _nowPointsToDraw.length; i++) {
				pointBlock = _nowPointsToDraw[i];
				for (var j:uint = 0; j < pointBlock.length; j++) {
					p = pointBlock[j];
					pp = pointBlock[j + 1];
					if (pp) {
						target(
							_relations.graphics,
							p,
							pp,
							RELATE_LINE_SHIFT,
							_nowLineColor,
							1,
							ALPHA
						);
					}
				}
			}			
		}
		
		/** Получаем все связи [родных муж/жена] в ввиде массивов точек для рисования */
		/** Вид: [relateType, [], [], ..., []] */
		private function get presentPartnerPoints():Array {
			var points:Array = [];
			points.push(PRESENT_PARTNER);
			
			var pointBlock:Array;
			var union:Union = _unions.presentPartnerUnion;
			
			if (union == null) return points;
			
			var targets:Array = union.unions;
			var targetTreeItem:TreeItem;
			
			var begin:Point;
			var end:Point;
			
			var drawElement:MovieClip;
			var middle:Number;
			var drawElementPos:Point;
			
			for (var i:uint = 0; i < targets.length; i++) {
				pointBlock = [];
				targetTreeItem = targets[i];
				
				begin = new Point(_treeItemBegin.x + _treeItemBegin.backHalfSize.x, _treeItemBegin.y + _treeItemBegin.backHalfSize.y);
				end = new Point(targetTreeItem.x + targetTreeItem.backHalfSize.x, targetTreeItem.y + targetTreeItem.backHalfSize.y);
				
				drawElement = union.drawElement;
				middle = Point.distance(begin, end) / 2;
				
				if (begin.x < end.x) drawElementPos = new Point(begin.x + middle, begin.y);
				else drawElementPos = new Point(begin.x - middle, begin.y);
				
				drawElement.x = drawElementPos.x;
				drawElement.y = drawElementPos.y;
				_relations.addChild(drawElement);
				
				points.push(pointBlock);
			}	
			
			return points;
		}
		
		/** Получаем все связи [прошлые муж/жена] в ввиде массивов точек для рисования */
		/** Вид: [relateType, [], [], ..., []] */
		private function get pastPartnerPoints():Array {
			var points:Array = [];
			points.push(PAST_PARTNER);
			
			var pointBlock:Array;
			var union:Union = _unions.pastPartnerUnion;
			
			if (union == null) return points;
			
			var targets:Array = union.unions;
			var targetTreeItem:TreeItem;
			
			var begin:Point;
			var end:Point;
			
			for (var i:uint = 0; i < targets.length; i++) {
				pointBlock = [];
				targetTreeItem = targets[i];
				
				begin = new Point(_treeItemBegin.x + _treeItemBegin.backHalfSize.x, _treeItemBegin.y + _treeItemBegin.backHalfSize.y);
				end = new Point(targetTreeItem.x + targetTreeItem.backHalfSize.x, targetTreeItem.y + targetTreeItem.backHalfSize.y);
				
				if (targetTreeItem.x <= _treeItemBegin.x) {
					begin.x = begin.x - SHIFT;
					end.x = end.x + SHIFT;
				} else {
					begin.x = begin.x + SHIFT;
					end.x = end.x - SHIFT;
				}
				
				pointBlock.push(begin);
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					var s:Number = targetTreeItem.y - SIBLING_SHIFT;
					var t:Number = _treeItemBegin.y - SIBLING_SHIFT;
					
					pointBlock.push(new Point(begin.x, t));
					
					if (s < t) pointBlock.push(new Point(begin.x, s));
					else pointBlock.push(new Point(end.x, t));
					
					pointBlock.push(new Point(end.x, s));
				}
				
				pointBlock.push(end);
				points.push(pointBlock);
			}	
			
			return points;
		}
		
		
		/** Получаем все связи [муж/жена как родители] в ввиде массивов точек для рисования */
		/** Вид: [relateType, [], [], ..., []] */
		private function get parentPoints():Array {
			var points:Array = [];
			points.push(PARENT);
			
			var pointBlock:Array = [];
			var union:Union = _unions.parentUnion;
			
			if (union == null) return points;
			
			var level:Level = Desktop.instance.getLevelByUID(_treeItemBegin.level);
			var levelShift:Number = level.y + PARENT_SHIFT;
			
			var begin:Point;
			var middle:Point;
			var end:Point;
			
			var presentPartnerUnion:Union; // Союз настоящий родительский...
			var pastPartnerUnion:Union; // Прошлый родительский союз...
			
			var firstPresentParent:TreeItem;
			var secondPresentParent:TreeItem;
			
			// Пытаюсь понять, есть ли для данного TreeItemBegin реальные настоящие родители в союзе...
			presentPartnerUnion = _relations.tree.relationController.getPresentPartnerUnion(union.parent);
			
			// Пытаюсь понять, есть ли для данного TreeItemBegin родители в прошлом союзе...
			if (presentPartnerUnion) {
				// С разных сторон...
				pastPartnerUnion = _relations.tree.relationController.getPastPartnerUnion(presentPartnerUnion.parent);
				if (!pastPartnerUnion) pastPartnerUnion = _relations.tree.relationController.getPastPartnerUnion(presentPartnerUnion.unions[0]);
			}
			 
			begin = new Point(_treeItemBegin.x + _treeItemBegin.backHalfSize.x, _treeItemBegin.y + _treeItemBegin.backHalfSize.y);
			pointBlock.push(begin);
			
			
			
			
			function present():void {
				firstPresentParent = presentPartnerUnion.parent;
				secondPresentParent = presentPartnerUnion.unions[0];
				
				var a:Point = new Point(firstPresentParent.x + firstPresentParent.backHalfSize.x, firstPresentParent.y + firstPresentParent.backHalfSize.y)
				var b:Point = new Point(secondPresentParent.x + secondPresentParent.backHalfSize.x, secondPresentParent.y + secondPresentParent.backHalfSize.y);
				
				var distance:Number = Point.distance(a, b) / 2;
				
				var center:Point;
				
				if (a.x < b.x) center = new Point(a.x + distance, a.y);
				else center = new Point(a.x - distance, a.y);
				
				middle = new Point(center.x, levelShift);
				end = new Point(center.x, center.y);
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					pointBlock.push(new Point(begin.x, levelShift));
				}
				
				pointBlock.push(middle);
				pointBlock.push(end);
			}
			
			
			
			
			function past():void {
				points[0] = PAST_PARTNER;
				
				firstPresentParent = pastPartnerUnion.parent;
				secondPresentParent = pastPartnerUnion.unions[0];
				
				var a:Point = new Point(firstPresentParent.x + firstPresentParent.backHalfSize.x, firstPresentParent.y + firstPresentParent.backHalfSize.y)
				var b:Point = new Point(secondPresentParent.x + secondPresentParent.backHalfSize.x, secondPresentParent.y + secondPresentParent.backHalfSize.y);
				
				var distance:Number = Point.distance(new Point(a.x, a.y), new Point(b.x, a.y)) / 2;
				
				var center:Point;
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_SIMPLE) {
					var hypotenuse:Number = Point.distance(a, b) / 2;
					var cathetus:Number = Point.distance(new Point(a.x, a.y), new Point(b.x, a.y)) / 2;
					var resultCathetus:Number = Math.sqrt(hypotenuse * hypotenuse - cathetus * cathetus);
					
					var r:Number;
					
					if (a.y < b.y) r = a.y + resultCathetus;
					else r = a.y - resultCathetus;
					
					if (a.x < b.x) center = new Point(a.x + distance, r);
					else center = new Point(a.x - distance, r);
					
					middle = new Point(center.x, levelShift);
					end = new Point(center.x, center.y);
				} else if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					pointBlock.push(new Point(begin.x, levelShift));
					
					var to:Number;
					if (firstPresentParent.y < secondPresentParent.y) to = firstPresentParent.y - SIBLING_SHIFT;
					else to = secondPresentParent.y - SIBLING_SHIFT;
					
					if (a.x < b.x) center = new Point(a.x + distance, a.y);
					else center = new Point(a.x - distance, a.y);
					
					middle = new Point(center.x, levelShift);
					end = new Point(center.x, to);
				}				
				
				pointBlock.push(middle);
				pointBlock.push(end);
			}
			
			
			
			
			if (presentPartnerUnion && !pastPartnerUnion) { // Есть реальный настоящий союз и нет прошлого...
				present();				
			} else if (!presentPartnerUnion && pastPartnerUnion) { // Есть прошлый союз, но нет реального союза... 
				past();				
			} else if (presentPartnerUnion && pastPartnerUnion) { // Есть реальный настоящий союз и прошлый союз...
				// Здесь нужно выяснить, к какому союзу относиться данный ребенок и тогда определить его к этому союзу...
				
				// Если это ребенок того или иного союза по двум родителям, к этому союзу его и прикрепляем...
				var allParents:Array = _treeItemBegin.treeItemRelative.relatives[PARENT];
				
				var firstParent_present:Boolean = TreeController.isUID(presentPartnerUnion.parent.uid, allParents);
				var secondParent_present:Boolean = TreeController.isUID(presentPartnerUnion.unions[0].uid, allParents);
				
				var firstParent_past:Boolean = TreeController.isUID(pastPartnerUnion.parent.uid, allParents);
				var secondParent_past:Boolean = TreeController.isUID(pastPartnerUnion.unions[0].uid, allParents);
				
				if (firstParent_present && secondParent_present) present();
				else if (firstParent_past && secondParent_past) past();
				else throw new Error("Stop! Error! No union for child uid = " + _treeItemBegin.uid); 
				
			} else { // Если родителей в союзе нет, то буду просто рисовать линию до этого родителя...
				
				pointBlock.push(new Point(begin.x, levelShift));
				end = new Point(union.parent.x + union.parent.backHalfSize.x, union.parent.y + union.parent.backHalfSize.y);
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					pointBlock.push(new Point(end.x, levelShift));
				}
				
				pointBlock.push(end);
			}
			
			
			
			
			points.push(pointBlock);
			
			return points;
		}
		
		/** Получаем все связи [родные братья/сестеры] в ввиде массивов точек для рисования */
		/** Вид: [relateType, [], [], ..., []] */
		private function get ownSiblingPoints():Array {
			var points:Array = [];
			points.push(OWN_SIBLING);
			
			var pointBlock:Array;
			var union:Union = _unions.ownSiblingUnion;
			
			if (union == null) return points;
			
			var targets:Array = union.unions;
			var targetTreeItem:TreeItem;
			
			var begin:Point;
			var end:Point;
				
			for (var i:uint = 0; i < targets.length; i++) {
				pointBlock = [];
				targetTreeItem = targets[i];
				
				begin = new Point(_treeItemBegin.x + _treeItemBegin.backHalfSize.x, _treeItemBegin.y + _treeItemBegin.backHalfSize.y);
				end = new Point(targetTreeItem.x + targetTreeItem.backHalfSize.x, targetTreeItem.y + targetTreeItem.backHalfSize.y);
				
				if (targetTreeItem.x <= _treeItemBegin.x) {
					begin.x = begin.x - SHIFT;
					end.x = end.x + SHIFT;
				} else {
					begin.x = begin.x + SHIFT;
					end.x = end.x - SHIFT;
				}
					
				pointBlock.push(begin);
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					var s:Number = targetTreeItem.y - SHIFT;
					var t:Number = _treeItemBegin.y - SHIFT;
					
					pointBlock.push(new Point(begin.x, t));
					
					if (s < t) pointBlock.push(new Point(begin.x, s));
					else pointBlock.push(new Point(end.x, t));
					
					pointBlock.push(new Point(end.x, s));
				}
				
				pointBlock.push(end);
				points.push(pointBlock);
			}	
			
			return points;
		}
		
		/** Получаем все связи [дальние братья/сестеры] в ввиде массивов точек для рисования */
		/** Вид: [relateType, [], [], ..., []] */
		private function get siblingPoints():Array {
			var points:Array = [];
			points.push(SIBLING);
			
			var pointBlock:Array;
			var union:Union = _unions.siblingUnion;
			
			if (union == null) return points;
			
			var targets:Array = union.unions;
			var targetTreeItem:TreeItem;
			
			var begin:Point;
			var end:Point;
			
			for (var i:uint = 0; i < targets.length; i++) {
				pointBlock = [];
				targetTreeItem = targets[i];
				
				begin = new Point(_treeItemBegin.x + _treeItemBegin.backHalfSize.x, _treeItemBegin.y + _treeItemBegin.backHalfSize.y);
				end = new Point(targetTreeItem.x + targetTreeItem.backHalfSize.x, targetTreeItem.y + targetTreeItem.backHalfSize.y);
				
				if (targetTreeItem.x <= _treeItemBegin.x) {
					begin.x = begin.x - SHIFT;
					end.x = end.x + SHIFT;
				} else {
					begin.x = begin.x + SHIFT;
					end.x = end.x - SHIFT;
				}
				
				pointBlock.push(begin);
				
				if (_type == RelationSetter.RELATE_DRAW_TYPE_CASCADE) {
					var s:Number = targetTreeItem.y - SIBLING_SHIFT;
					var t:Number = _treeItemBegin.y - SIBLING_SHIFT;
					
					pointBlock.push(new Point(begin.x, t));
					
					if (s < t) pointBlock.push(new Point(begin.x, s));
					else pointBlock.push(new Point(end.x, t));
					
					pointBlock.push(new Point(end.x, s));
				}
				
				pointBlock.push(end);
				points.push(pointBlock);
			}	
						
			return points;
		}	
		
		/** Интерфейс */
		
		public function update():void {
			_type = _relations.type;
			
			_allPointsToDraw = [];
			
			_allPointsToDraw.push(presentPartnerPoints);
			_allPointsToDraw.push(pastPartnerPoints);
			_allPointsToDraw.push(parentPoints);
			_allPointsToDraw.push(ownSiblingPoints);
			_allPointsToDraw.push(siblingPoints);
			
			for (var i:uint = 0; i < _allPointsToDraw.length; i++) { 
				_nowPointsToDraw = _allPointsToDraw[i];
				
				var presentType:uint = _nowPointsToDraw.shift();
				var lineType:uint = RELATE_LINE_STYLE[presentType];
				_nowLineColor = RELATE_COLORS[presentType];
				
				if (lineType == SOLID_LINE) drawSimpleLine(); // Простая линия
				else if (lineType == DASH_LINE) drawBrokenLine(Utils.drawDashLine); // Пунктир
				else if (lineType == DOT_LINE) drawBrokenLine(Utils.drawDotLine); // Точки
				else throw new Error("Stop! Error! No RelationLineType = " + lineType + " to draw relation!");
			}
		}
		
		public function dispose():void {
			
		}
	}
}