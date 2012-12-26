package tree.view.canvas {
import com.junkbyte.console.Cc;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import sandy.util.DistortImage;

import tree.common.Config;

import tree.common.IClear;
import tree.manager.ITick;

public class Cube3D extends Sprite implements IClear, ITick{

	private static const DURATION_TICKS:int = 30;

	private var _active:Boolean = false;
	private var canvas:Canvas;

	private var startSide:DistortImage;
	private var startSideShape:Shape;
	private var endSide:DistortImage;
	private var endSideShape:Shape;

	private var tickCounter:int;

	public function Cube3D(canvas:Canvas) {
		this.canvas = canvas;
		this.visible = false;

		startSideShape = new Shape();
		addChild(startSideShape);
		endSideShape = new Shape();
		addChild(endSideShape);
	}

	public function start():void {
		startSide = createDistortImage(startSideShape);
		c.redMultiplier = c.greenMultiplier = c.blueMultiplier = 1;
		startSide.texture.colorTransform(startSide.texture.rect, c);
		this.visible = true;
		render(1);
	}

	public function play():void {
		endSide = createDistortImage(endSideShape);
		tickCounter = DURATION_TICKS;
		Config.ticker.add(this);
	}

	public function activate():void {
		if(startSide){
			_active = true;
			this.visible = true;
		}
	}

	public function get active():Boolean{
		return _active;
	}

	public function clear():void {
		startSide = null;
		endSide = null;
		_active = false;
		visible = false;
		Config.ticker.remove(this);
		startSideShape.graphics.clear();
		endSideShape.graphics.clear();
	}

	private function createDistortImage(shape:Shape):DistortImage{
		var di:DistortImage = new DistortImage();
		var bmpData:BitmapData = canvas.getCube3DArea();
		di.target = bmpData;
		di.container = shape;
		di.initialize(1, 1);
		di.render();
		return di;
	}

	public function tick(deltaMS:int):void {
		if(tickCounter-- > 0){
			render(tickCounter / DURATION_TICKS);
		}else{
			clear();
			canvas.fireComplete();// after animation
		}
	}

	private var c:ColorTransform = new ColorTransform(0.95,0.95,0.95);

	private function render(value:Number):void{
		c.redMultiplier = c.greenMultiplier = c.blueMultiplier = value * 0.01 + 0.99;
		startSide.texture.colorTransform(startSide.texture.rect, c);

		var w:int = startSide.texture.width;
		var h:int = startSide.texture.height;
		var padding:int = h * 0.02 * (1 - Math.abs(0.5 - value) * 2);
		var p1:Point = new Point(w * value, 0 - padding);
		var p2:Point = new Point(w * value, h + padding);
		startSide.setTransform(	0, 0,
				p1.x, p1.y,
				p2.x, p2.y,
				0, h);

		if(endSide){
			w = endSide.texture.width;
			h = endSide.texture.height;
			endSide.setTransform(	p1.x, p1.y,
					w, 0,
					w, h,
					p2.x, p2.y);
		}

		this.x = -canvas.x;
		this.y = -canvas.y + Config.PANEL_HEIGHT;
	}
}
}
