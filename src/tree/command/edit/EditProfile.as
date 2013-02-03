package tree.command.edit {
	import tree.command.Command;
	import tree.command.ConstructTreeModel;
	import tree.command.RecalculateNodes;
	import tree.common.Config;
import tree.manager.Logic;
import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinCollectionBase;
	import tree.model.JoinType;
	import tree.model.Node;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;
	import tree.signal.RequestSignal;
import tree.signal.ResponseSignal;
import tree.signal.ViewSignal;

	public class EditProfile extends Command{

		private var person:Person;
		private var joinType:JoinType;
		private var join:Join;
		private var from:Person;

		public function EditProfile(person:Person, joinType:JoinType = null, from:Person = null) {
			this.person = person;
			this.joinType = joinType;
			this.from = from;
		}

		override public function execute():void {
			detain();

			if(joinType && joinType.superType == JoinType.SUPER_TYPE_MARRY && (person.marry || from.marry))
				joinType = Join.joinBy(JoinType.SUPER_TYPE_EX_MARRY, person.male)


			var requestType:String;
			if(person.isNew)
				requestType = RequestSignal.ADD_USER;
			else
				requestType = joinType != null && from != null ? RequestSignal.ADD_RELATION : RequestSignal.EDIT_USER;

			var request:RequestSignal = new RequestSignal(requestType);
			request.person = person;
			request.joinFrom = from;
			request.joinType = joinType;
			request.onSucces.add(onResponseSuccess)
			request.onComplete.add(onComplete)

			call(request);
		}

		private function onResponseSuccess(response:ResponseSignal):void{
			var tree:TreeModel = person.tree || (from ? from.tree : null);
			var newTree:Boolean = false;
			var newPerson:Boolean = false;
			if(!tree){
				newTree = true;
				tree = model.trees.allocate();
			}

			if(!person.node){
				newPerson = true;
				// todo: присвоить персоне новый id
				try{
					person.uid = response.toXml().data.user_id.toString();
					person.assignDefaultData();
				}catch (err:Error){
					error(err);
				}
				if(newTree){
					tree.uid = person.uid;
					model.trees.add(tree);
					person.tree = tree;
				}
				tree.nodes.add(tree.nodes.allocate(person));
			}

			if(joinType){
				join = new Join(tree.persons);
				join.type = joinType;
				join.associate = person;
				join.from = from;
				var p:Person;

				// если добаляется ребенок, актоматически делать ребенком 2-х родитеелй
				if(joinType.superType == JoinType.SUPER_TYPE_BREED){
					var bros:Array = [];
					if(from.marry){
						createJoin(joinType, from.marry, person);
						bros = from.legitimateBreed;
					}else
						bros = from.breeds;
					// сделать детей этих родителей его братьями и сестрами
					for each(p in bros)
						createJoin(Join.joinBy(JoinType.SUPER_TYPE_BRO, person.male), p, person);
				}

				// если добавляется родитель, автоматически делать родителем братьев и сестер
				if(joinType.superType == JoinType.SUPER_TYPE_PARENT){
					var commonParent:Person;
					var hasCommonParent:Boolean = true;
				    for each(p in from.bros){
						if(hasCommonParent){
							var parents:Array = p.parents;
							if(parents.length == 1 && (commonParent == null || parents[0] == commonParent))
								commonParent = parents[0];
							else{
								hasCommonParent = false;
								commonParent = null;
							}
						}
						createJoin(Join.joinBy(JoinType.SUPER_TYPE_PARENT, person.male), p, person)
					}
					// "поженить" на общем родителе детей
					if(commonParent)
						createJoin(Join.joinBy(JoinType.SUPER_TYPE_MARRY, person.male), commonParent, person)
				}

				// если добавляется супруг, детей автоматически делать общими
				if(joinType.superType == JoinType.SUPER_TYPE_MARRY)
				    for each(p in from.breeds)
						createJoin(Join.joinBy(JoinType.SUPER_TYPE_PARENT, person.male), p, person)

				// если добавляется bro, сделать родителей общими (если у bro их нет)
				if(joinType.superType == JoinType.SUPER_TYPE_BRO && person.parents.length == 0)
					for each(p in from.parents)
						createJoin(Join.joinBy(JoinType.SUPER_TYPE_PARENT, p.male), person, p)
			}

			var node:Node = person.node;
			tree.persons.add(person);

			if(joinType){
				var alterJoin:Join = new Join(tree.persons);
				alterJoin.associate = join.from;
				alterJoin.from = join.associate;
				alterJoin.type = Join.toAlter(join.type, join.from.male);

				join.associate.add(alterJoin);
				join.associate.node.add(alterJoin);
				join.from.add(join);
				join.from.node.add(join)
			}

			if(join && newPerson){
				Logic.calculateNode(node, from.node, join.flatten, join.breed);
			}

			person.isNew = false;
			person.editable = true;// можно редактировать, но неизвестна ссылка на расширенное редактирование, загрузку фото и т.д.

			if(!newPerson)
				bus.dispatch(ViewSignal.REDRAW_JOIN_LINES, person);
			else if(newTree)
				bus.dispatch(ModelSignal.TREE_NEED_CONSTRUCT, person.tree);
			else
				bus.dispatch(ModelSignal.SHOW_NODE, join);

			bus.dispatch(ViewSignal.RECALCULATE_ROLL_UNROLL);
		}

		private function createJoin(type:JoinType, _from:Person, _to:Person):Join{
			var j:Join = ConstructTreeModel.createJoin(type, _from, _to);
			_from.node.add(j);
			_to.node.add(_to.relation(_from));
			return j
		}

		private function onComplete(response:ResponseSignal):void{
			release();
			person.fireChange();
		}
	}
}
