package tree.view.gui {
	import com.somewater.storage.I18n;
	import com.somewater.text.TextInputPrompted;

	import flash.display.DisplayObject;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;

	import tree.common.Config;
	import tree.common.IClear;

	public class SearchField extends Sprite implements IClear{

		private var background:DisplayObject;
		private var promptedTF:TextInputPrompted;

		public function SearchField() {
			background = Config.loader.createMc('assets.SearchFieldBackground');
			addChild(background);

			promptedTF = new TextInputPrompted(null, 0x8C9966, 13);
			promptedTF.prompt = I18n.t('SEARCH_PROMPT');
			promptedTF.x = 10;
			promptedTF.y = 6;
			promptedTF.autoSize = TextFieldAutoSize.NONE;
			promptedTF.width = 165;
			addChild(promptedTF);

			promptedTF.addEventListener(TextEvent.TEXT_INPUT, onTextChanged);
		}

		private function onTextChanged(event:TextEvent):void {
			dispatchEvent(new Event(Event.CHANGE))
		}

		public function clear():void {
			promptedTF.removeEventListener(TextEvent.TEXT_INPUT, onTextChanged);
		}

		public function get search():String{
			return promptedTF.text;
		}
	}
}
