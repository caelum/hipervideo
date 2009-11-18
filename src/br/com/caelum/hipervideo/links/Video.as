package br.com.caelum.hipervideo.links
{
	public class Video
	{
		
		public var elements:Array;
		public var actions:Array;
		public var playlist:Array;
		public var current:Number;
		
		public function Video(elements:Array, actions:Array, playlist:Array, current:Number)
		{
			this.elements = elements;
			this.actions = actions;
			this.playlist = playlist;
			this.current = current;
		}

	}
}