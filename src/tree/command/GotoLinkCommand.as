package tree.command {
import flash.net.URLRequest;
import flash.net.navigateToURL;

import tree.model.Person;

public class GotoLinkCommand extends Command{

	public static const GOTO_PROFILE:String = 'gotoProfile';

	public static const GOTO_EDIT_PROFILE:String = 'gotoEditProfile';

	public static const GOTO_INVITE:String = 'gotoInvite';

	public static const GOTO_MESSAGE:String = 'gotoMessage';

	public static const GOTO_EDIT_PHOTO:String = 'gotoEditPhoto';

	public var person:Person;
	public var type:String;



	public function GotoLinkCommand(type:String, person:Person) {
		this.type = type;
		this.person = person;
	}

	override public function execute():void {
		var link:String;

		switch (type){
			case GOTO_PROFILE:
				link = person.profileUrl;
				break;

			case GOTO_EDIT_PROFILE:
				link = person.urls.editUrl;
				break;

			case GOTO_INVITE:
				link = person.urls.inviteUrl;
				break;

			case GOTO_MESSAGE:
				link = person.urls.messageUrl;
				break;

			case GOTO_EDIT_PHOTO:
				link = person.urls.editPhotoUrl;
				break;
		}

		if(link)
			navigateToURL(new URLRequest(link), '_blank');
	}
}
}
