package br.com.caelum.hipervideo.plugin
{
	import br.com.caelum.hipervideo.model.Element;
	
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TextElement extends MovieClip {
		
		private var element:Element;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var field:TextField;
		private var child:DisplayObject;
		public var shouldRemove:Boolean;
		
		private function newTextField():TextField {
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			format.size = 14;
			format.align = "left";
			format.font = "arial";
			format.leading = 4;
			format.display = "Hand";
			
			field = new TextField();
			field.x = Infinity;
			field.selectable = false;
			field.multiline = true;
			field.wordWrap = true;
			field.defaultTextFormat = format;
			field.mouseEnabled = true;
			
			field.htmlText = element.content;
			field.width = element.width;
			field.height = element.height;
			field.textColor = element.color;
			field.background = element.hasBackgroundColor;
			field.backgroundColor = element.backgroundColor;
			field.alpha = element.alpha;
			field.filters = new Array(new DropShadowFilter(0,45,0,1,2,2,10,3));
			
			field.addEventListener(MouseEvent.CLICK, clickHandler);
			
			return field;
		}
		
		public function TextElement(data:Element, clip:MovieClip, view:AbstractView) {
			this.element = data;
			this.clip = clip;
			this.view = view;
			element.active = true;
			child = clip.parent.addChild(newTextField());
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			view.addModelListener(ModelEvent.STATE,stateHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			field.scaleX = clip.scaleX;
			field.scaleY = clip.scaleY;
			field.x = element.x * clip.scaleX;
			field.y = element.y * clip.scaleY;
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
			clip.elementStateHandler(this, field, evt);
		}

	}
}