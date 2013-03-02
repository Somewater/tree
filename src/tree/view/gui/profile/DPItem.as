package tree.view.gui.profile {
import com.somewater.storage.I18n;

import tree.model.Person;

import tree.view.gui.TreeComboBox;

internal class DPItem{

	public var person:Person;
	public var newPerson:Boolean;
	public var sameTree:Boolean;
	public var reverseRoot:Boolean;

	public function DPItem(person:Person, newPerson:Boolean = false, sameTree:Boolean = true, reverseRoot:Boolean = false){
		this.person = person;
		this.newPerson = newPerson;
		this.sameTree = sameTree;
		this.reverseRoot = reverseRoot;
	}

	public function get label():String{
		return newPerson ? I18n.t('CREATE_NEW_PROFILE') : person.name;
	}

	public function get icon():String {
		return null;
	}
}
}
