/**
* This plugin template listens to a few playback events of the player.
**/
package {


import com.jeroenwijering.events.*;

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;


public class Listening extends MovieClip implements PluginInterface {


	/** Reference to the plugin flashvars. **/
	public var config:Object = {};
	/** Reference to the textfiled we'll print messages in. **/
	public var field:TextField;
	/** Reference to the View of the player. **/
	private var view:AbstractView;


	/** Constructor. Formats a textfield and places it on the display. **/
	public function Listening():void {
		field = new TextField();
		field.defaultTextFormat = new TextFormat('_sans',14,0xFF0000,true);
		field.x = field.y = 10;
		field.width = 300;
		field.height = 30;
		addChild(field);
	};


	/**
	* The initialize call is invoked by the player on startup.
	* It gives a reference to the player.
	* With it, we can start listening to the time and playback state.
	**/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		view.addModelListener(ModelEvent.STATE,stateHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
	};


	/** This function is called each time the playback state changes. **/
	private function stateHandler(evt:ModelEvent):void {
		switch(evt.data.newstate) {
			case ModelStates.PAUSED:
				field.text = 'video paused';
				break;
			case ModelStates.COMPLETED:
				field.text = 'video completed';
				break;
			case ModelStates.PLAYING:
				// nothing here, since now the time is updating.
				break;
			case ModelStates.IDLE:
				field.text = 'video idle';
				break;
			case ModelStates.BUFFERING:
				field.text = 'video buffering';
				break;
		}
	};


	/** 
	* This function is called each time the playhead position in the video changes.
	* Note the "view.config['state']" flashvar, which conveniently stores the latest playback state.
	**/
	private function timeHandler(evt:ModelEvent):void {
		if(view.config['state'] == ModelStates.PLAYING) {
			var dur:Number = evt.data.duration;
			var pos:Number = evt.data.position;
			var txt:String = Math.round(dur-pos)+" seconds left";
			field.text = txt;
		}
	};


};


}