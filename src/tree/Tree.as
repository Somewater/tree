package tree {
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.KeyBind;
	import com.somewater.storage.I18n;
	import com.somewater.text.EmbededTextField;
	import com.somewater.text.Hint;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.ui.Keyboard;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.command.AddPerson;
	import tree.command.ChangePersonJoins;
	import tree.command.PrepareateTreeDraw;

	import tree.command.RecalculateNodes;
	import tree.command.RemovePerson;

	import tree.command.ResponseRouter;
	import tree.command.view.CalculateNextNodeRollUnroll;
	import tree.command.view.CompleteTreeDraw;
	import tree.command.view.ContinueTreeDraw;
	import tree.command.view.RecalculateNodeRollUnroll;
	import tree.command.view.ShowNode;
	import tree.command.view.HideNode;
	import tree.command.view.RollUnrollNode;
	import tree.command.view.SelectNextTree;
	import tree.command.view.StartTreeDraw;
	import tree.loader.ITreeLoader;
	import tree.loader.TreeLoaderBase;
	import tree.manager.ITicker;
	import tree.model.Join;
	import tree.model.lines.LineMatrixCollection;
	import tree.model.Model;
	import tree.manager.Ticker;

	import tree.signal.AppSignal;
	import tree.command.Command;
	import tree.signal.ModelSignal;
	import tree.signal.RequestSignal;
	import tree.command.StartupCommand;
	import tree.common.Bus;

	import tree.common.Config;
	import tree.manager.AppServerHandler;
	import tree.model.NodesCollection;
	import tree.model.PersonsCollection;
	import tree.model.base.ICollection;
	import tree.model.base.ModelCollection;
	import tree.signal.ResponseSignal;
	import tree.signal.ViewSignal;
	import tree.view.canvas.Canvas;
	import tree.view.canvas.CanvasController;
	import tree.view.canvas.CanvasMediator;
	import tree.view.canvas.INodeViewCollection;
	import tree.view.gui.Gui;
	import tree.view.Preloader;
	import tree.view.WindowsManager;
	import tree.view.gui.GuiMediator;
	import tree.view.gui.panel.Panel;
	import tree.view.gui.panel.PanelMediator;

	public class Tree extends Sprite{

		public static var instance:Tree;

		private var model:Model;
		private var bus:Bus;

		public var detainedCommands:Array = [];

		private var canvas:Canvas;
		private var gui:Gui;
		private var panel:Panel;

		public var mediators:Array = [];

		[Embed(source='common/ru.txt', mimeType='application/octet-stream')]
		private var i18nText:Class;

		public function Tree() {
			instance = this;
			EmbededTextField.DEFAULT_FONT = 'Arial';
			I18n.text = (new i18nText()).toString();
		}

		public function startup():void {

			CONFIG::debug
			{
				Cc.config.commandLineAllowed = true;
				Cc.commandLine = true;
				Cc.config.tracing = true;
				Cc.startOnStage(this.stage);
				Cc.width = Config.WIDTH * 0.8;
				Cc.height = Config.HEIGHT * 0.6;
				Cc.visible = false;
				Cc.bindKey(new KeyBind('~'), showHideConsole);
				Cc.bindKey(new KeyBind('`'), showHideConsole);
				Cc.bindKey(new KeyBind('ё'), showHideConsole);
			}

			configurateInjections();
			configurateModel();
			configurateView();
			configurateCommands();

			bus.dispatch(AppSignal.STARTUP);
		}

		private function configurateInjections():void{
			var ticker:Ticker = new Ticker(this.stage)
			Config.ticker = ticker;
			Config.reject(Ticker, ticker);
			Config.reject(ITicker, ticker);
			Config.reject(Tree, this);
			Config.reject(ITreeLoader, Config.loader);
			Config.reject(LineMatrixCollection, new LineMatrixCollection())
		}

		private function configurateModel():void
		{
			bus = new Bus(this.stage);
			Config.reject(Bus, bus);
			model = new Model(bus);
			Config.reject(Model, model);

			AppServerHandler.instance = new AppServerHandler(Config.loader.serverHandler, bus);
			bus.addNamed(RequestSignal.SIGNAL, AppServerHandler.instance.call);
			Config.reject(AppServerHandler, AppServerHandler.instance);

			Join.initializeConstants();
		}

		private function configurateView():void {
			Font.registerFont(Config.loader.createMc('font.ArialBold_font', null, false));
			Font.registerFont(Config.loader.createMc('font.Arial_font', null, false));

			addChild(Config.content = new Sprite());
			addChild(Config.windows = new Sprite());
			new WindowsManager(bus, Config.windows, new Preloader());
			addChild(Config.tooltips = new Sprite());
			Hint.init(Config.tooltips);

			Config.content.addChild(canvas = new Canvas());
			var canvasController:CanvasController = new CanvasController(canvas)
			new CanvasMediator(canvas, canvasController);
			Config.reject(CanvasController, canvasController);
			Config.reject(Canvas, canvas);
			Config.reject(INodeViewCollection, canvas);

			Config.content.addChild(gui = new Gui());
			new GuiMediator(gui);

			Config.content.addChild(panel = new Panel());
			new PanelMediator(panel);

			//bus.sceneResize.add(onSceneResize);
			onSceneResize();
		}

		private function configurateCommands():void {
			bus.addCommand(AppSignal.STARTUP, StartupCommand);
			bus.addCommand(ResponseSignal.SIGNAL, ResponseRouter);
			bus.addCommand(ModelSignal.NODES_NEED_CALCULATE, RecalculateNodes);
			bus.addCommand(ModelSignal.TREE_NEED_CONSTRUCT, StartTreeDraw);
			bus.addCommand(ModelSignal.SHOW_NODE, ShowNode);
			bus.addCommand(ModelSignal.HIDE_NODE, HideNode);

			bus.addCommand(ViewSignal.CANVAS_READY_FOR_START, SelectNextTree);
			bus.addCommand(ViewSignal.JOIN_QUEUE_STARTED, PrepareateTreeDraw);
			bus.addCommand(ViewSignal.JOIN_QUEUE_STARTED, ContinueTreeDraw);
			bus.addCommand(ViewSignal.NODE_ROLL_UNROLL, RollUnrollNode);
			bus.addCommand(ViewSignal.JOIN_QUEUE_COMPLETED, SelectNextTree);
			bus.addCommand(ViewSignal.ALL_TREES_COMPLETED, CompleteTreeDraw);

			bus.addCommand(ModelSignal.ADD_PERSON, AddPerson);
			bus.addCommand(ModelSignal.REMOVE_PERSON, RemovePerson);
			bus.addCommand(ModelSignal.CHANGE_PERSON_JOINS, ChangePersonJoins)

			bus.addCommand(ViewSignal.RECALCULATE_ROLL_UNROLL, RecalculateNodeRollUnroll);
			bus.addCommand(ViewSignal.CALCULATE_NEXT_ROLL_UNROLL, CalculateNextNodeRollUnroll);

			//stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void{if(e.keyCode == Keyboard.N) new ContinueTreeDraw().execute()})
			bus.addCommand(ViewSignal.JOIN_DRAWED, ContinueTreeDraw);
		}


		CONFIG::debug
		{
		private function showHideConsole():void
		{
			Cc.visible = !Cc.visible;
		}
		}

		private function onSceneResize(point:Point = null):void {
			graphics.clear();
			graphics.beginFill(0xFEFFFD);
			graphics.drawRect(0, 0, Config.WIDTH, Config.HEIGHT);
		}
	}
}
