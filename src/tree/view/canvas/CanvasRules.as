package tree.view.canvas {
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import tree.model.Model;

public class CanvasRules extends Sprite{

	private var availableCoordsHolder:Shape

	private var snapColor:uint;
	private var snapAlpha:Number = 0;
	private var availableColor:uint;
	private var availableAlpha:Number = 0;

	public function CanvasRules() {
		availableCoordsHolder = new Shape();
		addChild(availableCoordsHolder)
	}

	public function refresh(minX:int, minY:int, maxX:int, maxY:int, xStep:int, yStep:int):void {
		snapColor = Model.instance.options.handHighlightSnapColor;
		snapAlpha = Model.instance.options.handHighlightSnapAlpha;
		availableColor = Model.instance.options.handHighlightAvailableColor;
		availableAlpha = Model.instance.options.handHighlightAvailableAlpha;

		if(snapAlpha == 0) return;
		var g:Graphics = this.graphics;

		g.clear();
		g.lineStyle(0, snapColor, snapAlpha);

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
		if(availableAlpha == 0) return;
		availableCoordsHolder.graphics.clear();
		availableCoordsHolder.graphics.beginFill(availableColor, availableAlpha);
	}

	public function drawAvailableCoord(x:int, y:int):void {
		if(availableAlpha == 0) return;
		availableCoordsHolder.graphics.drawRect(x, y, Canvas.ICON_WIDTH_SPACE, Canvas.LEVEL_HEIGHT);
	}
}
}
