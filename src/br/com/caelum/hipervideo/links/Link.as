package br.com.caelum.hipervideo.links
{
	public class Link
	{
		
		public var tooltip:String;
		public var url:String;
		public var thumbnail:String;
		
		public function Link(tooltip:String, 
							thumbnail:String, url:String) {
			this.url = url;
			this.tooltip = tooltip == "" ? url : tooltip;
			this.thumbnail = thumbnail == "" ? "thumbs/defaultThumb.jpg" : thumbnail;
		}

	}
}