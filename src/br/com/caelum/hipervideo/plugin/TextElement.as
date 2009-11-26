package br.com.caelum.hipervideo.plugin
{
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TextElement extends MovieClip
	{
		private var data:Object;
		private var endTime:Number;
		private var clip:MovieClip;
		private var view:AbstractView;
		private var field:TextField;
		private var child:DisplayObject;
		
		private function newTextField(data:Object):TextField {
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			format.size = 14;
			format.align = "center";
			format.font = "arial";
			format.leading = 4;
			
			field = new TextField();
			field.x = Infinity;
			field.selectable = false;
			field.multiline = true;
			field.wordWrap = true;
			field.defaultTextFormat = format;
			field.mouseEnabled = true;
			
			field.htmlText = data['content'];
			field.width = data['width'];
			field.height = data['height'];
			field.textColor = data['textColor'];
			field.background = data['hasBackgroundColor'];
			field.backgroundColor = data['backgroundColor'];
			field.filters = new Array(new DropShadowFilter(0,45,0,1,2,2,10,3));
			
			//field.addEventListener(MouseEvent.CLICK, clickHandler);
			
			return field;
		}
		
		public function TextElement(data:Object, clip:MovieClip, view:AbstractView)
		{
			this.data = data;
			this.clip = clip;
			this.view = view;
			data['active'] = true;
			child = clip.parent.addChild(newTextField(data));
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			view.addModelListener(ModelEvent.TIME,timeHandler);
			resizeHandler(null);
		}
		
		private function resizeHandler(evt:ControllerEvent=undefined):void {
			field.scaleX = clip.scaleX;
			field.scaleY = clip.scaleY;
			field.x = data['topLeft_x'] * clip.scaleX;
			field.y = data['topLeft_y'] * clip.scaleY;
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

	}
}