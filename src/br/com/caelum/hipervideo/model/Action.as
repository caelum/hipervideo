package br.com.caelum.hipervideo.model
{	
	public class Action
	{
		
		public var type:String;
		public var time:Number;
		public var data:Object;
		
		public function Action(type:String, time:Number, data:Object=null)
		{
			this.type = type;
			this.time = time;
			this.data = data;
		}

	}
}