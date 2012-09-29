package tree.view.gui.panel {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import flash.display.DisplayObject;

	import flash.events.MouseEvent;

	import flash.geom.Point;

	import tree.Tree;

	import tree.command.Actor;
	import tree.common.Config;
	import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.AppSignal;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.Tweener;
	import tree.view.gui.Button;

	public class PanelController extends Actor{

		private var panel:Panel;

		public function PanelController(panel:Panel) {
			this.panel = panel;

			bus.addNamed(ModelSignal.TREE_NEED_CONSTRUCT, onTreeConstructionStarted);
			Config.stage.addEventListener(MouseEvent.CLICK, onMouseDown);
			panel.ownerNameClick.add(onOwnerNameClicked);
			panel.treeSelectorPopup.linkClick.add(onNewOwnerClicked);
			panel.centreRotateButton.left.click.add(onCentre);
		}

		private function onNewOwnerClicked(person:Person):void {
			hideTreeOwnerSelectorPopup();
			bus.dispatch(AppSignal.RELOAD_TREE, person.uid);
		}

		private function onMouseDown(event:MouseEvent):void {
			var target:DisplayObject = event.target as DisplayObject;
			if(Tree.instance.mouseOnCanvas())
				hideTreeOwnerSelectorPopup();
		}

		private function onTreeConstructionStarted(tree:TreeModel):void {
			panel.setOwnerName(model.owner.name);
		}

		private function onOwnerNameClicked():void {
			//if(model.constructionInProcess) return;
			if(panel.treeSelectorPopup.visible){
				 hideTreeOwnerSelectorPopup();
			}else{
				var data:Array = [];
				var owner:Person = model.owner;
				for each(var p:Person in model.trees.iteratorForAllPersons())
					if(p != owner)
						data.push(p);
				data.sort(function(p1:Person, p2:Person):int{return p1.name < p2.name ? -1 : 1});
				panel.treeSelectorPopup.refreshData(data);
				panel.treeSelectorPopup.visible = true;
				Tweener.to(panel.treeSelectorPopup, 0.3, {scaleX: 1, scaleY: 1, alpha: 1});
				panel.treeOwnerMark.rotation = 0;
			}
		}

		private function hideTreeOwnerSelectorPopup():void{
			Tweener.to(panel.treeSelectorPopup, 0.3, {scaleX: 0.1, scaleY: 0.1, alpha: 0},
					{onComplete: function(g:GTween = null):void{panel.treeSelectorPopup.visible = false;}})
			panel.treeOwnerMark.rotation = 180;
		}

		private function onCentre(b:Button):void{
			bus.dispatch(ViewSignal.NEED_CENTRE_CANVAS);
		}
	}
}
