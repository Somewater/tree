package tree.command {
	import tree.model.Join;
	import tree.model.Join;
	import tree.model.Person;
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

			// прогон для построения Person
			for each(tree in xml.*)
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
						personModel = model.persons.allocate();
						personModel.uid = int(String(person.@uid))
						model.persons.add(personModel)
					}
					personModel.male = String(person.@sex) == '1';
					personModel.name = String(person.@name);
				}
			}

			// прогон для построения двусторонних связей между Person
			for each(tree in xml.*)
			{
				treeModel = model.trees.get(String(tree.@uid));

				for each(person in tree.*)
				{
					personModel = model.persons.get(String(person.@uid));

					for each(var group:XML in person.relatives.*)
					{
						var type:int = Join.serverToType(int(String(group.@type)));
						for each(var node:XML in group.*)
						{
							join = personModel.get(node.@uid)
							if(join == null)
							{
								join = new Join(model.persons);
								join.owner = personModel;
								join.uid = node.@uid;
								join.type = type;
								personModel.add(join);

								var associate:Person = join.associate;

								// одновременно строим другую связь
								join = new Join(model.persons);
								join.owner = associate;
								join.uid = personModel.uid;
								join.type = Join.toAlter(type, associate.male);
								associate.add(join);
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
