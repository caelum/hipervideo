package br.com.caelum.hipervideo.links
{
	public class Element
	{
		
		public var content:String;
		public var color:uint;
		public var backgroundColor:uint;
		
		public var start:Number;
		public var duration:Number;
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		
		public var hasBackgroundColor:Boolean;
		
		public var link:Link;
		
		public function Element(textContent:String, imageContent:String, 
							color:String, backgroundColor:String,
							tooltip:String, thumbnail:String, url:String,
							start:Number, duration:Number,
							x:Number, y:Number,
							width:Number, height:Number) {
			this.content = textContent == "" ? imageContent : textContent;
			this.color =  color == "" ? 0xFFFFFF : uint(color);
			
			if (backgroundColor != "") {
				this.hasBackgroundColor = true;
				this.backgroundColor = uint(backgroundColor);
			}
			
			this.start = start;
			this.duration = duration;
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			
			this.link = new Link(tooltip, thumbnail, url);
		}

	}
}