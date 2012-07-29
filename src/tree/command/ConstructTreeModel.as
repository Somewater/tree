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

			model.clear();

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
					var personModel:Person = treeModel.persons.get(String(person.@uid));
					if(personModel == null)
					{
						personModel = treeModel.persons.allocate(treeModel.nodes);
						personModel.tree = treeModel;
						personModel.uid = int(String(person.@uid))
						personModel.photo = String(person.fields.field.(@name == "photo_small"));
						treeModel.persons.add(personModel)
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
					personModel = treeModel.persons.get(String(person.@uid));

					for each(var group:XML in person.relatives.*)
					{
						var type:JoinType = Join.serverToType(String(group.@type));
						for each(var node:XML in group.*)
						{
							join = personModel.get(node.@uid)
							if(join == null)
							{
								var associate:Person = treeModel.persons.get(node.@uid);
								if(!associate)
									continue;

								join = new Join(treeModel.persons);
								join.from = personModel;
								join.uid = associate.uid;
								join.type = type;

								// одновременно строим другую связь
								var join2:Join = new Join(treeModel.persons);
								join2.from = associate;
								join2.uid = personModel.uid;
								join2.type = Join.toAlter(type, personModel.male);

								// проверяем, не пропагандируем ли мы многоженство и многомужество  (todo: пофиксить гомосексуализм)
								if(join.type.superType == JoinType.SUPER_TYPE_MARRY){
									if(personModel.marry || associate.marry){
										join.type = Join.toEx(join.type);
										join2.type = Join.toEx(join2.type);
									}
									// в любом случае снова выставляем флаг кэша в false, чтобы не создать женатых, которые урвенеы, что не женаты ни на ком
									personModel.dirtyMattyCache();
									associate.dirtyMattyCache();
								}

								personModel.add(join);
								associate.add(join2);

								if(join.type == null || join2.type == null)
									throw new Error('Undefined join type');

								if(join.associate == null || join.from == null)
									throw new Error('Incomplete join ' + join)

								if(join2.associate == null || join2.from == null)
									throw new Error('Incomplete join ' + join)

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
