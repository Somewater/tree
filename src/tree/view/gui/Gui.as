package tree.view.gui {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.osflash.signals.ISignal;

	import tree.common.Bus;
	import tree.common.Config;
	import tree.view.gui.notes.PersonNotesController;
	import tree.view.gui.notes.PersonNotesPage;
	import tree.view.gui.notes.SelectNoteController;
import tree.view.gui.profile.EditPersonProfilePage;
import tree.view.gui.profile.EditProfileController;
import tree.view.gui.profile.PersonProfilePage;
	import tree.view.gui.profile.ProfileController;

	public class Gui extends Sprite{

		public static var PAGES_CLASSES_BY_NAME:Object =
		{
			PersonNotesPage: {page: PersonNotesPage, controller: PersonNotesController, cachedPage: true}
			,
			PersonNotesPage_modeEditSelect: {page: PersonNotesPage, controller: SelectNoteController}
			,
			PersonProfilePage: {page: PersonProfilePage, controller: ProfileController}
			,
			EditPersonProfilePage: {page: EditPersonProfilePage, controller: EditProfileController}
		};

		private var background:Sprite;
		private var foreground:Sprite;

		public var page:PageBase;
		public var controller:GuiControllerBase;
		public var fold:Fold;

		private var pageHolder:Sprite;
		public var switcher:ProfileSwitcher;
		private var pageWidth:int;
		private var pageHeight:int;

		private var pageName:String;

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

			fold = new Fold();
			addChild(fold);

			cacheAsBitmap = true;
		}

		public function setSize(w:int, h:int):void {
			background.height = h;
			foreground.height = h;
			pageWidth = w;
			pageHeight = h - pageHolder.y;
			if(page)
				page.setSize(pageWidth, pageHeight);
			fold.y = h * 0.5;
			fold.setSize(w, h);
		}

		public function setPage(name:String, ...args):void{
			if(page){
				if(controller)
					controller.stop();
				if(!(pageName && PAGES_CLASSES_BY_NAME[pageName] && PAGES_CLASSES_BY_NAME[pageName]['cachedPage']))
					page.clear();
				pageHolder.removeChild(page);
				controller = null;
				page = null;
			}

			var data:Object = PAGES_CLASSES_BY_NAME[name];
			if(data['cachedPage'] is DisplayObject){
				page = data['cachedPage'];
			}else{
				var cl:Class = data['page'];
				var controllerCl:Class = data['controller'];
				page = new cl();
				if(data['cachedPage'])
					data['cachedPage'] = page;
			}
			page.setSize(pageWidth, pageHeight);
			pageHolder.addChild(page);

			if(controllerCl){
				controller = new controllerCl(page);
				controller.gui = this;
				controller.start.apply(null, args);
			}

			pageName = name;
		}

		public function utilize():void {
			if(page){
				page.clear();
				pageHolder.removeChild(page);
				page = null;
			}
		}

		public function set contentVisibility(visible:Boolean):void{
			pageHolder.visible = visible;
			switcher.visible = visible;
			background.visible = visible;
			foreground.visible = visible;
		}
	}
}
