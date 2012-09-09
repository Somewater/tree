package tree.view.gui {
	import tree.command.Actor;
	import tree.model.Join;
	import tree.model.Person;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;

	public class GuiController extends Actor{

		private var gui:Gui;

		public function GuiController(gui:Gui) {
			this.gui = gui;
			bus.addNamed(ViewSignal.CANVAS_READY_FOR_START, onStart);
		}


		public function addPerson():void {
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
			gui.setPage('PersonNotesPage');
		}
	}
}
