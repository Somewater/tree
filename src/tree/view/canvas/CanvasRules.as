package tree.view.canvas {
import flash.display.Graphics;
import flash.display.Shape;

public class CanvasRules extends Shape{
	public function CanvasRules() {
	}

	public function refresh(minX:int, minY:int, maxX:int, maxY:int, xStep:int, yStep:int):void {
		var g:Graphics = this.graphics;

		g.clear();
		g.lineStyle(0, 0xCCCCCC);

		var i:int;
		for(i = minX; i< maxX; i += xStep){
			g.moveTo(i,  minY);
			g.lineTo(i,  maxY);
		}

		for(i = minY; i< maxY; i += yStep){
			g.moveTo(minX, i);
			g.lineTo(maxX, i);
		}
	}
}
}
