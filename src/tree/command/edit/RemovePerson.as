package tree.command.edit {
import com.somewater.storage.I18n;

import tree.command.*;
import tree.common.Config;
import tree.model.Join;
import tree.model.JoinCollectionBase;
import tree.model.Node;
import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.RequestSignal;
import tree.signal.ResponseSignal;
import tree.view.gui.Gui;
import tree.view.gui.profile.PersonProfilePage;
import tree.view.window.AcceptWindow;
import tree.view.window.AcceptWindow;

public class RemovePerson extends Command{

		private var person:Person;
		private var join:Join;

		public function RemovePerson(person:Person) {
			this.person = person;
		}

		override public function execute():void {
			detain();
			var w:AcceptWindow = new AcceptWindow(I18n.t('ATTENTION'), I18n.t('DELETE_PERSON_ACCEPT', {name: person.name}), function():void{
				onAccept();
			});
			w.onComplete.add(release);
		}

		private function onAccept():void{
			detain();
			model.treeViewConstructed = false;

			// todo: отовсюду (nodes, persons) удалить джоины, в nodes отыскать  join, которая ссылается на удаляемую person
			join = null;
			for each(join in model.joinsQueue)
				if(join.associate == person)
					break;

			var request:RequestSignal = new RequestSignal(RequestSignal.DELETE_USER);
			request.person = person;
			request.onComplete.add(onComplete);
			request.onSucces.add(onResponseSuccess);
			call(request);
		}

		private function onResponseSuccess(response:ResponseSignal):void{
			// todo: всем нодам затронутым в удалении джоинов пересчитать джоины (возможно изменится их статус в дереве)
			//RecalculateNodes.calculate(node, join.associate.node, join.flatten, join.breed);

			bus.dispatch(ModelSignal.HIDE_NODE, join);

			if(model.selectedPerson == person)
				model.selectedPerson = model.trees.first.owner;
			if(model.editing.editEnabled && model.editing.edited == person){
				model.editing.editEnabled = false;
				(Config.inject(Gui) as Gui).setPage(PersonProfilePage.NAME);
			}

			detain();
			Config.ticker.callLater(removePersonFromModel, 100);
		}

		private function removePersonFromModel():void{
			release();

			var tree:TreeModel = person.tree;
			var node:Node = person.node;
			tree.nodes.remove(person.node);
			tree.persons.remove(person);
			model.treeViewConstructed = true;

			for each(var n:Node in tree.nodes.iterator){
				if(n.slaves){
					var idx:int = n.slaves.indexOf(node);
					if(idx != -1)
						n.slaves.splice(idx, 1);
				}
			}

			if(tree.persons.length == 0){
				// уничтожить всё дерево
				new RemoveTree(tree).execute();
			}
		}

		private function onComplete(response:ResponseSignal):void{
			release();
			model.treeViewConstructed = true;
		}
	}
}
