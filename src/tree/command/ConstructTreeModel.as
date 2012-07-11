package tree.command {
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinType;
	import tree.model.Person;
	import tree.model.PersonsCollection;
	import tree.model.TreeModel;
	import tree.signal.ModelSignal;

	/**
	 * Создание структуры дерева (не считая параметров позиционирования, т.е.Nodes)
	 */
	public class ConstructTreeModel extends ResponseHandlerBase{

		public function ConstructTreeModel() {
		}

		override public function execute():void {
			var xml:XML = response.toXml();
			var tree:XML;
			var person:XML;
			var treeModel:TreeModel;
			var join:Join;
			var persons:PersonsCollection = model.persons;

			// прогон для построения Person
			for each(tree in xml.trees.*)
			{
				treeModel = model.trees.get(String(tree.@uid));

				if(treeModel && treeModel.level != int(String(tree.@level)))
				{
					treeModel.clear();
					treeModel = null;
				}

				if(treeModel == null)
				{
					treeModel = model.trees.allocate();
					treeModel.uid = int(tree.@uid);
					treeModel.level = int(tree.@level);
					model.trees.add(treeModel);
				}

				for each(person in tree.*)
				{
					var personModel:Person = model.persons.get(String(person.@uid));
					if(personModel == null)
					{
						personModel = model.persons.allocate(model.nodes);
						personModel.uid = int(String(person.@uid))
						personModel.photo = String(person.fields.field.(@name == "photo_small"));
						persons.add(personModel)
					}
					personModel.male = String(person.fields.field.(@name == "sex")) == '1';
					personModel.name = String(person.fields.field.(@name == "last_name")) + " " + String(person.fields.field.(@name == "first_name"));
				}
			}

			// прогон для построения двусторонних связей между Person
			for each(tree in xml.trees.*)
			{
				treeModel = model.trees.get(String(tree.@uid));

				for each(person in tree.*)
				{
					personModel = persons.get(String(person.@uid));

					for each(var group:XML in person.relatives.*)
					{
						var type:JoinType = Join.serverToType(String(group.@type));
						for each(var node:XML in group.*)
						{
							join = personModel.get(node.@uid)
							if(join == null)
							{
								var associate:Person = persons.get(node.@uid);

								join = new Join(persons);
								join.from = personModel;
								join.uid = associate.uid;
								join.type = type;
								personModel.add(join);

								// одновременно строим другую связь
								var join2:Join = new Join(persons);
								join2.from = associate;
								join2.uid = personModel.uid;
								join2.type = Join.toAlter(type, personModel.male);
								associate.add(join2);

								if(join.type == null || join2.type == null)
									throw new Error('Undefined join type');

								log(personModel + ' ~> ' + associate + ';; ' + join + '; ' + join2);
							}

						}
					}
				}
			}

			// всё требует пересчёта
			bus.dispatch(ModelSignal.NODES_NEED_CONSTRUCT);
		}
	}
}
