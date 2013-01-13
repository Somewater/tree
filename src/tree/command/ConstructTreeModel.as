package tree.command {
	import flash.system.System;
	import flash.utils.getTimer;

	import tree.common.Config;

	import tree.model.Join;
	import tree.model.Join;
	import tree.model.JoinCollectionBase;
	import tree.model.JoinType;
	import tree.model.Model;
	import tree.model.ModelBase;
import tree.model.Node;
	import tree.model.Person;
	import tree.model.PersonsCollection;
	import tree.model.TreeModel;
import tree.model.Urls;
import tree.signal.ModelSignal;

	/**
	 * Создание структуры дерева (не считая параметров позиционирования, т.е.Nodes)
	 */
	public class ConstructTreeModel extends ResponseHandlerBase{

		private var xml:XML;
		private var xmlTrees:Array = [];
		private var currentXmlTree:XML;
		private var currentTreeModel:TreeModel;
		private var xmlPersons:Array = [];
		private var treePosition:int;
		private var personPosition:int;
		private var personsNumber:int = 0;
		private var relativePersonsCounter:int = 0;// для отображения прогресса по шагу 3

		private const STEP_FRAME_PADDING:int = 2;

		public function ConstructTreeModel() {
		}

		override public function execute():void {
			this.xml = response.toXml();
			var tree:XML;
			var person:XML;
			var treeModel:TreeModel;
			var join:Join;

			model.clear();
			ModelBase.radioSilence = true;

			detain();
			Config.ticker.callLater(createTreeModelsPrepareXmlTrees, STEP_FRAME_PADDING);
			progress(0, 1);
		}

		/**
		 * Шаг 1: создать деревья, подготовить xml-деревья для итерации
		 */
		private function createTreeModelsPrepareXmlTrees():void{
			var tree:XML;
			var treeModel:TreeModel;

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
					treeModel.name = tree.@name;
					model.trees.add(treeModel);
				}

				xmlTrees.push(tree);
			}

			if(xml.setup){
				model.options.read(xml.setup);
			}
			model.descending = model.options.defaultOrderDesc

			treePosition = 0;
			Config.ticker.callLater(createPersonsinXmlTree, STEP_FRAME_PADDING);
			progress(1, 1)
		}

		/**
		 * Шаг 2: создать персон в одном из подготовленных xml-деревьев
		 */
		private function createPersonsinXmlTree():void{
			var tree:XML;
			var person:XML;
			var treeModel:TreeModel;
			var nodeModel:Node;
			var personModel:Person

			var counter:int = 1;
			var time:Number = getTimer();

			for(; treePosition < xmlTrees.length; treePosition++)
			{
				tree = xmlTrees[treePosition]
				treeModel = model.trees.get(String(tree.@uid));

				if(treeModel != currentTreeModel){
					// перестановка дерева
					currentTreeModel = treeModel;
					currentXmlTree = tree;
					xmlPersons = [];
					for each(person in tree.*)
						xmlPersons.push(person);
					personPosition = 0;
				}

				for(; personPosition < xmlPersons.length; personPosition++, counter++)
				{
					// может хватит?
					if(counter % 10 == 0 && (getTimer() - time) > 50){
						Config.ticker.callLater(createPersonsinXmlTree);
						progress(2, ((personPosition + 1) / xmlPersons.length) * ((treePosition + 1) / xmlTrees.length))
						return;
					}

					person =  xmlPersons[personPosition]
					personModel = treeModel.persons.get(String(person.@uid));
					if(personModel == null)
					{
						personModel = treeModel.persons.allocate(treeModel);
						personModel.uid = int(String(person.@uid))
						treeModel.persons.add(personModel)
					}
					personModel.photoSmall = String(person.fields.field.(@name == "photo_small"));
					personModel.photoBig = String(person.fields.field.(@name == "photo_big"));
					personModel.male = String(person.fields.field.(@name == "sex")) == '1';
					personModel.lastName = String(person.fields.field.(@name == "last_name"))
					personModel.firstName = String(person.fields.field.(@name == "first_name"));
					personModel.middleName = String(person.fields.field.(@name == "middle_name"));
					personModel.maidenName = String(person.fields.field.(@name == "maiden_name"));
					personModel.birthday = databaseFormatToDate(person.fields.field.(@name == "birthday"));
					personModel.deathday = databaseFormatToDate(person.fields.field.(@name == "deathday"));
					personModel.died = String(person.fields.field.(@name == "died")) == '1';
					personModel.post = String(person.fields.field.(@name == "rel_label"));
					personModel.profileUrl = String(person.fields.field.(@name == "url"));
					personModel.homePlace = String(person.fields.field.(@name == "home_place"));
					personModel.birthPlace = String(person.fields.field.(@name == "birth_place"));
					personModel.open = String(person.@open) == '1';
					personModel.editable = String(person.@edit_access) == '1';
					if(!personModel.open){
						personModel.name = String(person.@name);
					}

					personModel.urls = new Urls(person);
					personModel.fields.read(person.fields);

					nodeModel = treeModel.nodes.allocate(personModel) ;
					if(person.fields.field.(@name == "hand_x").length > 0)
						nodeModel.handX = parseInt(person.fields.field.(@name == "hand_x"));
					if(person.fields.field.(@name == "hand_y").length > 0)
						nodeModel.handY = parseInt(person.fields.field.(@name == "hand_y"));
					treeModel.nodes.add(nodeModel);

					personsNumber++;
				}
			}

			treePosition = 0;
			currentTreeModel = null;
			currentXmlTree = null;
			xmlPersons = null;
			Config.ticker.callLater(createRelationsInXmlTree, STEP_FRAME_PADDING);
		}

		/**
		 * Шаг 3: создать связи в персонах xml-дерева
		 */
		private function createRelationsInXmlTree():void{
			var tree:XML;
			var person:XML;
			var treeModel:TreeModel;
			var join:Join;
			var nodeModel:Node;
			var personModel:Person

			var counter:int = 1;
			var time:Number = getTimer();

			for(; treePosition < xmlTrees.length; treePosition++)
			{
				tree = xmlTrees[treePosition]
				treeModel = model.trees.get(String(tree.@uid));

				if(treeModel != currentTreeModel){
					// перестановка дерева
					currentTreeModel = treeModel;
					currentXmlTree = tree;
					xmlPersons = [];
					for each(person in tree.*)
						xmlPersons.push(person);
					personPosition = 0;
				}

				for(; personPosition < xmlPersons.length; personPosition++, counter++)
				{
					// может хватит?
					if(counter % 10 == 0 && (getTimer() - time) > 50){
						Config.ticker.callLater(createRelationsInXmlTree);
						progress(3, (relativePersonsCounter / personsNumber))
						return;
					}

					person =  xmlPersons[personPosition]
					personModel = treeModel.persons.get(String(person.@uid));

					for each(var group:XML in person.relatives.*)
					{
						var type:JoinType = Join.serverToType(String(group.@type));
						if(type == null) throw new Error("Undefined join identifier '" + group + "'")
						for each(var node:XML in group.*)
						{
							join = personModel.get(node.@uid)
							if(join == null)
							{
								var associate:Person = treeModel.persons.get(node.@uid);
								if(!associate)
									continue;

								// в ручную выставляем пол на основе конфига
								if(!associate.open)associate.male = type.manAssoc;
								if(!personModel.open && (type.superType == JoinType.SUPER_TYPE_MARRY
														|| type.superType == JoinType.SUPER_TYPE_EX_MARRY))
									personModel.male = !type.manAssoc;

								join = createJoin(type, personModel, associate);

								//log(personModel + ' ~> ' + associate + ';; ' + join + '; ' + join2);
							}

						}
					}

					relativePersonsCounter++;
				}
			}

			Config.ticker.callLater(clearReleaseAndDispatchComplete);
		}

		/**
		 * Шаг 4: удалить все ранее созданные вспомогательные структуры и задиспатчить конец обработки
		 */
		private function clearReleaseAndDispatchComplete():void{
			clear();
			release();
			Config.ticker.callLater(bus.dispatch, 1, [ModelSignal.NODES_NEED_CALCULATE])
			progress(4, 1);
		}

		public function clear():void{
			try{
				var xml:XML
				for each(xml in xmlTrees)
					System.disposeXML(xml);
				for each(xml in xmlPersons)
					System.disposeXML(xml);
				System.disposeXML(this.xml);
			}catch(err:Error){
				error(err);
			}
			xmlTrees = null;
			currentXmlTree = null;
			currentTreeModel = null;
			xmlPersons = null;
		}

		private function databaseFormatToDate(string:String):Date{
			var data:Array = string.split('-');
			if(parseInt(data[0]) == 0)
				return null;
			return new Date(parseInt(data[0]), parseInt(data[1]) - 1, parseInt(data[2]));
		}

		private function progress(step:int, value:Number):void{
			value = (step/5) + 0.2 * value

			bus.initialLoadingProgress.dispatch(2, value);
		}

		public static function createJoin(type:JoinType, _from:JoinCollectionBase, _to:JoinCollectionBase):Join{
			var from:Person = _from is Person ? _from as Person : (_from as Node).person;
			var to:Person = _to is Person ? _to as Person : (_to as Node).person;
			var tree:TreeModel = from.tree ? from.tree : to.tree;

			var join:Join = new Join(tree.persons);
			join.from = from;
			join.associate = to;
			join.type = type;

			// одновременно строим другую связь
			var join2:Join = new Join(tree.persons);
			join2.from = to;
			join2.associate = from;
			join2.type = Join.toAlter(type, from.male);

			// проверяем, не пропагандируем ли мы многоженство и многомужество  (todo: пофиксить гомосексуализм)
			if(join.type.superType == JoinType.SUPER_TYPE_MARRY){
				if(from.marry || to.marry){
					join.type = Join.toEx(join.type);
					join2.type = Join.toEx(join2.type);
				}
				// в любом случае снова выставляем флаг кэша в false, чтобы не создать женатых, которые урвенеы, что не женаты ни на ком
				from.dirtyMattyCache();
				to.dirtyMattyCache();
			}

			from.add(join);
			to.add(join2);

			if(join.type == null || join2.type == null)
				throw new Error('Undefined join type. Type ' + type + ' from ' + from + ' to ' + to);

			if(join.associate == null || join.from == null)
				throw new Error('Incomplete join ' + join)

			if(join2.associate == null || join2.from == null)
				throw new Error('Incomplete join ' + join)

			return join;
		}
	}
}
