package br.com.caelum.hipervideo.model
{
	public class Link
	{
		
		public var tooltip:String;
		public var url:String
		public var time:Number;
		public var thumbnail:String;
		
		public function Link(tooltip:String, 
							thumbnail:String, url:String, time:Number) {
			this.url = url;
			this.time = time;
			this.tooltip = tooltip == "" ? url : tooltip;
			this.thumbnail = thumbnail == "" ? "thumbs/defaultThumb.jpg" : thumbnail;
		}

	}
}