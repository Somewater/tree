package tree.command {
	import tree.model.Join;

	public class RemovePerson extends Command{

		private var join:Join;

		public function RemovePerson(join:Join) {
			this.join = join;
		}

		override public function execute():void {

		}
	}
}
