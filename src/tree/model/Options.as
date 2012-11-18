package tree.model {
import tree.common.Config;

public class Options {

	private var flashVars:Object;

	public function Options() {
		flashVars = Config.loader.flashVars || {};
	}

	private function getProp(name:String, defaultVal:*):*{
		if(flashVars[name] === undefined)
			return defaultVal
		else
			return flashVars[name]
	}

	/**
	 * Минимальная продолжительность анимации, при которой работает твинер
	 * Т.е. анимация, требующее временную величину меньше указанной,  происходит "мгновенно"
	 * (твинер не создается, что существенно экономит ресурсы ЦП)
	 * В зависимости от текущего состояния, приложение воспроизводит или отказывается воспроизводить анимацию
	 *
	 * AnimQualityN - выбранное (на основе кол-ва нод дерева) "качество" анимации (чем больше, тем больше анимации)
	 * "0" - без анимации, "2" - полная анимация, "1" - больщинстов анимации отключено
	 */
	public function get minAnimQuality0():Number { return getProp('minAnimQuality0', 10); }
	public function get minAnimQuality1TreeUncompl():Number { return getProp('minAnimQuality1TreeUncompl', 0.4); };// при условии, что дерево еще не до конца достроено
	public function get minAnimQuality1():Number { return getProp('minAnimQuality1', 0.1); }
	public function get minAnimQuality2():Number { return getProp('minAnimQuality2', 0.05); }

	/**
	 * Величина дерева, при которой включается та или иная AnimQuality
	 * 	если нод больше, чем animQualityLow, animQuality=0
	 * 	если нод больше, чем animQualityMedium, animQuality=1,
	 * 	иначе максимальное качество animQuality=2
	 */
	public function get animQualityLow():int { return getProp('animQualityLow', 300); }
	public function get animQualityMedium():int { return getProp('animQualityMedium', 100); }

	/**
	 * Максимальное время, отводимое на построение всего дерева и мин. время на построение отдельной ноды
	 * Используется минимум от величин: Math.min(maxTimeForOne, maxTimeForAll / number)
	 * Время измеряется в тактах работы приложения,  1 такт = 1/30 секунды
	 */
	public function get maxTreeConstructTime():int { return getProp('maxTreeConstructTime', 5); }
	public function get maxTreeConstructTimeTreeUncompl():int { return getProp('maxTreeConstructTimeTreeUncompl', 10); }// при условии, что дерево еще не до конца достроено
	public function get minNodeConstructTime():int { return getProp('minNodeConstructTime', 1); }

	/**
	 * Минимальный и максимальный размер зума дерева
	 */
	public function get zoomMin():Number { return getProp('zoomMin', 0.1); }
	public function get zoomMax():Number { return getProp('zoomMax', 1); }

	/**
	 * Параметры, отвечающие за отказ от построения части нод, если дерево излишне большое
	 */
	public function get maxNodesQuantity():int { return getProp('maxNodesQuantity', 500); }// внутри одного отдельного дерева (т.е. у человека может быть несколько деревьев, все они усекаются до maxNodesQuantity вершин)
	public function get maxGenerationsDepth():int { return getProp('maxGenerationsDepth', 10); }// от корня дерева вверх и вниз не более чем на maxGenerationsDepth поколений
	public function get maxDepth():int { return getProp('maxDepth', 10); }// не рисовать ноды, отстоящие от центральной ноды дерева на расстояние, больше, чем maxDepth
}
}
