package br.com.caelum.hipervideo.plugin
{
	import br.com.caelum.hipervideo.model.Element;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class FrameElement extends MovieClip {
		
		private var element:Element;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		public var shouldRemove:Boolean;
		private var child:DisplayObject;

		public function FrameElement(data:Element, clip:MovieClip, view:AbstractView) {
			this.element = data;
			this.clip = clip;
			this.view = view;
			element.active = true;

			width = element.width;
			height = element.height;
			
			var offset:Number = element.thickness / 2;
			
			graphics.lineStyle(element.thickness, element.color, 1, false, "normal", null, JointStyle.BEVEL);
			graphics.moveTo(0+offset, 0+offset)
			graphics.lineTo(element.width-offset, 0+offset);
			graphics.lineTo(element.width-offset, element.height-offset);
			graphics.lineTo(0+offset, element.height-offset);
			graphics.lineTo(0+offset, 0+offset);
						
			child = clip.parent.addChild(this);

			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			scaleX = clip.scaleX;
			scaleY = clip.scaleY;
			x = element.x * clip.scaleX;
			y = element.y * clip.scaleY;
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
//			clip.elementStateHandler(this, field, evt);
		}

	}
}