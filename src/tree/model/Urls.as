package tree.model {
public class Urls {

	public var editUrl:String;
	public var editPhotoUrl:String;
	public var messageUrl:String;
	public var inviteUrl:String;

	public function Urls(person:XML = null) {
		if(person){
			editUrl = person.fields.field.(@name == "edit_url");
			editPhotoUrl = person.fields.field.(@name == "edit_photo_url");
			messageUrl = person.fields.field.(@name == "message_url");
			inviteUrl = person.fields.field.(@name == "invite_url");

			// обнуление пустых строк:
			if(!editUrl) editUrl = null;
			if(!editPhotoUrl) editPhotoUrl = null;
			if(!messageUrl) messageUrl = null;
			if(!inviteUrl) inviteUrl = null;
		}
	}
}
}
