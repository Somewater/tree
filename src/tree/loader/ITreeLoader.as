package tree.loader {
	public interface ITreeLoader {
		function get serverHandler():IServerHandler

		function get flashVars():Object;

		function get domain():String
	}
}
