package tree.model {
	import tree.common.Bus;
	import tree.model.base.IModel;
	import tree.model.base.ModelCollection;

	public class TreesCollection extends ModelCollection{
		private var bus:Bus;

		private static var numberCounter:int = 0;
		private static var orientationCounter:int = 0;

		public function TreesCollection(bus:Bus) {
			this.bus = bus;
		}

		public function get(id:String):TreeModel
		{
			return this.hash[id];
		}

		public function allocate():TreeModel {
			return new TreeModel(this.bus);
		}

		public function get first():TreeModel {
			return array[0];
		}

		override public function add(model:IModel):void {
			var t:TreeModel = model as TreeModel;
			if(!t)
				throw new Error('TreesCollection should contains only trees');
			t.number = numberCounter++;
			t.left = ((orientationCounter++) % 2) == 0;
			super.add(model);
		}

		public function refreshTreeSizes(person:Person, added:Boolean):void {
			var n:Node = person.node;
			var t:TreeModel = person.tree;
			var changed:Boolean = !t.visible || !added || t.dirty;// т.е. если это первая нода, то изменения в любом случае

			if(added){
				if(Model.instance.hand){
					if(n.handX > t.maxX){
						t.maxX = n.handX;
						changed = true;
					}else if(n.handX < t.minX){
						t.minX = n.handX;
						changed = true;
					}
				}else{
					if(n.x > t.maxX){
						t.maxX = n.x;
						changed = true;
					}else if(n.x < t.minX){
						t.minX = n.x;
						changed = true;
					}
				}
				n.positionChanged.add(onNodePositionChanged);
			}else{
				// придется перебрать всех, чтобы найти границы
				t.maxX = 0; t.minX = 0;
				for each(var _n:Node in t.nodes.iterator){
					if(_n.visible && _n != n){
						if(t.maxX < _n.x)
							t.maxX = _n.x;
						if(t.minX > _n.x)
							t.minX = _n.x;
					}
				}
				n.positionChanged.remove(onNodePositionChanged);
			}

			if(changed){
				t.visible = true;
				t.dirty = false;
				refresTreesShifts();
			}
		}

		public function recalculateTreesBounds():void{
			var hand:Boolean = Model.instance.hand
			for each(var t:TreeModel in array){
				t.maxX = int.MIN_VALUE;
				t.minX = int.MAX_VALUE;
				for each(var n:Node in t.nodes.iterator){
					if(n.visible){
						if(hand){
							if(t.maxX < n.handX)
								t.maxX = n.handX;
							if(t.minX > n.handX)
								t.minX = n.handX;
						}else{
							if(t.maxX < n.x)
								t.maxX = n.x;
							if(t.minX > n.x)
								t.minX = n.x;
						}
					}
				}
			}
		}

		public function refresTreesShifts():void{
			const PADDING:int = 2;// если 0, то на самом деле будет наложение, поэтому никак не меньше 1
			var changed:Boolean = true;
			var t2:TreeModel
			var maxX:int = 0;
			var minX:int = 0;
			var forChange:Array = [];
			for(var i:int = 0;i<array.length;i++){
				t2 = array[i];
				if(!t2.visible)
					continue;
				changed = false;

				if(i != 0){
					if(!t2.left){
						// right (positive) shift
						if(t2.shiftX != maxX + PADDING - t2.minX){
							t2.shiftX = maxX + PADDING - t2.minX
							changed = true;
						}
					}else{
						if(t2.shiftX != minX - PADDING - t2.maxX){
							t2.shiftX = minX - PADDING - t2.maxX
							changed = true;
						}
					}
				}

				if(maxX < t2.maxX + t2.shiftX)
					maxX = t2.maxX + t2.shiftX;
				if(minX > t2.minX + t2.shiftX)
					minX = t2.minX + t2.shiftX;

				if(changed) forChange.push(t2);
			}

			for each(t2 in forChange){
				for each(var p:Person in t2.persons.iterator)
					if(p.node.visible)
						p.node.firePositionChange();
				// TODO: сделать мгновеннуюn пересноановку нод и джоин-лайнов (т.к. данная команда делает анимацию)
			}
		}

		private function onNodePositionChanged(n:Node):void {
			var t:TreeModel = n.person.tree;
			if(Model.instance.hand){
				if(n.handX > t.maxX){
					t.maxX = n.handX;
					t.dirty = true;
				}else if(n.handX < t.minX){
					t.minX = n.handX;
					t.dirty = true;
				}
			}else{
				if(n.x > t.maxX){
					t.maxX = n.x;
					t.dirty = true;
				}else if(n.x < t.minX){
					t.minX = n.x;
					t.dirty = true;
				}
			}
		}

		public function iteratorForAllPersons():Array {
			var persons:Array = [];
			for each(var t:TreeModel in array)
				persons = persons.concat(t.persons.iterator);
			return persons;
		}

		public function get personQuantity():int{
			var l:int = 0;
			for each(var t:TreeModel in array)
				l += t.persons.length;
			return Math.max(1,l);
		}
	}
}
