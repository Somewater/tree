package tree.view {
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;

public class ShadeGround extends Sprite{

	private var blackBack:Shape;
	private var back:Shape;
	private var _width:Number = 0;
	private var _height:Number = 0;

	private var shadowSize:Number;

	public function ShadeGround(shadowSize:Number = 5) {
		this.shadowSize = shadowSize;

		back = new Shape();
		addChildAt(back, 0);
		blackBack = new Shape();
		addChildAt(blackBack, 0);
	}

	public function setSize(width:int, height:int):void {
		_width = width;
		_height = height;
		resize();
	}

	protected function resize():void {
		back.graphics.clear();
		blackBack.graphics.clear();

		const RADIUS:int = 10;
		back.graphics.beginFill(0xFFFFFF);
		back.graphics.drawRoundRectComplex(0, 0, _width, _height, RADIUS, RADIUS, RADIUS, RADIUS);
		back.graphics.endFill();

		const ELLIPSE_WIDTH:int = _width * shadowSize;
		const ELLIPSE_HEIGHT:int = _height * shadowSize;
		const ELL_DX:int = (ELLIPSE_WIDTH - _width) * 0.5
		const ELL_DY:int = (ELLIPSE_HEIGHT - _height) * 0.5;
		var mat:Matrix= new Matrix();
		var colors:Array=[0x0,0xFFFFFF];
		var alphas:Array=[0.5,0];
		var ratios:Array=[0,255];
		mat.createGradientBox(ELLIPSE_WIDTH, ELLIPSE_HEIGHT, 0, -ELL_DX, -ELL_DY);
		blackBack.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mat);
		blackBack.graphics.drawEllipse(-ELL_DX,  -ELL_DY, ELLIPSE_WIDTH, ELLIPSE_HEIGHT);
		blackBack.graphics.endFill();
	}


	override public function get width():Number {
		return _width;
	}


	override public function get height():Number {
		return _height;
	}


	override public function set width(value:Number):void {
		_width = value;
		resize();
	}


	override public function set height(value:Number):void {
		_height = value;
		resize();
	}
}
}
