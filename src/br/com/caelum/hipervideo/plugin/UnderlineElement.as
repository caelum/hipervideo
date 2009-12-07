package br.com.caelum.hipervideo.plugin
{
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class UnderlineElement extends MovieClip	{
		
		private var data:Object;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var childL:DisplayObject;
		private var childA:DisplayObject;
		public var shouldRemove:Boolean;
		
		private var line:TextField;
		private var clickArea:TextField;
		
		private var HEIGHT:Number = 2;
		
		private function newUnderline(data:Object):void {
			line = new TextField();
			line.width = data['width'];
			line.height = HEIGHT;
			line.background = true;
			line.backgroundColor = data['color'];
			
			clickArea = new TextField();
			clickArea.width = data['width'];
			clickArea.height = data['height'];
			
			clickArea.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function UnderlineElement(data:Object, clip:MovieClip, view:AbstractView) {
			this.data = data;
			this.clip = clip;
			this.view = view;
			data['active'] = true;
			newUnderline(data);
			childL = clip.parent.addChild(line);
			childA = clip.parent.addChild(clickArea);
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			clickArea.x = data['topLeft_x'] * clip.scaleX;
			clickArea.y = data['topLeft_y'] * clip.scaleY;
			line.x = data['topLeft_x'] * clip.scaleX;
			line.y = ( data['topLeft_y'] + data['height'] - HEIGHT) * clip.scaleY;
			
			clickArea.scaleX = clip.scaleX;
			clickArea.scaleY = clip.scaleY;
			line.scaleX = clip.scaleX;
			line.scaleY = clip.scaleY;
		}
		
		private function timeHandler(evt:ModelEvent):void {
			var pos:Number = evt.data.position;
			if (pos > data['end'] || pos < data['begin']) {
				clip.parent.removeChild(childL);
				clip.parent.removeChild(childA);
				view.removeModelListener(ModelEvent.TIME,timeHandler);
				view.removeControllerListener(ControllerEvent.RESIZE,resizeHandler);
				data['active'] = false;
			}
		}
		
		private function clickHandler(event:MouseEvent):void {
			clip.clickHandler(data, this);
		}
		
		private function stateHandler(evt:ModelEvent):void {
			clip.elementStateHandler(this, line, evt);
			clip.elementStateHandler(this, clickArea, evt);
		}

	}
}