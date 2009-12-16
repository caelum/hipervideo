package br.com.caelum.hipervideo.model
{
	import br.com.caelum.hipervideo.plugin.FrameElement;
	import br.com.caelum.hipervideo.plugin.ImageElement;
	import br.com.caelum.hipervideo.plugin.TextElement;
	import br.com.caelum.hipervideo.plugin.UnderlineElement;
	
	import com.jeroenwijering.events.AbstractView;
	
	import flash.display.MovieClip;
	
	public class Element {
		public var type:String;
		public var content:String;
		
		public var color:uint;
		public var backgroundColor:uint;
		public var alpha:Number;
		
		public var start:Number;
		public var duration:Number;
		public var end:Number;
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var thickness:Number;
		
		public var hasBackgroundColor:Boolean;
		
		public var link:Link;
		
		public var active:Boolean;
		
		public function Element(type:String, content:String,
							link:Link, 
							color:uint, backgroundColor:String, alpha:Number,
							start:Number, duration:Number,
							x:Number, y:Number,
							width:Number, height:Number, thickness:Number) {
			this.type = type;
			this.content = content;
			this.color =  color;
			this.alpha = alpha;
			
			if (backgroundColor != "") {
				this.hasBackgroundColor = true;
				this.backgroundColor = uint(backgroundColor);
			}
			
			this.start = start;
			this.duration = duration;
			this.end = start + duration;
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.thickness = thickness;
			this.link = link;			
		}
		
		public function build(plugin:MovieClip, view:AbstractView):MovieClip {
			if (type == ElementType.TEXT) {
				return new TextElement(this, plugin, view);
			} else if (type == ElementType.IMAGE) {
				return new ImageElement(this, plugin, view);
			} else if (type == ElementType.FRAME) {
				return new FrameElement(this, plugin, view);
			} else {
				return new UnderlineElement(this, plugin, view);
			}
		}

	}
}