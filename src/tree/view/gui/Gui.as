package tree.view.gui {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;

	import tree.common.Bus;
	import tree.common.Config;
	import tree.view.gui.notes.PersonNotesPage;
	import tree.view.gui.profile.PersonProfilePage;

	public class Gui extends Sprite{

		public static var PAGES_CLASSES_BY_NAME:Object = {
															PersonNotesPage: PersonNotesPage
															,
															PersonProfilePage: PersonProfilePage
														};

		private var background:Sprite;
		private var foreground:Sprite;
		private var page:PageBase;
		private var pageHolder:Sprite;
		public var switcher:ProfileSwitcher;
		private var pageWidth:int;
		private var pageHeight:int;

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
		}

		public function setSize(w:int, h:int):void {
			background.height = h;
			foreground.height = h;
			pageWidth = w;
			pageHeight = h - pageHolder.y;
			if(page)
				page.setSize(pageWidth, pageHeight);
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
				page.setSize(pageWidth, pageHeight);
				pageHolder.addChild(page);
			}
		}

		public function utilize():void {
			if(page){
				page.clear();
				pageHolder.removeChild(page);
				page = null;
			}
		}
	}
}
