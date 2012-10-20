package tree.signal {
	public class ViewSignal {

		public static const CANVAS_READY_FOR_START:String = 'canvasReadyForStart';// канва готова для построения нового дерева

		public static const JOIN_QUEUE_STARTED:String = 'joinQueueStarted';// просчитана и готова к начать появляться новая очередь Join-ов

		public static const DRAW_JOIN:String = 'drawJoin';// событие от контроллера, что пришло время построить очередную связь (g:GenNode)

		public static const REMOVE_JOIN:String = 'removeJoin';// пришло время удалить связь (g:GenNode)

		public static const JOIN_DRAWED:String = 'joinDrawed';// канва построила очередную связь и готова для дальнейших манипуляций

		public static const NODE_ROLL_UNROLL:String = 'nodeRoll';// свернуть-развернуть выбранную ноду

		public static const JOIN_QUEUE_COMPLETED:String = 'joinQueueCompleted';// все ноды построены

		public static const ALL_TREES_COMPLETED:String = 'allTreesCompleted';// все ноды построены

		public static const RECALCULATE_ROLL_UNROLL:String = 'recalculateRollUnroll';// скрыть все кнопки roll-unroll и начать их пересчет

		public static const CALCULATE_NEXT_ROLL_UNROLL:String = 'calculateNextRollUnroll';// калькулировать очередную ноду на возможность отображения кнопки roll-unroll

		public static const PERSON_DESELECTED:String = 'personDeselected';// с персоны снят выбор в GUI (person:Person)

		public static const PERSON_SELECTED:String = 'personSelected';// персона выбрана в GUI (person:Person)

		public static const TREE_DESELECTED:String = 'treeDeselected';// с дерева снят выбор в GUI (tree:TreeModel)

		public static const TREE_SELECTED:String = 'treeSelected';// дерево выбрана в GUI (tree:TreeModel)

		public static const PERSON_CENTERED:String = 'personCentered';// запрос на центровку на персоне (person:Person)

		public static const NEED_CENTRE_CANVAS:String = 'needCentreCanvas';

		public static const START_EDIT_PERSON:String = 'startEditPerson';// нужно перейти в режим редактирования выбранной ноды (person:Person, joinType:JoinType = null, from:Person = null)

		public static const DESCENDING_CHANGED:String = 'DescendingChanged';// правило (родители выше детей/ родители ниже детей) изменено

		public static const REFRESH_NODE_POSITIONS:String = 'RefreshNodePositions';// мгновенно обновить позиционирование всех нод дерева

		public static const REFRESH_JOIN_LINES:String = 'RefreshJoinLines';// мгновенно перерисовать все линии связей дерева

		public static const REFRESH_GENERATIONS:String = 'RefreshGenerations';// перерисовать все фоны поколений




		public function ViewSignal() {
		}
	}
}
