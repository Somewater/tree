package tree.view.gui.profile {
import com.somewater.display.Photo;
import com.somewater.storage.I18n;
import com.somewater.text.EmbededTextField;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;

import tree.common.Config;
import tree.model.Model;
import tree.model.Person;
import tree.view.gui.Button;
import tree.view.gui.PageBase;

public class PersonProfilePage extends PageBase{

		public static const FIELD_BIRTHDAY:String = 'birthday_str';
		public static const FIELD_DEATHDAY:String = 'deathday_str';
		public static const FIELD_BIRTH_PLACE:String = 'birth_place';
		public static const FIELD_LIVE_PLACE:String = 'home_place';
		public static function get DEFAULT_DISPLAY_FIELDS():String {
			var data:Object = {};
			data[FIELD_BIRTHDAY] = I18n.t('FIELD_BIRTHDAY');
			data[FIELD_DEATHDAY] = I18n.t('FIELD_DEATHDAY');
			data[FIELD_BIRTH_PLACE] = I18n.t('FIELD_BIRTH_PLACE');
			data[FIELD_LIVE_PLACE] = I18n.t('FIELD_LIVE_PLACE');
			var s:String = ''
			for(var k:String in data)
				s += (s.length > 0 ? ',' : '') + k + '=' + data[k];
			return s;
		};

		public static const LABELS_PADDING_X:int = 20;
		public static const PADDING:int = 10;

		public static const NAME:String = 'PersonProfilePage';

		private var photo:Photo;
		private var photoMask:Shape;

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
		//private var ageLabels:Labels;

		private var optionalLabels:OptionalLabels;

		private var deadMark:DisplayObject;

		public function PersonProfilePage() {
			photo = new Photo(Photo.SIZE_MAX | Photo.ORIENTED_CENTER, 200, 200);
			addChild(photo);
			photoMask = new Shape();
			addChild(photoMask);
			photo.mask = photoMask;
			photoMask.graphics.beginFill(0);
			photoMask.graphics.drawRoundRectComplex(0, 0, 200, 200, 5,5,5,5)

			nameField = new EmbededTextField(null, 0, 17, true, true);
			addChild(nameField);

			postField = new EmbededTextField(null, 0, 15);
			addChild(postField);

			editProfile = new IconButtonCustom(Config.loader.createMc('assets.IconEdit'))
			editProfile.label = I18n.t('EDIT_PROFILE');
			addChild(editProfile);

			viewTree = new IconButtonCustom(Config.loader.createMc('assets.IconTree'))
			viewTree.label = I18n.t('VIEW_TREE');
			addChild(viewTree);

			addPhoto = new IconButtonCustom(Config.loader.createMc('assets.IconAddPhoto'))
			addPhoto.label = I18n.t('ADD_PHOTO');
			addChild(addPhoto);

			viewProfile = new IconButtonCustom(Config.loader.createMc('assets.IconProfile'))
			viewProfile.label = I18n.t('VIEW_PROFILE');
			addChild(viewProfile);

			deleteProfile = new IconButtonCustom(Config.loader.createMc('assets.IconDelete'))
			deleteProfile.label = I18n.t('DELETE_PROFILE');
			addChild(deleteProfile);

			sendMessage = new IconButtonCustom(Config.loader.createMc('assets.IconMail'))
			sendMessage.label = I18n.t('SEND_MESSAGE');
			addChild(sendMessage);

			invite = new IconButtonCustom(Config.loader.createMc('assets.IconInvite'))
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
			//ageLabels = new Labels();
			//addChild(ageLabels);

			deadMark = Config.loader.createMc('assets.DeadMark');
			addChild(deadMark);

			optionalLabels = new OptionalLabels();
			addChild(optionalLabels);
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
			optionalLabels.clear();
		}

		override protected function refresh():void {
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
					livePlaceLabels
			];

			if(!optionalLabels.empty) elements.push(optionalLabels);

			nameField.width = _width - 2 * PADDING;

			var nextY:int = 0;
			for each(var elem:Object in elements){
				if(elem is DisplayObject){
					if(!DisplayObject(elem).visible) continue;
					DisplayObject(elem).x = LABELS_PADDING_X;
					DisplayObject(elem).y = nextY;
					nextY += DisplayObject(elem).height + PADDING;
					addChild(elem as DisplayObject);
				}else
					nextY += int(elem);
			}

			super.refresh();

			deadMark.x = photo.x + photo.width - deadMark.width;
			deadMark.y = photo.y - 1;
			addChild(deadMark);

			photoMask.x = photo.x;
			photoMask.y = photo.y;
		}

		internal function onPersonSelected(person:Person):void{
			var displayFields:Array = Model.instance.options.displayFields;
			var showBirthday:String = displayFields[FIELD_BIRTHDAY] || '';
			var showBirthPlace:String = displayFields[FIELD_BIRTH_PLACE] || '';
			var showDeathdat:String = displayFields[FIELD_DEATHDAY] || '';
			var showLivePlace:String = displayFields[FIELD_LIVE_PLACE] || '';

			if(!person || !person.node) return;
			photo.source = person.photo(Person.PHOTO_BIG);
			if(!photo.source) setDefaultPhoto(person.male);

			editProfile.visible = person.editable;
			deleteProfile.visible = !(person.node.slaves && person.node.slaves.length) && person.editable;
			addPhoto.visible = person.urls.editPhotoUrl != null;
			invite.visible = person.urls.inviteUrl != null;
			sendMessage.visible = person.urls.messageUrl != null;
			viewProfile.visible = person.profileUrl != null && person.profileUrl.length > 0;

			nameField.text = formattedIfEmpty(person.fullname);
			postField.visible = !!person.post;
			postField.text = formattedIfEmpty(person.post);

			bornLabels.visible = showBirthday && person.hasBirthdayDate
			bornLabels.title = showBirthday//(person.male ? I18n.t('MALE_BORN_FROM') : I18n.t('FEMALE_BORN_FROM')) + ':';
			bornLabels.value = formattedBirthday(person.birthday);

			diedLabels.visible = showDeathdat && person.died && person.hasDeathdayDate;
			diedLabels.title = showDeathdat//(person.male ? I18n.t('MALE_DEAD') : I18n.t('FEMALE_DEAD')) + ':';
			diedLabels.value = formattedBirthday(person.deathday);

			deadMark.visible = person.died;

			bornPlaceLabels.visible = showBirthPlace && person.birthPlace;
			bornPlaceLabels.title = showBirthPlace//(person.male ? I18n.t('BORN_PLACE_MALE') : I18n.t('BORN_PLACE_FEMALE'));
			bornPlaceLabels.value = formattedIfEmpty(person.birthPlace);

			livePlaceLabels.visible = showLivePlace && person.homePlace;
			livePlaceLabels.title = showLivePlace//person.died ? (person.male ? I18n.t('LIVED_PLACE_MALE') : I18n.t('LIVED_PLACE_FEMALE')) : (person.male ? I18n.t('LIVE_PLACE_MALE') : I18n.t('LIVE_PLACE_FEMALE'));
			livePlaceLabels.value = formattedIfEmpty(person.homePlace);

			//ageLabels.title = (person.male ? I18n.t('AGE_MALE') : I18n.t('AGE_FEMALE'));
			//ageLabels.value = formattedIfEmpty(person.age > 0 ? person.age.toString() : null);

			optionalLabels.setData(person);

			refresh();
		}

		public function setDefaultPhoto(male:Boolean):void {
			photo.source = Config.loader.createMc('assets.DefaultPhoto_' + (male ? 'male' : 'female'));
		}

		private function onFamilyBlockResized(event:Event):void{
			refresh();
		}

		public static function formattedBirthday(date:Date):String{
			if(!date || isNaN(date.date)) return '    ---';
			return date.date + ' ' + I18n.t('MONTH_GENETIVE_' + date.month) + ' ' + date.fullYear;
		}

		internal static function formattedIfEmpty(value:String):String{
			return value ? value : ''
		}
	}
}

