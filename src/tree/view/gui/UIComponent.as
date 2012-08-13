package tree.view.gui {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.IClear;

	public class UIComponent extends Sprite implements IClear, ISize{

		public var over:ISignal;
		public var out:ISignal;
		public var click:ISignal;
		public var dblClick:ISignal;

		public function UIComponent() {
			over = new Signal(UIComponent);
			out = new Signal(UIComponent);
			click = new Signal(UIComponent);
			dblClick = new Signal(UIComponent);

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
		}

		public function clear():void{
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);

			over.removeAll();
			out.removeAll();
			click.removeAll();
			dblClick.removeAll();

			out = over = click = dblClick = null;
		}

		private function onOver(event:MouseEvent):void {
			over.dispatch(this);
		}

		private function onOut(event:MouseEvent):void {
			out.dispatch(this);
		}

		private function onClick(event:MouseEvent):void {
			click.dispatch(this);
		}

		private function onDblClick(event:MouseEvent):void {
			dblClick.dispatch(this);
		}

		public function fireResize():void{
			dispatchEvent(new Event(Event.RESIZE))
		}

		public function get calculatedHeight():int {
			return this.height;
		}

		public function moveTo(y:int):void {
			this.y = y;
		}
	}
}
