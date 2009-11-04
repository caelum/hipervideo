package br.com.caelum.hipervideo.links
{
	public class Link
	{
		
		public var content:String;
		public var startTime:Number;
		public var endTime:Number;
		public var topLeft_x:Number;
		public var topLeft_y:Number;
		public var bottomRight_x:Number;
		public var bottomRight_y:Number;
		
		public function Link(content:String,
							startTime:Number, endTime:Number,
							topLeft_x:Number, topLeft_y:Number,
							bottomRight_x:Number, bottomRight_y:Number)
		{
			this.content = content;
			this.startTime = startTime;
			this.endTime = endTime;
			this.topLeft_x = topLeft_x;
			this.topLeft_y = topLeft_y;
			this.bottomRight_x = bottomRight_x;
			this.bottomRight_y = bottomRight_y;
		}

	}
}