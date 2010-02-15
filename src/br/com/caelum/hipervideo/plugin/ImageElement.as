package br.com.caelum.hipervideo.plugin
{
	import br.com.caelum.hipervideo.model.Element;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class ImageElement extends MovieClip {
		
		private var element:Element;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var image:Loader;
		private var child:DisplayObject;
		public var shouldRemove:Boolean;
		
		private function newImage():Loader {
			image = new Loader();
			image.load(new URLRequest(element.content));
			image.contentLoaderInfo.addEventListener(Event.COMPLETE, resizeImage);
			image.addEventListener(MouseEvent.CLICK, clickHandler);
			return image;
		}
		
		private function resizeImage(e:Event):void {
	        image.width = element.width;
	        image.height = element.height;
		} 
		
		public function ImageElement(data:Element, clip:MovieClip, view:AbstractView) {
			this.element = data;
			this.clip = clip;
			this.view = view;
			data.active = true;
			child = clip.parent.addChild(newImage());
			//child.alpha = 0.4; funciona!
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			image.scaleX = clip.scaleX;
			image.scaleY = clip.scaleY;
			image.x = element.x * clip.scaleX;
			image.y = element.y * clip.scaleY;
		}
		
		private function timeHandler(evt:ModelEvent):void {
			var pos:Number = evt.data.position;
			if (pos > element.end || pos < element.start) {
				clip.parent.removeChild(child);
				view.removeModelListener(ModelEvent.TIME,timeHandler);
				view.removeControllerListener(ControllerEvent.RESIZE,resizeHandler);
				element.active = false;
			}
		}
		
		private function clickHandler(event:MouseEvent):void {
			clip.clickHandler(element, this);
		}
		
		private function stateHandler(evt:ModelEvent):void {
			clip.elementStateHandler(this, image, evt);
		}

	}
}