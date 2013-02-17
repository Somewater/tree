package tree.command.edit {
import tree.command.Command;
import tree.command.view.RefreshTrees;
import tree.model.TreeModel;

public class RemoveTree extends Command{

	private var tree:TreeModel;

	public function RemoveTree(tree:TreeModel) {
		this.tree = tree;
	}

	override public function execute():void {
		model.trees.remove(tree);

		model.matrixes.deleteTree(tree);
		new RefreshTrees().execute();
	}
}
}
