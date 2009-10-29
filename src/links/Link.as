package links
{
	public class Link
	{
		
		public var content:String;
		public var startTime:int;
		public var endTime:int;
		public var topLeft_x:int;
		public var topLeft_y:int;
		public var bottomRight_x:int;
		public var bottomRight_y:int;
		
		public function Link(content:String,
							startTime:int, endTime:int,
							topLeft_x:int, topLeft_y:int,
							bottomRight_x:int, bottomRight_y:int)
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