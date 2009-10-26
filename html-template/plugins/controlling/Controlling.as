/**
* This is a simple plugin template for controlling the player. 
* It shows a small button in the top left corner of the display that toggles the mute state.
**/
package {


import com.jeroenwijering.events.*;

import flash.display.MovieClip;
import flash.events.MouseEvent;


public class Controlling extends MovieClip implements PluginInterface {


	/** Button clip the graphics will be drawn into. **/
	private var button:MovieClip;
	/** Reference to the View of the player. **/
	private var view:AbstractView;


	/** Constructor; draws a simple button and adds it to the stage. **/
	public function Controlling():void {
		button = new MovieClip();
		button.graphics.beginFill(0x000000,0.5);
		button.graphics.drawRoundRect(10,10,40,40,5);
		button.graphics.beginFill(0xFF0000,1);
		button.graphics.drawCircle(30,30,8);
		addChild(button);
	};


	/**
	* The initialize call is invoked by the player on startup.
	* It gives a reference to the player.
	* 
	* Before this function is called, the player links our "clip" variable to the FLA graphics.
	* In the FLA, the "button" MovieClip we use here is drawn.
	**/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		button.addEventListener(MouseEvent.CLICK,clickHandler);
		button.buttonMode = true;
		button.mouseChildren = false;
	};


	/** The button is clicked, so stop the player. **/
	private function clickHandler(evt:MouseEvent):void {
		view.sendEvent(ViewEvent.MUTE);
	};


};


}