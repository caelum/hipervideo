package br.com.caelum.hipervideo.model
{
	public class Link
	{
		public var activityId:String;
		public var tooltip:String;
		public var url:String;
		public var target:String;
		public var time:Number;
		public var video:String;
		public var thumbnail:String;
		public var action:String;
		
		public function Link(activityId:String, tooltip:String, 
							thumbnail:String, url:String, target:String, time:Number, video:String, action:String) {
			this.activityId = activityId;
			this.url = url;
			this.target = target == "" ? "_self" : target;
			this.time = time;
			this.video = video;
			this.tooltip = tooltip == "" ? url : tooltip;
			this.thumbnail = thumbnail == "" ? "thumbs/defaultThumb.jpg" : thumbnail;
			this.action = action;
		}

	}
}