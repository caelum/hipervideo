package br.com.caelum.hipervideo.model
{
	public final class ActionType
	{
		public static const PLAY:String = "PLAY";
		public static const PAUSE:String = "PAUSE";
	 	public static const NOTHING:String = "NOTHING";
	 	public static const ACTIVITY:String = "ACTIVITY";
	 	
	 	public static function fromValue(action:String):String {
	 		switch (action.toLowerCase()) {
	 			case "pause": 
	 				return PAUSE;
 				case "play":
	 				return PLAY;
	 			case "activity":
	 				return ACTIVITY;
	 			default:
	 				return NOTHING;
	 		}
	 	}		
	}
}