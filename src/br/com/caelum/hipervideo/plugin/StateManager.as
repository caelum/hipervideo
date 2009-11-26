package br.com.caelum.hipervideo.plugin {
	import br.com.caelum.hipervideo.model.Action;
	import br.com.caelum.hipervideo.model.ActionType;
	import br.com.caelum.hipervideo.model.Element;
	import br.com.caelum.hipervideo.model.Hipervideo;
	import br.com.caelum.hipervideo.reader.XMLReader;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.ModelStates;
	import com.jeroenwijering.events.PluginInterface;
	import com.jeroenwijering.events.ViewEvent;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class StateManager extends MovieClip implements PluginInterface {

		/** Reference to the View of the player. **/
		private var view:AbstractView;
		
		private var links:LinkBar = null;
		private var playlist:LinkBar = null;
		
		private var painelAtivo:Boolean = false;
		private var lastPos:Number;
		private var actions:Array;
		
		[Embed(source="../../../../../controlbar.png")]
		private const ControlbarIcon:Class;
		
		/** Icon for the controlbar. **/
		private var icon:Bitmap;
		
		private var loader:URLLoader = new URLLoader();
		
		public function initializePlugin(view:AbstractView):void {
			this.view = view;
		
			icon = new ControlbarIcon();
			view.getPlugin('controlbar').addButton(icon,'hipervideo',clickHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addControllerListener(ControllerEvent.SEEK, seekHandler);
			
			view.config['StateManager'] = this;
			
			loader.addEventListener(Event.COMPLETE, parseXML);
			loader.load(new URLRequest(view.config['hipervideo.file']));
			
			view.config['autoPaused'] = false;
		};
		
		private function seekHandler(evt:ControllerEvent):void {
			lastPos = Infinity;
		}

		private function clickHandler(event:MouseEvent):void {
			painelAtivo = !painelAtivo;
			if (painelAtivo) {
				playlist.setVisible(true);
				links.setVisible(false);
			} else {
				links.setVisible(true);
				playlist.setVisible(false);
			}
		}
		
		/** Slide the plugin in when movie complete or paused. **/
		public function stateHandler(evt:ModelEvent=undefined):void {
			if (!view.config['autoPaused']) {
				clickHandler(null);
				if (painelAtivo) {
					playlist.stateHandler(evt);
				} else {
					links.stateHandler(evt);
				}
			}
			
			if (evt.data.newstate == ModelStates.PLAYING) {
				view.config['autoPaused'] = false;
			}
			
			switch (evt.data.newstate) {
				case ModelStates.COMPLETED:
					loadNextVideo();
					break;
			}
		}
		
		private function loadNextVideo():void {
			notifyNextVideo();
			view.config['Hipervideo'].notifyNextVideo();
		}
		
		public function notifyNextVideo():void {
			if (view.config['next'] != null && view.config['next'] != "") {
				view.config['hipervideo.file'] = view.config['next'];
				playlist.die();
				links.die();
				loader.load(new URLRequest(view.config['hipervideo.file']));
			}
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			if (playlist != null && links != null) {
				playlist.setVisible(false);
				playlist.resizeMe();
				links.setVisible(false);
				links.resizeMe();
				clickHandler(null);
			}
		}
		
		/** Parse the XML and do some magic with it. **/	
		private function parseXML(e:Event):void {
			var video:Hipervideo = new XMLReader(new XML(e.target.data)).extract();
			
			var linkArray:Array = new Array();
			for each (var element:Element in video.elements) {
				linkArray.push(element.link);
			}
			
			playlist = new LinkBar("Playlist", video.playlist, view, this);
			links = new LinkBar("Links", linkArray, view, this);
			actions = video.actions;
		}
		
		/** Check timing of the player to sync captions. **/
		private function timeHandler(evt:ModelEvent):void {
			var pos:Number = evt.data.position;
			for (var next:Number = 0; next < actions.length; next++) {
				if (actions[next].time < pos && actions[next].time >= lastPos) {
					performAction(actions[next]);
					break;
				}
			}
			lastPos = pos;
		};
		
		private function performAction(action:Action):void {
			if (action.type == ActionType.PAUSE) {
				view.config['autoPaused'] = true;
				view.sendEvent(ControllerEvent.PLAY);
			}
		}

	}
}