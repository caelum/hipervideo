package br.com.caelum.hipervideo.plugin {
	import br.com.caelum.hipervideo.links.Element;
	import br.com.caelum.hipervideo.links.Video;
	import br.com.caelum.hipervideo.links.XMLReader;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.PluginInterface;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class LinkBarPlugin extends MovieClip implements PluginInterface {

		/** Reference to the View of the player. **/
		private var view:AbstractView;
		
		private var mySkin:Object;
		
		private var links:LinkBar;
		private var playlist:LinkBar;

		public function initializePlugin(view:AbstractView):void {
			this.view = view;
		
			//If the custom skin is defined, load it in
			if (view.config['drelated.dskin'] != undefined){
				loadMySkin();
			}
			view.addModelListener(ModelEvent.STATE,stateHandler);			
		};
		
		/** Initialize the skin swf loading **/	
		private function loadMySkin():void{
			var skinloader:Loader = new Loader();
			skinloader.contentLoaderInfo.addEventListener(Event.COMPLETE, displaySkin);
			skinloader.load(new URLRequest(view.config['drelated.dskin']));
		}
		
		/** The skin was loaded, display it, stretch it, and load the thumbs. **/	
		private function displaySkin(e:Event):void{		
			mySkin = e.target.content;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,parseXML);
			
			trace(view.config['hipervideo.file']);
			loader.load(new URLRequest(view.config['hipervideo.file']));
		}
		
		/** Slide the plugin in when movie complete or paused. **/
		public function stateHandler(evt:ModelEvent):void {
			links.stateHandler(evt);
//			playlist.stateHandler(evt);
		}
		
		/** Parse the XML and do some magic with it. **/	
		private function parseXML(e:Event):void {
			var video:Video = new XMLReader(new XML(e.target.data)).extract();
			
			var linkArray:Array = new Array();
			for each (var element:Element in video.elements) {
				linkArray.push(element.link);
			}
			
			links = new LinkBar(linkArray, view, mySkin, this);
//			playlist = new LinkBar(video.playlist, view, mySkin);
		}

	}
}