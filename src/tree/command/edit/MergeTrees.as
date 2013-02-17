package tree.command.edit {
import flash.display.JointStyle;

import tree.command.AddPerson;
import tree.command.Command;
import tree.command.RecalculateNodes;
import tree.command.view.ContinueTreeDraw;
import tree.command.view.HideNode;
import tree.command.view.RecalculateNodeRollUnroll;
import tree.common.Config;
import tree.model.Join;
import tree.model.JoinType;
import tree.model.Person;
import tree.model.TreeModel;
import tree.model.process.SortedPersonsProcessor;
import tree.signal.ModelSignal;
import tree.signal.ViewSignal;

/**
 * "Взрастить" дерево, содержащее ноду person на дереве, принадлежащем ноду "from"
 */
public class MergeTrees extends Command{

	private var person:Person;
	private var from:Person;
	private var joinFrom:Join;

	private var joinsQueue:Array;

	public function MergeTrees(person:Person, from:Person, joinFrom:Join) {
		this.person = person;
		this.from = from;
		this.joinFrom = joinFrom;// от from к person
	}

	override public function execute():void {
		model.treeViewConstructed = false;
		detain();

		joinsQueue = [];
		for each(var p:Person in person.tree.persons.iterator){
			var j:Join;
			for each(var j2:Join in model.joinsQueue)
				if(j2.associate.uid == p.uid){
					j = j2;
					break;
				}
			if(!j) throw new Error("Cant`t find join by assoc uid=" + p.uid);
			joinsQueue.push(j);
		}


		defer(hideTree);
	}


	private function defer(func:Function):void{
		Config.ticker.callLater(func);
	}

	/**
	 * Анимированно скрыть дерево, подлежащее удалению
	 */
	private function hideTree():void{
		if(model.joinsForDraw.length || model.joinsForRemove.length){
			defer(hideTree);
			return;
		}

		for each(var j:Join in joinsQueue)
			model.joinsForRemove.push(j);

		bus.addNamed(ViewSignal.JOIN_QUEUE_COMPLETED, mergeModel);
		new ContinueTreeDraw().execute();
	}

	/**
	 * Смерджить всё в модели
	 */
	private function mergeModel():void{
		bus.removeNamed(ViewSignal.JOIN_QUEUE_COMPLETED, mergeModel);

		var p:Person;
		var j:Join;
		for each(j in joinsQueue)
			RemovePerson.removeFromModel(j.associate);

		new RemoveTree(person.tree).execute();
		for each(j in joinsQueue)
			model.joinsQueue.splice(model.joinsQueue.indexOf(j), 1);

		var rootTree:TreeModel = from.tree;

		for each(j in joinsQueue.slice()){
			var j2:Join = j;
			if(j2.associate == person){
				j2 = this.joinFrom;
				joinsQueue[joinsQueue.indexOf(j)] = j2;
			}else if(j2.type == JoinType.FIRST_JOIN){
				j2 = j.associate.joins[0];// выбрать произвольную
				j2 = j2.associate.relation(j.associate)// todo работаетм с alter (которая от j.assoc)
				joinsQueue[joinsQueue.indexOf(j)] = j2;
			}

			j2.associate.tree = rootTree;
			AddPerson.addToModel(j2)
		}

		new RecalculateNodes().execute();

		bus.addNamed(ModelSignal.NODES_RECALCULATED, showNewBranch);
	}

	/**
	 * "Вырастить" ветку из новых нод
	 */
	private function showNewBranch():void{
		bus.removeNamed(ModelSignal.NODES_RECALCULATED, showNewBranch);

		for each(var j:Join in joinsQueue)
			model.joinsForDraw.push(j);

		bus.addNamed(ViewSignal.JOIN_QUEUE_COMPLETED, finish);
		new ContinueTreeDraw().execute();
	}

	/**
	 * Завершающие действия
	 */
	private function finish():void{
		bus.removeNamed(ViewSignal.JOIN_QUEUE_COMPLETED, finish);

		model.treeViewConstructed = true;
		release();

		new RecalculateNodeRollUnroll().execute();
	}
}
}
