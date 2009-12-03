package br.com.caelum.hipervideo.model
{
	public class Hipervideo
	{
		public var video:String;
		public var elements:Array;
		public var actions:Array;
		public var playlist:Array;
		public var current:Number;
		
		public function Hipervideo(video:String, elements:Array, actions:Array, playlist:Array, current:Number)
		{
			this.video = video;
			this.elements = elements;
			this.actions = actions;
			this.playlist = playlist;
			this.current = current;
		}

	}
}