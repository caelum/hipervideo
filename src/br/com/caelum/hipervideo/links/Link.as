package br.com.caelum.hipervideo.links
{
	public class Link
	{
		
		public var content:String;
		public var contentType:String;
		public var textColor:uint;
		public var backgroundColor:uint;
		public var startTime:Number;
		public var endTime:Number;
		public var topLeft_x:Number;
		public var topLeft_y:Number;
		public var bottomRight_x:Number;
		public var bottomRight_y:Number;
		
		public var hasBackgroundColor:Boolean;
		
		public function Link(content:String, contentType:String,
							textColor:String, backgroundColor:String,
							startTime:Number, endTime:Number,
							topLeft_x:Number, topLeft_y:Number,
							bottomRight_x:Number, bottomRight_y:Number)
		{
			this.content = content;
			this.contentType = contentType;
			if (textColor == "") {
				this.textColor = 0xFFFFFF;
			} else {
				this.textColor = uint(textColor);
			}
			this.hasBackgroundColor = backgroundColor != "";
			if (hasBackgroundColor) {
				this.backgroundColor = uint(backgroundColor);
			}
			this.startTime = startTime;
			this.endTime = endTime;
			this.topLeft_x = topLeft_x;
			this.topLeft_y = topLeft_y;
			this.bottomRight_x = bottomRight_x;
			this.bottomRight_y = bottomRight_y;
		}

	}
}