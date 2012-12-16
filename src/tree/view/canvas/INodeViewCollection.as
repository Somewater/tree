package tree.view.canvas {
	public interface INodeViewCollection {
		function getNodeIcon(uid:int):NodeIcon;

		function getJoinLine(from:int, to:int):JoinLine;

		function get iterator():*;
	}
}
