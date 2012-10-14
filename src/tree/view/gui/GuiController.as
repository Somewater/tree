package tree.view.gui {
	import com.gskinner.motion.GTween;

	import tree.command.Actor;
	import tree.common.Config;
	import tree.model.Join;
	import tree.model.Person;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.Tweener;
	import tree.view.gui.notes.PersonNotesPage;
	import tree.view.gui.profile.PersonProfilePage;

	public class GuiController extends Actor{

		private var gui:Gui;

		public function GuiController(gui:Gui) {
			this.gui = gui;
			bus.addNamed(ViewSignal.CANVAS_READY_FOR_START, onStart);
			gui.switcher.change.add(onSwitcherChanged);
			gui.fold.click.add(onGuiOpenChanged)
		}


		public function addPerson():void {
			// TODO TODO TODO
			var p:Person = model.trees.first.persons.allocate(model.trees.first.nodes);
			p.uid = (int.MAX_VALUE * Math.random()) | 536870912;
			p.firstName = 'Ребенок ' + int(Math.random() * 10);
			var from:Person = model.trees.first.owner;

			var j:Join = new Join(model.trees.first.persons);
			j.from = from;
			j.associate = p;
			j.type = p.male ? Join.SON : Join.DAUGHTER;

			bus.dispatch(ModelSignal.ADD_PERSON, j);
		}

		public function removePerson(uid:int):void{

		}

		private function onStart():void{
			gui.setPage(PersonProfilePage.NAME);
		}

		private function onSwitcherChanged(switcher:ProfileSwitcher):void{
			if(model.editing.editEnabled){
				if(switcher.list){
					// показываем лист выбора только в случае, если редактируется персона, имеющая прикрепление
					if(model.editing.joinType)
						gui.setPage(PersonNotesPage.NAME_MODE_SELECT, model.editing.edited, model.editing.joinType, model.editing.from)
					else
						gui.setPage(PersonNotesPage.NAME);
				}else
					gui.setPage(PersonProfilePage.NAME, model.editing.edited, model.editing.joinType, model.editing.from)
			}else{
				if(switcher.list)
					gui.setPage(PersonNotesPage.NAME);
				else
					gui.setPage(PersonProfilePage.NAME);
			}
		}

		private var guiAnimInProcess:Boolean = false;
		private function onGuiOpenChanged(f:Fold):void{
			if(guiAnimInProcess) return;
			guiAnimInProcess = true;
			// сначала анимация, затем фактическое переставление свойств
			var x:int;
			var open:Boolean = !f.open;
			if(open){
				gui.contentVisibility = true;
				x = Config.WIDTH - Config.GUI_WIDTH;
			}else{
				x = Config.WIDTH - Fold.BACKGROUND_WIDTH;
			}

			Tweener.to(gui, 0.2, {'x': x}, {onComplete: onGuiOpenAnimComplete})
		}

		private function onGuiOpenAnimComplete(g:GTween = null):void{
			model.guiOpen = !gui.fold.open;
			guiAnimInProcess = false;
		}
	}
}
