package ui.radio {
	
	import flash.text.TextFormat;
	
	public class LineInfo {
		
		public var elements:Array;
		public var back:Array;
		public var active:Array;
		public var shift:uint;
		public var loginTextFormat:TextFormat;
		public var positionType:Boolean; // false/true gorizontal/vertical
		public var filters:Array;
		public var radioFilter:Array;
		
		public function LineInfo(
			elements:Array,
			back:Array,
			active:Array,
			shift:uint,
			loginTextFormat:TextFormat,
			positionType:Boolean = true,
			filters:Array = null,
			radioFilter:Array = null
		) {
			this.elements = elements;
			this.back = back;
			this.active = active;
			this.shift = shift;
			this.loginTextFormat = loginTextFormat;
			this.positionType = positionType;
			this.filters = filters;
			this.radioFilter = radioFilter;
		}
	}
}