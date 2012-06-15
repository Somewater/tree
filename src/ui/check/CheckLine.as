package ui.components.check {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ui.components.radio.LineInfo;
	import ui.components.radio.Radio;
	import ui.components.radio.RadioLine;
	
	public class CheckLine extends RadioLine {
		
		public function CheckLine(lineInfo:LineInfo) {
			super(lineInfo);
		}
		
		/** Переопределение */
		
		override protected function createBack():Sprite {
			var s:Sprite = Utils.createSquare(
				_radioLineInfo.back[0],
				_radioLineInfo.back[1],
				_radioLineInfo.back[2],
				_radioLineInfo.back[3],
				_radioLineInfo.back[4]
			);
			s.filters = _radioLineInfo.radioFilter;
			return s;
		}
		
		override protected function createActive():Sprite {
			var s:Sprite = Utils.createTick(
				_radioLineInfo.active[0],
				_radioLineInfo.active[1]
			);
			s.filters = _radioLineInfo.radioFilter;
			return s;
		}
		
		override protected function onClick(e:Event):void {
			var radio:Radio = Radio(e.target);
			if (radio.select) radio.select = false;
			else radio.select = true;
		}
	}
}