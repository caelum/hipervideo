package br.com.caelum.hipervideo.plugin {
	import br.com.caelum.hipervideo.links.Element;
	import br.com.caelum.hipervideo.links.Video;
	import br.com.caelum.hipervideo.links.XMLReader;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.ModelStates;
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
		
		private var links:LinkBar;
		private var playlist:LinkBar;
		
		[Embed(source="../../../../../controlbar.png")]
		private const ControlbarIcon:Class;
		
		/** Icon for the controlbar. **/
		private var icon:Bitmap;

		public function initializePlugin(view:AbstractView):void {
			this.view = view;
		
			icon = new ControlbarIcon();
			view.getPlugin('controlbar').addButton(icon,'hipervideo',clickHandler);
		
			view.addModelListener(ModelEvent.STATE,stateHandler);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseXML);
			loader.load(new URLRequest(view.config['hipervideo.file']));
			trace(view.config['hipervideo.file']);
		};

		private function clickHandler(event:MouseEvent):void {
			painelAtivo = !painelAtivo;
			trace("painelAtivo = " + painelAtivo);
		}
		
		private var painelAtivo:Boolean;
		
		/** Slide the plugin in when movie complete or paused. **/
		public function stateHandler(evt:ModelEvent):void {
			if (painelAtivo) {
				trace("playlist");
				playlist.stateHandler(evt);
			} else {
				trace("links");
				links.stateHandler(evt);
			}
		}
		
		/** Parse the XML and do some magic with it. **/	
		private function parseXML(e:Event):void {
			var video:Video = new XMLReader(new XML(e.target.data)).extract();
			
			var linkArray:Array = new Array();
			for each (var element:Element in video.elements) {
				linkArray.push(element.link);
			}
			
			playlist = new LinkBar(video.playlist, view, this);
			links = new LinkBar(linkArray, view, this);
		}

	}
}