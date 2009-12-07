package br.com.caelum.hipervideo.model
{
	public class Element
	{
		public var type:String;
		
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
		
		public function Element(type:String, content:String,
							link:Link, 
							color:uint, backgroundColor:String,
							start:Number, duration:Number,
							x:Number, y:Number,
							width:Number, height:Number) {
			this.type = type;
			this.content = content;
			this.color =  color;
			
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
			this.link = link;			
		
		}

	}
}