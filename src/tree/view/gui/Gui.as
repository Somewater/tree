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

		private var background:Sprite;
		private var foreground:Sprite;
		private var page:PageBase;
		private var pageHolder:Sprite;
		private var switcher:ProfileSwitcher;

		public function Gui() {
			background = Config.loader.createMc('assets.GuiBack');
			background.mouseEnabled = background.mouseChildren = false;
			addChild(background);

			switcher = new ProfileSwitcher();
			switcher.x = (Config.GUI_WIDTH - switcher.width) * 0.5;
			switcher.y = 15;
			addChild(switcher);

			pageHolder = new Sprite()
			pageHolder.y = 60;
			addChild(pageHolder);

			foreground = Config.loader.createMc('assets.GuiForeground');
			foreground.mouseEnabled = foreground.mouseChildren = false;
			addChild(foreground);

			setPage('PersonNotesPage')
		}

		public function setSize(w:int, h:int):void {
			background.height = h;
			foreground.height = h;
			if(page)
				page.setSize(w, h - pageHolder.y);
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
