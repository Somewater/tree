package tree.model {
import flash.net.URLVariables;

import tree.common.Config;
import tree.view.gui.profile.PersonProfilePage;

public class Options {

	private var flashVars:Object;
	private var serverValues:Object = {};

	public function Options() {
		flashVars = Config.loader.flashVars || {};
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
	 * Размер, выставляемый по умолчанию при старте флешки
	 * При каком минимальном размере всё еще отображать кнопку "Действия"
	 */
	public function get zoomMin():Number { return parseFloat(getProp('zoomMin', 10)) * 0.01; }
	public function get zoomMax():Number { return parseFloat(getProp('zoomMax', 100)) * 0.01; }
	public function get defaultZoom():Number { return parseFloat(getProp('zoom', 100)) * 0.01; }
	public function get actionBtnZoomSeparator():Number { return parseFloat(getProp('actionBtnZoomSeparator', 80)) * 0.01; }

	/**
	 * Параметры, отвечающие за отказ от построения части нод, если дерево излишне большое
	 */
	public function get maxNodesQuantity():int { return getProp('maxNodesQuantity', 500); }// внутри одного отдельного дерева (т.е. у человека может быть несколько деревьев, все они усекаются до maxNodesQuantity вершин)
	public function get maxGenerationsDepth():int { return getProp('maxGenerationsDepth', 10); }// от корня дерева вверх и вниз не более чем на maxGenerationsDepth поколений
	public function get maxDepth():int { return getProp('maxDepth', 10); }// не рисовать ноды, отстоящие от центральной ноды дерева на расстояние, больше, чем maxDepth

	// ассоциативный массив полей, которые следует показывать в профайле
	public function get displayFields():Array{
		var s:String = getProp('display_fields', PersonProfilePage.DEFAULT_DISPLAY_FIELDS);
		return parseDisplayFields(s);
	}

	public function parseDisplayFields(str:String):Array{
		var arr:Array = [];
		for each(var pairs:String in str.split(',')){
			var pair:Array = pairs.split('=');
			arr[pair[0]] = pair[1];
		}
		return arr;
	}

	/**
	 * Направление роста дерева по умолчанию
	 */
	public function get defaultOrderDesc():Boolean{ return getProp('mode', 'asc') == 'asc'; }// изначально препутал, defaultOrderDesc=true на самом деле рисует восходящее дерево, учитываю эту багу

	/**
	 * Анимация построения (сворачивания-разворачивания, при редактировании и т.д.) работает
	 */
	public function get animation():Boolean{return parseInt(getProp('animation', 1)) != 0;}

	/**
	 * Путь до страницы настроек
	 */
	public function get setupUrl():String { return getProp('setup_url', null); }

	/**
	 * Путь до страницы сохранения
	 */
	public function get saveUrl():String { return getProp('save_url', null); }

	/**
	 * Ручной режим работосопсобен, если просматривается дерево с правами редактирования
	 */
	public function get handPermitted():Boolean {return getBoolProp('handPermitted', true);  }

	/**
	 * Переход между деревьями в виде 3D куба
	 */
	public function get cube3d():Boolean{return getBoolProp('cube3d', true);}

	/**
	 * Интервал (секунды) между автосохранениями расстановки в ручном режиме
	 */
	public function get autoSaveHandMode():int{return getProp('autoSaveHandMode', 30);}

	public function get currentYear():int{return getProp('current_year', 0);}
	public function get currentTime():Number{return parseFloat(getProp('current_time', 0.0));}// unixtime, секунды

	public function get defaultMalePhoto():String {
		return getProp('male_photo', 'http://static.familyspace.ru/i/system/users/u2_nophoto1.png');
	}

	public function get defaultFemalePhoto():String {
		return getProp('female_photo', 'http://static.familyspace.ru/i/system/users/u2_nophoto0.png');
	}

	public function read(setup:XMLList):void {
		for each(var option:XML in setup.*){
			var oName:String = String(option.@name);
			var oValue:String = option.toString();
			serverValues[oName] = oValue;
		}
	}

	private function getProp(name:String, defaultVal:*):*{
		if(serverValues[name] !== undefined)
			return defaultVal is Number ? parseFloat(serverValues[name]) : serverValues[name];

		if(flashVars[name] !== undefined)
			return flashVars[name]

		return defaultVal;
	}

	private function getBoolProp(name:String, defaultVal:Boolean):Boolean{
		var val:String = String(getProp(name, defaultVal));
		return val != '0' && val != 'false';
	}

	public function get userId():int {
		var get:String = flashVars['get'];
		var uid:int = 0;
		if(get && get.length)
		{
			var v:URLVariables = new URLVariables(get);
			uid = v.uid;
		}
		return uid;
	}
}
}
