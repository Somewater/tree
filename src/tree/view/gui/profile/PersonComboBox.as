package tree.view.gui.profile {
import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import fl.data.DataProvider;
import fl.events.ComponentEvent;

import flash.display.Shape;
import flash.events.Event;

import nid.ui.controls.datePicker.iconSprite;

import tree.model.Join;

import tree.model.JoinType;
import tree.model.Model;
import tree.model.Node;

import tree.model.Person;

import tree.view.gui.TreeComboBox;
import tree.view.gui.UIComponent;
import tree.view.gui.notes.PersonNotesController;

public class PersonComboBox extends UIComponent{

	private var selectFromFamily:EmbededTextField;
	public var comboBox:TreeComboBox;
	public var comboBoxBar:Shape;
	private var createPersonLabel:EmbededTextField;

	private var personItems:Array = [];

	public function PersonComboBox() {
		selectFromFamily = new EmbededTextField(null, 0x3a3a3a, 12, true);
		addChild(selectFromFamily);

		createPersonLabel = new EmbededTextField(null, 0x3a3a3a, 12, true);
		addChild(createPersonLabel);

		comboBox = new TreeComboBox();
		comboBox.editable = true;
		comboBox.addEventListener(Event.CHANGE, onComboChanged);
		comboBox.addEventListener(TreeComboBox.FILTER, onComboBoxEnter)
		addChild(comboBox);

		comboBoxBar = new Shape();
		addChild(comboBoxBar);
	}

	override public function clear():void {
		super.clear();
		comboBox.removeEventListener(Event.CHANGE, onComboChanged);
		comboBox.removeEventListener(TreeComboBox.FILTER, onComboBoxEnter)
		comboBox.clear();
		personItems = null;
	}

	override protected function refresh():void {
		var enabled:Boolean = this.enabled;

		selectFromFamily.text = I18n.t('SELECT_FROM_FAMILY');
		createPersonLabel.text = I18n.t('CREATE_NEW_PROFILE');

		comboBox.setSize(_width, 34)
		comboBox.y = selectFromFamily.y + selectFromFamily.height + 10;
		comboBox.buttonMode = comboBox.useHandCursor = comboBox.mouseEnabled = comboBox.mouseChildren = enabled;
		comboBox.alpha = enabled ? 1 : 0.8;
		comboBox.prompt = enabled ? I18n.t('FROM_LIST') : I18n.t('CANT_MATCHED_PERSONS');

		comboBoxBar.graphics.clear();
		comboBoxBar.graphics.lineStyle(1, 0xcedd9b);
		comboBoxBar.graphics.moveTo(0,0);
		comboBoxBar.graphics.lineTo(_width,0);
		comboBoxBar.graphics.lineStyle(1, 0xebf5cb);
		comboBoxBar.graphics.moveTo(0,1);
		comboBoxBar.graphics.lineTo(_width,1);
		comboBoxBar.y = comboBox.y + comboBox.height + 10;

		createPersonLabel.y = comboBoxBar.y + 15;
	}

	public function setPerson(person:Person, joinType:JoinType, from:Person):void {
		personItems = [new DPItem(person, true)];
		var fromNode:Node = from.node;
		for each(var p:Person in from.tree.persons.iterator)
			if(p != from && !from.relation(p)){
				var canAdd:Boolean = false;

				//  проверяем поколение
				if(joinType.flatten){
					canAdd = p.node.generation == fromNode.generation;
				}else if(joinType.breed){
					canAdd = (p.node.generation - fromNode.generation) == 1;
				}else if(!joinType.breed){
					canAdd = (p.node.generation - fromNode.generation) == -1;
				}

				// проверяем пол
				canAdd &&= p.male == joinType.manAssoc;

				if(canAdd){
					if(joinType.superType == JoinType.SUPER_TYPE_BREED){
						// если добавляем ребенка, проверяем, что у него еще нет соответствующего родителя
						canAdd = joinType == Join.MOTHER ? (p.mother == null) : (p.father == null);
					}else if(joinType.superType == JoinType.SUPER_TYPE_PARENT){
						// если добавляем родителя, проверяем, что муж/жена from не станет вдруг братом/сестрой
						if(from.marry){
							canAdd = (p.male ? p != from.marry.father : p != from.marry.mother);
						}
					}else if(joinType.superType == JoinType.SUPER_TYPE_BRO){
						// если добавляем брата/сестру, проверим, что у него нет хотя бы одного родителя, либо один из родителей у вас общий
						if(p.mother && p.father && from.mother && from.father)
							canAdd = p.mother == from.mother || p.father == from.father;
					}
				}

				if(canAdd)
					personItems.push(new DPItem(p));
			}

		var dataProvider:DataProvider = new DataProvider(filteredPersons(personItems));
		comboBox.dataProvider = dataProvider;

	}

	public function get enabled():Boolean{
		return comboBox && comboBox.dataProvider && comboBox.dataProvider.length > 0;
	}

	private function onComboChanged(event:Event):void{
		var item:DPItem = comboBox.selectedItem as DPItem;
		if(item && item.newPerson)
			comboBox.selectedIndex = -1;
	}

	private function onComboBoxEnter(event:Event):void{
		comboBox.dataProvider.removeAll();
		comboBox.dataProvider.addItems(filteredPersons(personItems, comboBox.text))
	}

	private function filteredPersons(persons:Array, text:String = null):Array{
		var result:Array;
		if(text && false){
			result = [];
			text = text.toLowerCase();
			for each(var i:DPItem in persons)
				if(i.newPerson || PersonNotesController.filter(i.person, text))
					result.push(i);
		}else
			result = persons.slice();
		return result;
	}
}
}

import com.somewater.storage.I18n;

import tree.model.Person;

import tree.view.gui.TreeComboBox;

class DPItem{

	public var person:Person;
	public var newPerson:Boolean;

	public function DPItem(person:Person, newPerson:Boolean = false){
		this.person = person;
		this.newPerson = newPerson;
	}

	public function get label():String{
		return newPerson ? I18n.t('CREATE_NEW_PROFILE') : person.name;
	}

	public function get icon():String {
		return null;
	}
}
