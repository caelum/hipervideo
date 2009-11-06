﻿/**
* Show a YouTube searchbar that loads the results into the player.
**/
package com.delfi.drelated{


import com.jeroenwijering.events.*;

import fl.transitions.*;
import fl.transitions.easing.*;

import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.*;
import flash.net.*;
import flash.utils.*;
import flash.xml.*; 

public class RelatedVideos extends MovieClip implements PluginInterface {


	/** Reference to the View of the player. **/
	private var view:AbstractView;
	/** Reference to the graphics. **/
	private var clip:MovieClip;	
	/** initialize call for backward compatibility. **/
	public var initialize:Function = initializePlugin;
	
	public var XMLLoader:URLLoader;
	private var VideoXML:XML;
	 
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
	  private var targX:int;
	  private var shuffleBounds:Array;
	  private var mySkin:Object;
	  private var maxw:int;
	  private var maxh:int;
	 	  
      
	
	/** Constructor; nothing going on. **/
	public function RelatedVideos() {
		clip = this;
	};


	/** The initialize call is invoked by the player View. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		
		//set the original position of the thumbs
		targX = 0;
		
		//If the custom skin is defined, load it in
		if(view.config['drelated.dskin']!=undefined){
			loadMySkin();
		}
		//Otherwise move on to resizing stuff to match the clips measurements and load the thumbs
		else{			
			resizeMe();
			getRelatedClips(view.config['drelated.dxmlpath']);		
		}
		view.addModelListener(ModelEvent.STATE,stateHandler);			
	};
	
	/** Initialize the skin swf loading **/	
	private function loadMySkin():void{
		var skinloader:Loader = new Loader();
		skinloader.contentLoaderInfo.addEventListener(Event.COMPLETE,displaySkin);
		skinloader.load(new URLRequest(view.config['drelated.dskin']));
		
	}
	
	/** The skin was loaded, display it, stretch it, and load the thumbs. **/	
	private function displaySkin(e:Event):void{		
		mySkin = e.target.content;
		resizeMe();
		getRelatedClips(view.config['drelated.dxmlpath']);		
	}
	
	/** Place the elements on stage, stretch and position them to meet our measurements. **/	
	private function resizeMe():void{
		
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
		//var mane:Container = new Container();
		//var ContainerClass:Object = getDefinitionByName ("Container") as Class;
		_container = clip.addChild(DisplayObject(new Sprite()));
		
		//Analyse the dposition flashvar and place the elements according to it.
		switch(view.config['drelated.dposition']) {
			case 'bottom':
				_container.y = view.config['height']-SampleItem.height;
				Cover.y = view.config['height']-SampleItem.height-5-InfoElement.height;
				InfoElement.y = view.config['height']-SampleItem.height-5-InfoElement.height
				ShuffleLeft.y = view.config['height']-SampleItem.height;
				ShuffleRight.y = view.config['height']-SampleItem.height;
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
	}
	
	/** Slide the plugin to the center stage when the movie is paused or complete. **/	
	private function SlideMe(showMe:Boolean):void{
		var targetX:int;
		if(showMe==true){
			targetX = 0;
		}
		else{
			targetX = -view.config['width'];		
		}
		var myTween:Object = new Tween(clip, "x", None.easeIn ,this.x,targetX,0.5,true)				
	}
	
	/** Load the XML for the related clips. **/		
	private function getRelatedClips(path:String):void{
		XMLLoader = new URLLoader();
		XMLLoader.addEventListener(Event.COMPLETE,parseXML);
		XMLLoader.load(new URLRequest(path));
	}
	
	/** Parse the XML and do some magic with it. **/	
	private function parseXML(e:Event):void {
		VideoXML = new XML(e.target.data);
		InfoElement["text"].text = VideoXML.title;
		var VideoList:XMLList = VideoXML.video;
		var i:int = 0
		
		//For each clip in xml, place an instance of the template to the container
		for each(var video:XML in VideoList){
			var VideoItem:Object = _container.addChild(DisplayObject(new TemplateClass()));
			VideoItem["test"].text = video.title;
			VideoItem.x = i*(VideoItem.thmask.width+5)+SpaceFromSides;			
		
			//Load the thumbnail
			var thumbloader:Loader = new Loader();
			thumbloader.contentLoaderInfo.addEventListener(Event.COMPLETE,resizeThumbs);
			thumbloader.load(new URLRequest(video.thumb));			
			VideoItem["holder_mc"].addChild(thumbloader);			
			
			//Make the clip remember what URL it should go to when clicked on
			VideoItem.cliptarget = video.url;
			
			//Make the clickable area clickable
			VideoItem.clickable.buttonMode = true;
			VideoItem.clickable.addEventListener(MouseEvent.CLICK,playClip)
			i++;
		}
		// Set the min/max bounds for the shufflebuttons
		shuffleBounds = [0-(i-4)*ClipWidth, 0]
		
		// Add the container enterframe event listner to move the clips when targX is changed
		_container.addEventListener(Event.ENTER_FRAME,shiftClips);
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
		var request:URLRequest = new URLRequest(e.target.parent.cliptarget);

		if(view.config['drelated.dtarget']!=undefined){
			try {
			  navigateToURL(request, view.config['drelated.dtarget']); 
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
	
	// Make the clips slide smoothly when shuffled
	private function shiftClips(e:Event):void{
		e.target.x -= (e.target.x-targX)/5;
	}
	
	/** Slide the plugin in when movie complete or paused. **/
	private function stateHandler(evt:ModelEvent):void { 
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