import com.somewater.text.EmbededTextField;

import flash.display.GradientType;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;

import tree.common.Config;
import tree.common.IClear;
import tree.model.Model;
import tree.model.Person;

import tree.view.gui.IconButton;
import tree.view.gui.UIComponent;
import tree.view.gui.profile.PersonProfilePage;

class Labels extends UIComponent{

	private var _label1_tf:EmbededTextField;
	private var _label2_tf:EmbededTextField;
	private var shadowMask:Shape;

	public function Labels(){
		var holder:Sprite = new Sprite();
		_label1_tf = new EmbededTextField(null, 0, 11, true);
		holder.addChild(_label1_tf);
		_label2_tf = new EmbededTextField(null, 0, 11, false);
		_label2_tf.autoSize = 'left';
		holder.addChild(_label2_tf);
		addChild(holder);

		var maskWidth:int = Config.GUI_WIDTH - PersonProfilePage.LABELS_PADDING_X * 1.5;
		var maskHeight:int = 100;
		shadowMask = new Shape();
		addChild(shadowMask);
		var mat:Matrix= new Matrix();
		var colors:Array=[0,0];
		var alphas:Array=[1,0];
		var ratios:Array=[230,255];
		mat.createGradientBox(maskWidth, maskHeight);
		shadowMask.graphics.lineStyle();
		shadowMask.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,mat);
		shadowMask.graphics.drawRect(0,0,maskWidth, maskHeight);
		shadowMask.graphics.endFill();
		holder.mask = shadowMask;
		shadowMask.cacheAsBitmap = holder.cacheAsBitmap = true;

