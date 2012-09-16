package com.somewater.text
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.view.gui.Helper;

	[Event(name="linkClick",type="com.somewater.text.LinkLabel")]
	
	public class LinkLabel extends Sprite
	{
		public static const LINK_CLICK:String = "linkClick";
		
		protected var _linked:Boolean;
		protected var _underline:Boolean = false;
		private var _dasched:Boolean = true;
		protected var _text:String;
		public var linkClick:Function;
		public var data:Object;
		public var textField:EmbededTextField;

		public var link:ISignal;
		
		public function LinkLabel(font:String=null, color:*=null, size:int=12, bold:Boolean=false, align:String="left",bitmapText:Boolean = false)
		{
			textField = new EmbededTextField(font, color, size, bold, false, false, false, align,bitmapText)
			textField.filters = [];
			addChild(textField);
			_linked = false;// иначе не сработает linked = true;
			linked = true;
			Helper.stylizeText(this);
			link = new Signal(LinkLabel);
		}
		
		public function clear():void{
			removeAllListeners();
			textField.hint = null;
			link.removeAll();
		}
		
		public function set linked(flag:Boolean):void{
			if (flag == _linked) return;
			underline = useHandCursor = buttonMode = mouseEnabled = underline = _linked = flag;
			if (flag){
				addEventListener(MouseEvent.MOUSE_OVER,headerLabelMouseOverEvent,false,0,true);
				addEventListener(MouseEvent.MOUSE_OUT,headerLabelMouseOutEvent,false,0,true);
				addEventListener(MouseEvent.CLICK,headerLabelMouseClick,false,0,true);
			}else{
				removeAllListeners();
			}
		}
		
		private function removeAllListeners():void{
			removeEventListener(MouseEvent.MOUSE_OVER,headerLabelMouseOverEvent);
			removeEventListener(MouseEvent.MOUSE_OUT,headerLabelMouseOutEvent);
			removeEventListener(MouseEvent.MOUSE_OUT,headerLabelMouseClick);
		}
		
		public function get linked():Boolean{
			return _linked;
		}
		
		private function headerLabelMouseOverEvent(e:MouseEvent):void{
			underline = false;
		}
		
		private function headerLabelMouseOutEvent(e:MouseEvent):void{
			underline = true;
		}
		
		private function headerLabelMouseClick(e:MouseEvent):void{
			if (linkClick != null) 
				linkClick(data?data: text);
			else{
				var event:TextEvent = new TextEvent(LinkLabel.LINK_CLICK,false,false,text);
				dispatchEvent(event);	
			}
			link.dispatch(this);
		}

		public function set text(value:String):void{
			_text = value;
			textField.htmlText = "<a href='event:'>"+value+"</a>";
			if(_underline)
				drawUnderline();
		}

		public function get text():String{
			return _text;
		}

		public function get underline():Boolean {
			return _underline;
		}

		public function set underline(value:Boolean):void {
			if(_underline != value){
				_underline = value;
				if(value)
					drawUnderline();
				else
					graphics.clear();
			}
		}

		private function drawUnderline():void {
			graphics.clear();
			graphics.lineStyle(1, textField.color);
			var CONST:int = (textField.width - textField.textWidth) * 0.5;
			graphics.moveTo(CONST, textField.textHeight + 2);

			if(_dasched){
				const dashSize:int = 1;
				var maxX:int = CONST + textField.textWidth;
				var y:Number = textField.textHeight + 2;
				var x:Number = CONST;
				while(x < maxX){
					x += dashSize;
					graphics.lineTo(x, y);
					x += dashSize + 1;
					graphics.moveTo(x, y);
				}
			} else
				graphics.lineTo(CONST + textField.textWidth, textField.textHeight + 2);
		}


		public function get dasched():Boolean {
			return _dasched;
		}

		public function set dasched(value:Boolean):void {
			_dasched = value;
			if(_underline)
				drawUnderline();
		}
	}
}