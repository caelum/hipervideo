package br.com.caelum.hipervideo.model
{
	public class Link
	{
		public var activityId:String;
		public var tooltip:String;
		public var url:String
		public var time:Number;
		public var thumbnail:String;
		
		public function Link(activityId:String, tooltip:String, 
							thumbnail:String, url:String, time:Number) {
			this.activityId = activityId;
			this.url = url;
			this.time = time;
			this.tooltip = tooltip == "" ? url : tooltip;
			this.thumbnail = thumbnail == "" ? "thumbs/defaultThumb.jpg" : thumbnail;
		}

	}
}