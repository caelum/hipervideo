package br.com.caelum.hipervideo.plugin
{
	import br.com.caelum.hipervideo.model.Element;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class UnderlineElement extends MovieClip	{
		
		private var element:Element;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var childLine:DisplayObject;
		private var childArea:DisplayObject;
		public var shouldRemove:Boolean;
		
		private var line:TextField;
		private var clickArea:TextField;
		
		private var HEIGHT:Number = 2;
		
		private function newUnderline():void {
			line = new TextField();
			line.width = element.width;
			line.height = HEIGHT;
			line.background = true;
			line.backgroundColor = element.color;
			
			clickArea = new TextField();
			clickArea.width = element.width;
			clickArea.height = element.height;
			
			clickArea.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function UnderlineElement(data:Element, clip:MovieClip, view:AbstractView) {
			this.element = data;
			this.clip = clip;
			this.view = view;
			element.active = true;
			newUnderline();
			childLine = clip.parent.addChild(line);
			childArea = clip.parent.addChild(clickArea);
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			clickArea.scaleX = clip.scaleX;
			clickArea.scaleY = clip.scaleY;
			line.scaleX = clip.scaleX;
			line.scaleY = clip.scaleY;
			
			clickArea.x = element.x * clip.scaleX;
			clickArea.y = element.y * clip.scaleY;
			line.x = element.x * clip.scaleX;
			line.y = ( element.y + element.height - HEIGHT) * clip.scaleY;
		}
		
		private function timeHandler(evt:ModelEvent):void {
			var pos:Number = evt.data.position;
			if (pos > element.end || pos < element.start) {
				clip.parent.removeChild(childLine);
				clip.parent.removeChild(childArea);
				view.removeModelListener(ModelEvent.TIME,timeHandler);
				view.removeControllerListener(ControllerEvent.RESIZE,resizeHandler);
				element.active = false;
			}
		}
		
		private function clickHandler(event:MouseEvent):void {
			clip.clickHandler(element, this);
		}
		
		private function stateHandler(evt:ModelEvent):void {
			clip.elementStateHandler(this, line, evt);
			clip.elementStateHandler(this, clickArea, evt);
		}

	}
}