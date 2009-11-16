﻿/**
* Show a YouTube searchbar that loads the results into the player.
**/
package br.com.caelum.hipervideo.plugin{

import br.com.caelum.hipervideo.links.Link;

import com.jeroenwijering.events.*;
import com.neoarchaic.ui.Tooltip;

import fl.transitions.*;
import fl.transitions.easing.*;

import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.*;
import flash.net.*;
import flash.utils.*;
import flash.xml.*; 

public class LinkBar extends MovieClip {

	/** Reference to the graphics. **/
	private var clip:MovieClip;	
	
	/** Reference to the View of the player. **/
	private var view:AbstractView;
	private var mySkin:Object;
	private var targX:int;
	
	private var _container:Object;
	private var ShuffleLeft:Object;
	private var ShuffleRight:Object;
	private var Cover:Object;
	private var InfoElement:Object;
	private var Bg:Object;
	private var TemplateClass:Object;
	private var SampleItem:Object;
	private var SpaceFromSides:int;
	private var ClipsVisible:int;
	private var ClipWidth:int;
	private var shuffleBounds:Array;
	 
	private var maxw:int;
	private var maxh:int;
	 	  
    private var title:String;	
    private var links:Array;
    
	public function LinkBar(title:String, links:Array, view:AbstractView, clip:MovieClip) {
		this.title = title;
		this.clip = clip;
		this.view = view;

		//set the original position of the thumbs
		targX = 0;
		
		//If the custom skin is defined, load it in
		if (view.config['drelated.dskin'] != undefined){
			loadMySkin();
		}
		
		this.links = links;
	};
	
    public function setVisible(v:Boolean):void {
    	_container.visible = v;
    	Bg.visible = v;
    	Cover.visible = v;
    	ShuffleLeft.visible = v;
    	ShuffleRight.visible = v;
    	InfoElement.visible = v;
    }



	private function create(links:Array, ClipsVisible:Number):void {
		InfoElement["text"].text = this.title;
		var i:int = 0;
		
		for each (var link:Link in links) {
			var item:Object = _container.addChild(DisplayObject(new TemplateClass()));
			
			item.x = i*(item.thmask.width+5)+SpaceFromSides;
			
			//Load the thumbnail
			var thumbloader:Loader = new Loader();
			thumbloader.contentLoaderInfo.addEventListener(Event.COMPLETE,resizeThumbs);
			thumbloader.load(new URLRequest(link.thumbnail));
			item["holder_mc"].addChild(thumbloader);
			
			item["test"].text = link.tooltip;	// DESCOMENTE PARA TER TOOLTIP EMBAIXO DA FIGURA

			Tooltip.subscribe(DisplayObject(item), link.tooltip, null);
			
			//Make the clip remember what URL it should go to when clicked on
			item.url = link.url;
			item.time = link.time;
			
			//Make the clickable area clickable
			item.clickable.buttonMode = true;
			item.clickable.addEventListener(MouseEvent.CLICK,playClip);
			i++;
		}
		
		// Set the min/max bounds for the shufflebuttons
		shuffleBounds = [0-(i-ClipsVisible)*ClipWidth, 0]
		
		// Add the container enterframe event listner to move the clips when targX is changed
		_container.addEventListener(Event.ENTER_FRAME,shiftClips);
	}

	
	/** Place the elements on stage, stretch and position them to meet our measurements. **/	
	public function resizeMe():void{
		var offset = 0;
		/**If the skin is defined, load the elements from the skin movieclip. 
		The bits and pieces are:
			Bg - the large semitransparent layer that's stretched to exact same size and video
			Cover - the smaller semitransparent layer to bring out the thumbrow and controls;
			shuffle_left, shuffle_right - buttons to scroll the thumbrow to the left or to the right
			infoelement - MovieClip containing textfield with the title for the clips shown
			template - Videoitem
		**/
		if(view.config['drelated.dskin']!=undefined){
			Bg = clip.addChild(mySkin.Bg);
			Cover = clip.addChild(mySkin.Cover);		
			ShuffleLeft = clip.addChild(mySkin.shuffle_left);
			ShuffleRight = clip.addChild(mySkin.shuffle_right);
			InfoElement = clip.addChild(mySkin.infoelement);
			TemplateClass = mySkin.template.constructor;
		}
		//Otherwise create class instances from the documents own library
		else{
			var BgClass:Object = getDefinitionByName ("background") as Class;
			Bg = clip.addChild(DisplayObject(new BgClass()));
			var CoverClass:Object = getDefinitionByName ("cover") as Class;
			Cover = clip.addChild(DisplayObject(new CoverClass()));
			var ShuffleLeftClass:Object = getDefinitionByName ("shuffleLeft") as Class;
			ShuffleLeft = clip.addChild(DisplayObject(new ShuffleLeftClass()));
			var ShuffleRightClass:Object = getDefinitionByName ("shuffleRight") as Class;
			ShuffleRight = clip.addChild(DisplayObject(new ShuffleRightClass()));
			TemplateClass = getDefinitionByName ("Template") as Class;		
			var InfoClass:Object = getDefinitionByName ("infoelement") as Class;
			InfoElement = clip.addChild(DisplayObject(new InfoClass()));
		}
		
		//Create a sample of the clip template for measuring sake
		SampleItem = DisplayObject(new TemplateClass());
		maxw = SampleItem.thmask.width;
	  	maxh = SampleItem.thmask.height;
		
		
		//Place the clip left from the stage
		clip.x = -view.config['width'];
		clip.y = 0;
		
		// Stretch the bg
		Bg.width = view.config['width'];
		Bg.height = view.config['height'];		
		Bg.x = 0;
		Bg.y = 0;
		
		//Create a container object for the clips
		//var ContainerClass:Object = getDefinitionByName ("Container") as Class;
		_container = clip.addChild(DisplayObject(new Sprite()));
		
		//Analyse the dposition flashvar and place the elements according to it.
		if (view.config['fullscreen']) {
			offset = 35;
		}
		switch(view.config['drelated.dposition']) {
			case 'bottom':
				_container.y = view.config['height']-SampleItem.height-offset;
				Cover.y = view.config['height']-SampleItem.height-5-InfoElement.height-offset;
				InfoElement.y = view.config['height']-SampleItem.height-5-InfoElement.height-offset;
				ShuffleLeft.y = view.config['height']-SampleItem.height-offset;
				ShuffleRight.y = view.config['height']-SampleItem.height-offset;
				break;
			case 'center':
				_container.y = (view.config['height']/2)-(SampleItem.height/2);
				Cover.y = (view.config['height']/2)-(SampleItem.height/2)-5-InfoElement.height;
				InfoElement.y = (view.config['height']/2)-(SampleItem.height/2)-5-InfoElement.height
				ShuffleLeft.y = (view.config['height']/2)-(SampleItem.height/2);
				ShuffleRight.y = (view.config['height']/2)-(SampleItem.height/2);
				break;
			default:
				_container.y = 5+InfoElement.height;				
				Cover.y = 0;
				InfoElement.y = 0;
				ShuffleLeft.y = 5+InfoElement.height
				ShuffleRight.y = 5+InfoElement.height
				break;			
		}
		
		//Add some cursors and events to the buttons
		ShuffleLeft.buttonMode = true;
		ShuffleRight.buttonMode = true;
		ShuffleLeft.x = 0;
		ShuffleLeft.addEventListener(MouseEvent.CLICK,shuffleleft)
		ShuffleRight.x = view.config['width'];
		ShuffleRight.addEventListener(MouseEvent.CLICK,shuffleright)
		
		//Stretch the cover
		Cover.height = SampleItem.height+5+InfoElement.height;
		Cover.width = view.config['width'];
		
		// Do some calculations to decide how many clips can we display at once and make sure they are aligned center
		ClipWidth = SampleItem.thmask.width+5;
		var Space:int = view.config['width']-ShuffleRight.width-ShuffleLeft.width;
		ClipsVisible = Math.floor(Space/(ClipWidth));
		var SpaceNeeded:int = ClipsVisible*(ClipWidth);
		SpaceFromSides = (view.config['width']-SpaceNeeded)/2;
		
		//Mask the clipcontainer object
		var square:Sprite = new Sprite();
		square.graphics.beginFill(0xFF0000);
		square.graphics.drawRect(SpaceFromSides, 0, SpaceNeeded, view.config['height']);
		clip.addChild(square);			
		_container.mask = square;
		
		create(links, ClipsVisible);
	}
	
	/** Slide the plugin in when movie complete or paused. **/
	public function stateHandler(evt:ModelEvent):void {
		switch(evt.data.newstate) {
			case ModelStates.BUFFERING:
			case ModelStates.PLAYING:
				SlideMe(false);
				break;
			case ModelStates.PAUSED:
				SlideMe(true);
				break;
			case ModelStates.COMPLETED:
				SlideMe(true);
				break;			
		}
	}	
	
	/** Initialize the skin swf loading **/	
	private function loadMySkin():void{
		var skinloader:Loader = new Loader();
		skinloader.contentLoaderInfo.addEventListener(Event.COMPLETE, displaySkin);
		skinloader.load(new URLRequest(view.config['drelated.dskin']));
	}
	
	/** The skin was loaded, display it, stretch it, and load the thumbs. **/	
	private function displaySkin(e:Event):void{
		mySkin = e.target.content;
		
		resizeMe();
	}

	
	/** Slide the plugin to the center stage when the movie is paused or complete. **/	
	private function SlideMe(showMe:Boolean):void{
		var targetX:int;
		if (showMe){
			targetX = 0;
		} else {
			targetX = -view.config['width'];		
		}
		var myTween:Object = new Tween(clip, "x", None.easeIn ,clip.x,targetX,0.5,true)				
	}
	
	
	//Make the loaded thumb images smaller if it's ridiculously big
	private function resizeThumbs(e:Event):void{		
		if(e.target.width > maxw || e.target.height > maxh){
		  	var ratio_x:Number = maxw/e.target.width;
		  	var ratio_y:Number = maxh/e.target.height;
		  	if(ratio_x>ratio_y){
			  	e.target.content.width = e.target.width*ratio_x;
			  	e.target.content.height = e.target.height*ratio_x;
		  	}
		  	else{
			  	e.target.content.width = e.target.width*ratio_y;
			  	e.target.content.height = e.target.height*ratio_y;
		  	}
	  	}
	}
	
	// Guide the viewer to the link playing related clip when the clip thumb is clicked 
	private function playClip(e:MouseEvent):void{
		var item:Object = e.target.parent;
		
		if (item.url == "") {
			view.sendEvent("SEEK", item.time);
		} else {
			var request:URLRequest = new URLRequest(item.url);
	
			if(view.config['hipervideo.target']!=undefined){
				try {
				  navigateToURL(request, view.config['hipervideo.target']); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			}
			else{
				try {
				  navigateToURL(request); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			}
		}
	}
	
	// Make the clips slide smoothly when shuffled
	private function shiftClips(e:Event):void{
		e.target.x -= (e.target.x-targX)/5;
	}
	
	
	
	//Shuffle left;
	function shuffleleft(e:MouseEvent):void{
		targX += ClipWidth;
		if (targX > shuffleBounds[1]){
			targX = shuffleBounds[1]
			if(targX>0){
				targX = 0;
			}
		}		
	}
	
	//Shuffle right
	function shuffleright(e:MouseEvent):void{
		targX -= ClipWidth;
		if (targX < shuffleBounds[0]){			
			targX = shuffleBounds[0]
			if(targX>0){
				targX = 0;
			}
		}		
	}

}


}