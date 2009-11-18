package br.com.caelum.hipervideo.plugin {
	import br.com.caelum.hipervideo.model.Action;
	import br.com.caelum.hipervideo.model.ActionType;
	import br.com.caelum.hipervideo.model.Element;
	import br.com.caelum.hipervideo.model.Video;
	import br.com.caelum.hipervideo.reader.XMLReader;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.PluginInterface;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class LinkBarPlugin extends MovieClip implements PluginInterface {

		/** Reference to the View of the player. **/
		private var view:AbstractView;
		
		private var links:LinkBar = null;
		private var playlist:LinkBar = null;
		
		private var painelAtivo:Boolean = false;
		private var lastPos:Number;
		private var actions:Array;
		private var stopPainel:Boolean = false;
		
		[Embed(source="../../../../../controlbar.png")]
		private const ControlbarIcon:Class;
		
		/** Icon for the controlbar. **/
		private var icon:Bitmap;

		public function initializePlugin(view:AbstractView):void {
			this.view = view;
		
			icon = new ControlbarIcon();
			view.getPlugin('controlbar').addButton(icon,'hipervideo',clickHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseXML);
			loader.load(new URLRequest(view.config['hipervideo.file']));
			trace(view.config['hipervideo.file']);
		};

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
			if (stopPainel) {
				stopPainel = false;
			} else {
				clickHandler(null);
				if (painelAtivo) {
					playlist.stateHandler(evt);
				} else {
					links.stateHandler(evt);
				}
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
			var video:Video = new XMLReader(new XML(e.target.data)).extract();
			
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
				stopPainel = true;
				view.sendEvent("PLAY");
			}
		}


	}
}