		_width = maskWidth;
		graphics.beginFill(0,0)
		graphics.drawRect(0,0,_width,20)
	}

	public function set title(v:String):void{
		_label1_tf.text = v;
		refresh();
	}

	public function set value(v:String):void{
		_label2_tf.text = v;
		refresh();
		if(_label2_tf.x + _label2_tf.width > _width + 5)
			hint = _label2_tf.text;
		else
			hint = null;
	}

	public function get title():String {return _label1_tf.text;}

	public function get value():String {return _label2_tf.text;}

	override protected function refresh():void {
		const L1_WIDTH:int = 80;
		if(_label1_tf.width > L1_WIDTH)
			_label2_tf.x = _label1_tf.x + _label1_tf.width + 5;
		else
			_label2_tf.x = L1_WIDTH;
		//_label2_tf.width = _width - _label2_tf.x;
	}

	override public function get height():Number {
		return Math.max(_label1_tf.height, _label2_tf.height);
	}
}

class IconButtonCustom extends IconButton{

	function IconButtonCustom(icon:MovieClip) {
		super(icon);
	}

	override public function set movie(value:MovieClip):void {
		super.movie = value;
		if(value){
			value.x = (17 - value.width) * 0.5;
			refresh();
		}
	}
}

class OptionalLabels extends UIComponent implements IClear{

	private var labels:Array = [];

	public function OptionalLabels(){

	}

	override public function clear():void{
		super.clear();
		removeLabels();
	}

	private function removeLabels():void{
		for each(var l:Labels in labels){
			if(l.parent) l.parent.removeChild(l);
			l.clear();
		}
		labels = [];
	}

	public function setData(person:Person):void{
		removeLabels();

		var nextY:int = 0;

		var m:Model = Model.instance;
		var standartFields:Array = m.options.parseDisplayFields(PersonProfilePage.DEFAULT_DISPLAY_FIELDS);
		var allFeilds:Array = m.options.displayFields;
		for(var fieldName:String in allFeilds)
			if(!standartFields[fieldName] && person.fields.has(fieldName)){
				var l:Labels = new Labels();
				l.title = allFeilds[fieldName];
				l.value = person.fields.get(fieldName);
				addChild(l);
				l.y = nextY;
				nextY += l.height + PersonProfilePage.PADDING;
				labels.push(l);
			}
	}

	public function get empty():Boolean {
		return labels.length == 0;
	}
}