/**
* This is a simple plugin that accepts specific flashvars.
**/
package {


import com.jeroenwijering.events.*;

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;


public class Flashvars extends MovieClip implements PluginInterface {


	/** Reference to the plugin flashvars. **/
	public var config:Object = {
		message:'hello world!'
	};
	/** Reference to the textfield that prints the flashvar. **/
	private var field:TextField;
	/** Reference to the View of the player. **/
	private var view:AbstractView;


	/** Constructor. Draws a textfield and places it on the stage. **/
	public function Flashvars():void {
		field = new TextField();
		field.defaultTextFormat = new TextFormat('_sans',14,0xFF0000,true);
		field.x = field.y = 10;
		field.width = 300;
		field.height = 30;
		addChild(field);
	};


	/**
	* The initialize call is invoked by the player on startup.
	*
	* With player 4.4+, the player automatically pushes the flashvars into the 'config' variable.
	* Unfortunately, we still have to do this manually for older players.
	**/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		if(view.config['flashvars.message']) {
			config['message'] = view.config['flashvars.message'];
		}
		field.text = config['message'];
	};


};


}