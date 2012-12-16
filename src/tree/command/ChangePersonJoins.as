package tree.command {
import tree.manager.Logic;
import tree.model.Join;
	import tree.model.Person;

	public class ChangePersonJoins extends Command{

		private var person:Person;

		public function ChangePersonJoins(person:Person) {
			this.person = person;
		}

		override public function execute():void {
			var selectedJoins:Array = [];
			var dict:int = int.MAX_VALUE;
			var join:Join;

			// выбираем джоин, ссылающуюся на ноду, наиболее близкую к центру
			for each(var j:Join in person.joins){
			    var _dist:int = j.associate.node.dist;
				if(_dist < dict) {
					selectedJoins = [j];
					dict = _dist;
				} else if(_dist == dict){
					selectedJoins.push(j);
				}
			}

			if(selectedJoins.length == 0)
				throw new Error('Person ' + person + ' can\'t has any joins');
			else{
				if(selectedJoins.length > 1)
					selectedJoins.sort(function(a:Join, b:Join):int{ return b.type.priority - a.type.priority; })
				join = selectedJoins[0];
			}

			Logic.calculateNode(person.node, join.associate.node, join.flatten, !join.breed);// инвертируем breed т.к. нам требуется джоин к node а не от нее
		}
	}
}
