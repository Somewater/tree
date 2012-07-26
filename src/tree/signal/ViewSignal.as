package tree.signal {
	public class ViewSignal {

		public static const CANVAS_READY_FOR_START:String = 'canvasReadyForStart';// канва готова для построения нового дерева

		public static const JOIN_QUEUE_STARTED:String = 'joinQueueStarted';// просчитана и готова к начать появляться новая очередь Join-ов

		public static const DRAW_JOIN:String = 'drawJoin';// событие от контроллера, что пришло время построить очередную связь

		public static const JOIN_DRAWED:String = 'joinDrawed';// канва построила очередную связь и готова для дальнейших манипуляций

		public static const NODE_ROLL_UNROLL:String = 'nodeRoll';// свернуть-развернуть выбранную ноду

		public static const JOIN_QUEUE_COMPLETED:String = 'joinQueueCompleted';// все ноды построены

		public function ViewSignal() {
		}
	}
}
