package tree.view.gui {
	import com.somewater.display.CorrectSizeDefinerSprite;
import com.somewater.text.Hint;

import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

import tree.common.Config;

import tree.common.IClear;
import tree.model.Model;

public class UIComponent extends CorrectSizeDefinerSprite implements IClear, ISize{

		public var over:ISignal;
		public var out:ISignal;
		public var click:ISignal;
		public var dblClick:ISignal;
		public var down:ISignal;
		public var up:ISignal;

		protected var _width:Number;
		protected var _height:Number;

		private var clickFlag:uint = 0;

		private var _hint:String;

		public function UIComponent() {
			over = new Signal(UIComponent);
			out = new Signal(UIComponent);
			click = new Signal(UIComponent);
			dblClick = new Signal(UIComponent);
			down = new Signal(UIComponent);
			up = new Signal(UIComponent);

			addEventListener(MouseEvent.MOUSE_OVER, _onOver);
			addEventListener(MouseEvent.MOUSE_OUT, _onOut);
			addEventListener(MouseEvent.DOUBLE_CLICK, _onDblClick);
			addEventListener(MouseEvent.MOUSE_DOWN, _onDown);
			addEventListener(MouseEvent.MOUSE_UP, _onUp);
		}

		public function clear():void{
			removeEventListener(MouseEvent.MOUSE_OVER, _onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, _onOut);
			removeEventListener(MouseEvent.DOUBLE_CLICK, _onDblClick);
			removeEventListener(MouseEvent.MOUSE_DOWN, _onDown);
			removeEventListener(MouseEvent.MOUSE_UP, _onUp);

			over.removeAll();
			out.removeAll();
			click.removeAll();
			dblClick.removeAll();
			down.removeAll();
			up.removeAll();

			down = up = out = over = click = dblClick = null;
		}

		private function _onOver(event:MouseEvent):void {
			over.dispatch(this);
		}

		protected function _onOut(event:MouseEvent):void {
			if(event.relatedObject && this.contains(event.relatedObject))
				return;
			out.dispatch(this);
			clickFlag = 0;
		}

		private function _onDblClick(event:MouseEvent):void {
			dblClick.dispatch(this);
		}

		private function _onDown(event:MouseEvent):void {
			down.dispatch(this);
			clickFlag = getClickHash();
		}

		private function _onUp(event:MouseEvent):void {
			up.dispatch(this);
			if(clickFlag){
				if(clickFlag == getClickHash())
					click.dispatch(this)
				clickFlag = 0;
			}
		}

		private function getClickHash():uint{
			return Model.instance.canvasMovingCounter;
		}

		public function fireResize():void{
			dispatchEvent(new Event(Event.RESIZE, true))
		}

		public function get calculatedHeight():int {
			return this.height;
		}

		public function moveTo(y:int):void {
			this.y = y;
		}

		public function setSize(w:int, h:int):void{
			_width = w;
			_height = h;
			refresh();
		}

		protected function refresh():void{

		}

		override public function get width():Number {
			return isNaN(_width) ? super.width : _width;
		}

		override public function get height():Number {
			return isNaN(_height) ? super.height : _height;
		}

		override public function set width(value:Number):void {
			setSize(value, this.height);
		}

		override public function set height(value:Number):void {
			setSize(this.width, value);
		}


		public function get hint():String {
			return _hint;
		}

		public function set hint(value:String):void {
			_hint = value;
			if(value)
				Hint.bind(this, _hint);
			else
				Hint.removeHint(this);
		}
	}
}
