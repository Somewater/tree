package tree.view.gui {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;

	import tree.common.Bus;
	import tree.common.Config;

	public class Gui extends Sprite{

		public static var PAGES_CLASSES_BY_NAME:Object = {
															PersonNotesPage: PersonNotesPage
														};

		private var background:DisplayObject
		private var page:PageBase;
		private var pageHolder:Sprite;

		public function Gui() {
			background = Config.loader.createMc('assets.GuiBack');
			addChild(background);

			pageHolder = new Sprite()
			addChild(pageHolder);

			setPage('PersonNotesPage')
		}

		public function setSize(w:int, h:int):void {
			background.height = h;
			if(page)
				page.setSize(w, h);
		}

		public function setPage(name:String):void{
			if(!page || page.pageName != name){
				if(page){
					page.clear();
					pageHolder.removeChild(page);
					page = null;
				}

				var cl:Class = PAGES_CLASSES_BY_NAME[name];
				page = new cl();
				pageHolder.addChild(page);
			}
		}
	}
}
