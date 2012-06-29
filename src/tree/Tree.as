package tree {
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.KeyBind;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.command.RecalculateNodes;

	import tree.command.ResponseRouter;
	import tree.command.TraceNodesOutput;
	import tree.loader.ITreeLoader;
	import tree.loader.TreeLoaderBase;
	import tree.manager.ITicker;
	import tree.model.Join;
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
	import tree.view.canvas.Canvas;
	import tree.view.canvas.CanvasMediator;
	import tree.view.gui.Gui;
	import tree.view.Preloader;
	import tree.view.WindowsManager;
	import tree.view.gui.GuiMediator;

	public class Tree extends Sprite{

		public static var instance:Tree;

		private var model:Model;
		private var bus:Bus;

		private var commandMap:Array;
		public var detainedCommands:Array = [];

		private var canvas:Canvas;
		private var gui:Gui;

		public var mediators:Array = [];

		public function Tree() {
			instance = this;
		}

		public function startup():void {

			CONFIG::debug
			{
				Cc.config.commandLineAllowed = true;
				Cc.config.tracing = true;
				Cc.startOnStage(this.stage);
				Cc.width = Config.WIDTH * 0.8;
				Cc.height = Config.HEIGHT * 0.6;
				//Cc.visible = false;
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

		private function onBusSignal(signal:String, ...args):void {
			var commandCl:Class = commandMap[signal];
			var command:Command;
			if(commandCl)
			{
				if(!args || args.length == 0)
					command = new commandCl();
				else if(args.length == 1)
					command = new commandCl(args[0]);
				else if(args.length == 2)
					command = new commandCl(args[0], args[1]);
				else if(args.length == 3)
					command = new commandCl(args[0], args[1], args[2]);
				else if(args.length == 4)
					command = new commandCl(args[0], args[1], args[2], args[3]);
				else if(args.length == 5)
					command = new commandCl(args[0], args[1], args[2], args[3], args[4]);

				command.execute();
			}
		}

		private function configurateInjections():void{
			var ticker:Ticker = new Ticker(this.stage)
			Config.reject(Ticker, ticker);
			Config.reject(ITicker, ticker);
			Config.reject(Tree, this);
			Config.reject(ITreeLoader, Config.loader);
		}

		private function configurateModel():void
		{
			bus = new Bus(this.stage);
			Config.reject(Bus, bus);
			bus.add(onBusSignal);
			model = new Model(bus);
			Config.reject(Model, model);

			AppServerHandler.instance = new AppServerHandler(Config.loader.serverHandler, bus);
			bus.addNamed(RequestSignal.SIGNAL, AppServerHandler.instance.call);
			Config.reject(AppServerHandler, AppServerHandler.instance);

			Join.initializeConstants();
		}

		private function configurateView():void {
			addChild(Config.content = new Sprite());
			addChild(Config.windows = new Sprite());
			new WindowsManager(bus, Config.windows, new Preloader());
			addChild(Config.tooltips = new Sprite());

			Config.content.addChild(canvas = new Canvas());
			new CanvasMediator(canvas);

			Config.content.addChild(gui = new Gui(bus));
			new GuiMediator(gui);
		}


		private function configurateCommands():void {
			//commandMap = new CommandMapData().create();
			commandMap = [];
			commandMap[AppSignal.STARTUP] = StartupCommand;
			commandMap[ResponseSignal.SIGNAL] = ResponseRouter;
			commandMap[ModelSignal.NODES_NEED_CONSTRUCT] = RecalculateNodes;
			commandMap[ModelSignal.NODES_RECALCULATED] = TraceNodesOutput;
		}


		CONFIG::debug
		{
		public function debugTrace(message:String):void {
			Cc.log(message);
		}

		private function showHideConsole():void
		{
			Cc.visible = !Cc.visible;
		}
		}
	}
}
