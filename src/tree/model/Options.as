package tree.model {
import tree.common.Config;
import tree.view.gui.profile.PersonProfilePage;

public class Options {

	private var flashVars:Object;
	private var serverValues:Object = {};

	public function Options() {
		flashVars = Config.loader.flashVars || {};
	}

	private function getProp(name:String, defaultVal:*):*{
		if(serverValues[name] !== undefined)
			return defaultVal is Number ? parseFloat(serverValues[name]) : serverValues[name];

		if(flashVars[name] !== undefined)
			return flashVars[name]

		return defaultVal;
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
	public function get defaultZoom():Number { return getProp('zoom', 1); }

	/**
	 * Параметры, отвечающие за отказ от построения части нод, если дерево излишне большое
	 */
	public function get maxNodesQuantity():int { return getProp('maxNodesQuantity', 500); }// внутри одного отдельного дерева (т.е. у человека может быть несколько деревьев, все они усекаются до maxNodesQuantity вершин)
	public function get maxGenerationsDepth():int { return getProp('maxGenerationsDepth', 10); }// от корня дерева вверх и вниз не более чем на maxGenerationsDepth поколений
	public function get maxDepth():int { return getProp('maxDepth', 10); }// не рисовать ноды, отстоящие от центральной ноды дерева на расстояние, больше, чем maxDepth

	// ассоциативный массив полей, которые следует показывать в профайле
	public function get displayFields():Array{
		var s:String = getProp('display_fields', PersonProfilePage.DEFAULT_DISPLAY_FIELDS);
		var arr:Array = [];
		for each(var pairs:String in s.split(',')){
			var pair:Array = pairs.split('=');
			arr[pair[0]] = pair[1];
		}
		return arr;
	}

	/**
	 * Направление роста дерева по умолчанию
	 */
	public function get defaultOrderDesc():Boolean{ return getProp('mode', 'asc') == 'asc'; }// нисходящее (DESC) дерево по умолчанию (на сервере всё перепутали)

	public function get animation():Boolean{return parseInt(getProp('animation', 1)) != 0;}

	public function read(setup:XMLList):void {
		var config:Array = [
			{s: 'display_fields', n: 'display_fields'},
			{s: 'zoom', n: 'zoom'},
			{s: 'mode', n: 'mode'},
			{s: 'animation', n: 'animation'},

		];
		for each(var c:Object in config){
			var sData:String = String(setup.option.(@name == c.s));
			if(c && sData.length > 0){
				serverValues[c.n] = sData;
			}
		}

	}
}
}
