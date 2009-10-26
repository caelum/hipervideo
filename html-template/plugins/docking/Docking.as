/**
* This is a simple plugin that accepts specific flashvars.
**/
package {


import com.jeroenwijering.events.*;

import flash.display.MovieClip;
import flash.events.MouseEvent;


public class Docking extends MovieClip implements PluginInterface {


	/** This code embeds the dock image. **/
	[Embed(source="./button.png")]
	private const DockIcon:Class;


	/** Reference to the button in the dock flashvars. **/
	private var button:MovieClip;
	/** Reference to the red area. **/
	private var red:MovieClip;
	/** Reference to the View of the player. **/
	private var view:AbstractView;


	/** Constructor; draws (and hides) the background graphic. **/
	public function Docking():void {
		red = new MovieClip();
		red.graphics.beginFill(0xFF0000);
		red.graphics.drawRect(0,0,400,300);
		red.visible = false;
		addChild(red);
	};


	/** 
	* This function is called when the dock button is clicked.
	* It toggles the display of the red area ánd the caption of the dock button.
	**/
	private function clickHandler(evt:MouseEvent):void {
		if(red.visible) {
			red.visible = false;
			button.field.text = "show me";
		} else {
			red.visible = true;
			button.field.text = "hide me";
		}
	};


	/**
	* The initialize call is invoked by the player on startup.
	*
	* With player 4.5+, A 'dock' plugin is available. We check for this.
	* If available, the button is created.
	**/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		if(view.getPlugin('dock')) {
			button = view.getPlugin('dock').addButton(new DockIcon(),'show me',clickHandler);
		}
	};


};


}