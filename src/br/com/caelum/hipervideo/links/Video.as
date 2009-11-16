package br.com.caelum.hipervideo.links
{
	public class Video
	{
		
		public var elements:Array;
		public var playlist:Array;
		public var current:Number;
		
		public function Video(elements:Array, playlist:Array, current:Number)
		{
			this.elements = elements;
			this.playlist = playlist;
			this.current = current;
		}

	}
}