package tree.view.canvas {
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

public class CanvasRules extends Sprite{

	private var availableCoordsHolder:Shape

	public function CanvasRules() {
		availableCoordsHolder = new Shape();
		addChild(availableCoordsHolder)
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

	public function removeAvailableCoords():void {
		availableCoordsHolder.graphics.clear();
		availableCoordsHolder.graphics.beginFill(0x0000FF, 0.1);
	}

	public function drawAvailableCoord(x:int, y:int):void {
		availableCoordsHolder.graphics.drawRect(x, y, Canvas.ICON_WIDTH_SPACE, Canvas.LEVEL_HEIGHT);
	}
}
}
