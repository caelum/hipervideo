package br.com.caelum.hipervideo.plugin
{
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.ModelStates;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class ImageElement extends MovieClip
	{
		private var data:Object;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var image:Loader;
		private var child:DisplayObject;
		
		private function newImage(data:Object):Loader {
			
			image = new Loader();
			image.load(new URLRequest(data['content']));
			child = addChild(image);
			
			image.addEventListener(MouseEvent.CLICK, clickHandler);
			return image;
		}
		
		public function ImageElement(data:Object, clip:MovieClip, view:AbstractView)
		{
			this.data = data;
			this.clip = clip;
			this.view = view;
			data['active'] = true;
			child = clip.parent.addChild(newImage(data));
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			image.scaleX = clip.scaleX;
			image.scaleY = clip.scaleY;
			image.x = data['topLeft_x'] * clip.scaleX;
			image.y = data['topLeft_y'] * clip.scaleY;
		}
		
		private function timeHandler(evt:ModelEvent):void {
			var pos:Number = evt.data.position;
			if (pos > data['end'] || pos < data['begin']) {
				clip.parent.removeChild(child);
				view.removeModelListener(ModelEvent.TIME,timeHandler);
				view.removeControllerListener(ControllerEvent.RESIZE,resizeHandler);
				data['active'] = false;
			}
		}
		
		private function clickHandler(event:MouseEvent):void {
			clip.clickHandler(data);
		}
		
		private function stateHandler(evt:ModelEvent):void {
			switch(evt.data.newstate) {
				case ModelStates.PLAYING:
					image.visible = true;
					break;
				case ModelStates.PAUSED:
					if (!view.config['autoPaused']) {
						image.visible = false;	
					}
					break;
				case ModelStates.COMPLETED:
					image.visible = false;
					break;			
			}
		}

	}
}