package br.com.caelum.hipervideo.model
{
	public class Hipervideo
	{
		public var video:String;
		public var next:String;
		public var elements:Array;
		public var actions:Array;
		public var playlist:Array;
		
		public function Hipervideo(video:String, next:String, elements:Array, actions:Array, playlist:Array)
		{
			this.video = video;
			this.next = next;
			this.elements = elements;
			this.actions = actions;
			this.playlist = playlist;
		}

	}
}