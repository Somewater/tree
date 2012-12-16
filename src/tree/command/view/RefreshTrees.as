package tree.command.view {
import tree.command.Command;
import tree.model.Generation;
import tree.model.ModelBase;
import tree.model.Person;
import tree.signal.ViewSignal;

/**
 * Пересчитать смещения и размеры деревьев, высоты для поколений
 */
public class RefreshTrees extends Command{
	public function RefreshTrees() {
	}

	override public function execute():void {
		ModelBase.radioSilence = true;
		refreshGenerations();
		refreshTrees();

		ModelBase.radioSilence = false;

		bus.dispatch(ViewSignal.REFRESH_GENERATIONS);
		for each(var p:Person in model.trees.iteratorForAllPersons())
			p.node.firePositionChange();
	}

	private function refreshGenerations():void{
		for each(var g:Generation in model.generations.iterator)
			g.recalculate();
	}

	private function refreshTrees():void{
		model.trees.recalculateTreesBounds();
		model.trees.refresTreesShifts();
	}
}
}
