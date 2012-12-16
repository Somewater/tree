package tree.view.gui.panel {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
import com.somewater.storage.I18n;

import flash.display.DisplayObject;

	import flash.events.MouseEvent;

	import flash.geom.Point;

	import tree.Tree;

	import tree.command.Actor;
import tree.command.GotoLinkCommand;
import tree.command.PrintTree;
	import tree.command.view.DepthIndexChanged;
	import tree.common.Config;
import tree.model.Model;
import tree.model.Person;
	import tree.model.TreeModel;
	import tree.signal.AppSignal;
	import tree.signal.ModelSignal;
	import tree.signal.ViewSignal;
	import tree.view.Tweener;
	import tree.view.gui.Button;
import tree.view.window.AcceptWindow;
import tree.view.window.TitleTextWindow;
import tree.view.window.TitleTextWindow;

public class PanelController extends Actor{

		private var panel:Panel;

		public function PanelController(panel:Panel) {
			this.panel = panel;

			bus.addNamed(ViewSignal.TREE_SELECTED, onTreeSelected);
			bus.hand.addWithPriority(onHandChanged);
			Config.stage.addEventListener(MouseEvent.CLICK, onMouseDown);
			panel.ownerNameClick.add(onOwnerNameClicked);
			panel.treeSelectorPopup.linkClick.add(onNewOwnerClicked);
			panel.centreRotateButton.left.click.add(onCentre);
			panel.centreRotateButton.right.click.add(onRotateTree);
			panel.depthSelector.indexChanged.add(onDepthIndexChanged);
			panel.savePrintButton.left.click.add(onSaveClicked);
			panel.savePrintButton.right.click.add(onPrintClicked)
			panel.optionsButton.click.add(onOptionsClicked);
			panel.changeHand.click.add(onChangeHandClick);

			panel.saveTreeButton.visible = false;
			panel.changeHand.visible = false;
		}

		private function onNewOwnerClicked(person:Person):void {
			hideTreeOwnerSelectorPopup();
			//bus.dispatch(AppSignal.RELOAD_TREE, person.uid);
			model.editing.editEnabled = false;
			bus.dispatch(ViewSignal.PERSON_SELECTED, person);
			bus.dispatch(ViewSignal.PERSON_CENTERED, person);
			model.selectedTree = person.tree;
		}

		private function onMouseDown(event:MouseEvent):void {
			var target:DisplayObject = event.target as DisplayObject;
			if(Tree.instance.mouseOnCanvas())
				hideTreeOwnerSelectorPopup();
		}

		private function onOwnerNameClicked():void {
			//if(model.constructionInProcess) return;
			if(panel.treeSelectorPopup.visible){
				 hideTreeOwnerSelectorPopup();
			}else{
				var data:Array = [];
				var owner:Person = model.owner;
				for each(var t:TreeModel in model.trees.iterator)
					if(t.owner.node.visible)
						data.push(t);
				panel.treeSelectorPopup.refreshData(data);
				panel.treeSelectorPopup.show()
				panel.treeOwnerMark.rotation = 0;
			}
		}

		private function hideTreeOwnerSelectorPopup():void{
			panel.treeSelectorPopup.hide();
			panel.treeOwnerMark.rotation = 180;
		}

		private function onCentre(b:Button):void{
			model.selectedPerson = model.selectedTree.owner;
			bus.dispatch(ViewSignal.PERSON_CENTERED, model.selectedTree.owner);
		}

		private function onTreeSelected(_tree:TreeModel):void{
			panel.setOwner(_tree.owner);
			panel.treeOwnerNameTFLinked = Model.instance.trees.length > 1;
			onHandChanged();
		}

		private function onHandChanged():void{
			if(model.owner.editable){
				panel.saveTreeButton.visible = model.hand;
				panel.changeHand.visible = model.options.handPermitted;
				panel.changeHand.label = model.hand ? I18n.t('HAND_MODE') : I18n.t('AUTO_MODE');
			}else{
				panel.saveTreeButton.visible = false;
				panel.changeHand.visible = false;
			}
		}

		private function onDepthIndexChanged(index:int):void{
			if(!model.constructionInProcess){
				panel.depthSelector.index = index
				new DepthIndexChanged(index).execute();
			}
		}

		private function onRotateTree(b:Button):void{
			if(!model.constructionInProcess)
				model.descending = !model.descending;
		}

		private function onPrintClicked(b:Button):void{
			var w:AcceptWindow = new AcceptWindow(I18n.t('ATTENTION'), I18n.t('PRINT_WND_TEXT'), function():void{
				// обычное
				new PrintTree().execute();
			}, function():void{
				// внешнее
				new GotoLinkCommand(GotoLinkCommand.GOTO_PRINT_EXTERNAL, model.owner).execute();
			});
			w.yesButton.label = I18n.t('PRINT_WND_NORMAL');
			w.noButton.label = I18n.t('PRINT_WND_EXTERNAL');
			w.noButton.width = 180;
			w.open();
		}

		private function onSaveClicked(b:Button):void{
			new GotoLinkCommand(GotoLinkCommand.LINK, null, model.options.saveUrl).execute();
		}

		private function onOptionsClicked(b:Button):void{
			new GotoLinkCommand(GotoLinkCommand.LINK, null, model.options.setupUrl).execute();
		}

		private function onChangeHandClick(b:Button):void{
			model.hand = !model.hand;
		}
	}
}
