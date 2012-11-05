package tree.view.gui.profile {
	import com.somewater.display.Photo;
	import com.somewater.storage.I18n;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.LinkLabel;

	import flash.display.DisplayObject;
	import flash.display.Shape;

	import flash.events.Event;

	import tree.common.Config;
	import tree.model.JoinType;

	import tree.model.Person;

	import tree.signal.ViewSignal;

	import tree.view.gui.Button;
import tree.view.gui.IconButton;

import tree.view.gui.PageBase;
	import tree.view.gui.StandartButton;
	import tree.view.gui.UIComponent;

	public class PersonProfilePage extends PageBase{

		public static const NAME:String = 'PersonProfilePage';

		private var photo:Photo;

		private var nameField:EmbededTextField;
		private var postField:EmbededTextField;

		internal var editProfile:Button;
		internal var viewProfile:Button;
		internal var viewTree:Button;
		internal var addPhoto:Button;
		internal var sendMessage:Button;
		internal var invite:Button;
		internal var deleteProfile:Button;

		private var bornLabels:Labels;
		private var diedLabels:Labels;

		private var bornPlaceLabels:Labels;
		private var livePlaceLabels:Labels;
		private var ageLabels:Labels;

		private var phoneLabels:Labels;
		private var icqLabels:Labels;
		private var skypeLabels:Labels;

		public function PersonProfilePage() {
			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER, 200, 200);
			addChild(photo);

			nameField = new EmbededTextField(null, 0, 17, true, true);
			addChild(nameField);

			postField = new EmbededTextField(null, 0, 15);
			addChild(postField);

			editProfile = new IconButton(Config.loader.createMc('assets.IconEdit'))
			editProfile.label = I18n.t('EDIT_PROFILE');
			addChild(editProfile);

			viewTree = new IconButton(Config.loader.createMc('assets.IconTree'))
			viewTree.label = I18n.t('VIEW_TREE');
			addChild(viewTree);

			addPhoto = new IconButton(Config.loader.createMc('assets.IconAddPhoto'))
			addPhoto.label = I18n.t('ADD_PHOTO');
			addChild(addPhoto);

			viewProfile = new IconButton(Config.loader.createMc('assets.IconProfile'))
			viewProfile.label = I18n.t('VIEW_PROFILE');
			addChild(viewProfile);

			deleteProfile = new IconButton(Config.loader.createMc('assets.IconDelete'))
			deleteProfile.label = I18n.t('DELETE_PROFILE');
			addChild(deleteProfile);

			sendMessage = new IconButton(Config.loader.createMc('assets.IconMail'))
			sendMessage.label = I18n.t('SEND_MESSAGE');
			addChild(sendMessage);

			invite = new IconButton(Config.loader.createMc('assets.IconInvite'))
			invite.label = I18n.t('INVITE');
			addChild(invite);

			bornLabels = new Labels();
			addChild(bornLabels);
			diedLabels = new Labels();
			addChild(diedLabels);

			bornPlaceLabels = new Labels();
			addChild(bornPlaceLabels);
			livePlaceLabels = new Labels();
			addChild(livePlaceLabels);
			ageLabels = new Labels();
			addChild(ageLabels);

			phoneLabels = new Labels();
			addChild(phoneLabels);
			icqLabels = new Labels();
			addChild(icqLabels);
			skypeLabels = new Labels();
			addChild(skypeLabels);
		}

		override public function get pageName():String {
			return NAME;
		}

		override public function clear():void {
			super.clear();
			photo.clear();
			editProfile.clear();
			viewProfile.clear();
			viewTree.clear();
		}

		override protected function refresh():void {
			const PADDING:int = 10;

			var elements:Array = [
					nameField,
					editProfile,
					photo,

					postField,
					bornLabels,
					diedLabels,

					10,
					// actions
					sendMessage,
					viewProfile,
					addPhoto,
					invite,
					viewTree,
					deleteProfile,
					10,

					bornPlaceLabels,
					livePlaceLabels,
					ageLabels,
					10,
					phoneLabels,
					icqLabels,
					skypeLabels
			];

			nameField.width = _width - 2 * PADDING;

			var nextY:int = 0;
			var paddingX:int = 20;
			for each(var elem:Object in elements){
				if(elem is DisplayObject){
					if(!DisplayObject(elem).visible) continue;
					DisplayObject(elem).x = paddingX;
					DisplayObject(elem).y = nextY;
					nextY += DisplayObject(elem).height + PADDING;
					addChild(elem as DisplayObject);
				}else
					nextY += int(elem);
			}

			super.refresh();
		}

		internal function onPersonSelected(person:Person):void{
			const SHOW_ALL_IF_DIE:Boolean = false;

			if(!person) return;
			photo.source = person.photo;
			if(!photo.source) setDefaultPhoto(person.male);

			editProfile.visible = deleteProfile.visible = person.open;

			nameField.text = formattedIfEmpty(person.fullname);
			postField.visible = !!person.post || SHOW_ALL_IF_DIE;
			postField.text = formattedIfEmpty(person.post);

			bornLabels.title = (person.male ? I18n.t('MALE_BORN_FROM') : I18n.t('FEMALE_BORN_FROM')) + ':';
			bornLabels.value = formattedBirthday(person.birthday);

			diedLabels.visible = person.died || SHOW_ALL_IF_DIE;
			diedLabels.title = (person.male ? I18n.t('MALE_DEAD') : I18n.t('FEMALE_DEAD')) + ':';
			diedLabels.value = formattedBirthday(person.deathday);

			bornPlaceLabels.title = (person.male ? I18n.t('BORN_PLACE_MALE') : I18n.t('BORN_PLACE_FEMALE'));
			bornPlaceLabels.value = formattedIfEmpty(null);

			livePlaceLabels.title = person.died ? (person.male ? I18n.t('LIVED_PLACE_MALE') : I18n.t('LIVED_PLACE_FEMALE')) : (person.male ? I18n.t('LIVE_PLACE_MALE') : I18n.t('LIVE_PLACE_FEMALE'));
			livePlaceLabels.value = formattedIfEmpty(null);

			ageLabels.title = (person.male ? I18n.t('AGE_MALE') : I18n.t('AGE_FEMALE'));
			ageLabels.value = formattedIfEmpty(person.age > 0 ? person.age.toString() : null);

			phoneLabels.title = I18n.t('MOBILE_PHONE');
			phoneLabels.value = formattedIfEmpty(null);

			icqLabels.title = I18n.t('ICQ');
			icqLabels.value = formattedIfEmpty(null);

			skypeLabels.title = I18n.t('SKYPE');
			skypeLabels.value = formattedIfEmpty(null);

			refresh();
		}

		public function setDefaultPhoto(male:Boolean):void {
			photo.source = Config.loader.createMc('assets.DefaultPhoto_' + (male ? 'male' : 'female'));
		}

		private function onFamilyBlockResized(event:Event):void{
			refresh();
		}

		internal static function formattedBirthday(date:Date):String{
			if(!date || isNaN(date.date)) return '    ---';
			return date.date + ' ' + I18n.t('MONTH_GENETIVE_' + date.month) + ' ' + date.fullYear;
		}

		internal static function formattedIfEmpty(value:String):String{
			return value ? value : ''
		}
	}
}

import com.somewater.text.EmbededTextField;

import tree.view.gui.UIComponent;

class Labels extends UIComponent{

	private var _label1_tf:EmbededTextField;
	private var _label2_tf:EmbededTextField;

	public function Labels(){
		_label1_tf = new EmbededTextField(null, 0, 11, true);
		addChild(_label1_tf);
		_label2_tf = new EmbededTextField(null, 0, 11, false);
		addChild(_label2_tf);
	}

	public function set title(v:String):void{
		_label1_tf.text = v;
		refresh();
	}

	public function set value(v:String):void{
		_label2_tf.text = v;
		refresh();
	}

	public function get title():String {return _label1_tf.text;}

	public function get value():String {return _label2_tf.text;}

	override protected function refresh():void {
		const L1_WIDTH:int = 80;
		if(_label1_tf.width > L1_WIDTH)
			_label2_tf.x = _label1_tf.x + _label1_tf.width + 5;
		else
			_label2_tf.x = L1_WIDTH;
	}
}