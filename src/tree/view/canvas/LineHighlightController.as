package tree.view.canvas {
	import flash.geom.Point;

	import tree.command.Actor;
	import tree.common.Config;
	import tree.model.Join;
	import tree.model.Node;
	import tree.model.Person;
	import tree.model.lines.Icon;
	import tree.model.lines.Line;
	import tree.model.lines.LineMatrix;
	import tree.model.lines.LineMatrixCollection;

	public class LineHighlightController extends Actor{

		private var canvas:Canvas;
		private var zoomedPosition:Point = new Point();
		private var highlighted:Array = [];
		private var lineModelCollection:LineMatrixCollection;
		public var supressMouseMoveAction:Boolean = false;

		public function LineHighlightController(canvas:Canvas) {
			this.canvas = canvas;
			lineModelCollection = Config.inject(LineMatrixCollection);
		}

		public function onMouseMove(position:Point):void {
			if(supressMouseMoveAction)
				return;

			zoomedPosition = canvas.globalToLocal(position);
			var mouseX:int = zoomedPosition.x;
			var mouseY:int = zoomedPosition.y;
			var newHighlighted:Array = [];
			var m:LineMatrix;
			var l:Line;
			var linesByConstart:Array;
			var delta:int;
			var jl:JoinLine;
			var icon:Icon;
			var iconFinded:Boolean = false;

			for each(icon in lineModelCollection.iconsByUids)
			{
				var dx:int = icon.x - mouseX;
				var dy:int = icon.y - mouseY;
				if(dx * dx + dy * dy < 100){
					iconFinded = true;
					var p0:Person = icon.join.from;
					var p1:Person = icon.join.associate;
					newHighlighted.push(canvas.getJoinLine(p0.uid, p1.uid));
					var p0Breeds:Array = p0.breeds;
					var p1Breeds:Array = p1.breeds;
					for each(var child:Person in p0Breeds)
						if(p1Breeds.indexOf(child) != -1){
							jl = canvas.getJoinLine(p0.uid, child.uid);
							if(!jl)jl = canvas.getJoinLine(p1.uid, child.uid);
							if(jl)newHighlighted.push(jl);
						}
					break;
				}
			}

			if(!iconFinded){
				for each(m in lineModelCollection.horizontalMatrixesByMask)
					for each(linesByConstart in m.linesByConstant)
						for each(l in linesByConstart){
							delta = l.constant - mouseY;
							if(delta * delta < 25 && l.start < mouseX && l.end > mouseX)
								newHighlighted.push(canvas.getJoinLine(l.join.associate.uid, l.join.from.uid));
						}


				for each(m in lineModelCollection.verticalMatrixesByMask)
					for each(linesByConstart in m.linesByConstant)
						for each(l in linesByConstart){
							delta = l.constant - mouseX;
							if(delta * delta < 25 && l.start < mouseY && l.end > mouseY)
								newHighlighted.push(canvas.getJoinLine(l.join.associate.uid, l.join.from.uid));
						}
			}

			setNewHighlight(newHighlighted);
		}

		private function setNewHighlight(newHighlighted:Array):void{
			var jl:JoinLine;
			var forAdd:Array = [];
			var forRemove:Array = [];

			var i:int = 0;
			while(i < newHighlighted.length)
				if(newHighlighted[i] == null)
					newHighlighted.splice(i, 1);
				else
					i++;

			for each(jl in newHighlighted)
				if(highlighted.indexOf(jl) == -1)
					forAdd.push(jl);

			for each(jl in highlighted)
				if(newHighlighted.indexOf(jl) == -1)
					forRemove.push(jl);

			for each(jl in forAdd)
				jl.highlighted = true;

			for each(jl in forRemove)
				jl.highlighted = false;

			highlighted = newHighlighted;
		}

		public function start():void{
			bus.mouseMove.add(onMouseMove);
		}

		public function stop():void{
			bus.mouseMove.remove(onMouseMove);
			clearHighlighted();
		}

		public function clearHighlighted():void{
			if(highlighted.length == 0) return;
			for each(var l:JoinLine in highlighted){
				l.highlighted = false;
			}
			highlighted = [];
		}

		public function highlightPersonLines(person:Person):void {
			var newHighlighted:Array = [];
			var jl:JoinLine;
			var marry:Person = person.marry;
			for each(var j:Join in person.joins){
				jl = canvas.getJoinLine(j.from.uid, j.associate.uid);
				if(!jl && j.breed && marry)
					jl = canvas.getJoinLine(marry.uid, j.associate.uid);
				if(jl)
					newHighlighted.push(jl);
			}
			setNewHighlight(newHighlighted);
		}
	}
}
