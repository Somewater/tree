package tree.view.canvas {

	import tree.common.Config;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.Mediator;

	public class CanvasMediator extends Mediator
	{
		private var canvas:Canvas;

		public function CanvasMediator(view:Canvas)
		{
			this.canvas = view;
			super(view);

			addModelListener(ModelSignal.NODES_RECALCULATED, onModelChanged);
		}

		override public function clear():void {
			super.clear();
			canvas = null;
		}

		override protected function refresh():void {
			canvas.x = (Config.WIDTH - Config.GUI_WIDTH) * 0.5;
			canvas.y = Config.HEIGHT * 0.5;
			canvas.setSize(Config.WIDTH, Config.HEIGHT);
		}

		private function onModelChanged():void {
			// todo: провести анимацию перехода, если уже было построено какое-то дерево
			bus.canvas.dispatch(ViewSignal.CANVAS_CONSTRUCTION_STARTED);

			// todo: начать построение дерева
		}
	}
}
